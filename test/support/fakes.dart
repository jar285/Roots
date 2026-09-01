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

/// Records saves; file "contents" live in memory keyed by returned name.
class InMemoryManagedMediaStore implements ManagedMediaStore {
  final Map<String, Uint8List> files = {};
  final List<String> saveLog = [];

  @override
  Future<String> saveProcessedPhoto({
    required String eventId,
    required Uint8List bytes,
  }) async {
    final fileName = '$eventId.jpg';
    files[fileName] = bytes;
    saveLog.add(fileName);
    return fileName;
  }
}

class FakeCameraSource implements CameraSource {
  FakeCameraSource({this.photo});

  /// Null simulates the user cancelling capture.
  CapturedPhoto? photo;

  @override
  Future<CapturedPhoto?> capture() async => photo;
}
