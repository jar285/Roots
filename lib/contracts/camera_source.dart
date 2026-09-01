import 'dart:typed_data';

/// One captured (or simulated) photo, as processed-ready bytes.
class CapturedPhoto {
  const CapturedPhoto({required this.bytes});

  final Uint8List bytes;
}

/// Owns capture input (spec §5.1). Mobile adapters arrive in Sprint 6;
/// until then every platform uses the simulated source (ADR 0004).
abstract interface class CameraSource {
  /// Returns the captured photo, or null when the user cancelled.
  Future<CapturedPhoto?> capture();
}
