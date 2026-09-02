import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:roots/domain/model/plant_state.dart';
import 'package:roots/presentation/plant/plant_view.dart';

PlantState plantWith({int leaves = 4}) {
  return PlantState(
    effectiveHeight: 120,
    branches: const [
      PlantElement(
        sourceEventId: 'b-0',
        paletteId: 'v1.calm',
        morphologyId: 'v1.balanced',
      ),
    ],
    leaves: [
      for (var i = 0; i < leaves; i++)
        PlantElement(
          sourceEventId: 'l-$i',
          paletteId: 'v1.happy',
          morphologyId: 'v1.balanced',
        ),
    ],
    decorations: const [],
    eventCount: 2,
    newestEventDate: '2026-09-01',
  );
}

Future<void> pumpPlant(WidgetTester tester, {required bool animate}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 390,
          height: 500,
          child: PlantView(plant: plantWith(), animate: animate),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('the growth reveal animates when motion is allowed', (
    tester,
  ) async {
    await pumpPlant(tester, animate: true);
    await tester.pump();

    expect(
      tester.binding.hasScheduledFrame,
      isTrue,
      reason: 'the 600ms reveal should be running',
    );

    await tester.pumpAndSettle();
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('reduced motion pins the reveal to the final state instantly '
      '(spec §8.8)', (tester) async {
    tester.binding.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(
      tester.binding.platformDispatcher.clearAccessibilityFeaturesTestValue,
    );

    await pumpPlant(tester, animate: true);
    await tester.pump();

    expect(
      tester.binding.hasScheduledFrame,
      isFalse,
      reason: 'no reveal animation under reduced motion',
    );
    expect(
      find.bySemanticsLabel(RegExp(r'Your plant: 2 check-ins')),
      findsOneWidget,
    );
  });

  testWidgets('without a fresh save the plant renders statically', (
    tester,
  ) async {
    await pumpPlant(tester, animate: false);
    await tester.pump();

    expect(tester.binding.hasScheduledFrame, isFalse);
  });
}
