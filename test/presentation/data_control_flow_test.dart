import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';
import '../support/pump_app.dart';
import 'home_screen_test.dart' show repositoryWithCheckInOn;

void main() {
  testWidgets('Home offers history and settings as secondary actions', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(find.text('HISTORY'), findsOneWidget);
    expect(find.text('SETTINGS'), findsOneWidget);
  });

  testWidgets('empty history explains itself without implying failure', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('HISTORY'));
    await tester.pumpAndSettle();

    expect(find.text('Completed check-ins will appear here.'), findsOneWidget);
  });

  testWidgets('history lists check-ins newest first with mood and time', (
    tester,
  ) async {
    final repository = await repositoryWithCheckInOn(day: 1);
    await pumpApp(
      tester,
      repository: repository,
      clock: FixedClock(momentOn(day: 2)),
    );

    // Complete today too, so two rows exist.
    await tester.tap(find.text('TAKE TODAY\'S SELFIE'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('USE THIS PHOTO'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Happy'));
    await tester.pump();
    await tester.tap(find.text('Happy'));
    await tester.pump();
    await tester.tap(find.text('CONTINUE'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ADD TODAY\'S GROWTH'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('HISTORY'));
    await tester.pumpAndSettle();

    final sept2 = tester.getTopLeft(find.text('2026-09-02'));
    final sept1 = tester.getTopLeft(find.text('2026-09-01'));
    expect(sept2.dy, lessThan(sept1.dy), reason: 'newest first');
    expect(find.text('Happy · afternoon'), findsOneWidget);
    expect(find.text('Calm · afternoon'), findsOneWidget);
  });

  testWidgets('event detail explains the contribution and a missing photo '
      'never hides the check-in', (tester) async {
    final repository = await repositoryWithCheckInOn(day: 1);
    // Media store starts empty in pumpApp -> the photo file is "missing".
    await pumpApp(
      tester,
      repository: repository,
      clock: FixedClock(momentOn(day: 2)),
    );

    await tester.tap(find.text('HISTORY'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2026-09-01'));
    await tester.pumpAndSettle();

    expect(
      find.text('Photo unavailable. Your check-in and growth are still here.'),
      findsOneWidget,
    );
    expect(find.textContaining('This day contributed'), findsOneWidget);
    expect(find.text('DELETE THIS CHECK-IN'), findsOneWidget);
    // Only today's event offers review; this one is yesterday's.
    expect(find.text('REVIEW TODAY\'S CHECK-IN'), findsNothing);
  });

  testWidgets('deletion names its scope, requires confirmation, and rebuilds '
      'the plant (spec §4.6)', (tester) async {
    final repository = await repositoryWithCheckInOn(day: 1);
    await pumpApp(
      tester,
      repository: repository,
      clock: FixedClock(momentOn(day: 2)),
    );

    await tester.tap(find.text('HISTORY'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2026-09-01'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('DELETE THIS CHECK-IN'));
    await tester.pumpAndSettle();

    expect(find.text('DELETE THIS CHECK-IN?'), findsOneWidget);
    expect(
      find.text(
        'This removes the check-in from 2026-09-01 and its contribution '
        'to your plant.',
      ),
      findsOneWidget,
    );

    // Cancelling changes nothing.
    await tester.tap(find.text('CANCEL'));
    await tester.pumpAndSettle();
    expect(await repository.allEvents(), hasLength(1));

    await tester.tap(find.text('DELETE THIS CHECK-IN'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('DELETE'));
    await tester.pumpAndSettle();

    expect(await repository.allEvents(), isEmpty);
    expect(find.text('Completed check-ins will appear here.'), findsOneWidget);
  });

  testWidgets('Start Over names its scope and resets everything, rotating '
      'identity (spec §4.6)', (tester) async {
    final repository = await repositoryWithCheckInOn(day: 2);
    final oldInstallation = await repository.installationId();
    await pumpApp(
      tester,
      repository: repository,
      clock: FixedClock(momentOn(day: 2)),
    );

    await tester.tap(find.text('SETTINGS'));
    await tester.pumpAndSettle();

    expect(find.text('Local Data'), findsOneWidget);

    await tester.tap(find.text('START OVER'));
    await tester.pumpAndSettle();

    expect(find.text('START OVER?'), findsOneWidget);
    expect(
      find.text(
        'This permanently removes your plant history and managed selfies '
        'from this installation. The plant returns to its seed state. '
        'This cannot be undone.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('ERASE EVERYTHING'));
    await tester.pumpAndSettle();

    expect(find.text('GROW SOMETHING PERSONAL'), findsOneWidget);
    expect(await repository.allEvents(), isEmpty);
    expect(await repository.installationId(), isNot(oldInstallation));
  });

  testWidgets('reviewing today can keep the existing photo (spec §4.5)', (
    tester,
  ) async {
    final repository = await repositoryWithCheckInOn(day: 2);
    final original = (await repository.allEvents()).single;
    final handles = await pumpApp(
      tester,
      repository: repository,
      clock: FixedClock(momentOn(day: 2)),
    );
    // The stored photo exists in the media store.
    handles.mediaStore.files[original.selfieFileName] = tinyJpeg;

    await tester.tap(find.text('REVIEW TODAY\'S CHECK-IN'));
    await tester.pumpAndSettle();

    expect(find.text('KEEP CURRENT PHOTO'), findsOneWidget);
    await tester.tap(find.text('KEEP CURRENT PHOTO'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Silly'),
      80,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();
    await tester.tap(find.text('Silly'));
    await tester.pump();
    await tester.tap(find.text('CONTINUE'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('UPDATE TODAY\'S GROWTH'));
    await tester.pumpAndSettle();

    final updated = (await repository.allEvents()).single;
    expect(updated.id, original.id);
    expect(updated.mood.name, 'silly');
    expect(updated.selfieFileName, original.selfieFileName);
    expect(
      handles.mediaStore.files[original.selfieFileName],
      tinyJpeg,
      reason: 'the kept photo is untouched',
    );
  });

  testWidgets('a fresh first check-in does not offer keeping a photo', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('TAKE TODAY\'S SELFIE'));
    await tester.pumpAndSettle();

    expect(find.text('KEEP CURRENT PHOTO'), findsNothing);
  });
}
