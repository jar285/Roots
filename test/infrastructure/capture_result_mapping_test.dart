import 'package:camera/camera.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:roots/contracts/camera_source.dart';
import 'package:roots/infrastructure/mobile_camera_source.dart';

/// The mobile adapter's most failure-prone logic is a pure function, so every
/// realistic camera failure has a tested recovery outcome without a device
/// (ADR 0008 #4).
void main() {
  group('captureResultForError', () {
    test(
      'iOS and Android permission denials become CapturePermissionDenied',
      () {
        for (final code in [
          'CameraAccessDenied',
          'CameraAccessDeniedWithoutPrompt',
          'cameraPermission',
          'CameraAccessRestricted',
        ]) {
          final result = captureResultForError(CameraException(code, 'denied'));
          expect(
            result,
            isA<CapturePermissionDenied>(),
            reason: '$code must map to a permission outcome',
          );
        }
      },
    );

    test('a permanent denial is flagged so the UI stops re-prompting', () {
      final permanent = captureResultForError(
        CameraException('CameraAccessDeniedWithoutPrompt', 'denied'),
      );
      expect((permanent as CapturePermissionDenied).permanentlyDenied, isTrue);

      final firstTime = captureResultForError(
        CameraException('CameraAccessDenied', 'denied'),
      );
      expect((firstTime as CapturePermissionDenied).permanentlyDenied, isFalse);
    });

    test('missing hardware becomes CameraUnavailable', () {
      expect(
        captureResultForError(CameraException('cameraNotFound', 'none')),
        isA<CameraUnavailable>(),
      );
      expect(
        captureResultForError(CameraException('CameraNotFound', 'none')),
        isA<CameraUnavailable>(),
      );
    });

    test('any other error is still a named outcome, never a crash', () {
      expect(
        captureResultForError(StateError('unexpected')),
        isA<CameraUnavailable>(),
      );
      expect(
        captureResultForError(CameraException('someNewCode', 'huh')),
        isA<CameraUnavailable>(),
      );
    });
  });
}
