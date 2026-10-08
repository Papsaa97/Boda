import 'package:equatable/equatable.dart';

import '../../../core/text/normalize.dart';
import '../../../core/text/numbers.dart';
import '../../inventory/domain/inventory_item.dart';
import '../../inventory/domain/units.dart';
import '../../zones/domain/zone_entity.dart';

/// Výpočet, který Bóďa smí v odpovědi použít (FR-B2). Čísla počítá kód,
/// jazykový model je jen přebírá i se zdrojem dávky.
class Calculation extends Equatable {
  const Calculation({
    required this.label,
    required this.result,
    required this.source,
  });

  /// Co se počítalo, např. „Cererit na zónu Zelenina (20 m²)“.
  final String label;

  /// Výsledek s jednotkou, např. „1,2 kg“.
  final String result;

  /// Odkud je dávka na m², např. „60 g/m² podle obalu“.
  final String source;

  Map<String, Object?> toJson() => {
    'label': label,
    'result': result,
    'source': source,
  };

  static Calculation? fromJson(Object? json) {
    if (json is! Map) return null;
    final label = json['label'];
    final result = json['result'];
    final source = json['source'];
    if (label is! String || result is! String || source is! String) {
      return null;
    }
    return Calculation(label: label, result: result, source: source);
  }

  @override
  List<Object?> get props => [label, result, source];
}

/// Nejvýš tolik výpočtů jde s dotazem (stejný limit hlídá backend).
const maxCalculations = 20;

/// Dávka [item] na zónu [zone]: dávka z obalu nebo etikety × výměra.
///
/// Null, když zóna nemá výměru, položka nemá dávku, nebo jde o přípravek,
/// který není povolený pro neprofesionální uživatele (FR-B4).
Calculation? zoneDose(InventoryItem item, ZoneEntity zone) {
  final dose = item.labelDose;
  final area = zone.areaM2;
  if (dose == null || area == null || area <= 0) return null;
  final details = item.details;
  if (details is PlantProtectionDetails && !details.nonProfessional) {
    return null;
  }

  final total = dose.amount * area;
  final source = switch (details) {
    PlantProtectionDetails(:final authorizationNo?) =>
      '${_perM2(dose)} podle etikety (povolení $authorizationNo)',
    PlantProtectionDetails() => '${_perM2(dose)} podle etikety',
    _ => '${_perM2(dose)} podle obalu',
  };
  return Calculation(
    label: '${item.name} na zónu ${zone.name} (${formatDecimal(area)} m²)',
    result: formatAmount(total, dose.unit),
    source: source,
  );
}

String _perM2(LabelDose dose) =>
    '${formatDecimal(dose.amount)} ${dose.unit.symbol}/m²';

/// Množství v čitelné jednotce: od 1000 g kilogramy, od 1000 ml litry.
String formatAmount(double value, InventoryUnit unit) {
  var v = value;
  var u = unit;
  if (u == InventoryUnit.g && v >= 1000) {
    v = v / 1000;
    u = InventoryUnit.kg;
  } else if (u == InventoryUnit.ml && v >= 1000) {
    v = v / 1000;
    u = InventoryUnit.l;
  }
  final digits = switch (u) {
    InventoryUnit.g || InventoryUnit.ml => v >= 10 ? 0 : 1,
    _ => 2,
  };
  return '${formatDecimal(v, maxFractionDigits: digits)} ${u.symbol}';
}

/// Výpočty k dotazu: dávky položek s dávkou na m² pro zóny s výměrou.
///
/// Když dotaz jmenuje zóny nebo položky, počítá se jen pro ně; jinak pro
/// všechny. Nejvýš [maxCalculations].
List<Calculation> calculationsFor({
  required String question,
  required List<ZoneEntity> zones,
  required List<InventoryItem> inventory,
}) {
  final measured = [
    for (final z in zones)
      if (z.isActive && (z.areaM2 ?? 0) > 0) z,
  ];
  final dosed = [
    for (final i in inventory)
      if (i.labelDose != null) i,
  ];
  final mentionedZones = [
    for (final z in measured)
      if (mentions(question, z.name)) z,
  ];
  final mentionedItems = [
    for (final i in dosed)
      if (mentions(question, i.name)) i,
  ];
  final out = <Calculation>[];
  for (final zone in mentionedZones.isEmpty ? measured : mentionedZones) {
    for (final item in mentionedItems.isEmpty ? dosed : mentionedItems) {
      final c = zoneDose(item, zone);
      if (c != null) out.add(c);
      if (out.length >= maxCalculations) return out;
    }
  }
  return out;
}

/// Zmiňuje [text] název [name]? Porovnává bez diakritiky a podle kmene
/// slov, takže „zeleninu“ najde zónu „Zelenina“. Slova kratší než
/// 4 znaky se ignorují; musí sedět všechna ostatní.
bool mentions(String text, String name) {
  final haystack = normalizeForSearch(text);
  final words = normalizeForSearch(
    name,
  ).split(RegExp(r'[^a-z0-9]+')).where((w) => w.length >= 4).toList();
  if (words.isEmpty) {
    final whole = normalizeForSearch(name).trim();
    return whole.isNotEmpty && haystack.contains(whole);
  }
  return words.every((w) {
    final stem = w.length > 6 ? w.substring(0, w.length - 2) : w;
    return haystack.contains(stem.length >= 4 ? stem : w);
  });
}
