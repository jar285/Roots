import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/delete_growth_event.dart';
import '../application/load_companion.dart';
import '../application/save_daily_check_in.dart';
import '../application/start_over.dart';
import '../contracts/camera_source.dart';
import '../contracts/clock.dart';
import '../contracts/companion_repository.dart';
import '../contracts/id_source.dart';
import '../contracts/managed_media_store.dart';
import '../contracts/seed_source.dart';
import '../domain/model/growth_event.dart';
import '../domain/projection/plant_projector.dart';

/// Adapter providers. Production values are wired by the composition root
/// (main.dart); tests override with fakes. Throwing defaults make a missing
/// override loud instead of subtly wrong (spec §5.2).
final repositoryProvider = Provider<CompanionRepository>(
  (ref) => throw UnimplementedError('override repositoryProvider'),
);
final mediaStoreProvider = Provider<ManagedMediaStore>(
  (ref) => throw UnimplementedError('override mediaStoreProvider'),
);
final cameraSourceProvider = Provider<CameraSource>(
  (ref) => throw UnimplementedError('override cameraSourceProvider'),
);
final clockProvider = Provider<Clock>(
  (ref) => throw UnimplementedError('override clockProvider'),
);
final idSourceProvider = Provider<IdSource>(
  (ref) => throw UnimplementedError('override idSourceProvider'),
);
final seedSourceProvider = Provider<SeedSource>(
  (ref) => throw UnimplementedError('override seedSourceProvider'),
);

final projectorRegistryProvider = Provider<ProjectorRegistry>(
  (ref) => ProjectorRegistry.standard(),
);

final loadCompanionProvider = Provider<LoadCompanion>(
  (ref) => LoadCompanion(
    repository: ref.watch(repositoryProvider),
    registry: ref.watch(projectorRegistryProvider),
    clock: ref.watch(clockProvider),
  ),
);

final saveDailyCheckInProvider = Provider<SaveDailyCheckIn>(
  (ref) => SaveDailyCheckIn(
    repository: ref.watch(repositoryProvider),
    mediaStore: ref.watch(mediaStoreProvider),
    clock: ref.watch(clockProvider),
    idSource: ref.watch(idSourceProvider),
    seedSource: ref.watch(seedSourceProvider),
  ),
);

final deleteGrowthEventProvider = Provider<DeleteGrowthEvent>(
  (ref) => DeleteGrowthEvent(
    repository: ref.watch(repositoryProvider),
    mediaStore: ref.watch(mediaStoreProvider),
  ),
);

final startOverProvider = Provider<StartOver>(
  (ref) => StartOver(
    repository: ref.watch(repositoryProvider),
    mediaStore: ref.watch(mediaStoreProvider),
    idSource: ref.watch(idSourceProvider),
  ),
);

/// The companion as async state: loading, data, and error are all explicit.
class CompanionNotifier extends AsyncNotifier<LoadedCompanion> {
  @override
  Future<LoadedCompanion> build() => ref.watch(loadCompanionProvider)();
}

final companionProvider =
    AsyncNotifierProvider<CompanionNotifier, LoadedCompanion>(
      CompanionNotifier.new,
    );

/// History is the personal archive, newest first (spec §6.5).
final historyProvider = FutureProvider<List<GrowthEvent>>((ref) async {
  final events = await ref.watch(repositoryProvider).allEvents();
  return events.reversed.toList();
});
