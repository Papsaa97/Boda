import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:zahradnik_boda/core/database/app_database.dart';
import 'package:zahradnik_boda/core/photos/photo_storage.dart';
import 'package:zahradnik_boda/features/activity/data/drift_activity_repository.dart';
import 'package:zahradnik_boda/features/activity/domain/activity_entity.dart';
import 'package:zahradnik_boda/features/activity/domain/activity_type.dart';
import 'package:zahradnik_boda/features/backup/data/backup_service.dart';
import 'package:zahradnik_boda/features/backup/domain/backup_format.dart';
import 'package:zahradnik_boda/features/tasks/data/drift_task_repository.dart';
import 'package:zahradnik_boda/features/tasks/domain/task_entity.dart';
import 'package:zahradnik_boda/features/zones/data/drift_zone_repository.dart';
import 'package:zahradnik_boda/features/zones/domain/zone_entity.dart';

import '../../helpers/database.dart';
import '../../helpers/fakes.dart';

/// Jedno „zařízení“: databáze a složka s fotkami.
class _Device {
  _Device._(this.db, this.gardenId, this.photos);

  static Future<_Device> create(String root) async {
    final db = memoryDatabase();
    final gardenId = await db.ensureDefaultGarden(
      newId: sequentialIds(),
      now: testNow,
    );
    return _Device._(db, gardenId, PhotoStorage(root));
  }

  final AppDatabase db;
  final String gardenId;
  final PhotoStorage photos;

  BackupService get backup => BackupService(
    db: db,
    gardenId: gardenId,
    photos: photos,
    clock: () => testNow,
  );

  DriftZoneRepository get zones => DriftZoneRepository(db, gardenId, clock);
  DriftActivityRepository get activities =>
      DriftActivityRepository(db, gardenId, clock);
  DriftTaskRepository get tasks => DriftTaskRepository(db, gardenId, clock);

  static DateTime clock() => testNow;
}

