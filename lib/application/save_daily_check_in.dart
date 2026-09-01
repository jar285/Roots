import 'dart:typed_data';

import '../contracts/clock.dart';
import '../contracts/companion_repository.dart';
import '../contracts/id_source.dart';
import '../contracts/managed_media_store.dart';
import '../contracts/seed_source.dart';
import '../domain/model/growth_event.dart';
import '../domain/model/mood.dart';
import '../domain/rules/growth_constants.dart';
import '../domain/rules/growth_rules.dart';

/// One intentional operation for the daily confirmation (spec §4.5):
/// takes one clock reading, resolves the deterministic growth delta, stores
/// the managed photo under the event id, and upserts the canonical event —
/// creating today's event or replacing it in place.
class SaveDailyCheckIn {
  const SaveDailyCheckIn({
    required this.repository,
    required this.mediaStore,
    required this.clock,
    required this.idSource,
    required this.seedSource,
  });

  final CompanionRepository repository;
  final ManagedMediaStore mediaStore;
  final Clock clock;
  final IdSource idSource;
  final SeedSource seedSource;

  Future<GrowthEvent> call({
    required Mood mood,
    required Uint8List photo,
  }) async {
    final moment = clock.now();

    // The id must exist before the row does: the managed filename is
    // "<eventId>.<ext>" and the committed row references it (ADR 0004 #1).
    final existing = await repository.eventForDate(moment.localDate);
    final eventId = existing?.id ?? idSource.nextId();

    final seed = seedSource.nextSeed();
    final delta = GrowthRules.resolve(
      timeCategory: moment.timeCategory,
      mood: mood,
      seed: seed,
    );

    final fileName = await mediaStore.saveProcessedPhoto(
      eventId: eventId,
      bytes: photo,
    );

    return repository.upsertDailyCheckIn(
      DailyCheckInDraft(
        proposedEventId: eventId,
        localDate: moment.localDate,
        checkedInAtUtc: moment.utcInstant,
        timezoneOffsetMinutes: moment.offsetMinutes,
        timeCategory: moment.timeCategory,
        mood: mood,
        selfieFileName: fileName,
        randomSeed: seed,
        algorithmVersion: GrowthConstants.initialAlgorithmVersion,
        growthDelta: delta,
      ),
    );
  }
}
