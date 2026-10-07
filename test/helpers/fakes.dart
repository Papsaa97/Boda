import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zahradnik_boda_mvp01/core/di/providers.dart';
import 'package:zahradnik_boda_mvp01/features/activity/domain/activity_entity.dart';
import 'package:zahradnik_boda_mvp01/features/activity/domain/activity_repository.dart';
import 'package:zahradnik_boda_mvp01/features/zones/domain/zone_entity.dart';
import 'package:zahradnik_boda_mvp01/features/zones/domain/zone_repository.dart';

class InMemoryActivityRepository implements ActivityRepository {
  InMemoryActivityRepository([List<ActivityEntity> initial = const []]) {
    for (final a in initial) {
      items[a.id] = a;
    }
  }

  final Map<String, ActivityEntity> items = {};

  @override
  Future<List<ActivityEntity>> getAllActivities() async => items.values.toList();

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

class InMemoryZoneRepository implements ZoneRepository {
  InMemoryZoneRepository([List<ZoneEntity> initial = defaultZones]) {
    for (final z in initial) {
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

  @override
  Future<void> seedDefaultsIfEmpty() async {
    if (items.isEmpty) {
      for (final z in defaultZones) {
        items[z.id] = z;
      }
    }
  }
}

/// Pevné „teď“ pro testy: úterý 7. 10. 2026 10:00.
final testNow = DateTime(2026, 10, 7, 10, 0);

ProviderContainer makeContainer({
  InMemoryActivityRepository? activities,
  InMemoryZoneRepository? zones,
}) {
  return ProviderContainer(overrides: testOverrides(
    activities: activities,
    zones: zones,
  ));
}

List<Override> testOverrides({
  InMemoryActivityRepository? activities,
  InMemoryZoneRepository? zones,
}) {
  return [
    activityRepositoryProvider
        .overrideWithValue(activities ?? InMemoryActivityRepository()),
    zoneRepositoryProvider.overrideWithValue(zones ?? InMemoryZoneRepository()),
    clockProvider.overrideWithValue(() => testNow),
  ];
}

ActivityEntity activity(
  String id, {
  required DateTime date,
  String zoneId = 'Z1',
  String? title,
  String? notes,
}) {
  return ActivityEntity(
    id: id,
    title: title ?? 'Aktivita $id',
    date: date,
    zoneId: zoneId,
    notes: notes,
  );
}

Widget wrap(Widget child, List<Override> overrides) =>
    ProviderScope(overrides: overrides, child: child);
