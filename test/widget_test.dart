// Phase 0 smoke test — verifies BlinkitApp mounts without crashing.
// Full widget tests added per-feature starting Phase 1.
import 'package:flutter_test/flutter_test.dart';
import 'package:blinkit_clone_app/app.dart';

void main() {
  testWidgets('Phase 0 smoke test — BlinkitApp renders without red screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const BlinkitApp());
    expect(tester.takeException(), isNull);
  });
}
