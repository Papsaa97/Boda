import 'package:flutter_test/flutter_test.dart';
import 'package:zahradnik_boda/features/zones/domain/zone_entity.dart';
import 'package:zahradnik_boda/features/zones/domain/zone_rules.dart';
import 'package:zahradnik_boda/features/zones/presentation/zones_controller.dart';

import '../../helpers/fakes.dart';

void main() {
  const zones = [
    ZoneEntity(id: 'Z1', name: 'Zelenina', type: ZoneType.vegetable),
    ZoneEntity(id: 'Z2', name: 'Skleník', type: ZoneType.greenhouse),
  ];

  test('zone name must not be empty or a duplicate', () {
    expect(validateZoneName('  ', zones), ZoneNameError.empty);
    expect(validateZoneName(' zelenina ', zones), ZoneNameError.duplicate);
    expect(validateZoneName('Bylinky', zones), isNull);
    // Přejmenování na stejný název u téže zóny je v pořádku.
    expect(validateZoneName('Zelenina', zones, exceptId: 'Z1'), isNull);
  });

  test('zone with activities or the last active zone cannot be deleted', () {
    expect(
      zoneDeleteBlocker(
        zoneId: 'Z1',
        activeZoneCount: 2,
        isArchived: false,
        activityCount: 3,
      ),
      ZoneDeleteBlocker.hasActivities,
    );
    expect(
      zoneDeleteBlocker(
        zoneId: 'Z1',
        activeZoneCount: 1,
        isArchived: false,
        activityCount: 0,
      ),
      ZoneDeleteBlocker.lastZone,
    );
    // Archivovaná prázdná zóna jde smazat, i když zbývá jen jedna aktivní.
    expect(
      zoneDeleteBlocker(
        zoneId: 'Z2',
        activeZoneCount: 1,
        isArchived: true,
        activityCount: 0,
      ),
      isNull,
    );
  });

  test('controller refuses a duplicate name and a blocked delete', () async {
    final zoneRepo = InMemoryZoneRepository(zones);
    final container = makeContainer(
      zones: zoneRepo,
      activities: InMemoryActivityRepository([
        activity('a', date: DateTime(2026, 10, 1), zoneId: 'Z1'),
      ]),
    );
    addTearDown(container.dispose);
    final controller = container.read(zonesControllerProvider.notifier);
    await container.read(zonesControllerProvider.future);

    expect(await controller.addZone('SKLENÍK'), ZoneNameError.duplicate);
    expect(zoneRepo.items, hasLength(2));

    expect(await controller.deleteZone('Z1'), ZoneDeleteBlocker.hasActivities);
    expect(zoneRepo.items.containsKey('Z1'), isTrue);

    expect(await controller.deleteZone('Z2'), isNull);
    expect(zoneRepo.items.containsKey('Z2'), isFalse);
  });

  test('zone with activities can be archived, but not the last one', () async {
    final zoneRepo = InMemoryZoneRepository(zones);
    final container = makeContainer(zones: zoneRepo);
    addTearDown(container.dispose);
    final controller = container.read(zonesControllerProvider.notifier);
    await container.read(zonesControllerProvider.future);

    expect(await controller.setArchived('Z1', true), isTrue);
    expect(zoneRepo.items['Z1']!.archived, isTrue);
    expect(container.read(activeZonesProvider).map((z) => z.id), ['Z2']);

    expect(await controller.setArchived('Z2', true), isFalse);
    expect(zoneRepo.items['Z2']!.archived, isFalse);

    expect(await controller.setArchived('Z1', false), isTrue);
    expect(container.read(activeZonesProvider), hasLength(2));
  });
}
