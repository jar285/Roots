import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';
import '../support/pump_app.dart';
import 'home_screen_test.dart' show repositoryWithCheckInOn;

/// Compact phone heights must keep every primary action reachable with no
/// overflow (UI/UX philosophy: "landscape and compact heights remain usable").
void main() {
  Future<void> useCompactSurface(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  testWidgets('empty Home fits a compact phone', (tester) async {
    await useCompactSurface(tester);
    await pumpApp(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('GROW SOMETHING PERSONAL'), findsOneWidget);
    await tester.tap(find.text('TAKE TODAY\'S SELFIE'));
    await tester.pumpAndSettle();
    expect(find.text('USE THIS PHOTO'), findsOneWidget);
  });

  testWidgets('completed Home fits a compact phone', (tester) async {
    await useCompactSurface(tester);
    final repository = await repositoryWithCheckInOn(day: 2);
    await pumpApp(
      tester,
      repository: repository,
      clock: FixedClock(momentOn(day: 2)),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('REVIEW TODAY\'S CHECK-IN'), findsOneWidget);
  });

  testWidgets('mood sheet fits a compact phone with CONTINUE reachable', (
    tester,
  ) async {
    await useCompactSurface(tester);
    await pumpApp(tester);
    await tester.tap(find.text('TAKE TODAY\'S SELFIE'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('USE THIS PHOTO'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('HOW ARE YOU FEELING?'), findsOneWidget);
    expect(find.text('CONTINUE'), findsOneWidget);
    expect(find.text('BACK'), findsOneWidget);
  });
}
