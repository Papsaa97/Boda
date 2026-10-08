import 'package:flutter_test/flutter_test.dart';
import 'package:zahradnik_boda/core/database/app_database.dart';
import 'package:zahradnik_boda/features/activity/data/drift_activity_repository.dart';
import 'package:zahradnik_boda/features/activity/domain/activity_entity.dart';
import 'package:zahradnik_boda/features/activity/domain/activity_type.dart';
import 'package:zahradnik_boda/features/settings/data/drift_settings_repository.dart';
import 'package:zahradnik_boda/features/settings/domain/app_settings.dart';
import 'package:zahradnik_boda/features/tasks/data/drift_task_repository.dart';
import 'package:zahradnik_boda/features/tasks/domain/task_entity.dart';
import 'package:zahradnik_boda/features/zones/data/drift_zone_repository.dart';
import 'package:zahradnik_boda/features/zones/domain/zone_entity.dart';

import '../../helpers/database.dart';
import '../../helpers/fakes.dart';

void main() {
  late AppDatabase db;
  late String gardenId;
  late DriftZoneRepository zones;
  late DriftActivityRepository activities;
  late DriftTaskRepository tasks;

  setUp(() async {
    db = memoryDatabase();
    gardenId = await db.ensureDefaultGarden(newId: () => 'g', now: testNow);
    zones = DriftZoneRepository(db, gardenId, () => testNow);
    activities = DriftActivityRepository(db, gardenId, () => testNow);
    tasks = DriftTaskRepository(db, gardenId, () => testNow);
    await zones.saveZone(testZones.first);
  });

  tearDown(() => db.close());

  test('there is one implicit garden', () async {
    expect(gardenId, 'g');
    expect(await db.ensureDefaultGarden(newId: () => 'h', now: testNow), 'g');
  });

  test('zones: save, archive, soft delete', () async {
    await zones.saveZone(
      const ZoneEntity(id: 'Z2', name: 'Skleník', type: ZoneType.greenhouse),
    );
    await zones.saveZone(testZones.first.copyWith(archived: true));
    var all = await zones.getAllZones();
    expect(all.map((z) => z.id), ['Z1', 'Z2']);
    expect(all.first.archived, isTrue);
    expect(all.last.type, ZoneType.greenhouse);

    await zones.deleteZone('Z2');
    all = await zones.getAllZones();
    expect(all.map((z) => z.id), ['Z1']);
    // Měkké mazání: řádek zůstává kvůli synchronizaci v 1.0.
    final row = await (db.select(
      db.zones,
    )..where((z) => z.id.equals('Z2'))).getSingle();
    expect(row.deletedAt, isNotNull);
  });

  test('activity with photos round-trips in local time', () async {
    final date = DateTime(2026, 3, 29, 1, 30); // den přechodu na letní čas
    await activities.addActivity(
      ActivityEntity(
        id: 'a',
        type: ActivityType.sowing,
        title: 'Výsev rajčat',
        date: date,
        zoneId: 'Z1',
        notes: 'Za oknem',
        photos: const [
          PhotoRef(id: 'p1', path: 'activity_photos/p1.jpg'),
          PhotoRef(id: 'p2', path: 'activity_photos/p2.jpg'),
        ],
      ),
    );

    final loaded = (await activities.getActivityById('a'))!;
    expect(loaded.date, date);
    expect(loaded.type, ActivityType.sowing);
    expect(loaded.notes, 'Za oknem');
    expect(loaded.photos.map((p) => p.id), ['p1', 'p2']);

    final row = await db.select(db.activities).getSingle();
    expect(row.occurredTz, matches(RegExp(r'^[+-]\d\d:\d\d$')));
  });

  test('update reorders and removes photos, clears notes', () async {
    await activities.addActivity(
      ActivityEntity(
        id: 'a',
        title: 'Zálivka',
        date: testNow,
        zoneId: 'Z1',
        notes: 'x',
        photos: const [
          PhotoRef(id: 'p1', path: 'activity_photos/p1.jpg'),
          PhotoRef(id: 'p2', path: 'activity_photos/p2.jpg'),
        ],
      ),
    );
    final loaded = (await activities.getActivityById('a'))!;
    await activities.updateActivity(
      loaded.copyWith(
        clearNotes: true,
        photos: const [
          PhotoRef(id: 'p3', path: 'activity_photos/p3.jpg'),
          PhotoRef(id: 'p2', path: 'activity_photos/p2.jpg'),
        ],
      ),
    );
    final updated = (await activities.getActivityById('a'))!;
    expect(updated.notes, isNull);
    expect(updated.photos.map((p) => p.id), ['p3', 'p2']);
  });

  test('deleted activity disappears with its photos', () async {
    await activities.addActivity(
      ActivityEntity(
        id: 'a',
        title: 'Zálivka',
        date: testNow,
        zoneId: 'Z1',
        photos: const [PhotoRef(id: 'p1', path: 'activity_photos/p1.jpg')],
      ),
    );
    await activities.deleteActivity('a');
    expect(await activities.getAllActivities(), isEmpty);
    expect(await activities.getActivityById('a'), isNull);
    final photo = await db.select(db.photos).getSingle();
    expect(photo.deletedAt, isNotNull);
  });

  test('tasks keep dates as days and survive a round trip', () async {
    final task = TaskEntity(
      id: 't',
      title: 'Postřik broskvoně',
      zoneId: 'Z1',
      due: DateTime(2027, 2, 20),
      remindAt: 9 * 60 + 30,
      rrule: 'FREQ=YEARLY',
      snoozedUntil: DateTime(2027, 2, 21),
      notes: 'Proti kadeřavosti',
    );
    await tasks.saveTask(task);
    final loaded = (await tasks.getAllTasks()).single;
    expect(loaded.due, task.due);
    expect(loaded.snoozedUntil, task.snoozedUntil);
    expect(loaded.remindAt, task.remindAt);
    expect(loaded.rrule, task.rrule);
    expect((await db.select(db.tasks).getSingle()).due, '2027-02-20');

    await tasks.saveTask(loaded.copyWith(status: TaskStatus.done));
    expect((await tasks.getAllTasks()).single.status, TaskStatus.done);

    await tasks.deleteTask('t');
    expect(await tasks.getAllTasks(), isEmpty);
  });

  test('settings survive a restart and ignore broken values', () async {
    final repo = await DriftSettingsRepository.open(db);
    expect(repo.load(), const AppSettings());

    final changed = AppSettings(
      theme: ThemePreference.light,
      quietStart: 22 * 60,
      quietEnd: 7 * 60,
      digest: DigestMode.weekly,
      lastExportAt: testNow,
      lastZoneId: 'Z1',
    );
    await repo.save(changed);
    expect((await DriftSettingsRepository.open(db)).load(), changed);

    await db.writeSetting('quiet_start', 'nesmysl');
    await db.writeSetting('theme', 'purple');
    final reloaded = (await DriftSettingsRepository.open(db)).load();
    expect(reloaded.quietStart, 21 * 60);
    expect(reloaded.theme, ThemePreference.system);
  });
}
