import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';
import '../support/pump_app.dart';
import 'home_screen_test.dart' show repositoryWithCheckInOn;

void main() {
  Future<void> startCheckIn(WidgetTester tester) async {
    await tester.tap(find.text('TAKE TODAY\'S SELFIE'));
    await tester.pumpAndSettle();
  }

  Future<void> chooseMood(WidgetTester tester, String label) async {
    final finder = find.text(label);
    await tester.scrollUntilVisible(
      finder,
      80,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();
    await tester.tap(finder);
    await tester.pump();
  }

  testWidgets('capture offers use, retake, and cancel', (tester) async {
    await pumpApp(tester);
    await startCheckIn(tester);

    expect(find.text('USE THIS PHOTO'), findsOneWidget);
    expect(find.text('RETAKE'), findsOneWidget);
    expect(find.text('CANCEL'), findsOneWidget);
  });

  testWidgets('cancelling capture returns to a stable Home with no event', (
    tester,
  ) async {
    final handles = await pumpApp(tester);
    await startCheckIn(tester);

    await tester.tap(find.text('CANCEL'));
    await tester.pumpAndSettle();

    expect(find.text('GROW SOMETHING PERSONAL'), findsOneWidget);
    expect(await handles.repository.allEvents(), isEmpty);
  });

  testWidgets('mood must be selected before continuing (spec §8.2)', (
    tester,
  ) async {
    await pumpApp(tester);
    await startCheckIn(tester);
    await tester.tap(find.text('USE THIS PHOTO'));
    await tester.pumpAndSettle();

    expect(find.text('HOW ARE YOU FEELING?'), findsOneWidget);
    // Design 3: the captured draft selfie shows in the upper stage.
    expect(find.byType(Image), findsOneWidget);

    final continueButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'CONTINUE'),
    );
    expect(continueButton.onPressed, isNull);

    await chooseMood(tester, 'Happy');

    final enabled = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'CONTINUE'),
    );
    expect(enabled.onPressed, isNotNull);
  });

  testWidgets('confirmation states the privacy promise before saving', (
    tester,
  ) async {
    await pumpApp(tester);
    await startCheckIn(tester);
    await tester.tap(find.text('USE THIS PHOTO'));
    await tester.pumpAndSettle();
    await chooseMood(tester, 'Calm');
    await tester.tap(find.text('CONTINUE'));
    await tester.pumpAndSettle();

    expect(find.text('ADD TODAY\'S GROWTH?'), findsOneWidget);
    expect(find.text('Your selfie stays on this device.'), findsOneWidget);
  });

  testWidgets('the full journey grows the plant and completes today', (
    tester,
  ) async {
    final handles = await pumpApp(tester);

    await startCheckIn(tester);
    await tester.tap(find.text('USE THIS PHOTO'));
    await tester.pumpAndSettle();
    await chooseMood(tester, 'Happy');
    await tester.tap(find.text('CONTINUE'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ADD TODAY\'S GROWTH'));
    await tester.pumpAndSettle();

    // pumpApp clock: afternoon; Happy -> 6 leaves (spec A.3 + ADR 0006 #7).
    expect(find.text('6 NEW LEAVES ARE PART OF IT NOW.'), findsOneWidget);
    expect(find.text('Today · Happy · saved'), findsOneWidget);
    expect(find.text('REVIEW TODAY\'S CHECK-IN'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp(r'Your plant: 1 check-in')),
      findsOneWidget,
    );

    final events = await handles.repository.allEvents();
    expect(events, hasLength(1));
    expect(handles.mediaStore.files.keys, ['${events.single.id}.jpg']);
  });

  testWidgets(
    'reduced motion shows the final grown plant with no pending animation '
    '(spec §8.8)',
    (tester) async {
      tester.binding.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.binding.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );

      await pumpApp(tester);
      await startCheckIn(tester);
      await tester.tap(find.text('USE THIS PHOTO'));
      await tester.pumpAndSettle();
      await chooseMood(tester, 'Happy');
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ADD TODAY\'S GROWTH'));
      // The journey completes and settles under reduced motion; the direct
      // no-reveal-frames proof lives in plant_view_test.dart (the route
      // transition itself is platform-default motion).
      await tester.pumpAndSettle();

      expect(find.text('6 NEW LEAVES ARE PART OF IT NOW.'), findsOneWidget);
      expect(
        find.bySemanticsLabel(RegExp(r'Your plant: 1 check-in')),
        findsOneWidget,
      );
    },
  );

  testWidgets('reviewing today explains replacement and updates the same event '
      '(spec §6.4)', (tester) async {
    final repository = await repositoryWithCheckInOn(day: 2);
    final original = (await repository.allEvents()).single;

    await pumpApp(
      tester,
      repository: repository,
      clock: FixedClock(momentOn(day: 2)),
    );

    await tester.tap(find.text('REVIEW TODAY\'S CHECK-IN'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('USE THIS PHOTO'));
    await tester.pumpAndSettle();
    await chooseMood(tester, 'Silly');
    await tester.tap(find.text('CONTINUE'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Saving updates today\'s existing check-in. '
        'Your plant keeps one contribution for today.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('UPDATE TODAY\'S GROWTH'));
    await tester.pumpAndSettle();

    final events = await repository.allEvents();
    expect(events, hasLength(1));
    expect(events.single.id, original.id);
    expect(events.single.mood.name, 'silly');
  });
}
