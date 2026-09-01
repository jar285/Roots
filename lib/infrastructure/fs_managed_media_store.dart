import 'dart:io';
import 'dart:typed_data';

import '../contracts/managed_media_store.dart';

/// Filesystem adapter for the private managed-photo directory (spec §5.4).
///
/// The base directory is injected (only the composition root touches
/// path_provider), so tests run against temp directories. Staging and
/// reconciliation join in Sprint 4 (ADR 0004 #2).
class FsManagedMediaStore implements ManagedMediaStore {
  FsManagedMediaStore({required this.baseDirectory});

  final Directory baseDirectory;

  static final RegExp _safeEventId = RegExp(r'^[A-Za-z0-9_-]+$');

  @override
  Future<String> saveProcessedPhoto({
    required String eventId,
    required Uint8List bytes,
  }) async {
    // Managed file names must stay inside the managed directory (spec A.9).
    if (!_safeEventId.hasMatch(eventId)) {
      throw ArgumentError.value(
        eventId,
        'eventId',
        'must contain only letters, digits, "-" and "_"',
      );
    }

    await baseDirectory.create(recursive: true);
    final fileName = '$eventId.jpg';
    await File(
      '${baseDirectory.path}/$fileName',
    ).writeAsBytes(bytes, flush: true);
    return fileName;
  }
}
