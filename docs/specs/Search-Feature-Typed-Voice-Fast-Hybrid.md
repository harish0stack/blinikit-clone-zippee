# Spec: Search Feature (Typed + Voice) — Fast, Hybrid, Zero-Cost Voice Transcription
### Companion to SESSION_CONTEXT.md — implements the search bar/mic from Screen 0, replaces the earlier "Search for atta, dal..." stub
### Target: Flutter + Riverpod + Hive (local catalog cache, already implemented) + Supabase (Postgres full-text search)

---

## 0. What I found from your screenshots (this drives the whole design)

**Image 4 is the key finding.** Tapping Blinkit's mic button doesn't open a custom in-house transcription UI — it launches **Android's own system speech-recognition dialog** ("Google — Speak now — English (India)", with the disclosure "Google speech services converts audio to text and…"). That's the stock `RecognizerIntent`/`SpeechRecognizer` dialog every Android app gets for free from Google Play Services — the same thing that powers voice typing in every keyboard and the Google Search widget. **Blinkit is not running Whisper or any custom/paid ASR model.** They're using the OS's built-in, zero-cost speech engine and just reading back the transcribed string.

This directly answers your "no big LLMs, no API keys, local-based" requirement — it's not a workaround, it's literally how the app you're cloning does it.

**Images 2–3 are the pre-query "browse" state of the search screen**, not filtered results (the search field is empty in both). This is the screen to clone pixel-for-pixel: Recent searches → Continue browsing for → Trending in your city → Your wishlist. I'll also spec the results-state layout (what replaces this once a query is typed), since that's implied but not in your screenshots.

