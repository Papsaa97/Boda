import 'package:equatable/equatable.dart';

import '../../../core/text/numbers.dart';
import '../../../core/time/calendar.dart';
import '../../activity/domain/activity_entity.dart';
import '../../inventory/domain/inventory_item.dart';
import '../../tasks/domain/task_entity.dart';
import '../../zones/domain/zone_entity.dart';
import 'dose_calculator.dart';

/// Limity kontextu (stejné hlídá backend, spec kap. 9 minimalizace).
const maxContextZones = 50;
const maxContextActivities = 30;
const maxContextTasks = 30;
const maxContextInventory = 100;

/// Co se k dotazu pošle Bódi (FR-B1). Jen vyjmenovaná pole, žádná jména
/// osob ani fotky; tvar odpovídá kontraktu funkce `boda-chat`.
class AssistantContext {
  const AssistantContext({
    required this.zones,
    required this.focusZones,
    required this.recentActivities,
    required this.openTasks,
    required this.inventory,
    required this.calculations,
  });

  final List<ZoneEntity> zones;

  /// Zóny, které dotaz jmenuje (podle nich se vybraly záznamy).
  final List<ZoneEntity> focusZones;
  final List<ActivityEntity> recentActivities;
  final List<TaskEntity> openTasks;
  final List<InventoryItem> inventory;
  final List<Calculation> calculations;

  Map<String, Object?> toJson() => {
    // Lokalitu zahrada zatím nemá (přijde s plátnem v 1.1), Bóďa se
    // na ni případně zeptá.
    'garden': null,
    'zones': [for (final z in zones) _zone(z)],
    'recentActivities': [for (final a in recentActivities) _activity(a)],
    'openTasks': [for (final t in openTasks) _task(t)],
    'inventory': [for (final i in inventory) _item(i)],
    'calculations': [for (final c in calculations) c.toJson()],
  };

  /// Shrnutí pro „Z čeho vycházím“ (uloží se ke zprávě).
  ContextSummary get summary => ContextSummary(
    zoneNames: [
      for (final z in focusZones.isEmpty ? zones : focusZones) z.name,
    ],
    activityCount: recentActivities.length,
    taskCount: openTasks.length,
    inventoryCount: inventory.length,
    calculations: calculations,
  );
}

Map<String, Object?> _compact(Map<String, Object?> map) => {
  for (final e in map.entries)
    if (e.value != null) e.key: e.value,
};

Map<String, Object?> _zone(ZoneEntity z) => _compact({
  'id': z.id,
  'name': z.name,
  'type': z.type.name,
  'areaM2': z.areaM2,
  'soilTexture': z.soilTexture?.name,
  'ph': z.ph,
  'phMeasuredAt': z.phMeasuredAt == null
      ? null
      : formatDateKey(z.phMeasuredAt!),
  'sunExposure': z.sunExposure?.name,
  'irrigation': z.irrigation?.name,
  'covered': z.covered,
});

Map<String, Object?> _activity(ActivityEntity a) => _compact({
  'zoneId': a.zoneId,
  'type': a.type.key,
  'title': a.title,
  'occurredAt': formatDateKey(a.date),
  'notes': a.notes,
  'harvestQty': a.harvestQty,
  'harvestUnit': a.harvestUnit,
});

Map<String, Object?> _task(TaskEntity t) => _compact({
  'title': t.title,
  'zoneId': t.zoneId,
  'due': formatDateKey(t.effectiveDate),
});

Map<String, Object?> _item(InventoryItem i) => _compact({
  'id': i.id,
  'name': i.name,
  'category': i.category.name,
  'unit': i.unit.name,
  'stockQty': i.stockQty,
  'lowStockThreshold': i.lowStockThreshold,
  'details': inventoryDetailsForAssistant(i),
});

