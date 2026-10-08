import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:zahradnik_boda/core/database/app_database.dart';
import 'package:zahradnik_boda/core/photos/photo_storage.dart';
import 'package:zahradnik_boda/core/sync/sync_engine.dart';
import 'package:zahradnik_boda/features/activity/data/drift_activity_repository.dart';
import 'package:zahradnik_boda/features/activity/domain/activity_entity.dart';
import 'package:zahradnik_boda/features/canvas/data/drift_plan_repository.dart';
import 'package:zahradnik_boda/features/canvas/domain/geometry.dart';
import 'package:zahradnik_boda/features/incidents/data/drift_incident_repository.dart';
import 'package:zahradnik_boda/features/incidents/domain/incident.dart';
import 'package:zahradnik_boda/features/inventory/domain/stock_movement.dart';
import 'package:zahradnik_boda/features/inventory/data/drift_inventory_repository.dart';
import 'package:zahradnik_boda/features/inventory/domain/inventory_item.dart';
import 'package:zahradnik_boda/features/inventory/domain/units.dart';
import 'package:zahradnik_boda/features/tasks/data/drift_task_repository.dart';
import 'package:zahradnik_boda/features/tasks/domain/task_entity.dart';
import 'package:zahradnik_boda/features/zones/data/drift_zone_repository.dart';
import 'package:zahradnik_boda/features/zones/domain/zone_entity.dart';

import '../../helpers/database.dart';
import '../../helpers/fake_sync_remote.dart';

/// Jeden telefon: vlastní databáze, složka fotek a hodiny.
class Device {
  Device(this.label);

  final String label;
  late AppDatabase db;
  late String gardenId;
  late PhotoStorage photos;
  DateTime now = DateTime.utc(2026, 10, 7, 10);

  Future<void> open() async {
    db = memoryDatabase();
    gardenId = await db.ensureDefaultGarden(
      newId: () => 'garden-$label',
      now: now,
    );
    final dir = await Directory.systemTemp.createTemp('boda_sync_$label');
    addTearDown(() => dir.delete(recursive: true));
    photos = PhotoStorage(dir.path);
  }

  DateTime clock() => now;

  SyncEngine engine(FakeSyncRemote remote) => SyncEngine(
    db: db,
    remote: remote,
    gardenId: gardenId,
    clock: clock,
    photos: photos,
  );

  DriftZoneRepository get zones => DriftZoneRepository(db, gardenId, clock);
  DriftTaskRepository get tasks => DriftTaskRepository(db, gardenId, clock);
  DriftActivityRepository get activities =>
      DriftActivityRepository(db, gardenId, clock);
  DriftInventoryRepository get inventory =>
      DriftInventoryRepository(db, gardenId, clock);

  DriftPlanRepository get plan => DriftPlanRepository(db, gardenId, clock);
  DriftIncidentRepository get incidents =>
      DriftIncidentRepository(db, gardenId, clock);

  Future<int> outbox() async => (await db.select(db.syncOutbox).get()).length;
}

