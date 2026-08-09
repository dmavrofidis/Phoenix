import 'package:drift/drift.dart';

part 'phoenix_database.g.dart';

class ProfileStates extends Table {
  TextColumn get profileId => text()();
  TextColumn get displayName => text().withLength(min: 1, max: 60)();
  TextColumn get payload => text()();
  IntColumn get storageVersion => integer().withDefault(const Constant(1))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {profileId};
}

class AppMeta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

class DiagnosticRows extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get level => text().withDefault(const Constant('info'))();
  TextColumn get category => text()();
  TextColumn get message => text()();
  DateTimeColumn get createdAt => dateTime()();
}

class ReminderRows extends Table {
  TextColumn get reminderId => text()();
  TextColumn get profileId => text()();
  IntColumn get weekday => integer()();
  IntColumn get minutesSinceMidnight => integer()();
  TextColumn get templateId => text().nullable()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {reminderId};
}

@DriftDatabase(tables: [ProfileStates, AppMeta, DiagnosticRows, ReminderRows])
class PhoenixDatabase extends _$PhoenixDatabase {
  PhoenixDatabase(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(diagnosticRows);
      }
      if (from < 3) {
        await migrator.createTable(appMeta);
        await migrator.createTable(reminderRows);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      if (details.wasCreated) {
        await into(appMeta).insert(
          AppMetaCompanion.insert(key: 'activeProfileId', value: 'default'),
          mode: InsertMode.insertOrIgnore,
        );
      }
    },
  );
}
