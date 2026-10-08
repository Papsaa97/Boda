import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:path/path.dart' as p;
import 'package:zahradnik_boda/core/database/app_database.dart';
import 'package:zahradnik_boda/core/photos/photo_storage.dart';
import 'package:zahradnik_boda/core/storage/app_storage.dart';
import 'package:zahradnik_boda/core/storage/legacy_hive_import.dart';
import 'package:zahradnik_boda/features/activity/data/drift_activity_repository.dart';
import 'package:zahradnik_boda/features/activity/domain/activity_type.dart';
import 'package:zahradnik_boda/features/zones/data/drift_zone_repository.dart';
import 'package:zahradnik_boda/features/zones/domain/zone_entity.dart';

import '../../helpers/database.dart';
import '../../helpers/fakes.dart';

/// Upgrade z verze 0.1 na 0.2 zachová data (spec 3, definice hotovo 0.2).
///
/// `test/fixtures/hive_0_1/activities.hive` zapsal původní balíček
/// `hive` 2.2.3 s adaptérem z commitu 6cf42f1 (verze 0.1).
void main() {
  late Directory dir;
  late String hiveDir;
  late AppDatabase db;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('boda_migration');
    hiveDir = p.join(dir.path, 'hive');
    Directory(hiveDir).createSync();
    File(
      'test/fixtures/hive_0_1/activities.hive',
    ).copySync(p.join(hiveDir, 'activities.hive'));
    Hive.init(hiveDir);
    db = memoryDatabase();
  });

  tearDown(() async {
    await Hive.close();
    await db.close();
    await dir.delete(recursive: true);
  });

  Future<LegacyImportResult> runImport({PhotoStorage? photos}) =>
      importLegacyHiveData(
        db: db,
        newId: sequentialIds(),
        now: testNow,
        photos: photos,
      );

  test('activities from 0.1 end up in the database with zones', () async {
    final result = await runImport();
    expect(result.activities, 2);

    final gardenId = await db.ensureDefaultGarden(
      newId: () => 'x',
      now: testNow,
    );
    final zones = await DriftZoneRepository(
      db,
      gardenId,
      () => testNow,
    ).getAllZones();
    final activities = await DriftActivityRepository(
      db,
      gardenId,
      () => testNow,
    ).getAllActivities();

    // Verze 0.1 neměla seznam zón, dostane výchozích pět (Z1–Z5).
    expect(zones.map((z) => z.name), [
      'Zelenina',
      'Okrasná zahrada',
      'Ovocný sad',
      'Trávník',
      'Skleník',
    ]);
    expect(zones.first.type, ZoneType.vegetable);
    // Zóny mají nová id (UUID), záznamy na ně odkazují.
    expect(zones.map((z) => z.id), isNot(contains('Z1')));

    final a1 = activities.firstWhere((a) => a.id == 'a1');
    expect(a1.title, 'Zálivka rajčat');
    // Fixtura vznikla v UTC; Hive ukládá okamžik, ne místní čas, proto
    // srovnání v UTC, aby test prošel v libovolném časovém pásmu.
    expect(a1.date.toUtc(), DateTime.utc(2026, 5, 1, 8, 30));
    expect(a1.notes, 'Ráno před sluncem');
    expect(a1.type, ActivityType.watering);
    expect(a1.zoneId, zones.first.id);

    final a2 = activities.firstWhere((a) => a.id == 'a2');
    expect(a2.title, 'Řez maliní');
    expect(a2.type, ActivityType.pruning);
    expect(a2.notes, isNull);
    expect(a2.photos, isEmpty);
  });

  test('import runs only once', () async {
    await runImport();
    final second = await runImport();
    expect(second.activities, 0);
    expect(await db.select(db.activities).get(), hasLength(2));
    expect(await db.readSetting(legacyImportSettingKey), isNotNull);
  });

  test('zones chosen in 0.1 onboarding keep their names', () async {
    final zones = await Hive.openBox<String>('zones');
    await zones.putAll({'Z1': 'Záhon u plotu', 'Z6': 'Bylinky'});
    await zones.close();

    await runImport();
    final rows = await db.select(db.zones).get();
    final byName = {for (final z in rows) z.name: z.type};
    expect(byName['Záhon u plotu'], 'vegetable');
    expect(byName['Bylinky'], 'herbs');
    // Zóna, na kterou odkazuje záznam a v boxu chybí, se dotvoří.
    expect(rows.length, greaterThanOrEqualTo(2));
    final zoneIds = {for (final z in rows) z.id};
    for (final a in await db.select(db.activities).get()) {
      expect(zoneIds, contains(a.zoneId));
    }
  });

  test('photo from the old cache is copied into the app folder', () async {
    // Verze 0.1 ukládala cestu do cache file_pickeru.
    final cached = File(p.join(dir.path, 'cache', 'IMG_1.jpg'))
      ..createSync(recursive: true)
      ..writeAsBytesSync([1, 2, 3]);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(LegacyActivityAdapter());
    }
    final box = await Hive.openBox<LegacyActivity>('activities');
    final a1 = box.get('a1')!;
    await box.put(
      'a1',
      LegacyActivity(
        id: a1.id,
        title: a1.title,
        date: a1.date,
        zoneId: a1.zoneId,
        notes: a1.notes,
        imagePath: cached.path,
      ),
    );
    await box.close();

    final root = p.join(dir.path, 'docs');
    final result = await runImport(photos: PhotoStorage(root));
    expect(result.photos, 1);

    final photo = (await db.select(db.photos).get()).single;
    expect(photo.activityId, 'a1');
    expect(p.isRelative(photo.localPath), isTrue);
    expect(File(p.join(root, photo.localPath)).readAsBytesSync(), [1, 2, 3]);
  });

  test(
    'openAppStorage imports, creates the garden and loads settings',
    () async {
      final storage = await openAppStorage(
        db: db,
        newId: sequentialIds(),
        clock: () => testNow,
        initHive: () async => Hive.init(hiveDir),
      );
      expect(storage.gardenId, isNotEmpty);
      expect(storage.settings.load().quietStart, 21 * 60);
      expect(await db.select(db.activities).get(), hasLength(2));
    },
  );
}
