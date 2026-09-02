import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:roots/app.dart';
import 'package:roots/contracts/seed_source.dart';
import 'package:roots/domain/model/check_in_moment.dart';
import 'package:roots/contracts/clock.dart';
import 'package:roots/infrastructure/drift/companion_database.dart';
import 'package:roots/infrastructure/drift/drift_companion_repository.dart';
import 'package:roots/infrastructure/fs_managed_media_store.dart';
import 'package:roots/infrastructure/simulated_camera_source.dart';
import 'package:roots/infrastructure/uuid_id_source.dart';
import 'package:roots/presentation/app_providers.dart';

/// Deterministic clock so the reviewer journey replays identically.
class _ReviewClock implements Clock {
  @override
  CheckInMoment now() => CheckInMoment(
    utcInstant: DateTime.utc(2026, 9, 1, 9, 30),
    offsetMinutes: 0,
  );
}

class _ReviewSeeds implements SeedSource {
  @override
  int nextSeed() => 20260901;
}

/// The spec §13 reviewer loop, on real infrastructure: real SQLite file,
/// real managed-media directory, simulated camera — no backend, no camera
/// hardware. Ends by "relaunching" against the same database file and
/// asserting the identical reconstructed plant.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('daily check-in journey persists and survives relaunch', (
    tester,
  ) async {
    final workDir = await Directory.systemTemp.createTemp(
      'roots-reviewer-journey',
    );
    addTearDown(() async {
      if (await workDir.exists()) {
        await workDir.delete(recursive: true);
      }
    });
    final dbFile = File('${workDir.path}/plant_selfie.sqlite');
    final mediaDir = Directory('${workDir.path}/plant_selfie_media');
    const ids = UuidIdSource();

    Future<CompanionDatabase> launchApp() async {
      final database = CompanionDatabase(NativeDatabase(dbFile));
      await tester.pumpWidget(
        ProviderScope(
          key: UniqueKey(),
          overrides: [
            repositoryProvider.overrideWithValue(
              DriftCompanionRepository(database: database, idSource: ids),
            ),
            mediaStoreProvider.overrideWithValue(
              FsManagedMediaStore(baseDirectory: mediaDir),
            ),
            clockProvider.overrideWithValue(_ReviewClock()),
            cameraSourceProvider.overrideWith(
              (ref) => SimulatedCameraSource(clock: ref.watch(clockProvider)),
            ),
            idSourceProvider.overrideWithValue(ids),
            seedSourceProvider.overrideWithValue(_ReviewSeeds()),
          ],
          child: const RootsApp(),
        ),
      );
      await tester.pumpAndSettle();
      return database;
    }

    // First launch: accountless empty Home.
    final firstRun = await launchApp();
    expect(find.text('GROW SOMETHING PERSONAL'), findsOneWidget);

    // The daily loop: capture (simulated) -> mood -> confirm.
    await tester.tap(find.text('TAKE TODAY\'S SELFIE'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('USE THIS PHOTO'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Happy'));
    await tester.pump();
    await tester.tap(find.text('CONTINUE'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ADD TODAY\'S GROWTH'));
    await tester.pumpAndSettle();

    // 09:30 morning + Happy -> 4 leaves (spec A.3, delta-derived headline).
    expect(find.text('4 NEW LEAVES ARE PART OF IT NOW.'), findsOneWidget);
    expect(
      find.text('Come back tomorrow, or don\'t. It keeps.'),
      findsOneWidget,
    );
    expect(find.text('REVIEW TODAY\'S CHECK-IN'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp(r'Your plant: 1 check-in')),
      findsOneWidget,
    );

    // One managed photo, named after the event id, exists on disk.
    expect(mediaDir.listSync().whereType<File>(), hasLength(1));

    await firstRun.close();

    // Relaunch against the same database file: the plant is reconstructed
    // deterministically from canonical events (spec §9).
    final secondRun = await launchApp();
    addTearDown(secondRun.close);

    expect(find.text('4 NEW LEAVES ARE PART OF IT NOW.'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp(r'Your plant: 1 check-in')),
      findsOneWidget,
    );
  });
}
