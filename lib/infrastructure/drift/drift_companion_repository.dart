import 'dart:convert';

import 'package:drift/drift.dart';

import '../../contracts/companion_repository.dart';
import '../../contracts/id_source.dart';
import '../../domain/model/growth_delta.dart';
import '../../domain/model/growth_event.dart';
import '../../domain/model/mood.dart';
import '../../domain/model/time_category.dart';
import 'companion_database.dart';

/// Drift/SQLite adapter for [CompanionRepository] (ADR 0003).
///
/// The unique (installation_id, local_date) index is the daily-rule
/// guarantee; upserts run in a transaction so competing submissions resolve
/// to one row. All stored values are validated on the way back into the
/// domain — corruption surfaces as [CorruptEventDataException].
class DriftCompanionRepository implements CompanionRepository {
  DriftCompanionRepository({required this.database, required this.idSource});

  final CompanionDatabase database;
  final IdSource idSource;

  static const String _installationKey = 'installation_id';

  @override
  Future<String> installationId() {
    return database.transaction(() async {
      final existing = await (database.select(
        database.appMetadata,
      )..where((t) => t.key.equals(_installationKey))).getSingleOrNull();
      if (existing != null) return existing.value;

      final created = idSource.nextId();
      await database
          .into(database.appMetadata)
          .insert(
            AppMetadataCompanion.insert(key: _installationKey, value: created),
          );
      return created;
    });
  }

  @override
  Future<GrowthEvent> upsertDailyCheckIn(DailyCheckInDraft draft) {
    return database.transaction(() async {
      final installation = await installationId();
      final confirmedAtMs = draft.checkedInAtUtc.millisecondsSinceEpoch;

      final existing =
          await (database.select(database.growthEvents)..where(
                (t) =>
                    t.installationId.equals(installation) &
                    t.localDate.equals(draft.localDate),
              ))
              .getSingleOrNull();

      if (existing == null) {
        final selfieFileName = draft.selfieFileName;
        if (selfieFileName == null) {
          throw ArgumentError.value(
            null,
            'selfieFileName',
            'required when creating the first event for a date',
          );
        }
        final id = draft.proposedEventId ?? idSource.nextId();
        await database
            .into(database.growthEvents)
            .insert(
              GrowthEventsCompanion.insert(
                id: id,
                installationId: installation,
                localDate: draft.localDate,
                checkedInAtUtc: confirmedAtMs,
                timezoneOffsetMinutes: draft.timezoneOffsetMinutes,
                timeCategory: draft.timeCategory.name,
                mood: draft.mood.name,
                selfieFileName: selfieFileName,
                randomSeed: draft.randomSeed,
                algorithmVersion: draft.algorithmVersion,
                growthDelta: _encodeDelta(draft.growthDelta),
                createdAtUtc: confirmedAtMs,
                updatedAtUtc: confirmedAtMs,
              ),
            );
        return _readById(id);
      }

      // Same-day correction (spec §4.5): replace in place, preserving id and
      // created_at_utc; keep the photo reference when no new one was prepared.
      await (database.update(
        database.growthEvents,
      )..where((t) => t.id.equals(existing.id))).write(
        GrowthEventsCompanion(
          checkedInAtUtc: Value(confirmedAtMs),
          timezoneOffsetMinutes: Value(draft.timezoneOffsetMinutes),
          timeCategory: Value(draft.timeCategory.name),
          mood: Value(draft.mood.name),
          selfieFileName: draft.selfieFileName == null
              ? const Value.absent()
              : Value(draft.selfieFileName!),
          randomSeed: Value(draft.randomSeed),
          algorithmVersion: Value(draft.algorithmVersion),
          growthDelta: Value(_encodeDelta(draft.growthDelta)),
          updatedAtUtc: Value(confirmedAtMs),
        ),
      );
      return _readById(existing.id);
    });
  }

