import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show SupabaseClient;
import 'package:uuid/uuid.dart';

import '../../features/account/data/supabase_auth_service.dart';
import '../../features/account/domain/auth_service.dart';
import '../../features/activity/data/drift_activity_repository.dart';
import '../../features/assistant/data/demo_assistant_backend.dart';
import '../../features/assistant/data/drift_assistant_repository.dart';
import '../../features/assistant/data/supabase_assistant_backend.dart';
import '../../features/assistant/domain/assistant_backend.dart';
import '../../features/assistant/domain/assistant_message.dart';
import '../../features/activity/domain/activity_repository.dart';
import '../../features/inventory/data/drift_inventory_repository.dart';
import '../../features/inventory/domain/inventory_repository.dart';
import '../../features/settings/domain/settings_repository.dart';
import '../../features/settings/presentation/settings_controller.dart';
import '../../features/tasks/data/drift_task_repository.dart';
import '../../features/tasks/domain/task_repository.dart';
import '../../features/zones/data/drift_zone_repository.dart';
import '../../features/zones/domain/zone_repository.dart';
import '../database/app_database.dart';
import '../notifications/notification_scheduler.dart';
import '../photos/photo_storage.dart';
import '../sync/supabase_sync_remote.dart';
import '../sync/sync_remote.dart';

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

final inventoryRepositoryProvider = Provider<InventoryRepository>(
  (ref) => DriftInventoryRepository(
    ref.watch(databaseProvider),
    ref.watch(gardenIdProvider),
    ref.watch(clockProvider),
  ),
);

final shoppingRepositoryProvider = Provider<ShoppingRepository>(
  (ref) => DriftShoppingRepository(
    ref.watch(databaseProvider),
    ref.watch(gardenIdProvider),
    ref.watch(clockProvider),
  ),
);

final assistantRepositoryProvider = Provider<AssistantRepository>(
  (ref) => DriftAssistantRepository(
    ref.watch(databaseProvider),
    ref.watch(gardenIdProvider),
    ref.watch(clockProvider),
  ),
);

/// Klient Supabase; null = build bez backendu (jen telefon). Nastavuje
/// main.dart podle `--dart-define` (DECLOG D71).
final supabaseClientProvider = Provider<SupabaseClient?>((ref) => null);

final authServiceProvider = Provider<AuthService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client == null
      ? const UnavailableAuthService()
      : SupabaseAuthService(client);
});

/// Přihlášený uživatel (null = bez účtu).
final currentUserProvider = StreamProvider<AccountUser?>((ref) {
  final auth = ref.watch(authServiceProvider);
  // Změny se poslouchají hned, aby žádná nezapadla mezi prvními hodnotami.
  final users = StreamController<AccountUser?>()..add(auth.currentUser);
  final changes = auth.userChanges.listen(users.add, onError: users.addError);
  ref.onDispose(() {
    changes.cancel();
    users.close();
  });
  return users.stream;
});

/// Server pro synchronizaci; null bez backendu.
final syncRemoteProvider = Provider<SyncRemote?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client == null ? null : SupabaseSyncRemote(client);
});

/// Znovu načte aplikaci (po převzetí zahrady z účtu se mění id zahrady).
/// Nastavuje main.dart.
final restartAppProvider = Provider<void Function()>((ref) => () {});

/// Kam Bóďa posílá dotazy: s účtem Edge Function `boda-chat`, jinak
/// ukázkový režim bez AI (DECLOG D64).
/// Co chybí, aby Bóďa odpovídal skutečnou AI (spec kap. 9).
enum AssistantAccess {
  /// Aplikace nemá backend (build bez SUPABASE_URL).
  noBackend,

  /// Uživatel není přihlášený.
  signedOut,

  /// Chybí souhlas se zpracováním dotazů (DECLOG D72).
  noConsent,

  /// Dotazy jdou na server.
  ready,
}

final assistantAccessProvider = Provider<AssistantAccess>((ref) {
  if (ref.watch(supabaseClientProvider) == null) {
    return AssistantAccess.noBackend;
  }
  if (ref.watch(currentUserProvider).value == null) {
    return AssistantAccess.signedOut;
  }
  final consent = ref.watch(
    settingsControllerProvider.select((s) => s.aiConsentAt),
  );
  return consent == null ? AssistantAccess.noConsent : AssistantAccess.ready;
});

/// Bez přihlášení a souhlasu nic z telefonu neodchází: odpovídá ukázka.
final assistantBackendProvider = Provider<AssistantBackend>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null ||
      ref.watch(assistantAccessProvider) != AssistantAccess.ready) {
    return const DemoAssistantBackend();
  }
  return SupabaseAssistantBackend(client);
});
