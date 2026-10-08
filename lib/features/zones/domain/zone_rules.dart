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
  /// K zóně patří záznamy deníku, úkoly, problémy nebo stavby; smazáním
  /// by osiřely. Jde ji archivovat.
  inUse,

  /// Musí zůstat aspoň jedna aktivní zóna, jinak by nešlo nic zapsat.
  lastZone,
}

ZoneDeleteBlocker? zoneDeleteBlocker({
  required String zoneId,
  required int activeZoneCount,
  required bool isArchived,
  required int linkedCount,
}) {
  if (linkedCount > 0) return ZoneDeleteBlocker.inUse;
  if (!isArchived && activeZoneCount <= 1) return ZoneDeleteBlocker.lastZone;
  return null;
}

/// Archivovat jde jen zónu, po které zůstane aspoň jedna aktivní.
bool canArchiveZone({required int activeZoneCount}) => activeZoneCount > 1;

/// Proč vlastnost zóny neprošla kontrolou.
enum ZonePropertyError { notANumber, outOfRange }

/// Největší výměra zóny (10 ha), větší číslo je skoro jistě překlep.
const maxZoneAreaM2 = 100000.0;

/// Ověří výměru zadanou textem; prázdná = nevyplněno (v pořádku).
ZonePropertyError? validateZoneArea(String text, double? parsed) {
  if (text.trim().isEmpty) return null;
  if (parsed == null) return ZonePropertyError.notANumber;
  if (parsed <= 0 || parsed > maxZoneAreaM2) {
    return ZonePropertyError.outOfRange;
  }
  return null;
}

/// Ověří pH půdy (rozumný rozsah 3–10); prázdné = nevyplněno.
ZonePropertyError? validateZonePh(String text, double? parsed) {
  if (text.trim().isEmpty) return null;
  if (parsed == null) return ZonePropertyError.notANumber;
  if (parsed < 3 || parsed > 10) return ZonePropertyError.outOfRange;
  return null;
}
