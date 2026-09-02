import 'dart:typed_data';

/// One captured (or simulated) photo, as processing-ready bytes.
class CapturedPhoto {
  const CapturedPhoto({required this.bytes});

  final Uint8List bytes;
}

/// Every way a capture attempt can end (ADR 0008 #3). Failure behavior is
/// product behavior: the UI needs to tell denial, cancellation, and absent
/// hardware apart to offer the right recovery (spec §8.9).
sealed class CaptureResult {
  const CaptureResult();
}

final class CapturePhoto extends CaptureResult {
  const CapturePhoto(this.photo);

  final CapturedPhoto photo;
}

/// The user backed out of the OS camera: return to the previous stable state
/// with no event and no error (spec §8 "camera cancelled").
final class CaptureCancelled extends CaptureResult {
  const CaptureCancelled();
}

/// Camera permission is not granted. [permanentlyDenied] means the OS will
/// not prompt again, so the UI offers Settings instead of re-prompting.
final class CapturePermissionDenied extends CaptureResult {
  const CapturePermissionDenied({required this.permanentlyDenied});

  final bool permanentlyDenied;
}

/// No usable camera (desktop, simulator, hardware failure). [reason] is for
/// privacy-safe diagnostics, never shown raw to the user.
final class CameraUnavailable extends CaptureResult {
  const CameraUnavailable(this.reason);

  final String reason;
}

/// Owns capture input (spec §5.1). The mobile adapter arrives in Sprint 6;
/// macOS and automated journeys keep using the simulated source.
abstract interface class CameraSource {
  Future<CaptureResult> capture();
}
