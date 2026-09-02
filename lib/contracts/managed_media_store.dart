import 'dart:typed_data';

/// A prepared-but-unpromoted photo (spec §5.4 step 4). [tag] is the
/// confirmation reading in UTC milliseconds — reconciliation promotes a
/// staged file only when an event's updatedAtUtc matches it (ADR 0005 #1).
class StagedPhoto {
  const StagedPhoto({
    required this.eventId,
    required this.tag,
    required this.finalFileName,
  });

  final String eventId;
  final int tag;

  /// `<eventId>.jpg` — what the committed event references.
  final String finalFileName;
}

class StagedEntry {
  const StagedEntry({required this.eventId, required this.tag});

  final String eventId;
  final int tag;
}

class ManagedMediaInventory {
  const ManagedMediaInventory({
    required this.finalFileNames,
    required this.staged,
  });

  final List<String> finalFileNames;
  final List<StagedEntry> staged;
}

/// Captured bytes were not a decodable image (spec §5.4 step 2).
class InvalidPhotoException implements Exception {
  const InvalidPhotoException(this.detail);

  final String detail;

  @override
  String toString() => 'InvalidPhotoException($detail)';
}

/// Owns the private managed-photo lifecycle (spec §5.4, A.9): validate,
/// process, stage, promote, read, remove, enumerate. Paths never escape the
/// managed directory.
abstract interface class ManagedMediaStore {
  /// Validates [bytes] decode as an image, resizes to a maximum 800-pixel
  /// edge, encodes JPEG quality 85, and writes a recognizable staged file.
  /// Throws [InvalidPhotoException] for undecodable bytes; writes nothing
  /// on failure. Never touches the final name.
  Future<StagedPhoto> prepareCapturedPhoto({
    required String eventId,
    required int tag,
    required Uint8List bytes,
  });

  /// Atomically promotes the staged file over `<eventId>.jpg` — on a
  /// same-day replacement this is also the removal of the old photo,
  /// after the new data is durable (spec §4.5).
  Future<void> promoteStagedPhoto({required String eventId, required int tag});

  /// Removes one staged file (an abandoned save found by reconciliation).
  /// Idempotent: a missing staged file is not an error.
  Future<void> removeStagedPhoto({required String eventId, required int tag});

  /// Bytes of a managed photo, or null when missing or the name is not a
  /// plain managed file name. Absence is a display concern, never an error.
  Future<Uint8List?> readManagedPhoto(String fileName);

  /// Idempotently removes one managed file; false when it was not there.
  Future<bool> removeManagedFile(String fileName);

  /// Removes every staged and final file (Start Over).
  Future<void> removeAllManagedMedia();

  /// Enumerates managed and staged files for reconciliation (A.9).
  Future<ManagedMediaInventory> inventory();
}