**How Blinkit's search is fast in general (industry-standard pattern, not literally visible in the screenshots but standard for this class of app):** two layers working together —
1. **Instant, local, zero-network suggestions** the moment you start typing, served from an already-downloaded product catalog cached on-device (you already have this — your locked stack's Hive local cache).
2. A **debounced backend query** (fires ~250–300ms after you stop typing, not on every keystroke) that hits an indexed full-text search on the server for full-catalog coverage, which then reconciles with/replaces the instant local results.

This is exactly what makes it feel instant: the first result you see never waited on a network round-trip.

---

## 1. Architecture: hybrid local-first search

```
User types "mil"
      │
      ├─► Instant path (every keystroke, <16ms, no network):
      │   search the in-memory Hive-backed catalog index for
      │   prefix/contains matches → render immediately
      │
      └─► Debounced path (300ms after last keystroke):
          call Supabase RPC `search_products(query)` →
          Postgres full-text + trigram search →
          merge into the result list, dedupe by product id,
          re-rank by combined score
```

Both paths write into the **same result list state** (a single Riverpod provider), so the UI never has two competing render paths — the instant path populates it first, the backend path refines/extends it a moment later without a visible "flash" if implemented as an additive merge rather than a replace.

### 1.1 Local instant search (Hive-backed)

You already cache the product catalog in Hive per your locked architecture. Build a lightweight **in-memory search index** from that cache once at app start (and refresh whenever the catalog syncs via your Phase 3 realtime sync):

```dart
// core/search/local_search_index.dart
class LocalSearchIndex {
  final List<ProductSearchEntry> _entries = [];

  void buildFromCatalog(List<Product> products) {
    _entries
      ..clear()
      ..addAll(products.map((p) => ProductSearchEntry(
            id: p.id,
            name: p.name.toLowerCase(),
            category: p.categoryName.toLowerCase(),
            product: p,
          )));
  }

  /// Cheap, synchronous, no async/isolate needed for catalogs up to a
  /// few tens of thousands of SKUs — this runs well under a frame budget.
  List<Product> search(String rawQuery, {int limit = 20}) {
    final query = rawQuery.trim().toLowerCase();
    if (query.isEmpty) return [];

    final scored = <_ScoredEntry>[];
    for (final entry in _entries) {
      final score = _score(entry, query);
      if (score > 0) scored.add(_ScoredEntry(entry.product, score));
    }
    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.take(limit).map((s) => s.product).toList();
  }

  int _score(ProductSearchEntry entry, String query) {
    if (entry.name == query) return 100;               // exact match
    if (entry.name.startsWith(query)) return 80;         // prefix match
    if (entry.name.contains(query)) return 60;           // substring match
    if (entry.category.contains(query)) return 40;       // category match
    // cheap typo tolerance: allow one-word-boundary fuzzy contains
    final words = entry.name.split(' ');
    for (final w in words) {
      if (_withinOneEdit(w, query)) return 50;
    }
    return 0;
  }

  bool _withinOneEdit(String a, String b) {
    // simple Damerau-Levenshtein-lite check, capped — good enough for
    // single-typo tolerance ("mlk" -> "milk") without pulling in a package
    if ((a.length - b.length).abs() > 1) return false;
    int i = 0, j = 0, edits = 0;
    while (i < a.length && j < b.length) {
      if (a[i] == b[j]) { i++; j++; continue; }
      edits++;
      if (edits > 1) return false;
      if (a.length > b.length) i++;
      else if (a.length < b.length) j++;
      else { i++; j++; }
    }
    return true;
  }
}

class ProductSearchEntry {
  final String id, name, category;
  final Product product;
  ProductSearchEntry({required this.id, required this.name, required this.category, required this.product});
}

class _ScoredEntry {
  final Product product;
  final int score;
  _ScoredEntry(this.product, this.score);
}
```

This runs entirely on-device, synchronously, against data you already have cached — it's the reason the first keystroke feels instant, and it works fully offline.

### 1.2 Backend search (Supabase / Postgres)

For coverage beyond whatever's currently cached on this specific device (new products since last sync, less-common items, full catalog breadth), add a proper indexed full-text search to Postgres. Raw `ILIKE '%query%'` does not scale or perform well past a small catalog and has no typo tolerance — use Postgres's built-in full-text search combined with `pg_trgm` for fuzzy/typo-tolerant matching, both native to Postgres (no extra service to run, fits your "Supabase only, no extra infra" locked stack).

```sql
-- Enable trigram matching (typo tolerance + partial-word matching)
create extension if not exists pg_trgm;
create extension if not exists unaccent;

-- Full-text search column, generated automatically from name+description
alter table products
  add column search_vector tsvector
  generated always as (
    to_tsvector('english', coalesce(name, '') || ' ' || coalesce(description, ''))
  ) stored;

-- GIN index for full-text search
create index if not exists products_search_vector_idx
  on products using gin(search_vector);

-- GIN trigram index for fuzzy/typo-tolerant + prefix matching on name
create index if not exists products_name_trgm_idx
  on products using gin(name gin_trgm_ops);
```

**Search RPC function** (combines full-text rank + trigram similarity, returns one ranked result set — call this from Flutter via `supabase.rpc()`, which the PostgREST layer exposes automatically):

```sql
create or replace function search_products(search_query text, result_limit int default 20)
returns setof products
language sql stable
as $$
  select p.*
  from products p
  where p.status = 'live'
    and (
      p.search_vector @@ plainto_tsquery('english', search_query)
      or p.name % search_query  -- pg_trgm similarity operator, catches typos
    )
  order by
    ts_rank(p.search_vector, plainto_tsquery('english', search_query)) desc,
    similarity(p.name, search_query) desc
  limit result_limit;
$$;
```

`stable` (not `volatile`) lets Postgres's query planner cache execution plans more aggressively across calls — a small but real win at high query volume.

### 1.3 Wiring it together in Flutter

```dart
// features/search/controllers/search_controller.dart
class SearchController extends StateNotifier<SearchState> {
  final LocalSearchIndex _localIndex;
  final SupabaseClient _supabase;
  Timer? _debounce;
  int _requestToken = 0; // guards against stale/out-of-order network responses

  SearchController(this._localIndex, this._supabase) : super(SearchState.initial());

  void onQueryChanged(String query) {
    state = state.copyWith(query: query);

    if (query.trim().isEmpty) {
      state = state.copyWith(results: [], isSearching: false);
      return;
    }

    // 1. Instant local results — synchronous, no debounce needed
    final localResults = _localIndex.search(query);
    state = state.copyWith(results: localResults, isSearching: true);

    // 2. Debounced backend query
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () => _runBackendSearch(query));
  }

  Future<void> _runBackendSearch(String query) async {
    final myToken = ++_requestToken;
    try {
      final response = await _supabase.rpc('search_products', params: {
        'search_query': query,
        'result_limit': 20,
      });
      if (myToken != _requestToken) return; // a newer query superseded this one, discard

      final backendResults = (response as List).map((r) => Product.fromJson(r)).toList();
      final merged = _mergeDedupe(state.results, backendResults);
      state = state.copyWith(results: merged, isSearching: false);
    } catch (e) {
      // Backend failed/offline — local results (already shown) remain valid,
      // just stop the loading indicator rather than clearing anything.
      if (myToken == _requestToken) state = state.copyWith(isSearching: false);
    }
  }

  List<Product> _mergeDedupe(List<Product> local, List<Product> backend) {
    final seen = <String>{};
    final merged = <Product>[];
    for (final p in [...backend, ...local]) { // backend results take priority in ordering
      if (seen.add(p.id)) merged.add(p);
    }
    return merged;
  }
}
```

The `_requestToken` guard matters at scale: without it, a fast typer can trigger overlapping network calls where an older, slower response arrives *after* a newer one and overwrites it with stale results — a classic race condition that gets worse (not better) the more responsive your UI otherwise is.

---

## 2. Scaling this to 20,000 concurrent users

- **Indexes are the whole story here.** Both the GIN full-text index and the GIN trigram index turn `search_products` into an indexed lookup rather than a sequential scan — this is what lets Postgres handle high query volume without the search feature becoming your bottleneck. Verify with `EXPLAIN ANALYZE select * from search_products('milk')` that both indexes are actually being used (look for `Bitmap Index Scan` / `Index Scan`, not `Seq Scan`).
- **Debouncing is your primary load-shedding mechanism.** 300ms of client-side debounce on a fast typer eliminates the vast majority of would-be requests — without it, a 20K-concurrent user base typing 5-character queries would generate roughly 5x the search traffic for zero UX benefit.
- **The local-first layer is also a load-shedding mechanism, not just a UX one** — many searches (repeat searches for common items, or fast typers who complete their query within the debounce window and then tap a local result before the backend call even lands) never hit the backend at all.
- **Supavisor pooler (port 6543, already locked)** handles the connection concurrency correctly here — nothing extra needed, just don't accidentally route this RPC call through a raw 5432 connection.
- **Consider a short server-side cache for the most popular queries** if you see specific terms ("milk", "bread", "chips") dominating search volume in production — a `trending_searches` materialized view refreshed periodically (Section 4) doubles as this cache, since the app can check it before hitting `search_products` for well-known popular terms.
- **k6 addition (Phase 8):** add a search scenario that simulates realistic typing patterns (multiple rapid `search_products` calls per simulated user representing a typed query, not just one call per user) so load testing reflects actual debounce-shaped traffic rather than one-shot requests.

---

## 3. Voice search — free, on-device, no API keys

### 3.1 Package

```yaml
dependencies:
  speech_to_text: ^7.3.0   # wraps Android SpeechRecognizer + iOS Speech framework natively
```

This is the mature, actively maintained plugin for exactly this — it's a thin Dart wrapper around the same OS-level speech engine your Image 4 screenshot shows Blinkit using. No API key, no network call your app makes directly (the OS/Play Services layer handles that transparently, same as it does for every other app using system dictation), no model to bundle or run yourself.

### 3.2 Permissions

`android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
```

`ios/Runner/Info.plist`:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>Used for voice search</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>Used to convert your spoken search into text</string>
```

### 3.3 Service wrapper

```dart
// core/services/voice_search_service.dart
class VoiceSearchService {
  final _speech = stt.SpeechToText();
  bool _initialized = false;

  Future<bool> initialize() async {
    if (_initialized) return true;
    _initialized = await _speech.initialize(
      onStatus: (status) => debugPrint('[Voice] status: $status'),
      onError: (error) => debugPrint('[Voice] error: ${error.errorMsg}'),
    );
    return _initialized;
  }

  Future<void> startListening({
    required void Function(String text, bool isFinal) onResult,
    required void Function(double level) onSoundLevel,
  }) async {
    final available = await initialize();
    if (!available) return;

    await _speech.listen(
      localeId: 'en_IN', // English (India), matching the target transcription language
      onResult: (result) => onResult(result.recognizedWords, result.finalResult),
      onSoundLevelChange: onSoundLevel, // drives the waveform animation, Section 3.4
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,       // stream text as the user speaks, not just at the end
        cancelOnError: true,
        listenMode: stt.ListenMode.search, // tuned for short search phrases, not dictation
      ),
    );
  }

  Future<void> stopListening() => _speech.stop();
  bool get isListening => _speech.isListening;
}
```

### 3.4 The "listening" animation (your "whisper flow" ask)

Custom pulsing-waveform overlay, driven by the plugin's own `onSoundLevelChange` callback (a real amplitude signal from the mic, not a fake decorative loop) — no external asset/Lottie file needed:

```dart
// features/search/widgets/voice_listening_overlay.dart
class VoiceListeningOverlay extends StatefulWidget {
  final VoidCallback onCancel;
  const VoiceListeningOverlay({super.key, required this.onCancel});

