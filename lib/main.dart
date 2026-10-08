import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'app.dart';
import 'core/database/app_database.dart';
import 'core/di/providers.dart';
import 'core/formatting/dates.dart';
import 'core/notifications/notification_scheduler.dart';
import 'core/photos/photo_storage.dart';
import 'core/storage/app_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting(appLocale);

  // Na webu fotky nejsou (prohlížeč nemá trvalou složku pro soubory).
  final photos = kIsWeb
      ? PhotoStorage('')
      : PhotoStorage((await getApplicationDocumentsDirectory()).path);

  final db = AppDatabase(
    driftDatabase(
      name: 'boda',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    ),
  );
  final storage = await openAppStorage(
    db: db,
    newId: const Uuid().v4,
    clock: DateTime.now,
    initHive: Hive.initFlutter,
    photos: kIsWeb ? null : photos,
  );
  final notifications = await LocalNotificationScheduler.create();

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(storage.db),
        gardenIdProvider.overrideWithValue(storage.gardenId),
        settingsRepositoryProvider.overrideWithValue(storage.settings),
        photoStorageProvider.overrideWithValue(photos),
        notificationSchedulerProvider.overrideWithValue(notifications),
      ],
      child: const ZahradnikBodaApp(),
    ),
  );
}
