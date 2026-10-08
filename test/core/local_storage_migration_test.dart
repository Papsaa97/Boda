import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:path/path.dart' as p;
import 'package:zahradnik_boda_mvp01/core/photos/photo_storage.dart';
import 'package:zahradnik_boda_mvp01/core/storage/local_storage.dart';

/// Data z verze 0.1 se po aktualizaci načtou (spec 12.1, „Migrace“).
///
/// `test/fixtures/hive_0_1/activities.hive` zapsal původní balíček
/// `hive` 2.2.3 s adaptérem z commitu 6cf42f1. Teď ho čte `hive_ce`.
void main() {
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('boda_migration');
    final hiveDir = Directory(p.join(dir.path, 'hive'))..createSync();
    File(
      'test/fixtures/hive_0_1/activities.hive',
    ).copySync(p.join(hiveDir.path, 'activities.hive'));
    Hive.init(hiveDir.path);
  });

  tearDown(() async {
    await Hive.close();
    await dir.delete(recursive: true);
  });

  test('hive_ce reads activities written by hive 2.2.3 (v0.1)', () async {
    final boxes = await openLocalBoxes();

    expect(boxes.activities.length, 2);
    final a1 = boxes.activities.get('a1')!;
    expect(a1.title, 'Zálivka rajčat');
    expect(a1.date, DateTime(2026, 5, 1, 8, 30));
    expect(a1.zoneId, 'Z1');
    expect(a1.notes, 'Ráno před sluncem');
    final a2 = boxes.activities.get('a2')!;
    expect(a2.title, 'Řez maliní');
    expect(a2.notes, isNull);
    expect(a2.imagePath, isNull);
  });

  test('users with old data get default zones and skip onboarding', () async {
    final boxes = await openLocalBoxes();
    expect(boxes.zones.keys, containsAll(['Z1', 'Z2', 'Z3']));
    expect(boxes.zones.get('Z3'), 'Ovocný sad');
  });

  test('photo from the old cache path is copied into the app folder', () async {
    // Verze 0.1 ukládala cestu do cache file_pickeru. Když soubor ještě
    // existuje, zkopíruje se do složky aplikace a cesta se převede na relativní.
    final root = p.join(dir.path, 'docs');
    final cached = File(p.join(dir.path, 'cache', 'IMG_1.jpg'))
      ..createSync(recursive: true)
      ..writeAsBytesSync([1, 2, 3]);

    Hive.init(p.join(dir.path, 'hive'));
    final boxes = await openLocalBoxes();
    final a1 = boxes.activities.get('a1')!;
    a1.imagePath = cached.path;
    await boxes.activities.put('a1', a1);

    await adoptLegacyPhotos(boxes.activities, PhotoStorage(root));

    final stored = boxes.activities.get('a1')!.imagePath!;
    expect(p.isRelative(stored), isTrue);
    expect(stored, startsWith('activity_photos'));
    expect(File(p.join(root, stored)).readAsBytesSync(), [1, 2, 3]);
  });

  test('photo whose file is gone keeps its path untouched', () async {
    final boxes = await openLocalBoxes();
    final before = boxes.activities.get('a1')!.imagePath;

    await adoptLegacyPhotos(
      boxes.activities,
      PhotoStorage(p.join(dir.path, 'docs')),
    );

    expect(boxes.activities.get('a1')!.imagePath, before);
  });
}