  @override
  State<VoiceListeningOverlay> createState() => _VoiceListeningOverlayState();
}

class _VoiceListeningOverlayState extends State<VoiceListeningOverlay>
    with SingleTickerProviderStateMixin {
  final _voiceService = VoiceSearchService();
  String _transcript = '';
  double _soundLevel = 0.0;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _voiceService.startListening(
      onResult: (text, isFinal) {
        setState(() => _transcript = text);
        if (isFinal && text.isNotEmpty) _finish(text);
      },
      onSoundLevel: (level) => setState(() => _soundLevel = level.clamp(0, 10) / 10),
    );
  }

  void _finish(String text) {
    _voiceService.stopListening();
    Navigator.of(context).pop(text); // caller populates the search field with this
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _voiceService.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xE6111111), // dark scrim, matches Image 4's tone
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, _) {
                final pulse = 1.0 + (_soundLevel * 0.4) + (_pulseController.value * 0.1);
                return Container(
                  width: 90 * pulse,
                  height: 90 * pulse,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0C831F),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.mic, color: Colors.white, size: 36),
                );
              },
            ),
            const SizedBox(height: 28),
            Text(
              _transcript.isEmpty ? 'Listening…' : _transcript,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextButton(onPressed: widget.onCancel, child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
          ],
        ),
      ),
    );
  }
}
```

Wire the mic tap to push this as a full-screen route/dialog and, on pop, feed the returned transcript straight into `SearchController.onQueryChanged()` — from there it flows through the exact same instant-local + debounced-backend pipeline as typed text, so voice search gets identical speed characteristics for free.

---

## 4. Search screen UI/UX spec (cloning Images 2–3)

### 4.1 Design tokens (consistent with your existing Payment/Checkout screens)

| Token | Value |
|---|---|
| Background | `#FFFDF7` (warm off-white, matches Image 2's cream tone) |
| Card/section background | `#FFFFFF` |
| Primary text | `#1E1E1E` |
| Secondary text | `#7E7E7E` |
| Accent green (CTA, price discounts) | `#0C831F` |
| Chip border (recent search pills) | `#E2E2E6` |
| Font | Inter via `google_fonts`, weights 500/600/700/800 matching existing screens |
| Section header | 16sp, weight 800, `#1E1E1E` |
| Card corner radius | 14 |
| Horizontal page padding | 14 |

