import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:roots/domain/model/growth_event.dart';
import 'package:roots/domain/projection/plant_projector.dart';
import 'package:roots/presentation/plant/plant_view.dart';
import 'package:roots/presentation/theme/app_theme.dart';

import '../domain/pacing_harness_test.dart' show dailyEvent;
import '../support/fakes.dart';
import '../support/pump_app.dart';
import 'home_screen_test.dart' show repositoryWithCheckInOn;

/// Goldens pin only stable, high-value states (ADR 0007 #3): the two Home
/// contracts, and the plant at the spec's pacing-gate checkpoints — these
/// PNGs are the visual-review artifacts for the maturity validation gate.
void main() {
  PlantState plantAfterDays(int days) {
    final events = List<GrowthEvent>.generate(days, dailyEvent);
    final result = ProjectorRegistry.standard().project(events);
    return (result as ProjectionSuccess).plantState;
  }

  Future<void> withSurface(
    WidgetTester tester,
    Future<void> Function() body,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await body();
  }

  testWidgets('golden: empty Home', (tester) async {
    await withSurface(tester, () async {
      await pumpApp(tester);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/home_empty.png'),
      );
    });
  });

  testWidgets('golden: completed-today Home', (tester) async {
    await withSurface(tester, () async {
      final repository = await repositoryWithCheckInOn(day: 2);
      await pumpApp(
        tester,
        repository: repository,
        clock: FixedClock(momentOn(day: 2)),
      );
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/home_completed.png'),
      );
    });
  });

  for (final days in const [30, 90, 180, 365]) {
    testWidgets('golden: plant after $days daily check-ins (pacing gate)', (
      tester,
    ) async {
      await withSurface(tester, () async {
        await tester.pumpWidget(
          MaterialApp(
            theme: buildAppTheme(),
            home: Scaffold(
              backgroundColor: AppTokens.background,
              body: Center(
                child: SizedBox(
                  width: 350,
                  height: 560,
                  child: PlantView(plant: plantAfterDays(days)),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        await expectLater(
          find.byType(PlantView),
          matchesGoldenFile('goldens/plant_day_$days.png'),
        );
      });
    });
  }
}
