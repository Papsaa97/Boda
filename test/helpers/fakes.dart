import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zahradnik_boda/app.dart';
import 'package:zahradnik_boda/core/di/providers.dart';
import 'package:zahradnik_boda/core/photos/photo_storage.dart';
import 'package:zahradnik_boda/features/activity/domain/activity_entity.dart';
import 'package:zahradnik_boda/features/activity/domain/activity_repository.dart';
import 'package:zahradnik_boda/features/activity/domain/activity_type.dart';
import 'package:zahradnik_boda/features/assistant/domain/assistant_backend.dart';
import 'package:zahradnik_boda/features/assistant/domain/assistant_message.dart';
import 'package:zahradnik_boda/features/incidents/domain/incident.dart';
import 'package:zahradnik_boda/features/inventory/domain/inventory_item.dart';
import 'package:zahradnik_boda/features/inventory/domain/inventory_repository.dart';
import 'package:zahradnik_boda/features/inventory/domain/shopping_item.dart';
import 'package:zahradnik_boda/features/inventory/domain/stock_movement.dart';
import 'package:zahradnik_boda/features/settings/domain/app_settings.dart';
import 'package:zahradnik_boda/features/settings/domain/settings_repository.dart';
import 'package:zahradnik_boda/features/tasks/domain/task_entity.dart';
import 'package:zahradnik_boda/features/tasks/domain/task_repository.dart';
import 'package:zahradnik_boda/features/weather/domain/garden_site.dart';
import 'package:zahradnik_boda/features/weather/domain/weather.dart';
import 'package:zahradnik_boda/features/zones/domain/zone_entity.dart';
import 'package:zahradnik_boda/features/zones/domain/zone_repository.dart';

class InMemoryActivityRepository implements ActivityRepository {
  InMemoryActivityRepository([List<ActivityEntity> initial = const []]) {
    for (final a in initial) {
      items[a.id] = a;
    }
  }

  final Map<String, ActivityEntity> items = {};

  @override
  Future<List<ActivityEntity>> getAllActivities() async =>
      items.values.toList();

  @override
  Future<ActivityEntity?> getActivityById(String id) async => items[id];

  @override
  Future<void> addActivity(ActivityEntity activity) async =>
      items[activity.id] = activity;

  @override
  Future<void> updateActivity(ActivityEntity activity) async =>
      items[activity.id] = activity;

  @override
  Future<void> deleteActivity(String id) async => items.remove(id);
}

/// Výchozí zóny v testech (krátká id kvůli čitelnosti).
const testZones = [
  ZoneEntity(id: 'Z1', name: 'Zelenina', type: ZoneType.vegetable),
  ZoneEntity(id: 'Z2', name: 'Okrasná zahrada', type: ZoneType.ornamental),
  ZoneEntity(id: 'Z3', name: 'Ovocný sad', type: ZoneType.fruit),
  ZoneEntity(id: 'Z4', name: 'Trávník', type: ZoneType.lawn),
  ZoneEntity(id: 'Z5', name: 'Skleník', type: ZoneType.greenhouse),
];

class InMemoryZoneRepository implements ZoneRepository {
  InMemoryZoneRepository([List<ZoneEntity>? initial]) {
    for (final z in initial ?? testZones) {
      items[z.id] = z;
    }
  }

  final Map<String, ZoneEntity> items = {};

  @override
  Future<List<ZoneEntity>> getAllZones() async => items.values.toList();

  @override
  Future<void> saveZone(ZoneEntity zone) async => items[zone.id] = zone;

  @override
  Future<void> deleteZone(String id) async => items.remove(id);
}

class InMemoryTaskRepository implements TaskRepository {
  InMemoryTaskRepository([List<TaskEntity> initial = const []]) {
    for (final t in initial) {
      items[t.id] = t;
    }
  }

  final Map<String, TaskEntity> items = {};

  @override
  Future<List<TaskEntity>> getAllTasks() async => items.values.toList();

  @override
  Future<void> saveTask(TaskEntity task) async => items[task.id] = task;

  @override
  Future<void> deleteTask(String id) async => items.remove(id);

  /// Záznamy s materiálem z úkolu: id záznamu → materiál.
  final Map<String, List<TaskMaterial>> usedMaterials = {};