void main() {
  late FakeSyncRemote server;
  late Device a;
  late Device b;

  setUp(() async {
    server = FakeSyncRemote();
    a = Device('a');
    b = Device('b');
    await a.open();
    await b.open();
  });

  tearDown(() async {
    await a.db.close();
    await b.db.close();
  });

  const zone = ZoneEntity(
    id: 'zone-1',
    name: 'Zelenina',
    type: ZoneType.vegetable,
    areaM2: 20,
    covered: true,
  );

  Future<void> seed(Device d) async {
    await d.zones.saveZone(zone);
    await d.inventory.save(
      const InventoryItem(
        id: 'item-1',
        category: InventoryCategory.fertilizer,
        name: 'Cererit',
        unit: InventoryUnit.kg,
        details: FertilizerDetails(dose: LabelDose(60, InventoryUnit.g)),
      ),
    );
    await d.tasks.saveTask(
      TaskEntity(
        id: 'task-1',
        title: 'Pohnojit',
        zoneId: 'zone-1',
        due: DateTime(2026, 10, 9),
        tools: const ['Konev'],
        materials: const [TaskMaterial(itemId: 'item-1', qty: 1.2, unit: 'kg')],
        source: TaskSource.boda,
      ),
    );
  }

  test('local changes are queued by triggers, one entry per row', () async {
    await seed(a);
    await a.zones.saveZone(zone.copyWith(name: 'Zelenina JV'));
    final rows = await a.db.select(a.db.syncOutbox).get();
    expect(
      rows.map((r) => '${r.entity}:${r.rowKey}'),
      unorderedEquals([
        'gardens:garden-a',
        'zones:zone-1',
        'inventory_items:item-1',
        'tasks:task-1',
        'task_materials:task-1|item-1',
      ]),
    );
  });

  test('an empty account gets the whole garden in server shape', () async {
    await seed(a);
    final report = await a.engine(server).sync();
    expect(report.pairing, isA<Paired>());
    expect(await a.outbox(), 0);
    expect(server.pushes, hasLength(1));

    final z = server.table('zones')['zone-1']!;
    expect(z['covered'], isTrue);
    expect(z['archived'], isFalse);
    expect(z['area_m2'], 20.0);
    final t = server.table('tasks')['task-1']!;
    expect(t['tools'], ['Konev']);
    expect(t['source'], 'boda');
    expect(t['due'], '2026-10-09');
    final details =
        server.table('inventory_items')['item-1']!['details']!
            as Map<String, Object?>;
    expect(details['dosePerM2'], 60);
    expect(server.table('task_materials').keys, ['task-1|item-1']);

    // Stažení vlastních změn nic neodešle zpátky.
    await a.engine(server).sync();
    expect(await a.outbox(), 0);
    expect(server.pushes, hasLength(1));
  });

  test('the garden plan travels to the second phone', () async {
    const outline = [Pt(0, 0), Pt(20, 0), Pt(20, 12.5), Pt(0, 12.5)];
    const bed = [Pt(1, 1), Pt(6, 1), Pt(6, 3), Pt(1, 3)];
    await a.zones.saveZone(
      zone.copyWith(polygon: () => bed, layer: ZoneLayer.plan),
    );
    await a.plan.saveOutline(outline);
    await a.engine(server).sync();

    final z = server.table('zones')['zone-1']!;
    expect(z['layer'], 'plan');
    expect(z['polygon'], [
      [1, 1],
      [6, 1],
      [6, 3],
      [1, 3],
    ]);
    final g = server.table('gardens')['garden-a']!;
    expect((g['bounds']! as Map)['outline'], hasLength(4));

    final first = await b.engine(server).sync();
    final remoteId = (first.pairing as PairingConflict).remoteGardenId;
    await b.engine(server).adoptRemoteGarden(remoteId);
    b.gardenId = remoteId;
    await b.engine(server).sync();
    final got = (await b.zones.getAllZones()).single;
    expect(got.polygon, bed);
    expect(got.layer, ZoneLayer.plan);
    expect(await b.plan.loadOutline(), outline);
  });

  test('incidents and stock movements travel to the second phone', () async {
    await seed(a);
    await a.incidents.save(
      Incident(
        id: 'inc-1',
        zoneId: 'zone-1',
        label: 'Mšice',
        candidates: const [IncidentCandidate(label: 'Mšice maková')],
        createdAt: a.now,
      ),
    );
    await a.tasks.saveTask(
      TaskEntity(
        id: 'check-1',
        title: 'Kontrola',
        due: DateTime(2026, 10, 10),
        incidentId: 'inc-1',
      ),
    );
    await a.inventory.applyMovements([
      StockMovement(
        id: 'mv-1',
        itemId: 'item-1',
        qtyDelta: -1.2,
        reason: MovementReason.task,
        taskId: 'task-1',
        at: a.now,
      ),
    ]);
    await a.engine(server).sync();
    final inc = server.table('incidents')['inc-1']!;
    expect(inc['candidates'], [
      {'label': 'Mšice maková'},
    ]);
    expect(server.table('tasks')['check-1']!['incident_id'], 'inc-1');
    expect(server.table('inventory_movements')['mv-1']!['qty_delta'], -1.2);

    final first = await b.engine(server).sync();
    final remoteId = (first.pairing as PairingConflict).remoteGardenId;
    await b.engine(server).adoptRemoteGarden(remoteId);
    b.gardenId = remoteId;
    await b.engine(server).sync();
    final got = (await b.incidents.getAll()).single;
    expect(got.label, 'Mšice');
    expect(got.candidates.single.label, 'Mšice maková');
    expect(
      (await b.inventory.movements(itemId: 'item-1')).single.reason,
      MovementReason.task,
    );
  });

  test('a second phone adopts the account garden and gets the data', () async {
    await seed(a);
    await a.engine(server).sync();
    await b.zones.saveZone(const ZoneEntity(id: 'zone-b', name: 'Jiná'));

    final first = await b.engine(server).sync();
    expect(first.pairing, isA<PairingConflict>());
    final remoteId = (first.pairing as PairingConflict).remoteGardenId;
    expect(remoteId, 'garden-a');

    await b.engine(server).adoptRemoteGarden(remoteId);
    b.gardenId = remoteId;
    final second = await b.engine(server).sync();
    expect(second.pairing, isA<Paired>());
    expect(await b.zones.getAllZones(), [zone]);
    final task = (await b.tasks.getAllTasks()).single;
    expect(task.tools, ['Konev']);
    expect(task.materials.single.qty, 1.2);
    expect(task.source, TaskSource.boda);
    expect(
      (await b.inventory.getAll()).single.labelDose,
      const LabelDose(60, InventoryUnit.g),
    );
    expect(await b.outbox(), 0);
    // Zóna z druhého telefonu na server nedorazila.
    expect(server.table('zones').keys, ['zone-1']);
  });

  test('last write wins in both directions', () async {
    await seed(a);
    await a.engine(server).sync();
    final adopt = b.engine(server);
    await adopt.adoptRemoteGarden('garden-a');
    b.gardenId = 'garden-a';
    await b.engine(server).sync();

    // B přejmenuje později než A; A po synchronizaci převezme jméno z B.
    a.now = DateTime.utc(2026, 10, 7, 11);
    await a.zones.saveZone(zone.copyWith(name: 'Od A'));
    b.now = DateTime.utc(2026, 10, 7, 12);
    await b.zones.saveZone(zone.copyWith(name: 'Od B'));
    await b.engine(server).sync();
    await a.engine(server).sync();
    expect((await a.zones.getAllZones()).single.name, 'Od B');
    expect(server.table('zones')['zone-1']!['name'], 'Od B');

    // Novější změna v telefonu se stažením nepřepíše.
    b.now = DateTime.utc(2026, 10, 7, 13);
    await b.zones.saveZone(zone.copyWith(name: 'B znovu'));
    await b.engine(server).sync();
    a.now = DateTime.utc(2026, 10, 7, 14);
    await a.zones.saveZone(zone.copyWith(name: 'A nejnovější'));
    await a.engine(server).pull();
    expect((await a.zones.getAllZones()).single.name, 'A nejnovější');
    await a.engine(server).sync();
    await b.engine(server).sync();
    expect((await b.zones.getAllZones()).single.name, 'A nejnovější');
  });

  test('soft and hard deletes reach the other phone', () async {
    await seed(a);
    await a.engine(server).sync();
    await b.engine(server).adoptRemoteGarden('garden-a');
    b.gardenId = 'garden-a';
    await b.engine(server).sync();

    a.now = DateTime.utc(2026, 10, 7, 11);
    await a.tasks.deleteTask('task-1');
    // Obnova ze zálohy maže natvrdo.
    await a.db.delete(a.db.taskMaterials).go();
    await a.engine(server).sync();
    expect(
      server.table('task_materials')['task-1|item-1']!['deleted_at'],
      isNotNull,
    );

    await b.engine(server).sync();
    expect(await b.tasks.getAllTasks(), isEmpty);
  });

  test('photos are uploaded once and downloaded on the other phone', () async {
    await seed(a);
    final source = File('${a.photos.rootPath}/source.jpg')
      ..writeAsBytesSync([1, 2, 3]);
    final stored = await a.photos.prepareFile('photo-1.jpg');
    source.copySync(stored);
    await a.activities.addActivity(
      ActivityEntity(
        id: 'act-1',
        title: 'Výsev',
        date: DateTime(2026, 10, 7, 9),
        zoneId: 'zone-1',
        photos: [
          PhotoRef(
            id: 'photo-1',
            path: a.photos.relativePathFor('photo-1.jpg'),
          ),
        ],
      ),
    );
    await a.engine(server).sync();
    expect(server.files['garden-a/photo-1.jpg'], [1, 2, 3]);
    expect(server.files.keys, contains('garden-a/photo-1_thumb.jpg'));
    expect(
      server.table('photos')['photo-1']!['storage_path'],
      'garden-a/photo-1.jpg',
    );
    expect(
      server.table('photos')['photo-1']!.containsKey('local_path'),
      isFalse,
    );

    await b.engine(server).adoptRemoteGarden('garden-a');
    b.gardenId = 'garden-a';
    await b.engine(server).sync();
    final photo = (await b.activities.getAllActivities()).single.photos.single;
    expect(File(b.photos.resolve(photo.path)!).readAsBytesSync(), [1, 2, 3]);
    expect(await b.outbox(), 0);
  });

  test('offline sync keeps the queue for later', () async {
    await seed(a);
    server.offline = true;
    await expectLater(a.engine(server).sync(), throwsA(anything));
    expect(await a.outbox(), 5);
    server.offline = false;
    await a.engine(server).sync();
    expect(await a.outbox(), 0);
  });
}
