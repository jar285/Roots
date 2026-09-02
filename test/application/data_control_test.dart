import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:roots/application/delete_growth_event.dart';
import 'package:roots/application/save_daily_check_in.dart';
import 'package:roots/application/start_over.dart';
import 'package:roots/contracts/id_source.dart';
import 'package:roots/domain/model/check_in_moment.dart';
import 'package:roots/domain/model/mood.dart';

import '../support/fakes.dart';
import '../support/in_memory_companion_repository.dart';

/// Distinct from every SequentialIds value, the way production UUIDs are
/// distinct across sources.
class _FreshIds implements IdSource {
  int _next = 0;

  @override
  String nextId() => 'fresh-${++_next}';
}

void main() {
  late InMemoryCompanionRepository repository;
  late InMemoryManagedMediaStore mediaStore;
  late SequentialIds eventIds;

  setUp(() {
    repository = InMemoryCompanionRepository(idSource: SequentialIds());
    mediaStore = InMemoryManagedMediaStore();
    eventIds = SequentialIds();
  });

  Future<void> checkInOn(int day) async {
    final save = SaveDailyCheckIn(
      repository: repository,
      mediaStore: mediaStore,
      clock: FixedClock(
        CheckInMoment(
          utcInstant: DateTime.utc(2026, 9, day, 12),
          offsetMinutes: 0,
        ),
      ),
      idSource: eventIds,
      seedSource: FixedSeedSource(7),
    );
    await save(mood: Mood.calm, photo: Uint8List.fromList([day]));
  }

  group('DeleteGrowthEvent (spec §4.6)', () {
    late DeleteGrowthEvent deleteEvent;

    setUp(() {
      deleteEvent = DeleteGrowthEvent(
        repository: repository,
        mediaStore: mediaStore,
      );
    });

    test(
      'deletes the row, removes the photo, and reports clean removal',
      () async {
        await checkInOn(1);
        await checkInOn(2);
        final victim = (await repository.allEvents()).first;

        final result = await deleteEvent(victim.id);

        expect(result.eventDeleted, isTrue);
        expect(result.cleanup, PhotoCleanup.removed);
        expect(await repository.allEvents(), hasLength(1));
        expect(mediaStore.files.containsKey(victim.selfieFileName), isFalse);
      },
    );

    test(
      'an already-missing photo is a recoverable warning, not a failure',
      () async {
        await checkInOn(1);
        final victim = (await repository.allEvents()).single;
        mediaStore.files.remove(victim.selfieFileName);

        final result = await deleteEvent(victim.id);

        expect(result.eventDeleted, isTrue);
        expect(result.cleanup, PhotoCleanup.alreadyMissing);
        expect(await repository.allEvents(), isEmpty);
      },
    );

    test('a failed file removal still deletes the event (reconciliation '
        'sweeps the orphan later)', () async {
      await checkInOn(1);
      final victim = (await repository.allEvents()).single;
      mediaStore.failOnRemove = true;

      final result = await deleteEvent(victim.id);

      expect(result.eventDeleted, isTrue);
      expect(result.cleanup, PhotoCleanup.failed);
      expect(await repository.allEvents(), isEmpty);
    });

    test('an unknown id reports not-deleted and touches nothing', () async {
      await checkInOn(1);

      final result = await deleteEvent('no-such-event');

      expect(result.eventDeleted, isFalse);
      expect(result.cleanup, isNull);
      expect(await repository.allEvents(), hasLength(1));
      expect(mediaStore.files, hasLength(1));
    });
  });

  group('StartOver (spec §4.6)', () {
    test(
      'clears events and media and rotates the installation identity',
      () async {
        await checkInOn(1);
        await checkInOn(2);
        final oldInstallation = await repository.installationId();

        final startOver = StartOver(
          repository: repository,
          mediaStore: mediaStore,
          idSource: _FreshIds(),
        );
        final result = await startOver();

        expect(await repository.allEvents(), isEmpty);
        expect(mediaStore.files, isEmpty);
        expect(mediaStore.staged, isEmpty);
        final newInstallation = await repository.installationId();
        expect(newInstallation, isNot(oldInstallation));
        expect(result.newInstallationId, newInstallation);
        expect(result.mediaCleared, isTrue);

        // The fresh companion accepts a check-in for a previously used date.
        await checkInOn(1);
        expect(await repository.allEvents(), hasLength(1));
      },
    );

    test(
      'a failed media wipe is reported but identity still rotates',
      () async {
        await checkInOn(1);
        final old = await repository.installationId();
        mediaStore.failOnRemove = true; // reused flag for removeAll below
        mediaStore.failOnRemoveAll = true;

        final startOver = StartOver(
          repository: repository,
          mediaStore: mediaStore,
          idSource: _FreshIds(),
        );
        final result = await startOver();

        expect(await repository.allEvents(), isEmpty);
        expect(await repository.installationId(), isNot(old));
        expect(result.mediaCleared, isFalse);
      },
    );
  });
}
