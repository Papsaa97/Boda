import 'zone_entity.dart';

/// Proč název zóny neprošel kontrolou.
enum ZoneNameError { empty, duplicate }

/// Ověří název zóny. Vrací důvod, nebo null, když je název v pořádku.
ZoneNameError? validateZoneName(
  String name,
  List<ZoneEntity> zones, {
  String? exceptId,
}) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return ZoneNameError.empty;
  final lower = trimmed.toLowerCase();
  final duplicate = zones.any(
    (z) => z.id != exceptId && z.name.trim().toLowerCase() == lower,
  );
  if (duplicate) return ZoneNameError.duplicate;
  return null;
}

/// Proč zónu nejde smazat.
enum ZoneDeleteBlocker {
  /// V zóně jsou záznamy deníku; smazáním by osiřely. Jde ji archivovat.
  hasActivities,

  /// Musí zůstat aspoň jedna aktivní zóna, jinak by nešlo nic zapsat.
  lastZone,
}

ZoneDeleteBlocker? zoneDeleteBlocker({
  required String zoneId,
  required int activeZoneCount,
  required bool isArchived,
  required int activityCount,
}) {
  if (activityCount > 0) return ZoneDeleteBlocker.hasActivities;
  if (!isArchived && activeZoneCount <= 1) return ZoneDeleteBlocker.lastZone;
  return null;
}

/// Archivovat jde jen zónu, po které zůstane aspoň jedna aktivní.
bool canArchiveZone({required int activeZoneCount}) => activeZoneCount > 1;
