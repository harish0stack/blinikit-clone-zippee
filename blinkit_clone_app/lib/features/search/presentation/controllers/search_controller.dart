// lib/features/search/presentation/controllers/search_controller.dart
// Riverpod state notifier managing instant local search, debounced backend queries, and voice transcription
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../home/models/product_model.dart';
import '../../../home/presentation/providers/catalog_providers.dart';
import '../../data/local_search_index.dart';
import '../../data/recent_searches_service.dart';
import '../../models/search_browse_models.dart';
import '../../services/voice_search_service.dart';

class SearchState {
  final String query;
  final bool isSearching;
  final bool isListening;
  final double soundLevel;
  final List<ProductModel> results;
  final List<String> recentSearches;
  final List<BrowseHistoryItem> continueBrowsingItems;
  final List<TrendingItem> trendingItems;
  final List<ProductModel> wishlistProducts;

  const SearchState({
    required this.query,
    required this.isSearching,
    required this.isListening,
    required this.soundLevel,
    required this.results,
    required this.recentSearches,
    required this.continueBrowsingItems,
    required this.trendingItems,
    required this.wishlistProducts,
  });

  factory SearchState.initial() {
    return const SearchState(
      query: '',
      isSearching: false,
      isListening: false,
      soundLevel: 0.0,
      results: [],
      recentSearches: RecentSearchesService.defaultInitialSearches,
      continueBrowsingItems: [
        BrowseHistoryItem(
          id: 'br_1',
          title: 'Rosemary',
          subtitle: '17 products',
          imageUrl: 'assets/product-images/Fresh Vegetables Online/img-5.png',
        ),
        BrowseHistoryItem(
          id: 'br_2',
          title: 'Rosemar...',
          subtitle: '6 products',
          imageUrl: 'assets/product-images/Fresh Vegetables Online/img-2.png',
        ),
        BrowseHistoryItem(
          id: 'br_3',
          title: 'Ice Cream...',
          subtitle: '297 products',
          imageUrl: 'assets/product-images/dairy-bread-eggs/img-1.png',
        ),
      ],
      trendingItems: [
        TrendingItem(
          id: 'tr_1',
          title: 'Playing Cards',
          imageUrl: 'assets/product-images/chips and namkeen/img-1.png',
        ),
        TrendingItem(
          id: 'tr_2',
          title: 'Diya',
          imageUrl: 'assets/product-images/Fresh Vegetables Online/img-7.png',
        ),
        TrendingItem(
          id: 'tr_3',
          title: 'Apple Earph...',
          imageUrl: 'assets/product-images/Energy Drinks and juices/img-1.png',
        ),
        TrendingItem(
          id: 'tr_4',
          title: 'Radha Poshak',
          imageUrl: 'assets/product-images/biscuits and cookies/img-1.png',
        ),
        TrendingItem(
          id: 'tr_5',
          title: 'Krishna Bhak...',
          imageUrl: 'assets/product-images/dairy-bread-eggs/img-2.png',
        ),
      ],
      wishlistProducts: [],
    );
  }

