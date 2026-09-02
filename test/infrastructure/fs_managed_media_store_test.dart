import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'package:roots/contracts/managed_media_store.dart';
import 'package:roots/infrastructure/fs_managed_media_store.dart';

Uint8List pngOfSize(int width, int height) =>
    Uint8List.fromList(img.encodePng(img.Image(width: width, height: height)));

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

  File finalFile(String name) => File('${baseDir.path}/$name');
  Directory stagingDir() => Directory('${baseDir.path}/staging');

  group('prepareCapturedPhoto (spec §5.4 steps 2–4)', () {
    test(
      'validates, resizes to an 800px edge, encodes JPEG, and stages',
      () async {
        final staged = await store.prepareCapturedPhoto(
          eventId: 'event-1',
          tag: 1725000000000,
          bytes: pngOfSize(1200, 900),
        );

        expect(staged.eventId, 'event-1');
        expect(staged.tag, 1725000000000);
        expect(staged.finalFileName, 'event-1.jpg');

        final stagedFile = File(
          '${stagingDir().path}/event-1.1725000000000.jpg',
        );
        expect(await stagedFile.exists(), isTrue);
        expect(
          await finalFile('event-1.jpg').exists(),
          isFalse,
          reason: 'staging must not touch the final name before promotion',
        );

        final decoded = img.decodeJpg(await stagedFile.readAsBytes());
        expect(decoded, isNotNull);
        expect(decoded!.width, 800);
        expect(decoded.height, 600, reason: 'aspect ratio preserved');
      },
    );

    test('does not upscale small captures', () async {
      await store.prepareCapturedPhoto(
        eventId: 'small',
        tag: 1,
        bytes: pngOfSize(320, 240),
      );

      final stagedFile = File('${stagingDir().path}/small.1.jpg');
      final decoded = img.decodeJpg(await stagedFile.readAsBytes());
      expect(decoded!.width, 320);
      expect(decoded.height, 240);
    });

    test(
      'rejects bytes that are not a decodable image, writing nothing',
      () async {
        await expectLater(
          store.prepareCapturedPhoto(
            eventId: 'bad',
            tag: 1,
            bytes: Uint8List.fromList([1, 2, 3, 4, 5]),
          ),
          throwsA(isA<InvalidPhotoException>()),
        );

        expect(
          stagingDir().existsSync() ? stagingDir().listSync() : const <Never>[],
          isEmpty,
        );
      },
    );

    test(
      'rejects event ids that could escape the managed directory (A.9)',
      () async {
        for (final hostile in ['../evil', 'a/b', '..', '']) {
          await expectLater(
            store.prepareCapturedPhoto(
              eventId: hostile,
              tag: 1,
              bytes: pngOfSize(8, 8),
            ),
            throwsArgumentError,
            reason: 'eventId "$hostile" must be rejected',
          );
        }
      },
    );
  });

  group('promoteStagedPhoto', () {
    test('atomically renames the staged file over the final name', () async {
      final staged = await store.prepareCapturedPhoto(
        eventId: 'e1',
        tag: 7,
        bytes: pngOfSize(100, 100),
      );

      await store.promoteStagedPhoto(eventId: staged.eventId, tag: staged.tag);

      expect(await finalFile('e1.jpg').exists(), isTrue);
      expect(stagingDir().listSync(), isEmpty);
    });

    test(
      'replaces an existing final photo (same-day replacement, §4.5)',
      () async {
        final first = await store.prepareCapturedPhoto(
          eventId: 'e1',
          tag: 1,
          bytes: pngOfSize(50, 50),
        );
        await store.promoteStagedPhoto(eventId: first.eventId, tag: first.tag);
        final firstBytes = await finalFile('e1.jpg').readAsBytes();

        final second = await store.prepareCapturedPhoto(
          eventId: 'e1',
          tag: 2,
          bytes: pngOfSize(200, 100),
        );
        await store.promoteStagedPhoto(
          eventId: second.eventId,
          tag: second.tag,
        );

        final replaced = await finalFile('e1.jpg').readAsBytes();
        expect(replaced, isNot(firstBytes));
        expect(img.decodeJpg(replaced)!.width, 200);
        expect(stagingDir().listSync(), isEmpty);
      },
    );
  });

  group('readManagedPhoto', () {
    test('returns bytes for a managed photo and null when missing', () async {
      final staged = await store.prepareCapturedPhoto(
        eventId: 'e1',
        tag: 1,
        bytes: pngOfSize(20, 20),
      );
      await store.promoteStagedPhoto(eventId: staged.eventId, tag: staged.tag);

      expect(await store.readManagedPhoto('e1.jpg'), isNotNull);
      expect(await store.readManagedPhoto('gone.jpg'), isNull);
    });

    test('returns null for names outside the managed directory', () async {
      expect(await store.readManagedPhoto('../secret.jpg'), isNull);
      expect(await store.readManagedPhoto('a/b.jpg'), isNull);
    });
  });

  group('removeManagedFile', () {
    test(
      'removes idempotently and reports whether the file was there',
      () async {
        final staged = await store.prepareCapturedPhoto(
          eventId: 'e1',
          tag: 1,
          bytes: pngOfSize(20, 20),
        );
        await store.promoteStagedPhoto(
          eventId: staged.eventId,
          tag: staged.tag,
        );

        expect(await store.removeManagedFile('e1.jpg'), isTrue);
        expect(await finalFile('e1.jpg').exists(), isFalse);
        expect(await store.removeManagedFile('e1.jpg'), isFalse);
      },
    );

    test('rejects names outside the managed directory (A.9)', () async {
      await expectLater(
        store.removeManagedFile('../etc.jpg'),
        throwsArgumentError,
      );
    });
  });

  group('inventory and removeAllManagedMedia', () {
    test('lists final files and staged entries; ignores stray junk', () async {
      final promoted = await store.prepareCapturedPhoto(
        eventId: 'kept',
        tag: 5,
        bytes: pngOfSize(10, 10),
      );
      await store.promoteStagedPhoto(
        eventId: promoted.eventId,
        tag: promoted.tag,
      );
      await store.prepareCapturedPhoto(
        eventId: 'pending',
        tag: 9,
        bytes: pngOfSize(10, 10),
      );
      await File('${stagingDir().path}/junk.txt').writeAsString('x');

      final inventory = await store.inventory();

      expect(inventory.finalFileNames, ['kept.jpg']);
      expect(inventory.staged, hasLength(1));
      expect(inventory.staged.single.eventId, 'pending');
      expect(inventory.staged.single.tag, 9);
    });

    test(
      'removeAllManagedMedia clears finals and staged files (Start Over)',
      () async {
        final a = await store.prepareCapturedPhoto(
          eventId: 'a',
          tag: 1,
          bytes: pngOfSize(10, 10),
        );
        await store.promoteStagedPhoto(eventId: a.eventId, tag: a.tag);
        await store.prepareCapturedPhoto(
          eventId: 'b',
          tag: 2,
          bytes: pngOfSize(10, 10),
        );

        await store.removeAllManagedMedia();

        final inventory = await store.inventory();
        expect(inventory.finalFileNames, isEmpty);
        expect(inventory.staged, isEmpty);
      },
    );
  });
}
