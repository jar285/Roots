import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:roots/application/save_daily_check_in.dart';
import 'package:roots/domain/model/mood.dart';

import '../support/fakes.dart';
import '../support/in_memory_companion_repository.dart';
import '../support/pump_app.dart';

Future<InMemoryCompanionRepository> repositoryWithCheckInOn({
  required int day,
}) async {
  final repository = InMemoryCompanionRepository(idSource: SequentialIds());
  final save = SaveDailyCheckIn(
    repository: repository,
    mediaStore: InMemoryManagedMediaStore(),
    clock: FixedClock(momentOn(day: day)),
    idSource: SequentialIds(),
    seedSource: FixedSeedSource(7),
  );
  await save(mood: Mood.calm, photo: Uint8List.fromList([1]));
  return repository;
}

void main() {
  testWidgets('empty Home invites the first check-in (spec A.7)', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(find.text('GROW SOMETHING PERSONAL'), findsOneWidget);
    expect(
      find.text('One private check-in can add to your plant each day.'),
      findsOneWidget,
    );
    expect(find.text('TAKE TODAY\'S SELFIE'), findsOneWidget);
    expect(find.text('Your selfie stays on this device.'), findsOneWidget);
  });

  testWidgets('Home before today\'s check-in offers the daily action', (
    tester,
  ) async {
    // Checked in yesterday (day 1); today is day 2.
    final repository = await repositoryWithCheckInOn(day: 1);
    await pumpApp(
      tester,
      repository: repository,
      clock: FixedClock(momentOn(day: 2)),
    );

    expect(find.text('TAKE TODAY\'S SELFIE'), findsOneWidget);
    expect(find.text('REVIEW TODAY\'S CHECK-IN'), findsNothing);
    expect(find.text('GROW SOMETHING PERSONAL'), findsNothing);
  });

  testWidgets('Home after today\'s check-in switches to review (spec §6.4)', (
    tester,
  ) async {
    final repository = await repositoryWithCheckInOn(day: 2);
    await pumpApp(
      tester,
      repository: repository,
      clock: FixedClock(momentOn(day: 2)),
    );

    expect(find.text('REVIEW TODAY\'S CHECK-IN'), findsOneWidget);
    expect(find.text('TAKE TODAY\'S SELFIE'), findsNothing);
    expect(find.text('Today\'s check-in is complete.'), findsOneWidget);
  });

  testWidgets('the plant exposes one concise semantics summary', (
    tester,
  ) async {
    final repository = await repositoryWithCheckInOn(day: 2);
    await pumpApp(
      tester,
      repository: repository,
      clock: FixedClock(momentOn(day: 2)),
    );

    expect(
      find.bySemanticsLabel(RegExp(r'Your plant: 1 check-in')),
      findsOneWidget,
    );
  });
}
