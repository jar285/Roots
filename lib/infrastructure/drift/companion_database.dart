import 'package:drift/drift.dart';

part 'companion_database.g.dart';

/// Canonical event rows (spec A.8). Timestamps are UTC milliseconds since
/// epoch; enums are text names; growth_delta is strict JSON — all mapping and
/// validation lives in the repository (ADR 0003).
@DataClassName('GrowthEventRow')
class GrowthEvents extends Table {
  TextColumn get id => text()();
  TextColumn get installationId => text()();
  TextColumn get localDate => text()();
  IntColumn get checkedInAtUtc => integer()();
  IntColumn get timezoneOffsetMinutes => integer()();
  TextColumn get timeCategory => text()();
  TextColumn get mood => text()();
  TextColumn get selfieFileName => text()();
  IntColumn get randomSeed => integer()();
  IntColumn get algorithmVersion => integer()();
  TextColumn get growthDelta => text()();
  IntColumn get createdAtUtc => integer()();
  IntColumn get updatedAtUtc => integer()();

  @override
  Set<Column> get primaryKey => {id};

  /// The daily rule lives here, below every interface (spec §3 guarantee 3).
  @override
  List<Set<Column>> get uniqueKeys => [
    {installationId, localDate},
  ];
}

/// Installation id and application metadata as key/value rows (spec A.8).
/// Never a second copy of plant state.
@DataClassName('AppMetadataRow')
class AppMetadata extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [GrowthEvents, AppMetadata])
class CompanionDatabase extends _$CompanionDatabase {
  CompanionDatabase(super.e);

  @override
  int get schemaVersion => 1;
}
