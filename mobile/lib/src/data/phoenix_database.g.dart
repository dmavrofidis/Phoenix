// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phoenix_database.dart';

// ignore_for_file: type=lint
class $ProfileStatesTable extends ProfileStates
    with TableInfo<$ProfileStatesTable, ProfileState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfileStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storageVersionMeta = const VerificationMeta(
    'storageVersion',
  );
  @override
  late final GeneratedColumn<int> storageVersion = GeneratedColumn<int>(
    'storage_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
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
  @override
  List<GeneratedColumn> get $columns => [
    profileId,
    displayName,
    payload,
    storageVersion,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profile_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProfileState> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('storage_version')) {
      context.handle(
        _storageVersionMeta,
        storageVersion.isAcceptableOrUnknown(
          data['storage_version']!,
          _storageVersionMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {profileId};
  @override
  ProfileState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileState(
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      storageVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}storage_version'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ProfileStatesTable createAlias(String alias) {
    return $ProfileStatesTable(attachedDatabase, alias);
  }
}

class ProfileState extends DataClass implements Insertable<ProfileState> {
  final String profileId;
  final String displayName;
  final String payload;
  final int storageVersion;
  final DateTime updatedAt;
  const ProfileState({
    required this.profileId,
    required this.displayName,
    required this.payload,
    required this.storageVersion,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_id'] = Variable<String>(profileId);
    map['display_name'] = Variable<String>(displayName);
    map['payload'] = Variable<String>(payload);
    map['storage_version'] = Variable<int>(storageVersion);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ProfileStatesCompanion toCompanion(bool nullToAbsent) {
    return ProfileStatesCompanion(
      profileId: Value(profileId),
      displayName: Value(displayName),
      payload: Value(payload),
      storageVersion: Value(storageVersion),
      updatedAt: Value(updatedAt),
    );
  }

  factory ProfileState.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileState(
      profileId: serializer.fromJson<String>(json['profileId']),
      displayName: serializer.fromJson<String>(json['displayName']),
      payload: serializer.fromJson<String>(json['payload']),
      storageVersion: serializer.fromJson<int>(json['storageVersion']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileId': serializer.toJson<String>(profileId),
      'displayName': serializer.toJson<String>(displayName),
      'payload': serializer.toJson<String>(payload),
      'storageVersion': serializer.toJson<int>(storageVersion),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ProfileState copyWith({
    String? profileId,
    String? displayName,
    String? payload,
    int? storageVersion,
    DateTime? updatedAt,
  }) => ProfileState(
    profileId: profileId ?? this.profileId,
    displayName: displayName ?? this.displayName,
    payload: payload ?? this.payload,
    storageVersion: storageVersion ?? this.storageVersion,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ProfileState copyWithCompanion(ProfileStatesCompanion data) {
    return ProfileState(
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      payload: data.payload.present ? data.payload.value : this.payload,
      storageVersion: data.storageVersion.present
          ? data.storageVersion.value
          : this.storageVersion,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileState(')
          ..write('profileId: $profileId, ')
          ..write('displayName: $displayName, ')
          ..write('payload: $payload, ')
          ..write('storageVersion: $storageVersion, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(profileId, displayName, payload, storageVersion, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileState &&
          other.profileId == this.profileId &&
          other.displayName == this.displayName &&
          other.payload == this.payload &&
          other.storageVersion == this.storageVersion &&
          other.updatedAt == this.updatedAt);
}

class ProfileStatesCompanion extends UpdateCompanion<ProfileState> {
  final Value<String> profileId;
  final Value<String> displayName;
  final Value<String> payload;
  final Value<int> storageVersion;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ProfileStatesCompanion({
    this.profileId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.payload = const Value.absent(),
    this.storageVersion = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfileStatesCompanion.insert({
    required String profileId,
    required String displayName,
    required String payload,
    this.storageVersion = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : profileId = Value(profileId),
       displayName = Value(displayName),
       payload = Value(payload),
       updatedAt = Value(updatedAt);
  static Insertable<ProfileState> custom({
    Expression<String>? profileId,
    Expression<String>? displayName,
    Expression<String>? payload,
    Expression<int>? storageVersion,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (profileId != null) 'profile_id': profileId,
      if (displayName != null) 'display_name': displayName,
      if (payload != null) 'payload': payload,
      if (storageVersion != null) 'storage_version': storageVersion,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfileStatesCompanion copyWith({
    Value<String>? profileId,
    Value<String>? displayName,
    Value<String>? payload,
    Value<int>? storageVersion,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ProfileStatesCompanion(
      profileId: profileId ?? this.profileId,
      displayName: displayName ?? this.displayName,
      payload: payload ?? this.payload,
      storageVersion: storageVersion ?? this.storageVersion,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (storageVersion.present) {
      map['storage_version'] = Variable<int>(storageVersion.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfileStatesCompanion(')
          ..write('profileId: $profileId, ')
          ..write('displayName: $displayName, ')
          ..write('payload: $payload, ')
          ..write('storageVersion: $storageVersion, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppMetaTable extends AppMeta with TableInfo<$AppMetaTable, AppMetaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppMetaTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'app_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppMetaData> instance, {
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
  AppMetaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppMetaData(
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
  $AppMetaTable createAlias(String alias) {
    return $AppMetaTable(attachedDatabase, alias);
  }
}

class AppMetaData extends DataClass implements Insertable<AppMetaData> {
  final String key;
  final String value;
  const AppMetaData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppMetaCompanion toCompanion(bool nullToAbsent) {
    return AppMetaCompanion(key: Value(key), value: Value(value));
  }

  factory AppMetaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppMetaData(
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

  AppMetaData copyWith({String? key, String? value}) =>
      AppMetaData(key: key ?? this.key, value: value ?? this.value);
  AppMetaData copyWithCompanion(AppMetaCompanion data) {
    return AppMetaData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaData(')
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
      (other is AppMetaData &&
          other.key == this.key &&
          other.value == this.value);
}

class AppMetaCompanion extends UpdateCompanion<AppMetaData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppMetaCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppMetaCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppMetaData> custom({
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

  AppMetaCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppMetaCompanion(
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
    return (StringBuffer('AppMetaCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DiagnosticRowsTable extends DiagnosticRows
    with TableInfo<$DiagnosticRowsTable, DiagnosticRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DiagnosticRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('info'),
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
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    level,
    category,
    message,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'diagnostic_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<DiagnosticRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DiagnosticRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DiagnosticRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DiagnosticRowsTable createAlias(String alias) {
    return $DiagnosticRowsTable(attachedDatabase, alias);
  }
}

class DiagnosticRow extends DataClass implements Insertable<DiagnosticRow> {
  final int id;
  final String level;
  final String category;
  final String message;
  final DateTime createdAt;
  const DiagnosticRow({
    required this.id,
    required this.level,
    required this.category,
    required this.message,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['level'] = Variable<String>(level);
    map['category'] = Variable<String>(category);
    map['message'] = Variable<String>(message);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DiagnosticRowsCompanion toCompanion(bool nullToAbsent) {
    return DiagnosticRowsCompanion(
      id: Value(id),
      level: Value(level),
      category: Value(category),
      message: Value(message),
      createdAt: Value(createdAt),
    );
  }

  factory DiagnosticRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DiagnosticRow(
      id: serializer.fromJson<int>(json['id']),
      level: serializer.fromJson<String>(json['level']),
      category: serializer.fromJson<String>(json['category']),
      message: serializer.fromJson<String>(json['message']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'level': serializer.toJson<String>(level),
      'category': serializer.toJson<String>(category),
      'message': serializer.toJson<String>(message),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DiagnosticRow copyWith({
    int? id,
    String? level,
    String? category,
    String? message,
    DateTime? createdAt,
  }) => DiagnosticRow(
    id: id ?? this.id,
    level: level ?? this.level,
    category: category ?? this.category,
    message: message ?? this.message,
    createdAt: createdAt ?? this.createdAt,
  );
  DiagnosticRow copyWithCompanion(DiagnosticRowsCompanion data) {
    return DiagnosticRow(
      id: data.id.present ? data.id.value : this.id,
      level: data.level.present ? data.level.value : this.level,
      category: data.category.present ? data.category.value : this.category,
      message: data.message.present ? data.message.value : this.message,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DiagnosticRow(')
          ..write('id: $id, ')
          ..write('level: $level, ')
          ..write('category: $category, ')
          ..write('message: $message, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, level, category, message, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DiagnosticRow &&
          other.id == this.id &&
          other.level == this.level &&
          other.category == this.category &&
          other.message == this.message &&
          other.createdAt == this.createdAt);
}

class DiagnosticRowsCompanion extends UpdateCompanion<DiagnosticRow> {
  final Value<int> id;
  final Value<String> level;
  final Value<String> category;
  final Value<String> message;
  final Value<DateTime> createdAt;
  const DiagnosticRowsCompanion({
    this.id = const Value.absent(),
    this.level = const Value.absent(),
    this.category = const Value.absent(),
    this.message = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  DiagnosticRowsCompanion.insert({
    this.id = const Value.absent(),
    this.level = const Value.absent(),
    required String category,
    required String message,
    required DateTime createdAt,
  }) : category = Value(category),
       message = Value(message),
       createdAt = Value(createdAt);
  static Insertable<DiagnosticRow> custom({
    Expression<int>? id,
    Expression<String>? level,
    Expression<String>? category,
    Expression<String>? message,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (level != null) 'level': level,
      if (category != null) 'category': category,
      if (message != null) 'message': message,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  DiagnosticRowsCompanion copyWith({
    Value<int>? id,
    Value<String>? level,
    Value<String>? category,
    Value<String>? message,
    Value<DateTime>? createdAt,
  }) {
    return DiagnosticRowsCompanion(
      id: id ?? this.id,
      level: level ?? this.level,
      category: category ?? this.category,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DiagnosticRowsCompanion(')
          ..write('id: $id, ')
          ..write('level: $level, ')
          ..write('category: $category, ')
          ..write('message: $message, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ReminderRowsTable extends ReminderRows
    with TableInfo<$ReminderRowsTable, ReminderRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReminderRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _reminderIdMeta = const VerificationMeta(
    'reminderId',
  );
  @override
  late final GeneratedColumn<String> reminderId = GeneratedColumn<String>(
    'reminder_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weekdayMeta = const VerificationMeta(
    'weekday',
  );
  @override
  late final GeneratedColumn<int> weekday = GeneratedColumn<int>(
    'weekday',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minutesSinceMidnightMeta =
      const VerificationMeta('minutesSinceMidnight');
  @override
  late final GeneratedColumn<int> minutesSinceMidnight = GeneratedColumn<int>(
    'minutes_since_midnight',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _templateIdMeta = const VerificationMeta(
    'templateId',
  );
  @override
  late final GeneratedColumn<String> templateId = GeneratedColumn<String>(
    'template_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    reminderId,
    profileId,
    weekday,
    minutesSinceMidnight,
    templateId,
    enabled,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminder_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReminderRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('reminder_id')) {
      context.handle(
        _reminderIdMeta,
        reminderId.isAcceptableOrUnknown(data['reminder_id']!, _reminderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_reminderIdMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('weekday')) {
      context.handle(
        _weekdayMeta,
        weekday.isAcceptableOrUnknown(data['weekday']!, _weekdayMeta),
      );
    } else if (isInserting) {
      context.missing(_weekdayMeta);
    }
    if (data.containsKey('minutes_since_midnight')) {
      context.handle(
        _minutesSinceMidnightMeta,
        minutesSinceMidnight.isAcceptableOrUnknown(
          data['minutes_since_midnight']!,
          _minutesSinceMidnightMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_minutesSinceMidnightMeta);
    }
    if (data.containsKey('template_id')) {
      context.handle(
        _templateIdMeta,
        templateId.isAcceptableOrUnknown(data['template_id']!, _templateIdMeta),
      );
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {reminderId};
  @override
  ReminderRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReminderRow(
      reminderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminder_id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      weekday: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekday'],
      )!,
      minutesSinceMidnight: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minutes_since_midnight'],
      )!,
      templateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}template_id'],
      ),
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
    );
  }

  @override
  $ReminderRowsTable createAlias(String alias) {
    return $ReminderRowsTable(attachedDatabase, alias);
  }
}

class ReminderRow extends DataClass implements Insertable<ReminderRow> {
  final String reminderId;
  final String profileId;
  final int weekday;
  final int minutesSinceMidnight;
  final String? templateId;
  final bool enabled;
  const ReminderRow({
    required this.reminderId,
    required this.profileId,
    required this.weekday,
    required this.minutesSinceMidnight,
    this.templateId,
    required this.enabled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['reminder_id'] = Variable<String>(reminderId);
    map['profile_id'] = Variable<String>(profileId);
    map['weekday'] = Variable<int>(weekday);
    map['minutes_since_midnight'] = Variable<int>(minutesSinceMidnight);
    if (!nullToAbsent || templateId != null) {
      map['template_id'] = Variable<String>(templateId);
    }
    map['enabled'] = Variable<bool>(enabled);
    return map;
  }

  ReminderRowsCompanion toCompanion(bool nullToAbsent) {
    return ReminderRowsCompanion(
      reminderId: Value(reminderId),
      profileId: Value(profileId),
      weekday: Value(weekday),
      minutesSinceMidnight: Value(minutesSinceMidnight),
      templateId: templateId == null && nullToAbsent
          ? const Value.absent()
          : Value(templateId),
      enabled: Value(enabled),
    );
  }

  factory ReminderRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReminderRow(
      reminderId: serializer.fromJson<String>(json['reminderId']),
      profileId: serializer.fromJson<String>(json['profileId']),
      weekday: serializer.fromJson<int>(json['weekday']),
      minutesSinceMidnight: serializer.fromJson<int>(
        json['minutesSinceMidnight'],
      ),
      templateId: serializer.fromJson<String?>(json['templateId']),
      enabled: serializer.fromJson<bool>(json['enabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'reminderId': serializer.toJson<String>(reminderId),
      'profileId': serializer.toJson<String>(profileId),
      'weekday': serializer.toJson<int>(weekday),
      'minutesSinceMidnight': serializer.toJson<int>(minutesSinceMidnight),
      'templateId': serializer.toJson<String?>(templateId),
      'enabled': serializer.toJson<bool>(enabled),
    };
  }

  ReminderRow copyWith({
    String? reminderId,
    String? profileId,
    int? weekday,
    int? minutesSinceMidnight,
    Value<String?> templateId = const Value.absent(),
    bool? enabled,
  }) => ReminderRow(
    reminderId: reminderId ?? this.reminderId,
    profileId: profileId ?? this.profileId,
    weekday: weekday ?? this.weekday,
    minutesSinceMidnight: minutesSinceMidnight ?? this.minutesSinceMidnight,
    templateId: templateId.present ? templateId.value : this.templateId,
    enabled: enabled ?? this.enabled,
  );
  ReminderRow copyWithCompanion(ReminderRowsCompanion data) {
    return ReminderRow(
      reminderId: data.reminderId.present
          ? data.reminderId.value
          : this.reminderId,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      weekday: data.weekday.present ? data.weekday.value : this.weekday,
      minutesSinceMidnight: data.minutesSinceMidnight.present
          ? data.minutesSinceMidnight.value
          : this.minutesSinceMidnight,
      templateId: data.templateId.present
          ? data.templateId.value
          : this.templateId,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReminderRow(')
          ..write('reminderId: $reminderId, ')
          ..write('profileId: $profileId, ')
          ..write('weekday: $weekday, ')
          ..write('minutesSinceMidnight: $minutesSinceMidnight, ')
          ..write('templateId: $templateId, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    reminderId,
    profileId,
    weekday,
    minutesSinceMidnight,
    templateId,
    enabled,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReminderRow &&
          other.reminderId == this.reminderId &&
          other.profileId == this.profileId &&
          other.weekday == this.weekday &&
          other.minutesSinceMidnight == this.minutesSinceMidnight &&
          other.templateId == this.templateId &&
          other.enabled == this.enabled);
}

class ReminderRowsCompanion extends UpdateCompanion<ReminderRow> {
  final Value<String> reminderId;
  final Value<String> profileId;
  final Value<int> weekday;
  final Value<int> minutesSinceMidnight;
  final Value<String?> templateId;
  final Value<bool> enabled;
  final Value<int> rowid;
  const ReminderRowsCompanion({
    this.reminderId = const Value.absent(),
    this.profileId = const Value.absent(),
    this.weekday = const Value.absent(),
    this.minutesSinceMidnight = const Value.absent(),
    this.templateId = const Value.absent(),
    this.enabled = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReminderRowsCompanion.insert({
    required String reminderId,
    required String profileId,
    required int weekday,
    required int minutesSinceMidnight,
    this.templateId = const Value.absent(),
    this.enabled = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : reminderId = Value(reminderId),
       profileId = Value(profileId),
       weekday = Value(weekday),
       minutesSinceMidnight = Value(minutesSinceMidnight);
  static Insertable<ReminderRow> custom({
    Expression<String>? reminderId,
    Expression<String>? profileId,
    Expression<int>? weekday,
    Expression<int>? minutesSinceMidnight,
    Expression<String>? templateId,
    Expression<bool>? enabled,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (reminderId != null) 'reminder_id': reminderId,
      if (profileId != null) 'profile_id': profileId,
      if (weekday != null) 'weekday': weekday,
      if (minutesSinceMidnight != null)
        'minutes_since_midnight': minutesSinceMidnight,
      if (templateId != null) 'template_id': templateId,
      if (enabled != null) 'enabled': enabled,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReminderRowsCompanion copyWith({
    Value<String>? reminderId,
    Value<String>? profileId,
    Value<int>? weekday,
    Value<int>? minutesSinceMidnight,
    Value<String?>? templateId,
    Value<bool>? enabled,
    Value<int>? rowid,
  }) {
    return ReminderRowsCompanion(
      reminderId: reminderId ?? this.reminderId,
      profileId: profileId ?? this.profileId,
      weekday: weekday ?? this.weekday,
      minutesSinceMidnight: minutesSinceMidnight ?? this.minutesSinceMidnight,
      templateId: templateId ?? this.templateId,
      enabled: enabled ?? this.enabled,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (reminderId.present) {
      map['reminder_id'] = Variable<String>(reminderId.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (weekday.present) {
      map['weekday'] = Variable<int>(weekday.value);
    }
    if (minutesSinceMidnight.present) {
      map['minutes_since_midnight'] = Variable<int>(minutesSinceMidnight.value);
    }
    if (templateId.present) {
      map['template_id'] = Variable<String>(templateId.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReminderRowsCompanion(')
          ..write('reminderId: $reminderId, ')
          ..write('profileId: $profileId, ')
          ..write('weekday: $weekday, ')
          ..write('minutesSinceMidnight: $minutesSinceMidnight, ')
          ..write('templateId: $templateId, ')
          ..write('enabled: $enabled, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$PhoenixDatabase extends GeneratedDatabase {
  _$PhoenixDatabase(QueryExecutor e) : super(e);
  $PhoenixDatabaseManager get managers => $PhoenixDatabaseManager(this);
  late final $ProfileStatesTable profileStates = $ProfileStatesTable(this);
  late final $AppMetaTable appMeta = $AppMetaTable(this);
  late final $DiagnosticRowsTable diagnosticRows = $DiagnosticRowsTable(this);
  late final $ReminderRowsTable reminderRows = $ReminderRowsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    profileStates,
    appMeta,
    diagnosticRows,
    reminderRows,
  ];
}

typedef $$ProfileStatesTableCreateCompanionBuilder =
    ProfileStatesCompanion Function({
      required String profileId,
      required String displayName,
      required String payload,
      Value<int> storageVersion,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ProfileStatesTableUpdateCompanionBuilder =
    ProfileStatesCompanion Function({
      Value<String> profileId,
      Value<String> displayName,
      Value<String> payload,
      Value<int> storageVersion,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$ProfileStatesTableFilterComposer
    extends Composer<_$PhoenixDatabase, $ProfileStatesTable> {
  $$ProfileStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get storageVersion => $composableBuilder(
    column: $table.storageVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProfileStatesTableOrderingComposer
    extends Composer<_$PhoenixDatabase, $ProfileStatesTable> {
  $$ProfileStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get storageVersion => $composableBuilder(
    column: $table.storageVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfileStatesTableAnnotationComposer
    extends Composer<_$PhoenixDatabase, $ProfileStatesTable> {
  $$ProfileStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<int> get storageVersion => $composableBuilder(
    column: $table.storageVersion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ProfileStatesTableTableManager
    extends
        RootTableManager<
          _$PhoenixDatabase,
          $ProfileStatesTable,
          ProfileState,
          $$ProfileStatesTableFilterComposer,
          $$ProfileStatesTableOrderingComposer,
          $$ProfileStatesTableAnnotationComposer,
          $$ProfileStatesTableCreateCompanionBuilder,
          $$ProfileStatesTableUpdateCompanionBuilder,
          (
            ProfileState,
            BaseReferences<
              _$PhoenixDatabase,
              $ProfileStatesTable,
              ProfileState
            >,
          ),
          ProfileState,
          PrefetchHooks Function()
        > {
  $$ProfileStatesTableTableManager(
    _$PhoenixDatabase db,
    $ProfileStatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfileStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfileStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfileStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> profileId = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> storageVersion = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfileStatesCompanion(
                profileId: profileId,
                displayName: displayName,
                payload: payload,
                storageVersion: storageVersion,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String profileId,
                required String displayName,
                required String payload,
                Value<int> storageVersion = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ProfileStatesCompanion.insert(
                profileId: profileId,
                displayName: displayName,
                payload: payload,
                storageVersion: storageVersion,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProfileStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$PhoenixDatabase,
      $ProfileStatesTable,
      ProfileState,
      $$ProfileStatesTableFilterComposer,
      $$ProfileStatesTableOrderingComposer,
      $$ProfileStatesTableAnnotationComposer,
      $$ProfileStatesTableCreateCompanionBuilder,
      $$ProfileStatesTableUpdateCompanionBuilder,
      (
        ProfileState,
        BaseReferences<_$PhoenixDatabase, $ProfileStatesTable, ProfileState>,
      ),
      ProfileState,
      PrefetchHooks Function()
    >;
typedef $$AppMetaTableCreateCompanionBuilder =
    AppMetaCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppMetaTableUpdateCompanionBuilder =
    AppMetaCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppMetaTableFilterComposer
    extends Composer<_$PhoenixDatabase, $AppMetaTable> {
  $$AppMetaTableFilterComposer({
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

class $$AppMetaTableOrderingComposer
    extends Composer<_$PhoenixDatabase, $AppMetaTable> {
  $$AppMetaTableOrderingComposer({
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

class $$AppMetaTableAnnotationComposer
    extends Composer<_$PhoenixDatabase, $AppMetaTable> {
  $$AppMetaTableAnnotationComposer({
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

class $$AppMetaTableTableManager
    extends
        RootTableManager<
          _$PhoenixDatabase,
          $AppMetaTable,
          AppMetaData,
          $$AppMetaTableFilterComposer,
          $$AppMetaTableOrderingComposer,
          $$AppMetaTableAnnotationComposer,
          $$AppMetaTableCreateCompanionBuilder,
          $$AppMetaTableUpdateCompanionBuilder,
          (
            AppMetaData,
            BaseReferences<_$PhoenixDatabase, $AppMetaTable, AppMetaData>,
          ),
          AppMetaData,
          PrefetchHooks Function()
        > {
  $$AppMetaTableTableManager(_$PhoenixDatabase db, $AppMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppMetaCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) =>
                  AppMetaCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$PhoenixDatabase,
      $AppMetaTable,
      AppMetaData,
      $$AppMetaTableFilterComposer,
      $$AppMetaTableOrderingComposer,
      $$AppMetaTableAnnotationComposer,
      $$AppMetaTableCreateCompanionBuilder,
      $$AppMetaTableUpdateCompanionBuilder,
      (
        AppMetaData,
        BaseReferences<_$PhoenixDatabase, $AppMetaTable, AppMetaData>,
      ),
      AppMetaData,
      PrefetchHooks Function()
    >;
typedef $$DiagnosticRowsTableCreateCompanionBuilder =
    DiagnosticRowsCompanion Function({
      Value<int> id,
      Value<String> level,
      required String category,
      required String message,
      required DateTime createdAt,
    });
typedef $$DiagnosticRowsTableUpdateCompanionBuilder =
    DiagnosticRowsCompanion Function({
      Value<int> id,
      Value<String> level,
      Value<String> category,
      Value<String> message,
      Value<DateTime> createdAt,
    });

class $$DiagnosticRowsTableFilterComposer
    extends Composer<_$PhoenixDatabase, $DiagnosticRowsTable> {
  $$DiagnosticRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DiagnosticRowsTableOrderingComposer
    extends Composer<_$PhoenixDatabase, $DiagnosticRowsTable> {
  $$DiagnosticRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DiagnosticRowsTableAnnotationComposer
    extends Composer<_$PhoenixDatabase, $DiagnosticRowsTable> {
  $$DiagnosticRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$DiagnosticRowsTableTableManager
    extends
        RootTableManager<
          _$PhoenixDatabase,
          $DiagnosticRowsTable,
          DiagnosticRow,
          $$DiagnosticRowsTableFilterComposer,
          $$DiagnosticRowsTableOrderingComposer,
          $$DiagnosticRowsTableAnnotationComposer,
          $$DiagnosticRowsTableCreateCompanionBuilder,
          $$DiagnosticRowsTableUpdateCompanionBuilder,
          (
            DiagnosticRow,
            BaseReferences<
              _$PhoenixDatabase,
              $DiagnosticRowsTable,
              DiagnosticRow
            >,
          ),
          DiagnosticRow,
          PrefetchHooks Function()
        > {
  $$DiagnosticRowsTableTableManager(
    _$PhoenixDatabase db,
    $DiagnosticRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DiagnosticRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DiagnosticRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DiagnosticRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> level = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> message = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => DiagnosticRowsCompanion(
                id: id,
                level: level,
                category: category,
                message: message,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> level = const Value.absent(),
                required String category,
                required String message,
                required DateTime createdAt,
              }) => DiagnosticRowsCompanion.insert(
                id: id,
                level: level,
                category: category,
                message: message,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DiagnosticRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$PhoenixDatabase,
      $DiagnosticRowsTable,
      DiagnosticRow,
      $$DiagnosticRowsTableFilterComposer,
      $$DiagnosticRowsTableOrderingComposer,
      $$DiagnosticRowsTableAnnotationComposer,
      $$DiagnosticRowsTableCreateCompanionBuilder,
      $$DiagnosticRowsTableUpdateCompanionBuilder,
      (
        DiagnosticRow,
        BaseReferences<_$PhoenixDatabase, $DiagnosticRowsTable, DiagnosticRow>,
      ),
      DiagnosticRow,
      PrefetchHooks Function()
    >;
typedef $$ReminderRowsTableCreateCompanionBuilder =
    ReminderRowsCompanion Function({
      required String reminderId,
      required String profileId,
      required int weekday,
      required int minutesSinceMidnight,
      Value<String?> templateId,
      Value<bool> enabled,
      Value<int> rowid,
    });
typedef $$ReminderRowsTableUpdateCompanionBuilder =
    ReminderRowsCompanion Function({
      Value<String> reminderId,
      Value<String> profileId,
      Value<int> weekday,
      Value<int> minutesSinceMidnight,
      Value<String?> templateId,
      Value<bool> enabled,
      Value<int> rowid,
    });

class $$ReminderRowsTableFilterComposer
    extends Composer<_$PhoenixDatabase, $ReminderRowsTable> {
  $$ReminderRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get reminderId => $composableBuilder(
    column: $table.reminderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weekday => $composableBuilder(
    column: $table.weekday,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minutesSinceMidnight => $composableBuilder(
    column: $table.minutesSinceMidnight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReminderRowsTableOrderingComposer
    extends Composer<_$PhoenixDatabase, $ReminderRowsTable> {
  $$ReminderRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get reminderId => $composableBuilder(
    column: $table.reminderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weekday => $composableBuilder(
    column: $table.weekday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minutesSinceMidnight => $composableBuilder(
    column: $table.minutesSinceMidnight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReminderRowsTableAnnotationComposer
    extends Composer<_$PhoenixDatabase, $ReminderRowsTable> {
  $$ReminderRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get reminderId => $composableBuilder(
    column: $table.reminderId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<int> get weekday =>
      $composableBuilder(column: $table.weekday, builder: (column) => column);

  GeneratedColumn<int> get minutesSinceMidnight => $composableBuilder(
    column: $table.minutesSinceMidnight,
    builder: (column) => column,
  );

  GeneratedColumn<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);
}

class $$ReminderRowsTableTableManager
    extends
        RootTableManager<
          _$PhoenixDatabase,
          $ReminderRowsTable,
          ReminderRow,
          $$ReminderRowsTableFilterComposer,
          $$ReminderRowsTableOrderingComposer,
          $$ReminderRowsTableAnnotationComposer,
          $$ReminderRowsTableCreateCompanionBuilder,
          $$ReminderRowsTableUpdateCompanionBuilder,
          (
            ReminderRow,
            BaseReferences<_$PhoenixDatabase, $ReminderRowsTable, ReminderRow>,
          ),
          ReminderRow,
          PrefetchHooks Function()
        > {
  $$ReminderRowsTableTableManager(
    _$PhoenixDatabase db,
    $ReminderRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReminderRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReminderRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReminderRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> reminderId = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<int> weekday = const Value.absent(),
                Value<int> minutesSinceMidnight = const Value.absent(),
                Value<String?> templateId = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReminderRowsCompanion(
                reminderId: reminderId,
                profileId: profileId,
                weekday: weekday,
                minutesSinceMidnight: minutesSinceMidnight,
                templateId: templateId,
                enabled: enabled,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String reminderId,
                required String profileId,
                required int weekday,
                required int minutesSinceMidnight,
                Value<String?> templateId = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReminderRowsCompanion.insert(
                reminderId: reminderId,
                profileId: profileId,
                weekday: weekday,
                minutesSinceMidnight: minutesSinceMidnight,
                templateId: templateId,
                enabled: enabled,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReminderRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$PhoenixDatabase,
      $ReminderRowsTable,
      ReminderRow,
      $$ReminderRowsTableFilterComposer,
      $$ReminderRowsTableOrderingComposer,
      $$ReminderRowsTableAnnotationComposer,
      $$ReminderRowsTableCreateCompanionBuilder,
      $$ReminderRowsTableUpdateCompanionBuilder,
      (
        ReminderRow,
        BaseReferences<_$PhoenixDatabase, $ReminderRowsTable, ReminderRow>,
      ),
      ReminderRow,
      PrefetchHooks Function()
    >;

class $PhoenixDatabaseManager {
  final _$PhoenixDatabase _db;
  $PhoenixDatabaseManager(this._db);
  $$ProfileStatesTableTableManager get profileStates =>
      $$ProfileStatesTableTableManager(_db, _db.profileStates);
  $$AppMetaTableTableManager get appMeta =>
      $$AppMetaTableTableManager(_db, _db.appMeta);
  $$DiagnosticRowsTableTableManager get diagnosticRows =>
      $$DiagnosticRowsTableTableManager(_db, _db.diagnosticRows);
  $$ReminderRowsTableTableManager get reminderRows =>
      $$ReminderRowsTableTableManager(_db, _db.reminderRows);
}
