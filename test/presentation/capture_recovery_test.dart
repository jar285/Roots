import 'package:flutter_test/flutter_test.dart';

import 'package:roots/contracts/camera_source.dart';

import '../support/fakes.dart';
import '../support/pump_app.dart';

/// Camera denial, cancellation, and absence each need a usable recovery path
/// (spec §9, A.7 copy; development philosophy #6).
void main() {
  Future<void> openCapture(WidgetTester tester) async {
    await tester.tap(find.text('TAKE TODAY\'S SELFIE'));
    await tester.pumpAndSettle();
  }

  testWidgets('denial explains itself with the approved copy and offers '
      'Settings, Try Again, and Cancel (spec A.7)', (tester) async {
    await pumpApp(
      tester,
      camera: FakeCameraSource(
        result: const CapturePermissionDenied(permanentlyDenied: true),
      ),
    );
    await openCapture(tester);

    expect(
      find.text(
        'Camera access is off. Enable it in Settings, or use the reviewer '
        'simulation where available.',
      ),
      findsOneWidget,
    );
    expect(find.text('OPEN SETTINGS'), findsOneWidget);
    expect(find.text('TRY AGAIN'), findsOneWidget);
    expect(find.text('CANCEL'), findsOneWidget);
  });

  testWidgets('a first-time denial offers Try Again but not Settings '
      '(no repeated OS prompts)', (tester) async {
    await pumpApp(
      tester,
      camera: FakeCameraSource(
        result: const CapturePermissionDenied(permanentlyDenied: false),
      ),
    );
    await openCapture(tester);

    expect(find.text('TRY AGAIN'), findsOneWidget);
    expect(find.text('OPEN SETTINGS'), findsNothing);
  });

  testWidgets(
    'denial never saves an event and Cancel returns to a stable Home',
    (tester) async {
      final handles = await pumpApp(
        tester,
        camera: FakeCameraSource(
          result: const CapturePermissionDenied(permanentlyDenied: true),
        ),
      );
      await openCapture(tester);

      await tester.tap(find.text('CANCEL'));
      await tester.pumpAndSettle();

      expect(find.text('GROW SOMETHING PERSONAL'), findsOneWidget);
      expect(await handles.repository.allEvents(), isEmpty);
    },
  );

  testWidgets('Try Again re-attempts capture and proceeds once granted', (
    tester,
  ) async {
    final camera = FakeCameraSource(
      result: const CapturePermissionDenied(permanentlyDenied: false),
    );
    await pumpApp(tester, camera: camera);
    await openCapture(tester);

    camera.result = CapturePhoto(CapturedPhoto(bytes: tinyJpeg));
    await tester.tap(find.text('TRY AGAIN'));
    await tester.pumpAndSettle();

    expect(find.text('USE THIS PHOTO'), findsOneWidget);
  });

  testWidgets('an unavailable camera explains itself and stays recoverable', (
    tester,
  ) async {
    await pumpApp(
      tester,
      camera: FakeCameraSource(
        result: const CameraUnavailable('no camera on this device'),
      ),
    );
    await openCapture(tester);

    expect(find.text('No camera is available on this device.'), findsOneWidget);
    expect(find.text('TRY AGAIN'), findsOneWidget);
    expect(find.text('CANCEL'), findsOneWidget);
  });

  testWidgets('cancelling at the OS camera returns Home with no event and no '
      'error state (spec §8 camera cancelled)', (tester) async {
    final handles = await pumpApp(
      tester,
      camera: FakeCameraSource(result: const CaptureCancelled()),
    );
    await openCapture(tester);
    await tester.pumpAndSettle();

    expect(find.text('GROW SOMETHING PERSONAL'), findsOneWidget);
    expect(await handles.repository.allEvents(), isEmpty);
    expect(find.textContaining('Camera access is off'), findsNothing);
  });
}
