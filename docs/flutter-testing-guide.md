# Flutter App Testing — All Workarounds & Approaches

> **Context**: Blinkit Clone consumer app built with Flutter + Riverpod + go_router + Supabase cloud backend.
> This document covers every practical way to test Flutter screens quickly during development.

---

## TL;DR — Fastest Way to See Your UI

```bash
cd blinkit_clone_app

# Option 1: Chrome (instant, no simulator needed)
flutter run -d chrome

# Option 2: iOS Simulator (macOS only)
open -a Simulator && flutter run

# Option 3: Android Emulator
emulator -avd Pixel_7_API_34 && flutter run

# Option 4: Physical device (USB)
flutter devices         # find device ID
flutter run -d <id>
```

With **hot reload** (`r` key in terminal) and **hot restart** (`R` key), UI changes reflect in < 1 second — no rebuild needed.

---

## Approach 1 — Flutter Web (Chrome) ✅ RECOMMENDED for UI iteration

**Best for**: Rapid UI development, layout checking, widget iteration  
**Limitation**: Some device-specific features (FCM, Hive on web, platform channels) behave differently

```bash
flutter run -d chrome --dart-define=SUPABASE_URL=https://xxx.supabase.co --dart-define=SUPABASE_ANON_KEY=yyy
```

**Why this is the fastest loop**:
- No simulator boot time (5–30 seconds saved per run)
- Chrome DevTools for layout debugging (inspect box constraints, overflow)
- Hot reload works exactly the same as on device
- Supabase SDK works on web — real data renders in the browser

**When to switch off Chrome**:
- Testing Hive cache behavior (use shared_preferences on web, Hive box flavor differs)
- Testing FCM notifications (not supported on web)
- Testing iOS-specific UI (SafeArea, system fonts, bottom nav insets)

---

## Approach 2 — iOS Simulator (macOS, no cost)

```bash
# List available simulators
xcrun simctl list devices available

# Boot a specific one
xcrun simctl boot "iPhone 15 Pro"
open -a Simulator

# Run Flutter on it
flutter run
```

**Hot reload works**: press `r` after saving any file — reflects in < 1s.
**Hot restart**: press `R` — re-runs `main()`, resets state, re-runs providers.

**Best for**: Testing iOS-specific layouts, SafeArea insets, system back gesture, iOS font rendering.

---

## Approach 3 — Android Emulator

```bash
# List available AVDs
emulator -list-avds

# Start one
emulator -avd Pixel_7_API_34 &

# Flutter run
flutter run
```

**Best for**: Testing Android-specific behavior, navigation bar insets, Material ripples.

---

## Approach 4 — Physical Device (Best Performance)

```bash
flutter devices      # see connected devices
flutter run -d <device-id>
```

**Enable wireless debugging (no USB after first connect)**:
```bash
# Android only
adb tcpip 5555
adb connect <device-ip>:5555
flutter run
```

For iOS, use Xcode → Devices and Simulators → enable Network for the device.

---

## Approach 5 — Widget Tests (Isolated, Instant, No Device Needed)

**Best for**: Testing individual widget behavior, UI states, interactions  
**Speed**: < 1 second per test, runs entirely in Dart VM, no simulator

```bash
flutter test test/features/cart/cart_screen_test.dart
flutter test --name "adds item to cart"    # run specific test by name
flutter test -r expanded                   # verbose output
```

**Example widget test for CartScreen**:
```dart
// test/features/cart/cart_screen_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blinkit_clone_app/features/cart/presentation/screens/cart_screen.dart';
import 'package:blinkit_clone_app/features/cart/presentation/providers/cart_provider.dart';

void main() {
  testWidgets('CartScreen shows empty state when cart is empty', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: CartScreen()),
      ),
    );
    expect(find.text('Your cart is empty'), findsOneWidget);
    expect(find.byType(CartItemTile), findsNothing);
  });

  testWidgets('CartScreen shows items when cart has products', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Override cart provider with pre-populated state
          cartNotifierProvider.overrideWith(() => MockCartNotifier()),
        ],
        child: MaterialApp(home: CartScreen()),
      ),
    );
    await tester.pump();
    expect(find.byType(CartItemTile), findsNWidgets(2));
  });
}
```

**Run all tests**:
```bash
flutter test                         # all tests
flutter test --coverage              # with coverage report
genhtml coverage/lcov.info -o coverage/html  # HTML coverage report
```

---

## Approach 6 — Integration Tests (End-to-End, Full App)

**Best for**: Testing complete user flows (login → browse → add to cart → checkout)  
**Speed**: Slower (runs on real simulator/device), but catches issues widget tests miss

```bash
# Setup
flutter pub add --dev integration_test

# Create test
# integration_test/home_flow_test.dart

# Run
flutter test integration_test/home_flow_test.dart -d <device-id>
```

**Example**:
```dart
// integration_test/cart_flow_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:blinkit_clone_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('User can add a product to cart', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Tap first product card
    await tester.tap(find.byKey(Key('product_card_0')));
    await tester.pumpAndSettle();

    // Tap Add to Cart
    await tester.tap(find.byKey(Key('add_to_cart_btn')));
    await tester.pumpAndSettle();

    // Verify cart badge shows 1
    expect(find.text('1'), findsOneWidget);
  });
}
```

---

## Approach 7 — Golden Tests (Screenshot Regression Testing)

**Best for**: Catching visual regressions — ensures screens look exactly the same after refactors  
**Speed**: Fast (runs in Dart VM), but requires updating golden files intentionally

