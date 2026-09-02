import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../contracts/camera_source.dart';
import '../contracts/clock.dart';
import '../domain/rng/seeded_prng.dart';

/// Deterministic reviewer/test camera (spec §2, ADR 0004 #3): produces the
/// same placeholder photo for the same local date, so simulated journeys are
/// exactly reproducible. Used by every platform until Sprint 6 lands the
/// mobile adapter.
class SimulatedCameraSource implements CameraSource {
  SimulatedCameraSource({required this.clock});

  final Clock clock;

  static const int _edge = 320;

  @override
  Future<CaptureResult> capture() async {
    final localDate = clock.now().localDate;
    // Repo-owned fold instead of String.hashCode, which is not stable
    // across SDK versions (same reasoning as ADR 0002's PRNG).
    final seed = localDate.codeUnits.fold<int>(
      17,
      (acc, unit) => (acc * 31 + unit) & 0x7FFFFFFF,
    );
    final prng = SeededPrng(seed);

    final image = img.Image(width: _edge, height: _edge);
    final base = img.ColorRgb8(
      60 + prng.nextInt(140),
      60 + prng.nextInt(140),
      60 + prng.nextInt(140),
    );
    img.fill(image, color: base);
    // A simple off-center disc so the placeholder reads as "a photo",
    // not a blank swatch.
    img.fillCircle(
      image,
      x: _edge ~/ 2 + prng.nextInt(60) - 30,
      y: _edge ~/ 2 + prng.nextInt(60) - 30,
      radius: 60 + prng.nextInt(40),
      color: img.ColorRgb8(
        30 + prng.nextInt(200),
        30 + prng.nextInt(200),
        30 + prng.nextInt(200),
      ),
    );

    final bytes = Uint8List.fromList(img.encodeJpg(image, quality: 85));
    return CapturePhoto(CapturedPhoto(bytes: bytes));
  }
}
