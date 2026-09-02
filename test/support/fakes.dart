import 'dart:typed_data';

import 'package:roots/contracts/camera_source.dart';
import 'package:roots/contracts/clock.dart';
import 'package:roots/contracts/id_source.dart';
import 'package:roots/contracts/managed_media_store.dart';
import 'package:roots/contracts/seed_source.dart';
import 'package:roots/domain/model/check_in_moment.dart';

class FixedClock implements Clock {
  FixedClock(this.moment);

  CheckInMoment moment;

  @override
  CheckInMoment now() => moment;
}

class FixedSeedSource implements SeedSource {
  FixedSeedSource(this.seed);

  int seed;

  @override
  int nextSeed() => seed;
}

class SequentialIds implements IdSource {
  int _next = 0;

  @override
  String nextId() => 'id-${++_next}';
}

/// In-memory ManagedMediaStore mirroring the staged lifecycle (ADR 0005):
/// `staged` holds prepared-but-unpromoted photos, `files` the final ones.
/// Failure injection flags let use-case tests exercise interruption paths.
class InMemoryManagedMediaStore implements ManagedMediaStore {
  final Map<String, Uint8List> staged = {}; // '<eventId>.<tag>' -> bytes
  final Map<String, Uint8List> files = {}; // '<eventId>.jpg' -> bytes
  final List<String> log = [];

  bool failOnPromote = false;
  bool failOnRemove = false;
  bool failOnRemoveAll = false;

  @override
  Future<StagedPhoto> prepareCapturedPhoto({
    required String eventId,
    required int tag,
    required Uint8List bytes,
  }) async {
    staged['$eventId.$tag'] = bytes;
    log.add('prepare:$eventId.$tag');
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
    if (failOnPromote) throw Exception('injected promote failure');
    final bytes = staged.remove('$eventId.$tag');
    if (bytes == null) throw StateError('nothing staged for $eventId.$tag');
    files['$eventId.jpg'] = bytes;
    log.add('promote:$eventId.$tag');
  }

  @override
  Future<void> removeStagedPhoto({
    required String eventId,
    required int tag,
  }) async {
    staged.remove('$eventId.$tag');
    log.add('removeStaged:$eventId.$tag');
  }

  @override
  Future<Uint8List?> readManagedPhoto(String fileName) async => files[fileName];

  @override
  Future<bool> removeManagedFile(String fileName) async {
    if (failOnRemove) throw Exception('injected remove failure');
    log.add('remove:$fileName');
    return files.remove(fileName) != null;
  }

  @override
  Future<void> removeAllManagedMedia() async {
    if (failOnRemoveAll) throw Exception('injected removeAll failure');
    log.add('removeAll');
    staged.clear();
    files.clear();
  }

  @override
  Future<ManagedMediaInventory> inventory() async {
    return ManagedMediaInventory(
      finalFileNames: files.keys.toList(),
      staged: [
        for (final key in staged.keys)
          StagedEntry(
            eventId: key.substring(0, key.lastIndexOf('.')),
            tag: int.parse(key.substring(key.lastIndexOf('.') + 1)),
          ),
      ],
    );
  }
}

class FakeCameraSource implements CameraSource {
  FakeCameraSource({this.photo});

  /// Null simulates the user cancelling capture.
  CapturedPhoto? photo;

  @override
  Future<CapturedPhoto?> capture() async => photo;
}