### 4.2 Browse state (empty query) — clone of Images 2–3

Top to bottom:

1. **Search bar row**: back arrow, text field (placeholder "Search for atta, dal, co...", autofocus on entry), mic icon button (right-aligned)
2. **"Recent searches"** section: header + "clear" text-link (green, right-aligned, clears all) — below it, a wrapped row of pill chips, each showing a small leading icon (magnifying glass or a thumbnail if the search matched a product) + the search term text. Tapping a pill re-runs that search immediately.
3. **"Continue browsing for"** section: horizontal scrollable card row — each card: product/category thumbnail image (from Supabase storage, Section 4.4), a small "👁 N day(s) ago" eyebrow badge top-left with a dismiss "×" top-right, then below the image: bold label (e.g. "Rosemary") + light-grey subtitle ("17 products")
4. **"Trending in your city"** section: horizontal scrollable row of rounded-square thumbnail + label pairs (no card background, just image + text) — these are curated/aggregated trending terms, not personal to the user (Section 4.5 covers the backend for this)
5. **"Your wishlist"** section: standard 2-per-row (or horizontally scrollable, matching Image 3) product card grid, reusing the exact product-card component from your category-listing screen (image, heart icon top-right filled red for wishlisted, "ADD"/stepper, weight, price with strikethrough MRP + discount %, name, badge chips like "Top Rated"/ingredient tags, rating + order count, delivery-time chip, low-stock chip) — do not build a second product-card component, reuse the one from Screen 1 of the checkout-flow doc
6. Sticky **"View cart"** bar at the bottom when cart is non-empty (same component/behavior as the rest of the app)

