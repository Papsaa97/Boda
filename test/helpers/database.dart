import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:zahradnik_boda/core/database/app_database.dart';

/// Databáze v paměti pro testy (stejné SQLite jako v aplikaci).
AppDatabase memoryDatabase() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return AppDatabase(NativeDatabase.memory());
}
