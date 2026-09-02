import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:roots/presentation/theme/stage_sheet.dart';

void main() {
  const total = Size(400, 700);

  Future<void> pump(
    WidgetTester tester, {
    required StagePanelMode mode,
    double panelContentHeight = 200,
  }) async {
    await tester.binding.setSurfaceSize(total);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StagePanelLayout(
            mode: mode,
            stage: Container(key: const Key('stage'), color: Colors.green),
            panel: SizedBox(
              key: const Key('panel'),
              height: mode == StagePanelMode.panelIntrinsic
                  ? panelContentHeight
                  : null,
              child: const ColoredBox(color: Colors.blue),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('panelIntrinsic: panel keeps its height at the bottom and the '
      'stage extends behind it by the overlap', (tester) async {
    await pump(tester, mode: StagePanelMode.panelIntrinsic);

    final stage = tester.getRect(find.byKey(const Key('stage')));
    final panel = tester.getRect(find.byKey(const Key('panel')));

    expect(panel.height, 200);
    expect(panel.bottom, total.height);
    expect(panel.width, total.width);
    expect(stage.top, 0);
    expect(stage.width, total.width);
    // Stage bottom reaches under the panel top by exactly the overlap.
    expect(stage.bottom, panel.top + StagePanelLayout.overlap);
  });

  testWidgets('panelIntrinsic: a towering panel is capped so the stage never '
      'collapses', (tester) async {
    await pump(
      tester,
      mode: StagePanelMode.panelIntrinsic,
      panelContentHeight: 3000,
    );

    final stage = tester.getRect(find.byKey(const Key('stage')));
    final panel = tester.getRect(find.byKey(const Key('panel')));

    expect(panel.height, lessThanOrEqualTo(total.height * 0.75));
    expect(stage.height, greaterThan(80));
  });

  testWidgets('stageFraction: the stage takes its clamped fraction and the '
      'sheet fills the rest, overlapping it', (tester) async {
    await pump(tester, mode: StagePanelMode.stageFraction);

    final stage = tester.getRect(find.byKey(const Key('stage')));
    final panel = tester.getRect(find.byKey(const Key('panel')));

    final expectedStage = (total.height * 0.26).clamp(120.0, 260.0);
    expect(stage.height, expectedStage);
    expect(panel.top, expectedStage - StagePanelLayout.overlap);
    expect(panel.bottom, total.height);
    expect(panel.width, total.width);
  });

  testWidgets('stageFraction: a short viewport still yields a usable stage '
      'and sheet', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 480));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StagePanelLayout(
            mode: StagePanelMode.stageFraction,
            stage: Container(key: const Key('stage')),
            panel: Container(key: const Key('panel')),
          ),
        ),
      ),
    );

    final stage = tester.getRect(find.byKey(const Key('stage')));
    final panel = tester.getRect(find.byKey(const Key('panel')));
    expect(
      stage.height,
      closeTo(124.8, 0.01),
      reason: '26% of 480 within [120, 260]',
    );
    expect(panel.height, greaterThan(300));
  });
}
