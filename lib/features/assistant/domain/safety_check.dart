import 'package:equatable/equatable.dart';

import '../../../core/text/normalize.dart';
import '../../../core/text/numbers.dart';
import '../../inventory/domain/inventory_item.dart';
import '../../inventory/domain/units.dart';
import 'dose_calculator.dart';

/// Upozornění u odpovědi Bódi (FR-B2, FR-B4). Kontrola běží v telefonu
/// nad hotovou odpovědí jako druhá pojistka k pravidlům v promptu.
sealed class SafetyWarning extends Equatable {
  const SafetyWarning();

  Map<String, Object?> toJson();

  static SafetyWarning? fromJson(Object? json) {
    if (json is! Map) return null;
    final value = json['value'];
    if (value is! String) return null;
    return switch (json['kind']) {
      'unverifiedDose' => UnverifiedDose(value),
      'professionalOnly' => ProfessionalOnly(value),
      'missingPhi' => MissingPhi(value),
      _ => null,
    };
  }
}

/// Dávka v odpovědi, která není z výpočtu, z etikety ani z dotazu.
class UnverifiedDose extends SafetyWarning {
  const UnverifiedDose(this.text);

  /// Číslo s jednotkou, jak stálo v odpovědi („80 g/m²“).
  final String text;

  @override
  Map<String, Object?> toJson() => {'kind': 'unverifiedDose', 'value': text};

  @override
  List<Object?> get props => [text];
}

/// Odpověď zmiňuje přípravek, který není povolený pro neprofesionální
/// uživatele.
class ProfessionalOnly extends SafetyWarning {
  const ProfessionalOnly(this.product);

  final String product;

  @override
  Map<String, Object?> toJson() => {
    'kind': 'professionalOnly',
    'value': product,
  };

  @override
  List<Object?> get props => [product];
}

/// Odpověď doporučuje přípravek a neuvádí ochrannou lhůtu.
class MissingPhi extends SafetyWarning {
  const MissingPhi(this.product);

  final String product;

  @override
  Map<String, Object?> toJson() => {'kind': 'missingPhi', 'value': product};

  @override
  List<Object?> get props => [product];
}

/// Číslo s jednotkou nalezené v textu, převedené na g nebo ml.
class _Amount {
  const _Amount(this.base, this.quantity, this.perM2, this.text);

  final double base;
  final Quantity quantity;
  final bool perM2;
  final String text;

  bool matches(_Amount other) =>
      quantity == other.quantity &&
      perM2 == other.perM2 &&
      (base - other.base).abs() <= 0.011 * base.abs().clamp(1, double.infinity);
}

final _amountPattern = RegExp(
  r'(\d+(?:[\u00A0\u202F ]\d{3})*(?:[.,]\d+)?)\s*'
  r'(kg|kilogram\p{L}*|g|gram\p{L}*|ml|mililitr\p{L}*|l|litr\p{L}*)'
  r'(?![\p{L}\d])'
  r'(\s*(?:/|na|za)\s*(?:1\s*)?(?:m²|m2|metr\p{L}*\s+čtvereční\p{L}*|'
  r'čtvereční\p{L}*\s+metr\p{L}*))?',
  caseSensitive: false,
  unicode: true,
);

InventoryUnit? _unit(String raw) {
  final u = raw.toLowerCase();
  if (u == 'kg' || u.startsWith('kilogram')) return InventoryUnit.kg;
  if (u == 'g' || u.startsWith('gram')) return InventoryUnit.g;
  if (u == 'ml' || u.startsWith('mililitr')) return InventoryUnit.ml;
  if (u == 'l' || u.startsWith('litr')) return InventoryUnit.l;
  return null;
}

List<_Amount> _amounts(String text) => [
  for (final m in _amountPattern.allMatches(text))
    if (_parse(m) case final a?) a,
];

_Amount? _parse(RegExpMatch m) {
  final value = parseDecimal(m.group(1));
  final unit = _unit(m.group(2)!);
  if (value == null || unit == null) return null;
  final base = unit.convert(
    value,
    unit.quantity == Quantity.mass ? InventoryUnit.g : InventoryUnit.ml,
  )!;
  return _Amount(base, unit.quantity, m.group(3) != null, m.group(0)!.trim());
}

/// Slova, podle kterých věta mluví o hnojení nebo chemické ochraně.
const _doseWords = ['hnoj', 'postrik', 'pripravek', 'pripravku', 'davk'];

/// Zkontroluje odpověď Bódi.
///
/// * Dávka na m², nebo množství ve větě o hnojení či postřiku, musí
///   pocházet z [calculations], z dávky na obalu položky skladu, ze stavu
///   skladu nebo z [question].
/// * Přípravek bez povolení pro neprofesionály se nesmí doporučit.
/// * U přípravku na ochranu rostlin musí zaznít ochranná lhůta.
List<SafetyWarning> checkAnswer({
  required String answer,
  required String question,
  required List<Calculation> calculations,
  required List<InventoryItem> inventory,
}) {
  final allowed = <_Amount>[
    for (final c in calculations) ..._amounts('${c.result} ${c.source}'),
    ..._amounts(question),
    for (final i in inventory) ...[
      if (i.labelDose case final d?)
        ..._amounts('${d.amount} ${d.unit.symbol}/m²'),
      ..._amounts('${i.stockQty} ${i.unit.symbol}'),
    ],
  ];
  final productNames = [
    for (final i in inventory)
      if (i.category == InventoryCategory.fertilizer ||
          i.category == InventoryCategory.plantProtection)
        i.name,
  ];

  final warnings = <SafetyWarning>[];
  for (final sentence in answer.split(RegExp(r'(?<=[.!?])\s+|\n+'))) {
    final plain = normalizeForSearch(sentence);
    final aboutDose =
        _doseWords.any(plain.contains) ||
        productNames.any((n) => mentions(sentence, n));
    for (final a in _amounts(sentence)) {
      if (!a.perM2 && !aboutDose) continue;
      if (allowed.any(a.matches)) continue;
      final w = UnverifiedDose(a.text);
      if (!warnings.contains(w)) warnings.add(w);
    }
  }

  final plainAnswer = normalizeForSearch(answer);
  for (final i in inventory) {
    final details = i.details;
    if (details is! PlantProtectionDetails || !mentions(answer, i.name)) {
      continue;
    }
    if (!details.nonProfessional) {
      warnings.add(ProfessionalOnly(i.name));
    } else if (!plainAnswer.contains('ochrann')) {
      warnings.add(MissingPhi(i.name));
    }
  }
  return warnings;
}