### 4.3 Results state (query non-empty) — not in your screenshots, standard extension

Once `SearchController.state.query` is non-empty, swap sections 2–5 above out for:

1. Search bar stays pinned at top (same position, now showing the typed/spoken query, an "×" clear icon appears at the end of the field)
2. A live-updating **2-column product grid**, same product-card component as the wishlist grid — populated by `SearchController.state.results`, re-rendering as local results arrive instantly and backend results merge in ~300ms later
3. While `isSearching` is true and results are still empty (very first frame before even local results resolve — rare, since local is synchronous, but covers the case where an empty catalog cache is still syncing), show the same shimmer/skeleton pattern used elsewhere in the app
4. **Empty state** (results genuinely empty after both local and backend have responded): centered illustration/icon + "No results found for '{query}'" + a lighter-weight suggestion ("Try searching for a different item" or 2–3 trending term chips as a recovery path)
5. On clearing the query (tap "×" or delete all text), animate back to the browse state (Section 4.2) — a simple `AnimatedSwitcher` crossfade between the two section sets is sufficient, no need for a route change since this is one screen with two content states

### 4.4 Product images — from your Supabase storage bucket, not the reference app's photos

Your `product-images` bucket is organized by category folder (`biscuits_and_cookies`, `chips_and_namkeen`, `dairy-bread-eggs`, `Energy_Drinks_and_juices`, `Fresh_Vegetables_Online`, `pet_food_and_supplies`, plus `figma-products`). Store the **full public URL** on each product/image row at catalog-seed time rather than reconstructing paths at render time:

```sql
-- product_images table, per your locked schema
-- image_url should already be the full public Storage URL, e.g.:
-- https://<project-ref>.supabase.co/storage/v1/object/public/product-images/dairy-bread-eggs/imgi_16_f2744d52...png
```

In Flutter, use `cached_network_image` (add to `pubspec.yaml` if not already present) for all product thumbnails across both the browse-state cards and the results grid — it gives you disk-caching of these images for free, which matters a lot for a search screen users will revisit constantly:

```dart
CachedNetworkImage(
  imageUrl: product.imageUrl,
  placeholder: (context, url) => const _ShimmerBox(),
  errorWidget: (context, url, error) => const Icon(Icons.image_not_supported_outlined),
  fit: BoxFit.contain,
)
```

