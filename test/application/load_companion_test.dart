import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:roots/application/load_companion.dart';
import 'package:roots/application/save_daily_check_in.dart';
import 'package:roots/contracts/companion_repository.dart';
import 'package:roots/domain/model/check_in_moment.dart';
import 'package:roots/domain/model/growth_delta.dart';
import 'package:roots/domain/model/mood.dart';
import 'package:roots/domain/model/time_category.dart';
import 'package:roots/domain/projection/plant_projector.dart';
import 'package:roots/domain/rules/growth_constants.dart';

import '../support/fakes.dart';
import '../support/in_memory_companion_repository.dart';

void main() {
  late InMemoryCompanionRepository repository;
  late FixedClock clock;
  late LoadCompanion loadCompanion;

  setUp(() {
    repository = InMemoryCompanionRepository(idSource: SequentialIds());
    clock = FixedClock(
      CheckInMoment(utcInstant: DateTime.utc(2026, 9, 2, 12), offsetMinutes: 0),
    );
    loadCompanion = LoadCompanion(
      repository: repository,
      registry: ProjectorRegistry.standard(),
      clock: clock,
    );
  });

  Future<void> checkIn({required Mood mood}) async {
    final save = SaveDailyCheckIn(
      repository: repository,
      mediaStore: InMemoryManagedMediaStore(),
      clock: clock,
      idSource: SequentialIds(),
      seedSource: FixedSeedSource(7),
    );
    await save(mood: mood, photo: Uint8List.fromList([1]));
  }

  test('an empty companion loads the seed plant with no event today', () async {
    final loaded = await loadCompanion();

    expect(loaded.plant.effectiveHeight, GrowthConstants.seedHeight);
    expect(loaded.plant.eventCount, 0);
    expect(loaded.todayEvent, isNull);
    expect(loaded.todayLocalDate, '2026-09-02');
  });

  test(
    'projects stored events and reports today\'s event when it exists',
    () async {
      await checkIn(mood: Mood.happy);

      final loaded = await loadCompanion();

      expect(loaded.plant.eventCount, 1);
      expect(loaded.plant.effectiveHeight, greaterThan(20));
      expect(loaded.todayEvent, isNotNull);
      expect(loaded.todayEvent!.mood, Mood.happy);
    },
  );

  test('yesterday\'s event does not count as today\'s', () async {
    await checkIn(mood: Mood.calm);

    clock.moment = CheckInMoment(
      utcInstant: DateTime.utc(2026, 9, 3, 12),
      offsetMinutes: 0,
    );

    final loaded = await loadCompanion();

    expect(loaded.plant.eventCount, 1);
    expect(loaded.todayEvent, isNull);
    expect(loaded.todayLocalDate, '2026-09-03');
  });

  test(
    'an unknown algorithm version surfaces as a typed recoverable error',
    () async {
      await repository.upsertDailyCheckIn(
        DailyCheckInDraft(
          proposedEventId: 'future-event',
          localDate: '2026-09-01',
          checkedInAtUtc: DateTime.utc(2026, 9, 1, 12),
          timezoneOffsetMinutes: 0,
          timeCategory: TimeCategory.afternoon,
          mood: Mood.calm,
          selfieFileName: 'x.jpg',
          randomSeed: 1,
          algorithmVersion: 99,
          growthDelta: const GrowthDelta(
            heightIncrease: 1,
            branchIncrease: 0,
            leafIncrease: 0,
            decorationIncrease: 0,
            spreadFactor: 0.5,
            prefersVertical: false,
            prefersSpiral: false,
            paletteId: 'v99.x',
            morphologyId: 'v99.x',
          ),
        ),
      );

      await expectLater(
        loadCompanion(),
        throwsA(
          isA<UnknownAlgorithmVersionException>()
              .having((e) => e.algorithmVersion, 'version', 99)
              .having((e) => e.eventId, 'eventId', 'future-event'),
        ),
      );
    },
  );
}
