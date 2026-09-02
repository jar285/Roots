import 'package:roots/contracts/companion_repository.dart';
import 'package:roots/contracts/id_source.dart';
import 'package:roots/domain/model/growth_event.dart';

/// In-memory [CompanionRepository] for fast application and widget tests.
///
/// Must behave observably like the Drift adapter — both run the same
/// contract suite (ADR 0003 #10). The mutation path is synchronous between
/// check and write, so competing submissions cannot interleave.
class InMemoryCompanionRepository implements CompanionRepository {
  InMemoryCompanionRepository({required this.idSource});

  final IdSource idSource;

  final Map<String, GrowthEvent> _eventsById = {};
  String? _installationId;

  String _requireInstallationId() => _installationId ??= idSource.nextId();

  @override
  Future<String> installationId() async => _requireInstallationId();

  @override
  Future<GrowthEvent> upsertDailyCheckIn(DailyCheckInDraft draft) async {
    final installation = _requireInstallationId();
    final existing = _eventsById.values
        .where(
          (e) =>
              e.installationId == installation &&
              e.localDate == draft.localDate,
        )
        .firstOrNull;

    if (existing == null) {
      final selfieFileName = draft.selfieFileName;
      if (selfieFileName == null) {
        throw ArgumentError.value(
          null,
          'selfieFileName',
          'required when creating the first event for a date',
        );
      }
      final created = GrowthEvent(
        id: draft.proposedEventId ?? idSource.nextId(),
        installationId: installation,
        localDate: draft.localDate,
        checkedInAtUtc: draft.checkedInAtUtc,
        timezoneOffsetMinutes: draft.timezoneOffsetMinutes,
        timeCategory: draft.timeCategory,
        mood: draft.mood,
        selfieFileName: selfieFileName,
        randomSeed: draft.randomSeed,
        algorithmVersion: draft.algorithmVersion,
        growthDelta: draft.growthDelta,
        createdAtUtc: draft.checkedInAtUtc,
        updatedAtUtc: draft.checkedInAtUtc,
      );
      _eventsById[created.id] = created;
      return created;
    }

    final updated = GrowthEvent(
      id: existing.id,
      installationId: existing.installationId,
      localDate: existing.localDate,
      checkedInAtUtc: draft.checkedInAtUtc,
      timezoneOffsetMinutes: draft.timezoneOffsetMinutes,
      timeCategory: draft.timeCategory,
      mood: draft.mood,
      selfieFileName: draft.selfieFileName ?? existing.selfieFileName,
      randomSeed: draft.randomSeed,
      algorithmVersion: draft.algorithmVersion,
      growthDelta: draft.growthDelta,
      createdAtUtc: existing.createdAtUtc,
      updatedAtUtc: draft.checkedInAtUtc,
    );
    _eventsById[updated.id] = updated;
    return updated;
  }

  @override
  Future<GrowthEvent?> eventForDate(String localDate) async {
    final installation = _requireInstallationId();
    return _eventsById.values
        .where(
          (e) => e.installationId == installation && e.localDate == localDate,
        )
        .firstOrNull;
  }

  @override
  Future<List<GrowthEvent>> allEvents() async {
    final installation = _requireInstallationId();
    final events = _eventsById.values
        .where((e) => e.installationId == installation)
        .toList();
    events.sort((a, b) {
      final byDate = a.localDate.compareTo(b.localDate);
      if (byDate != 0) return byDate;
      final byInstant = a.checkedInAtUtc.compareTo(b.checkedInAtUtc);
      if (byInstant != 0) return byInstant;
      return a.id.compareTo(b.id);
    });
    return events;
  }

  @override
  Future<bool> deleteEvent(String id) async {
    final installation = _requireInstallationId();
    final event = _eventsById[id];
    if (event == null || event.installationId != installation) return false;
    _eventsById.remove(id);
    return true;
  }

  @override
  Future<void> startOver({required String nextInstallationId}) async {
    _eventsById.clear();
    _installationId = nextInstallationId;
  }
}
