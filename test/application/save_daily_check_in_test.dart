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

  test('stages, commits, then promotes the photo under the event id '
      '(spec §5.4, A.9)', () async {
    final saved = await saveDailyCheckIn(mood: Mood.calm, photo: photoBytes);

    expect(saved.selfieFileName, '${saved.id}.jpg');
    expect(mediaStore.files.keys, ['${saved.id}.jpg']);
    expect(mediaStore.files.values.single, photoBytes);
    expect(
      mediaStore.staged,
      isEmpty,
      reason: 'a completed save leaves nothing staged',
    );
    // Staged under the confirmation reading's tag, promoted after commit.
    final tag = saved.updatedAtUtc.millisecondsSinceEpoch;
    expect(mediaStore.log, [
      'prepare:${saved.id}.$tag',
      'promote:${saved.id}.$tag',
    ]);
  });

  test('a second save on the same local date updates the same event', () async {
    final first = await saveDailyCheckIn(mood: Mood.calm, photo: photoBytes);

    clock.moment = CheckInMoment(
      utcInstant: DateTime.utc(2026, 9, 1, 23, 30),
      offsetMinutes: -240, // still 2026-09-01 locally (19:30)
    );
    final replacement = Uint8List.fromList([9, 9, 9]);
    final second = await saveDailyCheckIn(mood: Mood.silly, photo: replacement);

    expect(second.id, first.id);
    expect(second.mood, Mood.silly);
    expect(await repository.allEvents(), hasLength(1));
    // Replacement photo reuses the same managed name (same event id).
    expect(mediaStore.files.keys, ['${first.id}.jpg']);
    expect(mediaStore.files.values.single, replacement);
    expect(mediaStore.staged, isEmpty);
  });

  test('a null photo on a same-day review keeps the existing photo '
      '(spec §4.5)', () async {
    final first = await saveDailyCheckIn(mood: Mood.calm, photo: photoBytes);
    final logBefore = List.of(mediaStore.log);

    final second = await saveDailyCheckIn(mood: Mood.happy, photo: null);

    expect(second.id, first.id);
    expect(second.mood, Mood.happy);
    expect(second.selfieFileName, first.selfieFileName);
    expect(
      mediaStore.files.values.single,
      photoBytes,
      reason: 'no media work happens when the photo is kept',
    );
    expect(mediaStore.log, logBefore);
  });

  test('a null photo with no existing event is a programming error', () async {
    await expectLater(
      saveDailyCheckIn(mood: Mood.calm, photo: null),
      throwsStateError,
    );
    expect(await repository.allEvents(), isEmpty);
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
