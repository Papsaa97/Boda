import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:zahradnik_boda_mvp01/features/zones/data/zone_repository_impl.dart';
import 'package:zahradnik_boda_mvp01/features/zones/domain/zone_entity.dart';

void main() {
  late Directory dir;
  late Box<String> box;
  late ZoneRepositoryImpl repo;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('zones_test');
    Hive.init(dir.path);
    box = await Hive.openBox<String>('zones');
    repo = ZoneRepositoryImpl(box);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await dir.delete(recursive: true);
  });

  test('seeds default zones only into an empty box', () async {
    await repo.seedDefaultsIfEmpty();
    expect(await repo.getAllZones(), unorderedEquals(defaultZones));

    await repo.deleteZone('Z5');
    await repo.seedDefaultsIfEmpty();
    expect((await repo.getAllZones()).map((z) => z.id), isNot(contains('Z5')));
  });

  test('save renames an existing zone', () async {
    await repo.seedDefaultsIfEmpty();
    await repo.saveZone(const ZoneEntity(id: 'Z1', name: 'Zeleninový záhon'));
    final zones = await repo.getAllZones();
    expect(zones.firstWhere((z) => z.id == 'Z1').name, 'Zeleninový záhon');
  });
}
