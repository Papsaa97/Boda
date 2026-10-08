// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class SyncOutbox extends Table with TableInfo<SyncOutbox, SyncOutboxRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  SyncOutbox(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT',
  );
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _rowKeyMeta = const VerificationMeta('rowKey');
  late final GeneratedColumn<String> rowKey = GeneratedColumn<String>(
    'row_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [seq, entity, rowKey];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncOutboxRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    }
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('row_key')) {
      context.handle(
        _rowKeyMeta,
        rowKey.isAcceptableOrUnknown(data['row_key']!, _rowKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_rowKeyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {seq};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {entity, rowKey},
  ];
  @override
  SyncOutboxRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncOutboxRow(
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      rowKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}row_key'],
      )!,
    );
  }

  @override
  SyncOutbox createAlias(String alias) {
    return SyncOutbox(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const ['UNIQUE(entity, row_key)'];
  @override
  bool get dontWriteConstraints => true;
}

class SyncOutboxRow extends DataClass implements Insertable<SyncOutboxRow> {
  final int seq;
  final String entity;
  final String rowKey;
  const SyncOutboxRow({
    required this.seq,
    required this.entity,
    required this.rowKey,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['seq'] = Variable<int>(seq);
    map['entity'] = Variable<String>(entity);
    map['row_key'] = Variable<String>(rowKey);
    return map;
  }

  SyncOutboxCompanion toCompanion(bool nullToAbsent) {
    return SyncOutboxCompanion(
      seq: Value(seq),
      entity: Value(entity),
      rowKey: Value(rowKey),
    );
  }

  factory SyncOutboxRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncOutboxRow(
      seq: serializer.fromJson<int>(json['seq']),
      entity: serializer.fromJson<String>(json['entity']),
      rowKey: serializer.fromJson<String>(json['row_key']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'seq': serializer.toJson<int>(seq),
      'entity': serializer.toJson<String>(entity),
      'row_key': serializer.toJson<String>(rowKey),
    };
  }

  SyncOutboxRow copyWith({int? seq, String? entity, String? rowKey}) =>
      SyncOutboxRow(
        seq: seq ?? this.seq,
        entity: entity ?? this.entity,
        rowKey: rowKey ?? this.rowKey,
      );
  SyncOutboxRow copyWithCompanion(SyncOutboxCompanion data) {
    return SyncOutboxRow(
      seq: data.seq.present ? data.seq.value : this.seq,
      entity: data.entity.present ? data.entity.value : this.entity,
      rowKey: data.rowKey.present ? data.rowKey.value : this.rowKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxRow(')
          ..write('seq: $seq, ')
          ..write('entity: $entity, ')
          ..write('rowKey: $rowKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(seq, entity, rowKey);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncOutboxRow &&
          other.seq == this.seq &&
          other.entity == this.entity &&
          other.rowKey == this.rowKey);
}

class SyncOutboxCompanion extends UpdateCompanion<SyncOutboxRow> {
  final Value<int> seq;
  final Value<String> entity;
  final Value<String> rowKey;
  const SyncOutboxCompanion({
    this.seq = const Value.absent(),
    this.entity = const Value.absent(),
    this.rowKey = const Value.absent(),
  });
  SyncOutboxCompanion.insert({
    this.seq = const Value.absent(),
    required String entity,
    required String rowKey,
  }) : entity = Value(entity),
       rowKey = Value(rowKey);
  static Insertable<SyncOutboxRow> custom({
    Expression<int>? seq,
    Expression<String>? entity,
    Expression<String>? rowKey,
  }) {
    return RawValuesInsertable({
      if (seq != null) 'seq': seq,
      if (entity != null) 'entity': entity,
      if (rowKey != null) 'row_key': rowKey,
    });
  }

  SyncOutboxCompanion copyWith({
    Value<int>? seq,
    Value<String>? entity,
    Value<String>? rowKey,
  }) {
    return SyncOutboxCompanion(
      seq: seq ?? this.seq,
      entity: entity ?? this.entity,
      rowKey: rowKey ?? this.rowKey,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (rowKey.present) {
      map['row_key'] = Variable<String>(rowKey.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxCompanion(')
          ..write('seq: $seq, ')
          ..write('entity: $entity, ')
          ..write('rowKey: $rowKey')
          ..write(')'))
        .toString();
  }
}

class SyncState extends Table with TableInfo<SyncState, SyncStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  SyncState(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [name, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncStateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {name};
  @override
  SyncStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncStateRow(
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      ),
    );
  }

  @override
  SyncState createAlias(String alias) {
    return SyncState(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class SyncStateRow extends DataClass implements Insertable<SyncStateRow> {
  final String name;
  final String? value;
  const SyncStateRow({required this.name, this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(value);
    }
    return map;
  }

  SyncStateCompanion toCompanion(bool nullToAbsent) {
    return SyncStateCompanion(
      name: Value(name),
      value: value == null && nullToAbsent
          ? const Value.absent()
          : Value(value),
    );
  }

  factory SyncStateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncStateRow(
      name: serializer.fromJson<String>(json['name']),
      value: serializer.fromJson<String?>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'name': serializer.toJson<String>(name),
      'value': serializer.toJson<String?>(value),
    };
  }

  SyncStateRow copyWith({
    String? name,
    Value<String?> value = const Value.absent(),
  }) => SyncStateRow(
    name: name ?? this.name,
    value: value.present ? value.value : this.value,
  );
  SyncStateRow copyWithCompanion(SyncStateCompanion data) {
    return SyncStateRow(
      name: data.name.present ? data.name.value : this.name,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateRow(')
          ..write('name: $name, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(name, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncStateRow &&
          other.name == this.name &&
          other.value == this.value);
}

class SyncStateCompanion extends UpdateCompanion<SyncStateRow> {
  final Value<String> name;
  final Value<String?> value;
  final Value<int> rowid;
  const SyncStateCompanion({
    this.name = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncStateCompanion.insert({
    required String name,
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name);
  static Insertable<SyncStateRow> custom({
    Expression<String>? name,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (name != null) 'name': name,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncStateCompanion copyWith({
    Value<String>? name,
    Value<String?>? value,
    Value<int>? rowid,
  }) {
    return SyncStateCompanion(
      name: name ?? this.name,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (name.present) {
      map['name'] = Variable<String>(name.value);
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
    return (StringBuffer('SyncStateCompanion(')
          ..write('name: $name, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GardensTable extends Gardens with TableInfo<$GardensTable, GardenRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GardensTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _boundsMeta = const VerificationMeta('bounds');
  @override
  late final GeneratedColumn<String> bounds = GeneratedColumn<String>(
    'bounds',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationLatMeta = const VerificationMeta(
    'locationLat',
  );
  @override
  late final GeneratedColumn<double> locationLat = GeneratedColumn<double>(
    'location_lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationLngMeta = const VerificationMeta(
    'locationLng',
  );
  @override
  late final GeneratedColumn<double> locationLng = GeneratedColumn<double>(
    'location_lng',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _altitudeMMeta = const VerificationMeta(
    'altitudeM',
  );
  @override
  late final GeneratedColumn<int> altitudeM = GeneratedColumn<int>(
    'altitude_m',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    createdAt,
    updatedAt,
    bounds,
    locationLat,
    locationLng,
    altitudeM,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gardens';
  @override
  VerificationContext validateIntegrity(
    Insertable<GardenRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('bounds')) {
      context.handle(
        _boundsMeta,
        bounds.isAcceptableOrUnknown(data['bounds']!, _boundsMeta),
      );
    }
    if (data.containsKey('location_lat')) {
      context.handle(
        _locationLatMeta,
        locationLat.isAcceptableOrUnknown(
          data['location_lat']!,
          _locationLatMeta,
        ),
      );
    }
    if (data.containsKey('location_lng')) {
      context.handle(
        _locationLngMeta,
        locationLng.isAcceptableOrUnknown(
          data['location_lng']!,
          _locationLngMeta,
        ),
      );
    }
    if (data.containsKey('altitude_m')) {
      context.handle(
        _altitudeMMeta,
        altitudeM.isAcceptableOrUnknown(data['altitude_m']!, _altitudeMMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GardenRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GardenRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      bounds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bounds'],
      ),
      locationLat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}location_lat'],
      ),
      locationLng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}location_lng'],
      ),
      altitudeM: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}altitude_m'],
      ),
    );
  }

  @override
  $GardensTable createAlias(String alias) {
    return $GardensTable(attachedDatabase, alias);
  }
}

class GardenRow extends DataClass implements Insertable<GardenRow> {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Plán zahrady (1.1, schéma 5): JSON `{"outline": [[x, y], ...]}`
  /// v metrech; serverový sloupec `bounds`.
  final String? bounds;

  /// Poloha zahrady pro počasí (V2, schéma 7), zaokrouhlená na 2 desetinná
  /// místa (~1 km, spec 8.1).
  final double? locationLat;
  final double? locationLng;

  /// Nadmořská výška v metrech (fenologický kalendář, FR-W5).
  final int? altitudeM;
  const GardenRow({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.bounds,
    this.locationLat,
    this.locationLng,
    this.altitudeM,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || bounds != null) {
      map['bounds'] = Variable<String>(bounds);
    }
    if (!nullToAbsent || locationLat != null) {
      map['location_lat'] = Variable<double>(locationLat);
    }
    if (!nullToAbsent || locationLng != null) {
      map['location_lng'] = Variable<double>(locationLng);
    }
    if (!nullToAbsent || altitudeM != null) {
      map['altitude_m'] = Variable<int>(altitudeM);
    }
    return map;
  }

  GardensCompanion toCompanion(bool nullToAbsent) {
    return GardensCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      bounds: bounds == null && nullToAbsent
          ? const Value.absent()
          : Value(bounds),
      locationLat: locationLat == null && nullToAbsent
          ? const Value.absent()
          : Value(locationLat),
      locationLng: locationLng == null && nullToAbsent
          ? const Value.absent()
          : Value(locationLng),
      altitudeM: altitudeM == null && nullToAbsent
          ? const Value.absent()
          : Value(altitudeM),
    );
  }

  factory GardenRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GardenRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      bounds: serializer.fromJson<String?>(json['bounds']),
      locationLat: serializer.fromJson<double?>(json['locationLat']),
      locationLng: serializer.fromJson<double?>(json['locationLng']),
      altitudeM: serializer.fromJson<int?>(json['altitudeM']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'bounds': serializer.toJson<String?>(bounds),
      'locationLat': serializer.toJson<double?>(locationLat),
      'locationLng': serializer.toJson<double?>(locationLng),
      'altitudeM': serializer.toJson<int?>(altitudeM),
    };
  }

  GardenRow copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<String?> bounds = const Value.absent(),
    Value<double?> locationLat = const Value.absent(),
    Value<double?> locationLng = const Value.absent(),
    Value<int?> altitudeM = const Value.absent(),
  }) => GardenRow(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    bounds: bounds.present ? bounds.value : this.bounds,
    locationLat: locationLat.present ? locationLat.value : this.locationLat,
    locationLng: locationLng.present ? locationLng.value : this.locationLng,
    altitudeM: altitudeM.present ? altitudeM.value : this.altitudeM,
  );
  GardenRow copyWithCompanion(GardensCompanion data) {
    return GardenRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      bounds: data.bounds.present ? data.bounds.value : this.bounds,
      locationLat: data.locationLat.present
          ? data.locationLat.value
          : this.locationLat,
      locationLng: data.locationLng.present
          ? data.locationLng.value
          : this.locationLng,
      altitudeM: data.altitudeM.present ? data.altitudeM.value : this.altitudeM,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GardenRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('bounds: $bounds, ')
          ..write('locationLat: $locationLat, ')
          ..write('locationLng: $locationLng, ')
          ..write('altitudeM: $altitudeM')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    createdAt,
    updatedAt,
    bounds,
    locationLat,
    locationLng,
    altitudeM,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GardenRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.bounds == this.bounds &&
          other.locationLat == this.locationLat &&
          other.locationLng == this.locationLng &&
          other.altitudeM == this.altitudeM);
}

class GardensCompanion extends UpdateCompanion<GardenRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String?> bounds;
  final Value<double?> locationLat;
  final Value<double?> locationLng;
  final Value<int?> altitudeM;
  final Value<int> rowid;
  const GardensCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.bounds = const Value.absent(),
    this.locationLat = const Value.absent(),
    this.locationLng = const Value.absent(),
    this.altitudeM = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GardensCompanion.insert({
    required String id,
    required String name,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.bounds = const Value.absent(),
    this.locationLat = const Value.absent(),
    this.locationLng = const Value.absent(),
    this.altitudeM = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<GardenRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? bounds,
    Expression<double>? locationLat,
    Expression<double>? locationLng,
    Expression<int>? altitudeM,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (bounds != null) 'bounds': bounds,
      if (locationLat != null) 'location_lat': locationLat,
      if (locationLng != null) 'location_lng': locationLng,
      if (altitudeM != null) 'altitude_m': altitudeM,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GardensCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String?>? bounds,
    Value<double?>? locationLat,
    Value<double?>? locationLng,
    Value<int?>? altitudeM,
    Value<int>? rowid,
  }) {
    return GardensCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      bounds: bounds ?? this.bounds,
      locationLat: locationLat ?? this.locationLat,
      locationLng: locationLng ?? this.locationLng,
      altitudeM: altitudeM ?? this.altitudeM,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (bounds.present) {
      map['bounds'] = Variable<String>(bounds.value);
    }
    if (locationLat.present) {
      map['location_lat'] = Variable<double>(locationLat.value);
    }
    if (locationLng.present) {
      map['location_lng'] = Variable<double>(locationLng.value);
    }
    if (altitudeM.present) {
      map['altitude_m'] = Variable<int>(altitudeM.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GardensCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('bounds: $bounds, ')
          ..write('locationLat: $locationLat, ')
          ..write('locationLng: $locationLng, ')
          ..write('altitudeM: $altitudeM, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ZonesTable extends Zones with TableInfo<$ZonesTable, ZoneRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ZonesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gardenIdMeta = const VerificationMeta(
    'gardenId',
  );
  @override
  late final GeneratedColumn<String> gardenId = GeneratedColumn<String>(
    'garden_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES gardens (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('other'),
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _areaM2Meta = const VerificationMeta('areaM2');
  @override
  late final GeneratedColumn<double> areaM2 = GeneratedColumn<double>(
    'area_m2',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _soilTextureMeta = const VerificationMeta(
    'soilTexture',
  );
  @override
  late final GeneratedColumn<String> soilTexture = GeneratedColumn<String>(
    'soil_texture',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phMeta = const VerificationMeta('ph');
  @override
  late final GeneratedColumn<double> ph = GeneratedColumn<double>(
    'ph',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phMeasuredAtMeta = const VerificationMeta(
    'phMeasuredAt',
  );
  @override
  late final GeneratedColumn<String> phMeasuredAt = GeneratedColumn<String>(
    'ph_measured_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sunExposureMeta = const VerificationMeta(
    'sunExposure',
  );
  @override
  late final GeneratedColumn<String> sunExposure = GeneratedColumn<String>(
    'sun_exposure',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _irrigationMeta = const VerificationMeta(
    'irrigation',
  );
  @override
  late final GeneratedColumn<String> irrigation = GeneratedColumn<String>(
    'irrigation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coveredMeta = const VerificationMeta(
    'covered',
  );
  @override
  late final GeneratedColumn<bool> covered = GeneratedColumn<bool>(
    'covered',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("covered" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _polygonMeta = const VerificationMeta(
    'polygon',
  );
  @override
  late final GeneratedColumn<String> polygon = GeneratedColumn<String>(
    'polygon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _layerMeta = const VerificationMeta('layer');
  @override
  late final GeneratedColumn<String> layer = GeneratedColumn<String>(
    'layer',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    gardenId,
    name,
    type,
    archived,
    sortOrder,
    areaM2,
    soilTexture,
    ph,
    phMeasuredAt,
    sunExposure,
    irrigation,
    covered,
    polygon,
    layer,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'zones';
  @override
  VerificationContext validateIntegrity(
    Insertable<ZoneRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('garden_id')) {
      context.handle(
        _gardenIdMeta,
        gardenId.isAcceptableOrUnknown(data['garden_id']!, _gardenIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gardenIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('area_m2')) {
      context.handle(
        _areaM2Meta,
        areaM2.isAcceptableOrUnknown(data['area_m2']!, _areaM2Meta),
      );
    }
    if (data.containsKey('soil_texture')) {
      context.handle(
        _soilTextureMeta,
        soilTexture.isAcceptableOrUnknown(
          data['soil_texture']!,
          _soilTextureMeta,
        ),
      );
    }
    if (data.containsKey('ph')) {
      context.handle(_phMeta, ph.isAcceptableOrUnknown(data['ph']!, _phMeta));
    }
    if (data.containsKey('ph_measured_at')) {
      context.handle(
        _phMeasuredAtMeta,
        phMeasuredAt.isAcceptableOrUnknown(
          data['ph_measured_at']!,
          _phMeasuredAtMeta,
        ),
      );
    }
    if (data.containsKey('sun_exposure')) {
      context.handle(
        _sunExposureMeta,
        sunExposure.isAcceptableOrUnknown(
          data['sun_exposure']!,
          _sunExposureMeta,
        ),
      );
    }
    if (data.containsKey('irrigation')) {
      context.handle(
        _irrigationMeta,
        irrigation.isAcceptableOrUnknown(data['irrigation']!, _irrigationMeta),
      );
    }
    if (data.containsKey('covered')) {
      context.handle(
        _coveredMeta,
        covered.isAcceptableOrUnknown(data['covered']!, _coveredMeta),
      );
    }
    if (data.containsKey('polygon')) {
      context.handle(
        _polygonMeta,
        polygon.isAcceptableOrUnknown(data['polygon']!, _polygonMeta),
      );
    }
    if (data.containsKey('layer')) {
      context.handle(
        _layerMeta,
        layer.isAcceptableOrUnknown(data['layer']!, _layerMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ZoneRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ZoneRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      gardenId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}garden_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      ),
      areaM2: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}area_m2'],
      ),
      soilTexture: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}soil_texture'],
      ),
      ph: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ph'],
      ),
      phMeasuredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ph_measured_at'],
      ),
      sunExposure: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sun_exposure'],
      ),
      irrigation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}irrigation'],
      ),
      covered: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}covered'],
      )!,
      polygon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}polygon'],
      ),
      layer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}layer'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $ZonesTable createAlias(String alias) {
    return $ZonesTable(attachedDatabase, alias);
  }
}

class ZoneRow extends DataClass implements Insertable<ZoneRow> {
  final String id;
  final String gardenId;
  final String name;

  /// Číselník `zone.type` (kap. 8.3).
  final String type;
  final bool archived;

  /// Pořadí v nabídce (menší první); null = podle názvu.
  final int? sortOrder;
  final double? areaM2;
  final String? soilTexture;
  final double? ph;

  /// Den měření pH `YYYY-MM-DD`.
  final String? phMeasuredAt;
  final String? sunExposure;
  final String? irrigation;
  final bool covered;

  /// Tvar na plánu zahrady (1.1, schéma 5): JSON `[[x, y], ...]` v metrech.
  final String? polygon;

  /// Vrstva plánu `reality` | `plan`; null = realita.
  final String? layer;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const ZoneRow({
    required this.id,
    required this.gardenId,
    required this.name,
    required this.type,
    required this.archived,
    this.sortOrder,
    this.areaM2,
    this.soilTexture,
    this.ph,
    this.phMeasuredAt,
    this.sunExposure,
    this.irrigation,
    required this.covered,
    this.polygon,
    this.layer,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['garden_id'] = Variable<String>(gardenId);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['archived'] = Variable<bool>(archived);
    if (!nullToAbsent || sortOrder != null) {
      map['sort_order'] = Variable<int>(sortOrder);
    }
    if (!nullToAbsent || areaM2 != null) {
      map['area_m2'] = Variable<double>(areaM2);
    }
    if (!nullToAbsent || soilTexture != null) {
      map['soil_texture'] = Variable<String>(soilTexture);
    }
    if (!nullToAbsent || ph != null) {
      map['ph'] = Variable<double>(ph);
    }
    if (!nullToAbsent || phMeasuredAt != null) {
      map['ph_measured_at'] = Variable<String>(phMeasuredAt);
    }
    if (!nullToAbsent || sunExposure != null) {
      map['sun_exposure'] = Variable<String>(sunExposure);
    }
    if (!nullToAbsent || irrigation != null) {
      map['irrigation'] = Variable<String>(irrigation);
    }
    map['covered'] = Variable<bool>(covered);
    if (!nullToAbsent || polygon != null) {
      map['polygon'] = Variable<String>(polygon);
    }
    if (!nullToAbsent || layer != null) {
      map['layer'] = Variable<String>(layer);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  ZonesCompanion toCompanion(bool nullToAbsent) {
    return ZonesCompanion(
      id: Value(id),
      gardenId: Value(gardenId),
      name: Value(name),
      type: Value(type),
      archived: Value(archived),
      sortOrder: sortOrder == null && nullToAbsent
          ? const Value.absent()
          : Value(sortOrder),
      areaM2: areaM2 == null && nullToAbsent
          ? const Value.absent()
          : Value(areaM2),
      soilTexture: soilTexture == null && nullToAbsent
          ? const Value.absent()
          : Value(soilTexture),
      ph: ph == null && nullToAbsent ? const Value.absent() : Value(ph),
      phMeasuredAt: phMeasuredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(phMeasuredAt),
      sunExposure: sunExposure == null && nullToAbsent
          ? const Value.absent()
          : Value(sunExposure),
      irrigation: irrigation == null && nullToAbsent
          ? const Value.absent()
          : Value(irrigation),
      covered: Value(covered),
      polygon: polygon == null && nullToAbsent
          ? const Value.absent()
          : Value(polygon),
      layer: layer == null && nullToAbsent
          ? const Value.absent()
          : Value(layer),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory ZoneRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ZoneRow(
      id: serializer.fromJson<String>(json['id']),
      gardenId: serializer.fromJson<String>(json['gardenId']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      archived: serializer.fromJson<bool>(json['archived']),
      sortOrder: serializer.fromJson<int?>(json['sortOrder']),
      areaM2: serializer.fromJson<double?>(json['areaM2']),
      soilTexture: serializer.fromJson<String?>(json['soilTexture']),
      ph: serializer.fromJson<double?>(json['ph']),
      phMeasuredAt: serializer.fromJson<String?>(json['phMeasuredAt']),
      sunExposure: serializer.fromJson<String?>(json['sunExposure']),
      irrigation: serializer.fromJson<String?>(json['irrigation']),
      covered: serializer.fromJson<bool>(json['covered']),
      polygon: serializer.fromJson<String?>(json['polygon']),
      layer: serializer.fromJson<String?>(json['layer']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'gardenId': serializer.toJson<String>(gardenId),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'archived': serializer.toJson<bool>(archived),
      'sortOrder': serializer.toJson<int?>(sortOrder),
      'areaM2': serializer.toJson<double?>(areaM2),
      'soilTexture': serializer.toJson<String?>(soilTexture),
      'ph': serializer.toJson<double?>(ph),
      'phMeasuredAt': serializer.toJson<String?>(phMeasuredAt),
      'sunExposure': serializer.toJson<String?>(sunExposure),
      'irrigation': serializer.toJson<String?>(irrigation),
      'covered': serializer.toJson<bool>(covered),
      'polygon': serializer.toJson<String?>(polygon),
      'layer': serializer.toJson<String?>(layer),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  ZoneRow copyWith({
    String? id,
    String? gardenId,
    String? name,
    String? type,
    bool? archived,
    Value<int?> sortOrder = const Value.absent(),
    Value<double?> areaM2 = const Value.absent(),
    Value<String?> soilTexture = const Value.absent(),
    Value<double?> ph = const Value.absent(),
    Value<String?> phMeasuredAt = const Value.absent(),
    Value<String?> sunExposure = const Value.absent(),
    Value<String?> irrigation = const Value.absent(),
    bool? covered,
    Value<String?> polygon = const Value.absent(),
    Value<String?> layer = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => ZoneRow(
    id: id ?? this.id,
    gardenId: gardenId ?? this.gardenId,
    name: name ?? this.name,
    type: type ?? this.type,
    archived: archived ?? this.archived,
    sortOrder: sortOrder.present ? sortOrder.value : this.sortOrder,
    areaM2: areaM2.present ? areaM2.value : this.areaM2,
    soilTexture: soilTexture.present ? soilTexture.value : this.soilTexture,
    ph: ph.present ? ph.value : this.ph,
    phMeasuredAt: phMeasuredAt.present ? phMeasuredAt.value : this.phMeasuredAt,
    sunExposure: sunExposure.present ? sunExposure.value : this.sunExposure,
    irrigation: irrigation.present ? irrigation.value : this.irrigation,
    covered: covered ?? this.covered,
    polygon: polygon.present ? polygon.value : this.polygon,
    layer: layer.present ? layer.value : this.layer,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  ZoneRow copyWithCompanion(ZonesCompanion data) {
    return ZoneRow(
      id: data.id.present ? data.id.value : this.id,
      gardenId: data.gardenId.present ? data.gardenId.value : this.gardenId,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      archived: data.archived.present ? data.archived.value : this.archived,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      areaM2: data.areaM2.present ? data.areaM2.value : this.areaM2,
      soilTexture: data.soilTexture.present
          ? data.soilTexture.value
          : this.soilTexture,
      ph: data.ph.present ? data.ph.value : this.ph,
      phMeasuredAt: data.phMeasuredAt.present
          ? data.phMeasuredAt.value
          : this.phMeasuredAt,
      sunExposure: data.sunExposure.present
          ? data.sunExposure.value
          : this.sunExposure,
      irrigation: data.irrigation.present
          ? data.irrigation.value
          : this.irrigation,
      covered: data.covered.present ? data.covered.value : this.covered,
      polygon: data.polygon.present ? data.polygon.value : this.polygon,
      layer: data.layer.present ? data.layer.value : this.layer,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ZoneRow(')
          ..write('id: $id, ')
          ..write('gardenId: $gardenId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('archived: $archived, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('areaM2: $areaM2, ')
          ..write('soilTexture: $soilTexture, ')
          ..write('ph: $ph, ')
          ..write('phMeasuredAt: $phMeasuredAt, ')
          ..write('sunExposure: $sunExposure, ')
          ..write('irrigation: $irrigation, ')
          ..write('covered: $covered, ')
          ..write('polygon: $polygon, ')
          ..write('layer: $layer, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    gardenId,
    name,
    type,
    archived,
    sortOrder,
    areaM2,
    soilTexture,
    ph,
    phMeasuredAt,
    sunExposure,
    irrigation,
    covered,
    polygon,
    layer,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ZoneRow &&
          other.id == this.id &&
          other.gardenId == this.gardenId &&
          other.name == this.name &&
          other.type == this.type &&
          other.archived == this.archived &&
          other.sortOrder == this.sortOrder &&
          other.areaM2 == this.areaM2 &&
          other.soilTexture == this.soilTexture &&
          other.ph == this.ph &&
          other.phMeasuredAt == this.phMeasuredAt &&
          other.sunExposure == this.sunExposure &&
          other.irrigation == this.irrigation &&
          other.covered == this.covered &&
          other.polygon == this.polygon &&
          other.layer == this.layer &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class ZonesCompanion extends UpdateCompanion<ZoneRow> {
  final Value<String> id;
  final Value<String> gardenId;
  final Value<String> name;
  final Value<String> type;
  final Value<bool> archived;
  final Value<int?> sortOrder;
  final Value<double?> areaM2;
  final Value<String?> soilTexture;
  final Value<double?> ph;
  final Value<String?> phMeasuredAt;
  final Value<String?> sunExposure;
  final Value<String?> irrigation;
  final Value<bool> covered;
  final Value<String?> polygon;
  final Value<String?> layer;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const ZonesCompanion({
    this.id = const Value.absent(),
    this.gardenId = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.archived = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.areaM2 = const Value.absent(),
    this.soilTexture = const Value.absent(),
    this.ph = const Value.absent(),
    this.phMeasuredAt = const Value.absent(),
    this.sunExposure = const Value.absent(),
    this.irrigation = const Value.absent(),
    this.covered = const Value.absent(),
    this.polygon = const Value.absent(),
    this.layer = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ZonesCompanion.insert({
    required String id,
    required String gardenId,
    required String name,
    this.type = const Value.absent(),
    this.archived = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.areaM2 = const Value.absent(),
    this.soilTexture = const Value.absent(),
    this.ph = const Value.absent(),
    this.phMeasuredAt = const Value.absent(),
    this.sunExposure = const Value.absent(),
    this.irrigation = const Value.absent(),
    this.covered = const Value.absent(),
    this.polygon = const Value.absent(),
    this.layer = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       gardenId = Value(gardenId),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ZoneRow> custom({
    Expression<String>? id,
    Expression<String>? gardenId,
    Expression<String>? name,
    Expression<String>? type,
    Expression<bool>? archived,
    Expression<int>? sortOrder,
    Expression<double>? areaM2,
    Expression<String>? soilTexture,
    Expression<double>? ph,
    Expression<String>? phMeasuredAt,
    Expression<String>? sunExposure,
    Expression<String>? irrigation,
    Expression<bool>? covered,
    Expression<String>? polygon,
    Expression<String>? layer,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gardenId != null) 'garden_id': gardenId,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (archived != null) 'archived': archived,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (areaM2 != null) 'area_m2': areaM2,
      if (soilTexture != null) 'soil_texture': soilTexture,
      if (ph != null) 'ph': ph,
      if (phMeasuredAt != null) 'ph_measured_at': phMeasuredAt,
      if (sunExposure != null) 'sun_exposure': sunExposure,
      if (irrigation != null) 'irrigation': irrigation,
      if (covered != null) 'covered': covered,
      if (polygon != null) 'polygon': polygon,
      if (layer != null) 'layer': layer,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ZonesCompanion copyWith({
    Value<String>? id,
    Value<String>? gardenId,
    Value<String>? name,
    Value<String>? type,
    Value<bool>? archived,
    Value<int?>? sortOrder,
    Value<double?>? areaM2,
    Value<String?>? soilTexture,
    Value<double?>? ph,
    Value<String?>? phMeasuredAt,
    Value<String?>? sunExposure,
    Value<String?>? irrigation,
    Value<bool>? covered,
    Value<String?>? polygon,
    Value<String?>? layer,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return ZonesCompanion(
      id: id ?? this.id,
      gardenId: gardenId ?? this.gardenId,
      name: name ?? this.name,
      type: type ?? this.type,
      archived: archived ?? this.archived,
      sortOrder: sortOrder ?? this.sortOrder,
      areaM2: areaM2 ?? this.areaM2,
      soilTexture: soilTexture ?? this.soilTexture,
      ph: ph ?? this.ph,
      phMeasuredAt: phMeasuredAt ?? this.phMeasuredAt,
      sunExposure: sunExposure ?? this.sunExposure,
      irrigation: irrigation ?? this.irrigation,
      covered: covered ?? this.covered,
      polygon: polygon ?? this.polygon,
      layer: layer ?? this.layer,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (gardenId.present) {
      map['garden_id'] = Variable<String>(gardenId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (areaM2.present) {
      map['area_m2'] = Variable<double>(areaM2.value);
    }
    if (soilTexture.present) {
      map['soil_texture'] = Variable<String>(soilTexture.value);
    }
    if (ph.present) {
      map['ph'] = Variable<double>(ph.value);
    }
    if (phMeasuredAt.present) {
      map['ph_measured_at'] = Variable<String>(phMeasuredAt.value);
    }
    if (sunExposure.present) {
      map['sun_exposure'] = Variable<String>(sunExposure.value);
    }
    if (irrigation.present) {
      map['irrigation'] = Variable<String>(irrigation.value);
    }
    if (covered.present) {
      map['covered'] = Variable<bool>(covered.value);
    }
    if (polygon.present) {
      map['polygon'] = Variable<String>(polygon.value);
    }
    if (layer.present) {
      map['layer'] = Variable<String>(layer.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ZonesCompanion(')
          ..write('id: $id, ')
          ..write('gardenId: $gardenId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('archived: $archived, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('areaM2: $areaM2, ')
          ..write('soilTexture: $soilTexture, ')
          ..write('ph: $ph, ')
          ..write('phMeasuredAt: $phMeasuredAt, ')
          ..write('sunExposure: $sunExposure, ')
          ..write('irrigation: $irrigation, ')
          ..write('covered: $covered, ')
          ..write('polygon: $polygon, ')
          ..write('layer: $layer, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InventoryItemsTable extends InventoryItems
    with TableInfo<$InventoryItemsTable, InventoryItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InventoryItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gardenIdMeta = const VerificationMeta(
    'gardenId',
  );
  @override
  late final GeneratedColumn<String> gardenId = GeneratedColumn<String>(
    'garden_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES gardens (id)',
    ),
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stockQtyMeta = const VerificationMeta(
    'stockQty',
  );
  @override
  late final GeneratedColumn<double> stockQty = GeneratedColumn<double>(
    'stock_qty',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lowStockThresholdMeta = const VerificationMeta(
    'lowStockThreshold',
  );
  @override
  late final GeneratedColumn<double> lowStockThreshold =
      GeneratedColumn<double>(
        'low_stock_threshold',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _detailsMeta = const VerificationMeta(
    'details',
  );
  @override
  late final GeneratedColumn<String> details = GeneratedColumn<String>(
    'details',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    gardenId,
    category,
    name,
    unit,
    stockQty,
    lowStockThreshold,
    details,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inventory_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<InventoryItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('garden_id')) {
      context.handle(
        _gardenIdMeta,
        gardenId.isAcceptableOrUnknown(data['garden_id']!, _gardenIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gardenIdMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('stock_qty')) {
      context.handle(
        _stockQtyMeta,
        stockQty.isAcceptableOrUnknown(data['stock_qty']!, _stockQtyMeta),
      );
    }
    if (data.containsKey('low_stock_threshold')) {
      context.handle(
        _lowStockThresholdMeta,
        lowStockThreshold.isAcceptableOrUnknown(
          data['low_stock_threshold']!,
          _lowStockThresholdMeta,
        ),
      );
    }
    if (data.containsKey('details')) {
      context.handle(
        _detailsMeta,
        details.isAcceptableOrUnknown(data['details']!, _detailsMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InventoryItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InventoryItemRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      gardenId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}garden_id'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      stockQty: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stock_qty'],
      )!,
      lowStockThreshold: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}low_stock_threshold'],
      ),
      details: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}details'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $InventoryItemsTable createAlias(String alias) {
    return $InventoryItemsTable(attachedDatabase, alias);
  }
}

class InventoryItemRow extends DataClass
    implements Insertable<InventoryItemRow> {
  final String id;
  final String gardenId;

  /// `seed`, `fertilizer`, `plantProtection`, `tool`, `other`.
  final String category;
  final String name;

  /// `g`, `kg`, `ml`, `l`, `ks`, `pack`.
  final String unit;
  final double stockQty;
  final double? lowStockThreshold;

  /// Údaje podle kategorie jako JSON (v PostgreSQL `jsonb`).
  final String? details;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const InventoryItemRow({
    required this.id,
    required this.gardenId,
    required this.category,
    required this.name,
    required this.unit,
    required this.stockQty,
    this.lowStockThreshold,
    this.details,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['garden_id'] = Variable<String>(gardenId);
    map['category'] = Variable<String>(category);
    map['name'] = Variable<String>(name);
    map['unit'] = Variable<String>(unit);
    map['stock_qty'] = Variable<double>(stockQty);
    if (!nullToAbsent || lowStockThreshold != null) {
      map['low_stock_threshold'] = Variable<double>(lowStockThreshold);
    }
    if (!nullToAbsent || details != null) {
      map['details'] = Variable<String>(details);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  InventoryItemsCompanion toCompanion(bool nullToAbsent) {
    return InventoryItemsCompanion(
      id: Value(id),
      gardenId: Value(gardenId),
      category: Value(category),
      name: Value(name),
      unit: Value(unit),
      stockQty: Value(stockQty),
      lowStockThreshold: lowStockThreshold == null && nullToAbsent
          ? const Value.absent()
          : Value(lowStockThreshold),
      details: details == null && nullToAbsent
          ? const Value.absent()
          : Value(details),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory InventoryItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InventoryItemRow(
      id: serializer.fromJson<String>(json['id']),
      gardenId: serializer.fromJson<String>(json['gardenId']),
      category: serializer.fromJson<String>(json['category']),
      name: serializer.fromJson<String>(json['name']),
      unit: serializer.fromJson<String>(json['unit']),
      stockQty: serializer.fromJson<double>(json['stockQty']),
      lowStockThreshold: serializer.fromJson<double?>(
        json['lowStockThreshold'],
      ),
      details: serializer.fromJson<String?>(json['details']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'gardenId': serializer.toJson<String>(gardenId),
      'category': serializer.toJson<String>(category),
      'name': serializer.toJson<String>(name),
      'unit': serializer.toJson<String>(unit),
      'stockQty': serializer.toJson<double>(stockQty),
      'lowStockThreshold': serializer.toJson<double?>(lowStockThreshold),
      'details': serializer.toJson<String?>(details),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  InventoryItemRow copyWith({
    String? id,
    String? gardenId,
    String? category,
    String? name,
    String? unit,
    double? stockQty,
    Value<double?> lowStockThreshold = const Value.absent(),
    Value<String?> details = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => InventoryItemRow(
    id: id ?? this.id,
    gardenId: gardenId ?? this.gardenId,
    category: category ?? this.category,
    name: name ?? this.name,
    unit: unit ?? this.unit,
    stockQty: stockQty ?? this.stockQty,
    lowStockThreshold: lowStockThreshold.present
        ? lowStockThreshold.value
        : this.lowStockThreshold,
    details: details.present ? details.value : this.details,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  InventoryItemRow copyWithCompanion(InventoryItemsCompanion data) {
    return InventoryItemRow(
      id: data.id.present ? data.id.value : this.id,
      gardenId: data.gardenId.present ? data.gardenId.value : this.gardenId,
      category: data.category.present ? data.category.value : this.category,
      name: data.name.present ? data.name.value : this.name,
      unit: data.unit.present ? data.unit.value : this.unit,
      stockQty: data.stockQty.present ? data.stockQty.value : this.stockQty,
      lowStockThreshold: data.lowStockThreshold.present
          ? data.lowStockThreshold.value
          : this.lowStockThreshold,
      details: data.details.present ? data.details.value : this.details,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InventoryItemRow(')
          ..write('id: $id, ')
          ..write('gardenId: $gardenId, ')
          ..write('category: $category, ')
          ..write('name: $name, ')
          ..write('unit: $unit, ')
          ..write('stockQty: $stockQty, ')
          ..write('lowStockThreshold: $lowStockThreshold, ')
          ..write('details: $details, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    gardenId,
    category,
    name,
    unit,
    stockQty,
    lowStockThreshold,
    details,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InventoryItemRow &&
          other.id == this.id &&
          other.gardenId == this.gardenId &&
          other.category == this.category &&
          other.name == this.name &&
          other.unit == this.unit &&
          other.stockQty == this.stockQty &&
          other.lowStockThreshold == this.lowStockThreshold &&
          other.details == this.details &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class InventoryItemsCompanion extends UpdateCompanion<InventoryItemRow> {
  final Value<String> id;
  final Value<String> gardenId;
  final Value<String> category;
  final Value<String> name;
  final Value<String> unit;
  final Value<double> stockQty;
  final Value<double?> lowStockThreshold;
  final Value<String?> details;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const InventoryItemsCompanion({
    this.id = const Value.absent(),
    this.gardenId = const Value.absent(),
    this.category = const Value.absent(),
    this.name = const Value.absent(),
    this.unit = const Value.absent(),
    this.stockQty = const Value.absent(),
    this.lowStockThreshold = const Value.absent(),
    this.details = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InventoryItemsCompanion.insert({
    required String id,
    required String gardenId,
    required String category,
    required String name,
    required String unit,
    this.stockQty = const Value.absent(),
    this.lowStockThreshold = const Value.absent(),
    this.details = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       gardenId = Value(gardenId),
       category = Value(category),
       name = Value(name),
       unit = Value(unit),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<InventoryItemRow> custom({
    Expression<String>? id,
    Expression<String>? gardenId,
    Expression<String>? category,
    Expression<String>? name,
    Expression<String>? unit,
    Expression<double>? stockQty,
    Expression<double>? lowStockThreshold,
    Expression<String>? details,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gardenId != null) 'garden_id': gardenId,
      if (category != null) 'category': category,
      if (name != null) 'name': name,
      if (unit != null) 'unit': unit,
      if (stockQty != null) 'stock_qty': stockQty,
      if (lowStockThreshold != null) 'low_stock_threshold': lowStockThreshold,
      if (details != null) 'details': details,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InventoryItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? gardenId,
    Value<String>? category,
    Value<String>? name,
    Value<String>? unit,
    Value<double>? stockQty,
    Value<double?>? lowStockThreshold,
    Value<String?>? details,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return InventoryItemsCompanion(
      id: id ?? this.id,
      gardenId: gardenId ?? this.gardenId,
      category: category ?? this.category,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      stockQty: stockQty ?? this.stockQty,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      details: details ?? this.details,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (gardenId.present) {
      map['garden_id'] = Variable<String>(gardenId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (stockQty.present) {
      map['stock_qty'] = Variable<double>(stockQty.value);
    }
    if (lowStockThreshold.present) {
      map['low_stock_threshold'] = Variable<double>(lowStockThreshold.value);
    }
    if (details.present) {
      map['details'] = Variable<String>(details.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InventoryItemsCompanion(')
          ..write('id: $id, ')
          ..write('gardenId: $gardenId, ')
          ..write('category: $category, ')
          ..write('name: $name, ')
          ..write('unit: $unit, ')
          ..write('stockQty: $stockQty, ')
          ..write('lowStockThreshold: $lowStockThreshold, ')
          ..write('details: $details, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IncidentsTable extends Incidents
    with TableInfo<$IncidentsTable, IncidentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IncidentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gardenIdMeta = const VerificationMeta(
    'gardenId',
  );
  @override
  late final GeneratedColumn<String> gardenId = GeneratedColumn<String>(
    'garden_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES gardens (id)',
    ),
  );
  static const VerificationMeta _zoneIdMeta = const VerificationMeta('zoneId');
  @override
  late final GeneratedColumn<String> zoneId = GeneratedColumn<String>(
    'zone_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES zones (id)',
    ),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('user'),
  );
  static const VerificationMeta _candidatesMeta = const VerificationMeta(
    'candidates',
  );
  @override
  late final GeneratedColumn<String> candidates = GeneratedColumn<String>(
    'candidates',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _planBioMeta = const VerificationMeta(
    'planBio',
  );
  @override
  late final GeneratedColumn<String> planBio = GeneratedColumn<String>(
    'plan_bio',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _planChemMeta = const VerificationMeta(
    'planChem',
  );
  @override
  late final GeneratedColumn<String> planChem = GeneratedColumn<String>(
    'plan_chem',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('open'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    gardenId,
    zoneId,
    label,
    source,
    candidates,
    planBio,
    planChem,
    status,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'incidents';
  @override
  VerificationContext validateIntegrity(
    Insertable<IncidentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('garden_id')) {
      context.handle(
        _gardenIdMeta,
        gardenId.isAcceptableOrUnknown(data['garden_id']!, _gardenIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gardenIdMeta);
    }
    if (data.containsKey('zone_id')) {
      context.handle(
        _zoneIdMeta,
        zoneId.isAcceptableOrUnknown(data['zone_id']!, _zoneIdMeta),
      );
    } else if (isInserting) {
      context.missing(_zoneIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('candidates')) {
      context.handle(
        _candidatesMeta,
        candidates.isAcceptableOrUnknown(data['candidates']!, _candidatesMeta),
      );
    }
    if (data.containsKey('plan_bio')) {
      context.handle(
        _planBioMeta,
        planBio.isAcceptableOrUnknown(data['plan_bio']!, _planBioMeta),
      );
    }
    if (data.containsKey('plan_chem')) {
      context.handle(
        _planChemMeta,
        planChem.isAcceptableOrUnknown(data['plan_chem']!, _planChemMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IncidentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IncidentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      gardenId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}garden_id'],
      )!,
      zoneId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}zone_id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      candidates: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}candidates'],
      ),
      planBio: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan_bio'],
      ),
      planChem: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan_chem'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $IncidentsTable createAlias(String alias) {
    return $IncidentsTable(attachedDatabase, alias);
  }
}

class IncidentRow extends DataClass implements Insertable<IncidentRow> {
  final String id;
  final String gardenId;
  final String zoneId;

  /// Co se děje („mšice na rybízu“).
  final String label;

  /// `user` (založeno ručně) nebo `model` (z diagnostiky fotky).
  final String source;

  /// Možné příčiny z diagnostiky jako JSON (FR-V2).
  final String? candidates;
  final String? planBio;
  final String? planChem;

  /// `open` nebo `resolved`.
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const IncidentRow({
    required this.id,
    required this.gardenId,
    required this.zoneId,
    required this.label,
    required this.source,
    this.candidates,
    this.planBio,
    this.planChem,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['garden_id'] = Variable<String>(gardenId);
    map['zone_id'] = Variable<String>(zoneId);
    map['label'] = Variable<String>(label);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || candidates != null) {
      map['candidates'] = Variable<String>(candidates);
    }
    if (!nullToAbsent || planBio != null) {
      map['plan_bio'] = Variable<String>(planBio);
    }
    if (!nullToAbsent || planChem != null) {
      map['plan_chem'] = Variable<String>(planChem);
    }
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  IncidentsCompanion toCompanion(bool nullToAbsent) {
    return IncidentsCompanion(
      id: Value(id),
      gardenId: Value(gardenId),
      zoneId: Value(zoneId),
      label: Value(label),
      source: Value(source),
      candidates: candidates == null && nullToAbsent
          ? const Value.absent()
          : Value(candidates),
      planBio: planBio == null && nullToAbsent
          ? const Value.absent()
          : Value(planBio),
      planChem: planChem == null && nullToAbsent
          ? const Value.absent()
          : Value(planChem),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory IncidentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IncidentRow(
      id: serializer.fromJson<String>(json['id']),
      gardenId: serializer.fromJson<String>(json['gardenId']),
      zoneId: serializer.fromJson<String>(json['zoneId']),
      label: serializer.fromJson<String>(json['label']),
      source: serializer.fromJson<String>(json['source']),
      candidates: serializer.fromJson<String?>(json['candidates']),
      planBio: serializer.fromJson<String?>(json['planBio']),
      planChem: serializer.fromJson<String?>(json['planChem']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'gardenId': serializer.toJson<String>(gardenId),
      'zoneId': serializer.toJson<String>(zoneId),
      'label': serializer.toJson<String>(label),
      'source': serializer.toJson<String>(source),
      'candidates': serializer.toJson<String?>(candidates),
      'planBio': serializer.toJson<String?>(planBio),
      'planChem': serializer.toJson<String?>(planChem),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  IncidentRow copyWith({
    String? id,
    String? gardenId,
    String? zoneId,
    String? label,
    String? source,
    Value<String?> candidates = const Value.absent(),
    Value<String?> planBio = const Value.absent(),
    Value<String?> planChem = const Value.absent(),
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => IncidentRow(
    id: id ?? this.id,
    gardenId: gardenId ?? this.gardenId,
    zoneId: zoneId ?? this.zoneId,
    label: label ?? this.label,
    source: source ?? this.source,
    candidates: candidates.present ? candidates.value : this.candidates,
    planBio: planBio.present ? planBio.value : this.planBio,
    planChem: planChem.present ? planChem.value : this.planChem,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  IncidentRow copyWithCompanion(IncidentsCompanion data) {
    return IncidentRow(
      id: data.id.present ? data.id.value : this.id,
      gardenId: data.gardenId.present ? data.gardenId.value : this.gardenId,
      zoneId: data.zoneId.present ? data.zoneId.value : this.zoneId,
      label: data.label.present ? data.label.value : this.label,
      source: data.source.present ? data.source.value : this.source,
      candidates: data.candidates.present
          ? data.candidates.value
          : this.candidates,
      planBio: data.planBio.present ? data.planBio.value : this.planBio,
      planChem: data.planChem.present ? data.planChem.value : this.planChem,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IncidentRow(')
          ..write('id: $id, ')
          ..write('gardenId: $gardenId, ')
          ..write('zoneId: $zoneId, ')
          ..write('label: $label, ')
          ..write('source: $source, ')
          ..write('candidates: $candidates, ')
          ..write('planBio: $planBio, ')
          ..write('planChem: $planChem, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    gardenId,
    zoneId,
    label,
    source,
    candidates,
    planBio,
    planChem,
    status,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IncidentRow &&
          other.id == this.id &&
          other.gardenId == this.gardenId &&
          other.zoneId == this.zoneId &&
          other.label == this.label &&
          other.source == this.source &&
          other.candidates == this.candidates &&
          other.planBio == this.planBio &&
          other.planChem == this.planChem &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class IncidentsCompanion extends UpdateCompanion<IncidentRow> {
  final Value<String> id;
  final Value<String> gardenId;
  final Value<String> zoneId;
  final Value<String> label;
  final Value<String> source;
  final Value<String?> candidates;
  final Value<String?> planBio;
  final Value<String?> planChem;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const IncidentsCompanion({
    this.id = const Value.absent(),
    this.gardenId = const Value.absent(),
    this.zoneId = const Value.absent(),
    this.label = const Value.absent(),
    this.source = const Value.absent(),
    this.candidates = const Value.absent(),
    this.planBio = const Value.absent(),
    this.planChem = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IncidentsCompanion.insert({
    required String id,
    required String gardenId,
    required String zoneId,
    required String label,
    this.source = const Value.absent(),
    this.candidates = const Value.absent(),
    this.planBio = const Value.absent(),
    this.planChem = const Value.absent(),
    this.status = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       gardenId = Value(gardenId),
       zoneId = Value(zoneId),
       label = Value(label),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<IncidentRow> custom({
    Expression<String>? id,
    Expression<String>? gardenId,
    Expression<String>? zoneId,
    Expression<String>? label,
    Expression<String>? source,
    Expression<String>? candidates,
    Expression<String>? planBio,
    Expression<String>? planChem,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gardenId != null) 'garden_id': gardenId,
      if (zoneId != null) 'zone_id': zoneId,
      if (label != null) 'label': label,
      if (source != null) 'source': source,
      if (candidates != null) 'candidates': candidates,
      if (planBio != null) 'plan_bio': planBio,
      if (planChem != null) 'plan_chem': planChem,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IncidentsCompanion copyWith({
    Value<String>? id,
    Value<String>? gardenId,
    Value<String>? zoneId,
    Value<String>? label,
    Value<String>? source,
    Value<String?>? candidates,
    Value<String?>? planBio,
    Value<String?>? planChem,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return IncidentsCompanion(
      id: id ?? this.id,
      gardenId: gardenId ?? this.gardenId,
      zoneId: zoneId ?? this.zoneId,
      label: label ?? this.label,
      source: source ?? this.source,
      candidates: candidates ?? this.candidates,
      planBio: planBio ?? this.planBio,
      planChem: planChem ?? this.planChem,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (gardenId.present) {
      map['garden_id'] = Variable<String>(gardenId.value);
    }
    if (zoneId.present) {
      map['zone_id'] = Variable<String>(zoneId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (candidates.present) {
      map['candidates'] = Variable<String>(candidates.value);
    }
    if (planBio.present) {
      map['plan_bio'] = Variable<String>(planBio.value);
    }
    if (planChem.present) {
      map['plan_chem'] = Variable<String>(planChem.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IncidentsCompanion(')
          ..write('id: $id, ')
          ..write('gardenId: $gardenId, ')
          ..write('zoneId: $zoneId, ')
          ..write('label: $label, ')
          ..write('source: $source, ')
          ..write('candidates: $candidates, ')
          ..write('planBio: $planBio, ')
          ..write('planChem: $planChem, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TasksTable extends Tasks with TableInfo<$TasksTable, TaskRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gardenIdMeta = const VerificationMeta(
    'gardenId',
  );
  @override
  late final GeneratedColumn<String> gardenId = GeneratedColumn<String>(
    'garden_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES gardens (id)',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _zoneIdMeta = const VerificationMeta('zoneId');
  @override
  late final GeneratedColumn<String> zoneId = GeneratedColumn<String>(
    'zone_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES zones (id)',
    ),
  );
  static const VerificationMeta _dueMeta = const VerificationMeta('due');
  @override
  late final GeneratedColumn<String> due = GeneratedColumn<String>(
    'due',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remindAtMeta = const VerificationMeta(
    'remindAt',
  );
  @override
  late final GeneratedColumn<int> remindAt = GeneratedColumn<int>(
    'remind_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rruleMeta = const VerificationMeta('rrule');
  @override
  late final GeneratedColumn<String> rrule = GeneratedColumn<String>(
    'rrule',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _snoozedUntilMeta = const VerificationMeta(
    'snoozedUntil',
  );
  @override
  late final GeneratedColumn<String> snoozedUntil = GeneratedColumn<String>(
    'snoozed_until',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('open'),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedActivityIdMeta =
      const VerificationMeta('completedActivityId');
  @override
  late final GeneratedColumn<String> completedActivityId =
      GeneratedColumn<String>(
        'completed_activity_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('user'),
  );
  static const VerificationMeta _durationEstMinMeta = const VerificationMeta(
    'durationEstMin',
  );
  @override
  late final GeneratedColumn<int> durationEstMin = GeneratedColumn<int>(
    'duration_est_min',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _toolsMeta = const VerificationMeta('tools');
  @override
  late final GeneratedColumn<String> tools = GeneratedColumn<String>(
    'tools',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _incidentIdMeta = const VerificationMeta(
    'incidentId',
  );
  @override
  late final GeneratedColumn<String> incidentId = GeneratedColumn<String>(
    'incident_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES incidents (id)',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    gardenId,
    title,
    zoneId,
    due,
    remindAt,
    rrule,
    snoozedUntil,
    status,
    notes,
    completedAt,
    completedActivityId,
    source,
    durationEstMin,
    tools,
    incidentId,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('garden_id')) {
      context.handle(
        _gardenIdMeta,
        gardenId.isAcceptableOrUnknown(data['garden_id']!, _gardenIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gardenIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('zone_id')) {
      context.handle(
        _zoneIdMeta,
        zoneId.isAcceptableOrUnknown(data['zone_id']!, _zoneIdMeta),
      );
    }
    if (data.containsKey('due')) {
      context.handle(
        _dueMeta,
        due.isAcceptableOrUnknown(data['due']!, _dueMeta),
      );
    } else if (isInserting) {
      context.missing(_dueMeta);
    }
    if (data.containsKey('remind_at')) {
      context.handle(
        _remindAtMeta,
        remindAt.isAcceptableOrUnknown(data['remind_at']!, _remindAtMeta),
      );
    }
    if (data.containsKey('rrule')) {
      context.handle(
        _rruleMeta,
        rrule.isAcceptableOrUnknown(data['rrule']!, _rruleMeta),
      );
    }
    if (data.containsKey('snoozed_until')) {
      context.handle(
        _snoozedUntilMeta,
        snoozedUntil.isAcceptableOrUnknown(
          data['snoozed_until']!,
          _snoozedUntilMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('completed_activity_id')) {
      context.handle(
        _completedActivityIdMeta,
        completedActivityId.isAcceptableOrUnknown(
          data['completed_activity_id']!,
          _completedActivityIdMeta,
        ),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('duration_est_min')) {
      context.handle(
        _durationEstMinMeta,
        durationEstMin.isAcceptableOrUnknown(
          data['duration_est_min']!,
          _durationEstMinMeta,
        ),
      );
    }
    if (data.containsKey('tools')) {
      context.handle(
        _toolsMeta,
        tools.isAcceptableOrUnknown(data['tools']!, _toolsMeta),
      );
    }
    if (data.containsKey('incident_id')) {
      context.handle(
        _incidentIdMeta,
        incidentId.isAcceptableOrUnknown(data['incident_id']!, _incidentIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      gardenId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}garden_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      zoneId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}zone_id'],
      ),
      due: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}due'],
      )!,
      remindAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remind_at'],
      ),
      rrule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rrule'],
      ),
      snoozedUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}snoozed_until'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      completedActivityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}completed_activity_id'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      durationEstMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_est_min'],
      ),
      tools: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tools'],
      ),
      incidentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}incident_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class TaskRow extends DataClass implements Insertable<TaskRow> {
  final String id;
  final String gardenId;
  final String title;
  final String? zoneId;

  /// Den termínu `YYYY-MM-DD` (v PostgreSQL typ `date`).
  final String due;

  /// Čas připomínky v den termínu v minutách od půlnoci.
  final int? remindAt;
  final String? rrule;
  final String? snoozedUntil;
  final String status;
  final String? notes;
  final DateTime? completedAt;
  final String? completedActivityId;
  final String source;

  /// Odhad doby v minutách (FR-U7, schéma v2).
  final int? durationEstMin;

  /// Nářadí jako JSON pole textů (v PostgreSQL `text[]`).
  final String? tools;

  /// Kontrola incidentu D+3 / D+7 (V2, schéma 6).
  final String? incidentId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const TaskRow({
    required this.id,
    required this.gardenId,
    required this.title,
    this.zoneId,
    required this.due,
    this.remindAt,
    this.rrule,
    this.snoozedUntil,
    required this.status,
    this.notes,
    this.completedAt,
    this.completedActivityId,
    required this.source,
    this.durationEstMin,
    this.tools,
    this.incidentId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['garden_id'] = Variable<String>(gardenId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || zoneId != null) {
      map['zone_id'] = Variable<String>(zoneId);
    }
    map['due'] = Variable<String>(due);
    if (!nullToAbsent || remindAt != null) {
      map['remind_at'] = Variable<int>(remindAt);
    }
    if (!nullToAbsent || rrule != null) {
      map['rrule'] = Variable<String>(rrule);
    }
    if (!nullToAbsent || snoozedUntil != null) {
      map['snoozed_until'] = Variable<String>(snoozedUntil);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || completedActivityId != null) {
      map['completed_activity_id'] = Variable<String>(completedActivityId);
    }
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || durationEstMin != null) {
      map['duration_est_min'] = Variable<int>(durationEstMin);
    }
    if (!nullToAbsent || tools != null) {
      map['tools'] = Variable<String>(tools);
    }
    if (!nullToAbsent || incidentId != null) {
      map['incident_id'] = Variable<String>(incidentId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      gardenId: Value(gardenId),
      title: Value(title),
      zoneId: zoneId == null && nullToAbsent
          ? const Value.absent()
          : Value(zoneId),
      due: Value(due),
      remindAt: remindAt == null && nullToAbsent
          ? const Value.absent()
          : Value(remindAt),
      rrule: rrule == null && nullToAbsent
          ? const Value.absent()
          : Value(rrule),
      snoozedUntil: snoozedUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(snoozedUntil),
      status: Value(status),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      completedActivityId: completedActivityId == null && nullToAbsent
          ? const Value.absent()
          : Value(completedActivityId),
      source: Value(source),
      durationEstMin: durationEstMin == null && nullToAbsent
          ? const Value.absent()
          : Value(durationEstMin),
      tools: tools == null && nullToAbsent
          ? const Value.absent()
          : Value(tools),
      incidentId: incidentId == null && nullToAbsent
          ? const Value.absent()
          : Value(incidentId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory TaskRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskRow(
      id: serializer.fromJson<String>(json['id']),
      gardenId: serializer.fromJson<String>(json['gardenId']),
      title: serializer.fromJson<String>(json['title']),
      zoneId: serializer.fromJson<String?>(json['zoneId']),
      due: serializer.fromJson<String>(json['due']),
      remindAt: serializer.fromJson<int?>(json['remindAt']),
      rrule: serializer.fromJson<String?>(json['rrule']),
      snoozedUntil: serializer.fromJson<String?>(json['snoozedUntil']),
      status: serializer.fromJson<String>(json['status']),
      notes: serializer.fromJson<String?>(json['notes']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      completedActivityId: serializer.fromJson<String?>(
        json['completedActivityId'],
      ),
      source: serializer.fromJson<String>(json['source']),
      durationEstMin: serializer.fromJson<int?>(json['durationEstMin']),
      tools: serializer.fromJson<String?>(json['tools']),
      incidentId: serializer.fromJson<String?>(json['incidentId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'gardenId': serializer.toJson<String>(gardenId),
      'title': serializer.toJson<String>(title),
      'zoneId': serializer.toJson<String?>(zoneId),
      'due': serializer.toJson<String>(due),
      'remindAt': serializer.toJson<int?>(remindAt),
      'rrule': serializer.toJson<String?>(rrule),
      'snoozedUntil': serializer.toJson<String?>(snoozedUntil),
      'status': serializer.toJson<String>(status),
      'notes': serializer.toJson<String?>(notes),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'completedActivityId': serializer.toJson<String?>(completedActivityId),
      'source': serializer.toJson<String>(source),
      'durationEstMin': serializer.toJson<int?>(durationEstMin),
      'tools': serializer.toJson<String?>(tools),
      'incidentId': serializer.toJson<String?>(incidentId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  TaskRow copyWith({
    String? id,
    String? gardenId,
    String? title,
    Value<String?> zoneId = const Value.absent(),
    String? due,
    Value<int?> remindAt = const Value.absent(),
    Value<String?> rrule = const Value.absent(),
    Value<String?> snoozedUntil = const Value.absent(),
    String? status,
    Value<String?> notes = const Value.absent(),
    Value<DateTime?> completedAt = const Value.absent(),
    Value<String?> completedActivityId = const Value.absent(),
    String? source,
    Value<int?> durationEstMin = const Value.absent(),
    Value<String?> tools = const Value.absent(),
    Value<String?> incidentId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => TaskRow(
    id: id ?? this.id,
    gardenId: gardenId ?? this.gardenId,
    title: title ?? this.title,
    zoneId: zoneId.present ? zoneId.value : this.zoneId,
    due: due ?? this.due,
    remindAt: remindAt.present ? remindAt.value : this.remindAt,
    rrule: rrule.present ? rrule.value : this.rrule,
    snoozedUntil: snoozedUntil.present ? snoozedUntil.value : this.snoozedUntil,
    status: status ?? this.status,
    notes: notes.present ? notes.value : this.notes,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    completedActivityId: completedActivityId.present
        ? completedActivityId.value
        : this.completedActivityId,
    source: source ?? this.source,
    durationEstMin: durationEstMin.present
        ? durationEstMin.value
        : this.durationEstMin,
    tools: tools.present ? tools.value : this.tools,
    incidentId: incidentId.present ? incidentId.value : this.incidentId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  TaskRow copyWithCompanion(TasksCompanion data) {
    return TaskRow(
      id: data.id.present ? data.id.value : this.id,
      gardenId: data.gardenId.present ? data.gardenId.value : this.gardenId,
      title: data.title.present ? data.title.value : this.title,
      zoneId: data.zoneId.present ? data.zoneId.value : this.zoneId,
      due: data.due.present ? data.due.value : this.due,
      remindAt: data.remindAt.present ? data.remindAt.value : this.remindAt,
      rrule: data.rrule.present ? data.rrule.value : this.rrule,
      snoozedUntil: data.snoozedUntil.present
          ? data.snoozedUntil.value
          : this.snoozedUntil,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      completedActivityId: data.completedActivityId.present
          ? data.completedActivityId.value
          : this.completedActivityId,
      source: data.source.present ? data.source.value : this.source,
      durationEstMin: data.durationEstMin.present
          ? data.durationEstMin.value
          : this.durationEstMin,
      tools: data.tools.present ? data.tools.value : this.tools,
      incidentId: data.incidentId.present
          ? data.incidentId.value
          : this.incidentId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskRow(')
          ..write('id: $id, ')
          ..write('gardenId: $gardenId, ')
          ..write('title: $title, ')
          ..write('zoneId: $zoneId, ')
          ..write('due: $due, ')
          ..write('remindAt: $remindAt, ')
          ..write('rrule: $rrule, ')
          ..write('snoozedUntil: $snoozedUntil, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('completedAt: $completedAt, ')
          ..write('completedActivityId: $completedActivityId, ')
          ..write('source: $source, ')
          ..write('durationEstMin: $durationEstMin, ')
          ..write('tools: $tools, ')
          ..write('incidentId: $incidentId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    gardenId,
    title,
    zoneId,
    due,
    remindAt,
    rrule,
    snoozedUntil,
    status,
    notes,
    completedAt,
    completedActivityId,
    source,
    durationEstMin,
    tools,
    incidentId,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskRow &&
          other.id == this.id &&
          other.gardenId == this.gardenId &&
          other.title == this.title &&
          other.zoneId == this.zoneId &&
          other.due == this.due &&
          other.remindAt == this.remindAt &&
          other.rrule == this.rrule &&
          other.snoozedUntil == this.snoozedUntil &&
          other.status == this.status &&
          other.notes == this.notes &&
          other.completedAt == this.completedAt &&
          other.completedActivityId == this.completedActivityId &&
          other.source == this.source &&
          other.durationEstMin == this.durationEstMin &&
          other.tools == this.tools &&
          other.incidentId == this.incidentId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class TasksCompanion extends UpdateCompanion<TaskRow> {
  final Value<String> id;
  final Value<String> gardenId;
  final Value<String> title;
  final Value<String?> zoneId;
  final Value<String> due;
  final Value<int?> remindAt;
  final Value<String?> rrule;
  final Value<String?> snoozedUntil;
  final Value<String> status;
  final Value<String?> notes;
  final Value<DateTime?> completedAt;
  final Value<String?> completedActivityId;
  final Value<String> source;
  final Value<int?> durationEstMin;
  final Value<String?> tools;
  final Value<String?> incidentId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.gardenId = const Value.absent(),
    this.title = const Value.absent(),
    this.zoneId = const Value.absent(),
    this.due = const Value.absent(),
    this.remindAt = const Value.absent(),
    this.rrule = const Value.absent(),
    this.snoozedUntil = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.completedActivityId = const Value.absent(),
    this.source = const Value.absent(),
    this.durationEstMin = const Value.absent(),
    this.tools = const Value.absent(),
    this.incidentId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TasksCompanion.insert({
    required String id,
    required String gardenId,
    required String title,
    this.zoneId = const Value.absent(),
    required String due,
    this.remindAt = const Value.absent(),
    this.rrule = const Value.absent(),
    this.snoozedUntil = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.completedActivityId = const Value.absent(),
    this.source = const Value.absent(),
    this.durationEstMin = const Value.absent(),
    this.tools = const Value.absent(),
    this.incidentId = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       gardenId = Value(gardenId),
       title = Value(title),
       due = Value(due),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<TaskRow> custom({
    Expression<String>? id,
    Expression<String>? gardenId,
    Expression<String>? title,
    Expression<String>? zoneId,
    Expression<String>? due,
    Expression<int>? remindAt,
    Expression<String>? rrule,
    Expression<String>? snoozedUntil,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<DateTime>? completedAt,
    Expression<String>? completedActivityId,
    Expression<String>? source,
    Expression<int>? durationEstMin,
    Expression<String>? tools,
    Expression<String>? incidentId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gardenId != null) 'garden_id': gardenId,
      if (title != null) 'title': title,
      if (zoneId != null) 'zone_id': zoneId,
      if (due != null) 'due': due,
      if (remindAt != null) 'remind_at': remindAt,
      if (rrule != null) 'rrule': rrule,
      if (snoozedUntil != null) 'snoozed_until': snoozedUntil,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (completedAt != null) 'completed_at': completedAt,
      if (completedActivityId != null)
        'completed_activity_id': completedActivityId,
      if (source != null) 'source': source,
      if (durationEstMin != null) 'duration_est_min': durationEstMin,
      if (tools != null) 'tools': tools,
      if (incidentId != null) 'incident_id': incidentId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TasksCompanion copyWith({
    Value<String>? id,
    Value<String>? gardenId,
    Value<String>? title,
    Value<String?>? zoneId,
    Value<String>? due,
    Value<int?>? remindAt,
    Value<String?>? rrule,
    Value<String?>? snoozedUntil,
    Value<String>? status,
    Value<String?>? notes,
    Value<DateTime?>? completedAt,
    Value<String?>? completedActivityId,
    Value<String>? source,
    Value<int?>? durationEstMin,
    Value<String?>? tools,
    Value<String?>? incidentId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return TasksCompanion(
      id: id ?? this.id,
      gardenId: gardenId ?? this.gardenId,
      title: title ?? this.title,
      zoneId: zoneId ?? this.zoneId,
      due: due ?? this.due,
      remindAt: remindAt ?? this.remindAt,
      rrule: rrule ?? this.rrule,
      snoozedUntil: snoozedUntil ?? this.snoozedUntil,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      completedAt: completedAt ?? this.completedAt,
      completedActivityId: completedActivityId ?? this.completedActivityId,
      source: source ?? this.source,
      durationEstMin: durationEstMin ?? this.durationEstMin,
      tools: tools ?? this.tools,
      incidentId: incidentId ?? this.incidentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (gardenId.present) {
      map['garden_id'] = Variable<String>(gardenId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (zoneId.present) {
      map['zone_id'] = Variable<String>(zoneId.value);
    }
    if (due.present) {
      map['due'] = Variable<String>(due.value);
    }
    if (remindAt.present) {
      map['remind_at'] = Variable<int>(remindAt.value);
    }
    if (rrule.present) {
      map['rrule'] = Variable<String>(rrule.value);
    }
    if (snoozedUntil.present) {
      map['snoozed_until'] = Variable<String>(snoozedUntil.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (completedActivityId.present) {
      map['completed_activity_id'] = Variable<String>(
        completedActivityId.value,
      );
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (durationEstMin.present) {
      map['duration_est_min'] = Variable<int>(durationEstMin.value);
    }
    if (tools.present) {
      map['tools'] = Variable<String>(tools.value);
    }
    if (incidentId.present) {
      map['incident_id'] = Variable<String>(incidentId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('gardenId: $gardenId, ')
          ..write('title: $title, ')
          ..write('zoneId: $zoneId, ')
          ..write('due: $due, ')
          ..write('remindAt: $remindAt, ')
          ..write('rrule: $rrule, ')
          ..write('snoozedUntil: $snoozedUntil, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('completedAt: $completedAt, ')
          ..write('completedActivityId: $completedActivityId, ')
          ..write('source: $source, ')
          ..write('durationEstMin: $durationEstMin, ')
          ..write('tools: $tools, ')
          ..write('incidentId: $incidentId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActivitiesTable extends Activities
    with TableInfo<$ActivitiesTable, ActivityRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gardenIdMeta = const VerificationMeta(
    'gardenId',
  );
  @override
  late final GeneratedColumn<String> gardenId = GeneratedColumn<String>(
    'garden_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES gardens (id)',
    ),
  );
  static const VerificationMeta _zoneIdMeta = const VerificationMeta('zoneId');
  @override
  late final GeneratedColumn<String> zoneId = GeneratedColumn<String>(
    'zone_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES zones (id)',
    ),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredTzMeta = const VerificationMeta(
    'occurredTz',
  );
  @override
  late final GeneratedColumn<String> occurredTz = GeneratedColumn<String>(
    'occurred_tz',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _harvestQtyMeta = const VerificationMeta(
    'harvestQty',
  );
  @override
  late final GeneratedColumn<double> harvestQty = GeneratedColumn<double>(
    'harvest_qty',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _harvestUnitMeta = const VerificationMeta(
    'harvestUnit',
  );
  @override
  late final GeneratedColumn<String> harvestUnit = GeneratedColumn<String>(
    'harvest_unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _costCzkMeta = const VerificationMeta(
    'costCzk',
  );
  @override
  late final GeneratedColumn<double> costCzk = GeneratedColumn<double>(
    'cost_czk',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    gardenId,
    zoneId,
    type,
    title,
    occurredAt,
    occurredTz,
    notes,
    harvestQty,
    harvestUnit,
    costCzk,
    taskId,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activities';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActivityRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('garden_id')) {
      context.handle(
        _gardenIdMeta,
        gardenId.isAcceptableOrUnknown(data['garden_id']!, _gardenIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gardenIdMeta);
    }
    if (data.containsKey('zone_id')) {
      context.handle(
        _zoneIdMeta,
        zoneId.isAcceptableOrUnknown(data['zone_id']!, _zoneIdMeta),
      );
    } else if (isInserting) {
      context.missing(_zoneIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('occurred_tz')) {
      context.handle(
        _occurredTzMeta,
        occurredTz.isAcceptableOrUnknown(data['occurred_tz']!, _occurredTzMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredTzMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('harvest_qty')) {
      context.handle(
        _harvestQtyMeta,
        harvestQty.isAcceptableOrUnknown(data['harvest_qty']!, _harvestQtyMeta),
      );
    }
    if (data.containsKey('harvest_unit')) {
      context.handle(
        _harvestUnitMeta,
        harvestUnit.isAcceptableOrUnknown(
          data['harvest_unit']!,
          _harvestUnitMeta,
        ),
      );
    }
    if (data.containsKey('cost_czk')) {
      context.handle(
        _costCzkMeta,
        costCzk.isAcceptableOrUnknown(data['cost_czk']!, _costCzkMeta),
      );
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActivityRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivityRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      gardenId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}garden_id'],
      )!,
      zoneId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}zone_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      occurredTz: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}occurred_tz'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      harvestQty: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}harvest_qty'],
      ),
      harvestUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}harvest_unit'],
      ),
      costCzk: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cost_czk'],
      ),
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $ActivitiesTable createAlias(String alias) {
    return $ActivitiesTable(attachedDatabase, alias);
  }
}

class ActivityRow extends DataClass implements Insertable<ActivityRow> {
  final String id;
  final String gardenId;
  final String zoneId;

  /// Číselník `activity.type` (kap. 8.3).
  final String type;
  final String title;
  final DateTime occurredAt;

  /// Posun časové zóny v době činnosti, např. `+02:00` (kap. 7.3).
  final String occurredTz;
  final String? notes;
  final double? harvestQty;
  final String? harvestUnit;
  final double? costCzk;
  final String? taskId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const ActivityRow({
    required this.id,
    required this.gardenId,
    required this.zoneId,
    required this.type,
    required this.title,
    required this.occurredAt,
    required this.occurredTz,
    this.notes,
    this.harvestQty,
    this.harvestUnit,
    this.costCzk,
    this.taskId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['garden_id'] = Variable<String>(gardenId);
    map['zone_id'] = Variable<String>(zoneId);
    map['type'] = Variable<String>(type);
    map['title'] = Variable<String>(title);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    map['occurred_tz'] = Variable<String>(occurredTz);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || harvestQty != null) {
      map['harvest_qty'] = Variable<double>(harvestQty);
    }
    if (!nullToAbsent || harvestUnit != null) {
      map['harvest_unit'] = Variable<String>(harvestUnit);
    }
    if (!nullToAbsent || costCzk != null) {
      map['cost_czk'] = Variable<double>(costCzk);
    }
    if (!nullToAbsent || taskId != null) {
      map['task_id'] = Variable<String>(taskId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  ActivitiesCompanion toCompanion(bool nullToAbsent) {
    return ActivitiesCompanion(
      id: Value(id),
      gardenId: Value(gardenId),
      zoneId: Value(zoneId),
      type: Value(type),
      title: Value(title),
      occurredAt: Value(occurredAt),
      occurredTz: Value(occurredTz),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      harvestQty: harvestQty == null && nullToAbsent
          ? const Value.absent()
          : Value(harvestQty),
      harvestUnit: harvestUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(harvestUnit),
      costCzk: costCzk == null && nullToAbsent
          ? const Value.absent()
          : Value(costCzk),
      taskId: taskId == null && nullToAbsent
          ? const Value.absent()
          : Value(taskId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory ActivityRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivityRow(
      id: serializer.fromJson<String>(json['id']),
      gardenId: serializer.fromJson<String>(json['gardenId']),
      zoneId: serializer.fromJson<String>(json['zoneId']),
      type: serializer.fromJson<String>(json['type']),
      title: serializer.fromJson<String>(json['title']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      occurredTz: serializer.fromJson<String>(json['occurredTz']),
      notes: serializer.fromJson<String?>(json['notes']),
      harvestQty: serializer.fromJson<double?>(json['harvestQty']),
      harvestUnit: serializer.fromJson<String?>(json['harvestUnit']),
      costCzk: serializer.fromJson<double?>(json['costCzk']),
      taskId: serializer.fromJson<String?>(json['taskId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'gardenId': serializer.toJson<String>(gardenId),
      'zoneId': serializer.toJson<String>(zoneId),
      'type': serializer.toJson<String>(type),
      'title': serializer.toJson<String>(title),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'occurredTz': serializer.toJson<String>(occurredTz),
      'notes': serializer.toJson<String?>(notes),
      'harvestQty': serializer.toJson<double?>(harvestQty),
      'harvestUnit': serializer.toJson<String?>(harvestUnit),
      'costCzk': serializer.toJson<double?>(costCzk),
      'taskId': serializer.toJson<String?>(taskId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  ActivityRow copyWith({
    String? id,
    String? gardenId,
    String? zoneId,
    String? type,
    String? title,
    DateTime? occurredAt,
    String? occurredTz,
    Value<String?> notes = const Value.absent(),
    Value<double?> harvestQty = const Value.absent(),
    Value<String?> harvestUnit = const Value.absent(),
    Value<double?> costCzk = const Value.absent(),
    Value<String?> taskId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => ActivityRow(
    id: id ?? this.id,
    gardenId: gardenId ?? this.gardenId,
    zoneId: zoneId ?? this.zoneId,
    type: type ?? this.type,
    title: title ?? this.title,
    occurredAt: occurredAt ?? this.occurredAt,
    occurredTz: occurredTz ?? this.occurredTz,
    notes: notes.present ? notes.value : this.notes,
    harvestQty: harvestQty.present ? harvestQty.value : this.harvestQty,
    harvestUnit: harvestUnit.present ? harvestUnit.value : this.harvestUnit,
    costCzk: costCzk.present ? costCzk.value : this.costCzk,
    taskId: taskId.present ? taskId.value : this.taskId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  ActivityRow copyWithCompanion(ActivitiesCompanion data) {
    return ActivityRow(
      id: data.id.present ? data.id.value : this.id,
      gardenId: data.gardenId.present ? data.gardenId.value : this.gardenId,
      zoneId: data.zoneId.present ? data.zoneId.value : this.zoneId,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      occurredTz: data.occurredTz.present
          ? data.occurredTz.value
          : this.occurredTz,
      notes: data.notes.present ? data.notes.value : this.notes,
      harvestQty: data.harvestQty.present
          ? data.harvestQty.value
          : this.harvestQty,
      harvestUnit: data.harvestUnit.present
          ? data.harvestUnit.value
          : this.harvestUnit,
      costCzk: data.costCzk.present ? data.costCzk.value : this.costCzk,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivityRow(')
          ..write('id: $id, ')
          ..write('gardenId: $gardenId, ')
          ..write('zoneId: $zoneId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('occurredTz: $occurredTz, ')
          ..write('notes: $notes, ')
          ..write('harvestQty: $harvestQty, ')
          ..write('harvestUnit: $harvestUnit, ')
          ..write('costCzk: $costCzk, ')
          ..write('taskId: $taskId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    gardenId,
    zoneId,
    type,
    title,
    occurredAt,
    occurredTz,
    notes,
    harvestQty,
    harvestUnit,
    costCzk,
    taskId,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivityRow &&
          other.id == this.id &&
          other.gardenId == this.gardenId &&
          other.zoneId == this.zoneId &&
          other.type == this.type &&
          other.title == this.title &&
          other.occurredAt == this.occurredAt &&
          other.occurredTz == this.occurredTz &&
          other.notes == this.notes &&
          other.harvestQty == this.harvestQty &&
          other.harvestUnit == this.harvestUnit &&
          other.costCzk == this.costCzk &&
          other.taskId == this.taskId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class ActivitiesCompanion extends UpdateCompanion<ActivityRow> {
  final Value<String> id;
  final Value<String> gardenId;
  final Value<String> zoneId;
  final Value<String> type;
  final Value<String> title;
  final Value<DateTime> occurredAt;
  final Value<String> occurredTz;
  final Value<String?> notes;
  final Value<double?> harvestQty;
  final Value<String?> harvestUnit;
  final Value<double?> costCzk;
  final Value<String?> taskId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const ActivitiesCompanion({
    this.id = const Value.absent(),
    this.gardenId = const Value.absent(),
    this.zoneId = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.occurredTz = const Value.absent(),
    this.notes = const Value.absent(),
    this.harvestQty = const Value.absent(),
    this.harvestUnit = const Value.absent(),
    this.costCzk = const Value.absent(),
    this.taskId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActivitiesCompanion.insert({
    required String id,
    required String gardenId,
    required String zoneId,
    required String type,
    required String title,
    required DateTime occurredAt,
    required String occurredTz,
    this.notes = const Value.absent(),
    this.harvestQty = const Value.absent(),
    this.harvestUnit = const Value.absent(),
    this.costCzk = const Value.absent(),
    this.taskId = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       gardenId = Value(gardenId),
       zoneId = Value(zoneId),
       type = Value(type),
       title = Value(title),
       occurredAt = Value(occurredAt),
       occurredTz = Value(occurredTz),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ActivityRow> custom({
    Expression<String>? id,
    Expression<String>? gardenId,
    Expression<String>? zoneId,
    Expression<String>? type,
    Expression<String>? title,
    Expression<DateTime>? occurredAt,
    Expression<String>? occurredTz,
    Expression<String>? notes,
    Expression<double>? harvestQty,
    Expression<String>? harvestUnit,
    Expression<double>? costCzk,
    Expression<String>? taskId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gardenId != null) 'garden_id': gardenId,
      if (zoneId != null) 'zone_id': zoneId,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (occurredTz != null) 'occurred_tz': occurredTz,
      if (notes != null) 'notes': notes,
      if (harvestQty != null) 'harvest_qty': harvestQty,
      if (harvestUnit != null) 'harvest_unit': harvestUnit,
      if (costCzk != null) 'cost_czk': costCzk,
      if (taskId != null) 'task_id': taskId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActivitiesCompanion copyWith({
    Value<String>? id,
    Value<String>? gardenId,
    Value<String>? zoneId,
    Value<String>? type,
    Value<String>? title,
    Value<DateTime>? occurredAt,
    Value<String>? occurredTz,
    Value<String?>? notes,
    Value<double?>? harvestQty,
    Value<String?>? harvestUnit,
    Value<double?>? costCzk,
    Value<String?>? taskId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return ActivitiesCompanion(
      id: id ?? this.id,
      gardenId: gardenId ?? this.gardenId,
      zoneId: zoneId ?? this.zoneId,
      type: type ?? this.type,
      title: title ?? this.title,
      occurredAt: occurredAt ?? this.occurredAt,
      occurredTz: occurredTz ?? this.occurredTz,
      notes: notes ?? this.notes,
      harvestQty: harvestQty ?? this.harvestQty,
      harvestUnit: harvestUnit ?? this.harvestUnit,
      costCzk: costCzk ?? this.costCzk,
      taskId: taskId ?? this.taskId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (gardenId.present) {
      map['garden_id'] = Variable<String>(gardenId.value);
    }
    if (zoneId.present) {
      map['zone_id'] = Variable<String>(zoneId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (occurredTz.present) {
      map['occurred_tz'] = Variable<String>(occurredTz.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (harvestQty.present) {
      map['harvest_qty'] = Variable<double>(harvestQty.value);
    }
    if (harvestUnit.present) {
      map['harvest_unit'] = Variable<String>(harvestUnit.value);
    }
    if (costCzk.present) {
      map['cost_czk'] = Variable<double>(costCzk.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivitiesCompanion(')
          ..write('id: $id, ')
          ..write('gardenId: $gardenId, ')
          ..write('zoneId: $zoneId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('occurredTz: $occurredTz, ')
          ..write('notes: $notes, ')
          ..write('harvestQty: $harvestQty, ')
          ..write('harvestUnit: $harvestUnit, ')
          ..write('costCzk: $costCzk, ')
          ..write('taskId: $taskId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PhotosTable extends Photos with TableInfo<$PhotosTable, PhotoRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PhotosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gardenIdMeta = const VerificationMeta(
    'gardenId',
  );
  @override
  late final GeneratedColumn<String> gardenId = GeneratedColumn<String>(
    'garden_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES gardens (id)',
    ),
  );
  static const VerificationMeta _activityIdMeta = const VerificationMeta(
    'activityId',
  );
  @override
  late final GeneratedColumn<String> activityId = GeneratedColumn<String>(
    'activity_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES activities (id)',
    ),
  );
  static const VerificationMeta _incidentIdMeta = const VerificationMeta(
    'incidentId',
  );
  @override
  late final GeneratedColumn<String> incidentId = GeneratedColumn<String>(
    'incident_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES incidents (id)',
    ),
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    gardenId,
    activityId,
    incidentId,
    localPath,
    position,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'photos';
  @override
  VerificationContext validateIntegrity(
    Insertable<PhotoRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('garden_id')) {
      context.handle(
        _gardenIdMeta,
        gardenId.isAcceptableOrUnknown(data['garden_id']!, _gardenIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gardenIdMeta);
    }
    if (data.containsKey('activity_id')) {
      context.handle(
        _activityIdMeta,
        activityId.isAcceptableOrUnknown(data['activity_id']!, _activityIdMeta),
      );
    }
    if (data.containsKey('incident_id')) {
      context.handle(
        _incidentIdMeta,
        incidentId.isAcceptableOrUnknown(data['incident_id']!, _incidentIdMeta),
      );
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PhotoRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PhotoRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      gardenId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}garden_id'],
      )!,
      activityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activity_id'],
      ),
      incidentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}incident_id'],
      ),
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $PhotosTable createAlias(String alias) {
    return $PhotosTable(attachedDatabase, alias);
  }
}

class PhotoRow extends DataClass implements Insertable<PhotoRow> {
  final String id;
  final String gardenId;
  final String? activityId;

  /// Fotka problému (V2, schéma 6); fotka patří záznamu, nebo incidentu.
  final String? incidentId;

  /// Cesta k souboru relativní ke složce dokumentů aplikace. Na server
  /// se neposílá (tam je `storage_path`).
  final String localPath;

  /// Pořadí fotky v záznamu.
  final int position;
  final DateTime createdAt;

  /// Od schématu 4 (synchronizace „poslední zápis vyhrává“); starší
  /// fotky ho dostaly podle `created_at`.
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  const PhotoRow({
    required this.id,
    required this.gardenId,
    this.activityId,
    this.incidentId,
    required this.localPath,
    required this.position,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['garden_id'] = Variable<String>(gardenId);
    if (!nullToAbsent || activityId != null) {
      map['activity_id'] = Variable<String>(activityId);
    }
    if (!nullToAbsent || incidentId != null) {
      map['incident_id'] = Variable<String>(incidentId);
    }
    map['local_path'] = Variable<String>(localPath);
    map['position'] = Variable<int>(position);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  PhotosCompanion toCompanion(bool nullToAbsent) {
    return PhotosCompanion(
      id: Value(id),
      gardenId: Value(gardenId),
      activityId: activityId == null && nullToAbsent
          ? const Value.absent()
          : Value(activityId),
      incidentId: incidentId == null && nullToAbsent
          ? const Value.absent()
          : Value(incidentId),
      localPath: Value(localPath),
      position: Value(position),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory PhotoRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PhotoRow(
      id: serializer.fromJson<String>(json['id']),
      gardenId: serializer.fromJson<String>(json['gardenId']),
      activityId: serializer.fromJson<String?>(json['activityId']),
      incidentId: serializer.fromJson<String?>(json['incidentId']),
      localPath: serializer.fromJson<String>(json['localPath']),
      position: serializer.fromJson<int>(json['position']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'gardenId': serializer.toJson<String>(gardenId),
      'activityId': serializer.toJson<String?>(activityId),
      'incidentId': serializer.toJson<String?>(incidentId),
      'localPath': serializer.toJson<String>(localPath),
      'position': serializer.toJson<int>(position),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  PhotoRow copyWith({
    String? id,
    String? gardenId,
    Value<String?> activityId = const Value.absent(),
    Value<String?> incidentId = const Value.absent(),
    String? localPath,
    int? position,
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => PhotoRow(
    id: id ?? this.id,
    gardenId: gardenId ?? this.gardenId,
    activityId: activityId.present ? activityId.value : this.activityId,
    incidentId: incidentId.present ? incidentId.value : this.incidentId,
    localPath: localPath ?? this.localPath,
    position: position ?? this.position,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  PhotoRow copyWithCompanion(PhotosCompanion data) {
    return PhotoRow(
      id: data.id.present ? data.id.value : this.id,
      gardenId: data.gardenId.present ? data.gardenId.value : this.gardenId,
      activityId: data.activityId.present
          ? data.activityId.value
          : this.activityId,
      incidentId: data.incidentId.present
          ? data.incidentId.value
          : this.incidentId,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      position: data.position.present ? data.position.value : this.position,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PhotoRow(')
          ..write('id: $id, ')
          ..write('gardenId: $gardenId, ')
          ..write('activityId: $activityId, ')
          ..write('incidentId: $incidentId, ')
          ..write('localPath: $localPath, ')
          ..write('position: $position, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    gardenId,
    activityId,
    incidentId,
    localPath,
    position,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PhotoRow &&
          other.id == this.id &&
          other.gardenId == this.gardenId &&
          other.activityId == this.activityId &&
          other.incidentId == this.incidentId &&
          other.localPath == this.localPath &&
          other.position == this.position &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class PhotosCompanion extends UpdateCompanion<PhotoRow> {
  final Value<String> id;
  final Value<String> gardenId;
  final Value<String?> activityId;
  final Value<String?> incidentId;
  final Value<String> localPath;
  final Value<int> position;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const PhotosCompanion({
    this.id = const Value.absent(),
    this.gardenId = const Value.absent(),
    this.activityId = const Value.absent(),
    this.incidentId = const Value.absent(),
    this.localPath = const Value.absent(),
    this.position = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PhotosCompanion.insert({
    required String id,
    required String gardenId,
    this.activityId = const Value.absent(),
    this.incidentId = const Value.absent(),
    required String localPath,
    this.position = const Value.absent(),
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       gardenId = Value(gardenId),
       localPath = Value(localPath),
       createdAt = Value(createdAt);
  static Insertable<PhotoRow> custom({
    Expression<String>? id,
    Expression<String>? gardenId,
    Expression<String>? activityId,
    Expression<String>? incidentId,
    Expression<String>? localPath,
    Expression<int>? position,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gardenId != null) 'garden_id': gardenId,
      if (activityId != null) 'activity_id': activityId,
      if (incidentId != null) 'incident_id': incidentId,
      if (localPath != null) 'local_path': localPath,
      if (position != null) 'position': position,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PhotosCompanion copyWith({
    Value<String>? id,
    Value<String>? gardenId,
    Value<String?>? activityId,
    Value<String?>? incidentId,
    Value<String>? localPath,
    Value<int>? position,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return PhotosCompanion(
      id: id ?? this.id,
      gardenId: gardenId ?? this.gardenId,
      activityId: activityId ?? this.activityId,
      incidentId: incidentId ?? this.incidentId,
      localPath: localPath ?? this.localPath,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (gardenId.present) {
      map['garden_id'] = Variable<String>(gardenId.value);
    }
    if (activityId.present) {
      map['activity_id'] = Variable<String>(activityId.value);
    }
    if (incidentId.present) {
      map['incident_id'] = Variable<String>(incidentId.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PhotosCompanion(')
          ..write('id: $id, ')
          ..write('gardenId: $gardenId, ')
          ..write('activityId: $activityId, ')
          ..write('incidentId: $incidentId, ')
          ..write('localPath: $localPath, ')
          ..write('position: $position, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TaskMaterialsTable extends TaskMaterials
    with TableInfo<$TaskMaterialsTable, TaskMaterialRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskMaterialsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tasks (id)',
    ),
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES inventory_items (id)',
    ),
  );
  static const VerificationMeta _gardenIdMeta = const VerificationMeta(
    'gardenId',
  );
  @override
  late final GeneratedColumn<String> gardenId = GeneratedColumn<String>(
    'garden_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES gardens (id)',
    ),
  );
  static const VerificationMeta _qtyMeta = const VerificationMeta('qty');
  @override
  late final GeneratedColumn<double> qty = GeneratedColumn<double>(
    'qty',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    taskId,
    itemId,
    gardenId,
    qty,
    unit,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_materials';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskMaterialRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('garden_id')) {
      context.handle(
        _gardenIdMeta,
        gardenId.isAcceptableOrUnknown(data['garden_id']!, _gardenIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gardenIdMeta);
    }
    if (data.containsKey('qty')) {
      context.handle(
        _qtyMeta,
        qty.isAcceptableOrUnknown(data['qty']!, _qtyMeta),
      );
    } else if (isInserting) {
      context.missing(_qtyMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {taskId, itemId};
  @override
  TaskMaterialRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskMaterialRow(
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      gardenId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}garden_id'],
      )!,
      qty: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}qty'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $TaskMaterialsTable createAlias(String alias) {
    return $TaskMaterialsTable(attachedDatabase, alias);
  }
}

class TaskMaterialRow extends DataClass implements Insertable<TaskMaterialRow> {
  final String taskId;
  final String itemId;
  final String gardenId;
  final double qty;
  final String unit;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const TaskMaterialRow({
    required this.taskId,
    required this.itemId,
    required this.gardenId,
    required this.qty,
    required this.unit,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['task_id'] = Variable<String>(taskId);
    map['item_id'] = Variable<String>(itemId);
    map['garden_id'] = Variable<String>(gardenId);
    map['qty'] = Variable<double>(qty);
    map['unit'] = Variable<String>(unit);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  TaskMaterialsCompanion toCompanion(bool nullToAbsent) {
    return TaskMaterialsCompanion(
      taskId: Value(taskId),
      itemId: Value(itemId),
      gardenId: Value(gardenId),
      qty: Value(qty),
      unit: Value(unit),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory TaskMaterialRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskMaterialRow(
      taskId: serializer.fromJson<String>(json['taskId']),
      itemId: serializer.fromJson<String>(json['itemId']),
      gardenId: serializer.fromJson<String>(json['gardenId']),
      qty: serializer.fromJson<double>(json['qty']),
      unit: serializer.fromJson<String>(json['unit']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'taskId': serializer.toJson<String>(taskId),
      'itemId': serializer.toJson<String>(itemId),
      'gardenId': serializer.toJson<String>(gardenId),
      'qty': serializer.toJson<double>(qty),
      'unit': serializer.toJson<String>(unit),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  TaskMaterialRow copyWith({
    String? taskId,
    String? itemId,
    String? gardenId,
    double? qty,
    String? unit,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => TaskMaterialRow(
    taskId: taskId ?? this.taskId,
    itemId: itemId ?? this.itemId,
    gardenId: gardenId ?? this.gardenId,
    qty: qty ?? this.qty,
    unit: unit ?? this.unit,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  TaskMaterialRow copyWithCompanion(TaskMaterialsCompanion data) {
    return TaskMaterialRow(
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      gardenId: data.gardenId.present ? data.gardenId.value : this.gardenId,
      qty: data.qty.present ? data.qty.value : this.qty,
      unit: data.unit.present ? data.unit.value : this.unit,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskMaterialRow(')
          ..write('taskId: $taskId, ')
          ..write('itemId: $itemId, ')
          ..write('gardenId: $gardenId, ')
          ..write('qty: $qty, ')
          ..write('unit: $unit, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    taskId,
    itemId,
    gardenId,
    qty,
    unit,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskMaterialRow &&
          other.taskId == this.taskId &&
          other.itemId == this.itemId &&
          other.gardenId == this.gardenId &&
          other.qty == this.qty &&
          other.unit == this.unit &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class TaskMaterialsCompanion extends UpdateCompanion<TaskMaterialRow> {
  final Value<String> taskId;
  final Value<String> itemId;
  final Value<String> gardenId;
  final Value<double> qty;
  final Value<String> unit;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const TaskMaterialsCompanion({
    this.taskId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.gardenId = const Value.absent(),
    this.qty = const Value.absent(),
    this.unit = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaskMaterialsCompanion.insert({
    required String taskId,
    required String itemId,
    required String gardenId,
    required double qty,
    required String unit,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : taskId = Value(taskId),
       itemId = Value(itemId),
       gardenId = Value(gardenId),
       qty = Value(qty),
       unit = Value(unit),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<TaskMaterialRow> custom({
    Expression<String>? taskId,
    Expression<String>? itemId,
    Expression<String>? gardenId,
    Expression<double>? qty,
    Expression<String>? unit,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (taskId != null) 'task_id': taskId,
      if (itemId != null) 'item_id': itemId,
      if (gardenId != null) 'garden_id': gardenId,
      if (qty != null) 'qty': qty,
      if (unit != null) 'unit': unit,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TaskMaterialsCompanion copyWith({
    Value<String>? taskId,
    Value<String>? itemId,
    Value<String>? gardenId,
    Value<double>? qty,
    Value<String>? unit,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return TaskMaterialsCompanion(
      taskId: taskId ?? this.taskId,
      itemId: itemId ?? this.itemId,
      gardenId: gardenId ?? this.gardenId,
      qty: qty ?? this.qty,
      unit: unit ?? this.unit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (gardenId.present) {
      map['garden_id'] = Variable<String>(gardenId.value);
    }
    if (qty.present) {
      map['qty'] = Variable<double>(qty.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskMaterialsCompanion(')
          ..write('taskId: $taskId, ')
          ..write('itemId: $itemId, ')
          ..write('gardenId: $gardenId, ')
          ..write('qty: $qty, ')
          ..write('unit: $unit, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActivityMaterialsTable extends ActivityMaterials
    with TableInfo<$ActivityMaterialsTable, ActivityMaterialRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivityMaterialsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _activityIdMeta = const VerificationMeta(
    'activityId',
  );
  @override
  late final GeneratedColumn<String> activityId = GeneratedColumn<String>(
    'activity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES activities (id)',
    ),
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES inventory_items (id)',
    ),
  );
  static const VerificationMeta _gardenIdMeta = const VerificationMeta(
    'gardenId',
  );
  @override
  late final GeneratedColumn<String> gardenId = GeneratedColumn<String>(
    'garden_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES gardens (id)',
    ),
  );
  static const VerificationMeta _qtyMeta = const VerificationMeta('qty');
  @override
  late final GeneratedColumn<double> qty = GeneratedColumn<double>(
    'qty',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    activityId,
    itemId,
    gardenId,
    qty,
    unit,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activity_materials';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActivityMaterialRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('activity_id')) {
      context.handle(
        _activityIdMeta,
        activityId.isAcceptableOrUnknown(data['activity_id']!, _activityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_activityIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('garden_id')) {
      context.handle(
        _gardenIdMeta,
        gardenId.isAcceptableOrUnknown(data['garden_id']!, _gardenIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gardenIdMeta);
    }
    if (data.containsKey('qty')) {
      context.handle(
        _qtyMeta,
        qty.isAcceptableOrUnknown(data['qty']!, _qtyMeta),
      );
    } else if (isInserting) {
      context.missing(_qtyMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {activityId, itemId};
  @override
  ActivityMaterialRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivityMaterialRow(
      activityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activity_id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      gardenId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}garden_id'],
      )!,
      qty: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}qty'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $ActivityMaterialsTable createAlias(String alias) {
    return $ActivityMaterialsTable(attachedDatabase, alias);
  }
}

class ActivityMaterialRow extends DataClass
    implements Insertable<ActivityMaterialRow> {
  final String activityId;
  final String itemId;
  final String gardenId;
  final double qty;
  final String unit;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const ActivityMaterialRow({
    required this.activityId,
    required this.itemId,
    required this.gardenId,
    required this.qty,
    required this.unit,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['activity_id'] = Variable<String>(activityId);
    map['item_id'] = Variable<String>(itemId);
    map['garden_id'] = Variable<String>(gardenId);
    map['qty'] = Variable<double>(qty);
    map['unit'] = Variable<String>(unit);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  ActivityMaterialsCompanion toCompanion(bool nullToAbsent) {
    return ActivityMaterialsCompanion(
      activityId: Value(activityId),
      itemId: Value(itemId),
      gardenId: Value(gardenId),
      qty: Value(qty),
      unit: Value(unit),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory ActivityMaterialRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivityMaterialRow(
      activityId: serializer.fromJson<String>(json['activityId']),
      itemId: serializer.fromJson<String>(json['itemId']),
      gardenId: serializer.fromJson<String>(json['gardenId']),
      qty: serializer.fromJson<double>(json['qty']),
      unit: serializer.fromJson<String>(json['unit']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'activityId': serializer.toJson<String>(activityId),
      'itemId': serializer.toJson<String>(itemId),
      'gardenId': serializer.toJson<String>(gardenId),
      'qty': serializer.toJson<double>(qty),
      'unit': serializer.toJson<String>(unit),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  ActivityMaterialRow copyWith({
    String? activityId,
    String? itemId,
    String? gardenId,
    double? qty,
    String? unit,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => ActivityMaterialRow(
    activityId: activityId ?? this.activityId,
    itemId: itemId ?? this.itemId,
    gardenId: gardenId ?? this.gardenId,
    qty: qty ?? this.qty,
    unit: unit ?? this.unit,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  ActivityMaterialRow copyWithCompanion(ActivityMaterialsCompanion data) {
    return ActivityMaterialRow(
      activityId: data.activityId.present
          ? data.activityId.value
          : this.activityId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      gardenId: data.gardenId.present ? data.gardenId.value : this.gardenId,
      qty: data.qty.present ? data.qty.value : this.qty,
      unit: data.unit.present ? data.unit.value : this.unit,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivityMaterialRow(')
          ..write('activityId: $activityId, ')
          ..write('itemId: $itemId, ')
          ..write('gardenId: $gardenId, ')
          ..write('qty: $qty, ')
          ..write('unit: $unit, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    activityId,
    itemId,
    gardenId,
    qty,
    unit,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivityMaterialRow &&
          other.activityId == this.activityId &&
          other.itemId == this.itemId &&
          other.gardenId == this.gardenId &&
          other.qty == this.qty &&
          other.unit == this.unit &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class ActivityMaterialsCompanion extends UpdateCompanion<ActivityMaterialRow> {
  final Value<String> activityId;
  final Value<String> itemId;
  final Value<String> gardenId;
  final Value<double> qty;
  final Value<String> unit;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const ActivityMaterialsCompanion({
    this.activityId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.gardenId = const Value.absent(),
    this.qty = const Value.absent(),
    this.unit = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActivityMaterialsCompanion.insert({
    required String activityId,
    required String itemId,
    required String gardenId,
    required double qty,
    required String unit,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : activityId = Value(activityId),
       itemId = Value(itemId),
       gardenId = Value(gardenId),
       qty = Value(qty),
       unit = Value(unit),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ActivityMaterialRow> custom({
    Expression<String>? activityId,
    Expression<String>? itemId,
    Expression<String>? gardenId,
    Expression<double>? qty,
    Expression<String>? unit,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (activityId != null) 'activity_id': activityId,
      if (itemId != null) 'item_id': itemId,
      if (gardenId != null) 'garden_id': gardenId,
      if (qty != null) 'qty': qty,
      if (unit != null) 'unit': unit,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActivityMaterialsCompanion copyWith({
    Value<String>? activityId,
    Value<String>? itemId,
    Value<String>? gardenId,
    Value<double>? qty,
    Value<String>? unit,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return ActivityMaterialsCompanion(
      activityId: activityId ?? this.activityId,
      itemId: itemId ?? this.itemId,
      gardenId: gardenId ?? this.gardenId,
      qty: qty ?? this.qty,
      unit: unit ?? this.unit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (activityId.present) {
      map['activity_id'] = Variable<String>(activityId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (gardenId.present) {
      map['garden_id'] = Variable<String>(gardenId.value);
    }
    if (qty.present) {
      map['qty'] = Variable<double>(qty.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivityMaterialsCompanion(')
          ..write('activityId: $activityId, ')
          ..write('itemId: $itemId, ')
          ..write('gardenId: $gardenId, ')
          ..write('qty: $qty, ')
          ..write('unit: $unit, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShoppingItemsTable extends ShoppingItems
    with TableInfo<$ShoppingItemsTable, ShoppingItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShoppingItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gardenIdMeta = const VerificationMeta(
    'gardenId',
  );
  @override
  late final GeneratedColumn<String> gardenId = GeneratedColumn<String>(
    'garden_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES gardens (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _qtyMeta = const VerificationMeta('qty');
  @override
  late final GeneratedColumn<double> qty = GeneratedColumn<double>(
    'qty',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES inventory_items (id)',
    ),
  );
  static const VerificationMeta _doneMeta = const VerificationMeta('done');
  @override
  late final GeneratedColumn<bool> done = GeneratedColumn<bool>(
    'done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("done" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('user'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    gardenId,
    name,
    qty,
    unit,
    itemId,
    done,
    source,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shopping_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShoppingItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('garden_id')) {
      context.handle(
        _gardenIdMeta,
        gardenId.isAcceptableOrUnknown(data['garden_id']!, _gardenIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gardenIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('qty')) {
      context.handle(
        _qtyMeta,
        qty.isAcceptableOrUnknown(data['qty']!, _qtyMeta),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    }
    if (data.containsKey('done')) {
      context.handle(
        _doneMeta,
        done.isAcceptableOrUnknown(data['done']!, _doneMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShoppingItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShoppingItemRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      gardenId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}garden_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      qty: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}qty'],
      ),
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      ),
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      ),
      done: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}done'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $ShoppingItemsTable createAlias(String alias) {
    return $ShoppingItemsTable(attachedDatabase, alias);
  }
}

class ShoppingItemRow extends DataClass implements Insertable<ShoppingItemRow> {
  final String id;
  final String gardenId;
  final String name;
  final double? qty;
  final String? unit;
  final String? itemId;
  final bool done;

  /// `user`, `boda`, `lowStock`.
  final String source;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const ShoppingItemRow({
    required this.id,
    required this.gardenId,
    required this.name,
    this.qty,
    this.unit,
    this.itemId,
    required this.done,
    required this.source,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['garden_id'] = Variable<String>(gardenId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || qty != null) {
      map['qty'] = Variable<double>(qty);
    }
    if (!nullToAbsent || unit != null) {
      map['unit'] = Variable<String>(unit);
    }
    if (!nullToAbsent || itemId != null) {
      map['item_id'] = Variable<String>(itemId);
    }
    map['done'] = Variable<bool>(done);
    map['source'] = Variable<String>(source);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  ShoppingItemsCompanion toCompanion(bool nullToAbsent) {
    return ShoppingItemsCompanion(
      id: Value(id),
      gardenId: Value(gardenId),
      name: Value(name),
      qty: qty == null && nullToAbsent ? const Value.absent() : Value(qty),
      unit: unit == null && nullToAbsent ? const Value.absent() : Value(unit),
      itemId: itemId == null && nullToAbsent
          ? const Value.absent()
          : Value(itemId),
      done: Value(done),
      source: Value(source),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory ShoppingItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShoppingItemRow(
      id: serializer.fromJson<String>(json['id']),
      gardenId: serializer.fromJson<String>(json['gardenId']),
      name: serializer.fromJson<String>(json['name']),
      qty: serializer.fromJson<double?>(json['qty']),
      unit: serializer.fromJson<String?>(json['unit']),
      itemId: serializer.fromJson<String?>(json['itemId']),
      done: serializer.fromJson<bool>(json['done']),
      source: serializer.fromJson<String>(json['source']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'gardenId': serializer.toJson<String>(gardenId),
      'name': serializer.toJson<String>(name),
      'qty': serializer.toJson<double?>(qty),
      'unit': serializer.toJson<String?>(unit),
      'itemId': serializer.toJson<String?>(itemId),
      'done': serializer.toJson<bool>(done),
      'source': serializer.toJson<String>(source),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  ShoppingItemRow copyWith({
    String? id,
    String? gardenId,
    String? name,
    Value<double?> qty = const Value.absent(),
    Value<String?> unit = const Value.absent(),
    Value<String?> itemId = const Value.absent(),
    bool? done,
    String? source,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => ShoppingItemRow(
    id: id ?? this.id,
    gardenId: gardenId ?? this.gardenId,
    name: name ?? this.name,
    qty: qty.present ? qty.value : this.qty,
    unit: unit.present ? unit.value : this.unit,
    itemId: itemId.present ? itemId.value : this.itemId,
    done: done ?? this.done,
    source: source ?? this.source,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  ShoppingItemRow copyWithCompanion(ShoppingItemsCompanion data) {
    return ShoppingItemRow(
      id: data.id.present ? data.id.value : this.id,
      gardenId: data.gardenId.present ? data.gardenId.value : this.gardenId,
      name: data.name.present ? data.name.value : this.name,
      qty: data.qty.present ? data.qty.value : this.qty,
      unit: data.unit.present ? data.unit.value : this.unit,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      done: data.done.present ? data.done.value : this.done,
      source: data.source.present ? data.source.value : this.source,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShoppingItemRow(')
          ..write('id: $id, ')
          ..write('gardenId: $gardenId, ')
          ..write('name: $name, ')
          ..write('qty: $qty, ')
          ..write('unit: $unit, ')
          ..write('itemId: $itemId, ')
          ..write('done: $done, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    gardenId,
    name,
    qty,
    unit,
    itemId,
    done,
    source,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShoppingItemRow &&
          other.id == this.id &&
          other.gardenId == this.gardenId &&
          other.name == this.name &&
          other.qty == this.qty &&
          other.unit == this.unit &&
          other.itemId == this.itemId &&
          other.done == this.done &&
          other.source == this.source &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class ShoppingItemsCompanion extends UpdateCompanion<ShoppingItemRow> {
  final Value<String> id;
  final Value<String> gardenId;
  final Value<String> name;
  final Value<double?> qty;
  final Value<String?> unit;
  final Value<String?> itemId;
  final Value<bool> done;
  final Value<String> source;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const ShoppingItemsCompanion({
    this.id = const Value.absent(),
    this.gardenId = const Value.absent(),
    this.name = const Value.absent(),
    this.qty = const Value.absent(),
    this.unit = const Value.absent(),
    this.itemId = const Value.absent(),
    this.done = const Value.absent(),
    this.source = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShoppingItemsCompanion.insert({
    required String id,
    required String gardenId,
    required String name,
    this.qty = const Value.absent(),
    this.unit = const Value.absent(),
    this.itemId = const Value.absent(),
    this.done = const Value.absent(),
    this.source = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       gardenId = Value(gardenId),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ShoppingItemRow> custom({
    Expression<String>? id,
    Expression<String>? gardenId,
    Expression<String>? name,
    Expression<double>? qty,
    Expression<String>? unit,
    Expression<String>? itemId,
    Expression<bool>? done,
    Expression<String>? source,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gardenId != null) 'garden_id': gardenId,
      if (name != null) 'name': name,
      if (qty != null) 'qty': qty,
      if (unit != null) 'unit': unit,
      if (itemId != null) 'item_id': itemId,
      if (done != null) 'done': done,
      if (source != null) 'source': source,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShoppingItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? gardenId,
    Value<String>? name,
    Value<double?>? qty,
    Value<String?>? unit,
    Value<String?>? itemId,
    Value<bool>? done,
    Value<String>? source,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return ShoppingItemsCompanion(
      id: id ?? this.id,
      gardenId: gardenId ?? this.gardenId,
      name: name ?? this.name,
      qty: qty ?? this.qty,
      unit: unit ?? this.unit,
      itemId: itemId ?? this.itemId,
      done: done ?? this.done,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (gardenId.present) {
      map['garden_id'] = Variable<String>(gardenId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (qty.present) {
      map['qty'] = Variable<double>(qty.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (done.present) {
      map['done'] = Variable<bool>(done.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShoppingItemsCompanion(')
          ..write('id: $id, ')
          ..write('gardenId: $gardenId, ')
          ..write('name: $name, ')
          ..write('qty: $qty, ')
          ..write('unit: $unit, ')
          ..write('itemId: $itemId, ')
          ..write('done: $done, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AssistantThreadsTable extends AssistantThreads
    with TableInfo<$AssistantThreadsTable, AssistantThreadRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssistantThreadsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gardenIdMeta = const VerificationMeta(
    'gardenId',
  );
  @override
  late final GeneratedColumn<String> gardenId = GeneratedColumn<String>(
    'garden_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES gardens (id)',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    gardenId,
    title,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'assistant_threads';
  @override
  VerificationContext validateIntegrity(
    Insertable<AssistantThreadRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('garden_id')) {
      context.handle(
        _gardenIdMeta,
        gardenId.isAcceptableOrUnknown(data['garden_id']!, _gardenIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AssistantThreadRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssistantThreadRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      gardenId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}garden_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $AssistantThreadsTable createAlias(String alias) {
    return $AssistantThreadsTable(attachedDatabase, alias);
  }
}

class AssistantThreadRow extends DataClass
    implements Insertable<AssistantThreadRow> {
  final String id;
  final String? gardenId;
  final String? title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const AssistantThreadRow({
    required this.id,
    this.gardenId,
    this.title,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || gardenId != null) {
      map['garden_id'] = Variable<String>(gardenId);
    }
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  AssistantThreadsCompanion toCompanion(bool nullToAbsent) {
    return AssistantThreadsCompanion(
      id: Value(id),
      gardenId: gardenId == null && nullToAbsent
          ? const Value.absent()
          : Value(gardenId),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory AssistantThreadRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssistantThreadRow(
      id: serializer.fromJson<String>(json['id']),
      gardenId: serializer.fromJson<String?>(json['gardenId']),
      title: serializer.fromJson<String?>(json['title']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'gardenId': serializer.toJson<String?>(gardenId),
      'title': serializer.toJson<String?>(title),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  AssistantThreadRow copyWith({
    String? id,
    Value<String?> gardenId = const Value.absent(),
    Value<String?> title = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => AssistantThreadRow(
    id: id ?? this.id,
    gardenId: gardenId.present ? gardenId.value : this.gardenId,
    title: title.present ? title.value : this.title,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  AssistantThreadRow copyWithCompanion(AssistantThreadsCompanion data) {
    return AssistantThreadRow(
      id: data.id.present ? data.id.value : this.id,
      gardenId: data.gardenId.present ? data.gardenId.value : this.gardenId,
      title: data.title.present ? data.title.value : this.title,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssistantThreadRow(')
          ..write('id: $id, ')
          ..write('gardenId: $gardenId, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, gardenId, title, createdAt, updatedAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssistantThreadRow &&
          other.id == this.id &&
          other.gardenId == this.gardenId &&
          other.title == this.title &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class AssistantThreadsCompanion extends UpdateCompanion<AssistantThreadRow> {
  final Value<String> id;
  final Value<String?> gardenId;
  final Value<String?> title;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const AssistantThreadsCompanion({
    this.id = const Value.absent(),
    this.gardenId = const Value.absent(),
    this.title = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AssistantThreadsCompanion.insert({
    required String id,
    this.gardenId = const Value.absent(),
    this.title = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<AssistantThreadRow> custom({
    Expression<String>? id,
    Expression<String>? gardenId,
    Expression<String>? title,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gardenId != null) 'garden_id': gardenId,
      if (title != null) 'title': title,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AssistantThreadsCompanion copyWith({
    Value<String>? id,
    Value<String?>? gardenId,
    Value<String?>? title,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return AssistantThreadsCompanion(
      id: id ?? this.id,
      gardenId: gardenId ?? this.gardenId,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (gardenId.present) {
      map['garden_id'] = Variable<String>(gardenId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssistantThreadsCompanion(')
          ..write('id: $id, ')
          ..write('gardenId: $gardenId, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AssistantMessagesTable extends AssistantMessages
    with TableInfo<$AssistantMessagesTable, AssistantMessageRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssistantMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _threadIdMeta = const VerificationMeta(
    'threadId',
  );
  @override
  late final GeneratedColumn<String> threadId = GeneratedColumn<String>(
    'thread_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES assistant_threads (id)',
    ),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contextSummaryMeta = const VerificationMeta(
    'contextSummary',
  );
  @override
  late final GeneratedColumn<String> contextSummary = GeneratedColumn<String>(
    'context_summary',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('sent'),
  );
  static const VerificationMeta _feedbackMeta = const VerificationMeta(
    'feedback',
  );
  @override
  late final GeneratedColumn<String> feedback = GeneratedColumn<String>(
    'feedback',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _feedbackCommentMeta = const VerificationMeta(
    'feedbackComment',
  );
  @override
  late final GeneratedColumn<String> feedbackComment = GeneratedColumn<String>(
    'feedback_comment',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    threadId,
    role,
    body,
    contextSummary,
    status,
    feedback,
    feedbackComment,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'assistant_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<AssistantMessageRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('thread_id')) {
      context.handle(
        _threadIdMeta,
        threadId.isAcceptableOrUnknown(data['thread_id']!, _threadIdMeta),
      );
    } else if (isInserting) {
      context.missing(_threadIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('context_summary')) {
      context.handle(
        _contextSummaryMeta,
        contextSummary.isAcceptableOrUnknown(
          data['context_summary']!,
          _contextSummaryMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('feedback')) {
      context.handle(
        _feedbackMeta,
        feedback.isAcceptableOrUnknown(data['feedback']!, _feedbackMeta),
      );
    }
    if (data.containsKey('feedback_comment')) {
      context.handle(
        _feedbackCommentMeta,
        feedbackComment.isAcceptableOrUnknown(
          data['feedback_comment']!,
          _feedbackCommentMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AssistantMessageRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssistantMessageRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      threadId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thread_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      contextSummary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}context_summary'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      feedback: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feedback'],
      ),
      feedbackComment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feedback_comment'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $AssistantMessagesTable createAlias(String alias) {
    return $AssistantMessagesTable(attachedDatabase, alias);
  }
}

class AssistantMessageRow extends DataClass
    implements Insertable<AssistantMessageRow> {
  final String id;
  final String threadId;

  /// `user` nebo `assistant`.
  final String role;

  /// Na serveru sloupec `text` (synchronizace ho přejmenuje); `text` by se
  /// v generovaném kódu Driftu tloukl s metodou `Table.text()`.
  final String body;

  /// Z čeho Bóďa vycházel, akce, upozornění a čerpání limitu (JSON).
  final String? contextSummary;

  /// Dotaz bez připojení čeká na odeslání (FR-B7): `pending`, `sent`,
  /// `failed`. Jen v telefonu.
  final String status;

  /// `up` / `down` (FR-B6).
  final String? feedback;
  final String? feedbackComment;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const AssistantMessageRow({
    required this.id,
    required this.threadId,
    required this.role,
    required this.body,
    this.contextSummary,
    required this.status,
    this.feedback,
    this.feedbackComment,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['thread_id'] = Variable<String>(threadId);
    map['role'] = Variable<String>(role);
    map['body'] = Variable<String>(body);
    if (!nullToAbsent || contextSummary != null) {
      map['context_summary'] = Variable<String>(contextSummary);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || feedback != null) {
      map['feedback'] = Variable<String>(feedback);
    }
    if (!nullToAbsent || feedbackComment != null) {
      map['feedback_comment'] = Variable<String>(feedbackComment);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  AssistantMessagesCompanion toCompanion(bool nullToAbsent) {
    return AssistantMessagesCompanion(
      id: Value(id),
      threadId: Value(threadId),
      role: Value(role),
      body: Value(body),
      contextSummary: contextSummary == null && nullToAbsent
          ? const Value.absent()
          : Value(contextSummary),
      status: Value(status),
      feedback: feedback == null && nullToAbsent
          ? const Value.absent()
          : Value(feedback),
      feedbackComment: feedbackComment == null && nullToAbsent
          ? const Value.absent()
          : Value(feedbackComment),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory AssistantMessageRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssistantMessageRow(
      id: serializer.fromJson<String>(json['id']),
      threadId: serializer.fromJson<String>(json['threadId']),
      role: serializer.fromJson<String>(json['role']),
      body: serializer.fromJson<String>(json['body']),
      contextSummary: serializer.fromJson<String?>(json['contextSummary']),
      status: serializer.fromJson<String>(json['status']),
      feedback: serializer.fromJson<String?>(json['feedback']),
      feedbackComment: serializer.fromJson<String?>(json['feedbackComment']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'threadId': serializer.toJson<String>(threadId),
      'role': serializer.toJson<String>(role),
      'body': serializer.toJson<String>(body),
      'contextSummary': serializer.toJson<String?>(contextSummary),
      'status': serializer.toJson<String>(status),
      'feedback': serializer.toJson<String?>(feedback),
      'feedbackComment': serializer.toJson<String?>(feedbackComment),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  AssistantMessageRow copyWith({
    String? id,
    String? threadId,
    String? role,
    String? body,
    Value<String?> contextSummary = const Value.absent(),
    String? status,
    Value<String?> feedback = const Value.absent(),
    Value<String?> feedbackComment = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => AssistantMessageRow(
    id: id ?? this.id,
    threadId: threadId ?? this.threadId,
    role: role ?? this.role,
    body: body ?? this.body,
    contextSummary: contextSummary.present
        ? contextSummary.value
        : this.contextSummary,
    status: status ?? this.status,
    feedback: feedback.present ? feedback.value : this.feedback,
    feedbackComment: feedbackComment.present
        ? feedbackComment.value
        : this.feedbackComment,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  AssistantMessageRow copyWithCompanion(AssistantMessagesCompanion data) {
    return AssistantMessageRow(
      id: data.id.present ? data.id.value : this.id,
      threadId: data.threadId.present ? data.threadId.value : this.threadId,
      role: data.role.present ? data.role.value : this.role,
      body: data.body.present ? data.body.value : this.body,
      contextSummary: data.contextSummary.present
          ? data.contextSummary.value
          : this.contextSummary,
      status: data.status.present ? data.status.value : this.status,
      feedback: data.feedback.present ? data.feedback.value : this.feedback,
      feedbackComment: data.feedbackComment.present
          ? data.feedbackComment.value
          : this.feedbackComment,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssistantMessageRow(')
          ..write('id: $id, ')
          ..write('threadId: $threadId, ')
          ..write('role: $role, ')
          ..write('body: $body, ')
          ..write('contextSummary: $contextSummary, ')
          ..write('status: $status, ')
          ..write('feedback: $feedback, ')
          ..write('feedbackComment: $feedbackComment, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    threadId,
    role,
    body,
    contextSummary,
    status,
    feedback,
    feedbackComment,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssistantMessageRow &&
          other.id == this.id &&
          other.threadId == this.threadId &&
          other.role == this.role &&
          other.body == this.body &&
          other.contextSummary == this.contextSummary &&
          other.status == this.status &&
          other.feedback == this.feedback &&
          other.feedbackComment == this.feedbackComment &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class AssistantMessagesCompanion extends UpdateCompanion<AssistantMessageRow> {
  final Value<String> id;
  final Value<String> threadId;
  final Value<String> role;
  final Value<String> body;
  final Value<String?> contextSummary;
  final Value<String> status;
  final Value<String?> feedback;
  final Value<String?> feedbackComment;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const AssistantMessagesCompanion({
    this.id = const Value.absent(),
    this.threadId = const Value.absent(),
    this.role = const Value.absent(),
    this.body = const Value.absent(),
    this.contextSummary = const Value.absent(),
    this.status = const Value.absent(),
    this.feedback = const Value.absent(),
    this.feedbackComment = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AssistantMessagesCompanion.insert({
    required String id,
    required String threadId,
    required String role,
    required String body,
    this.contextSummary = const Value.absent(),
    this.status = const Value.absent(),
    this.feedback = const Value.absent(),
    this.feedbackComment = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       threadId = Value(threadId),
       role = Value(role),
       body = Value(body),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<AssistantMessageRow> custom({
    Expression<String>? id,
    Expression<String>? threadId,
    Expression<String>? role,
    Expression<String>? body,
    Expression<String>? contextSummary,
    Expression<String>? status,
    Expression<String>? feedback,
    Expression<String>? feedbackComment,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (threadId != null) 'thread_id': threadId,
      if (role != null) 'role': role,
      if (body != null) 'body': body,
      if (contextSummary != null) 'context_summary': contextSummary,
      if (status != null) 'status': status,
      if (feedback != null) 'feedback': feedback,
      if (feedbackComment != null) 'feedback_comment': feedbackComment,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AssistantMessagesCompanion copyWith({
    Value<String>? id,
    Value<String>? threadId,
    Value<String>? role,
    Value<String>? body,
    Value<String?>? contextSummary,
    Value<String>? status,
    Value<String?>? feedback,
    Value<String?>? feedbackComment,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return AssistantMessagesCompanion(
      id: id ?? this.id,
      threadId: threadId ?? this.threadId,
      role: role ?? this.role,
      body: body ?? this.body,
      contextSummary: contextSummary ?? this.contextSummary,
      status: status ?? this.status,
      feedback: feedback ?? this.feedback,
      feedbackComment: feedbackComment ?? this.feedbackComment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (threadId.present) {
      map['thread_id'] = Variable<String>(threadId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (contextSummary.present) {
      map['context_summary'] = Variable<String>(contextSummary.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (feedback.present) {
      map['feedback'] = Variable<String>(feedback.value);
    }
    if (feedbackComment.present) {
      map['feedback_comment'] = Variable<String>(feedbackComment.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssistantMessagesCompanion(')
          ..write('id: $id, ')
          ..write('threadId: $threadId, ')
          ..write('role: $role, ')
          ..write('body: $body, ')
          ..write('contextSummary: $contextSummary, ')
          ..write('status: $status, ')
          ..write('feedback: $feedback, ')
          ..write('feedbackComment: $feedbackComment, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InventoryMovementsTable extends InventoryMovements
    with TableInfo<$InventoryMovementsTable, InventoryMovementRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InventoryMovementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gardenIdMeta = const VerificationMeta(
    'gardenId',
  );
  @override
  late final GeneratedColumn<String> gardenId = GeneratedColumn<String>(
    'garden_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES gardens (id)',
    ),
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES inventory_items (id)',
    ),
  );
  static const VerificationMeta _qtyDeltaMeta = const VerificationMeta(
    'qtyDelta',
  );
  @override
  late final GeneratedColumn<double> qtyDelta = GeneratedColumn<double>(
    'qty_delta',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tasks (id)',
    ),
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<DateTime> at = GeneratedColumn<DateTime>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    gardenId,
    itemId,
    qtyDelta,
    reason,
    taskId,
    at,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inventory_movements';
  @override
  VerificationContext validateIntegrity(
    Insertable<InventoryMovementRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('garden_id')) {
      context.handle(
        _gardenIdMeta,
        gardenId.isAcceptableOrUnknown(data['garden_id']!, _gardenIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gardenIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('qty_delta')) {
      context.handle(
        _qtyDeltaMeta,
        qtyDelta.isAcceptableOrUnknown(data['qty_delta']!, _qtyDeltaMeta),
      );
    } else if (isInserting) {
      context.missing(_qtyDeltaMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InventoryMovementRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InventoryMovementRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      gardenId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}garden_id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      qtyDelta: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}qty_delta'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      ),
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}at'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $InventoryMovementsTable createAlias(String alias) {
    return $InventoryMovementsTable(attachedDatabase, alias);
  }
}

class InventoryMovementRow extends DataClass
    implements Insertable<InventoryMovementRow> {
  final String id;
  final String gardenId;
  final String itemId;

  /// Změna stavu v jednotce položky (záporná = odpis).
  final double qtyDelta;

  /// `purchase`, `task`, `manual`, `reversal`.
  final String reason;
  final String? taskId;
  final DateTime at;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const InventoryMovementRow({
    required this.id,
    required this.gardenId,
    required this.itemId,
    required this.qtyDelta,
    required this.reason,
    this.taskId,
    required this.at,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['garden_id'] = Variable<String>(gardenId);
    map['item_id'] = Variable<String>(itemId);
    map['qty_delta'] = Variable<double>(qtyDelta);
    map['reason'] = Variable<String>(reason);
    if (!nullToAbsent || taskId != null) {
      map['task_id'] = Variable<String>(taskId);
    }
    map['at'] = Variable<DateTime>(at);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  InventoryMovementsCompanion toCompanion(bool nullToAbsent) {
    return InventoryMovementsCompanion(
      id: Value(id),
      gardenId: Value(gardenId),
      itemId: Value(itemId),
      qtyDelta: Value(qtyDelta),
      reason: Value(reason),
      taskId: taskId == null && nullToAbsent
          ? const Value.absent()
          : Value(taskId),
      at: Value(at),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory InventoryMovementRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InventoryMovementRow(
      id: serializer.fromJson<String>(json['id']),
      gardenId: serializer.fromJson<String>(json['gardenId']),
      itemId: serializer.fromJson<String>(json['itemId']),
      qtyDelta: serializer.fromJson<double>(json['qtyDelta']),
      reason: serializer.fromJson<String>(json['reason']),
      taskId: serializer.fromJson<String?>(json['taskId']),
      at: serializer.fromJson<DateTime>(json['at']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'gardenId': serializer.toJson<String>(gardenId),
      'itemId': serializer.toJson<String>(itemId),
      'qtyDelta': serializer.toJson<double>(qtyDelta),
      'reason': serializer.toJson<String>(reason),
      'taskId': serializer.toJson<String?>(taskId),
      'at': serializer.toJson<DateTime>(at),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  InventoryMovementRow copyWith({
    String? id,
    String? gardenId,
    String? itemId,
    double? qtyDelta,
    String? reason,
    Value<String?> taskId = const Value.absent(),
    DateTime? at,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => InventoryMovementRow(
    id: id ?? this.id,
    gardenId: gardenId ?? this.gardenId,
    itemId: itemId ?? this.itemId,
    qtyDelta: qtyDelta ?? this.qtyDelta,
    reason: reason ?? this.reason,
    taskId: taskId.present ? taskId.value : this.taskId,
    at: at ?? this.at,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  InventoryMovementRow copyWithCompanion(InventoryMovementsCompanion data) {
    return InventoryMovementRow(
      id: data.id.present ? data.id.value : this.id,
      gardenId: data.gardenId.present ? data.gardenId.value : this.gardenId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      qtyDelta: data.qtyDelta.present ? data.qtyDelta.value : this.qtyDelta,
      reason: data.reason.present ? data.reason.value : this.reason,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      at: data.at.present ? data.at.value : this.at,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InventoryMovementRow(')
          ..write('id: $id, ')
          ..write('gardenId: $gardenId, ')
          ..write('itemId: $itemId, ')
          ..write('qtyDelta: $qtyDelta, ')
          ..write('reason: $reason, ')
          ..write('taskId: $taskId, ')
          ..write('at: $at, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    gardenId,
    itemId,
    qtyDelta,
    reason,
    taskId,
    at,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InventoryMovementRow &&
          other.id == this.id &&
          other.gardenId == this.gardenId &&
          other.itemId == this.itemId &&
          other.qtyDelta == this.qtyDelta &&
          other.reason == this.reason &&
          other.taskId == this.taskId &&
          other.at == this.at &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class InventoryMovementsCompanion
    extends UpdateCompanion<InventoryMovementRow> {
  final Value<String> id;
  final Value<String> gardenId;
  final Value<String> itemId;
  final Value<double> qtyDelta;
  final Value<String> reason;
  final Value<String?> taskId;
  final Value<DateTime> at;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const InventoryMovementsCompanion({
    this.id = const Value.absent(),
    this.gardenId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.qtyDelta = const Value.absent(),
    this.reason = const Value.absent(),
    this.taskId = const Value.absent(),
    this.at = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InventoryMovementsCompanion.insert({
    required String id,
    required String gardenId,
    required String itemId,
    required double qtyDelta,
    required String reason,
    this.taskId = const Value.absent(),
    required DateTime at,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       gardenId = Value(gardenId),
       itemId = Value(itemId),
       qtyDelta = Value(qtyDelta),
       reason = Value(reason),
       at = Value(at),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<InventoryMovementRow> custom({
    Expression<String>? id,
    Expression<String>? gardenId,
    Expression<String>? itemId,
    Expression<double>? qtyDelta,
    Expression<String>? reason,
    Expression<String>? taskId,
    Expression<DateTime>? at,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gardenId != null) 'garden_id': gardenId,
      if (itemId != null) 'item_id': itemId,
      if (qtyDelta != null) 'qty_delta': qtyDelta,
      if (reason != null) 'reason': reason,
      if (taskId != null) 'task_id': taskId,
      if (at != null) 'at': at,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InventoryMovementsCompanion copyWith({
    Value<String>? id,
    Value<String>? gardenId,
    Value<String>? itemId,
    Value<double>? qtyDelta,
    Value<String>? reason,
    Value<String?>? taskId,
    Value<DateTime>? at,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return InventoryMovementsCompanion(
      id: id ?? this.id,
      gardenId: gardenId ?? this.gardenId,
      itemId: itemId ?? this.itemId,
      qtyDelta: qtyDelta ?? this.qtyDelta,
      reason: reason ?? this.reason,
      taskId: taskId ?? this.taskId,
      at: at ?? this.at,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (gardenId.present) {
      map['garden_id'] = Variable<String>(gardenId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (qtyDelta.present) {
      map['qty_delta'] = Variable<double>(qtyDelta.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (at.present) {
      map['at'] = Variable<DateTime>(at.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InventoryMovementsCompanion(')
          ..write('id: $id, ')
          ..write('gardenId: $gardenId, ')
          ..write('itemId: $itemId, ')
          ..write('qtyDelta: $qtyDelta, ')
          ..write('reason: $reason, ')
          ..write('taskId: $taskId, ')
          ..write('at: $at, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingEntriesTable extends SettingEntries
    with TableInfo<$SettingEntriesTable, SettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingEntriesTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingRow> instance, {
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
  SettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingRow(
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
  $SettingEntriesTable createAlias(String alias) {
    return $SettingEntriesTable(attachedDatabase, alias);
  }
}

class SettingRow extends DataClass implements Insertable<SettingRow> {
  final String key;
  final String value;
  const SettingRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingEntriesCompanion toCompanion(bool nullToAbsent) {
    return SettingEntriesCompanion(key: Value(key), value: Value(value));
  }

  factory SettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingRow(
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

  SettingRow copyWith({String? key, String? value}) =>
      SettingRow(key: key ?? this.key, value: value ?? this.value);
  SettingRow copyWithCompanion(SettingEntriesCompanion data) {
    return SettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingRow(')
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
      (other is SettingRow &&
          other.key == this.key &&
          other.value == this.value);
}

class SettingEntriesCompanion extends UpdateCompanion<SettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingEntriesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingEntriesCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SettingRow> custom({
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

  SettingEntriesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingEntriesCompanion(
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
    return (StringBuffer('SettingEntriesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final SyncOutbox syncOutbox = SyncOutbox(this);
  late final SyncState syncState = SyncState(this);
  late final $GardensTable gardens = $GardensTable(this);
  late final Trigger gardensOutboxInsert = Trigger(
    'CREATE TRIGGER gardens_outbox_insert AFTER INSERT ON gardens WHEN NOT EXISTS (SELECT 1 FROM sync_state WHERE name = \'applying\') BEGIN DELETE FROM sync_outbox WHERE entity = \'gardens\' AND row_key = NEW.id;INSERT INTO sync_outbox (entity, row_key) VALUES (\'gardens\', NEW.id);END',
    'gardens_outbox_insert',
  );
  late final Trigger gardensOutboxUpdate = Trigger(
    'CREATE TRIGGER gardens_outbox_update AFTER UPDATE ON gardens WHEN NOT EXISTS (SELECT 1 FROM sync_state WHERE name = \'applying\') BEGIN DELETE FROM sync_outbox WHERE entity = \'gardens\' AND row_key = NEW.id;INSERT INTO sync_outbox (entity, row_key) VALUES (\'gardens\', NEW.id);END',
    'gardens_outbox_update',
  );
  late final Trigger gardensOutboxDelete = Trigger(
    'CREATE TRIGGER gardens_outbox_delete AFTER DELETE ON gardens WHEN NOT EXISTS (SELECT 1 FROM sync_state WHERE name = \'applying\') BEGIN DELETE FROM sync_outbox WHERE entity = \'gardens\' AND row_key = OLD.id;INSERT INTO sync_outbox (entity, row_key) VALUES (\'gardens\', OLD.id);END',
    'gardens_outbox_delete',
  );
  late final $ZonesTable zones = $ZonesTable(this);
  late final Trigger zonesOutboxInsert = Trigger(
    'CREATE TRIGGER zones_outbox_insert AFTER INSERT ON zones WHEN NOT EXISTS (SELECT 1 FROM sync_state WHERE name = \'applying\') BEGIN DELETE FROM sync_outbox WHERE entity = \'zones\' AND row_key = NEW.id;INSERT INTO sync_outbox (entity, row_key) VALUES (\'zones\', NEW.id);END',
    'zones_outbox_insert',
  );
  late final Trigger zonesOutboxUpdate = Trigger(
    'CREATE TRIGGER zones_outbox_update AFTER UPDATE ON zones WHEN NOT EXISTS (SELECT 1 FROM sync_state WHERE name = \'applying\') BEGIN DELETE FROM sync_outbox WHERE entity = \'zones\' AND row_key = NEW.id;INSERT INTO sync_outbox (entity, row_key) VALUES (\'zones\', NEW.id);END',
    'zones_outbox_update',
  );
  late final Trigger zonesOutboxDelete = Trigger(
    'CREATE TRIGGER zones_outbox_delete AFTER DELETE ON zones WHEN NOT EXISTS (SELECT 1 FROM sync_state WHERE name = \'applying\') BEGIN DELETE FROM sync_outbox WHERE entity = \'zones\' AND row_key = OLD.id;INSERT INTO sync_outbox (entity, row_key) VALUES (\'zones\', OLD.id);END',
    'zones_outbox_delete',
  );
  late final $InventoryItemsTable inventoryItems = $InventoryItemsTable(this);
  late final Trigger inventoryItemsOutboxInsert = Trigger(
    'CREATE TRIGGER inventory_items_outbox_insert AFTER INSERT ON inventory_items WHEN NOT EXISTS (SELECT 1 FROM sync_state WHERE name = \'applying\') BEGIN DELETE FROM sync_outbox WHERE entity = \'inventory_items\' AND row_key = NEW.id;INSERT INTO sync_outbox (entity, row_key) VALUES (\'inventory_items\', NEW.id);END',
    'inventory_items_outbox_insert',
  );
  late final Trigger inventoryItemsOutboxUpdate = Trigger(
    'CREATE TRIGGER inventory_items_outbox_update AFTER UPDATE ON inventory_items WHEN NOT EXISTS (SELECT 1 FROM sync_state WHERE name = \'applying\') BEGIN DELETE FROM sync_outbox WHERE entity = \'inventory_items\' AND row_key = NEW.id;INSERT INTO sync_outbox (entity, row_key) VALUES (\'inventory_items\', NEW.id);END',
    'inventory_items_outbox_update',
  );
  late final Trigger inventoryItemsOutboxDelete = Trigger(
    'CREATE TRIGGER inventory_items_outbox_delete AFTER DELETE ON inventory_items WHEN NOT EXISTS (SELECT 1 FROM sync_state WHERE name = \'applying\') BEGIN DELETE FROM sync_outbox WHERE entity = \'inventory_items\' AND row_key = OLD.id;INSERT INTO sync_outbox (entity, row_key) VALUES (\'inventory_items\', OLD.id);END',
    'inventory_items_outbox_delete',
  );
  late final $IncidentsTable incidents = $IncidentsTable(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final Trigger tasksOutboxInsert = Trigger(
    'CREATE TRIGGER tasks_outbox_insert AFTER INSERT ON tasks WHEN NOT EXISTS (SELECT 1 FROM sync_state WHERE name = \'applying\') BEGIN DELETE FROM sync_outbox WHERE entity = \'tasks\' AND row_key = NEW.id;INSERT INTO sync_outbox (entity, row_key) VALUES (\'tasks\', NEW.id);END',
    'tasks_outbox_insert',
  );
  late final Trigger tasksOutboxUpdate = Trigger(
    'CREATE TRIGGER tasks_outbox_update AFTER UPDATE ON tasks WHEN NOT EXISTS (SELECT 1 FROM sync_state WHERE name = \'applying\') BEGIN DELETE FROM sync_outbox WHERE entity = \'tasks\' AND row_key = NEW.id;INSERT INTO sync_outbox (entity, row_key) VALUES (\'tasks\', NEW.id);END',
    'tasks_outbox_update',
  );
  late final Trigger tasksOutboxDelete = Trigger(
    'CREATE TRIGGER tasks_outbox_delete AFTER DELETE ON tasks WHEN NOT EXISTS (SELECT 1 FROM sync_state WHERE name = \'applying\') BEGIN DELETE FROM sync_outbox WHERE entity = \'tasks\' AND row_key = OLD.id;INSERT INTO sync_outbox (entity, row_key) VALUES (\'tasks\', OLD.id);END',
    'tasks_outbox_delete',
  );
  late final $ActivitiesTable activities = $ActivitiesTable(this);
  late final Trigger activitiesOutboxInsert = Trigger(
    'CREATE TRIGGER activities_outbox_insert AFTER INSERT ON activities WHEN NOT EXISTS (SELECT 1 FROM sync_state WHERE name = \'applying\') BEGIN DELETE FROM sync_outbox WHERE entity = \'activities\' AND row_key = NEW.id;INSERT INTO sync_outbox (entity, row_key) VALUES (\'activities\', NEW.id);END',
    'activities_outbox_insert',
  );
  late final Trigger activitiesOutboxUpdate = Trigger(
    'CREATE TRIGGER activities_outbox_update AFTER UPDATE ON activities WHEN NOT EXISTS (SELECT 1 FROM sync_state WHERE name = \'applying\') BEGIN DELETE FROM sync_outbox WHERE entity = \'activities\' AND row_key = NEW.id;INSERT INTO sync_outbox (entity, row_key) VALUES (\'activities\', NEW.id);END',
    'activities_outbox_update',
  );
  late final Trigger activitiesOutboxDelete = Trigger(
    'CREATE TRIGGER activities_outbox_delete AFTER DELETE ON activities WHEN NOT EXISTS (SELECT 1 FROM sync_state WHERE name = \'applying\') BEGIN DELETE FROM sync_outbox WHERE entity = \'activities\' AND row_key = OLD.id;INSERT INTO sync_outbox (entity, row_key) VALUES (\'activities\', OLD.id);END',
    'activities_outbox_delete',
  );
  late final $PhotosTable photos = $PhotosTable(this);
  late final Trigger photosOutboxInsert = Trigger(
    'CREATE TRIGGER photos_outbox_insert AFTER INSERT ON photos WHEN NOT EXISTS (SELECT 1 FROM sync_state WHERE name = \'applying\') BEGIN DELETE FROM sync_outbox WHERE entity = \'photos\' AND row_key = NEW.id;INSERT INTO sync_outbox (entity, row_key) VALUES (\'photos\', NEW.id);END',
    'photos_outbox_insert',
  );
  late final Trigger photosOutboxUpdate = Trigger(
    'CREATE TRIGGER photos_outbox_update AFTER UPDATE ON photos WHEN NOT EXISTS (SELECT 1 FROM sync_state WHERE name = \'applying\') BEGIN DELETE FROM sync_outbox WHERE entity = \'photos\' AND row_key = NEW.id;INSERT INTO sync_outbox (entity, row_key) VALUES (\'photos\', NEW.id);END',
    'photos_outbox_update',
  );
  late final Trigger photosOutboxDelete = Trigger(
    'CREATE TRIGGER photos_outbox_delete AFTER DELETE ON photos WHEN NOT EXISTS (SELECT 1 FROM sync_state WHERE name = \'applying\') BEGIN DELETE FROM sync_outbox WHERE entity = \'photos\' AND row_key = OLD.id;INSERT INTO sync_outbox (entity, row_key) VALUES (\'photos\', OLD.id);END',
    'photos_outbox_delete',
  );
  late final $TaskMaterialsTable taskMaterials = $TaskMaterialsTable(this);
  late final Trigger taskMaterialsOutboxInsert = Trigger(
    'CREATE TRIGGER task_materials_outbox_insert AFTER INSERT ON task_materials WHEN NOT EXISTS (SELECT 1 FROM sync_state WHERE name = \'applying\') BEGIN DELETE FROM sync_outbox WHERE entity = \'task_materials\' AND row_key = NEW.task_id || \'|\' || NEW.item_id;INSERT INTO sync_outbox (entity, row_key) VALUES (\'task_materials\', NEW.task_id || \'|\' || NEW.item_id);END',
    'task_materials_outbox_insert',
  );
  late final Trigger taskMaterialsOutboxUpdate = Trigger(
    'CREATE TRIGGER task_materials_outbox_update AFTER UPDATE ON task_materials WHEN NOT EXISTS (SELECT 1 FROM sync_state WHERE name = \'applying\') BEGIN DELETE FROM sync_outbox WHERE entity = \'task_materials\' AND row_key = NEW.task_id || \'|\' || NEW.item_id;INSERT INTO sync_outbox (entity, row_key) VALUES (\'task_materials\', NEW.task_id || \'|\' || NEW.item_id);END',
    'task_materials_outbox_update',
  );
  late final Trigger taskMaterialsOutboxDelete = Trigger(
    'CREATE TRIGGER task_materials_outbox_delete AFTER DELETE ON task_materials WHEN NOT EXISTS (SELECT 1 FROM sync_state WHERE name = \'applying\') BEGIN DELETE FROM sync_outbox WHERE entity = \'task_materials\' AND row_key = OLD.task_id || \'|\' || OLD.item_id;INSERT INTO sync_outbox (entity, row_key) VALUES (\'task_materials\', OLD.task_id || \'|\' || OLD.item_id);END',
    'task_materials_outbox_delete',
  );
  late final $ActivityMaterialsTable activityMaterials =
      $ActivityMaterialsTable(this);
  late final Trigger activityMaterialsOutboxInsert = Trigger(
    'CREATE TRIGGER activity_materials_outbox_insert AFTER INSERT ON activity_materials WHEN NOT EXISTS (SELECT 1 FROM sync_state WHERE name = \'applying\') BEGIN DELETE FROM sync_outbox WHERE entity = \'activity_materials\' AND row_key = NEW.activity_id || \'|\' || NEW.item_id;INSERT INTO sync_outbox (entity, row_key) VALUES (\'activity_materials\', NEW.activity_id || \'|\' || NEW.item_id);END',
    'activity_materials_outbox_insert',
  );
  late final Trigger activityMaterialsOutboxUpdate = Trigger(
    'CREATE TRIGGER activity_materials_outbox_update AFTER UPDATE ON activity_materials WHEN NOT EXISTS (SELECT 1 FROM sync_state WHERE name = \'applying\') BEGIN DELETE FROM sync_outbox WHERE entity = \'activity_materials\' AND row_key = NEW.activity_id || \'|\' || NEW.item_id;INSERT INTO sync_outbox (entity, row_key) VALUES (\'activity_materials\', NEW.activity_id || \'|\' || NEW.item_id);END',
    'activity_materials_outbox_update',
  );
  late final Trigger activityMaterialsOutboxDelete = Trigger(
    'CREATE TRIGGER activity_materials_outbox_delete AFTER DELETE ON activity_materials WHEN NOT EXISTS (SELECT 1 FROM sync_state WHERE name = \'applying\') BEGIN DELETE FROM sync_outbox WHERE entity = \'activity_materials\' AND row_key = OLD.activity_id || \'|\' || OLD.item_id;INSERT INTO sync_outbox (entity, row_key) VALUES (\'activity_materials\', OLD.activity_id || \'|\' || OLD.item_id);END',
    'activity_materials_outbox_delete',
  );
  late final $ShoppingItemsTable shoppingItems = $ShoppingItemsTable(this);
  late final Trigger shoppingItemsOutboxInsert = Trigger(
    'CREATE TRIGGER shopping_items_outbox_insert AFTER INSERT ON shopping_items WHEN NOT EXISTS (SELECT 1 FROM sync_state WHERE name = \'applying\') BEGIN DELETE FROM sync_outbox WHERE entity = \'shopping_items\' AND row_key = NEW.id;INSERT INTO sync_outbox (entity, row_key) VALUES (\'shopping_items\', NEW.id);END',
    'shopping_items_outbox_insert',
  );
  late final Trigger shoppingItemsOutboxUpdate = Trigger(
    'CREATE TRIGGER shopping_items_outbox_update AFTER UPDATE ON shopping_items WHEN NOT EXISTS (SELECT 1 FROM sync_state WHERE name = \'applying\') BEGIN DELETE FROM sync_outbox WHERE entity = \'shopping_items\' AND row_key = NEW.id;INSERT INTO sync_outbox (entity, row_key) VALUES (\'shopping_items\', NEW.id);END',
    'shopping_items_outbox_update',
  );
  late final Trigger shoppingItemsOutboxDelete = Trigger(
    'CREATE TRIGGER shopping_items_outbox_delete AFTER DELETE ON shopping_items WHEN NOT EXISTS (SELECT 1 FROM sync_state WHERE name = \'applying\') BEGIN DELETE FROM sync_outbox WHERE entity = \'shopping_items\' AND row_key = OLD.id;INSERT INTO sync_outbox (entity, row_key) VALUES (\'shopping_items\', OLD.id);END',
    'shopping_items_outbox_delete',
  );
  late final $AssistantThreadsTable assistantThreads = $AssistantThreadsTable(
    this,
  );
  late final Trigger assistantThreadsOutboxInsert = Trigger(
    'CREATE TRIGGER assistant_threads_outbox_insert AFTER INSERT ON assistant_threads WHEN NOT EXISTS (SELECT 1 FROM sync_state WHERE name = \'applying\') BEGIN DELETE FROM sync_outbox WHERE entity = \'assistant_threads\' AND row_key = NEW.id;INSERT INTO sync_outbox (entity, row_key) VALUES (\'assistant_threads\', NEW.id);END',
    'assistant_threads_outbox_insert',
  );
  late final Trigger assistantThreadsOutboxUpdate = Trigger(
    'CREATE TRIGGER assistant_threads_outbox_update AFTER UPDATE ON assistant_threads WHEN NOT EXISTS (SELECT 1 FROM sync_state WHERE name = \'applying\') BEGIN DELETE FROM sync_outbox WHERE entity = \'assistant_threads\' AND row_key = NEW.id;INSERT INTO sync_outbox (entity, row_key) VALUES (\'assistant_threads\', NEW.id);END',
    'assistant_threads_outbox_update',
  );
  late final Trigger assistantThreadsOutboxDelete = Trigger(
    'CREATE TRIGGER assistant_threads_outbox_delete AFTER DELETE ON assistant_threads WHEN NOT EXISTS (SELECT 1 FROM sync_state WHERE name = \'applying\') BEGIN DELETE FROM sync_outbox WHERE entity = \'assistant_threads\' AND row_key = OLD.id;INSERT INTO sync_outbox (entity, row_key) VALUES (\'assistant_threads\', OLD.id);END',
    'assistant_threads_outbox_delete',
  );
  late final $AssistantMessagesTable assistantMessages =
      $AssistantMessagesTable(this);
  late final Trigger assistantMessagesOutboxInsert = Trigger(
    'CREATE TRIGGER assistant_messages_outbox_insert AFTER INSERT ON assistant_messages WHEN NOT EXISTS (SELECT 1 FROM sync_state WHERE name = \'applying\') BEGIN DELETE FROM sync_outbox WHERE entity = \'assistant_messages\' AND row_key = NEW.id;INSERT INTO sync_outbox (entity, row_key) VALUES (\'assistant_messages\', NEW.id);END',
    'assistant_messages_outbox_insert',
  );
  late final Trigger assistantMessagesOutboxUpdate = Trigger(
    'CREATE TRIGGER assistant_messages_outbox_update AFTER UPDATE ON assistant_messages WHEN NOT EXISTS (SELECT 1 FROM sync_state WHERE name = \'applying\') BEGIN DELETE FROM sync_outbox WHERE entity = \'assistant_messages\' AND row_key = NEW.id;INSERT INTO sync_outbox (entity, row_key) VALUES (\'assistant_messages\', NEW.id);END',
    'assistant_messages_outbox_update',
  );
  late final Trigger assistantMessagesOutboxDelete = Trigger(
    'CREATE TRIGGER assistant_messages_outbox_delete AFTER DELETE ON assistant_messages WHEN NOT EXISTS (SELECT 1 FROM sync_state WHERE name = \'applying\') BEGIN DELETE FROM sync_outbox WHERE entity = \'assistant_messages\' AND row_key = OLD.id;INSERT INTO sync_outbox (entity, row_key) VALUES (\'assistant_messages\', OLD.id);END',
    'assistant_messages_outbox_delete',
  );
  late final Trigger incidentsOutboxInsert = Trigger(
    'CREATE TRIGGER incidents_outbox_insert AFTER INSERT ON incidents WHEN NOT EXISTS (SELECT 1 FROM sync_state WHERE name = \'applying\') BEGIN DELETE FROM sync_outbox WHERE entity = \'incidents\' AND row_key = NEW.id;INSERT INTO sync_outbox (entity, row_key) VALUES (\'incidents\', NEW.id);END',
    'incidents_outbox_insert',
  );
  late final Trigger incidentsOutboxUpdate = Trigger(
    'CREATE TRIGGER incidents_outbox_update AFTER UPDATE ON incidents WHEN NOT EXISTS (SELECT 1 FROM sync_state WHERE name = \'applying\') BEGIN DELETE FROM sync_outbox WHERE entity = \'incidents\' AND row_key = NEW.id;INSERT INTO sync_outbox (entity, row_key) VALUES (\'incidents\', NEW.id);END',
    'incidents_outbox_update',
  );
  late final Trigger incidentsOutboxDelete = Trigger(
    'CREATE TRIGGER incidents_outbox_delete AFTER DELETE ON incidents WHEN NOT EXISTS (SELECT 1 FROM sync_state WHERE name = \'applying\') BEGIN DELETE FROM sync_outbox WHERE entity = \'incidents\' AND row_key = OLD.id;INSERT INTO sync_outbox (entity, row_key) VALUES (\'incidents\', OLD.id);END',
    'incidents_outbox_delete',
  );
  late final $InventoryMovementsTable inventoryMovements =
      $InventoryMovementsTable(this);
  late final Trigger inventoryMovementsOutboxInsert = Trigger(
    'CREATE TRIGGER inventory_movements_outbox_insert AFTER INSERT ON inventory_movements WHEN NOT EXISTS (SELECT 1 FROM sync_state WHERE name = \'applying\') BEGIN DELETE FROM sync_outbox WHERE entity = \'inventory_movements\' AND row_key = NEW.id;INSERT INTO sync_outbox (entity, row_key) VALUES (\'inventory_movements\', NEW.id);END',
    'inventory_movements_outbox_insert',
  );
  late final Trigger inventoryMovementsOutboxUpdate = Trigger(
    'CREATE TRIGGER inventory_movements_outbox_update AFTER UPDATE ON inventory_movements WHEN NOT EXISTS (SELECT 1 FROM sync_state WHERE name = \'applying\') BEGIN DELETE FROM sync_outbox WHERE entity = \'inventory_movements\' AND row_key = NEW.id;INSERT INTO sync_outbox (entity, row_key) VALUES (\'inventory_movements\', NEW.id);END',
    'inventory_movements_outbox_update',
  );
  late final Trigger inventoryMovementsOutboxDelete = Trigger(
    'CREATE TRIGGER inventory_movements_outbox_delete AFTER DELETE ON inventory_movements WHEN NOT EXISTS (SELECT 1 FROM sync_state WHERE name = \'applying\') BEGIN DELETE FROM sync_outbox WHERE entity = \'inventory_movements\' AND row_key = OLD.id;INSERT INTO sync_outbox (entity, row_key) VALUES (\'inventory_movements\', OLD.id);END',
    'inventory_movements_outbox_delete',
  );
  late final $SettingEntriesTable settingEntries = $SettingEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    syncOutbox,
    syncState,
    gardens,
    gardensOutboxInsert,
    gardensOutboxUpdate,
    gardensOutboxDelete,
    zones,
    zonesOutboxInsert,
    zonesOutboxUpdate,
    zonesOutboxDelete,
    inventoryItems,
    inventoryItemsOutboxInsert,
    inventoryItemsOutboxUpdate,
    inventoryItemsOutboxDelete,
    incidents,
    tasks,
    tasksOutboxInsert,
    tasksOutboxUpdate,
    tasksOutboxDelete,
    activities,
    activitiesOutboxInsert,
    activitiesOutboxUpdate,
    activitiesOutboxDelete,
    photos,
    photosOutboxInsert,
    photosOutboxUpdate,
    photosOutboxDelete,
    taskMaterials,
    taskMaterialsOutboxInsert,
    taskMaterialsOutboxUpdate,
    taskMaterialsOutboxDelete,
    activityMaterials,
    activityMaterialsOutboxInsert,
    activityMaterialsOutboxUpdate,
    activityMaterialsOutboxDelete,
    shoppingItems,
    shoppingItemsOutboxInsert,
    shoppingItemsOutboxUpdate,
    shoppingItemsOutboxDelete,
    assistantThreads,
    assistantThreadsOutboxInsert,
    assistantThreadsOutboxUpdate,
    assistantThreadsOutboxDelete,
    assistantMessages,
    assistantMessagesOutboxInsert,
    assistantMessagesOutboxUpdate,
    assistantMessagesOutboxDelete,
    incidentsOutboxInsert,
    incidentsOutboxUpdate,
    incidentsOutboxDelete,
    inventoryMovements,
    inventoryMovementsOutboxInsert,
    inventoryMovementsOutboxUpdate,
    inventoryMovementsOutboxDelete,
    settingEntries,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'gardens',
        limitUpdateKind: UpdateKind.insert,
      ),
      result: [
        TableUpdate('sync_outbox', kind: UpdateKind.delete),
        TableUpdate('sync_outbox', kind: UpdateKind.insert),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'gardens',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [
        TableUpdate('sync_outbox', kind: UpdateKind.delete),
        TableUpdate('sync_outbox', kind: UpdateKind.insert),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'gardens',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('sync_outbox', kind: UpdateKind.delete),
        TableUpdate('sync_outbox', kind: UpdateKind.insert),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'zones',
        limitUpdateKind: UpdateKind.insert,
      ),
      result: [
        TableUpdate('sync_outbox', kind: UpdateKind.delete),
        TableUpdate('sync_outbox', kind: UpdateKind.insert),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'zones',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [
        TableUpdate('sync_outbox', kind: UpdateKind.delete),
        TableUpdate('sync_outbox', kind: UpdateKind.insert),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'zones',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('sync_outbox', kind: UpdateKind.delete),
        TableUpdate('sync_outbox', kind: UpdateKind.insert),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'inventory_items',
        limitUpdateKind: UpdateKind.insert,
      ),
      result: [
        TableUpdate('sync_outbox', kind: UpdateKind.delete),
        TableUpdate('sync_outbox', kind: UpdateKind.insert),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'inventory_items',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [
        TableUpdate('sync_outbox', kind: UpdateKind.delete),
        TableUpdate('sync_outbox', kind: UpdateKind.insert),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'inventory_items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('sync_outbox', kind: UpdateKind.delete),
        TableUpdate('sync_outbox', kind: UpdateKind.insert),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tasks',
        limitUpdateKind: UpdateKind.insert,
      ),
      result: [
        TableUpdate('sync_outbox', kind: UpdateKind.delete),
        TableUpdate('sync_outbox', kind: UpdateKind.insert),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tasks',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [
        TableUpdate('sync_outbox', kind: UpdateKind.delete),
        TableUpdate('sync_outbox', kind: UpdateKind.insert),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tasks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('sync_outbox', kind: UpdateKind.delete),
        TableUpdate('sync_outbox', kind: UpdateKind.insert),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'activities',
        limitUpdateKind: UpdateKind.insert,
      ),
      result: [
        TableUpdate('sync_outbox', kind: UpdateKind.delete),
        TableUpdate('sync_outbox', kind: UpdateKind.insert),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'activities',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [
        TableUpdate('sync_outbox', kind: UpdateKind.delete),
        TableUpdate('sync_outbox', kind: UpdateKind.insert),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'activities',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('sync_outbox', kind: UpdateKind.delete),
        TableUpdate('sync_outbox', kind: UpdateKind.insert),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'photos',
        limitUpdateKind: UpdateKind.insert,
      ),
      result: [
        TableUpdate('sync_outbox', kind: UpdateKind.delete),
        TableUpdate('sync_outbox', kind: UpdateKind.insert),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'photos',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [
        TableUpdate('sync_outbox', kind: UpdateKind.delete),
        TableUpdate('sync_outbox', kind: UpdateKind.insert),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'photos',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('sync_outbox', kind: UpdateKind.delete),
        TableUpdate('sync_outbox', kind: UpdateKind.insert),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'task_materials',
        limitUpdateKind: UpdateKind.insert,
      ),
      result: [
        TableUpdate('sync_outbox', kind: UpdateKind.delete),
        TableUpdate('sync_outbox', kind: UpdateKind.insert),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'task_materials',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [
        TableUpdate('sync_outbox', kind: UpdateKind.delete),
        TableUpdate('sync_outbox', kind: UpdateKind.insert),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'task_materials',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('sync_outbox', kind: UpdateKind.delete),
        TableUpdate('sync_outbox', kind: UpdateKind.insert),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'activity_materials',
        limitUpdateKind: UpdateKind.insert,
      ),
      result: [
        TableUpdate('sync_outbox', kind: UpdateKind.delete),
        TableUpdate('sync_outbox', kind: UpdateKind.insert),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'activity_materials',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [
        TableUpdate('sync_outbox', kind: UpdateKind.delete),
        TableUpdate('sync_outbox', kind: UpdateKind.insert),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'activity_materials',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('sync_outbox', kind: UpdateKind.delete),
        TableUpdate('sync_outbox', kind: UpdateKind.insert),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'shopping_items',
        limitUpdateKind: UpdateKind.insert,
      ),
      result: [
        TableUpdate('sync_outbox', kind: UpdateKind.delete),
        TableUpdate('sync_outbox', kind: UpdateKind.insert),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'shopping_items',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [
        TableUpdate('sync_outbox', kind: UpdateKind.delete),
        TableUpdate('sync_outbox', kind: UpdateKind.insert),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'shopping_items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('sync_outbox', kind: UpdateKind.delete),
        TableUpdate('sync_outbox', kind: UpdateKind.insert),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'assistant_threads',
        limitUpdateKind: UpdateKind.insert,
      ),
      result: [
        TableUpdate('sync_outbox', kind: UpdateKind.delete),
        TableUpdate('sync_outbox', kind: UpdateKind.insert),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'assistant_threads',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [
        TableUpdate('sync_outbox', kind: UpdateKind.delete),
        TableUpdate('sync_outbox', kind: UpdateKind.insert),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'assistant_threads',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('sync_outbox', kind: UpdateKind.delete),
        TableUpdate('sync_outbox', kind: UpdateKind.insert),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'assistant_messages',
        limitUpdateKind: UpdateKind.insert,
      ),
      result: [
        TableUpdate('sync_outbox', kind: UpdateKind.delete),
        TableUpdate('sync_outbox', kind: UpdateKind.insert),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'assistant_messages',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [
        TableUpdate('sync_outbox', kind: UpdateKind.delete),
        TableUpdate('sync_outbox', kind: UpdateKind.insert),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'assistant_messages',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('sync_outbox', kind: UpdateKind.delete),
        TableUpdate('sync_outbox', kind: UpdateKind.insert),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'incidents',
        limitUpdateKind: UpdateKind.insert,
      ),
      result: [
        TableUpdate('sync_outbox', kind: UpdateKind.delete),
        TableUpdate('sync_outbox', kind: UpdateKind.insert),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'incidents',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [
        TableUpdate('sync_outbox', kind: UpdateKind.delete),
        TableUpdate('sync_outbox', kind: UpdateKind.insert),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'incidents',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('sync_outbox', kind: UpdateKind.delete),
        TableUpdate('sync_outbox', kind: UpdateKind.insert),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'inventory_movements',
        limitUpdateKind: UpdateKind.insert,
      ),
      result: [
        TableUpdate('sync_outbox', kind: UpdateKind.delete),
        TableUpdate('sync_outbox', kind: UpdateKind.insert),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'inventory_movements',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [
        TableUpdate('sync_outbox', kind: UpdateKind.delete),
        TableUpdate('sync_outbox', kind: UpdateKind.insert),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'inventory_movements',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('sync_outbox', kind: UpdateKind.delete),
        TableUpdate('sync_outbox', kind: UpdateKind.insert),
      ],
    ),
  ]);
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $SyncOutboxCreateCompanionBuilder =
    SyncOutboxCompanion Function({
      Value<int> seq,
      required String entity,
      required String rowKey,
    });
typedef $SyncOutboxUpdateCompanionBuilder =
    SyncOutboxCompanion Function({
      Value<int> seq,
      Value<String> entity,
      Value<String> rowKey,
    });

class $SyncOutboxFilterComposer extends Composer<_$AppDatabase, SyncOutbox> {
  $SyncOutboxFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rowKey => $composableBuilder(
    column: $table.rowKey,
    builder: (column) => ColumnFilters(column),
  );
}

class $SyncOutboxOrderingComposer extends Composer<_$AppDatabase, SyncOutbox> {
  $SyncOutboxOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rowKey => $composableBuilder(
    column: $table.rowKey,
    builder: (column) => ColumnOrderings(column),
  );
}

class $SyncOutboxAnnotationComposer
    extends Composer<_$AppDatabase, SyncOutbox> {
  $SyncOutboxAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get rowKey =>
      $composableBuilder(column: $table.rowKey, builder: (column) => column);
}

class $SyncOutboxTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          SyncOutbox,
          SyncOutboxRow,
          $SyncOutboxFilterComposer,
          $SyncOutboxOrderingComposer,
          $SyncOutboxAnnotationComposer,
          $SyncOutboxCreateCompanionBuilder,
          $SyncOutboxUpdateCompanionBuilder,
          (
            SyncOutboxRow,
            BaseReferences<_$AppDatabase, SyncOutbox, SyncOutboxRow>,
          ),
          SyncOutboxRow,
          PrefetchHooks Function()
        > {
  $SyncOutboxTableManager(_$AppDatabase db, SyncOutbox table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $SyncOutboxFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $SyncOutboxOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $SyncOutboxAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> seq = const Value.absent(),
                Value<String> entity = const Value.absent(),
                Value<String> rowKey = const Value.absent(),
              }) =>
                  SyncOutboxCompanion(seq: seq, entity: entity, rowKey: rowKey),
          createCompanionCallback:
              ({
                Value<int> seq = const Value.absent(),
                required String entity,
                required String rowKey,
              }) => SyncOutboxCompanion.insert(
                seq: seq,
                entity: entity,
                rowKey: rowKey,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<SyncOutbox, SyncOutboxRow>(table),
                  BaseReferences<_$AppDatabase, SyncOutbox, SyncOutboxRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $SyncOutboxProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      SyncOutbox,
      SyncOutboxRow,
      $SyncOutboxFilterComposer,
      $SyncOutboxOrderingComposer,
      $SyncOutboxAnnotationComposer,
      $SyncOutboxCreateCompanionBuilder,
      $SyncOutboxUpdateCompanionBuilder,
      (SyncOutboxRow, BaseReferences<_$AppDatabase, SyncOutbox, SyncOutboxRow>),
      SyncOutboxRow,
      PrefetchHooks Function()
    >;
typedef $SyncStateCreateCompanionBuilder =
    SyncStateCompanion Function({
      required String name,
      Value<String?> value,
      Value<int> rowid,
    });
typedef $SyncStateUpdateCompanionBuilder =
    SyncStateCompanion Function({
      Value<String> name,
      Value<String?> value,
      Value<int> rowid,
    });

class $SyncStateFilterComposer extends Composer<_$AppDatabase, SyncState> {
  $SyncStateFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $SyncStateOrderingComposer extends Composer<_$AppDatabase, SyncState> {
  $SyncStateOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $SyncStateAnnotationComposer extends Composer<_$AppDatabase, SyncState> {
  $SyncStateAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $SyncStateTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          SyncState,
          SyncStateRow,
          $SyncStateFilterComposer,
          $SyncStateOrderingComposer,
          $SyncStateAnnotationComposer,
          $SyncStateCreateCompanionBuilder,
          $SyncStateUpdateCompanionBuilder,
          (
            SyncStateRow,
            BaseReferences<_$AppDatabase, SyncState, SyncStateRow>,
          ),
          SyncStateRow,
          PrefetchHooks Function()
        > {
  $SyncStateTableManager(_$AppDatabase db, SyncState table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $SyncStateFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $SyncStateOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $SyncStateAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> name = const Value.absent(),
                Value<String?> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncStateCompanion(name: name, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String name,
                Value<String?> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncStateCompanion.insert(
                name: name,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<SyncState, SyncStateRow>(table),
                  BaseReferences<_$AppDatabase, SyncState, SyncStateRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $SyncStateProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      SyncState,
      SyncStateRow,
      $SyncStateFilterComposer,
      $SyncStateOrderingComposer,
      $SyncStateAnnotationComposer,
      $SyncStateCreateCompanionBuilder,
      $SyncStateUpdateCompanionBuilder,
      (SyncStateRow, BaseReferences<_$AppDatabase, SyncState, SyncStateRow>),
      SyncStateRow,
      PrefetchHooks Function()
    >;
typedef $$GardensTableCreateCompanionBuilder =
    GardensCompanion Function({
      required String id,
      required String name,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<String?> bounds,
      Value<double?> locationLat,
      Value<double?> locationLng,
      Value<int?> altitudeM,
      Value<int> rowid,
    });
typedef $$GardensTableUpdateCompanionBuilder =
    GardensCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String?> bounds,
      Value<double?> locationLat,
      Value<double?> locationLng,
      Value<int?> altitudeM,
      Value<int> rowid,
    });

final class $$GardensTableReferences
    extends BaseReferences<_$AppDatabase, $GardensTable, GardenRow> {
  $$GardensTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ZonesTable, List<ZoneRow>> _zonesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.zones,
    aliasName: 'gardens__id__zones__garden_id',
  );

  $$ZonesTableProcessedTableManager get zonesRefs {
    final manager = $$ZonesTableTableManager(
      $_db,
      $_db.zones,
    ).filter((f) => f.gardenId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_zonesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$InventoryItemsTable, List<InventoryItemRow>>
  _inventoryItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.inventoryItems,
    aliasName: 'gardens__id__inventory_items__garden_id',
  );

  $$InventoryItemsTableProcessedTableManager get inventoryItemsRefs {
    final manager = $$InventoryItemsTableTableManager(
      $_db,
      $_db.inventoryItems,
    ).filter((f) => f.gardenId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_inventoryItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$IncidentsTable, List<IncidentRow>>
  _incidentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.incidents,
    aliasName: 'gardens__id__incidents__garden_id',
  );

  $$IncidentsTableProcessedTableManager get incidentsRefs {
    final manager = $$IncidentsTableTableManager(
      $_db,
      $_db.incidents,
    ).filter((f) => f.gardenId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_incidentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TasksTable, List<TaskRow>> _tasksRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.tasks,
    aliasName: 'gardens__id__tasks__garden_id',
  );

  $$TasksTableProcessedTableManager get tasksRefs {
    final manager = $$TasksTableTableManager(
      $_db,
      $_db.tasks,
    ).filter((f) => f.gardenId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tasksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ActivitiesTable, List<ActivityRow>>
  _activitiesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.activities,
    aliasName: 'gardens__id__activities__garden_id',
  );

  $$ActivitiesTableProcessedTableManager get activitiesRefs {
    final manager = $$ActivitiesTableTableManager(
      $_db,
      $_db.activities,
    ).filter((f) => f.gardenId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_activitiesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PhotosTable, List<PhotoRow>> _photosRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.photos,
    aliasName: 'gardens__id__photos__garden_id',
  );

  $$PhotosTableProcessedTableManager get photosRefs {
    final manager = $$PhotosTableTableManager(
      $_db,
      $_db.photos,
    ).filter((f) => f.gardenId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_photosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TaskMaterialsTable, List<TaskMaterialRow>>
  _taskMaterialsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.taskMaterials,
    aliasName: 'gardens__id__task_materials__garden_id',
  );

  $$TaskMaterialsTableProcessedTableManager get taskMaterialsRefs {
    final manager = $$TaskMaterialsTableTableManager(
      $_db,
      $_db.taskMaterials,
    ).filter((f) => f.gardenId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_taskMaterialsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ActivityMaterialsTable, List<ActivityMaterialRow>>
  _activityMaterialsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.activityMaterials,
        aliasName: 'gardens__id__activity_materials__garden_id',
      );

  $$ActivityMaterialsTableProcessedTableManager get activityMaterialsRefs {
    final manager = $$ActivityMaterialsTableTableManager(
      $_db,
      $_db.activityMaterials,
    ).filter((f) => f.gardenId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _activityMaterialsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ShoppingItemsTable, List<ShoppingItemRow>>
  _shoppingItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.shoppingItems,
    aliasName: 'gardens__id__shopping_items__garden_id',
  );

  $$ShoppingItemsTableProcessedTableManager get shoppingItemsRefs {
    final manager = $$ShoppingItemsTableTableManager(
      $_db,
      $_db.shoppingItems,
    ).filter((f) => f.gardenId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_shoppingItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AssistantThreadsTable, List<AssistantThreadRow>>
  _assistantThreadsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.assistantThreads,
    aliasName: 'gardens__id__assistant_threads__garden_id',
  );

  $$AssistantThreadsTableProcessedTableManager get assistantThreadsRefs {
    final manager = $$AssistantThreadsTableTableManager(
      $_db,
      $_db.assistantThreads,
    ).filter((f) => f.gardenId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _assistantThreadsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $InventoryMovementsTable,
    List<InventoryMovementRow>
  >
  _inventoryMovementsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.inventoryMovements,
        aliasName: 'gardens__id__inventory_movements__garden_id',
      );

  $$InventoryMovementsTableProcessedTableManager get inventoryMovementsRefs {
    final manager = $$InventoryMovementsTableTableManager(
      $_db,
      $_db.inventoryMovements,
    ).filter((f) => f.gardenId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _inventoryMovementsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GardensTableFilterComposer
    extends Composer<_$AppDatabase, $GardensTable> {
  $$GardensTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bounds => $composableBuilder(
    column: $table.bounds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get locationLat => $composableBuilder(
    column: $table.locationLat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get locationLng => $composableBuilder(
    column: $table.locationLng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get altitudeM => $composableBuilder(
    column: $table.altitudeM,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> zonesRefs(
    Expression<bool> Function($$ZonesTableFilterComposer f) f,
  ) {
    final $$ZonesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.zones,
      getReferencedColumn: (t) => t.gardenId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ZonesTableFilterComposer(
            $db: $db,
            $table: $db.zones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> inventoryItemsRefs(
    Expression<bool> Function($$InventoryItemsTableFilterComposer f) f,
  ) {
    final $$InventoryItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.inventoryItems,
      getReferencedColumn: (t) => t.gardenId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InventoryItemsTableFilterComposer(
            $db: $db,
            $table: $db.inventoryItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> incidentsRefs(
    Expression<bool> Function($$IncidentsTableFilterComposer f) f,
  ) {
    final $$IncidentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.incidents,
      getReferencedColumn: (t) => t.gardenId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IncidentsTableFilterComposer(
            $db: $db,
            $table: $db.incidents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> tasksRefs(
    Expression<bool> Function($$TasksTableFilterComposer f) f,
  ) {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.gardenId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> activitiesRefs(
    Expression<bool> Function($$ActivitiesTableFilterComposer f) f,
  ) {
    final $$ActivitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.gardenId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableFilterComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> photosRefs(
    Expression<bool> Function($$PhotosTableFilterComposer f) f,
  ) {
    final $$PhotosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.photos,
      getReferencedColumn: (t) => t.gardenId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhotosTableFilterComposer(
            $db: $db,
            $table: $db.photos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> taskMaterialsRefs(
    Expression<bool> Function($$TaskMaterialsTableFilterComposer f) f,
  ) {
    final $$TaskMaterialsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskMaterials,
      getReferencedColumn: (t) => t.gardenId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskMaterialsTableFilterComposer(
            $db: $db,
            $table: $db.taskMaterials,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> activityMaterialsRefs(
    Expression<bool> Function($$ActivityMaterialsTableFilterComposer f) f,
  ) {
    final $$ActivityMaterialsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.activityMaterials,
      getReferencedColumn: (t) => t.gardenId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivityMaterialsTableFilterComposer(
            $db: $db,
            $table: $db.activityMaterials,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> shoppingItemsRefs(
    Expression<bool> Function($$ShoppingItemsTableFilterComposer f) f,
  ) {
    final $$ShoppingItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.shoppingItems,
      getReferencedColumn: (t) => t.gardenId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShoppingItemsTableFilterComposer(
            $db: $db,
            $table: $db.shoppingItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> assistantThreadsRefs(
    Expression<bool> Function($$AssistantThreadsTableFilterComposer f) f,
  ) {
    final $$AssistantThreadsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.assistantThreads,
      getReferencedColumn: (t) => t.gardenId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssistantThreadsTableFilterComposer(
            $db: $db,
            $table: $db.assistantThreads,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> inventoryMovementsRefs(
    Expression<bool> Function($$InventoryMovementsTableFilterComposer f) f,
  ) {
    final $$InventoryMovementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.inventoryMovements,
      getReferencedColumn: (t) => t.gardenId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InventoryMovementsTableFilterComposer(
            $db: $db,
            $table: $db.inventoryMovements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GardensTableOrderingComposer
    extends Composer<_$AppDatabase, $GardensTable> {
  $$GardensTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bounds => $composableBuilder(
    column: $table.bounds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get locationLat => $composableBuilder(
    column: $table.locationLat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get locationLng => $composableBuilder(
    column: $table.locationLng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get altitudeM => $composableBuilder(
    column: $table.altitudeM,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GardensTableAnnotationComposer
    extends Composer<_$AppDatabase, $GardensTable> {
  $$GardensTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get bounds =>
      $composableBuilder(column: $table.bounds, builder: (column) => column);

  GeneratedColumn<double> get locationLat => $composableBuilder(
    column: $table.locationLat,
    builder: (column) => column,
  );

  GeneratedColumn<double> get locationLng => $composableBuilder(
    column: $table.locationLng,
    builder: (column) => column,
  );

  GeneratedColumn<int> get altitudeM =>
      $composableBuilder(column: $table.altitudeM, builder: (column) => column);

  Expression<T> zonesRefs<T extends Object>(
    Expression<T> Function($$ZonesTableAnnotationComposer a) f,
  ) {
    final $$ZonesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.zones,
      getReferencedColumn: (t) => t.gardenId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ZonesTableAnnotationComposer(
            $db: $db,
            $table: $db.zones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> inventoryItemsRefs<T extends Object>(
    Expression<T> Function($$InventoryItemsTableAnnotationComposer a) f,
  ) {
    final $$InventoryItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.inventoryItems,
      getReferencedColumn: (t) => t.gardenId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InventoryItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.inventoryItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> incidentsRefs<T extends Object>(
    Expression<T> Function($$IncidentsTableAnnotationComposer a) f,
  ) {
    final $$IncidentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.incidents,
      getReferencedColumn: (t) => t.gardenId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IncidentsTableAnnotationComposer(
            $db: $db,
            $table: $db.incidents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> tasksRefs<T extends Object>(
    Expression<T> Function($$TasksTableAnnotationComposer a) f,
  ) {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.gardenId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> activitiesRefs<T extends Object>(
    Expression<T> Function($$ActivitiesTableAnnotationComposer a) f,
  ) {
    final $$ActivitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.gardenId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> photosRefs<T extends Object>(
    Expression<T> Function($$PhotosTableAnnotationComposer a) f,
  ) {
    final $$PhotosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.photos,
      getReferencedColumn: (t) => t.gardenId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhotosTableAnnotationComposer(
            $db: $db,
            $table: $db.photos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> taskMaterialsRefs<T extends Object>(
    Expression<T> Function($$TaskMaterialsTableAnnotationComposer a) f,
  ) {
    final $$TaskMaterialsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskMaterials,
      getReferencedColumn: (t) => t.gardenId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskMaterialsTableAnnotationComposer(
            $db: $db,
            $table: $db.taskMaterials,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> activityMaterialsRefs<T extends Object>(
    Expression<T> Function($$ActivityMaterialsTableAnnotationComposer a) f,
  ) {
    final $$ActivityMaterialsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.activityMaterials,
          getReferencedColumn: (t) => t.gardenId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ActivityMaterialsTableAnnotationComposer(
                $db: $db,
                $table: $db.activityMaterials,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> shoppingItemsRefs<T extends Object>(
    Expression<T> Function($$ShoppingItemsTableAnnotationComposer a) f,
  ) {
    final $$ShoppingItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.shoppingItems,
      getReferencedColumn: (t) => t.gardenId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShoppingItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.shoppingItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> assistantThreadsRefs<T extends Object>(
    Expression<T> Function($$AssistantThreadsTableAnnotationComposer a) f,
  ) {
    final $$AssistantThreadsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.assistantThreads,
      getReferencedColumn: (t) => t.gardenId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssistantThreadsTableAnnotationComposer(
            $db: $db,
            $table: $db.assistantThreads,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> inventoryMovementsRefs<T extends Object>(
    Expression<T> Function($$InventoryMovementsTableAnnotationComposer a) f,
  ) {
    final $$InventoryMovementsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.inventoryMovements,
          getReferencedColumn: (t) => t.gardenId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$InventoryMovementsTableAnnotationComposer(
                $db: $db,
                $table: $db.inventoryMovements,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$GardensTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GardensTable,
          GardenRow,
          $$GardensTableFilterComposer,
          $$GardensTableOrderingComposer,
          $$GardensTableAnnotationComposer,
          $$GardensTableCreateCompanionBuilder,
          $$GardensTableUpdateCompanionBuilder,
          (GardenRow, $$GardensTableReferences),
          GardenRow,
          PrefetchHooks Function({
            bool zonesRefs,
            bool inventoryItemsRefs,
            bool incidentsRefs,
            bool tasksRefs,
            bool activitiesRefs,
            bool photosRefs,
            bool taskMaterialsRefs,
            bool activityMaterialsRefs,
            bool shoppingItemsRefs,
            bool assistantThreadsRefs,
            bool inventoryMovementsRefs,
          })
        > {
  $$GardensTableTableManager(_$AppDatabase db, $GardensTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GardensTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GardensTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GardensTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> bounds = const Value.absent(),
                Value<double?> locationLat = const Value.absent(),
                Value<double?> locationLng = const Value.absent(),
                Value<int?> altitudeM = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GardensCompanion(
                id: id,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
                bounds: bounds,
                locationLat: locationLat,
                locationLng: locationLng,
                altitudeM: altitudeM,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<String?> bounds = const Value.absent(),
                Value<double?> locationLat = const Value.absent(),
                Value<double?> locationLng = const Value.absent(),
                Value<int?> altitudeM = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GardensCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
                bounds: bounds,
                locationLat: locationLat,
                locationLng: locationLng,
                altitudeM: altitudeM,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GardensTable, GardenRow>(table),
                  $$GardensTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                zonesRefs = false,
                inventoryItemsRefs = false,
                incidentsRefs = false,
                tasksRefs = false,
                activitiesRefs = false,
                photosRefs = false,
                taskMaterialsRefs = false,
                activityMaterialsRefs = false,
                shoppingItemsRefs = false,
                assistantThreadsRefs = false,
                inventoryMovementsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (zonesRefs) db.zones,
                    if (inventoryItemsRefs) db.inventoryItems,
                    if (incidentsRefs) db.incidents,
                    if (tasksRefs) db.tasks,
                    if (activitiesRefs) db.activities,
                    if (photosRefs) db.photos,
                    if (taskMaterialsRefs) db.taskMaterials,
                    if (activityMaterialsRefs) db.activityMaterials,
                    if (shoppingItemsRefs) db.shoppingItems,
                    if (assistantThreadsRefs) db.assistantThreads,
                    if (inventoryMovementsRefs) db.inventoryMovements,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (zonesRefs)
                        await $_getPrefetchedData<
                          GardenRow,
                          $GardensTable,
                          ZoneRow
                        >(
                          currentTable: table,
                          referencedTable: $$GardensTableReferences
                              ._zonesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GardensTableReferences(db, table, p0).zonesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.gardenId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (inventoryItemsRefs)
                        await $_getPrefetchedData<
                          GardenRow,
                          $GardensTable,
                          InventoryItemRow
                        >(
                          currentTable: table,
                          referencedTable: $$GardensTableReferences
                              ._inventoryItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GardensTableReferences(
                                db,
                                table,
                                p0,
                              ).inventoryItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.gardenId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (incidentsRefs)
                        await $_getPrefetchedData<
                          GardenRow,
                          $GardensTable,
                          IncidentRow
                        >(
                          currentTable: table,
                          referencedTable: $$GardensTableReferences
                              ._incidentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GardensTableReferences(
                                db,
                                table,
                                p0,
                              ).incidentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.gardenId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (tasksRefs)
                        await $_getPrefetchedData<
                          GardenRow,
                          $GardensTable,
                          TaskRow
                        >(
                          currentTable: table,
                          referencedTable: $$GardensTableReferences
                              ._tasksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GardensTableReferences(db, table, p0).tasksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.gardenId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (activitiesRefs)
                        await $_getPrefetchedData<
                          GardenRow,
                          $GardensTable,
                          ActivityRow
                        >(
                          currentTable: table,
                          referencedTable: $$GardensTableReferences
                              ._activitiesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GardensTableReferences(
                                db,
                                table,
                                p0,
                              ).activitiesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.gardenId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (photosRefs)
                        await $_getPrefetchedData<
                          GardenRow,
                          $GardensTable,
                          PhotoRow
                        >(
                          currentTable: table,
                          referencedTable: $$GardensTableReferences
                              ._photosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GardensTableReferences(
                                db,
                                table,
                                p0,
                              ).photosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.gardenId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (taskMaterialsRefs)
                        await $_getPrefetchedData<
                          GardenRow,
                          $GardensTable,
                          TaskMaterialRow
                        >(
                          currentTable: table,
                          referencedTable: $$GardensTableReferences
                              ._taskMaterialsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GardensTableReferences(
                                db,
                                table,
                                p0,
                              ).taskMaterialsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.gardenId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (activityMaterialsRefs)
                        await $_getPrefetchedData<
                          GardenRow,
                          $GardensTable,
                          ActivityMaterialRow
                        >(
                          currentTable: table,
                          referencedTable: $$GardensTableReferences
                              ._activityMaterialsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GardensTableReferences(
                                db,
                                table,
                                p0,
                              ).activityMaterialsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.gardenId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (shoppingItemsRefs)
                        await $_getPrefetchedData<
                          GardenRow,
                          $GardensTable,
                          ShoppingItemRow
                        >(
                          currentTable: table,
                          referencedTable: $$GardensTableReferences
                              ._shoppingItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GardensTableReferences(
                                db,
                                table,
                                p0,
                              ).shoppingItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.gardenId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (assistantThreadsRefs)
                        await $_getPrefetchedData<
                          GardenRow,
                          $GardensTable,
                          AssistantThreadRow
                        >(
                          currentTable: table,
                          referencedTable: $$GardensTableReferences
                              ._assistantThreadsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GardensTableReferences(
                                db,
                                table,
                                p0,
                              ).assistantThreadsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.gardenId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (inventoryMovementsRefs)
                        await $_getPrefetchedData<
                          GardenRow,
                          $GardensTable,
                          InventoryMovementRow
                        >(
                          currentTable: table,
                          referencedTable: $$GardensTableReferences
                              ._inventoryMovementsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GardensTableReferences(
                                db,
                                table,
                                p0,
                              ).inventoryMovementsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.gardenId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$GardensTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GardensTable,
      GardenRow,
      $$GardensTableFilterComposer,
      $$GardensTableOrderingComposer,
      $$GardensTableAnnotationComposer,
      $$GardensTableCreateCompanionBuilder,
      $$GardensTableUpdateCompanionBuilder,
      (GardenRow, $$GardensTableReferences),
      GardenRow,
      PrefetchHooks Function({
        bool zonesRefs,
        bool inventoryItemsRefs,
        bool incidentsRefs,
        bool tasksRefs,
        bool activitiesRefs,
        bool photosRefs,
        bool taskMaterialsRefs,
        bool activityMaterialsRefs,
        bool shoppingItemsRefs,
        bool assistantThreadsRefs,
        bool inventoryMovementsRefs,
      })
    >;
typedef $$ZonesTableCreateCompanionBuilder =
    ZonesCompanion Function({
      required String id,
      required String gardenId,
      required String name,
      Value<String> type,
      Value<bool> archived,
      Value<int?> sortOrder,
      Value<double?> areaM2,
      Value<String?> soilTexture,
      Value<double?> ph,
      Value<String?> phMeasuredAt,
      Value<String?> sunExposure,
      Value<String?> irrigation,
      Value<bool> covered,
      Value<String?> polygon,
      Value<String?> layer,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$ZonesTableUpdateCompanionBuilder =
    ZonesCompanion Function({
      Value<String> id,
      Value<String> gardenId,
      Value<String> name,
      Value<String> type,
      Value<bool> archived,
      Value<int?> sortOrder,
      Value<double?> areaM2,
      Value<String?> soilTexture,
      Value<double?> ph,
      Value<String?> phMeasuredAt,
      Value<String?> sunExposure,
      Value<String?> irrigation,
      Value<bool> covered,
      Value<String?> polygon,
      Value<String?> layer,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$ZonesTableReferences
    extends BaseReferences<_$AppDatabase, $ZonesTable, ZoneRow> {
  $$ZonesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GardensTable _gardenIdTable(_$AppDatabase db) =>
      db.gardens.createAlias('zones__garden_id__gardens__id');

  $$GardensTableProcessedTableManager get gardenId {
    final $_column = $_itemColumn<String>('garden_id')!;

    final manager = $$GardensTableTableManager(
      $_db,
      $_db.gardens,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gardenIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$IncidentsTable, List<IncidentRow>>
  _incidentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.incidents,
    aliasName: 'zones__id__incidents__zone_id',
  );

  $$IncidentsTableProcessedTableManager get incidentsRefs {
    final manager = $$IncidentsTableTableManager(
      $_db,
      $_db.incidents,
    ).filter((f) => f.zoneId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_incidentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TasksTable, List<TaskRow>> _tasksRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.tasks,
    aliasName: 'zones__id__tasks__zone_id',
  );

  $$TasksTableProcessedTableManager get tasksRefs {
    final manager = $$TasksTableTableManager(
      $_db,
      $_db.tasks,
    ).filter((f) => f.zoneId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tasksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ActivitiesTable, List<ActivityRow>>
  _activitiesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.activities,
    aliasName: 'zones__id__activities__zone_id',
  );

  $$ActivitiesTableProcessedTableManager get activitiesRefs {
    final manager = $$ActivitiesTableTableManager(
      $_db,
      $_db.activities,
    ).filter((f) => f.zoneId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_activitiesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ZonesTableFilterComposer extends Composer<_$AppDatabase, $ZonesTable> {
  $$ZonesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get areaM2 => $composableBuilder(
    column: $table.areaM2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get soilTexture => $composableBuilder(
    column: $table.soilTexture,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ph => $composableBuilder(
    column: $table.ph,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phMeasuredAt => $composableBuilder(
    column: $table.phMeasuredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sunExposure => $composableBuilder(
    column: $table.sunExposure,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get irrigation => $composableBuilder(
    column: $table.irrigation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get covered => $composableBuilder(
    column: $table.covered,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get polygon => $composableBuilder(
    column: $table.polygon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get layer => $composableBuilder(
    column: $table.layer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$GardensTableFilterComposer get gardenId {
    final $$GardensTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gardenId,
      referencedTable: $db.gardens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GardensTableFilterComposer(
            $db: $db,
            $table: $db.gardens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> incidentsRefs(
    Expression<bool> Function($$IncidentsTableFilterComposer f) f,
  ) {
    final $$IncidentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.incidents,
      getReferencedColumn: (t) => t.zoneId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IncidentsTableFilterComposer(
            $db: $db,
            $table: $db.incidents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> tasksRefs(
    Expression<bool> Function($$TasksTableFilterComposer f) f,
  ) {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.zoneId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> activitiesRefs(
    Expression<bool> Function($$ActivitiesTableFilterComposer f) f,
  ) {
    final $$ActivitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.zoneId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableFilterComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ZonesTableOrderingComposer
    extends Composer<_$AppDatabase, $ZonesTable> {
  $$ZonesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get areaM2 => $composableBuilder(
    column: $table.areaM2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get soilTexture => $composableBuilder(
    column: $table.soilTexture,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ph => $composableBuilder(
    column: $table.ph,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phMeasuredAt => $composableBuilder(
    column: $table.phMeasuredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sunExposure => $composableBuilder(
    column: $table.sunExposure,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get irrigation => $composableBuilder(
    column: $table.irrigation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get covered => $composableBuilder(
    column: $table.covered,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get polygon => $composableBuilder(
    column: $table.polygon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get layer => $composableBuilder(
    column: $table.layer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$GardensTableOrderingComposer get gardenId {
    final $$GardensTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gardenId,
      referencedTable: $db.gardens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GardensTableOrderingComposer(
            $db: $db,
            $table: $db.gardens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ZonesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ZonesTable> {
  $$ZonesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<double> get areaM2 =>
      $composableBuilder(column: $table.areaM2, builder: (column) => column);

  GeneratedColumn<String> get soilTexture => $composableBuilder(
    column: $table.soilTexture,
    builder: (column) => column,
  );

  GeneratedColumn<double> get ph =>
      $composableBuilder(column: $table.ph, builder: (column) => column);

  GeneratedColumn<String> get phMeasuredAt => $composableBuilder(
    column: $table.phMeasuredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sunExposure => $composableBuilder(
    column: $table.sunExposure,
    builder: (column) => column,
  );

  GeneratedColumn<String> get irrigation => $composableBuilder(
    column: $table.irrigation,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get covered =>
      $composableBuilder(column: $table.covered, builder: (column) => column);

  GeneratedColumn<String> get polygon =>
      $composableBuilder(column: $table.polygon, builder: (column) => column);

  GeneratedColumn<String> get layer =>
      $composableBuilder(column: $table.layer, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$GardensTableAnnotationComposer get gardenId {
    final $$GardensTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gardenId,
      referencedTable: $db.gardens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GardensTableAnnotationComposer(
            $db: $db,
            $table: $db.gardens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> incidentsRefs<T extends Object>(
    Expression<T> Function($$IncidentsTableAnnotationComposer a) f,
  ) {
    final $$IncidentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.incidents,
      getReferencedColumn: (t) => t.zoneId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IncidentsTableAnnotationComposer(
            $db: $db,
            $table: $db.incidents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> tasksRefs<T extends Object>(
    Expression<T> Function($$TasksTableAnnotationComposer a) f,
  ) {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.zoneId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> activitiesRefs<T extends Object>(
    Expression<T> Function($$ActivitiesTableAnnotationComposer a) f,
  ) {
    final $$ActivitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.zoneId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ZonesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ZonesTable,
          ZoneRow,
          $$ZonesTableFilterComposer,
          $$ZonesTableOrderingComposer,
          $$ZonesTableAnnotationComposer,
          $$ZonesTableCreateCompanionBuilder,
          $$ZonesTableUpdateCompanionBuilder,
          (ZoneRow, $$ZonesTableReferences),
          ZoneRow,
          PrefetchHooks Function({
            bool gardenId,
            bool incidentsRefs,
            bool tasksRefs,
            bool activitiesRefs,
          })
        > {
  $$ZonesTableTableManager(_$AppDatabase db, $ZonesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ZonesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ZonesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ZonesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> gardenId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int?> sortOrder = const Value.absent(),
                Value<double?> areaM2 = const Value.absent(),
                Value<String?> soilTexture = const Value.absent(),
                Value<double?> ph = const Value.absent(),
                Value<String?> phMeasuredAt = const Value.absent(),
                Value<String?> sunExposure = const Value.absent(),
                Value<String?> irrigation = const Value.absent(),
                Value<bool> covered = const Value.absent(),
                Value<String?> polygon = const Value.absent(),
                Value<String?> layer = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ZonesCompanion(
                id: id,
                gardenId: gardenId,
                name: name,
                type: type,
                archived: archived,
                sortOrder: sortOrder,
                areaM2: areaM2,
                soilTexture: soilTexture,
                ph: ph,
                phMeasuredAt: phMeasuredAt,
                sunExposure: sunExposure,
                irrigation: irrigation,
                covered: covered,
                polygon: polygon,
                layer: layer,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String gardenId,
                required String name,
                Value<String> type = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int?> sortOrder = const Value.absent(),
                Value<double?> areaM2 = const Value.absent(),
                Value<String?> soilTexture = const Value.absent(),
                Value<double?> ph = const Value.absent(),
                Value<String?> phMeasuredAt = const Value.absent(),
                Value<String?> sunExposure = const Value.absent(),
                Value<String?> irrigation = const Value.absent(),
                Value<bool> covered = const Value.absent(),
                Value<String?> polygon = const Value.absent(),
                Value<String?> layer = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ZonesCompanion.insert(
                id: id,
                gardenId: gardenId,
                name: name,
                type: type,
                archived: archived,
                sortOrder: sortOrder,
                areaM2: areaM2,
                soilTexture: soilTexture,
                ph: ph,
                phMeasuredAt: phMeasuredAt,
                sunExposure: sunExposure,
                irrigation: irrigation,
                covered: covered,
                polygon: polygon,
                layer: layer,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ZonesTable, ZoneRow>(table),
                  $$ZonesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                gardenId = false,
                incidentsRefs = false,
                tasksRefs = false,
                activitiesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (incidentsRefs) db.incidents,
                    if (tasksRefs) db.tasks,
                    if (activitiesRefs) db.activities,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (gardenId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.gardenId,
                                    referencedTable: $$ZonesTableReferences
                                        ._gardenIdTable(db),
                                    referencedColumn: $$ZonesTableReferences
                                        ._gardenIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (incidentsRefs)
                        await $_getPrefetchedData<
                          ZoneRow,
                          $ZonesTable,
                          IncidentRow
                        >(
                          currentTable: table,
                          referencedTable: $$ZonesTableReferences
                              ._incidentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ZonesTableReferences(
                                db,
                                table,
                                p0,
                              ).incidentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.zoneId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (tasksRefs)
                        await $_getPrefetchedData<
                          ZoneRow,
                          $ZonesTable,
                          TaskRow
                        >(
                          currentTable: table,
                          referencedTable: $$ZonesTableReferences
                              ._tasksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ZonesTableReferences(db, table, p0).tasksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.zoneId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (activitiesRefs)
                        await $_getPrefetchedData<
                          ZoneRow,
                          $ZonesTable,
                          ActivityRow
                        >(
                          currentTable: table,
                          referencedTable: $$ZonesTableReferences
                              ._activitiesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ZonesTableReferences(
                                db,
                                table,
                                p0,
                              ).activitiesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.zoneId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ZonesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ZonesTable,
      ZoneRow,
      $$ZonesTableFilterComposer,
      $$ZonesTableOrderingComposer,
      $$ZonesTableAnnotationComposer,
      $$ZonesTableCreateCompanionBuilder,
      $$ZonesTableUpdateCompanionBuilder,
      (ZoneRow, $$ZonesTableReferences),
      ZoneRow,
      PrefetchHooks Function({
        bool gardenId,
        bool incidentsRefs,
        bool tasksRefs,
        bool activitiesRefs,
      })
    >;
typedef $$InventoryItemsTableCreateCompanionBuilder =
    InventoryItemsCompanion Function({
      required String id,
      required String gardenId,
      required String category,
      required String name,
      required String unit,
      Value<double> stockQty,
      Value<double?> lowStockThreshold,
      Value<String?> details,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$InventoryItemsTableUpdateCompanionBuilder =
    InventoryItemsCompanion Function({
      Value<String> id,
      Value<String> gardenId,
      Value<String> category,
      Value<String> name,
      Value<String> unit,
      Value<double> stockQty,
      Value<double?> lowStockThreshold,
      Value<String?> details,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$InventoryItemsTableReferences
    extends
        BaseReferences<_$AppDatabase, $InventoryItemsTable, InventoryItemRow> {
  $$InventoryItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $GardensTable _gardenIdTable(_$AppDatabase db) =>
      db.gardens.createAlias('inventory_items__garden_id__gardens__id');

  $$GardensTableProcessedTableManager get gardenId {
    final $_column = $_itemColumn<String>('garden_id')!;

    final manager = $$GardensTableTableManager(
      $_db,
      $_db.gardens,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gardenIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TaskMaterialsTable, List<TaskMaterialRow>>
  _taskMaterialsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.taskMaterials,
    aliasName: 'inventory_items__id__task_materials__item_id',
  );

  $$TaskMaterialsTableProcessedTableManager get taskMaterialsRefs {
    final manager = $$TaskMaterialsTableTableManager(
      $_db,
      $_db.taskMaterials,
    ).filter((f) => f.itemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_taskMaterialsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ActivityMaterialsTable, List<ActivityMaterialRow>>
  _activityMaterialsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.activityMaterials,
        aliasName: 'inventory_items__id__activity_materials__item_id',
      );

  $$ActivityMaterialsTableProcessedTableManager get activityMaterialsRefs {
    final manager = $$ActivityMaterialsTableTableManager(
      $_db,
      $_db.activityMaterials,
    ).filter((f) => f.itemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _activityMaterialsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ShoppingItemsTable, List<ShoppingItemRow>>
  _shoppingItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.shoppingItems,
    aliasName: 'inventory_items__id__shopping_items__item_id',
  );

  $$ShoppingItemsTableProcessedTableManager get shoppingItemsRefs {
    final manager = $$ShoppingItemsTableTableManager(
      $_db,
      $_db.shoppingItems,
    ).filter((f) => f.itemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_shoppingItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $InventoryMovementsTable,
    List<InventoryMovementRow>
  >
  _inventoryMovementsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.inventoryMovements,
        aliasName: 'inventory_items__id__inventory_movements__item_id',
      );

  $$InventoryMovementsTableProcessedTableManager get inventoryMovementsRefs {
    final manager = $$InventoryMovementsTableTableManager(
      $_db,
      $_db.inventoryMovements,
    ).filter((f) => f.itemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _inventoryMovementsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$InventoryItemsTableFilterComposer
    extends Composer<_$AppDatabase, $InventoryItemsTable> {
  $$InventoryItemsTableFilterComposer({
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

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stockQty => $composableBuilder(
    column: $table.stockQty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lowStockThreshold => $composableBuilder(
    column: $table.lowStockThreshold,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get details => $composableBuilder(
    column: $table.details,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$GardensTableFilterComposer get gardenId {
    final $$GardensTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gardenId,
      referencedTable: $db.gardens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GardensTableFilterComposer(
            $db: $db,
            $table: $db.gardens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> taskMaterialsRefs(
    Expression<bool> Function($$TaskMaterialsTableFilterComposer f) f,
  ) {
    final $$TaskMaterialsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskMaterials,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskMaterialsTableFilterComposer(
            $db: $db,
            $table: $db.taskMaterials,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> activityMaterialsRefs(
    Expression<bool> Function($$ActivityMaterialsTableFilterComposer f) f,
  ) {
    final $$ActivityMaterialsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.activityMaterials,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivityMaterialsTableFilterComposer(
            $db: $db,
            $table: $db.activityMaterials,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> shoppingItemsRefs(
    Expression<bool> Function($$ShoppingItemsTableFilterComposer f) f,
  ) {
    final $$ShoppingItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.shoppingItems,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShoppingItemsTableFilterComposer(
            $db: $db,
            $table: $db.shoppingItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> inventoryMovementsRefs(
    Expression<bool> Function($$InventoryMovementsTableFilterComposer f) f,
  ) {
    final $$InventoryMovementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.inventoryMovements,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InventoryMovementsTableFilterComposer(
            $db: $db,
            $table: $db.inventoryMovements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$InventoryItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $InventoryItemsTable> {
  $$InventoryItemsTableOrderingComposer({
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

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stockQty => $composableBuilder(
    column: $table.stockQty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lowStockThreshold => $composableBuilder(
    column: $table.lowStockThreshold,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get details => $composableBuilder(
    column: $table.details,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$GardensTableOrderingComposer get gardenId {
    final $$GardensTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gardenId,
      referencedTable: $db.gardens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GardensTableOrderingComposer(
            $db: $db,
            $table: $db.gardens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InventoryItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InventoryItemsTable> {
  $$InventoryItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<double> get stockQty =>
      $composableBuilder(column: $table.stockQty, builder: (column) => column);

  GeneratedColumn<double> get lowStockThreshold => $composableBuilder(
    column: $table.lowStockThreshold,
    builder: (column) => column,
  );

  GeneratedColumn<String> get details =>
      $composableBuilder(column: $table.details, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$GardensTableAnnotationComposer get gardenId {
    final $$GardensTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gardenId,
      referencedTable: $db.gardens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GardensTableAnnotationComposer(
            $db: $db,
            $table: $db.gardens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> taskMaterialsRefs<T extends Object>(
    Expression<T> Function($$TaskMaterialsTableAnnotationComposer a) f,
  ) {
    final $$TaskMaterialsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskMaterials,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskMaterialsTableAnnotationComposer(
            $db: $db,
            $table: $db.taskMaterials,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> activityMaterialsRefs<T extends Object>(
    Expression<T> Function($$ActivityMaterialsTableAnnotationComposer a) f,
  ) {
    final $$ActivityMaterialsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.activityMaterials,
          getReferencedColumn: (t) => t.itemId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ActivityMaterialsTableAnnotationComposer(
                $db: $db,
                $table: $db.activityMaterials,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> shoppingItemsRefs<T extends Object>(
    Expression<T> Function($$ShoppingItemsTableAnnotationComposer a) f,
  ) {
    final $$ShoppingItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.shoppingItems,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShoppingItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.shoppingItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> inventoryMovementsRefs<T extends Object>(
    Expression<T> Function($$InventoryMovementsTableAnnotationComposer a) f,
  ) {
    final $$InventoryMovementsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.inventoryMovements,
          getReferencedColumn: (t) => t.itemId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$InventoryMovementsTableAnnotationComposer(
                $db: $db,
                $table: $db.inventoryMovements,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$InventoryItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InventoryItemsTable,
          InventoryItemRow,
          $$InventoryItemsTableFilterComposer,
          $$InventoryItemsTableOrderingComposer,
          $$InventoryItemsTableAnnotationComposer,
          $$InventoryItemsTableCreateCompanionBuilder,
          $$InventoryItemsTableUpdateCompanionBuilder,
          (InventoryItemRow, $$InventoryItemsTableReferences),
          InventoryItemRow,
          PrefetchHooks Function({
            bool gardenId,
            bool taskMaterialsRefs,
            bool activityMaterialsRefs,
            bool shoppingItemsRefs,
            bool inventoryMovementsRefs,
          })
        > {
  $$InventoryItemsTableTableManager(
    _$AppDatabase db,
    $InventoryItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InventoryItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InventoryItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InventoryItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> gardenId = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<double> stockQty = const Value.absent(),
                Value<double?> lowStockThreshold = const Value.absent(),
                Value<String?> details = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InventoryItemsCompanion(
                id: id,
                gardenId: gardenId,
                category: category,
                name: name,
                unit: unit,
                stockQty: stockQty,
                lowStockThreshold: lowStockThreshold,
                details: details,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String gardenId,
                required String category,
                required String name,
                required String unit,
                Value<double> stockQty = const Value.absent(),
                Value<double?> lowStockThreshold = const Value.absent(),
                Value<String?> details = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InventoryItemsCompanion.insert(
                id: id,
                gardenId: gardenId,
                category: category,
                name: name,
                unit: unit,
                stockQty: stockQty,
                lowStockThreshold: lowStockThreshold,
                details: details,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$InventoryItemsTable, InventoryItemRow>(table),
                  $$InventoryItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                gardenId = false,
                taskMaterialsRefs = false,
                activityMaterialsRefs = false,
                shoppingItemsRefs = false,
                inventoryMovementsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (taskMaterialsRefs) db.taskMaterials,
                    if (activityMaterialsRefs) db.activityMaterials,
                    if (shoppingItemsRefs) db.shoppingItems,
                    if (inventoryMovementsRefs) db.inventoryMovements,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (gardenId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.gardenId,
                                    referencedTable:
                                        $$InventoryItemsTableReferences
                                            ._gardenIdTable(db),
                                    referencedColumn:
                                        $$InventoryItemsTableReferences
                                            ._gardenIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (taskMaterialsRefs)
                        await $_getPrefetchedData<
                          InventoryItemRow,
                          $InventoryItemsTable,
                          TaskMaterialRow
                        >(
                          currentTable: table,
                          referencedTable: $$InventoryItemsTableReferences
                              ._taskMaterialsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$InventoryItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).taskMaterialsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.itemId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (activityMaterialsRefs)
                        await $_getPrefetchedData<
                          InventoryItemRow,
                          $InventoryItemsTable,
                          ActivityMaterialRow
                        >(
                          currentTable: table,
                          referencedTable: $$InventoryItemsTableReferences
                              ._activityMaterialsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$InventoryItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).activityMaterialsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.itemId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (shoppingItemsRefs)
                        await $_getPrefetchedData<
                          InventoryItemRow,
                          $InventoryItemsTable,
                          ShoppingItemRow
                        >(
                          currentTable: table,
                          referencedTable: $$InventoryItemsTableReferences
                              ._shoppingItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$InventoryItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).shoppingItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.itemId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (inventoryMovementsRefs)
                        await $_getPrefetchedData<
                          InventoryItemRow,
                          $InventoryItemsTable,
                          InventoryMovementRow
                        >(
                          currentTable: table,
                          referencedTable: $$InventoryItemsTableReferences
                              ._inventoryMovementsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$InventoryItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).inventoryMovementsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.itemId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$InventoryItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InventoryItemsTable,
      InventoryItemRow,
      $$InventoryItemsTableFilterComposer,
      $$InventoryItemsTableOrderingComposer,
      $$InventoryItemsTableAnnotationComposer,
      $$InventoryItemsTableCreateCompanionBuilder,
      $$InventoryItemsTableUpdateCompanionBuilder,
      (InventoryItemRow, $$InventoryItemsTableReferences),
      InventoryItemRow,
      PrefetchHooks Function({
        bool gardenId,
        bool taskMaterialsRefs,
        bool activityMaterialsRefs,
        bool shoppingItemsRefs,
        bool inventoryMovementsRefs,
      })
    >;
typedef $$IncidentsTableCreateCompanionBuilder =
    IncidentsCompanion Function({
      required String id,
      required String gardenId,
      required String zoneId,
      required String label,
      Value<String> source,
      Value<String?> candidates,
      Value<String?> planBio,
      Value<String?> planChem,
      Value<String> status,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$IncidentsTableUpdateCompanionBuilder =
    IncidentsCompanion Function({
      Value<String> id,
      Value<String> gardenId,
      Value<String> zoneId,
      Value<String> label,
      Value<String> source,
      Value<String?> candidates,
      Value<String?> planBio,
      Value<String?> planChem,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$IncidentsTableReferences
    extends BaseReferences<_$AppDatabase, $IncidentsTable, IncidentRow> {
  $$IncidentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GardensTable _gardenIdTable(_$AppDatabase db) =>
      db.gardens.createAlias('incidents__garden_id__gardens__id');

  $$GardensTableProcessedTableManager get gardenId {
    final $_column = $_itemColumn<String>('garden_id')!;

    final manager = $$GardensTableTableManager(
      $_db,
      $_db.gardens,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gardenIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ZonesTable _zoneIdTable(_$AppDatabase db) =>
      db.zones.createAlias('incidents__zone_id__zones__id');

  $$ZonesTableProcessedTableManager get zoneId {
    final $_column = $_itemColumn<String>('zone_id')!;

    final manager = $$ZonesTableTableManager(
      $_db,
      $_db.zones,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_zoneIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TasksTable, List<TaskRow>> _tasksRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.tasks,
    aliasName: 'incidents__id__tasks__incident_id',
  );

  $$TasksTableProcessedTableManager get tasksRefs {
    final manager = $$TasksTableTableManager(
      $_db,
      $_db.tasks,
    ).filter((f) => f.incidentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tasksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PhotosTable, List<PhotoRow>> _photosRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.photos,
    aliasName: 'incidents__id__photos__incident_id',
  );

  $$PhotosTableProcessedTableManager get photosRefs {
    final manager = $$PhotosTableTableManager(
      $_db,
      $_db.photos,
    ).filter((f) => f.incidentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_photosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$IncidentsTableFilterComposer
    extends Composer<_$AppDatabase, $IncidentsTable> {
  $$IncidentsTableFilterComposer({
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

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get candidates => $composableBuilder(
    column: $table.candidates,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get planBio => $composableBuilder(
    column: $table.planBio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get planChem => $composableBuilder(
    column: $table.planChem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$GardensTableFilterComposer get gardenId {
    final $$GardensTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gardenId,
      referencedTable: $db.gardens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GardensTableFilterComposer(
            $db: $db,
            $table: $db.gardens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ZonesTableFilterComposer get zoneId {
    final $$ZonesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.zoneId,
      referencedTable: $db.zones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ZonesTableFilterComposer(
            $db: $db,
            $table: $db.zones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> tasksRefs(
    Expression<bool> Function($$TasksTableFilterComposer f) f,
  ) {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.incidentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> photosRefs(
    Expression<bool> Function($$PhotosTableFilterComposer f) f,
  ) {
    final $$PhotosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.photos,
      getReferencedColumn: (t) => t.incidentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhotosTableFilterComposer(
            $db: $db,
            $table: $db.photos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$IncidentsTableOrderingComposer
    extends Composer<_$AppDatabase, $IncidentsTable> {
  $$IncidentsTableOrderingComposer({
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

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get candidates => $composableBuilder(
    column: $table.candidates,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get planBio => $composableBuilder(
    column: $table.planBio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get planChem => $composableBuilder(
    column: $table.planChem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$GardensTableOrderingComposer get gardenId {
    final $$GardensTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gardenId,
      referencedTable: $db.gardens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GardensTableOrderingComposer(
            $db: $db,
            $table: $db.gardens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ZonesTableOrderingComposer get zoneId {
    final $$ZonesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.zoneId,
      referencedTable: $db.zones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ZonesTableOrderingComposer(
            $db: $db,
            $table: $db.zones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IncidentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $IncidentsTable> {
  $$IncidentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get candidates => $composableBuilder(
    column: $table.candidates,
    builder: (column) => column,
  );

  GeneratedColumn<String> get planBio =>
      $composableBuilder(column: $table.planBio, builder: (column) => column);

  GeneratedColumn<String> get planChem =>
      $composableBuilder(column: $table.planChem, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$GardensTableAnnotationComposer get gardenId {
    final $$GardensTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gardenId,
      referencedTable: $db.gardens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GardensTableAnnotationComposer(
            $db: $db,
            $table: $db.gardens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ZonesTableAnnotationComposer get zoneId {
    final $$ZonesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.zoneId,
      referencedTable: $db.zones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ZonesTableAnnotationComposer(
            $db: $db,
            $table: $db.zones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> tasksRefs<T extends Object>(
    Expression<T> Function($$TasksTableAnnotationComposer a) f,
  ) {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.incidentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> photosRefs<T extends Object>(
    Expression<T> Function($$PhotosTableAnnotationComposer a) f,
  ) {
    final $$PhotosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.photos,
      getReferencedColumn: (t) => t.incidentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhotosTableAnnotationComposer(
            $db: $db,
            $table: $db.photos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$IncidentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IncidentsTable,
          IncidentRow,
          $$IncidentsTableFilterComposer,
          $$IncidentsTableOrderingComposer,
          $$IncidentsTableAnnotationComposer,
          $$IncidentsTableCreateCompanionBuilder,
          $$IncidentsTableUpdateCompanionBuilder,
          (IncidentRow, $$IncidentsTableReferences),
          IncidentRow,
          PrefetchHooks Function({
            bool gardenId,
            bool zoneId,
            bool tasksRefs,
            bool photosRefs,
          })
        > {
  $$IncidentsTableTableManager(_$AppDatabase db, $IncidentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IncidentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IncidentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IncidentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> gardenId = const Value.absent(),
                Value<String> zoneId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> candidates = const Value.absent(),
                Value<String?> planBio = const Value.absent(),
                Value<String?> planChem = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IncidentsCompanion(
                id: id,
                gardenId: gardenId,
                zoneId: zoneId,
                label: label,
                source: source,
                candidates: candidates,
                planBio: planBio,
                planChem: planChem,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String gardenId,
                required String zoneId,
                required String label,
                Value<String> source = const Value.absent(),
                Value<String?> candidates = const Value.absent(),
                Value<String?> planBio = const Value.absent(),
                Value<String?> planChem = const Value.absent(),
                Value<String> status = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IncidentsCompanion.insert(
                id: id,
                gardenId: gardenId,
                zoneId: zoneId,
                label: label,
                source: source,
                candidates: candidates,
                planBio: planBio,
                planChem: planChem,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$IncidentsTable, IncidentRow>(table),
                  $$IncidentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                gardenId = false,
                zoneId = false,
                tasksRefs = false,
                photosRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (tasksRefs) db.tasks,
                    if (photosRefs) db.photos,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (gardenId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.gardenId,
                                    referencedTable: $$IncidentsTableReferences
                                        ._gardenIdTable(db),
                                    referencedColumn: $$IncidentsTableReferences
                                        ._gardenIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (zoneId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.zoneId,
                                    referencedTable: $$IncidentsTableReferences
                                        ._zoneIdTable(db),
                                    referencedColumn: $$IncidentsTableReferences
                                        ._zoneIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (tasksRefs)
                        await $_getPrefetchedData<
                          IncidentRow,
                          $IncidentsTable,
                          TaskRow
                        >(
                          currentTable: table,
                          referencedTable: $$IncidentsTableReferences
                              ._tasksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$IncidentsTableReferences(
                                db,
                                table,
                                p0,
                              ).tasksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.incidentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (photosRefs)
                        await $_getPrefetchedData<
                          IncidentRow,
                          $IncidentsTable,
                          PhotoRow
                        >(
                          currentTable: table,
                          referencedTable: $$IncidentsTableReferences
                              ._photosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$IncidentsTableReferences(
                                db,
                                table,
                                p0,
                              ).photosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.incidentId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$IncidentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IncidentsTable,
      IncidentRow,
      $$IncidentsTableFilterComposer,
      $$IncidentsTableOrderingComposer,
      $$IncidentsTableAnnotationComposer,
      $$IncidentsTableCreateCompanionBuilder,
      $$IncidentsTableUpdateCompanionBuilder,
      (IncidentRow, $$IncidentsTableReferences),
      IncidentRow,
      PrefetchHooks Function({
        bool gardenId,
        bool zoneId,
        bool tasksRefs,
        bool photosRefs,
      })
    >;
typedef $$TasksTableCreateCompanionBuilder =
    TasksCompanion Function({
      required String id,
      required String gardenId,
      required String title,
      Value<String?> zoneId,
      required String due,
      Value<int?> remindAt,
      Value<String?> rrule,
      Value<String?> snoozedUntil,
      Value<String> status,
      Value<String?> notes,
      Value<DateTime?> completedAt,
      Value<String?> completedActivityId,
      Value<String> source,
      Value<int?> durationEstMin,
      Value<String?> tools,
      Value<String?> incidentId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$TasksTableUpdateCompanionBuilder =
    TasksCompanion Function({
      Value<String> id,
      Value<String> gardenId,
      Value<String> title,
      Value<String?> zoneId,
      Value<String> due,
      Value<int?> remindAt,
      Value<String?> rrule,
      Value<String?> snoozedUntil,
      Value<String> status,
      Value<String?> notes,
      Value<DateTime?> completedAt,
      Value<String?> completedActivityId,
      Value<String> source,
      Value<int?> durationEstMin,
      Value<String?> tools,
      Value<String?> incidentId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$TasksTableReferences
    extends BaseReferences<_$AppDatabase, $TasksTable, TaskRow> {
  $$TasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GardensTable _gardenIdTable(_$AppDatabase db) =>
      db.gardens.createAlias('tasks__garden_id__gardens__id');

  $$GardensTableProcessedTableManager get gardenId {
    final $_column = $_itemColumn<String>('garden_id')!;

    final manager = $$GardensTableTableManager(
      $_db,
      $_db.gardens,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gardenIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ZonesTable _zoneIdTable(_$AppDatabase db) =>
      db.zones.createAlias('tasks__zone_id__zones__id');

  $$ZonesTableProcessedTableManager? get zoneId {
    final $_column = $_itemColumn<String>('zone_id');
    if ($_column == null) return null;
    final manager = $$ZonesTableTableManager(
      $_db,
      $_db.zones,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_zoneIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $IncidentsTable _incidentIdTable(_$AppDatabase db) =>
      db.incidents.createAlias('tasks__incident_id__incidents__id');

  $$IncidentsTableProcessedTableManager? get incidentId {
    final $_column = $_itemColumn<String>('incident_id');
    if ($_column == null) return null;
    final manager = $$IncidentsTableTableManager(
      $_db,
      $_db.incidents,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_incidentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TaskMaterialsTable, List<TaskMaterialRow>>
  _taskMaterialsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.taskMaterials,
    aliasName: 'tasks__id__task_materials__task_id',
  );

  $$TaskMaterialsTableProcessedTableManager get taskMaterialsRefs {
    final manager = $$TaskMaterialsTableTableManager(
      $_db,
      $_db.taskMaterials,
    ).filter((f) => f.taskId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_taskMaterialsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $InventoryMovementsTable,
    List<InventoryMovementRow>
  >
  _inventoryMovementsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.inventoryMovements,
        aliasName: 'tasks__id__inventory_movements__task_id',
      );

  $$InventoryMovementsTableProcessedTableManager get inventoryMovementsRefs {
    final manager = $$InventoryMovementsTableTableManager(
      $_db,
      $_db.inventoryMovements,
    ).filter((f) => f.taskId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _inventoryMovementsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get due => $composableBuilder(
    column: $table.due,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remindAt => $composableBuilder(
    column: $table.remindAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rrule => $composableBuilder(
    column: $table.rrule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get snoozedUntil => $composableBuilder(
    column: $table.snoozedUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get completedActivityId => $composableBuilder(
    column: $table.completedActivityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationEstMin => $composableBuilder(
    column: $table.durationEstMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tools => $composableBuilder(
    column: $table.tools,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$GardensTableFilterComposer get gardenId {
    final $$GardensTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gardenId,
      referencedTable: $db.gardens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GardensTableFilterComposer(
            $db: $db,
            $table: $db.gardens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ZonesTableFilterComposer get zoneId {
    final $$ZonesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.zoneId,
      referencedTable: $db.zones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ZonesTableFilterComposer(
            $db: $db,
            $table: $db.zones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$IncidentsTableFilterComposer get incidentId {
    final $$IncidentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.incidentId,
      referencedTable: $db.incidents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IncidentsTableFilterComposer(
            $db: $db,
            $table: $db.incidents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> taskMaterialsRefs(
    Expression<bool> Function($$TaskMaterialsTableFilterComposer f) f,
  ) {
    final $$TaskMaterialsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskMaterials,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskMaterialsTableFilterComposer(
            $db: $db,
            $table: $db.taskMaterials,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> inventoryMovementsRefs(
    Expression<bool> Function($$InventoryMovementsTableFilterComposer f) f,
  ) {
    final $$InventoryMovementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.inventoryMovements,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InventoryMovementsTableFilterComposer(
            $db: $db,
            $table: $db.inventoryMovements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get due => $composableBuilder(
    column: $table.due,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remindAt => $composableBuilder(
    column: $table.remindAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rrule => $composableBuilder(
    column: $table.rrule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get snoozedUntil => $composableBuilder(
    column: $table.snoozedUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get completedActivityId => $composableBuilder(
    column: $table.completedActivityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationEstMin => $composableBuilder(
    column: $table.durationEstMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tools => $composableBuilder(
    column: $table.tools,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$GardensTableOrderingComposer get gardenId {
    final $$GardensTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gardenId,
      referencedTable: $db.gardens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GardensTableOrderingComposer(
            $db: $db,
            $table: $db.gardens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ZonesTableOrderingComposer get zoneId {
    final $$ZonesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.zoneId,
      referencedTable: $db.zones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ZonesTableOrderingComposer(
            $db: $db,
            $table: $db.zones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$IncidentsTableOrderingComposer get incidentId {
    final $$IncidentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.incidentId,
      referencedTable: $db.incidents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IncidentsTableOrderingComposer(
            $db: $db,
            $table: $db.incidents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get due =>
      $composableBuilder(column: $table.due, builder: (column) => column);

  GeneratedColumn<int> get remindAt =>
      $composableBuilder(column: $table.remindAt, builder: (column) => column);

  GeneratedColumn<String> get rrule =>
      $composableBuilder(column: $table.rrule, builder: (column) => column);

  GeneratedColumn<String> get snoozedUntil => $composableBuilder(
    column: $table.snoozedUntil,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get completedActivityId => $composableBuilder(
    column: $table.completedActivityId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get durationEstMin => $composableBuilder(
    column: $table.durationEstMin,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tools =>
      $composableBuilder(column: $table.tools, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$GardensTableAnnotationComposer get gardenId {
    final $$GardensTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gardenId,
      referencedTable: $db.gardens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GardensTableAnnotationComposer(
            $db: $db,
            $table: $db.gardens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ZonesTableAnnotationComposer get zoneId {
    final $$ZonesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.zoneId,
      referencedTable: $db.zones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ZonesTableAnnotationComposer(
            $db: $db,
            $table: $db.zones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$IncidentsTableAnnotationComposer get incidentId {
    final $$IncidentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.incidentId,
      referencedTable: $db.incidents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IncidentsTableAnnotationComposer(
            $db: $db,
            $table: $db.incidents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> taskMaterialsRefs<T extends Object>(
    Expression<T> Function($$TaskMaterialsTableAnnotationComposer a) f,
  ) {
    final $$TaskMaterialsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskMaterials,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskMaterialsTableAnnotationComposer(
            $db: $db,
            $table: $db.taskMaterials,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> inventoryMovementsRefs<T extends Object>(
    Expression<T> Function($$InventoryMovementsTableAnnotationComposer a) f,
  ) {
    final $$InventoryMovementsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.inventoryMovements,
          getReferencedColumn: (t) => t.taskId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$InventoryMovementsTableAnnotationComposer(
                $db: $db,
                $table: $db.inventoryMovements,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$TasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasksTable,
          TaskRow,
          $$TasksTableFilterComposer,
          $$TasksTableOrderingComposer,
          $$TasksTableAnnotationComposer,
          $$TasksTableCreateCompanionBuilder,
          $$TasksTableUpdateCompanionBuilder,
          (TaskRow, $$TasksTableReferences),
          TaskRow,
          PrefetchHooks Function({
            bool gardenId,
            bool zoneId,
            bool incidentId,
            bool taskMaterialsRefs,
            bool inventoryMovementsRefs,
          })
        > {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> gardenId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> zoneId = const Value.absent(),
                Value<String> due = const Value.absent(),
                Value<int?> remindAt = const Value.absent(),
                Value<String?> rrule = const Value.absent(),
                Value<String?> snoozedUntil = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String?> completedActivityId = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int?> durationEstMin = const Value.absent(),
                Value<String?> tools = const Value.absent(),
                Value<String?> incidentId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion(
                id: id,
                gardenId: gardenId,
                title: title,
                zoneId: zoneId,
                due: due,
                remindAt: remindAt,
                rrule: rrule,
                snoozedUntil: snoozedUntil,
                status: status,
                notes: notes,
                completedAt: completedAt,
                completedActivityId: completedActivityId,
                source: source,
                durationEstMin: durationEstMin,
                tools: tools,
                incidentId: incidentId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String gardenId,
                required String title,
                Value<String?> zoneId = const Value.absent(),
                required String due,
                Value<int?> remindAt = const Value.absent(),
                Value<String?> rrule = const Value.absent(),
                Value<String?> snoozedUntil = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String?> completedActivityId = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int?> durationEstMin = const Value.absent(),
                Value<String?> tools = const Value.absent(),
                Value<String?> incidentId = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion.insert(
                id: id,
                gardenId: gardenId,
                title: title,
                zoneId: zoneId,
                due: due,
                remindAt: remindAt,
                rrule: rrule,
                snoozedUntil: snoozedUntil,
                status: status,
                notes: notes,
                completedAt: completedAt,
                completedActivityId: completedActivityId,
                source: source,
                durationEstMin: durationEstMin,
                tools: tools,
                incidentId: incidentId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TasksTable, TaskRow>(table),
                  $$TasksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                gardenId = false,
                zoneId = false,
                incidentId = false,
                taskMaterialsRefs = false,
                inventoryMovementsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (taskMaterialsRefs) db.taskMaterials,
                    if (inventoryMovementsRefs) db.inventoryMovements,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (gardenId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.gardenId,
                                    referencedTable: $$TasksTableReferences
                                        ._gardenIdTable(db),
                                    referencedColumn: $$TasksTableReferences
                                        ._gardenIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (zoneId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.zoneId,
                                    referencedTable: $$TasksTableReferences
                                        ._zoneIdTable(db),
                                    referencedColumn: $$TasksTableReferences
                                        ._zoneIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (incidentId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.incidentId,
                                    referencedTable: $$TasksTableReferences
                                        ._incidentIdTable(db),
                                    referencedColumn: $$TasksTableReferences
                                        ._incidentIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (taskMaterialsRefs)
                        await $_getPrefetchedData<
                          TaskRow,
                          $TasksTable,
                          TaskMaterialRow
                        >(
                          currentTable: table,
                          referencedTable: $$TasksTableReferences
                              ._taskMaterialsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TasksTableReferences(
                                db,
                                table,
                                p0,
                              ).taskMaterialsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.taskId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (inventoryMovementsRefs)
                        await $_getPrefetchedData<
                          TaskRow,
                          $TasksTable,
                          InventoryMovementRow
                        >(
                          currentTable: table,
                          referencedTable: $$TasksTableReferences
                              ._inventoryMovementsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TasksTableReferences(
                                db,
                                table,
                                p0,
                              ).inventoryMovementsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.taskId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasksTable,
      TaskRow,
      $$TasksTableFilterComposer,
      $$TasksTableOrderingComposer,
      $$TasksTableAnnotationComposer,
      $$TasksTableCreateCompanionBuilder,
      $$TasksTableUpdateCompanionBuilder,
      (TaskRow, $$TasksTableReferences),
      TaskRow,
      PrefetchHooks Function({
        bool gardenId,
        bool zoneId,
        bool incidentId,
        bool taskMaterialsRefs,
        bool inventoryMovementsRefs,
      })
    >;
typedef $$ActivitiesTableCreateCompanionBuilder =
    ActivitiesCompanion Function({
      required String id,
      required String gardenId,
      required String zoneId,
      required String type,
      required String title,
      required DateTime occurredAt,
      required String occurredTz,
      Value<String?> notes,
      Value<double?> harvestQty,
      Value<String?> harvestUnit,
      Value<double?> costCzk,
      Value<String?> taskId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$ActivitiesTableUpdateCompanionBuilder =
    ActivitiesCompanion Function({
      Value<String> id,
      Value<String> gardenId,
      Value<String> zoneId,
      Value<String> type,
      Value<String> title,
      Value<DateTime> occurredAt,
      Value<String> occurredTz,
      Value<String?> notes,
      Value<double?> harvestQty,
      Value<String?> harvestUnit,
      Value<double?> costCzk,
      Value<String?> taskId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$ActivitiesTableReferences
    extends BaseReferences<_$AppDatabase, $ActivitiesTable, ActivityRow> {
  $$ActivitiesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GardensTable _gardenIdTable(_$AppDatabase db) =>
      db.gardens.createAlias('activities__garden_id__gardens__id');

  $$GardensTableProcessedTableManager get gardenId {
    final $_column = $_itemColumn<String>('garden_id')!;

    final manager = $$GardensTableTableManager(
      $_db,
      $_db.gardens,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gardenIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ZonesTable _zoneIdTable(_$AppDatabase db) =>
      db.zones.createAlias('activities__zone_id__zones__id');

  $$ZonesTableProcessedTableManager get zoneId {
    final $_column = $_itemColumn<String>('zone_id')!;

    final manager = $$ZonesTableTableManager(
      $_db,
      $_db.zones,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_zoneIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PhotosTable, List<PhotoRow>> _photosRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.photos,
    aliasName: 'activities__id__photos__activity_id',
  );

  $$PhotosTableProcessedTableManager get photosRefs {
    final manager = $$PhotosTableTableManager(
      $_db,
      $_db.photos,
    ).filter((f) => f.activityId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_photosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ActivityMaterialsTable, List<ActivityMaterialRow>>
  _activityMaterialsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.activityMaterials,
        aliasName: 'activities__id__activity_materials__activity_id',
      );

  $$ActivityMaterialsTableProcessedTableManager get activityMaterialsRefs {
    final manager = $$ActivityMaterialsTableTableManager(
      $_db,
      $_db.activityMaterials,
    ).filter((f) => f.activityId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _activityMaterialsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ActivitiesTableFilterComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableFilterComposer({
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

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get occurredTz => $composableBuilder(
    column: $table.occurredTz,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get harvestQty => $composableBuilder(
    column: $table.harvestQty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get harvestUnit => $composableBuilder(
    column: $table.harvestUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get costCzk => $composableBuilder(
    column: $table.costCzk,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$GardensTableFilterComposer get gardenId {
    final $$GardensTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gardenId,
      referencedTable: $db.gardens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GardensTableFilterComposer(
            $db: $db,
            $table: $db.gardens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ZonesTableFilterComposer get zoneId {
    final $$ZonesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.zoneId,
      referencedTable: $db.zones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ZonesTableFilterComposer(
            $db: $db,
            $table: $db.zones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> photosRefs(
    Expression<bool> Function($$PhotosTableFilterComposer f) f,
  ) {
    final $$PhotosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.photos,
      getReferencedColumn: (t) => t.activityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhotosTableFilterComposer(
            $db: $db,
            $table: $db.photos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> activityMaterialsRefs(
    Expression<bool> Function($$ActivityMaterialsTableFilterComposer f) f,
  ) {
    final $$ActivityMaterialsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.activityMaterials,
      getReferencedColumn: (t) => t.activityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivityMaterialsTableFilterComposer(
            $db: $db,
            $table: $db.activityMaterials,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ActivitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableOrderingComposer({
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

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get occurredTz => $composableBuilder(
    column: $table.occurredTz,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get harvestQty => $composableBuilder(
    column: $table.harvestQty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get harvestUnit => $composableBuilder(
    column: $table.harvestUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get costCzk => $composableBuilder(
    column: $table.costCzk,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$GardensTableOrderingComposer get gardenId {
    final $$GardensTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gardenId,
      referencedTable: $db.gardens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GardensTableOrderingComposer(
            $db: $db,
            $table: $db.gardens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ZonesTableOrderingComposer get zoneId {
    final $$ZonesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.zoneId,
      referencedTable: $db.zones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ZonesTableOrderingComposer(
            $db: $db,
            $table: $db.zones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActivitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get occurredTz => $composableBuilder(
    column: $table.occurredTz,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<double> get harvestQty => $composableBuilder(
    column: $table.harvestQty,
    builder: (column) => column,
  );

  GeneratedColumn<String> get harvestUnit => $composableBuilder(
    column: $table.harvestUnit,
    builder: (column) => column,
  );

  GeneratedColumn<double> get costCzk =>
      $composableBuilder(column: $table.costCzk, builder: (column) => column);

  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$GardensTableAnnotationComposer get gardenId {
    final $$GardensTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gardenId,
      referencedTable: $db.gardens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GardensTableAnnotationComposer(
            $db: $db,
            $table: $db.gardens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ZonesTableAnnotationComposer get zoneId {
    final $$ZonesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.zoneId,
      referencedTable: $db.zones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ZonesTableAnnotationComposer(
            $db: $db,
            $table: $db.zones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> photosRefs<T extends Object>(
    Expression<T> Function($$PhotosTableAnnotationComposer a) f,
  ) {
    final $$PhotosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.photos,
      getReferencedColumn: (t) => t.activityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhotosTableAnnotationComposer(
            $db: $db,
            $table: $db.photos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> activityMaterialsRefs<T extends Object>(
    Expression<T> Function($$ActivityMaterialsTableAnnotationComposer a) f,
  ) {
    final $$ActivityMaterialsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.activityMaterials,
          getReferencedColumn: (t) => t.activityId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ActivityMaterialsTableAnnotationComposer(
                $db: $db,
                $table: $db.activityMaterials,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ActivitiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActivitiesTable,
          ActivityRow,
          $$ActivitiesTableFilterComposer,
          $$ActivitiesTableOrderingComposer,
          $$ActivitiesTableAnnotationComposer,
          $$ActivitiesTableCreateCompanionBuilder,
          $$ActivitiesTableUpdateCompanionBuilder,
          (ActivityRow, $$ActivitiesTableReferences),
          ActivityRow,
          PrefetchHooks Function({
            bool gardenId,
            bool zoneId,
            bool photosRefs,
            bool activityMaterialsRefs,
          })
        > {
  $$ActivitiesTableTableManager(_$AppDatabase db, $ActivitiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> gardenId = const Value.absent(),
                Value<String> zoneId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<String> occurredTz = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<double?> harvestQty = const Value.absent(),
                Value<String?> harvestUnit = const Value.absent(),
                Value<double?> costCzk = const Value.absent(),
                Value<String?> taskId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivitiesCompanion(
                id: id,
                gardenId: gardenId,
                zoneId: zoneId,
                type: type,
                title: title,
                occurredAt: occurredAt,
                occurredTz: occurredTz,
                notes: notes,
                harvestQty: harvestQty,
                harvestUnit: harvestUnit,
                costCzk: costCzk,
                taskId: taskId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String gardenId,
                required String zoneId,
                required String type,
                required String title,
                required DateTime occurredAt,
                required String occurredTz,
                Value<String?> notes = const Value.absent(),
                Value<double?> harvestQty = const Value.absent(),
                Value<String?> harvestUnit = const Value.absent(),
                Value<double?> costCzk = const Value.absent(),
                Value<String?> taskId = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivitiesCompanion.insert(
                id: id,
                gardenId: gardenId,
                zoneId: zoneId,
                type: type,
                title: title,
                occurredAt: occurredAt,
                occurredTz: occurredTz,
                notes: notes,
                harvestQty: harvestQty,
                harvestUnit: harvestUnit,
                costCzk: costCzk,
                taskId: taskId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ActivitiesTable, ActivityRow>(table),
                  $$ActivitiesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                gardenId = false,
                zoneId = false,
                photosRefs = false,
                activityMaterialsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (photosRefs) db.photos,
                    if (activityMaterialsRefs) db.activityMaterials,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (gardenId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.gardenId,
                                    referencedTable: $$ActivitiesTableReferences
                                        ._gardenIdTable(db),
                                    referencedColumn:
                                        $$ActivitiesTableReferences
                                            ._gardenIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (zoneId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.zoneId,
                                    referencedTable: $$ActivitiesTableReferences
                                        ._zoneIdTable(db),
                                    referencedColumn:
                                        $$ActivitiesTableReferences
                                            ._zoneIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (photosRefs)
                        await $_getPrefetchedData<
                          ActivityRow,
                          $ActivitiesTable,
                          PhotoRow
                        >(
                          currentTable: table,
                          referencedTable: $$ActivitiesTableReferences
                              ._photosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ActivitiesTableReferences(
                                db,
                                table,
                                p0,
                              ).photosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.activityId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (activityMaterialsRefs)
                        await $_getPrefetchedData<
                          ActivityRow,
                          $ActivitiesTable,
                          ActivityMaterialRow
                        >(
                          currentTable: table,
                          referencedTable: $$ActivitiesTableReferences
                              ._activityMaterialsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ActivitiesTableReferences(
                                db,
                                table,
                                p0,
                              ).activityMaterialsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.activityId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ActivitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActivitiesTable,
      ActivityRow,
      $$ActivitiesTableFilterComposer,
      $$ActivitiesTableOrderingComposer,
      $$ActivitiesTableAnnotationComposer,
      $$ActivitiesTableCreateCompanionBuilder,
      $$ActivitiesTableUpdateCompanionBuilder,
      (ActivityRow, $$ActivitiesTableReferences),
      ActivityRow,
      PrefetchHooks Function({
        bool gardenId,
        bool zoneId,
        bool photosRefs,
        bool activityMaterialsRefs,
      })
    >;
typedef $$PhotosTableCreateCompanionBuilder =
    PhotosCompanion Function({
      required String id,
      required String gardenId,
      Value<String?> activityId,
      Value<String?> incidentId,
      required String localPath,
      Value<int> position,
      required DateTime createdAt,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$PhotosTableUpdateCompanionBuilder =
    PhotosCompanion Function({
      Value<String> id,
      Value<String> gardenId,
      Value<String?> activityId,
      Value<String?> incidentId,
      Value<String> localPath,
      Value<int> position,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$PhotosTableReferences
    extends BaseReferences<_$AppDatabase, $PhotosTable, PhotoRow> {
  $$PhotosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GardensTable _gardenIdTable(_$AppDatabase db) =>
      db.gardens.createAlias('photos__garden_id__gardens__id');

  $$GardensTableProcessedTableManager get gardenId {
    final $_column = $_itemColumn<String>('garden_id')!;

    final manager = $$GardensTableTableManager(
      $_db,
      $_db.gardens,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gardenIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ActivitiesTable _activityIdTable(_$AppDatabase db) =>
      db.activities.createAlias('photos__activity_id__activities__id');

  $$ActivitiesTableProcessedTableManager? get activityId {
    final $_column = $_itemColumn<String>('activity_id');
    if ($_column == null) return null;
    final manager = $$ActivitiesTableTableManager(
      $_db,
      $_db.activities,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_activityIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $IncidentsTable _incidentIdTable(_$AppDatabase db) =>
      db.incidents.createAlias('photos__incident_id__incidents__id');

  $$IncidentsTableProcessedTableManager? get incidentId {
    final $_column = $_itemColumn<String>('incident_id');
    if ($_column == null) return null;
    final manager = $$IncidentsTableTableManager(
      $_db,
      $_db.incidents,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_incidentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PhotosTableFilterComposer
    extends Composer<_$AppDatabase, $PhotosTable> {
  $$PhotosTableFilterComposer({
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

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$GardensTableFilterComposer get gardenId {
    final $$GardensTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gardenId,
      referencedTable: $db.gardens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GardensTableFilterComposer(
            $db: $db,
            $table: $db.gardens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ActivitiesTableFilterComposer get activityId {
    final $$ActivitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activityId,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableFilterComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$IncidentsTableFilterComposer get incidentId {
    final $$IncidentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.incidentId,
      referencedTable: $db.incidents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IncidentsTableFilterComposer(
            $db: $db,
            $table: $db.incidents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PhotosTableOrderingComposer
    extends Composer<_$AppDatabase, $PhotosTable> {
  $$PhotosTableOrderingComposer({
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

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$GardensTableOrderingComposer get gardenId {
    final $$GardensTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gardenId,
      referencedTable: $db.gardens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GardensTableOrderingComposer(
            $db: $db,
            $table: $db.gardens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ActivitiesTableOrderingComposer get activityId {
    final $$ActivitiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activityId,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableOrderingComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$IncidentsTableOrderingComposer get incidentId {
    final $$IncidentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.incidentId,
      referencedTable: $db.incidents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IncidentsTableOrderingComposer(
            $db: $db,
            $table: $db.incidents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PhotosTableAnnotationComposer
    extends Composer<_$AppDatabase, $PhotosTable> {
  $$PhotosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$GardensTableAnnotationComposer get gardenId {
    final $$GardensTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gardenId,
      referencedTable: $db.gardens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GardensTableAnnotationComposer(
            $db: $db,
            $table: $db.gardens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ActivitiesTableAnnotationComposer get activityId {
    final $$ActivitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activityId,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$IncidentsTableAnnotationComposer get incidentId {
    final $$IncidentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.incidentId,
      referencedTable: $db.incidents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IncidentsTableAnnotationComposer(
            $db: $db,
            $table: $db.incidents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PhotosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PhotosTable,
          PhotoRow,
          $$PhotosTableFilterComposer,
          $$PhotosTableOrderingComposer,
          $$PhotosTableAnnotationComposer,
          $$PhotosTableCreateCompanionBuilder,
          $$PhotosTableUpdateCompanionBuilder,
          (PhotoRow, $$PhotosTableReferences),
          PhotoRow,
          PrefetchHooks Function({
            bool gardenId,
            bool activityId,
            bool incidentId,
          })
        > {
  $$PhotosTableTableManager(_$AppDatabase db, $PhotosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PhotosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PhotosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PhotosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> gardenId = const Value.absent(),
                Value<String?> activityId = const Value.absent(),
                Value<String?> incidentId = const Value.absent(),
                Value<String> localPath = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PhotosCompanion(
                id: id,
                gardenId: gardenId,
                activityId: activityId,
                incidentId: incidentId,
                localPath: localPath,
                position: position,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String gardenId,
                Value<String?> activityId = const Value.absent(),
                Value<String?> incidentId = const Value.absent(),
                required String localPath,
                Value<int> position = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PhotosCompanion.insert(
                id: id,
                gardenId: gardenId,
                activityId: activityId,
                incidentId: incidentId,
                localPath: localPath,
                position: position,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PhotosTable, PhotoRow>(table),
                  $$PhotosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({gardenId = false, activityId = false, incidentId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (gardenId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.gardenId,
                                    referencedTable: $$PhotosTableReferences
                                        ._gardenIdTable(db),
                                    referencedColumn: $$PhotosTableReferences
                                        ._gardenIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (activityId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.activityId,
                                    referencedTable: $$PhotosTableReferences
                                        ._activityIdTable(db),
                                    referencedColumn: $$PhotosTableReferences
                                        ._activityIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (incidentId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.incidentId,
                                    referencedTable: $$PhotosTableReferences
                                        ._incidentIdTable(db),
                                    referencedColumn: $$PhotosTableReferences
                                        ._incidentIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$PhotosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PhotosTable,
      PhotoRow,
      $$PhotosTableFilterComposer,
      $$PhotosTableOrderingComposer,
      $$PhotosTableAnnotationComposer,
      $$PhotosTableCreateCompanionBuilder,
      $$PhotosTableUpdateCompanionBuilder,
      (PhotoRow, $$PhotosTableReferences),
      PhotoRow,
      PrefetchHooks Function({bool gardenId, bool activityId, bool incidentId})
    >;
typedef $$TaskMaterialsTableCreateCompanionBuilder =
    TaskMaterialsCompanion Function({
      required String taskId,
      required String itemId,
      required String gardenId,
      required double qty,
      required String unit,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$TaskMaterialsTableUpdateCompanionBuilder =
    TaskMaterialsCompanion Function({
      Value<String> taskId,
      Value<String> itemId,
      Value<String> gardenId,
      Value<double> qty,
      Value<String> unit,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$TaskMaterialsTableReferences
    extends
        BaseReferences<_$AppDatabase, $TaskMaterialsTable, TaskMaterialRow> {
  $$TaskMaterialsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TasksTable _taskIdTable(_$AppDatabase db) =>
      db.tasks.createAlias('task_materials__task_id__tasks__id');

  $$TasksTableProcessedTableManager get taskId {
    final $_column = $_itemColumn<String>('task_id')!;

    final manager = $$TasksTableTableManager(
      $_db,
      $_db.tasks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $InventoryItemsTable _itemIdTable(_$AppDatabase db) => db
      .inventoryItems
      .createAlias('task_materials__item_id__inventory_items__id');

  $$InventoryItemsTableProcessedTableManager get itemId {
    final $_column = $_itemColumn<String>('item_id')!;

    final manager = $$InventoryItemsTableTableManager(
      $_db,
      $_db.inventoryItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $GardensTable _gardenIdTable(_$AppDatabase db) =>
      db.gardens.createAlias('task_materials__garden_id__gardens__id');

  $$GardensTableProcessedTableManager get gardenId {
    final $_column = $_itemColumn<String>('garden_id')!;

    final manager = $$GardensTableTableManager(
      $_db,
      $_db.gardens,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gardenIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TaskMaterialsTableFilterComposer
    extends Composer<_$AppDatabase, $TaskMaterialsTable> {
  $$TaskMaterialsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<double> get qty => $composableBuilder(
    column: $table.qty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TasksTableFilterComposer get taskId {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InventoryItemsTableFilterComposer get itemId {
    final $$InventoryItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.inventoryItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InventoryItemsTableFilterComposer(
            $db: $db,
            $table: $db.inventoryItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GardensTableFilterComposer get gardenId {
    final $$GardensTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gardenId,
      referencedTable: $db.gardens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GardensTableFilterComposer(
            $db: $db,
            $table: $db.gardens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TaskMaterialsTableOrderingComposer
    extends Composer<_$AppDatabase, $TaskMaterialsTable> {
  $$TaskMaterialsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<double> get qty => $composableBuilder(
    column: $table.qty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TasksTableOrderingComposer get taskId {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableOrderingComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InventoryItemsTableOrderingComposer get itemId {
    final $$InventoryItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.inventoryItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InventoryItemsTableOrderingComposer(
            $db: $db,
            $table: $db.inventoryItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GardensTableOrderingComposer get gardenId {
    final $$GardensTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gardenId,
      referencedTable: $db.gardens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GardensTableOrderingComposer(
            $db: $db,
            $table: $db.gardens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TaskMaterialsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaskMaterialsTable> {
  $$TaskMaterialsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<double> get qty =>
      $composableBuilder(column: $table.qty, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$TasksTableAnnotationComposer get taskId {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InventoryItemsTableAnnotationComposer get itemId {
    final $$InventoryItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.inventoryItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InventoryItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.inventoryItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GardensTableAnnotationComposer get gardenId {
    final $$GardensTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gardenId,
      referencedTable: $db.gardens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GardensTableAnnotationComposer(
            $db: $db,
            $table: $db.gardens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TaskMaterialsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TaskMaterialsTable,
          TaskMaterialRow,
          $$TaskMaterialsTableFilterComposer,
          $$TaskMaterialsTableOrderingComposer,
          $$TaskMaterialsTableAnnotationComposer,
          $$TaskMaterialsTableCreateCompanionBuilder,
          $$TaskMaterialsTableUpdateCompanionBuilder,
          (TaskMaterialRow, $$TaskMaterialsTableReferences),
          TaskMaterialRow,
          PrefetchHooks Function({bool taskId, bool itemId, bool gardenId})
        > {
  $$TaskMaterialsTableTableManager(_$AppDatabase db, $TaskMaterialsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskMaterialsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskMaterialsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaskMaterialsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> taskId = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<String> gardenId = const Value.absent(),
                Value<double> qty = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskMaterialsCompanion(
                taskId: taskId,
                itemId: itemId,
                gardenId: gardenId,
                qty: qty,
                unit: unit,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String taskId,
                required String itemId,
                required String gardenId,
                required double qty,
                required String unit,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskMaterialsCompanion.insert(
                taskId: taskId,
                itemId: itemId,
                gardenId: gardenId,
                qty: qty,
                unit: unit,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TaskMaterialsTable, TaskMaterialRow>(table),
                  $$TaskMaterialsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({taskId = false, itemId = false, gardenId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (taskId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.taskId,
                                    referencedTable:
                                        $$TaskMaterialsTableReferences
                                            ._taskIdTable(db),
                                    referencedColumn:
                                        $$TaskMaterialsTableReferences
                                            ._taskIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (itemId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.itemId,
                                    referencedTable:
                                        $$TaskMaterialsTableReferences
                                            ._itemIdTable(db),
                                    referencedColumn:
                                        $$TaskMaterialsTableReferences
                                            ._itemIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (gardenId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.gardenId,
                                    referencedTable:
                                        $$TaskMaterialsTableReferences
                                            ._gardenIdTable(db),
                                    referencedColumn:
                                        $$TaskMaterialsTableReferences
                                            ._gardenIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$TaskMaterialsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TaskMaterialsTable,
      TaskMaterialRow,
      $$TaskMaterialsTableFilterComposer,
      $$TaskMaterialsTableOrderingComposer,
      $$TaskMaterialsTableAnnotationComposer,
      $$TaskMaterialsTableCreateCompanionBuilder,
      $$TaskMaterialsTableUpdateCompanionBuilder,
      (TaskMaterialRow, $$TaskMaterialsTableReferences),
      TaskMaterialRow,
      PrefetchHooks Function({bool taskId, bool itemId, bool gardenId})
    >;
typedef $$ActivityMaterialsTableCreateCompanionBuilder =
    ActivityMaterialsCompanion Function({
      required String activityId,
      required String itemId,
      required String gardenId,
      required double qty,
      required String unit,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$ActivityMaterialsTableUpdateCompanionBuilder =
    ActivityMaterialsCompanion Function({
      Value<String> activityId,
      Value<String> itemId,
      Value<String> gardenId,
      Value<double> qty,
      Value<String> unit,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$ActivityMaterialsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ActivityMaterialsTable,
          ActivityMaterialRow
        > {
  $$ActivityMaterialsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ActivitiesTable _activityIdTable(_$AppDatabase db) => db.activities
      .createAlias('activity_materials__activity_id__activities__id');

  $$ActivitiesTableProcessedTableManager get activityId {
    final $_column = $_itemColumn<String>('activity_id')!;

    final manager = $$ActivitiesTableTableManager(
      $_db,
      $_db.activities,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_activityIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $InventoryItemsTable _itemIdTable(_$AppDatabase db) => db
      .inventoryItems
      .createAlias('activity_materials__item_id__inventory_items__id');

  $$InventoryItemsTableProcessedTableManager get itemId {
    final $_column = $_itemColumn<String>('item_id')!;

    final manager = $$InventoryItemsTableTableManager(
      $_db,
      $_db.inventoryItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $GardensTable _gardenIdTable(_$AppDatabase db) =>
      db.gardens.createAlias('activity_materials__garden_id__gardens__id');

  $$GardensTableProcessedTableManager get gardenId {
    final $_column = $_itemColumn<String>('garden_id')!;

    final manager = $$GardensTableTableManager(
      $_db,
      $_db.gardens,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gardenIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ActivityMaterialsTableFilterComposer
    extends Composer<_$AppDatabase, $ActivityMaterialsTable> {
  $$ActivityMaterialsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<double> get qty => $composableBuilder(
    column: $table.qty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ActivitiesTableFilterComposer get activityId {
    final $$ActivitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activityId,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableFilterComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InventoryItemsTableFilterComposer get itemId {
    final $$InventoryItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.inventoryItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InventoryItemsTableFilterComposer(
            $db: $db,
            $table: $db.inventoryItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GardensTableFilterComposer get gardenId {
    final $$GardensTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gardenId,
      referencedTable: $db.gardens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GardensTableFilterComposer(
            $db: $db,
            $table: $db.gardens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActivityMaterialsTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivityMaterialsTable> {
  $$ActivityMaterialsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<double> get qty => $composableBuilder(
    column: $table.qty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ActivitiesTableOrderingComposer get activityId {
    final $$ActivitiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activityId,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableOrderingComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InventoryItemsTableOrderingComposer get itemId {
    final $$InventoryItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.inventoryItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InventoryItemsTableOrderingComposer(
            $db: $db,
            $table: $db.inventoryItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GardensTableOrderingComposer get gardenId {
    final $$GardensTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gardenId,
      referencedTable: $db.gardens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GardensTableOrderingComposer(
            $db: $db,
            $table: $db.gardens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActivityMaterialsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivityMaterialsTable> {
  $$ActivityMaterialsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<double> get qty =>
      $composableBuilder(column: $table.qty, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$ActivitiesTableAnnotationComposer get activityId {
    final $$ActivitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activityId,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InventoryItemsTableAnnotationComposer get itemId {
    final $$InventoryItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.inventoryItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InventoryItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.inventoryItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GardensTableAnnotationComposer get gardenId {
    final $$GardensTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gardenId,
      referencedTable: $db.gardens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GardensTableAnnotationComposer(
            $db: $db,
            $table: $db.gardens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActivityMaterialsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActivityMaterialsTable,
          ActivityMaterialRow,
          $$ActivityMaterialsTableFilterComposer,
          $$ActivityMaterialsTableOrderingComposer,
          $$ActivityMaterialsTableAnnotationComposer,
          $$ActivityMaterialsTableCreateCompanionBuilder,
          $$ActivityMaterialsTableUpdateCompanionBuilder,
          (ActivityMaterialRow, $$ActivityMaterialsTableReferences),
          ActivityMaterialRow,
          PrefetchHooks Function({bool activityId, bool itemId, bool gardenId})
        > {
  $$ActivityMaterialsTableTableManager(
    _$AppDatabase db,
    $ActivityMaterialsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivityMaterialsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivityMaterialsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivityMaterialsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> activityId = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<String> gardenId = const Value.absent(),
                Value<double> qty = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivityMaterialsCompanion(
                activityId: activityId,
                itemId: itemId,
                gardenId: gardenId,
                qty: qty,
                unit: unit,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String activityId,
                required String itemId,
                required String gardenId,
                required double qty,
                required String unit,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivityMaterialsCompanion.insert(
                activityId: activityId,
                itemId: itemId,
                gardenId: gardenId,
                qty: qty,
                unit: unit,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ActivityMaterialsTable, ActivityMaterialRow>(
                    table,
                  ),
                  $$ActivityMaterialsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({activityId = false, itemId = false, gardenId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (activityId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.activityId,
                                    referencedTable:
                                        $$ActivityMaterialsTableReferences
                                            ._activityIdTable(db),
                                    referencedColumn:
                                        $$ActivityMaterialsTableReferences
                                            ._activityIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (itemId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.itemId,
                                    referencedTable:
                                        $$ActivityMaterialsTableReferences
                                            ._itemIdTable(db),
                                    referencedColumn:
                                        $$ActivityMaterialsTableReferences
                                            ._itemIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (gardenId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.gardenId,
                                    referencedTable:
                                        $$ActivityMaterialsTableReferences
                                            ._gardenIdTable(db),
                                    referencedColumn:
                                        $$ActivityMaterialsTableReferences
                                            ._gardenIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$ActivityMaterialsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActivityMaterialsTable,
      ActivityMaterialRow,
      $$ActivityMaterialsTableFilterComposer,
      $$ActivityMaterialsTableOrderingComposer,
      $$ActivityMaterialsTableAnnotationComposer,
      $$ActivityMaterialsTableCreateCompanionBuilder,
      $$ActivityMaterialsTableUpdateCompanionBuilder,
      (ActivityMaterialRow, $$ActivityMaterialsTableReferences),
      ActivityMaterialRow,
      PrefetchHooks Function({bool activityId, bool itemId, bool gardenId})
    >;
typedef $$ShoppingItemsTableCreateCompanionBuilder =
    ShoppingItemsCompanion Function({
      required String id,
      required String gardenId,
      required String name,
      Value<double?> qty,
      Value<String?> unit,
      Value<String?> itemId,
      Value<bool> done,
      Value<String> source,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$ShoppingItemsTableUpdateCompanionBuilder =
    ShoppingItemsCompanion Function({
      Value<String> id,
      Value<String> gardenId,
      Value<String> name,
      Value<double?> qty,
      Value<String?> unit,
      Value<String?> itemId,
      Value<bool> done,
      Value<String> source,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$ShoppingItemsTableReferences
    extends
        BaseReferences<_$AppDatabase, $ShoppingItemsTable, ShoppingItemRow> {
  $$ShoppingItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $GardensTable _gardenIdTable(_$AppDatabase db) =>
      db.gardens.createAlias('shopping_items__garden_id__gardens__id');

  $$GardensTableProcessedTableManager get gardenId {
    final $_column = $_itemColumn<String>('garden_id')!;

    final manager = $$GardensTableTableManager(
      $_db,
      $_db.gardens,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gardenIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $InventoryItemsTable _itemIdTable(_$AppDatabase db) => db
      .inventoryItems
      .createAlias('shopping_items__item_id__inventory_items__id');

  $$InventoryItemsTableProcessedTableManager? get itemId {
    final $_column = $_itemColumn<String>('item_id');
    if ($_column == null) return null;
    final manager = $$InventoryItemsTableTableManager(
      $_db,
      $_db.inventoryItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ShoppingItemsTableFilterComposer
    extends Composer<_$AppDatabase, $ShoppingItemsTable> {
  $$ShoppingItemsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get qty => $composableBuilder(
    column: $table.qty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$GardensTableFilterComposer get gardenId {
    final $$GardensTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gardenId,
      referencedTable: $db.gardens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GardensTableFilterComposer(
            $db: $db,
            $table: $db.gardens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InventoryItemsTableFilterComposer get itemId {
    final $$InventoryItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.inventoryItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InventoryItemsTableFilterComposer(
            $db: $db,
            $table: $db.inventoryItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShoppingItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ShoppingItemsTable> {
  $$ShoppingItemsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get qty => $composableBuilder(
    column: $table.qty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$GardensTableOrderingComposer get gardenId {
    final $$GardensTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gardenId,
      referencedTable: $db.gardens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GardensTableOrderingComposer(
            $db: $db,
            $table: $db.gardens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InventoryItemsTableOrderingComposer get itemId {
    final $$InventoryItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.inventoryItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InventoryItemsTableOrderingComposer(
            $db: $db,
            $table: $db.inventoryItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShoppingItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShoppingItemsTable> {
  $$ShoppingItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get qty =>
      $composableBuilder(column: $table.qty, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<bool> get done =>
      $composableBuilder(column: $table.done, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$GardensTableAnnotationComposer get gardenId {
    final $$GardensTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gardenId,
      referencedTable: $db.gardens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GardensTableAnnotationComposer(
            $db: $db,
            $table: $db.gardens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InventoryItemsTableAnnotationComposer get itemId {
    final $$InventoryItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.inventoryItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InventoryItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.inventoryItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShoppingItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShoppingItemsTable,
          ShoppingItemRow,
          $$ShoppingItemsTableFilterComposer,
          $$ShoppingItemsTableOrderingComposer,
          $$ShoppingItemsTableAnnotationComposer,
          $$ShoppingItemsTableCreateCompanionBuilder,
          $$ShoppingItemsTableUpdateCompanionBuilder,
          (ShoppingItemRow, $$ShoppingItemsTableReferences),
          ShoppingItemRow,
          PrefetchHooks Function({bool gardenId, bool itemId})
        > {
  $$ShoppingItemsTableTableManager(_$AppDatabase db, $ShoppingItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShoppingItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShoppingItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShoppingItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> gardenId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double?> qty = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<String?> itemId = const Value.absent(),
                Value<bool> done = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShoppingItemsCompanion(
                id: id,
                gardenId: gardenId,
                name: name,
                qty: qty,
                unit: unit,
                itemId: itemId,
                done: done,
                source: source,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String gardenId,
                required String name,
                Value<double?> qty = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<String?> itemId = const Value.absent(),
                Value<bool> done = const Value.absent(),
                Value<String> source = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShoppingItemsCompanion.insert(
                id: id,
                gardenId: gardenId,
                name: name,
                qty: qty,
                unit: unit,
                itemId: itemId,
                done: done,
                source: source,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ShoppingItemsTable, ShoppingItemRow>(table),
                  $$ShoppingItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({gardenId = false, itemId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (gardenId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.gardenId,
                                referencedTable: $$ShoppingItemsTableReferences
                                    ._gardenIdTable(db),
                                referencedColumn: $$ShoppingItemsTableReferences
                                    ._gardenIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (itemId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.itemId,
                                referencedTable: $$ShoppingItemsTableReferences
                                    ._itemIdTable(db),
                                referencedColumn: $$ShoppingItemsTableReferences
                                    ._itemIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ShoppingItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShoppingItemsTable,
      ShoppingItemRow,
      $$ShoppingItemsTableFilterComposer,
      $$ShoppingItemsTableOrderingComposer,
      $$ShoppingItemsTableAnnotationComposer,
      $$ShoppingItemsTableCreateCompanionBuilder,
      $$ShoppingItemsTableUpdateCompanionBuilder,
      (ShoppingItemRow, $$ShoppingItemsTableReferences),
      ShoppingItemRow,
      PrefetchHooks Function({bool gardenId, bool itemId})
    >;
typedef $$AssistantThreadsTableCreateCompanionBuilder =
    AssistantThreadsCompanion Function({
      required String id,
      Value<String?> gardenId,
      Value<String?> title,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$AssistantThreadsTableUpdateCompanionBuilder =
    AssistantThreadsCompanion Function({
      Value<String> id,
      Value<String?> gardenId,
      Value<String?> title,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$AssistantThreadsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $AssistantThreadsTable,
          AssistantThreadRow
        > {
  $$AssistantThreadsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $GardensTable _gardenIdTable(_$AppDatabase db) =>
      db.gardens.createAlias('assistant_threads__garden_id__gardens__id');

  $$GardensTableProcessedTableManager? get gardenId {
    final $_column = $_itemColumn<String>('garden_id');
    if ($_column == null) return null;
    final manager = $$GardensTableTableManager(
      $_db,
      $_db.gardens,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gardenIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$AssistantMessagesTable, List<AssistantMessageRow>>
  _assistantMessagesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.assistantMessages,
        aliasName: 'assistant_threads__id__assistant_messages__thread_id',
      );

  $$AssistantMessagesTableProcessedTableManager get assistantMessagesRefs {
    final manager = $$AssistantMessagesTableTableManager(
      $_db,
      $_db.assistantMessages,
    ).filter((f) => f.threadId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _assistantMessagesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AssistantThreadsTableFilterComposer
    extends Composer<_$AppDatabase, $AssistantThreadsTable> {
  $$AssistantThreadsTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$GardensTableFilterComposer get gardenId {
    final $$GardensTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gardenId,
      referencedTable: $db.gardens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GardensTableFilterComposer(
            $db: $db,
            $table: $db.gardens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> assistantMessagesRefs(
    Expression<bool> Function($$AssistantMessagesTableFilterComposer f) f,
  ) {
    final $$AssistantMessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.assistantMessages,
      getReferencedColumn: (t) => t.threadId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssistantMessagesTableFilterComposer(
            $db: $db,
            $table: $db.assistantMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AssistantThreadsTableOrderingComposer
    extends Composer<_$AppDatabase, $AssistantThreadsTable> {
  $$AssistantThreadsTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$GardensTableOrderingComposer get gardenId {
    final $$GardensTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gardenId,
      referencedTable: $db.gardens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GardensTableOrderingComposer(
            $db: $db,
            $table: $db.gardens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AssistantThreadsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssistantThreadsTable> {
  $$AssistantThreadsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$GardensTableAnnotationComposer get gardenId {
    final $$GardensTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gardenId,
      referencedTable: $db.gardens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GardensTableAnnotationComposer(
            $db: $db,
            $table: $db.gardens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> assistantMessagesRefs<T extends Object>(
    Expression<T> Function($$AssistantMessagesTableAnnotationComposer a) f,
  ) {
    final $$AssistantMessagesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.assistantMessages,
          getReferencedColumn: (t) => t.threadId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AssistantMessagesTableAnnotationComposer(
                $db: $db,
                $table: $db.assistantMessages,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$AssistantThreadsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AssistantThreadsTable,
          AssistantThreadRow,
          $$AssistantThreadsTableFilterComposer,
          $$AssistantThreadsTableOrderingComposer,
          $$AssistantThreadsTableAnnotationComposer,
          $$AssistantThreadsTableCreateCompanionBuilder,
          $$AssistantThreadsTableUpdateCompanionBuilder,
          (AssistantThreadRow, $$AssistantThreadsTableReferences),
          AssistantThreadRow,
          PrefetchHooks Function({bool gardenId, bool assistantMessagesRefs})
        > {
  $$AssistantThreadsTableTableManager(
    _$AppDatabase db,
    $AssistantThreadsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssistantThreadsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssistantThreadsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssistantThreadsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> gardenId = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssistantThreadsCompanion(
                id: id,
                gardenId: gardenId,
                title: title,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> gardenId = const Value.absent(),
                Value<String?> title = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssistantThreadsCompanion.insert(
                id: id,
                gardenId: gardenId,
                title: title,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AssistantThreadsTable, AssistantThreadRow>(
                    table,
                  ),
                  $$AssistantThreadsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({gardenId = false, assistantMessagesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (assistantMessagesRefs) db.assistantMessages,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (gardenId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.gardenId,
                                    referencedTable:
                                        $$AssistantThreadsTableReferences
                                            ._gardenIdTable(db),
                                    referencedColumn:
                                        $$AssistantThreadsTableReferences
                                            ._gardenIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (assistantMessagesRefs)
                        await $_getPrefetchedData<
                          AssistantThreadRow,
                          $AssistantThreadsTable,
                          AssistantMessageRow
                        >(
                          currentTable: table,
                          referencedTable: $$AssistantThreadsTableReferences
                              ._assistantMessagesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AssistantThreadsTableReferences(
                                db,
                                table,
                                p0,
                              ).assistantMessagesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.threadId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$AssistantThreadsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AssistantThreadsTable,
      AssistantThreadRow,
      $$AssistantThreadsTableFilterComposer,
      $$AssistantThreadsTableOrderingComposer,
      $$AssistantThreadsTableAnnotationComposer,
      $$AssistantThreadsTableCreateCompanionBuilder,
      $$AssistantThreadsTableUpdateCompanionBuilder,
      (AssistantThreadRow, $$AssistantThreadsTableReferences),
      AssistantThreadRow,
      PrefetchHooks Function({bool gardenId, bool assistantMessagesRefs})
    >;
typedef $$AssistantMessagesTableCreateCompanionBuilder =
    AssistantMessagesCompanion Function({
      required String id,
      required String threadId,
      required String role,
      required String body,
      Value<String?> contextSummary,
      Value<String> status,
      Value<String?> feedback,
      Value<String?> feedbackComment,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$AssistantMessagesTableUpdateCompanionBuilder =
    AssistantMessagesCompanion Function({
      Value<String> id,
      Value<String> threadId,
      Value<String> role,
      Value<String> body,
      Value<String?> contextSummary,
      Value<String> status,
      Value<String?> feedback,
      Value<String?> feedbackComment,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$AssistantMessagesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $AssistantMessagesTable,
          AssistantMessageRow
        > {
  $$AssistantMessagesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AssistantThreadsTable _threadIdTable(_$AppDatabase db) => db
      .assistantThreads
      .createAlias('assistant_messages__thread_id__assistant_threads__id');

  $$AssistantThreadsTableProcessedTableManager get threadId {
    final $_column = $_itemColumn<String>('thread_id')!;

    final manager = $$AssistantThreadsTableTableManager(
      $_db,
      $_db.assistantThreads,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_threadIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AssistantMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $AssistantMessagesTable> {
  $$AssistantMessagesTableFilterComposer({
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

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contextSummary => $composableBuilder(
    column: $table.contextSummary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get feedback => $composableBuilder(
    column: $table.feedback,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get feedbackComment => $composableBuilder(
    column: $table.feedbackComment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$AssistantThreadsTableFilterComposer get threadId {
    final $$AssistantThreadsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.threadId,
      referencedTable: $db.assistantThreads,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssistantThreadsTableFilterComposer(
            $db: $db,
            $table: $db.assistantThreads,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AssistantMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $AssistantMessagesTable> {
  $$AssistantMessagesTableOrderingComposer({
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

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contextSummary => $composableBuilder(
    column: $table.contextSummary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feedback => $composableBuilder(
    column: $table.feedback,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feedbackComment => $composableBuilder(
    column: $table.feedbackComment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$AssistantThreadsTableOrderingComposer get threadId {
    final $$AssistantThreadsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.threadId,
      referencedTable: $db.assistantThreads,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssistantThreadsTableOrderingComposer(
            $db: $db,
            $table: $db.assistantThreads,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AssistantMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssistantMessagesTable> {
  $$AssistantMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get contextSummary => $composableBuilder(
    column: $table.contextSummary,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get feedback =>
      $composableBuilder(column: $table.feedback, builder: (column) => column);

  GeneratedColumn<String> get feedbackComment => $composableBuilder(
    column: $table.feedbackComment,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$AssistantThreadsTableAnnotationComposer get threadId {
    final $$AssistantThreadsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.threadId,
      referencedTable: $db.assistantThreads,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssistantThreadsTableAnnotationComposer(
            $db: $db,
            $table: $db.assistantThreads,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AssistantMessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AssistantMessagesTable,
          AssistantMessageRow,
          $$AssistantMessagesTableFilterComposer,
          $$AssistantMessagesTableOrderingComposer,
          $$AssistantMessagesTableAnnotationComposer,
          $$AssistantMessagesTableCreateCompanionBuilder,
          $$AssistantMessagesTableUpdateCompanionBuilder,
          (AssistantMessageRow, $$AssistantMessagesTableReferences),
          AssistantMessageRow,
          PrefetchHooks Function({bool threadId})
        > {
  $$AssistantMessagesTableTableManager(
    _$AppDatabase db,
    $AssistantMessagesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssistantMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssistantMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssistantMessagesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> threadId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String?> contextSummary = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> feedback = const Value.absent(),
                Value<String?> feedbackComment = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssistantMessagesCompanion(
                id: id,
                threadId: threadId,
                role: role,
                body: body,
                contextSummary: contextSummary,
                status: status,
                feedback: feedback,
                feedbackComment: feedbackComment,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String threadId,
                required String role,
                required String body,
                Value<String?> contextSummary = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> feedback = const Value.absent(),
                Value<String?> feedbackComment = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssistantMessagesCompanion.insert(
                id: id,
                threadId: threadId,
                role: role,
                body: body,
                contextSummary: contextSummary,
                status: status,
                feedback: feedback,
                feedbackComment: feedbackComment,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AssistantMessagesTable, AssistantMessageRow>(
                    table,
                  ),
                  $$AssistantMessagesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({threadId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (threadId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.threadId,
                                referencedTable:
                                    $$AssistantMessagesTableReferences
                                        ._threadIdTable(db),
                                referencedColumn:
                                    $$AssistantMessagesTableReferences
                                        ._threadIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AssistantMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AssistantMessagesTable,
      AssistantMessageRow,
      $$AssistantMessagesTableFilterComposer,
      $$AssistantMessagesTableOrderingComposer,
      $$AssistantMessagesTableAnnotationComposer,
      $$AssistantMessagesTableCreateCompanionBuilder,
      $$AssistantMessagesTableUpdateCompanionBuilder,
      (AssistantMessageRow, $$AssistantMessagesTableReferences),
      AssistantMessageRow,
      PrefetchHooks Function({bool threadId})
    >;
typedef $$InventoryMovementsTableCreateCompanionBuilder =
    InventoryMovementsCompanion Function({
      required String id,
      required String gardenId,
      required String itemId,
      required double qtyDelta,
      required String reason,
      Value<String?> taskId,
      required DateTime at,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$InventoryMovementsTableUpdateCompanionBuilder =
    InventoryMovementsCompanion Function({
      Value<String> id,
      Value<String> gardenId,
      Value<String> itemId,
      Value<double> qtyDelta,
      Value<String> reason,
      Value<String?> taskId,
      Value<DateTime> at,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$InventoryMovementsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $InventoryMovementsTable,
          InventoryMovementRow
        > {
  $$InventoryMovementsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $GardensTable _gardenIdTable(_$AppDatabase db) =>
      db.gardens.createAlias('inventory_movements__garden_id__gardens__id');

  $$GardensTableProcessedTableManager get gardenId {
    final $_column = $_itemColumn<String>('garden_id')!;

    final manager = $$GardensTableTableManager(
      $_db,
      $_db.gardens,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gardenIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $InventoryItemsTable _itemIdTable(_$AppDatabase db) => db
      .inventoryItems
      .createAlias('inventory_movements__item_id__inventory_items__id');

  $$InventoryItemsTableProcessedTableManager get itemId {
    final $_column = $_itemColumn<String>('item_id')!;

    final manager = $$InventoryItemsTableTableManager(
      $_db,
      $_db.inventoryItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TasksTable _taskIdTable(_$AppDatabase db) =>
      db.tasks.createAlias('inventory_movements__task_id__tasks__id');

  $$TasksTableProcessedTableManager? get taskId {
    final $_column = $_itemColumn<String>('task_id');
    if ($_column == null) return null;
    final manager = $$TasksTableTableManager(
      $_db,
      $_db.tasks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$InventoryMovementsTableFilterComposer
    extends Composer<_$AppDatabase, $InventoryMovementsTable> {
  $$InventoryMovementsTableFilterComposer({
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

  ColumnFilters<double> get qtyDelta => $composableBuilder(
    column: $table.qtyDelta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$GardensTableFilterComposer get gardenId {
    final $$GardensTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gardenId,
      referencedTable: $db.gardens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GardensTableFilterComposer(
            $db: $db,
            $table: $db.gardens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InventoryItemsTableFilterComposer get itemId {
    final $$InventoryItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.inventoryItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InventoryItemsTableFilterComposer(
            $db: $db,
            $table: $db.inventoryItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TasksTableFilterComposer get taskId {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InventoryMovementsTableOrderingComposer
    extends Composer<_$AppDatabase, $InventoryMovementsTable> {
  $$InventoryMovementsTableOrderingComposer({
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

  ColumnOrderings<double> get qtyDelta => $composableBuilder(
    column: $table.qtyDelta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$GardensTableOrderingComposer get gardenId {
    final $$GardensTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gardenId,
      referencedTable: $db.gardens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GardensTableOrderingComposer(
            $db: $db,
            $table: $db.gardens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InventoryItemsTableOrderingComposer get itemId {
    final $$InventoryItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.inventoryItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InventoryItemsTableOrderingComposer(
            $db: $db,
            $table: $db.inventoryItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TasksTableOrderingComposer get taskId {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableOrderingComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InventoryMovementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InventoryMovementsTable> {
  $$InventoryMovementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get qtyDelta =>
      $composableBuilder(column: $table.qtyDelta, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$GardensTableAnnotationComposer get gardenId {
    final $$GardensTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gardenId,
      referencedTable: $db.gardens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GardensTableAnnotationComposer(
            $db: $db,
            $table: $db.gardens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InventoryItemsTableAnnotationComposer get itemId {
    final $$InventoryItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.inventoryItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InventoryItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.inventoryItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TasksTableAnnotationComposer get taskId {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InventoryMovementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InventoryMovementsTable,
          InventoryMovementRow,
          $$InventoryMovementsTableFilterComposer,
          $$InventoryMovementsTableOrderingComposer,
          $$InventoryMovementsTableAnnotationComposer,
          $$InventoryMovementsTableCreateCompanionBuilder,
          $$InventoryMovementsTableUpdateCompanionBuilder,
          (InventoryMovementRow, $$InventoryMovementsTableReferences),
          InventoryMovementRow,
          PrefetchHooks Function({bool gardenId, bool itemId, bool taskId})
        > {
  $$InventoryMovementsTableTableManager(
    _$AppDatabase db,
    $InventoryMovementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InventoryMovementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InventoryMovementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InventoryMovementsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> gardenId = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<double> qtyDelta = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<String?> taskId = const Value.absent(),
                Value<DateTime> at = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InventoryMovementsCompanion(
                id: id,
                gardenId: gardenId,
                itemId: itemId,
                qtyDelta: qtyDelta,
                reason: reason,
                taskId: taskId,
                at: at,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String gardenId,
                required String itemId,
                required double qtyDelta,
                required String reason,
                Value<String?> taskId = const Value.absent(),
                required DateTime at,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InventoryMovementsCompanion.insert(
                id: id,
                gardenId: gardenId,
                itemId: itemId,
                qtyDelta: qtyDelta,
                reason: reason,
                taskId: taskId,
                at: at,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$InventoryMovementsTable, InventoryMovementRow>(
                    table,
                  ),
                  $$InventoryMovementsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({gardenId = false, itemId = false, taskId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (gardenId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.gardenId,
                                    referencedTable:
                                        $$InventoryMovementsTableReferences
                                            ._gardenIdTable(db),
                                    referencedColumn:
                                        $$InventoryMovementsTableReferences
                                            ._gardenIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (itemId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.itemId,
                                    referencedTable:
                                        $$InventoryMovementsTableReferences
                                            ._itemIdTable(db),
                                    referencedColumn:
                                        $$InventoryMovementsTableReferences
                                            ._itemIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (taskId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.taskId,
                                    referencedTable:
                                        $$InventoryMovementsTableReferences
                                            ._taskIdTable(db),
                                    referencedColumn:
                                        $$InventoryMovementsTableReferences
                                            ._taskIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$InventoryMovementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InventoryMovementsTable,
      InventoryMovementRow,
      $$InventoryMovementsTableFilterComposer,
      $$InventoryMovementsTableOrderingComposer,
      $$InventoryMovementsTableAnnotationComposer,
      $$InventoryMovementsTableCreateCompanionBuilder,
      $$InventoryMovementsTableUpdateCompanionBuilder,
      (InventoryMovementRow, $$InventoryMovementsTableReferences),
      InventoryMovementRow,
      PrefetchHooks Function({bool gardenId, bool itemId, bool taskId})
    >;
typedef $$SettingEntriesTableCreateCompanionBuilder =
    SettingEntriesCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$SettingEntriesTableUpdateCompanionBuilder =
    SettingEntriesCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$SettingEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SettingEntriesTable> {
  $$SettingEntriesTableFilterComposer({
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

class $$SettingEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingEntriesTable> {
  $$SettingEntriesTableOrderingComposer({
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

class $$SettingEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingEntriesTable> {
  $$SettingEntriesTableAnnotationComposer({
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

class $$SettingEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingEntriesTable,
          SettingRow,
          $$SettingEntriesTableFilterComposer,
          $$SettingEntriesTableOrderingComposer,
          $$SettingEntriesTableAnnotationComposer,
          $$SettingEntriesTableCreateCompanionBuilder,
          $$SettingEntriesTableUpdateCompanionBuilder,
          (
            SettingRow,
            BaseReferences<_$AppDatabase, $SettingEntriesTable, SettingRow>,
          ),
          SettingRow,
          PrefetchHooks Function()
        > {
  $$SettingEntriesTableTableManager(
    _$AppDatabase db,
    $SettingEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) =>
                  SettingEntriesCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SettingEntriesCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingEntriesTable, SettingRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SettingEntriesTable,
                    SettingRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingEntriesTable,
      SettingRow,
      $$SettingEntriesTableFilterComposer,
      $$SettingEntriesTableOrderingComposer,
      $$SettingEntriesTableAnnotationComposer,
      $$SettingEntriesTableCreateCompanionBuilder,
      $$SettingEntriesTableUpdateCompanionBuilder,
      (
        SettingRow,
        BaseReferences<_$AppDatabase, $SettingEntriesTable, SettingRow>,
      ),
      SettingRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $SyncOutboxTableManager get syncOutbox =>
      $SyncOutboxTableManager(_db, _db.syncOutbox);
  $SyncStateTableManager get syncState =>
      $SyncStateTableManager(_db, _db.syncState);
  $$GardensTableTableManager get gardens =>
      $$GardensTableTableManager(_db, _db.gardens);
  $$ZonesTableTableManager get zones =>
      $$ZonesTableTableManager(_db, _db.zones);
  $$InventoryItemsTableTableManager get inventoryItems =>
      $$InventoryItemsTableTableManager(_db, _db.inventoryItems);
  $$IncidentsTableTableManager get incidents =>
      $$IncidentsTableTableManager(_db, _db.incidents);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$ActivitiesTableTableManager get activities =>
      $$ActivitiesTableTableManager(_db, _db.activities);
  $$PhotosTableTableManager get photos =>
      $$PhotosTableTableManager(_db, _db.photos);
  $$TaskMaterialsTableTableManager get taskMaterials =>
      $$TaskMaterialsTableTableManager(_db, _db.taskMaterials);
  $$ActivityMaterialsTableTableManager get activityMaterials =>
      $$ActivityMaterialsTableTableManager(_db, _db.activityMaterials);
  $$ShoppingItemsTableTableManager get shoppingItems =>
      $$ShoppingItemsTableTableManager(_db, _db.shoppingItems);
  $$AssistantThreadsTableTableManager get assistantThreads =>
      $$AssistantThreadsTableTableManager(_db, _db.assistantThreads);
  $$AssistantMessagesTableTableManager get assistantMessages =>
      $$AssistantMessagesTableTableManager(_db, _db.assistantMessages);
  $$InventoryMovementsTableTableManager get inventoryMovements =>
      $$InventoryMovementsTableTableManager(_db, _db.inventoryMovements);
  $$SettingEntriesTableTableManager get settingEntries =>
      $$SettingEntriesTableTableManager(_db, _db.settingEntries);
}
