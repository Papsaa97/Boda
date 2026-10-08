import 'package:flutter_test/flutter_test.dart';
import 'package:zahradnik_boda_mvp01/features/zones/domain/zone_entity.dart';
import 'package:zahradnik_boda_mvp01/features/zones/domain/zone_rules.dart';
import 'package:zahradnik_boda_mvp01/features/zones/presentation/zones_controller.dart';

import '../../helpers/fakes.dart';

void main() {
  const zones = [
    ZoneEntity(id: 'Z1', name: 'Zelenina'),
    ZoneEntity(id: 'Z2', name: 'Skleník'),
  ];

  test('zone name must not be empty or a duplicate', () {
    expect(validateZoneName('  ', zones), 'Zadej název zóny');
    expect(
      validateZoneName(' zelenina ', zones),
      'Zóna s tímto názvem už existuje',
    );
    expect(validateZoneName('Bylinky', zones), isNull);
    // Přejmenování na stejný název u téže zóny je v pořádku.
    expect(validateZoneName('Zelenina', zones, exceptId: 'Z1'), isNull);
  });

  test('zone with activities or the last zone cannot be deleted', () {
    expect(
      zoneDeleteBlocker(zoneId: 'Z1', zoneCount: 2, activityCount: 3),
      ZoneDeleteBlocker.hasActivities,
    );
    expect(
      zoneDeleteBlocker(zoneId: 'Z1', zoneCount: 1, activityCount: 0),
      ZoneDeleteBlocker.lastZone,
    );
    expect(
      zoneDeleteBlocker(zoneId: 'Z1', zoneCount: 2, activityCount: 0),
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

    expect(await controller.addZone('SKLENÍK'), isNotNull);
    expect(zoneRepo.items, hasLength(2));

    expect(await controller.deleteZone('Z1'), ZoneDeleteBlocker.hasActivities);
    expect(zoneRepo.items.containsKey('Z1'), isTrue);

    expect(await controller.deleteZone('Z2'), isNull);
    expect(zoneRepo.items.containsKey('Z2'), isFalse);
  });
}
