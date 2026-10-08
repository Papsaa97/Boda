import 'package:equatable/equatable.dart';

import '../../../core/time/calendar.dart';

import 'units.dart';

/// Kategorie položky skladu (FR-S1).
enum InventoryCategory {
  seed,
  fertilizer,
  plantProtection,
  tool,
  other;

  static InventoryCategory fromKey(String? key) =>
      values.firstWhere((c) => c.name == key, orElse: () => other);
}

/// Dávka z obalu nebo etikety na 1 m² (FR-B2). Z ní kalkulátor spočítá
/// množství na zónu; číslo vždy zadává uživatel, Bóďa ho nevymýšlí.
class LabelDose extends Equatable {
  const LabelDose(this.amount, this.unit);

  final double amount;
  final InventoryUnit unit;

  @override
  List<Object?> get props => [amount, unit];
}

/// Údaje podle kategorie (v databázi JSON `details`).
sealed class ItemDetails extends Equatable {
  const ItemDetails();

  Map<String, Object?> toJson();

  static ItemDetails? fromJson(InventoryCategory category, Object? json) {
    final Map<String, Object?> map = json is Map
        ? json.cast<String, Object?>()
        : const {};
    return switch (category) {
      InventoryCategory.seed => SeedDetails.fromJson(map),
      InventoryCategory.fertilizer => FertilizerDetails.fromJson(map),
      InventoryCategory.plantProtection => PlantProtectionDetails.fromJson(map),
      InventoryCategory.tool => ToolDetails.fromJson(map),
      InventoryCategory.other => null,
    };
  }
}

class SeedDetails extends ItemDetails {
  const SeedDetails({this.species, this.variety, this.lot, this.bestBefore});

  final String? species;
  final String? variety;

  /// Šarže.
  final String? lot;

  /// Datum spotřeby / klíčivosti (den).
  final DateTime? bestBefore;

  factory SeedDetails.fromJson(Map<String, Object?> j) => SeedDetails(
    species: _str(j['species']),
    variety: _str(j['variety']),
    lot: _str(j['lot']),
    bestBefore: _date(j['bestBefore']),
  );

  @override
  Map<String, Object?> toJson() => {
    'species': species,
    'variety': variety,
    'lot': lot,
    'bestBefore': _dateKey(bestBefore),
  };

  @override
  List<Object?> get props => [species, variety, lot, bestBefore];
}

/// Forma hnojiva.
enum FertilizerForm {
  granular,
  liquid,
  powder,
  organic;

  static FertilizerForm? fromKey(Object? key) {
    for (final f in values) {
      if (f.name == key) return f;
    }
    return null;
  }
}

class FertilizerDetails extends ItemDetails {
  const FertilizerDetails({this.n, this.p, this.k, this.form, this.dose});

  /// Obsah živin v % (N-P-K).
  final double? n;
  final double? p;
  final double? k;
  final FertilizerForm? form;

  /// Dávka na m² podle obalu.
  final LabelDose? dose;

  factory FertilizerDetails.fromJson(Map<String, Object?> j) =>
      FertilizerDetails(
        n: _num(j['n']),
        p: _num(j['p']),
        k: _num(j['k']),
        form: FertilizerForm.fromKey(j['form']),
        dose: _dose(j),
      );

  @override
  Map<String, Object?> toJson() => {
    'n': n,
    'p': p,
    'k': k,
    'form': form?.name,
    ..._doseJson(dose),
  };

  @override
  List<Object?> get props => [n, p, k, form, dose];
}

/// Přípravek na ochranu rostlin. Údaje se přebírají z etikety (FR-B4).
class PlantProtectionDetails extends ItemDetails {
  const PlantProtectionDetails({
    this.activeSubstance,
    this.authorizationNo,
    this.phiDays,
    this.nonProfessional = false,
    this.dose,
  });

  final String? activeSubstance;

  /// Číslo povolení (registr přípravků ÚKZÚZ).
  final String? authorizationNo;

  /// Ochranná lhůta do sklizně ve dnech (PHI).
  final int? phiDays;

  /// Povoleno pro neprofesionální uživatele. Bóďa jiné nedoporučí.
  final bool nonProfessional;

  /// Dávka na m² podle etikety.
  final LabelDose? dose;

  factory PlantProtectionDetails.fromJson(Map<String, Object?> j) =>
      PlantProtectionDetails(
        activeSubstance: _str(j['activeSubstance']),
        authorizationNo: _str(j['authorizationNo']),
        phiDays: _num(j['phiDays'])?.round(),
        nonProfessional: j['nonProfessional'] == true,
        dose: _dose(j),
      );