  @override
  Future<GrowthEvent?> eventForDate(String localDate) async {
    final installation = await installationId();
    final row =
        await (database.select(database.growthEvents)..where(
              (t) =>
                  t.installationId.equals(installation) &
                  t.localDate.equals(localDate),
            ))
            .getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<List<GrowthEvent>> allEvents() async {
    final installation = await installationId();
    final rows =
        await (database.select(database.growthEvents)
              ..where((t) => t.installationId.equals(installation))
              ..orderBy([
                (t) => OrderingTerm.asc(t.localDate),
                (t) => OrderingTerm.asc(t.checkedInAtUtc),
                (t) => OrderingTerm.asc(t.id),
              ]))
            .get();
    return rows.map(_toDomain).toList();
  }

  @override
  Future<bool> deleteEvent(String id) async {
    final installation = await installationId();
    final deleted =
        await (database.delete(database.growthEvents)..where(
              (t) => t.id.equals(id) & t.installationId.equals(installation),
            ))
            .go();
    return deleted > 0;
  }

  Future<GrowthEvent> _readById(String id) async {
    final row = await (database.select(
      database.growthEvents,
    )..where((t) => t.id.equals(id))).getSingle();
    return _toDomain(row);
  }

  String _encodeDelta(GrowthDelta delta) {
    return jsonEncode({
      'height': delta.heightIncrease,
      'branches': delta.branchIncrease,
      'leaves': delta.leafIncrease,
      'decorations': delta.decorationIncrease,
      'spread': delta.spreadFactor,
      'vertical': delta.prefersVertical,
      'spiral': delta.prefersSpiral,
      'palette': delta.paletteId,
      'morphology': delta.morphologyId,
    });
  }

  GrowthEvent _toDomain(GrowthEventRow row) {
    final timeCategory = TimeCategory.values.asNameMap()[row.timeCategory];
    if (timeCategory == null) {
      throw CorruptEventDataException(
        eventId: row.id,
        field: 'time_category',
        detail: 'unknown value "${row.timeCategory}"',
      );
    }
    final mood = Mood.values.asNameMap()[row.mood];
    if (mood == null) {
      throw CorruptEventDataException(
        eventId: row.id,
        field: 'mood',
        detail: 'unknown value "${row.mood}"',
      );
    }

    return GrowthEvent(
      id: row.id,
      installationId: row.installationId,
      localDate: row.localDate,
      checkedInAtUtc: DateTime.fromMillisecondsSinceEpoch(
        row.checkedInAtUtc,
        isUtc: true,
      ),
      timezoneOffsetMinutes: row.timezoneOffsetMinutes,
      timeCategory: timeCategory,
      mood: mood,
      selfieFileName: row.selfieFileName,
      randomSeed: row.randomSeed,
      algorithmVersion: row.algorithmVersion,
      growthDelta: _decodeDelta(row.growthDelta, row.id),
      createdAtUtc: DateTime.fromMillisecondsSinceEpoch(
        row.createdAtUtc,
        isUtc: true,
      ),
      updatedAtUtc: DateTime.fromMillisecondsSinceEpoch(
        row.updatedAtUtc,
        isUtc: true,
      ),
    );
  }

  GrowthDelta _decodeDelta(String raw, String eventId) {
    Never corrupt(String detail) {
      throw CorruptEventDataException(
        eventId: eventId,
        field: 'growth_delta',
        detail: detail,
      );
    }

    final Object? parsed;
    try {
      parsed = jsonDecode(raw);
    } on FormatException catch (e) {
      corrupt('invalid JSON: ${e.message}');
    }
    if (parsed is! Map<String, Object?>) {
      corrupt('expected a JSON object');
    }
    final Map<String, Object?> decoded = parsed;

    int intField(String key) {
      final value = decoded[key];
      if (value is! int) corrupt('"$key" must be an integer');
      return value;
    }

    bool boolField(String key) {
      final value = decoded[key];
      if (value is! bool) corrupt('"$key" must be a boolean');
      return value;
    }

    String stringField(String key) {
      final value = decoded[key];
      if (value is! String) corrupt('"$key" must be a string');
      return value;
    }

    final spread = decoded['spread'];
    if (spread is! num) corrupt('"spread" must be a number');

    return GrowthDelta(
      heightIncrease: intField('height'),
      branchIncrease: intField('branches'),
      leafIncrease: intField('leaves'),
      decorationIncrease: intField('decorations'),
      spreadFactor: spread.toDouble(),
      prefersVertical: boolField('vertical'),
      prefersSpiral: boolField('spiral'),
      paletteId: stringField('palette'),
      morphologyId: stringField('morphology'),
    );
  }
}
