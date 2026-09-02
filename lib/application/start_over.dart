import '../contracts/companion_repository.dart';
import '../contracts/id_source.dart';
import '../contracts/managed_media_store.dart';

class StartOverResult {
  const StartOverResult({
    required this.newInstallationId,
    required this.mediaCleared,
  });

  final String newInstallationId;

  /// False when the media wipe failed — the remaining files reference no
  /// event and the next reconciliation sweeps them (ADR 0005 #7).
  final bool mediaCleared;
}

/// Start Over (spec §4.6): one repository transaction removes every event
/// and rotates the installation identity; managed media is then removed
/// best-effort. Never disguised as logout — this is real data lifecycle.
class StartOver {
  const StartOver({
    required this.repository,
    required this.mediaStore,
    required this.idSource,
  });

  final CompanionRepository repository;
  final ManagedMediaStore mediaStore;
  final IdSource idSource;

  Future<StartOverResult> call() async {
    final nextInstallationId = idSource.nextId();
    await repository.startOver(nextInstallationId: nextInstallationId);

    var mediaCleared = true;
    try {
      await mediaStore.removeAllManagedMedia();
    } catch (_) {
      mediaCleared = false;
    }

    return StartOverResult(
      newInstallationId: nextInstallationId,
      mediaCleared: mediaCleared,
    );
  }
}
