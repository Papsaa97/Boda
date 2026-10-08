import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'app.dart';
import 'core/app/app_info.dart';
import 'core/backend/backend_config.dart';
import 'core/backend/release_config.dart';
import 'core/database/app_database.dart';
import 'core/di/providers.dart';
import 'core/formatting/dates.dart';
import 'core/notifications/notification_scheduler.dart';
import 'core/photos/photo_storage.dart';
import 'core/storage/app_storage.dart';
import 'core/telemetry/posthog_analytics.dart';
import 'core/telemetry/sentry_crash_reporter.dart';
import 'core/telemetry/telemetry.dart';
import 'features/premium/data/revenuecat_purchase_service.dart';
import 'features/premium/domain/premium.dart';
import 'features/settings/data/drift_settings_repository.dart';

Future<void> main() async {
  const release = ReleaseConfig.fromEnvironment;
  if (!release.hasSentry) return _run(release, const DebugCrashReporter());

  // Pády do Sentry (DECLOG D75, D102): bez osobních údajů a bez snímků
  // obrazovky; Sentry si sám zachytí chyby Flutteru i nezachycené výjimky.
  await SentryFlutter.init((options) {
    options
      ..dsn = release.sentryDsn
      ..environment = release.environment
      ..release = 'cz.zahradnikboda.app@$appVersion'
      ..sendDefaultPii = false
      ..attachScreenshot = false
      ..enableUserInteractionBreadcrumbs = false
      ..tracesSampleRate = 0;
  }, appRunner: () => _run(release, const SentryCrashReporter()));
}

Future<void> _run(ReleaseConfig release, CrashReporter crashes) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!release.hasSentry) {
    // Bez Sentry aspoň do konzole (DECLOG D75).
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      crashes.recordError(details.exception, details.stack, fatal: true);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      crashes.recordError(error, stack, fatal: true);
      return true;
    };
  }

  await initializeDateFormatting(appLocale);

  // Analytika (PostHog EU) jen se souhlasem: SDK se nastaví, ale všechno
  // automatické je vypnuté; události posílá jen `analyticsProvider`.
  Analytics? analytics;
  if (release.hasPosthog) {
    final config = PostHogConfig(release.posthogApiKey)
      ..host = release.posthogHost
      ..captureApplicationLifecycleEvents = false
      ..preloadFeatureFlags = false
      ..sendFeatureFlagEvent = false
      ..sessionReplay = false
      ..surveys = false
      ..capturePushNotificationSubscriptions = false
      ..capturePushNotificationOpened = false;
    await Posthog().setup(config);
    analytics = const PosthogAnalytics();
  }

  // Platby (RevenueCat) jen s klíčem pro tuhle platformu (DECLOG D73).
  PurchaseService purchases = const UnavailablePurchaseService();
  final revenueCatKey = release.revenueCatKey;
  if (revenueCatKey != null) {
    await Purchases.configure(PurchasesConfiguration(revenueCatKey));
    purchases = RevenueCatPurchaseService();
  }

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
      crashes: crashes,
      analytics: analytics,
      purchases: purchases,
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
    required this.crashes,
    required this.analytics,
    required this.purchases,
  });

  final AppDatabase db;
  final String gardenId;
  final DriftSettingsRepository settings;
  final PhotoStorage photos;
  final NotificationScheduler notifications;
  final SupabaseClient? client;
  final CrashReporter crashes;
  final Analytics? analytics;
  final PurchaseService purchases;

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
      crashReporterProvider.overrideWithValue(widget.crashes),
      analyticsSinkProvider.overrideWithValue(widget.analytics),
      purchaseServiceProvider.overrideWithValue(widget.purchases),
      restartAppProvider.overrideWithValue(_restart),
    ],
    child: const ZahradnikBodaApp(),
  );
}