/// Údaje z obalu a etikety, které smí do modelu (whitelist backendu).
Map<String, Object>? inventoryDetailsForAssistant(InventoryItem i) {
  final dose = i.labelDose;
  final doseText = dose == null
      ? null
      : '${formatDecimal(dose.amount)} ${dose.unit.symbol}/m²';
  final Map<String, Object?> raw = switch (i.details) {
    SeedDetails d => {
      'species': d.species,
      'variety': d.variety,
      'bestBefore': d.bestBefore == null ? null : formatDateKey(d.bestBefore!),
    },
    FertilizerDetails d => {
      'n': d.n,
      'p': d.p,
      'k': d.k,
      'form': d.form?.name,
      'labelDose': doseText,
    },
    PlantProtectionDetails d => {
      'activeSubstance': d.activeSubstance,
      'authorizationNo': d.authorizationNo,
      'phiDays': d.phiDays,
      'nonProfessional': d.nonProfessional,
      'labelDose': doseText,
    },
    ToolDetails d => {'condition': d.condition?.name},
    null => const {},
  };
  final details = <String, Object>{
    for (final e in raw.entries)
      if (e.value != null) e.key: e.value!,
  };
  return details.isEmpty ? null : details;
}

/// Sestaví kontext k dotazu [question] z dat v telefonu.
///
/// Záznamy z deníku se berou z jmenovaných zón (když dotaz žádnou
/// nejmenuje, ze všech), nejnovější první.
AssistantContext buildAssistantContext({
  required String question,
  required List<ZoneEntity> zones,
  required List<ActivityEntity> activities,
  required List<TaskEntity> tasks,
  required List<InventoryItem> inventory,
}) {
  final active = [
    for (final z in zones)
      if (!z.archived) z,
  ].take(maxContextZones).toList();
  final focus = [
    for (final z in active)
      if (mentions(question, z.name)) z,
  ];
  final focusIds = {for (final z in focus) z.id};
  final recent = [
    for (final a in activities)
      if (focusIds.isEmpty || focusIds.contains(a.zoneId)) a,
  ]..sort((a, b) => b.date.compareTo(a.date));
  final open = [
    for (final t in tasks)
      if (t.isOpen) t,
  ]..sort((a, b) => a.effectiveDate.compareTo(b.effectiveDate));
  final items = inventory.take(maxContextInventory).toList();
  return AssistantContext(
    zones: active,
    focusZones: focus,
    recentActivities: recent.take(maxContextActivities).toList(),
    openTasks: open.take(maxContextTasks).toList(),
    inventory: items,
    calculations: calculationsFor(
      question: question,
      zones: active,
      inventory: items,
    ),
  );
}

/// Z čeho Bóďa vycházel (FR-B1); ukládá se ke zprávě jako JSON.
class ContextSummary extends Equatable {
  const ContextSummary({
    this.zoneNames = const [],
    this.activityCount = 0,
    this.taskCount = 0,
    this.inventoryCount = 0,
    this.calculations = const [],
  });

  final List<String> zoneNames;
  final int activityCount;
  final int taskCount;
  final int inventoryCount;
  final List<Calculation> calculations;

  Map<String, Object?> toJson() => {
    'zones': zoneNames,
    'activities': activityCount,
    'tasks': taskCount,
    'inventory': inventoryCount,
    'calculations': [for (final c in calculations) c.toJson()],
  };

  factory ContextSummary.fromJson(Object? json) {
    if (json is! Map) return const ContextSummary();
    int count(Object? v) => v is num ? v.toInt() : 0;
    return ContextSummary(
      zoneNames: [
        for (final z in (json['zones'] as List?) ?? const [])
          if (z is String) z,
      ],
      activityCount: count(json['activities']),
      taskCount: count(json['tasks']),
      inventoryCount: count(json['inventory']),
      calculations: [
        for (final c in (json['calculations'] as List?) ?? const [])
          ?Calculation.fromJson(c),
      ],
    );
  }

  @override
  List<Object?> get props => [
    zoneNames,
    activityCount,
    taskCount,
    inventoryCount,
    calculations,
  ];
}
