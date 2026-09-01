import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:roots/application/save_daily_check_in.dart';
import 'package:roots/domain/model/check_in_moment.dart';
import 'package:roots/domain/model/mood.dart';
import 'package:roots/domain/model/time_category.dart';
import 'package:roots/domain/rules/growth_constants.dart';
import 'package:roots/domain/rules/growth_rules.dart';

import '../support/fakes.dart';
import '../support/in_memory_companion_repository.dart';

void main() {
  late InMemoryCompanionRepository repository;
  late InMemoryManagedMediaStore mediaStore;
  late FixedClock clock;
  late SaveDailyCheckIn saveDailyCheckIn;

  final photoBytes = Uint8List.fromList([1, 2, 3, 4]);

  setUp(() {
    repository = InMemoryCompanionRepository(idSource: SequentialIds());
    mediaStore = InMemoryManagedMediaStore();
    clock = FixedClock(
      // 14:05 UTC at offset -240 → local 10:05 → morning, 2026-09-01.
      CheckInMoment(
        utcInstant: DateTime.utc(2026, 9, 1, 14, 5),
        offsetMinutes: -240,
      ),
    );
    saveDailyCheckIn = SaveDailyCheckIn(
      repository: repository,
      mediaStore: mediaStore,
      clock: clock,
      idSource: SequentialIds(),
      seedSource: FixedSeedSource(4242),
    );
  });

  test('creates today\'s event from one clock reading (spec §4.1)', () async {
    final saved = await saveDailyCheckIn(mood: Mood.happy, photo: photoBytes);

    expect(saved.localDate, '2026-09-01');
    expect(saved.checkedInAtUtc, DateTime.utc(2026, 9, 1, 14, 5));
    expect(saved.timezoneOffsetMinutes, -240);
    expect(saved.timeCategory, TimeCategory.morning);
    expect(saved.mood, Mood.happy);
    expect(saved.randomSeed, 4242);
    expect(saved.algorithmVersion, GrowthConstants.initialAlgorithmVersion);
    expect(
      saved.growthDelta,
      GrowthRules.resolve(
        timeCategory: TimeCategory.morning,
        mood: Mood.happy,
        seed: 4242,
      ),
    );
  });

  test('names the managed photo after the event id (spec A.9)', () async {
    final saved = await saveDailyCheckIn(mood: Mood.calm, photo: photoBytes);

    expect(saved.selfieFileName, '${saved.id}.jpg');
    expect(mediaStore.files.keys, ['${saved.id}.jpg']);
    expect(mediaStore.files.values.single, photoBytes);
  });

  test('a second save on the same local date updates the same event', () async {
    final first = await saveDailyCheckIn(mood: Mood.calm, photo: photoBytes);

    clock.moment = CheckInMoment(
      utcInstant: DateTime.utc(2026, 9, 1, 23, 30),
      offsetMinutes: -240, // still 2026-09-01 locally (19:30)
    );
    final second = await saveDailyCheckIn(
      mood: Mood.silly,
      photo: Uint8List.fromList([9, 9, 9]),
    );

    expect(second.id, first.id);
    expect(second.mood, Mood.silly);
    expect(await repository.allEvents(), hasLength(1));
    // Replacement photo reuses the same managed name (same event id).
    expect(mediaStore.saveLog, ['${first.id}.jpg', '${first.id}.jpg']);
  });

  test('a new local day creates a new event', () async {
    final first = await saveDailyCheckIn(mood: Mood.calm, photo: photoBytes);

    clock.moment = CheckInMoment(
      utcInstant: DateTime.utc(2026, 9, 2, 14, 5),
      offsetMinutes: -240,
    );
    final second = await saveDailyCheckIn(mood: Mood.happy, photo: photoBytes);

    expect(second.id, isNot(first.id));
    expect(await repository.allEvents(), hasLength(2));
  });
}