  SearchState copyWith({
    String? query,
    bool? isSearching,
    bool? isListening,
    double? soundLevel,
    List<ProductModel>? results,
    List<String>? recentSearches,
    List<BrowseHistoryItem>? continueBrowsingItems,
    List<TrendingItem>? trendingItems,
    List<ProductModel>? wishlistProducts,
  }) {
    return SearchState(
      query: query ?? this.query,
      isSearching: isSearching ?? this.isSearching,
      isListening: isListening ?? this.isListening,
      soundLevel: soundLevel ?? this.soundLevel,
      results: results ?? this.results,
      recentSearches: recentSearches ?? this.recentSearches,
      continueBrowsingItems: continueBrowsingItems ?? this.continueBrowsingItems,
      trendingItems: trendingItems ?? this.trendingItems,
      wishlistProducts: wishlistProducts ?? this.wishlistProducts,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  final Ref _ref;
  final LocalSearchIndex _localIndex = LocalSearchIndex();
  final RecentSearchesService _recentService = RecentSearchesService();
  final VoiceSearchService _voiceService = VoiceSearchService();

  Timer? _debounceTimer;
  int _requestToken = 0;

  SearchNotifier(this._ref) : super(SearchState.initial()) {
    _initialize();
  }

  Future<void> _initialize() async {
    // 1. Load persisted recent searches
    try {
      final recents = await _recentService.getRecentSearches();
      state = state.copyWith(recentSearches: recents);
    } catch (_) {}

    // 2. Build local index from cached products & preload wishlist
    try {
      final allProducts = await _ref.read(catalogRepositoryProvider).fetchAllProducts();
      _localIndex.buildFromCatalog(allProducts);

      // Prepopulate curated wishlist from products
      final wishlist = allProducts.take(6).toList();
      state = state.copyWith(wishlistProducts: wishlist);
    } catch (e) {
      debugPrint('[SearchNotifier] Init error: $e');
    }
  }

  /// Instant search on text change + 300ms debounced backend check
  void onQueryChanged(String rawQuery) {
    final query = rawQuery.trim();
    state = state.copyWith(query: rawQuery);

    if (query.isEmpty) {
      _debounceTimer?.cancel();
      state = state.copyWith(results: [], isSearching: false);
      return;
    }

    // 1. Sub-16ms Synchronous Instant Search from In-Memory Index
    final localMatches = _localIndex.search(query);
    state = state.copyWith(results: localMatches, isSearching: true);

    // 2. Debounced Backend Network Query
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _runBackendSearch(query);
    });
  }

  Future<void> _runBackendSearch(String query) async {
    final token = ++_requestToken;
    try {
      // Query backend repository for broader results
      final allProducts = await _ref.read(catalogRepositoryProvider).fetchAllProducts();
      if (token != _requestToken) return; // Discard stale/superseded responses

      final filtered = allProducts
          .where((p) =>
              p.name.toLowerCase().contains(query.toLowerCase()) ||
              p.categoryId.toLowerCase().contains(query.toLowerCase()))
          .toList();

      // Merge and deduplicate by product ID
      final seenIds = <String>{};
      final merged = <ProductModel>[];

      for (final p in [...state.results, ...filtered]) {
        if (seenIds.add(p.id)) {
          merged.add(p);
        }
      }

      state = state.copyWith(results: merged, isSearching: false);
    } catch (e) {
      debugPrint('[SearchNotifier] Backend search error: $e');
      if (token == _requestToken) {
        state = state.copyWith(isSearching: false);
      }
    }
  }

  /// Start Voice Search with immediate text injection and auto-search initiation
  Future<void> startVoiceSearch({
    required void Function(String liveText) onTextRecognized,
    void Function()? onCompleted,
  }) async {
    state = state.copyWith(isListening: true, soundLevel: 0.0);

    await _voiceService.startListening(
      onResult: (text, isFinal) {
        // Real-time injection into search input & auto-trigger search
        onTextRecognized(text);
        onQueryChanged(text);

        if (isFinal) {
          _recentService.addSearch(text);
          state = state.copyWith(isListening: false);
          onCompleted?.call();
        }
      },
      onSoundLevelChange: (level) {
        state = state.copyWith(soundLevel: level);
      },
      onListeningStopped: () {
        state = state.copyWith(isListening: false);
        onCompleted?.call();
      },
    );
  }

  Future<void> stopVoiceSearch() async {
    await _voiceService.stopListening();
    state = state.copyWith(isListening: false);
  }

  Future<void> addRecentSearch(String term) async {
    await _recentService.addSearch(term);
    final recents = await _recentService.getRecentSearches();
    state = state.copyWith(recentSearches: recents);
  }

  Future<void> removeRecentSearch(String term) async {
    await _recentService.removeSearch(term);
    final recents = await _recentService.getRecentSearches();
    state = state.copyWith(recentSearches: recents);
  }

  Future<void> clearAllRecentSearches() async {
    state = state.copyWith(recentSearches: []);
    await _recentService.clearAll();
  }

  void removeContinueBrowsingItem(String id) {
    final updated = state.continueBrowsingItems.where((i) => i.id != id).toList();
    state = state.copyWith(continueBrowsingItems: updated);
  }
}

final searchNotifierProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(ref);
});
