// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'companion_database.dart';

// ignore_for_file: type=lint
class $GrowthEventsTable extends GrowthEvents
    with TableInfo<$GrowthEventsTable, GrowthEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GrowthEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _installationIdMeta = const VerificationMeta(
    'installationId',
  );
  @override
  late final GeneratedColumn<String> installationId = GeneratedColumn<String>(
    'installation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localDateMeta = const VerificationMeta(
    'localDate',
  );
  @override
  late final GeneratedColumn<String> localDate = GeneratedColumn<String>(
    'local_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _checkedInAtUtcMeta = const VerificationMeta(
    'checkedInAtUtc',
  );
  @override
  late final GeneratedColumn<int> checkedInAtUtc = GeneratedColumn<int>(
    'checked_in_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timezoneOffsetMinutesMeta =
      const VerificationMeta('timezoneOffsetMinutes');
  @override
  late final GeneratedColumn<int> timezoneOffsetMinutes = GeneratedColumn<int>(
    'timezone_offset_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeCategoryMeta = const VerificationMeta(
    'timeCategory',
  );
  @override
  late final GeneratedColumn<String> timeCategory = GeneratedColumn<String>(
    'time_category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _moodMeta = const VerificationMeta('mood');
  @override
  late final GeneratedColumn<String> mood = GeneratedColumn<String>(
    'mood',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _selfieFileNameMeta = const VerificationMeta(
    'selfieFileName',
  );
  @override
  late final GeneratedColumn<String> selfieFileName = GeneratedColumn<String>(
    'selfie_file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _randomSeedMeta = const VerificationMeta(
    'randomSeed',
  );
  @override
  late final GeneratedColumn<int> randomSeed = GeneratedColumn<int>(
    'random_seed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _algorithmVersionMeta = const VerificationMeta(
    'algorithmVersion',
  );
  @override
  late final GeneratedColumn<int> algorithmVersion = GeneratedColumn<int>(
    'algorithm_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _growthDeltaMeta = const VerificationMeta(
    'growthDelta',
  );
  @override
  late final GeneratedColumn<String> growthDelta = GeneratedColumn<String>(
    'growth_delta',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<int> createdAtUtc = GeneratedColumn<int>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcMeta = const VerificationMeta(
    'updatedAtUtc',
  );
  @override
  late final GeneratedColumn<int> updatedAtUtc = GeneratedColumn<int>(
    'updated_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    installationId,
    localDate,
    checkedInAtUtc,
    timezoneOffsetMinutes,
    timeCategory,
    mood,
    selfieFileName,
    randomSeed,
    algorithmVersion,
    growthDelta,
    createdAtUtc,
    updatedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'growth_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<GrowthEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('installation_id')) {
      context.handle(
        _installationIdMeta,
        installationId.isAcceptableOrUnknown(
          data['installation_id']!,
          _installationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_installationIdMeta);
    }
    if (data.containsKey('local_date')) {
      context.handle(
        _localDateMeta,
        localDate.isAcceptableOrUnknown(data['local_date']!, _localDateMeta),
      );
    } else if (isInserting) {
      context.missing(_localDateMeta);
    }
    if (data.containsKey('checked_in_at_utc')) {
      context.handle(
        _checkedInAtUtcMeta,
        checkedInAtUtc.isAcceptableOrUnknown(
          data['checked_in_at_utc']!,
          _checkedInAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_checkedInAtUtcMeta);
    }
    if (data.containsKey('timezone_offset_minutes')) {
      context.handle(
        _timezoneOffsetMinutesMeta,
        timezoneOffsetMinutes.isAcceptableOrUnknown(
          data['timezone_offset_minutes']!,
          _timezoneOffsetMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timezoneOffsetMinutesMeta);
    }
    if (data.containsKey('time_category')) {
      context.handle(
        _timeCategoryMeta,
        timeCategory.isAcceptableOrUnknown(
          data['time_category']!,
          _timeCategoryMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timeCategoryMeta);
    }
    if (data.containsKey('mood')) {
      context.handle(
        _moodMeta,
        mood.isAcceptableOrUnknown(data['mood']!, _moodMeta),
      );
    } else if (isInserting) {
      context.missing(_moodMeta);
    }
    if (data.containsKey('selfie_file_name')) {
      context.handle(
        _selfieFileNameMeta,
        selfieFileName.isAcceptableOrUnknown(
          data['selfie_file_name']!,
          _selfieFileNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_selfieFileNameMeta);
    }
    if (data.containsKey('random_seed')) {
      context.handle(
        _randomSeedMeta,
        randomSeed.isAcceptableOrUnknown(data['random_seed']!, _randomSeedMeta),
      );
    } else if (isInserting) {
      context.missing(_randomSeedMeta);
    }
    if (data.containsKey('algorithm_version')) {
      context.handle(
        _algorithmVersionMeta,
        algorithmVersion.isAcceptableOrUnknown(
          data['algorithm_version']!,
          _algorithmVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_algorithmVersionMeta);
    }
    if (data.containsKey('growth_delta')) {
      context.handle(
        _growthDeltaMeta,
        growthDelta.isAcceptableOrUnknown(
          data['growth_delta']!,
          _growthDeltaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_growthDeltaMeta);
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    if (data.containsKey('updated_at_utc')) {
      context.handle(
        _updatedAtUtcMeta,
        updatedAtUtc.isAcceptableOrUnknown(
          data['updated_at_utc']!,
          _updatedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {installationId, localDate},
  ];
  @override
  GrowthEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GrowthEventRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      installationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}installation_id'],
      )!,
      localDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_date'],
      )!,
      checkedInAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}checked_in_at_utc'],
      )!,
      timezoneOffsetMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timezone_offset_minutes'],
      )!,
      timeCategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time_category'],
      )!,
      mood: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mood'],
      )!,
      selfieFileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}selfie_file_name'],
      )!,
      randomSeed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}random_seed'],
      )!,
      algorithmVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}algorithm_version'],
      )!,
      growthDelta: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}growth_delta'],
      )!,
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_utc'],
      )!,
      updatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_utc'],
      )!,
    );
  }

  @override
  $GrowthEventsTable createAlias(String alias) {
    return $GrowthEventsTable(attachedDatabase, alias);
  }
}