void main() {
  late Directory dir;

  setUp(() async => dir = await Directory.systemTemp.createTemp('boda_backup'));
  tearDown(() => dir.delete(recursive: true));

  Future<void> fill(_Device d) async {
    await d.zones.saveZone(testZones[0]);
    await d.zones.saveZone(testZones[2].copyWith(archived: true));
    final photo = File(p.join(d.photos.rootPath, 'activity_photos', 'p1.jpg'))
      ..createSync(recursive: true)
      ..writeAsBytesSync([1, 2, 3, 4]);
    await d.activities.addActivity(
      ActivityEntity(
        id: 'a1',
        type: ActivityType.harvest,
        title: 'Sklizeň jablek',
        date: DateTime(2026, 9, 20, 16, 45),
        zoneId: 'Z3',
        notes: 'Jonagold, 2 bedny',
        photos: [
          PhotoRef(
            id: 'p1',
            path: p.relative(photo.path, from: d.photos.rootPath),
          ),
        ],
      ),
    );
    await d.activities.addActivity(
      ActivityEntity(
        id: 'a2',
        type: ActivityType.watering,
        title: 'Zálivka',
        date: DateTime(2026, 10, 6, 7),
        zoneId: 'Z1',
      ),
    );
    await d.tasks.saveTask(
      TaskEntity(
        id: 't1',
        title: 'Zazimovat hadice',
        zoneId: 'Z1',
        due: DateTime(2026, 10, 25),
        remindAt: 10 * 60,
        rrule: 'FREQ=YEARLY',
      ),
    );
  }

  test(
    'export, uninstall, install and import restores everything incl. photos',
    () async {
      final phone = await _Device.create(p.join(dir.path, 'phone1'));
      await fill(phone);
      final zip = await phone.backup.export(
        directory: dir.path,
        appVersion: '0.2.0',
      );
      expect(p.basename(zip), 'boda-export-2026-10-07.zip');
      await phone.db.close();

      // Nový telefon: prázdná databáze, jiná složka, nějaká data navíc.
      final fresh = await _Device.create(p.join(dir.path, 'phone2'));
      await fresh.zones.saveZone(
        const ZoneEntity(id: 'X', name: 'Smazat mě', type: ZoneType.other),
      );
      final stray = File(
        p.join(fresh.photos.rootPath, 'activity_photos', 'stray.jpg'),
      )..createSync(recursive: true);

      final data = await fresh.backup.read(zip);
      expect(data.activities, hasLength(2));
      await fresh.backup.restore(zip, data);

      final zones = await fresh.zones.getAllZones();
      expect(zones.map((z) => z.id), unorderedEquals(['Z1', 'Z3']));
      expect(zones.firstWhere((z) => z.id == 'Z3').archived, isTrue);
      expect(zones.firstWhere((z) => z.id == 'Z1').type, ZoneType.vegetable);

      final activities = await fresh.activities.getAllActivities();
      final a1 = activities.firstWhere((a) => a.id == 'a1');
      expect(a1.title, 'Sklizeň jablek');
      expect(a1.type, ActivityType.harvest);
      expect(a1.date, DateTime(2026, 9, 20, 16, 45));
      expect(a1.notes, 'Jonagold, 2 bedny');
      final photoPath = fresh.photos.resolve(a1.photos.single.path)!;
      expect(File(photoPath).readAsBytesSync(), [1, 2, 3, 4]);
      expect(stray.existsSync(), isFalse);

      final task = (await fresh.tasks.getAllTasks()).single;
      expect(task.title, 'Zazimovat hadice');
      expect(task.due, DateTime(2026, 10, 25));
      expect(task.remindAt, 10 * 60);
      expect(task.rrule, 'FREQ=YEARLY');
      await fresh.db.close();
    },
  );

  test('data.json follows docs/FORMAT_EXPORTU.md', () async {
    final phone = await _Device.create(p.join(dir.path, 'phone'));
    await fill(phone);
    final zip = await phone.backup.export(
      directory: dir.path,
      appVersion: '0.2.0',
    );
    final archive = ZipDecoder().decodeBytes(File(zip).readAsBytesSync());
    final json =
        jsonDecode(utf8.decode(archive.find('data.json')!.content))
            as Map<String, Object?>;
    expect(json['formatVersion'], 1);
    expect(json['appVersion'], '0.2.0');
    final a1 = (json['activities'] as List).cast<Map>().firstWhere(
      (a) => a['id'] == 'a1',
    );
    expect(a1['type'], 'harvest');
    expect(a1['occurredAt'], endsWith('Z'));
    expect(a1['occurredTz'], matches(RegExp(r'^[+-]\d\d:\d\d$')));
    expect(a1['photoIds'], ['p1']);
    expect(json['photos'], [
      {'id': 'p1', 'file': 'photos/p1.jpg'},
    ]);
    expect(archive.find('photos/p1.jpg')!.content, [1, 2, 3, 4]);
    final t1 = (json['tasks'] as List).single as Map;
    expect(t1['due'], '2026-10-25');
    expect(t1['remindAt'], '10:00');
    await phone.db.close();
  });

  group('broken files are rejected without touching data', () {
    late _Device phone;

    setUp(() async => phone = await _Device.create(p.join(dir.path, 'p')));
    tearDown(() => phone.db.close());

    Future<String> zipWith(Map<String, String> files) async {
      final path = p.join(dir.path, 'test.zip');
      final archive = Archive();
      files.forEach(
        (name, text) => archive.add(ArchiveFile.string(name, text)),
      );
      File(path).writeAsBytesSync(ZipEncoder().encode(archive));
      return path;
    }

    Future<BackupError?> errorOf(String path) async {
      try {
        await phone.backup.read(path);
        return null;
      } on BackupException catch (e) {
        return e.error;
      }
    }

    test('not a zip', () async {
      final path = p.join(dir.path, 'x.zip');
      File(path).writeAsStringSync('ahoj');
      expect(await errorOf(path), BackupError.notABackup);
    });

    test('zip without data.json', () async {
      expect(
        await errorOf(await zipWith({'readme.txt': 'x'})),
        BackupError.notABackup,
      );
    });

    test('garbage json', () async {
      expect(
        await errorOf(await zipWith({'data.json': '{nope'})),
        BackupError.corrupted,
      );
    });

    test('newer format version', () async {
      expect(
        await errorOf(await zipWith({'data.json': '{"formatVersion": 99}'})),
        BackupError.tooNew,
      );
    });

    test('activity pointing to a missing zone', () async {
      final json = jsonEncode({
        'formatVersion': 1,
        'exportedAt': '2026-10-07T08:00:00.000Z',
        'zones': [],
        'activities': [
          {
            'id': 'a',
            'type': 'watering',
            'title': 'x',
            'occurredAt': '2026-10-07T08:00:00.000Z',
            'zoneId': 'nope',
          },
        ],
      });
      expect(
        await errorOf(await zipWith({'data.json': json})),
        BackupError.corrupted,
      );
    });

    test('photo path escaping the photos folder', () async {
      final json = jsonEncode({
        'formatVersion': 1,
        'exportedAt': '2026-10-07T08:00:00.000Z',
        'zones': [
          {'id': 'Z1', 'name': 'Zelenina'},
        ],
        'activities': [
          {
            'id': 'a',
            'title': 'x',
            'occurredAt': '2026-10-07T08:00:00.000Z',
            'zoneId': 'Z1',
            'photoIds': ['p'],
          },
        ],
        'photos': [
          {'id': 'p', 'file': '../../evil.jpg'},
        ],
      });
      expect(
        await errorOf(await zipWith({'data.json': json})),
        BackupError.corrupted,
      );
    });
  });
}
