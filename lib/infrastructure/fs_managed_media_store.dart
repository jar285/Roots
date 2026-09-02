import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../contracts/managed_media_store.dart';

/// Filesystem adapter for the private managed-photo lifecycle (ADR 0005).
///
/// Layout: finals live at `<base>/<eventId>.jpg`; staged files at
/// `<base>/staging/<eventId>.<tag>.jpg`. Promotion is an atomic same-volume
/// rename. The base directory is injected — only the composition root
/// touches path_provider, and tests run against temp directories.
class FsManagedMediaStore implements ManagedMediaStore {
  FsManagedMediaStore({required this.baseDirectory});

  final Directory baseDirectory;

  static const int _maxEdge = 800;
  static const int _jpegQuality = 85;

  static final RegExp _safeEventId = RegExp(r'^[A-Za-z0-9_-]+$');
  static final RegExp _safeFinalName = RegExp(r'^[A-Za-z0-9_-]+\.jpg$');
  static final RegExp _stagedName = RegExp(r'^([A-Za-z0-9_-]+)\.(\d+)\.jpg$');

  Directory get _stagingDir => Directory('${baseDirectory.path}/staging');

  File _finalFile(String fileName) => File('${baseDirectory.path}/$fileName');

  File _stagedFile(String eventId, int tag) =>
      File('${_stagingDir.path}/$eventId.$tag.jpg');

  void _requireSafeEventId(String eventId) {
    if (!_safeEventId.hasMatch(eventId)) {
      throw ArgumentError.value(
        eventId,
        'eventId',
        'must contain only letters, digits, "-" and "_"',
      );
    }
  }

  @override
  Future<StagedPhoto> prepareCapturedPhoto({
    required String eventId,
    required int tag,
    required Uint8List bytes,
  }) async {
    _requireSafeEventId(eventId);

    // Spec §5.4 steps 2–4: validate, resize, encode, stage. Decoders may
    // either return null or throw on malformed data — both are the same
    // recoverable outcome here.
    img.Image? decoded;
    try {
      decoded = img.decodeImage(bytes);
    } catch (e) {
      throw InvalidPhotoException('bytes are not a decodable image: $e');
    }
    if (decoded == null) {
      throw const InvalidPhotoException('bytes are not a decodable image');
    }
    final longest = decoded.width > decoded.height
        ? decoded.width
        : decoded.height;
    final resized = longest > _maxEdge
        ? img.copyResize(
            decoded,
            width: decoded.width >= decoded.height ? _maxEdge : null,
            height: decoded.height > decoded.width ? _maxEdge : null,
          )
        : decoded;
    final processed = Uint8List.fromList(
      img.encodeJpg(resized, quality: _jpegQuality),
    );

    await _stagingDir.create(recursive: true);
    await _stagedFile(eventId, tag).writeAsBytes(processed, flush: true);

    return StagedPhoto(
      eventId: eventId,
      tag: tag,
      finalFileName: '$eventId.jpg',
    );
  }

  @override
  Future<void> promoteStagedPhoto({
    required String eventId,
    required int tag,
  }) async {
    _requireSafeEventId(eventId);
    // Same-volume rename: atomic, and replaces any previous final photo
    // only after the new data is durable (spec §4.5).
    await _stagedFile(eventId, tag).rename(_finalFile('$eventId.jpg').path);
  }

  @override
  Future<void> removeStagedPhoto({
    required String eventId,
    required int tag,
  }) async {
    _requireSafeEventId(eventId);
    final file = _stagedFile(eventId, tag);
    if (await file.exists()) await file.delete();
  }

  @override
  Future<Uint8List?> readManagedPhoto(String fileName) async {
    if (!_safeFinalName.hasMatch(fileName)) return null;
    final file = _finalFile(fileName);
    if (!await file.exists()) return null;
    return file.readAsBytes();
  }

  @override
  Future<bool> removeManagedFile(String fileName) async {
    if (!_safeFinalName.hasMatch(fileName)) {
      throw ArgumentError.value(
        fileName,
        'fileName',
        'is not a managed file name',
      );
    }
    final file = _finalFile(fileName);
    if (!await file.exists()) return false;
    await file.delete();
    return true;
  }

  @override
  Future<void> removeAllManagedMedia() async {
    if (!await baseDirectory.exists()) return;
    final inventoryNow = await inventory();
    for (final name in inventoryNow.finalFileNames) {
      await removeManagedFile(name);
    }
    for (final entry in inventoryNow.staged) {
      final file = _stagedFile(entry.eventId, entry.tag);
      if (await file.exists()) await file.delete();
    }
  }

  @override
  Future<ManagedMediaInventory> inventory() async {
    final finals = <String>[];
    if (await baseDirectory.exists()) {
      for (final entity in baseDirectory.listSync()) {
        if (entity is! File) continue;
        final name = entity.uri.pathSegments.last;
        if (_safeFinalName.hasMatch(name)) finals.add(name);
      }
    }

    final staged = <StagedEntry>[];
    if (await _stagingDir.exists()) {
      for (final entity in _stagingDir.listSync()) {
        if (entity is! File) continue;
        final name = entity.uri.pathSegments.last;
        final match = _stagedName.firstMatch(name);
        if (match == null) continue; // stray junk is ignored, not an error
        staged.add(
          StagedEntry(
            eventId: match.group(1)!,
            tag: int.parse(match.group(2)!),
          ),
        );
      }
    }

    finals.sort();
    return ManagedMediaInventory(finalFileNames: finals, staged: staged);
  }
}