class GrowthEventRow extends DataClass implements Insertable<GrowthEventRow> {
  final String id;
  final String installationId;
  final String localDate;
  final int checkedInAtUtc;
  final int timezoneOffsetMinutes;
  final String timeCategory;
  final String mood;
  final String selfieFileName;
  final int randomSeed;
  final int algorithmVersion;
  final String growthDelta;
  final int createdAtUtc;
  final int updatedAtUtc;
  const GrowthEventRow({
    required this.id,
    required this.installationId,
    required this.localDate,
    required this.checkedInAtUtc,
    required this.timezoneOffsetMinutes,
    required this.timeCategory,
    required this.mood,
    required this.selfieFileName,
    required this.randomSeed,
    required this.algorithmVersion,
    required this.growthDelta,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['installation_id'] = Variable<String>(installationId);
    map['local_date'] = Variable<String>(localDate);
    map['checked_in_at_utc'] = Variable<int>(checkedInAtUtc);
    map['timezone_offset_minutes'] = Variable<int>(timezoneOffsetMinutes);
    map['time_category'] = Variable<String>(timeCategory);
    map['mood'] = Variable<String>(mood);
    map['selfie_file_name'] = Variable<String>(selfieFileName);
    map['random_seed'] = Variable<int>(randomSeed);
    map['algorithm_version'] = Variable<int>(algorithmVersion);
    map['growth_delta'] = Variable<String>(growthDelta);
    map['created_at_utc'] = Variable<int>(createdAtUtc);
    map['updated_at_utc'] = Variable<int>(updatedAtUtc);
    return map;
  }

  GrowthEventsCompanion toCompanion(bool nullToAbsent) {
    return GrowthEventsCompanion(
      id: Value(id),
      installationId: Value(installationId),
      localDate: Value(localDate),
      checkedInAtUtc: Value(checkedInAtUtc),
      timezoneOffsetMinutes: Value(timezoneOffsetMinutes),
      timeCategory: Value(timeCategory),
      mood: Value(mood),
      selfieFileName: Value(selfieFileName),
      randomSeed: Value(randomSeed),
      algorithmVersion: Value(algorithmVersion),
      growthDelta: Value(growthDelta),
      createdAtUtc: Value(createdAtUtc),
      updatedAtUtc: Value(updatedAtUtc),
    );
  }

  factory GrowthEventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GrowthEventRow(
      id: serializer.fromJson<String>(json['id']),
      installationId: serializer.fromJson<String>(json['installationId']),
      localDate: serializer.fromJson<String>(json['localDate']),
      checkedInAtUtc: serializer.fromJson<int>(json['checkedInAtUtc']),
      timezoneOffsetMinutes: serializer.fromJson<int>(
        json['timezoneOffsetMinutes'],
      ),
      timeCategory: serializer.fromJson<String>(json['timeCategory']),
      mood: serializer.fromJson<String>(json['mood']),
      selfieFileName: serializer.fromJson<String>(json['selfieFileName']),
      randomSeed: serializer.fromJson<int>(json['randomSeed']),
      algorithmVersion: serializer.fromJson<int>(json['algorithmVersion']),
      growthDelta: serializer.fromJson<String>(json['growthDelta']),
      createdAtUtc: serializer.fromJson<int>(json['createdAtUtc']),
      updatedAtUtc: serializer.fromJson<int>(json['updatedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'installationId': serializer.toJson<String>(installationId),
      'localDate': serializer.toJson<String>(localDate),
      'checkedInAtUtc': serializer.toJson<int>(checkedInAtUtc),
      'timezoneOffsetMinutes': serializer.toJson<int>(timezoneOffsetMinutes),
      'timeCategory': serializer.toJson<String>(timeCategory),
      'mood': serializer.toJson<String>(mood),
      'selfieFileName': serializer.toJson<String>(selfieFileName),
      'randomSeed': serializer.toJson<int>(randomSeed),
      'algorithmVersion': serializer.toJson<int>(algorithmVersion),
      'growthDelta': serializer.toJson<String>(growthDelta),
      'createdAtUtc': serializer.toJson<int>(createdAtUtc),
      'updatedAtUtc': serializer.toJson<int>(updatedAtUtc),
    };
  }

  GrowthEventRow copyWith({
    String? id,
    String? installationId,
    String? localDate,
    int? checkedInAtUtc,
    int? timezoneOffsetMinutes,
    String? timeCategory,
    String? mood,
    String? selfieFileName,
    int? randomSeed,
    int? algorithmVersion,
    String? growthDelta,
    int? createdAtUtc,
    int? updatedAtUtc,
  }) => GrowthEventRow(
    id: id ?? this.id,
    installationId: installationId ?? this.installationId,
    localDate: localDate ?? this.localDate,
    checkedInAtUtc: checkedInAtUtc ?? this.checkedInAtUtc,
    timezoneOffsetMinutes: timezoneOffsetMinutes ?? this.timezoneOffsetMinutes,
    timeCategory: timeCategory ?? this.timeCategory,
    mood: mood ?? this.mood,
    selfieFileName: selfieFileName ?? this.selfieFileName,
    randomSeed: randomSeed ?? this.randomSeed,
    algorithmVersion: algorithmVersion ?? this.algorithmVersion,
    growthDelta: growthDelta ?? this.growthDelta,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
  );
  GrowthEventRow copyWithCompanion(GrowthEventsCompanion data) {
    return GrowthEventRow(
      id: data.id.present ? data.id.value : this.id,
      installationId: data.installationId.present
          ? data.installationId.value
          : this.installationId,
      localDate: data.localDate.present ? data.localDate.value : this.localDate,
      checkedInAtUtc: data.checkedInAtUtc.present
          ? data.checkedInAtUtc.value
          : this.checkedInAtUtc,
      timezoneOffsetMinutes: data.timezoneOffsetMinutes.present
          ? data.timezoneOffsetMinutes.value
          : this.timezoneOffsetMinutes,
      timeCategory: data.timeCategory.present
          ? data.timeCategory.value
          : this.timeCategory,
      mood: data.mood.present ? data.mood.value : this.mood,
      selfieFileName: data.selfieFileName.present
          ? data.selfieFileName.value
          : this.selfieFileName,
      randomSeed: data.randomSeed.present
          ? data.randomSeed.value
          : this.randomSeed,
      algorithmVersion: data.algorithmVersion.present
          ? data.algorithmVersion.value
          : this.algorithmVersion,
      growthDelta: data.growthDelta.present
          ? data.growthDelta.value
          : this.growthDelta,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GrowthEventRow(')
          ..write('id: $id, ')
          ..write('installationId: $installationId, ')
          ..write('localDate: $localDate, ')
          ..write('checkedInAtUtc: $checkedInAtUtc, ')
          ..write('timezoneOffsetMinutes: $timezoneOffsetMinutes, ')
          ..write('timeCategory: $timeCategory, ')
          ..write('mood: $mood, ')
          ..write('selfieFileName: $selfieFileName, ')
          ..write('randomSeed: $randomSeed, ')
          ..write('algorithmVersion: $algorithmVersion, ')
          ..write('growthDelta: $growthDelta, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    installationId,
    localDate,
    checkedInAtUtc,
    timezoneOffsetMinutes,
    timeCategory,
    mood,
    selfieFileName,
    randomSeed,
    algorithmVersion,
    growthDelta,
    createdAtUtc,
    updatedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GrowthEventRow &&
          other.id == this.id &&
          other.installationId == this.installationId &&
          other.localDate == this.localDate &&
          other.checkedInAtUtc == this.checkedInAtUtc &&
          other.timezoneOffsetMinutes == this.timezoneOffsetMinutes &&
          other.timeCategory == this.timeCategory &&
          other.mood == this.mood &&
          other.selfieFileName == this.selfieFileName &&
          other.randomSeed == this.randomSeed &&
          other.algorithmVersion == this.algorithmVersion &&
          other.growthDelta == this.growthDelta &&
          other.createdAtUtc == this.createdAtUtc &&
          other.updatedAtUtc == this.updatedAtUtc);
}

class GrowthEventsCompanion extends UpdateCompanion<GrowthEventRow> {
  final Value<String> id;
  final Value<String> installationId;
  final Value<String> localDate;
  final Value<int> checkedInAtUtc;
  final Value<int> timezoneOffsetMinutes;
  final Value<String> timeCategory;
  final Value<String> mood;
  final Value<String> selfieFileName;
  final Value<int> randomSeed;
  final Value<int> algorithmVersion;
  final Value<String> growthDelta;
  final Value<int> createdAtUtc;
  final Value<int> updatedAtUtc;
  final Value<int> rowid;
  const GrowthEventsCompanion({
    this.id = const Value.absent(),
    this.installationId = const Value.absent(),
    this.localDate = const Value.absent(),
    this.checkedInAtUtc = const Value.absent(),
    this.timezoneOffsetMinutes = const Value.absent(),
    this.timeCategory = const Value.absent(),
    this.mood = const Value.absent(),
    this.selfieFileName = const Value.absent(),
    this.randomSeed = const Value.absent(),
    this.algorithmVersion = const Value.absent(),
    this.growthDelta = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GrowthEventsCompanion.insert({
    required String id,
    required String installationId,
    required String localDate,
    required int checkedInAtUtc,
    required int timezoneOffsetMinutes,
    required String timeCategory,
    required String mood,
    required String selfieFileName,
    required int randomSeed,
    required int algorithmVersion,
    required String growthDelta,
    required int createdAtUtc,
    required int updatedAtUtc,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       installationId = Value(installationId),
       localDate = Value(localDate),
       checkedInAtUtc = Value(checkedInAtUtc),
       timezoneOffsetMinutes = Value(timezoneOffsetMinutes),
       timeCategory = Value(timeCategory),
       mood = Value(mood),
       selfieFileName = Value(selfieFileName),
       randomSeed = Value(randomSeed),
       algorithmVersion = Value(algorithmVersion),
       growthDelta = Value(growthDelta),
       createdAtUtc = Value(createdAtUtc),
       updatedAtUtc = Value(updatedAtUtc);
  static Insertable<GrowthEventRow> custom({
    Expression<String>? id,
    Expression<String>? installationId,
    Expression<String>? localDate,
    Expression<int>? checkedInAtUtc,
    Expression<int>? timezoneOffsetMinutes,
    Expression<String>? timeCategory,
    Expression<String>? mood,
    Expression<String>? selfieFileName,
    Expression<int>? randomSeed,
    Expression<int>? algorithmVersion,
    Expression<String>? growthDelta,
    Expression<int>? createdAtUtc,
    Expression<int>? updatedAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (installationId != null) 'installation_id': installationId,
      if (localDate != null) 'local_date': localDate,
      if (checkedInAtUtc != null) 'checked_in_at_utc': checkedInAtUtc,
      if (timezoneOffsetMinutes != null)
        'timezone_offset_minutes': timezoneOffsetMinutes,
      if (timeCategory != null) 'time_category': timeCategory,
      if (mood != null) 'mood': mood,
      if (selfieFileName != null) 'selfie_file_name': selfieFileName,
      if (randomSeed != null) 'random_seed': randomSeed,
      if (algorithmVersion != null) 'algorithm_version': algorithmVersion,
      if (growthDelta != null) 'growth_delta': growthDelta,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GrowthEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? installationId,
    Value<String>? localDate,
    Value<int>? checkedInAtUtc,
    Value<int>? timezoneOffsetMinutes,
    Value<String>? timeCategory,
    Value<String>? mood,
    Value<String>? selfieFileName,
    Value<int>? randomSeed,
    Value<int>? algorithmVersion,
    Value<String>? growthDelta,
    Value<int>? createdAtUtc,
    Value<int>? updatedAtUtc,
    Value<int>? rowid,
  }) {
    return GrowthEventsCompanion(
      id: id ?? this.id,
      installationId: installationId ?? this.installationId,
      localDate: localDate ?? this.localDate,
      checkedInAtUtc: checkedInAtUtc ?? this.checkedInAtUtc,
      timezoneOffsetMinutes:
          timezoneOffsetMinutes ?? this.timezoneOffsetMinutes,
      timeCategory: timeCategory ?? this.timeCategory,
      mood: mood ?? this.mood,
      selfieFileName: selfieFileName ?? this.selfieFileName,
      randomSeed: randomSeed ?? this.randomSeed,
      algorithmVersion: algorithmVersion ?? this.algorithmVersion,
      growthDelta: growthDelta ?? this.growthDelta,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (installationId.present) {
      map['installation_id'] = Variable<String>(installationId.value);
    }
    if (localDate.present) {
      map['local_date'] = Variable<String>(localDate.value);
    }
    if (checkedInAtUtc.present) {
      map['checked_in_at_utc'] = Variable<int>(checkedInAtUtc.value);
    }
    if (timezoneOffsetMinutes.present) {
      map['timezone_offset_minutes'] = Variable<int>(
        timezoneOffsetMinutes.value,
      );
    }
    if (timeCategory.present) {
      map['time_category'] = Variable<String>(timeCategory.value);
    }
    if (mood.present) {
      map['mood'] = Variable<String>(mood.value);
    }
    if (selfieFileName.present) {
      map['selfie_file_name'] = Variable<String>(selfieFileName.value);
    }
    if (randomSeed.present) {
      map['random_seed'] = Variable<int>(randomSeed.value);
    }
    if (algorithmVersion.present) {
      map['algorithm_version'] = Variable<int>(algorithmVersion.value);
    }
    if (growthDelta.present) {
      map['growth_delta'] = Variable<String>(growthDelta.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<int>(createdAtUtc.value);
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<int>(updatedAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GrowthEventsCompanion(')
          ..write('id: $id, ')
          ..write('installationId: $installationId, ')
          ..write('localDate: $localDate, ')
          ..write('checkedInAtUtc: $checkedInAtUtc, ')
          ..write('timezoneOffsetMinutes: $timezoneOffsetMinutes, ')
          ..write('timeCategory: $timeCategory, ')
          ..write('mood: $mood, ')
          ..write('selfieFileName: $selfieFileName, ')
          ..write('randomSeed: $randomSeed, ')
          ..write('algorithmVersion: $algorithmVersion, ')
          ..write('growthDelta: $growthDelta, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppMetadataTable extends AppMetadata
    with TableInfo<$AppMetadataTable, AppMetadataRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppMetadataRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppMetadataRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppMetadataRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppMetadataTable createAlias(String alias) {
    return $AppMetadataTable(attachedDatabase, alias);
  }
}

class AppMetadataRow extends DataClass implements Insertable<AppMetadataRow> {
  final String key;
  final String value;
  const AppMetadataRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppMetadataCompanion toCompanion(bool nullToAbsent) {
    return AppMetadataCompanion(key: Value(key), value: Value(value));
  }

  factory AppMetadataRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppMetadataRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppMetadataRow copyWith({String? key, String? value}) =>
      AppMetadataRow(key: key ?? this.key, value: value ?? this.value);
  AppMetadataRow copyWithCompanion(AppMetadataCompanion data) {
    return AppMetadataRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppMetadataRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppMetadataRow &&
          other.key == this.key &&
          other.value == this.value);
}

class AppMetadataCompanion extends UpdateCompanion<AppMetadataRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppMetadataCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppMetadataCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppMetadataRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppMetadataCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppMetadataCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppMetadataCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$CompanionDatabase extends GeneratedDatabase {
  _$CompanionDatabase(QueryExecutor e) : super(e);
  $CompanionDatabaseManager get managers => $CompanionDatabaseManager(this);
  late final $GrowthEventsTable growthEvents = $GrowthEventsTable(this);
  late final $AppMetadataTable appMetadata = $AppMetadataTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    growthEvents,
    appMetadata,
  ];
}

typedef $$GrowthEventsTableCreateCompanionBuilder =
    GrowthEventsCompanion Function({
      required String id,
      required String installationId,
      required String localDate,
      required int checkedInAtUtc,
      required int timezoneOffsetMinutes,
      required String timeCategory,
      required String mood,
      required String selfieFileName,
      required int randomSeed,
      required int algorithmVersion,
      required String growthDelta,
      required int createdAtUtc,
      required int updatedAtUtc,
      Value<int> rowid,
    });
typedef $$GrowthEventsTableUpdateCompanionBuilder =
    GrowthEventsCompanion Function({
      Value<String> id,
      Value<String> installationId,
      Value<String> localDate,
      Value<int> checkedInAtUtc,
      Value<int> timezoneOffsetMinutes,
      Value<String> timeCategory,
      Value<String> mood,
      Value<String> selfieFileName,
      Value<int> randomSeed,
      Value<int> algorithmVersion,
      Value<String> growthDelta,
      Value<int> createdAtUtc,
      Value<int> updatedAtUtc,
      Value<int> rowid,
    });

class $$GrowthEventsTableFilterComposer
    extends Composer<_$CompanionDatabase, $GrowthEventsTable> {
  $$GrowthEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get installationId => $composableBuilder(
    column: $table.installationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get checkedInAtUtc => $composableBuilder(
    column: $table.checkedInAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timezoneOffsetMinutes => $composableBuilder(
    column: $table.timezoneOffsetMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timeCategory => $composableBuilder(
    column: $table.timeCategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get selfieFileName => $composableBuilder(
    column: $table.selfieFileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get randomSeed => $composableBuilder(
    column: $table.randomSeed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get algorithmVersion => $composableBuilder(
    column: $table.algorithmVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get growthDelta => $composableBuilder(
    column: $table.growthDelta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GrowthEventsTableOrderingComposer
    extends Composer<_$CompanionDatabase, $GrowthEventsTable> {
  $$GrowthEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get installationId => $composableBuilder(
    column: $table.installationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get checkedInAtUtc => $composableBuilder(
    column: $table.checkedInAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timezoneOffsetMinutes => $composableBuilder(
    column: $table.timezoneOffsetMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeCategory => $composableBuilder(
    column: $table.timeCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get selfieFileName => $composableBuilder(
    column: $table.selfieFileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get randomSeed => $composableBuilder(
    column: $table.randomSeed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get algorithmVersion => $composableBuilder(
    column: $table.algorithmVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get growthDelta => $composableBuilder(
    column: $table.growthDelta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GrowthEventsTableAnnotationComposer
    extends Composer<_$CompanionDatabase, $GrowthEventsTable> {
  $$GrowthEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get installationId => $composableBuilder(
    column: $table.installationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => column);

  GeneratedColumn<int> get checkedInAtUtc => $composableBuilder(
    column: $table.checkedInAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timezoneOffsetMinutes => $composableBuilder(
    column: $table.timezoneOffsetMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get timeCategory => $composableBuilder(
    column: $table.timeCategory,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mood =>
      $composableBuilder(column: $table.mood, builder: (column) => column);

  GeneratedColumn<String> get selfieFileName => $composableBuilder(
    column: $table.selfieFileName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get randomSeed => $composableBuilder(
    column: $table.randomSeed,
    builder: (column) => column,
  );

  GeneratedColumn<int> get algorithmVersion => $composableBuilder(
    column: $table.algorithmVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get growthDelta => $composableBuilder(
    column: $table.growthDelta,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => column,
  );
}

class $$GrowthEventsTableTableManager
    extends
        RootTableManager<
          _$CompanionDatabase,
          $GrowthEventsTable,
          GrowthEventRow,
          $$GrowthEventsTableFilterComposer,
          $$GrowthEventsTableOrderingComposer,
          $$GrowthEventsTableAnnotationComposer,
          $$GrowthEventsTableCreateCompanionBuilder,
          $$GrowthEventsTableUpdateCompanionBuilder,
          (
            GrowthEventRow,
            BaseReferences<
              _$CompanionDatabase,
              $GrowthEventsTable,
              GrowthEventRow
            >,
          ),
          GrowthEventRow,
          PrefetchHooks Function()
        > {
  $$GrowthEventsTableTableManager(
    _$CompanionDatabase db,
    $GrowthEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GrowthEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GrowthEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GrowthEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> installationId = const Value.absent(),
                Value<String> localDate = const Value.absent(),
                Value<int> checkedInAtUtc = const Value.absent(),
                Value<int> timezoneOffsetMinutes = const Value.absent(),
                Value<String> timeCategory = const Value.absent(),
                Value<String> mood = const Value.absent(),
                Value<String> selfieFileName = const Value.absent(),
                Value<int> randomSeed = const Value.absent(),
                Value<int> algorithmVersion = const Value.absent(),
                Value<String> growthDelta = const Value.absent(),
                Value<int> createdAtUtc = const Value.absent(),
                Value<int> updatedAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GrowthEventsCompanion(
                id: id,
                installationId: installationId,
                localDate: localDate,
                checkedInAtUtc: checkedInAtUtc,
                timezoneOffsetMinutes: timezoneOffsetMinutes,
                timeCategory: timeCategory,
                mood: mood,
                selfieFileName: selfieFileName,
                randomSeed: randomSeed,
                algorithmVersion: algorithmVersion,
                growthDelta: growthDelta,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String installationId,
                required String localDate,
                required int checkedInAtUtc,
                required int timezoneOffsetMinutes,
                required String timeCategory,
                required String mood,
                required String selfieFileName,
                required int randomSeed,
                required int algorithmVersion,
                required String growthDelta,
                required int createdAtUtc,
                required int updatedAtUtc,
                Value<int> rowid = const Value.absent(),
              }) => GrowthEventsCompanion.insert(
                id: id,
                installationId: installationId,
                localDate: localDate,
                checkedInAtUtc: checkedInAtUtc,
                timezoneOffsetMinutes: timezoneOffsetMinutes,
                timeCategory: timeCategory,
                mood: mood,
                selfieFileName: selfieFileName,
                randomSeed: randomSeed,
                algorithmVersion: algorithmVersion,
                growthDelta: growthDelta,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GrowthEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$CompanionDatabase,
      $GrowthEventsTable,
      GrowthEventRow,
      $$GrowthEventsTableFilterComposer,
      $$GrowthEventsTableOrderingComposer,
      $$GrowthEventsTableAnnotationComposer,
      $$GrowthEventsTableCreateCompanionBuilder,
      $$GrowthEventsTableUpdateCompanionBuilder,
      (
        GrowthEventRow,
        BaseReferences<_$CompanionDatabase, $GrowthEventsTable, GrowthEventRow>,
      ),
      GrowthEventRow,
      PrefetchHooks Function()
    >;
typedef $$AppMetadataTableCreateCompanionBuilder =
    AppMetadataCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppMetadataTableUpdateCompanionBuilder =
    AppMetadataCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppMetadataTableFilterComposer
    extends Composer<_$CompanionDatabase, $AppMetadataTable> {
  $$AppMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppMetadataTableOrderingComposer
    extends Composer<_$CompanionDatabase, $AppMetadataTable> {
  $$AppMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppMetadataTableAnnotationComposer
    extends Composer<_$CompanionDatabase, $AppMetadataTable> {
  $$AppMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppMetadataTableTableManager
    extends
        RootTableManager<
          _$CompanionDatabase,
          $AppMetadataTable,
          AppMetadataRow,
          $$AppMetadataTableFilterComposer,
          $$AppMetadataTableOrderingComposer,
          $$AppMetadataTableAnnotationComposer,
          $$AppMetadataTableCreateCompanionBuilder,
          $$AppMetadataTableUpdateCompanionBuilder,
          (
            AppMetadataRow,
            BaseReferences<
              _$CompanionDatabase,
              $AppMetadataTable,
              AppMetadataRow
            >,
          ),
          AppMetadataRow,
          PrefetchHooks Function()
        > {
  $$AppMetadataTableTableManager(
    _$CompanionDatabase db,
    $AppMetadataTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppMetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppMetadataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppMetadataCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppMetadataCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppMetadataTableProcessedTableManager =
    ProcessedTableManager<
      _$CompanionDatabase,
      $AppMetadataTable,
      AppMetadataRow,
      $$AppMetadataTableFilterComposer,
      $$AppMetadataTableOrderingComposer,
      $$AppMetadataTableAnnotationComposer,
      $$AppMetadataTableCreateCompanionBuilder,
      $$AppMetadataTableUpdateCompanionBuilder,
      (
        AppMetadataRow,
        BaseReferences<_$CompanionDatabase, $AppMetadataTable, AppMetadataRow>,
      ),
      AppMetadataRow,
      PrefetchHooks Function()
    >;

class $CompanionDatabaseManager {
  final _$CompanionDatabase _db;
  $CompanionDatabaseManager(this._db);
  $$GrowthEventsTableTableManager get growthEvents =>
      $$GrowthEventsTableTableManager(_db, _db.growthEvents);
  $$AppMetadataTableTableManager get appMetadata =>
      $$AppMetadataTableTableManager(_db, _db.appMetadata);
}
