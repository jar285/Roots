import 'package:flutter_test/flutter_test.dart';

import 'support/pump_app.dart';

void main() {
  testWidgets('the app boots to Home without any account or network', (
    tester,
  ) async {
    await pumpApp(tester);

    // Straight into the companion: no sign-in, no onboarding wall.
    expect(find.text('GROW SOMETHING PERSONAL'), findsOneWidget);
  });
}
