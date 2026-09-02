import 'dart:io';

import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

import '../contracts/camera_source.dart';

/// Maps any camera failure onto a named recovery outcome (ADR 0008 #4).
/// Pure and unit-tested, because this is where device behavior varies most.
CaptureResult captureResultForError(Object error) {
  if (error is CameraException) {
    switch (error.code) {
      // iOS "…WithoutPrompt" and Android's restricted state mean the OS will
      // not ask again: the only way forward is Settings.
      case 'CameraAccessDeniedWithoutPrompt':
      case 'CameraAccessRestricted':
      case 'AudioAccessDeniedWithoutPrompt':
        return const CapturePermissionDenied(permanentlyDenied: true);
      case 'CameraAccessDenied':
      case 'cameraPermission':
      case 'AudioAccessDenied':
        return const CapturePermissionDenied(permanentlyDenied: false);
      case 'cameraNotFound':
      case 'CameraNotFound':
        return CameraUnavailable('camera not found (${error.code})');
      default:
        return CameraUnavailable('camera error ${error.code}');
    }
  }
  return CameraUnavailable('unexpected capture failure: ${error.runtimeType}');
}

/// Real mobile capture (spec §5.1, Sprint 6). A thin shell: it asks for
/// permission in context, takes one picture with the front camera when
/// available, hands the bytes to the media boundary, and deletes the
/// temporary OS file so no unprocessed original is retained (spec §5.4).
class MobileCameraSource implements CameraSource {
  MobileCameraSource({this.preferFrontCamera = true});

  final bool preferFrontCamera;

  @override
  Future<CaptureResult> capture() async {
    try {
      // Ask in context, immediately before use (spec §11).
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        return CapturePermissionDenied(
          permanentlyDenied: status.isPermanentlyDenied || status.isRestricted,
        );
      }

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        return const CameraUnavailable('no cameras reported by the platform');
      }
      final description = cameras.firstWhere(
        (c) =>
            !preferFrontCamera || c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        description,
        ResolutionPreset.high,
        enableAudio: false,
      );
      try {
        await controller.initialize();
        final file = await controller.takePicture();
        final bytes = await file.readAsBytes();
        // The processed managed copy is the only retained image (spec §5.4).
        await _deleteQuietly(file.path);
        return CapturePhoto(CapturedPhoto(bytes: bytes));
      } finally {
        await controller.dispose();
      }
    } catch (error) {
      return captureResultForError(error);
    }
  }

  Future<void> _deleteQuietly(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (_) {
      // A leftover OS temp file is the platform's to clean; never fail a
      // successful capture over it.
    }
  }
}

/// Deep-links to the app's OS settings page for a permanently denied camera
/// (ADR 0008 #2). Injected so widget tests can assert the call without
/// touching platform channels.
abstract interface class AppSettingsLauncher {
  Future<void> openAppSettingsPage();
}

class PlatformAppSettingsLauncher implements AppSettingsLauncher {
  const PlatformAppSettingsLauncher();

  @override
  Future<void> openAppSettingsPage() => openAppSettings();
}