### 4.5 Data model additions

```sql
-- Backend-aggregated trending terms (refresh periodically, e.g. hourly via pg_cron
-- or a scheduled Edge Function), NOT computed per-request
create materialized view trending_searches as
select query_text, count(*) as search_count
from search_log
where searched_at > now() - interval '7 days'
group by query_text
order by search_count desc
limit 20;

-- Lightweight log of what people search, feeds the view above.
-- Keep this table cheap to write to — it's on the hot path of every search.
create table if not exists search_log (
  id bigint generated always as identity primary key,
  query_text text not null,
  user_id uuid references users(id),
  searched_at timestamptz not null default now()
);
create index if not exists search_log_searched_at_idx on search_log(searched_at);
```

Insert into `search_log` from the backend search RPC path only (not the local-instant path, and not on every keystroke — only when a query actually completes/settles, e.g. debounce fires or user taps a result) to avoid write-amplifying every single keystroke into a database insert at 20K-concurrent scale.

**Recent searches** (per-user, Section 4.2 item 2) stay **local-only in Hive** — no backend table needed, this is purely a per-device convenience list, cap it at the last ~10 unique terms, most-recent-first, persisted across app restarts.

**Wishlist** reuses your existing wishlist feature/table — nothing new here, just render it in this screen too.

---

## 5. Step-by-step implementation plan for the agent

### Phase A — Backend (Supabase, via MCP tools)
1. `apply_migration`: `pg_trgm`/`unaccent` extensions, `search_vector` generated column + GIN index, trigram index, `search_products` RPC function (Section 1.2)
2. `apply_migration`: `search_log` table + `trending_searches` materialized view (Section 4.5)
3. Set up a scheduled refresh of `trending_searches` (Supabase supports `pg_cron` — schedule `refresh materialized view trending_searches` hourly)
4. `execute_sql`: verify with `EXPLAIN ANALYZE select * from search_products('milk')` that both indexes are used, not a sequential scan
5. `get_advisors`: confirm RLS is correctly configured on `search_log` (users can insert their own rows only; reads restricted to service role for the materialized view refresh path)

### Phase B — Flutter: local search engine
6. `LocalSearchIndex` (Section 1.1), built from the existing Hive-cached catalog at app start and refreshed on catalog sync (Phase 3 realtime hook)
7. `SearchController` (Section 1.3) wiring instant local + debounced backend + request-token race guard

### Phase C — Flutter: search screen UI
8. Browse-state layout (Section 4.2) — Recent searches (Hive-only), Continue browsing (Hive-tracked view history), Trending (fetched from `trending_searches` view, cached locally with a short TTL), Wishlist (existing feature)
9. Results-state layout (Section 4.3), `AnimatedSwitcher` transition between the two states
10. Product image loading via `cached_network_image` pointed at the real Supabase Storage URLs (Section 4.4) — no placeholder/stock images

### Phase D — Voice search
11. Add `speech_to_text` dependency + platform permissions (Section 3.2)
12. `VoiceSearchService` wrapper (Section 3.3)
13. `VoiceListeningOverlay` (Section 3.4), wired to mic tap → on pop, feed transcript into `SearchController.onQueryChanged()`

### Phase E — Verification
14. Test typed search: confirm first-keystroke results are instant (no visible network wait) and backend results merge in without flicker
15. Test voice search on a real device (emulator microphone support is unreliable) — confirm `en_IN` locale transcribes correctly and populates the search bar
16. Test offline: airplane mode, confirm local search still returns results from cache, backend call fails gracefully without breaking the UI
17. k6 addition per Section 2's scaling notes, folded into your existing Phase 8 load-testing plan

---

## 6. Package additions to `pubspec.yaml`

```yaml
dependencies:
  speech_to_text: ^7.3.0
  cached_network_image: ^3.4.1   # if not already present
```

No other new dependencies — everything else (Hive, Supabase client, Riverpod, go_router) is already in your locked stack.