  @override
  Future<void> recordMaterialsUsed(TaskEntity task, String activityId) async =>
      usedMaterials[activityId] = task.materials;
}

class InMemoryInventoryRepository implements InventoryRepository {
  InMemoryInventoryRepository([List<InventoryItem> initial = const []]) {
    for (final i in initial) {
      items[i.id] = i;
    }
  }

  final Map<String, InventoryItem> items = {};

  @override
  Future<List<InventoryItem>> getAll() async => items.values.toList();

  @override
  Future<void> save(InventoryItem item) async => items[item.id] = item;

  @override
  Future<void> delete(String id) async => items.remove(id);

  final List<StockMovement> movementLog = [];

  @override
  Future<List<StockMovement>> movements({
    String? itemId,
    String? taskId,
  }) async => [
    for (final m in movementLog.reversed)
      if ((itemId == null || m.itemId == itemId) &&
          (taskId == null || m.taskId == taskId))
        m,
  ];

  @override
  Future<void> applyMovements(
    List<StockMovement> movements, {
    bool adjustStock = true,
  }) async {
    for (final m in movements) {
      movementLog.add(m);
      final item = items[m.itemId];
      if (!adjustStock || item == null) continue;
      final stock = item.stockQty + m.qtyDelta;
      items[m.itemId] = item.copyWith(stockQty: stock < 0 ? 0 : stock);
    }
  }
}

class InMemoryShoppingRepository implements ShoppingRepository {
  final Map<String, ShoppingItem> items = {};

  @override
  Future<List<ShoppingItem>> getAll() async => items.values.toList();

  @override
  Future<void> save(ShoppingItem item) async => items[item.id] = item;

  @override
  Future<void> delete(String id) async => items.remove(id);

  @override
  Future<void> clearDone() async => items.removeWhere((_, s) => s.done);
}

class InMemoryAssistantRepository implements AssistantRepository {
  final Map<String, AssistantThread> threads = {};
  final Map<String, AssistantMessage> items = {};

  @override
  Future<AssistantThread?> latestThread() async => threads.values.lastOrNull;

  @override
  Future<void> saveThread(AssistantThread thread) async =>
      threads[thread.id] = thread;

  @override
  Future<List<AssistantMessage>> messages(String threadId) async => [
    for (final m in items.values)
      if (m.threadId == threadId) m,
  ]..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  @override
  Future<void> saveMessage(AssistantMessage message) async =>
      items[message.id] = message;

  @override
  Future<void> deleteThread(String threadId) async {
    threads.remove(threadId);
    items.removeWhere((_, m) => m.threadId == threadId);
  }
}

class InMemorySettingsRepository implements SettingsRepository {
  InMemorySettingsRepository([this.current = const AppSettings()]);

  AppSettings current;

  @override
  AppSettings load() => current;

  @override
  Future<void> save(AppSettings settings) async => current = settings;
}

/// Pevné „teď“ pro testy: úterý 7. 10. 2026 10:00.
final testNow = DateTime(2026, 10, 7, 10, 0);

ProviderContainer makeContainer({
  InMemoryActivityRepository? activities,
  InMemoryZoneRepository? zones,
  InMemoryTaskRepository? tasks,
  InMemorySettingsRepository? settings,
  InMemoryInventoryRepository? inventory,
  InMemoryShoppingRepository? shopping,
  InMemoryAssistantRepository? assistant,
  AssistantBackend? backend,
  DateTime Function()? clock,
}) {
  return ProviderContainer(
    overrides: testOverrides(
      activities: activities,
      zones: zones,
      tasks: tasks,
      settings: settings,
      inventory: inventory,
      shopping: shopping,
      assistant: assistant,
      backend: backend,
      clock: clock,
    ),
  );
}

/// Poloha zahrady, počasí a nastavení zálivky v paměti.
class InMemoryGardenSiteRepository implements GardenSiteRepository {
  InMemoryGardenSiteRepository({
    this.site = const GardenSite(),
    this.cache,
    this.prefs = const WeatherPrefs(),
  });

  GardenSite site;
  CachedWeather? cache;
  WeatherPrefs prefs;

  @override
  Future<GardenSite> loadSite() async => site;

