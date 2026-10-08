import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../features/activity/data/drift_activity_repository.dart';
import '../../features/activity/domain/activity_repository.dart';
import '../../features/settings/domain/settings_repository.dart';
import '../../features/tasks/data/drift_task_repository.dart';
import '../../features/tasks/domain/task_repository.dart';
import '../../features/zones/data/drift_zone_repository.dart';
import '../../features/zones/domain/zone_repository.dart';
import '../database/app_database.dart';
import '../notifications/notification_scheduler.dart';
import '../photos/photo_storage.dart';

Never _notOverridden(String name) =>
    throw UnimplementedError('$name se nastavuje v main.dart (overrides).');

/// Otevřená lokální databáze. Nastavuje main.dart, v testech paměťová.
final databaseProvider = Provider<AppDatabase>(
  (ref) => _notOverridden('databaseProvider'),
);

/// Id implicitní zahrady (v 0.x je jen jedna, spec 8.2).
final gardenIdProvider = Provider<String>(
  (ref) => _notOverridden('gardenIdProvider'),
);

/// Nastavení načtená při startu.
final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => _notOverridden('settingsRepositoryProvider'),
);

/// Ukládání fotek k záznamům do složky aplikace.
///
/// Kořenovou složku zná až main.dart, proto se provider přepisuje.
final photoStorageProvider = Provider<PhotoStorage>(
  (ref) => _notOverridden('photoStorageProvider'),
);

/// Plánování lokálních notifikací. Bez přepsání nic neplánuje (testy, web).
final notificationSchedulerProvider = Provider<NotificationScheduler>(
  (ref) => NoopNotificationScheduler(),
);

/// Aktuální čas. V testech se přepisuje pevným datem.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Generátor nových id (UUID v4).
final newIdProvider = Provider<String Function()>((ref) => const Uuid().v4);

final activityRepositoryProvider = Provider<ActivityRepository>(
  (ref) => DriftActivityRepository(
    ref.watch(databaseProvider),
    ref.watch(gardenIdProvider),
    ref.watch(clockProvider),
  ),
);

final zoneRepositoryProvider = Provider<ZoneRepository>(
  (ref) => DriftZoneRepository(
    ref.watch(databaseProvider),
    ref.watch(gardenIdProvider),
    ref.watch(clockProvider),
  ),
);

final taskRepositoryProvider = Provider<TaskRepository>(
  (ref) => DriftTaskRepository(
    ref.watch(databaseProvider),
    ref.watch(gardenIdProvider),
    ref.watch(clockProvider),
  ),
);
