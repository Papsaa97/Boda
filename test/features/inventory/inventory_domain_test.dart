import 'package:flutter_test/flutter_test.dart';
import 'package:zahradnik_boda/core/text/numbers.dart';
import 'package:zahradnik_boda/features/inventory/domain/inventory_alerts.dart';
import 'package:zahradnik_boda/features/inventory/domain/inventory_item.dart';
import 'package:zahradnik_boda/features/inventory/domain/units.dart';
import 'package:zahradnik_boda/features/zones/domain/zone_rules.dart';

void main() {
  group('units convert only within the same quantity (FR-S2)', () {
    test('mass and volume', () {
      expect(InventoryUnit.kg.convert(1.5, InventoryUnit.g), 1500);
      expect(InventoryUnit.g.convert(250, InventoryUnit.kg), 0.25);
      expect(InventoryUnit.l.convert(0.5, InventoryUnit.ml), 500);
      expect(InventoryUnit.ks.convert(3, InventoryUnit.ks), 3);
    });

    test('across quantities there is no answer', () {
      expect(InventoryUnit.kg.convert(1, InventoryUnit.l), isNull);
      expect(InventoryUnit.ks.convert(1, InventoryUnit.pack), isNull);
      expect(InventoryUnit.ml.compatible, [InventoryUnit.ml, InventoryUnit.l]);
    });
  });

  group('details survive JSON', () {
    test('every category', () {
      final cases = <InventoryCategory, ItemDetails>{
        InventoryCategory.seed: SeedDetails(
          species: 'rajče',
          variety: 'Start S F1',
          lot: 'A12',
          bestBefore: DateTime(2027, 12, 31),
        ),
        InventoryCategory.fertilizer: const FertilizerDetails(
          n: 12,
          p: 11,
          k: 18,
          form: FertilizerForm.granular,
          dose: LabelDose(60, InventoryUnit.g),
        ),
        InventoryCategory.plantProtection: const PlantProtectionDetails(
          activeSubstance: 'azadirachtin',
          authorizationNo: '4818-0',
          phiDays: 3,
          nonProfessional: true,
          dose: LabelDose(0.3, InventoryUnit.ml),
        ),
        InventoryCategory.tool: ToolDetails(
          condition: ToolCondition.needsService,
          serviceIntervalDays: 365,
          lastServiceAt: DateTime(2026, 3, 1),
        ),
      };
      cases.forEach((category, details) {
        expect(ItemDetails.fromJson(category, details.toJson()), details);
      });
      expect(ItemDetails.fromJson(InventoryCategory.other, {'x': 1}), isNull);
    });

    test('garbage reads as empty details, a zero dose as no dose', () {
      expect(
        ItemDetails.fromJson(InventoryCategory.seed, 'nonsense'),
        const SeedDetails(),
      );
      expect(
        (ItemDetails.fromJson(InventoryCategory.fertilizer, {
                  'dosePerM2': 0,
                  'doseUnit': 'g',
                })
                as FertilizerDetails)
            .dose,
        isNull,
      );
    });
  });

  group('stock watcher (FR-S3)', () {
    final today = DateTime(2026, 10, 7, 9);
    InventoryItem item(
      String name, {
      double stock = 1,
      double? threshold,
      ItemDetails? details,
      InventoryCategory category = InventoryCategory.other,
    }) => InventoryItem(
      id: name,
      category: category,
      name: name,
      unit: InventoryUnit.kg,
      stockQty: stock,
      lowStockThreshold: threshold,
      details: details,
    );

    test('low stock, seeds by date and tool service, in that order', () {
      final alerts = inventoryAlerts([
        item(
          'Pila',
          category: InventoryCategory.tool,
          details: ToolDetails(
            serviceIntervalDays: 30,
            lastServiceAt: DateTime(2026, 9, 7),
          ),
        ),
        item(
          'Mrkev',
          category: InventoryCategory.seed,
          details: SeedDetails(bestBefore: DateTime(2026, 10, 6)),
        ),
        item(
          'Ředkvička',
          category: InventoryCategory.seed,
          details: SeedDetails(bestBefore: DateTime(2026, 11, 30)),
        ),
        item(
          'Hrách',
          category: InventoryCategory.seed,
          details: SeedDetails(bestBefore: DateTime(2027, 6, 1)),
        ),
        item('Cererit', stock: 0.5, threshold: 1),
        item('Kompost', stock: 5, threshold: 1),
        item('Bez prahu', stock: 0),
      ], today);

      expect(
        [for (final a in alerts) (a.item.name, a.kind)],
        [
          ('Cererit', InventoryAlertKind.lowStock),
          ('Mrkev', InventoryAlertKind.seedExpired),
          ('Ředkvička', InventoryAlertKind.seedExpiringSoon),
          ('Pila', InventoryAlertKind.toolServiceDue),
        ],
      );
    });

    test('stock exactly at the threshold already warns', () {
      final alerts = inventoryAlerts([
        item('Cererit', stock: 1, threshold: 1),
      ], today);
      expect(alerts.single.kind, InventoryAlertKind.lowStock);
    });
  });

  group('numbers typed the Czech way', () {
    test('parse', () {
      expect(parseDecimal('12,5'), 12.5);
      expect(parseDecimal(' 1 250 '), 1250);
      expect(parseDecimal('6.6'), 6.6);
      expect(parseDecimal(''), isNull);
      expect(parseDecimal('12,5,1'), isNull);
      expect(parseDecimal('abc'), isNull);
    });

    test('zone area and pH ranges', () {
      expect(validateZoneArea('', null), isNull);
      expect(validateZoneArea('x', null), ZonePropertyError.notANumber);
      expect(validateZoneArea('0', 0), ZonePropertyError.outOfRange);
      expect(validateZoneArea('20', 20), isNull);
      expect(validateZonePh('6,5', 6.5), isNull);
      expect(validateZonePh('14', 14), ZonePropertyError.outOfRange);
    });
  });
}
