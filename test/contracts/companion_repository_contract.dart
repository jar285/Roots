import 'package:flutter_test/flutter_test.dart';

import 'package:roots/contracts/companion_repository.dart';
import 'package:roots/domain/model/growth_delta.dart';
import 'package:roots/domain/model/mood.dart';
import 'package:roots/domain/model/time_category.dart';

/// Behavioral contract every CompanionRepository implementation must satisfy
/// (ADR 0003 #10, Liskov substitutability). Run it against the Drift adapter
/// now and against any future in-memory fake — both must pass unchanged.
void runCompanionRepositoryContractTests({
  required Future<CompanionRepository> Function() create,
  Future<void> Function(CompanionRepository repository)? dispose,
}) {
  late CompanionRepository repository;

  setUp(() async {
    repository = await create();
  });

  tearDown(() async {
    await dispose?.call(repository);
  });

  GrowthDelta delta({String paletteId = 'v1.calm'}) {
    return GrowthDelta(
      heightIncrease: 10,
      branchIncrease: 1,
      leafIncrease: 3,
      decorationIncrease: 0,
      spreadFactor: 0.3,
      prefersVertical: false,
      prefersSpiral: false,
      paletteId: paletteId,
      morphologyId: 'v1.compact',
    );
  }

  DailyCheckInDraft draft({
    String localDate = '2026-09-01',
    DateTime? checkedInAtUtc,
    Mood mood = Mood.calm,
    String? selfieFileName = 'photo.jpg',
    int randomSeed = 7,
    String paletteId = 'v1.calm',
  }) {
    return DailyCheckInDraft(
      localDate: localDate,
      checkedInAtUtc: checkedInAtUtc ?? DateTime.utc(2026, 9, 1, 14, 5),
      timezoneOffsetMinutes: -240,
      timeCategory: TimeCategory.afternoon,
      mood: mood,
      selfieFileName: selfieFileName,
      randomSeed: randomSeed,
      algorithmVersion: 1,
      growthDelta: delta(paletteId: paletteId),
    );
  }

  group('installation identity', () {
    test('is created lazily, is non-empty, and stays stable', () async {
      final first = await repository.installationId();
      final second = await repository.installationId();

      expect(first, isNotEmpty);
      expect(second, first);
    });

    test('is stamped onto saved events', () async {
      final saved = await repository.upsertDailyCheckIn(draft());

      expect(saved.installationId, await repository.installationId());
    });
  });

  group('upsertDailyCheckIn — create (spec §4.5)', () {
    test(
      'creates the first event for a date from the confirmation reading',
      () async {
        final d = draft();
        final saved = await repository.upsertDailyCheckIn(d);

        expect(saved.id, isNotEmpty);
        expect(saved.localDate, d.localDate);
        expect(saved.checkedInAtUtc, d.checkedInAtUtc);
        expect(saved.timezoneOffsetMinutes, d.timezoneOffsetMinutes);
        expect(saved.timeCategory, d.timeCategory);
        expect(saved.mood, d.mood);
        expect(saved.selfieFileName, d.selfieFileName);
        expect(saved.randomSeed, d.randomSeed);
        expect(saved.algorithmVersion, d.algorithmVersion);
        expect(saved.growthDelta, d.growthDelta);
        expect(saved.createdAtUtc, d.checkedInAtUtc);
        expect(saved.updatedAtUtc, d.checkedInAtUtc);
      },
    );

    test('requires a selfie file name on first create', () async {
      expect(
        () => repository.upsertDailyCheckIn(draft(selfieFileName: null)),
        throwsArgumentError,
      );
    });
  });

  group('upsertDailyCheckIn — same-day correction (spec §4.5)', () {
    test(
      'replaces the event in place, preserving id and createdAtUtc',
      () async {
        final original = await repository.upsertDailyCheckIn(draft());

        final correction = draft(
          checkedInAtUtc: DateTime.utc(2026, 9, 1, 20, 45),
          mood: Mood.silly,
          selfieFileName: 'retake.jpg',
          randomSeed: 99,
          paletteId: 'v1.silly',
        );
        final updated = await repository.upsertDailyCheckIn(correction);

        expect(updated.id, original.id);
        expect(updated.createdAtUtc, original.createdAtUtc);
        expect(updated.mood, Mood.silly);
        expect(updated.randomSeed, 99);
        expect(updated.selfieFileName, 'retake.jpg');
        expect(updated.growthDelta, correction.growthDelta);
        expect(updated.checkedInAtUtc, correction.checkedInAtUtc);
        expect(updated.updatedAtUtc, correction.checkedInAtUtc);

        final all = await repository.allEvents();
        expect(all, hasLength(1));
        expect(all.single, updated);
      },
    );

    test(
      'a null selfie file name keeps the existing photo reference',
      () async {
        await repository.upsertDailyCheckIn(draft(selfieFileName: 'first.jpg'));

        final updated = await repository.upsertDailyCheckIn(
          draft(mood: Mood.happy, selfieFileName: null),
        );

        expect(updated.selfieFileName, 'first.jpg');
        expect(updated.mood, Mood.happy);
      },
    );

    test('rapid competing submissions resolve to exactly one event', () async {
      await Future.wait([
        for (var i = 0; i < 5; i++)
          repository.upsertDailyCheckIn(
            draft(
              checkedInAtUtc: DateTime.utc(2026, 9, 1, 14, i),
              randomSeed: i,
            ),
          ),
      ]);

      final all = await repository.allEvents();
      expect(all, hasLength(1));
    });
  });

  group('reads', () {
    test('eventForDate returns the event for that date or null', () async {
      final saved = await repository.upsertDailyCheckIn(draft());

      expect(await repository.eventForDate('2026-09-01'), saved);
      expect(await repository.eventForDate('2026-09-02'), isNull);
    });

    test(
      'allEvents returns canonical order regardless of insert order',
      () async {
        final third = await repository.upsertDailyCheckIn(
          draft(
            localDate: '2026-09-03',
            checkedInAtUtc: DateTime.utc(2026, 9, 3, 9),
          ),
        );
        final first = await repository.upsertDailyCheckIn(
          draft(
            localDate: '2026-09-01',
            checkedInAtUtc: DateTime.utc(2026, 9, 1, 22),
          ),
        );
        final second = await repository.upsertDailyCheckIn(
          draft(
            localDate: '2026-09-02',
            checkedInAtUtc: DateTime.utc(2026, 9, 2, 7),
          ),
        );

        expect(await repository.allEvents(), [first, second, third]);
      },
    );

    test('round-trips an event with exact value equality', () async {
      final saved = await repository.upsertDailyCheckIn(draft());

      final read = await repository.eventForDate('2026-09-01');

      expect(read, saved);
    });
  });

  group('deleteEvent (spec §4.6)', () {
    test('removes the event and reports whether one was found', () async {
      final saved = await repository.upsertDailyCheckIn(draft());

      expect(await repository.deleteEvent(saved.id), isTrue);
      expect(await repository.allEvents(), isEmpty);
      expect(await repository.eventForDate('2026-09-01'), isNull);
      expect(await repository.deleteEvent(saved.id), isFalse);
      expect(await repository.deleteEvent('never-existed'), isFalse);
    });

    test('deleting today frees the date for a fresh check-in', () async {
      final original = await repository.upsertDailyCheckIn(draft());
      await repository.deleteEvent(original.id);

      final fresh = await repository.upsertDailyCheckIn(draft());

      expect(fresh.id, isNot(original.id));
      expect(await repository.allEvents(), hasLength(1));
    });
  });
}