  @override
  Map<String, Object?> toJson() => {
    'activeSubstance': activeSubstance,
    'authorizationNo': authorizationNo,
    'phiDays': phiDays,
    'nonProfessional': nonProfessional,
    ..._doseJson(dose),
  };

  @override
  List<Object?> get props => [
    activeSubstance,
    authorizationNo,
    phiDays,
    nonProfessional,
    dose,
  ];
}

/// Stav nářadí.
enum ToolCondition {
  good,
  needsService,
  broken;

  static ToolCondition? fromKey(Object? key) {
    for (final c in values) {
      if (c.name == key) return c;
    }
    return null;
  }
}

class ToolDetails extends ItemDetails {
  const ToolDetails({
    this.condition,
    this.serviceIntervalDays,
    this.lastServiceAt,
  });

  final ToolCondition? condition;
  final int? serviceIntervalDays;
  final DateTime? lastServiceAt;

  /// Den, kdy je nářadí na řadě se servisem; null = bez intervalu.
  DateTime? get nextServiceAt {
    final interval = serviceIntervalDays;
    final last = lastServiceAt;
    if (interval == null || last == null) return null;
    return DateTime(last.year, last.month, last.day + interval);
  }

  factory ToolDetails.fromJson(Map<String, Object?> j) => ToolDetails(
    condition: ToolCondition.fromKey(j['condition']),
    serviceIntervalDays: _num(j['serviceIntervalDays'])?.round(),
    lastServiceAt: _date(j['lastServiceAt']),
  );

  @override
  Map<String, Object?> toJson() => {
    'condition': condition?.name,
    'serviceIntervalDays': serviceIntervalDays,
    'lastServiceAt': _dateKey(lastServiceAt),
  };

  @override
  List<Object?> get props => [condition, serviceIntervalDays, lastServiceAt];
}

/// Položka skladu (FR-S1, FR-S2). Stav se v 1.0 mění jen ručně;
/// automatický odpis při dokončení úkolu je až ve V2 (FR-S4).
class InventoryItem extends Equatable {
  const InventoryItem({
    required this.id,
    required this.category,
    required this.name,
    required this.unit,
    this.stockQty = 0,
    this.lowStockThreshold,
    this.details,
  });

  final String id;
  final InventoryCategory category;
  final String name;
  final InventoryUnit unit;
  final double stockQty;

  /// Pod tímhle množstvím hlídač upozorní (FR-S3); null = nehlídat.
  final double? lowStockThreshold;
  final ItemDetails? details;

  /// Dávka na m² z obalu nebo etikety, pokud ji položka má.
  LabelDose? get labelDose => switch (details) {
    FertilizerDetails(:final dose) => dose,
    PlantProtectionDetails(:final dose) => dose,
    _ => null,
  };

  InventoryItem copyWith({
    InventoryCategory? category,
    String? name,
    InventoryUnit? unit,
    double? stockQty,
    double? Function()? lowStockThreshold,
    ItemDetails? Function()? details,
  }) => InventoryItem(
    id: id,
    category: category ?? this.category,
    name: name ?? this.name,
    unit: unit ?? this.unit,
    stockQty: stockQty ?? this.stockQty,
    lowStockThreshold: lowStockThreshold == null
        ? this.lowStockThreshold
        : lowStockThreshold(),
    details: details == null ? this.details : details(),
  );

  @override
  List<Object?> get props => [
    id,
    category,
    name,
    unit,
    stockQty,
    lowStockThreshold,
    details,
  ];
}

String? _str(Object? v) => v is String && v.trim().isNotEmpty ? v : null;

double? _num(Object? v) => v is num && v.isFinite ? v.toDouble() : null;

DateTime? _date(Object? v) => v is String ? parseDateKey(v) : null;

String? _dateKey(DateTime? d) => d == null ? null : formatDateKey(d);

LabelDose? _dose(Map<String, Object?> j) {
  final amount = _num(j['dosePerM2']);
  final unit = InventoryUnit.fromKey(j['doseUnit'] as String?);
  if (amount == null || amount <= 0 || unit == null) return null;
  return LabelDose(amount, unit);
}

Map<String, Object?> _doseJson(LabelDose? dose) => {
  'dosePerM2': dose?.amount,
  'doseUnit': dose?.unit.name,
};