  @override
  Future<void> saveSite(GardenSite site) async => this.site = site;

  @override
  Future<CachedWeather?> loadCache() async => cache;

  @override
  Future<void> saveCache(CachedWeather? cache) async => this.cache = cache;

  @override
  Future<WeatherPrefs> loadPrefs() async => prefs;

  @override
  Future<void> savePrefs(WeatherPrefs prefs) async => this.prefs = prefs;
}

/// Id pro nové entity v testech: id-1, id-2, …
String Function() sequentialIds() {
  var n = 0;
  return () => 'id-${++n}';
}

List<Override> testOverrides({
  InMemoryActivityRepository? activities,
  InMemoryZoneRepository? zones,
  InMemoryTaskRepository? tasks,
  InMemorySettingsRepository? settings,
  InMemoryInventoryRepository? inventory,
  InMemoryShoppingRepository? shopping,
  InMemoryAssistantRepository? assistant,
  AssistantBackend? backend,
  DateTime Function()? clock,
  InMemoryIncidentRepository? incidents,
  InMemoryGardenSiteRepository? site,
  WeatherSource? weather,
}) {
  return [
    gardenSiteRepositoryProvider.overrideWithValue(
      site ?? InMemoryGardenSiteRepository(),
    ),
    weatherSourceProvider.overrideWithValue(
      weather ?? const UnavailableWeatherSource(),
    ),
    deviceLocationProvider.overrideWithValue(const UnsupportedDeviceLocation()),
    incidentRepositoryProvider.overrideWithValue(
      incidents ?? InMemoryIncidentRepository(),
    ),
    assistantRepositoryProvider.overrideWithValue(
      assistant ?? InMemoryAssistantRepository(),
    ),
    if (backend != null) assistantBackendProvider.overrideWithValue(backend),
    inventoryRepositoryProvider.overrideWithValue(
      inventory ?? InMemoryInventoryRepository(),
    ),
    shoppingRepositoryProvider.overrideWithValue(
      shopping ?? InMemoryShoppingRepository(),
    ),
    activityRepositoryProvider.overrideWithValue(
      activities ?? InMemoryActivityRepository(),
    ),
    zoneRepositoryProvider.overrideWithValue(zones ?? InMemoryZoneRepository()),
    taskRepositoryProvider.overrideWithValue(tasks ?? InMemoryTaskRepository()),
    settingsRepositoryProvider.overrideWithValue(
      settings ?? InMemorySettingsRepository(),
    ),
    newIdProvider.overrideWithValue(sequentialIds()),
    clockProvider.overrideWithValue(clock ?? () => testNow),
    photoStorageProvider.overrideWithValue(
      PhotoStorage('${Directory.systemTemp.path}/boda_test_photos'),
    ),
  ];
}

ActivityEntity activity(
  String id, {
  required DateTime date,
  String zoneId = 'Z1',
  String? title,
  String? notes,
  ActivityType type = ActivityType.other,
}) {
  return ActivityEntity(
    id: id,
    type: type,
    title: title ?? 'Aktivita $id',
    date: date,
    zoneId: zoneId,
    notes: notes,
  );
}

Widget wrap(Widget child, List<Override> overrides) =>
    ProviderScope(overrides: overrides, child: child);

/// Repozitář, jehož zápisy selžou (pro testy chybových stavů).
class FailingActivityRepository extends InMemoryActivityRepository {
  FailingActivityRepository([super.initial]);

  @override
  Future<void> addActivity(ActivityEntity activity) async =>
      throw Exception('disk je plný');

  @override
  Future<void> deleteActivity(String id) async =>
      throw Exception('disk je plný');
}

/// Spustí aplikaci na obrazovce velikosti telefonu (360 × 780).
Future<void> pumpApp(WidgetTester tester, List<Override> overrides) async {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(wrap(const ZahradnikBodaApp(), overrides));
  await tester.pumpAndSettle();
}

class InMemoryIncidentRepository implements IncidentRepository {
  final Map<String, Incident> items = {};

  @override
  Future<List<Incident>> getAll() async => items.values.toList();

  @override
  Future<void> save(Incident incident) async => items[incident.id] = incident;

  @override
  Future<void> delete(String id) async => items.remove(id);
}
