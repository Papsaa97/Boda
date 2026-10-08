import 'zone_entity.dart';

/// Ověří název zóny. Vrací chybovou hlášku, nebo null, když je název v pořádku.
String? validateZoneName(
  String name,
  List<ZoneEntity> zones, {
  String? exceptId,
}) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return 'Zadej název zóny';
  final lower = trimmed.toLowerCase();
  final duplicate = zones.any(
    (z) => z.id != exceptId && z.name.trim().toLowerCase() == lower,
  );
  if (duplicate) return 'Zóna s tímto názvem už existuje';
  return null;
}

/// Proč zónu nejde smazat.
enum ZoneDeleteBlocker {
  /// V zóně jsou záznamy deníku; smazáním by osiřely.
  hasActivities,

  /// Musí zůstat aspoň jedna zóna, jinak by nešlo nic zapsat.
  lastZone,
}

ZoneDeleteBlocker? zoneDeleteBlocker({
  required String zoneId,
  required int zoneCount,
  required int activityCount,
}) {
  if (activityCount > 0) return ZoneDeleteBlocker.hasActivities;
  if (zoneCount <= 1) return ZoneDeleteBlocker.lastZone;
  return null;
}
