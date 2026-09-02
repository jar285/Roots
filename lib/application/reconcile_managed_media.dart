import '../contracts/companion_repository.dart';
import '../contracts/managed_media_store.dart';

/// What one reconciliation pass changed — privacy-safe counts only.
class ReconciliationReport {
  const ReconciliationReport({
    required this.promoted,
    required this.removedStaged,
    required this.removedOrphanFinals,
  });

  final int promoted;
  final int removedStaged;
  final int removedOrphanFinals;
}

/// Repairs the database/filesystem seam after interruption (spec §5.4,
/// ADR 0005 #4). Run at every launch; idempotent. The three states:
///
/// - staged file whose tag matches a committed event's updatedAtUtc →
///   the commit happened, promotion did not: promote it now;
/// - staged file matching no committed confirmation → abandoned save:
///   remove it;
/// - final file referenced by no event → failed deletion cleanup: remove it.
class ReconcileManagedMedia {
  const ReconcileManagedMedia({
    required this.repository,
    required this.mediaStore,
  });

  final CompanionRepository repository;
  final ManagedMediaStore mediaStore;

  Future<ReconciliationReport> call() async {
    final events = await repository.allEvents();
    final committedTags = {
      for (final event in events)
        '${event.id}.${event.updatedAtUtc.millisecondsSinceEpoch}',
    };
    final referencedFiles = {for (final e in events) e.selfieFileName};

    var promoted = 0;
    var removedStaged = 0;
    final inventory = await mediaStore.inventory();

    for (final entry in inventory.staged) {
      if (committedTags.contains('${entry.eventId}.${entry.tag}')) {
        await mediaStore.promoteStagedPhoto(
          eventId: entry.eventId,
          tag: entry.tag,
        );
        promoted++;
      } else {
        // Abandoned save: promoting would clobber a good photo with data
        // from a confirmation that never committed.
        await mediaStore.removeStagedPhoto(
          eventId: entry.eventId,
          tag: entry.tag,
        );
        removedStaged++;
      }
    }

    var removedOrphanFinals = 0;
    final afterPromotion = await mediaStore.inventory();
    for (final fileName in afterPromotion.finalFileNames) {
      if (!referencedFiles.contains(fileName)) {
        await mediaStore.removeManagedFile(fileName);
        removedOrphanFinals++;
      }
    }

    return ReconciliationReport(
      promoted: promoted,
      removedStaged: removedStaged,
      removedOrphanFinals: removedOrphanFinals,
    );
  }
}
