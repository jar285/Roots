import 'dart:io';

import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'application/reconcile_managed_media.dart';
import 'infrastructure/drift/companion_database.dart';
import 'infrastructure/drift/drift_companion_repository.dart';
import 'infrastructure/fs_managed_media_store.dart';
import 'infrastructure/mobile_camera_source.dart';
import 'infrastructure/simulated_camera_source.dart';
import 'infrastructure/system_clock.dart';
import 'infrastructure/system_seed_source.dart';
import 'infrastructure/uuid_id_source.dart';
import 'presentation/app_providers.dart';

/// Composition root: the only place that touches path_provider and wires
/// production adapters. Everything below it is injected and testable.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final documents = await getApplicationDocumentsDirectory();
  final mediaDirectory = Directory('${documents.path}/plant_selfie_media');

  // Spec A.2: database file plant_selfie.sqlite.
  final database = CompanionDatabase(driftDatabase(name: 'plant_selfie'));
  final repository = DriftCompanionRepository(
    database: database,
    idSource: const UuidIdSource(),
  );
  final mediaStore = FsManagedMediaStore(baseDirectory: mediaDirectory);

  // Repair any interrupted save or deletion before the UI loads (ADR 0005).
  await ReconcileManagedMedia(repository: repository, mediaStore: mediaStore)();

  runApp(
    ProviderScope(
      overrides: [
        repositoryProvider.overrideWithValue(repository),
        mediaStoreProvider.overrideWithValue(mediaStore),
        clockProvider.overrideWithValue(const SystemClock()),
        // Real capture on the product surfaces; the deterministic simulated
        // source stays the reviewer path everywhere else (ADR 0008 #8).
        cameraSourceProvider.overrideWith(
          (ref) => (Platform.isIOS || Platform.isAndroid)
              ? MobileCameraSource()
              : SimulatedCameraSource(clock: ref.watch(clockProvider)),
        ),
        idSourceProvider.overrideWithValue(const UuidIdSource()),
        seedSourceProvider.overrideWithValue(SystemSeedSource()),
      ],
      child: const RootsApp(),
    ),
  );
}
