import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';

import '../../features/settings/data/drift_settings_repository.dart';
import '../database/app_database.dart';
import '../photos/photo_storage.dart';
import 'legacy_hive_import.dart';

/// Otevřené lokální úložiště, které aplikace potřebuje od prvního snímku.
class AppStorage {
  const AppStorage({
    required this.db,
    required this.gardenId,
    required this.settings,
  });

  final AppDatabase db;
  final String gardenId;
  final DriftSettingsRepository settings;
}

/// Připraví databázi: převede data z verze 0.1 (jen poprvé), založí
/// implicitní zahradu a načte nastavení.
///
/// [initHive] inicializuje Hive jen tehdy, když je převod potřeba
/// (`Hive.initFlutter` v aplikaci, `Hive.init` v testech).
Future<AppStorage> openAppStorage({
  required AppDatabase db,
  required String Function() newId,
  required DateTime Function() clock,
  required Future<void> Function() initHive,
  PhotoStorage? photos,
}) async {
  if (await db.readSetting(legacyImportSettingKey) == null) {
    try {
      await initHive();
      await importLegacyHiveData(
        db: db,
        newId: newId,
        now: clock(),
        photos: photos,
      );
    } catch (e, st) {
      // Stará data zůstávají v Hive a převod se zkusí při dalším startu.
      debugPrint('Převod dat z verze 0.1 selhal: $e\n$st');
    } finally {
      await Hive.close();
    }
  }
  final gardenId = await db.ensureDefaultGarden(newId: newId, now: clock());
  final settings = await DriftSettingsRepository.open(db);
  return AppStorage(db: db, gardenId: gardenId, settings: settings);
}
