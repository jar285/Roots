import '../contracts/companion_repository.dart';
import '../contracts/managed_media_store.dart';

/// What happened to the managed photo during a deletion (spec §4.6 step 5).
enum PhotoCleanup {
  removed,

  /// The file was already gone — recoverable warning, not a failure.
  alreadyMissing,

  /// Removal failed; the row is gone and the orphaned file is swept by the
  /// next reconciliation pass (ADR 0005 #6).
  failed,
}

class DeleteGrowthEventResult {
  const DeleteGrowthEventResult({required this.eventDeleted, this.cleanup});

  final bool eventDeleted;

  /// Null when no event was found (nothing to clean).
  final PhotoCleanup? cleanup;
}

/// Deletes one check-in (spec §4.6): transactional row delete first, then
/// idempotent photo removal. The projection rebuild is the caller's concern
/// (invalidate and re-project — PlantState is always derived).
class DeleteGrowthEvent {
  const DeleteGrowthEvent({required this.repository, required this.mediaStore});

  final CompanionRepository repository;
  final ManagedMediaStore mediaStore;

  Future<DeleteGrowthEventResult> call(String eventId) async {
    final events = await repository.allEvents();
    final event = events.where((e) => e.id == eventId).firstOrNull;
    if (event == null) {
      return const DeleteGrowthEventResult(eventDeleted: false);
    }

    final deleted = await repository.deleteEvent(eventId);
    if (!deleted) {
      return const DeleteGrowthEventResult(eventDeleted: false);
    }

    PhotoCleanup cleanup;
    try {
      final removed = await mediaStore.removeManagedFile(event.selfieFileName);
      cleanup = removed ? PhotoCleanup.removed : PhotoCleanup.alreadyMissing;
    } catch (_) {
      cleanup = PhotoCleanup.failed;
    }

    return DeleteGrowthEventResult(eventDeleted: true, cleanup: cleanup);
  }
}
