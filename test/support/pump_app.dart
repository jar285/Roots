import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'package:roots/app.dart';
import 'package:roots/contracts/camera_source.dart';
import 'package:roots/domain/model/check_in_moment.dart';
import 'package:roots/presentation/app_providers.dart';

import 'fakes.dart';
import 'in_memory_companion_repository.dart';

/// A tiny but valid JPEG so Image.memory can decode previews in tests.
final Uint8List tinyJpeg = Uint8List.fromList(
  img.encodeJpg(img.Image(width: 8, height: 8)),
);

CheckInMoment momentOn({int day = 1, int hour = 12}) => CheckInMoment(
  utcInstant: DateTime.utc(2026, 9, day, hour),
  offsetMinutes: 0,
);

/// Pumps the full app with fake adapters. Returns the handles tests need.
Future<
  ({
    InMemoryCompanionRepository repository,
    InMemoryManagedMediaStore mediaStore,
    FixedClock clock,
    FakeCameraSource camera,
  })
>
pumpApp(
  WidgetTester tester, {
  InMemoryCompanionRepository? repository,
  FixedClock? clock,
  FakeCameraSource? camera,
}) async {
  final repo =
      repository ?? InMemoryCompanionRepository(idSource: SequentialIds());
  final media = InMemoryManagedMediaStore();
  final theClock = clock ?? FixedClock(momentOn());
  final theCamera =
      camera ?? FakeCameraSource(photo: CapturedPhoto(bytes: tinyJpeg));

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        repositoryProvider.overrideWithValue(repo),
        mediaStoreProvider.overrideWithValue(media),
        clockProvider.overrideWithValue(theClock),
        cameraSourceProvider.overrideWithValue(theCamera),
        idSourceProvider.overrideWithValue(SequentialIds()),
        seedSourceProvider.overrideWithValue(FixedSeedSource(4242)),
      ],
      child: const RootsApp(),
    ),
  );
  await tester.pumpAndSettle();

  return (
    repository: repo,
    mediaStore: media,
    clock: theClock,
    camera: theCamera,
  );
}
