import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';
import '../support/pump_app.dart';
import 'home_screen_test.dart' show repositoryWithCheckInOn;

/// 200% text scaling must not clip controls or hide the daily state
/// (spec §9 accessibility; UI/UX philosophy text rules).
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    binding.platformDispatcher.textScaleFactorTestValue = 2.0;
  });

  tearDown(() {
    binding.platformDispatcher.clearTextScaleFactorTestValue();
  });

  testWidgets('empty Home survives 200% text with no overflow', (tester) async {
    await pumpApp(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('GROW SOMETHING PERSONAL'), findsOneWidget);
    expect(find.text('TAKE TODAY\'S SELFIE'), findsOneWidget);
  });

  testWidgets('completed Home survives 200% text with no overflow', (
    tester,
  ) async {
    final repository = await repositoryWithCheckInOn(day: 2);
    await pumpApp(
      tester,
      repository: repository,
      clock: FixedClock(momentOn(day: 2)),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('REVIEW TODAY\'S CHECK-IN'), findsOneWidget);
  });

  testWidgets('mood selection survives 200% text with no overflow', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.text('TAKE TODAY\'S SELFIE'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('USE THIS PHOTO'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('HOW ARE YOU FEELING?'), findsOneWidget);
    expect(find.text('CONTINUE'), findsOneWidget);
  });
}
