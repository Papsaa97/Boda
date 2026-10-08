import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'app.dart';
import 'core/backend/backend_config.dart';
import 'core/database/app_database.dart';
import 'core/di/providers.dart';
import 'core/formatting/dates.dart';
import 'core/notifications/notification_scheduler.dart';
import 'core/photos/photo_storage.dart';
import 'core/storage/app_storage.dart';
import 'features/settings/data/drift_settings_repository.dart';

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

  // Účet, synchronizace a Bóďa s AI jen v buildu s adresou backendu.
  const backend = BackendConfig.fromEnvironment;
  SupabaseClient? client;
  if (backend.isConfigured) {
    final supabase = await Supabase.initialize(
      url: backend.url,
      publishableKey: backend.publishableKey,
    );
    client = supabase.client;
  }

  runApp(
    _Bootstrap(
      db: storage.db,
      gardenId: storage.gardenId,
      settings: storage.settings,
      photos: photos,
      notifications: notifications,
      client: client,
    ),
  );
}

/// Drží kořen aplikace. Po převzetí zahrady z účtu (DECLOG D70) se změní
/// id zahrady, takže se celá aplikace postaví znovu s novými providery.
class _Bootstrap extends StatefulWidget {
  const _Bootstrap({
    required this.db,
    required this.gardenId,
    required this.settings,
    required this.photos,
    required this.notifications,
    required this.client,
  });

  final AppDatabase db;
  final String gardenId;
  final DriftSettingsRepository settings;
  final PhotoStorage photos;
  final NotificationScheduler notifications;
  final SupabaseClient? client;

  @override
  State<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<_Bootstrap> {
  late String _gardenId = widget.gardenId;
  var _generation = 0;

  Future<void> _restart() async {
    final id = await widget.db.ensureDefaultGarden(
      newId: const Uuid().v4,
      now: DateTime.now(),
    );
    if (!mounted) return;
    setState(() {
      _gardenId = id;
      _generation++;
    });
  }

  @override
  Widget build(BuildContext context) => ProviderScope(
    key: ValueKey(_generation),
    overrides: [
      databaseProvider.overrideWithValue(widget.db),
      gardenIdProvider.overrideWithValue(_gardenId),
      settingsRepositoryProvider.overrideWithValue(widget.settings),
      photoStorageProvider.overrideWithValue(widget.photos),
      notificationSchedulerProvider.overrideWithValue(widget.notifications),
      supabaseClientProvider.overrideWithValue(widget.client),
      restartAppProvider.overrideWithValue(_restart),
    ],
    child: const ZahradnikBodaApp(),
  );
}
