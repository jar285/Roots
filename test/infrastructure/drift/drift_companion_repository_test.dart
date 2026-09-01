import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:roots/contracts/companion_repository.dart';
import 'package:roots/contracts/id_source.dart';
import 'package:roots/domain/model/growth_delta.dart';
import 'package:roots/domain/model/mood.dart';
import 'package:roots/domain/model/time_category.dart';
import 'package:roots/infrastructure/drift/companion_database.dart';
import 'package:roots/infrastructure/drift/drift_companion_repository.dart';

import '../../contracts/companion_repository_contract.dart';

/// Deterministic ids for tests: id-1, id-2, ...
class SequentialIdSource implements IdSource {
  int _next = 0;

  @override
  String nextId() => 'id-${++_next}';
}

DailyCheckInDraft draft({String localDate = '2026-09-01'}) {
  return DailyCheckInDraft(
    localDate: localDate,
    checkedInAtUtc: DateTime.utc(2026, 9, 1, 14, 5),
    timezoneOffsetMinutes: -240,
    timeCategory: TimeCategory.afternoon,
    mood: Mood.calm,
    selfieFileName: 'photo.jpg',
    randomSeed: 7,
    algorithmVersion: 1,
    growthDelta: const GrowthDelta(
      heightIncrease: 10,
      branchIncrease: 1,
      leafIncrease: 3,
      decorationIncrease: 0,
      spreadFactor: 0.3,
      prefersVertical: false,
      prefersSpiral: false,
      paletteId: 'v1.calm',
      morphologyId: 'v1.compact',
    ),
  );
}

void main() {
  group('DriftCompanionRepository satisfies the repository contract', () {
    final openDatabases = <DriftCompanionRepository, CompanionDatabase>{};

    runCompanionRepositoryContractTests(
      create: () async {
        final db = CompanionDatabase(NativeDatabase.memory());
        final repository = DriftCompanionRepository(
          database: db,
          idSource: SequentialIdSource(),
        );
        openDatabases[repository] = db;
        return repository;
      },
      dispose: (repository) async {
        await openDatabases.remove(repository)?.close();
      },
    );
  });

  group('SQLite-level guarantees', () {
    late CompanionDatabase db;
    late DriftCompanionRepository repository;

    setUp(() {
      db = CompanionDatabase(NativeDatabase.memory());
      repository = DriftCompanionRepository(
        database: db,
        idSource: SequentialIdSource(),
      );
    });

    tearDown(() async {
      await db.close();
    });

    GrowthEventsCompanion rawRow({
      required String id,
      required String installationId,
      required String localDate,
    }) {
      return GrowthEventsCompanion.insert(
        id: id,
        installationId: installationId,
        localDate: localDate,
        checkedInAtUtc: 1000,
        timezoneOffsetMinutes: 0,
        timeCategory: 'afternoon',
        mood: 'calm',
        selfieFileName: 'x.jpg',
        randomSeed: 1,
        algorithmVersion: 1,
        growthDelta:
            '{"height":10,"branches":1,"leaves":3,"decorations":0,'
            '"spread":0.3,"vertical":false,"spiral":false,'
            '"palette":"v1.calm","morphology":"v1.compact"}',
        createdAtUtc: 1000,
        updatedAtUtc: 1000,
      );
    }

    test('the unique (installation_id, local_date) index rejects a duplicate '
        'even when the repository is bypassed', () async {
      await db
          .into(db.growthEvents)
          .insert(
            rawRow(id: 'a', installationId: 'i-1', localDate: '2026-09-01'),
          );

      await expectLater(
        db
            .into(db.growthEvents)
            .insert(
              rawRow(id: 'b', installationId: 'i-1', localDate: '2026-09-01'),
            ),
        throwsA(
          predicate((e) => e.toString().toUpperCase().contains('UNIQUE')),
        ),
      );
    });

    test(
      'the same local date under a different installation is allowed',
      () async {
        await db
            .into(db.growthEvents)
            .insert(
              rawRow(id: 'a', installationId: 'i-1', localDate: '2026-09-01'),
            );
        await db
            .into(db.growthEvents)
            .insert(
              rawRow(id: 'b', installationId: 'i-2', localDate: '2026-09-01'),
            );

        expect(await db.select(db.growthEvents).get(), hasLength(2));
      },
    );

    test(
      'a corrupt mood value surfaces as CorruptEventDataException',
      () async {
        final saved = await repository.upsertDailyCheckIn(draft());
        await db.customStatement(
          'UPDATE growth_events SET mood = ? WHERE id = ?',
          ['not-a-mood', saved.id],
        );

        await expectLater(
          repository.allEvents(),
          throwsA(
            isA<CorruptEventDataException>()
                .having((e) => e.eventId, 'eventId', saved.id)
                .having((e) => e.field, 'field', 'mood'),
          ),
        );
      },
    );

    test(
      'corrupt growth_delta JSON surfaces as CorruptEventDataException',
      () async {
        final saved = await repository.upsertDailyCheckIn(draft());
        await db.customStatement(
          'UPDATE growth_events SET growth_delta = ? WHERE id = ?',
          ['{"height": "tall"}', saved.id],
        );

        await expectLater(
          repository.eventForDate('2026-09-01'),
          throwsA(
            isA<CorruptEventDataException>()
                .having((e) => e.eventId, 'eventId', saved.id)
                .having((e) => e.field, 'field', 'growth_delta'),
          ),
        );
      },
    );
  });

  group('durability across reopen', () {
    test('installation id and events survive a database restart', () async {
      final dir = await Directory.systemTemp.createTemp('roots-drift-test');
      final file = File('${dir.path}/plant_selfie.sqlite');
      addTearDown(() async {
        if (await dir.exists()) {
          await dir.delete(recursive: true);
        }
      });

      final db1 = CompanionDatabase(NativeDatabase(file));
      final repo1 = DriftCompanionRepository(
        database: db1,
        idSource: SequentialIdSource(),
      );
      final installation = await repo1.installationId();
      final saved = await repo1.upsertDailyCheckIn(draft());
      await db1.close();

      final db2 = CompanionDatabase(NativeDatabase(file));
      final repo2 = DriftCompanionRepository(
        database: db2,
        idSource: SequentialIdSource(),
      );
      addTearDown(db2.close);

      expect(await repo2.installationId(), installation);
      expect(await repo2.allEvents(), [saved]);
    });
  });
}
