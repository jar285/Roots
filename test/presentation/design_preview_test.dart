import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';
import '../support/pump_app.dart';
import 'home_screen_test.dart' show repositoryWithCheckInOn;

/// Design QA harness: renders key screens WITH REAL FONTS to
/// build/design_previews/*.png so humans can review actual typography and
/// composition (golden files use the blocky test font by design). Not a
/// golden — it asserts nothing visual, it produces review artifacts.
void main() {
  setUpAll(() async {
    // Load Roboto from the Flutter SDK cache so text renders realistically.
    final flutterRoot =
        Platform.environment['FLUTTER_ROOT'] ?? '/opt/homebrew/share/flutter';
    final fontDir = Directory(
      '$flutterRoot/bin/cache/artifacts/material_fonts',
    );
    if (!fontDir.existsSync()) return;
    final loader = FontLoader('Roboto');
    for (final file in fontDir.listSync().whereType<File>()) {
      final name = file.uri.pathSegments.last;
      if (name.startsWith('Roboto-')) {
        loader.addFont(
          Future.value(ByteData.sublistView(file.readAsBytesSync())),
        );
      }
    }
    await loader.load();
  });

  Future<void> capture(WidgetTester tester, String name) async {
    // Engine-side image encoding needs real async inside widget tests.
    await tester.runAsync(() async {
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byType(RepaintBoundary).first,
      );
      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final out = File('build/design_previews/$name.png');
      out.parent.createSync(recursive: true);
      out.writeAsBytesSync(bytes!.buffer.asUint8List());
    });
  }

  testWidgets('render design previews with real fonts', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 780));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    // Empty Home.
    await pumpApp(tester);
    await capture(tester, 'home_empty');

    // Completed-today Home.
    final repository = await repositoryWithCheckInOn(day: 2);
    await pumpApp(
      tester,
      repository: repository,
      clock: FixedClock(momentOn(day: 2)),
    );
    await capture(tester, 'home_completed');

    // Mood selection.
    await tester.tap(find.text('REVIEW TODAY\'S CHECK-IN'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('KEEP CURRENT PHOTO'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Calm'));
    await tester.pump();
    await capture(tester, 'mood');

    // History.
    await tester.tap(find.text('BACK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('CANCEL'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('HISTORY'));
    await tester.pumpAndSettle();
    await capture(tester, 'history');
  });
}
