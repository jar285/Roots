import '../domain/model/growth_delta.dart';
import '../domain/model/growth_event.dart';
import '../domain/model/mood.dart';
import '../domain/model/time_category.dart';

/// Everything the user confirmed for one daily check-in, before storage
/// resolves it into a canonical GrowthEvent.
///
/// [selfieFileName] is null when no new photo was prepared: on a same-day
/// correction the existing photo reference is kept (spec §4.5); on a first
/// create it is required.
///
/// [proposedEventId] lets the caller resolve the event id before commit —
/// managed photo filenames are "event id + extension" (spec A.9), so the id
/// must exist before the row does (ADR 0004). Used on create; ignored on
/// update, where the stored id always wins. Null lets the repository mint one.
class DailyCheckInDraft {
  const DailyCheckInDraft({
    required this.localDate,
    required this.checkedInAtUtc,
    required this.timezoneOffsetMinutes,
    required this.timeCategory,
    required this.mood,
    required this.selfieFileName,
    required this.randomSeed,
    required this.algorithmVersion,
    required this.growthDelta,
    this.proposedEventId,
  });

  final String? proposedEventId;
  final String localDate;
  final DateTime checkedInAtUtc;
  final int timezoneOffsetMinutes;
  final TimeCategory timeCategory;
  final Mood mood;
  final String? selfieFileName;
  final int randomSeed;
  final int algorithmVersion;
  final GrowthDelta growthDelta;
}

/// A stored row cannot be converted back into a valid domain value
/// (spec A.8 validation). Recoverable data error: it names the event and
/// field instead of silently coercing.
class CorruptEventDataException implements Exception {
  const CorruptEventDataException({
    required this.eventId,
    required this.field,
    required this.detail,
  });

  final String eventId;
  final String field;
  final String detail;

  @override
  String toString() =>
      'CorruptEventDataException(event $eventId, field $field: $detail)';
}

/// Owns GrowthEvent persistence semantics (spec §5.1, ADR 0003).
///
/// Implementations guarantee: one event per (installation, localDate) —
/// backed by storage, not call discipline; same-day upserts preserve id and
/// createdAtUtc; reads return canonical projection order.
abstract interface class CompanionRepository {
  /// The stable identity of this installation, created lazily on first use
  /// and replaced only by Start Over (spec §4.6).
  Future<String> installationId();

  /// Creates today's event, or replaces the existing event for
  /// [DailyCheckInDraft.localDate] in place (spec §4.5). Returns the
  /// persisted canonical event.
  Future<GrowthEvent> upsertDailyCheckIn(DailyCheckInDraft draft);

  /// The event recorded for [localDate], or null.
  Future<GrowthEvent?> eventForDate(String localDate);

  /// All events for this installation in canonical projection order
  /// (localDate, checkedInAtUtc, id — all ascending).
  Future<List<GrowthEvent>> allEvents();

  /// Deletes one event by id. Returns false when no such event exists.
  /// The date becomes available for a fresh check-in (ADR 0003 #7).
  Future<bool> deleteEvent(String id);

  /// Start Over's storage half (spec §4.6): in one transaction, removes
  /// every event and replaces the installation identity with
  /// [nextInstallationId], so the new companion is not linked to the reset
  /// history. Media cleanup is the media store's job.
  Future<void> startOver({required String nextInstallationId});
}
