import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'package:roots/application/reconcile_managed_media.dart';
import 'package:roots/application/save_daily_check_in.dart';
import 'package:roots/contracts/managed_media_store.dart';
import 'package:roots/domain/model/check_in_moment.dart';
import 'package:roots/domain/model/mood.dart';
import 'package:roots/infrastructure/fs_managed_media_store.dart';

import '../support/fakes.dart';
import '../support/in_memory_companion_repository.dart';

Uint8List photoBytes() =>
    Uint8List.fromList(img.encodePng(img.Image(width: 16, height: 16)));

/// Delegates to a real store but fails promotion — the crash window between
/// database commit and file promotion (spec §5.4).
class _PromoteFails implements ManagedMediaStore {
  _PromoteFails(this.inner);

  final ManagedMediaStore inner;

  @override
  Future<StagedPhoto> prepareCapturedPhoto({
    required String eventId,
    required int tag,
    required Uint8List bytes,
  }) => inner.prepareCapturedPhoto(eventId: eventId, tag: tag, bytes: bytes);

  @override
  Future<void> promoteStagedPhoto({
    required String eventId,
    required int tag,
  }) async {
    throw Exception('simulated crash before promotion');
  }

  @override
  Future<void> removeStagedPhoto({required String eventId, required int tag}) =>
      inner.removeStagedPhoto(eventId: eventId, tag: tag);

  @override
  Future<Uint8List?> readManagedPhoto(String fileName) =>
      inner.readManagedPhoto(fileName);

  @override
  Future<bool> removeManagedFile(String fileName) =>
      inner.removeManagedFile(fileName);

  @override
  Future<void> removeAllManagedMedia() => inner.removeAllManagedMedia();

  @override
  Future<ManagedMediaInventory> inventory() => inner.inventory();
}

void main() {
  late Directory baseDir;
  late FsManagedMediaStore store;
  late InMemoryCompanionRepository repository;
  late ReconcileManagedMedia reconcile;

  final moment = CheckInMoment(
    utcInstant: DateTime.utc(2026, 9, 1, 14, 5),
    offsetMinutes: 0,
  );

  setUp(() async {
    baseDir = await Directory.systemTemp.createTemp('roots-reconcile-test');
    store = FsManagedMediaStore(baseDirectory: baseDir);
    repository = InMemoryCompanionRepository(idSource: SequentialIds());
    reconcile = ReconcileManagedMedia(
      repository: repository,
      mediaStore: store,
    );
  });

  tearDown(() async {
    if (await baseDir.exists()) {
      await baseDir.delete(recursive: true);
    }
  });

  SaveDailyCheckIn saver({ManagedMediaStore? media}) => SaveDailyCheckIn(
    repository: repository,
    mediaStore: media ?? store,
    clock: FixedClock(moment),
    idSource: SequentialIds(),
    seedSource: FixedSeedSource(7),
  );

  test('removes a staged file whose save never committed', () async {
    await store.prepareCapturedPhoto(
      eventId: 'abandoned',
      tag: 111,
      bytes: photoBytes(),
    );

    final report = await reconcile();

    expect(report.removedStaged, 1);
    expect(report.promoted, 0);
    expect((await store.inventory()).staged, isEmpty);
  });

  test('promotes a staged file whose event committed (crash before '
      'promotion), restoring the photo', () async {
    await expectLater(
      saver(media: _PromoteFails(store))(mood: Mood.calm, photo: photoBytes()),
      throwsException,
    );
    final event = (await repository.allEvents()).single;
    expect(
      await store.readManagedPhoto(event.selfieFileName),
      isNull,
      reason: 'the crash left the committed event without its photo',
    );

    final report = await reconcile();

    expect(report.promoted, 1);
    expect(report.removedStaged, 0);
    expect(await store.readManagedPhoto(event.selfieFileName), isNotNull);
  });

  test('removes a staged file from an abandoned same-day edit, keeping the '
      'committed photo (ADR 0005 #1)', () async {
    await saver()(mood: Mood.calm, photo: photoBytes());
    final event = (await repository.allEvents()).single;
    final committedBytes = await store.readManagedPhoto(event.selfieFileName);
    // An edit staged a new photo but crashed before committing: its tag
    // matches no event's updatedAtUtc.
    await store.prepareCapturedPhoto(
      eventId: event.id,
      tag: event.updatedAtUtc.millisecondsSinceEpoch + 5000,
      bytes: photoBytes(),
    );

    final report = await reconcile();

    expect(report.removedStaged, 1);
    expect(report.promoted, 0);
    expect(await store.readManagedPhoto(event.selfieFileName), committedBytes);
  });

  test(
    'removes final files no event references (failed deletion cleanup)',
    () async {
      final staged = await store.prepareCapturedPhoto(
        eventId: 'ghost',
        tag: 1,
        bytes: photoBytes(),
      );
      await store.promoteStagedPhoto(eventId: staged.eventId, tag: staged.tag);

      final report = await reconcile();

      expect(report.removedOrphanFinals, 1);
      expect(await store.readManagedPhoto('ghost.jpg'), isNull);
    },
  );

  test('leaves a healthy store untouched and is idempotent', () async {
    await saver()(mood: Mood.happy, photo: photoBytes());

    final first = await reconcile();
    final second = await reconcile();

    for (final report in [first, second]) {
      expect(report.promoted, 0);
      expect(report.removedStaged, 0);
      expect(report.removedOrphanFinals, 0);
    }
    final event = (await repository.allEvents()).single;
    expect(await store.readManagedPhoto(event.selfieFileName), isNotNull);
  });
}