```bash
# First run — generates golden files
flutter test --update-goldens

# Subsequent runs — compares to goldens
flutter test
```

**Example**:
```dart
// test/features/home/home_screen_golden_test.dart
void main() {
  testWidgets('HomeScreen golden', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [catalogRepositoryProvider.overrideWithValue(DemoCatalogRepository())],
        child: MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(HomeScreen),
      matchesGoldenFile('goldens/home_screen.png'),
    );
  });
}
```

---

## Approach 8 — Storybook Pattern (Widgetbook)

**Best for**: Designing and reviewing widgets in complete isolation without needing the full app  
**Setup**: Uses the `widgetbook` package

```bash
flutter pub add --dev widgetbook widgetbook_annotation
flutter pub add --dev widgetbook_generator build_runner
```

```dart
// widgetbook/main.dart — runs as a separate flutter app
@App()
class WidgetbookApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      directories: $directories,  // generated
    );
  }
}

// widgetbook/components/product_card.book.dart
@UseCase(name: 'Default', type: ProductCard)
Widget buildProductCard(BuildContext context) {
  return ProductCard(
    product: Product(id: '1', name: 'Amul Butter', unit: '500g', mrp: 60, sellingPrice: 54, inStock: true, ...),
  );
}
```

Run widgetbook on Chrome: `flutter run -d chrome -t widgetbook/main.dart`

---

## Approach 9 — `flutter run --profile` (Performance Testing)

**Best for**: Checking scroll performance, animation jank, Realtime stream rendering lag  

```bash
flutter run --profile   # profile mode — optimized but with profiling hooks
```

Then open Chrome DevTools → More tools → Flutter DevTools → Performance tab.  
Look for: frame budget violations (red bars = > 16ms on 60fps), unnecessary rebuilds.

---

## Approach 10 — VS Code / Android Studio Flutter DevTools

Built into the IDEs. While the app is running:
- **Widget Inspector**: See the widget tree live, tap any widget to highlight it
- **Layout Explorer**: Visualize flex/stack layouts, spot overflow before it crashes
- **Performance**: Frame timeline, detect jank
- **Network**: See all HTTP requests (Supabase REST calls)
- **Logging**: `debugPrint()` output, errors

---

## Quick Reference — Which Approach for What

| Goal | Fastest Approach |
|---|---|
| Check if a widget renders correctly | Widget test or `flutter run -d chrome` |
| Iterate on UI layout (colors, spacing) | `flutter run -d chrome` + hot reload |
| Test iOS-specific look (fonts, nav bar) | iOS Simulator |
| Test full user flow (auth → cart → order) | Integration test or physical device |
| Catch visual regressions after refactor | Golden tests |
| Design widgets in isolation | Widgetbook on Chrome |
| Check scroll performance / animations | `flutter run --profile` + DevTools |
| Test with real Supabase data | Any device with `--dart-define` env vars |
| Test offline/cache behavior (Hive) | iOS Simulator or Android Emulator (toggle airplane mode) |
| CI/CD automated testing | Widget tests + integration tests headlessly |

---

## Running with Real Supabase Data (any approach)

Always pass credentials via `--dart-define`, never hardcode:

```bash
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://your-ref.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

Add a VS Code launch config for convenience:

```json
// .vscode/launch.json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Blinkit (Chrome)",
      "request": "launch",
      "type": "dart",
      "deviceId": "chrome",
      "args": [
        "--dart-define=SUPABASE_URL=https://your-ref.supabase.co",
        "--dart-define=SUPABASE_ANON_KEY=your-anon-key"
      ]
    },
    {
      "name": "Blinkit (iOS Sim)",
      "request": "launch",
      "type": "dart",
      "deviceId": "iPhone 15 Pro",
      "args": [
        "--dart-define=SUPABASE_URL=https://your-ref.supabase.co",
        "--dart-define=SUPABASE_ANON_KEY=your-anon-key"
      ]
    }
  ]
}
```

---

## CI/CD Headless Testing (GitHub Actions)

```yaml
# .github/workflows/flutter_test.yml
name: Flutter Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
      - name: Install dependencies
        run: flutter pub get
        working-directory: blinkit_clone_app
      - name: Run tests
        run: flutter test --coverage
        working-directory: blinkit_clone_app
      - name: Build runner (freezed)
        run: flutter pub run build_runner build --delete-conflicting-outputs
        working-directory: blinkit_clone_app
```

---

## Recommended Testing Workflow Per Phase

| Phase | What to Test | Tool |
|---|---|---|
| Phase 0 | Scaffold builds | `flutter run -d chrome` (blank screen check) |
| Phase 1 | All 7 UI screens, cart state | Chrome hot reload + widget tests |
| Phase 2 | DB schema (no Flutter tests) | MCP execute_sql RLS checks |
| Phase 3 | Realtime — product appears in 2s | Two Chrome tabs + Supabase dashboard |
| Phase 4 | Auth flows | iOS Simulator (OTP requires SMS in prod) |
| Phase 5 | Vendor upload → Flutter update | Chrome (vendor hub) + iOS Sim (Flutter) side-by-side |
| Phase 6 | Cache hits, prefetch timing | iOS Sim + airplane mode toggle |
| Phase 7 | Push notifications | Physical device (simulators support FCM on iOS 16+) |
| Phase 8 | Load test | k6 distributed, not Flutter-specific |
