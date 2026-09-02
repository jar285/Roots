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

  /// [photo] null means "keep the existing photo" on a same-day review
  /// (spec §4.5); it requires today's event to already exist.
  Future<GrowthEvent> call({required Mood mood, Uint8List? photo}) async {
    final moment = clock.now();

    // The id must exist before the row does: the managed filename is
    // "<eventId>.<ext>" and the committed row references it (ADR 0004 #1).
    final existing = await repository.eventForDate(moment.localDate);
    if (photo == null && existing == null) {
      throw StateError(
        'a first check-in for ${moment.localDate} requires a photo',
      );
    }
    final eventId = existing?.id ?? idSource.nextId();

    final seed = seedSource.nextSeed();
    final delta = GrowthRules.resolve(
      timeCategory: moment.timeCategory,
      mood: mood,
      seed: seed,
    );

    // Spec §5.4 order: stage, commit referencing the final name, promote.
    final staged = photo == null
        ? null
        : await mediaStore.prepareCapturedPhoto(
            eventId: eventId,
            tag: moment.utcInstant.millisecondsSinceEpoch,
            bytes: photo,
          );

    final saved = await repository.upsertDailyCheckIn(
      DailyCheckInDraft(
        proposedEventId: eventId,
        localDate: moment.localDate,
        checkedInAtUtc: moment.utcInstant,
        timezoneOffsetMinutes: moment.offsetMinutes,
        timeCategory: moment.timeCategory,
        mood: mood,
        selfieFileName: staged?.finalFileName,
        randomSeed: seed,
        algorithmVersion: GrowthConstants.initialAlgorithmVersion,
        growthDelta: delta,
      ),
    );

    if (staged != null) {
      await mediaStore.promoteStagedPhoto(
        eventId: staged.eventId,
        tag: staged.tag,
      );
    }
    return saved;
  }
}
