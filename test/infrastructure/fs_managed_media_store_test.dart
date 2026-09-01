import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:roots/infrastructure/fs_managed_media_store.dart';

void main() {
  late Directory baseDir;
  late FsManagedMediaStore store;

  setUp(() async {
    baseDir = await Directory.systemTemp.createTemp('roots-media-test');
    store = FsManagedMediaStore(baseDirectory: baseDir);
  });

  tearDown(() async {
    if (await baseDir.exists()) {
      await baseDir.delete(recursive: true);
    }
  });

  test(
    'saves processed bytes under the event id and returns the name',
    () async {
      final bytes = Uint8List.fromList([10, 20, 30]);

      final fileName = await store.saveProcessedPhoto(
        eventId: 'event-1',
        bytes: bytes,
      );

      expect(fileName, 'event-1.jpg');
      final file = File('${baseDir.path}/event-1.jpg');
      expect(await file.exists(), isTrue);
      expect(await file.readAsBytes(), bytes);
    },
  );

  test(
    'overwrites the photo for the same event id (same-day replacement)',
    () async {
      await store.saveProcessedPhoto(
        eventId: 'event-1',
        bytes: Uint8List.fromList([1]),
      );
      await store.saveProcessedPhoto(
        eventId: 'event-1',
        bytes: Uint8List.fromList([2, 2]),
      );

      final file = File('${baseDir.path}/event-1.jpg');
      expect(await file.readAsBytes(), [2, 2]);
      expect(baseDir.listSync(), hasLength(1));
    },
  );

  test('creates the managed directory when it does not exist yet', () async {
    final nested = Directory('${baseDir.path}/not-yet/media');
    final nestedStore = FsManagedMediaStore(baseDirectory: nested);

    await nestedStore.saveProcessedPhoto(
      eventId: 'e',
      bytes: Uint8List.fromList([5]),
    );

    expect(await File('${nested.path}/e.jpg').exists(), isTrue);
  });

  test(
    'rejects event ids that could escape the managed directory (A.9)',
    () async {
      for (final hostile in ['../evil', 'a/b', r'a\b', '..', '']) {
        await expectLater(
          store.saveProcessedPhoto(
            eventId: hostile,
            bytes: Uint8List.fromList([1]),
          ),
          throwsArgumentError,
          reason: 'eventId "$hostile" must be rejected',
        );
      }
    },
  );
}
