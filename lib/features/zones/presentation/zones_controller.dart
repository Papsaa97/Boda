import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../activity/domain/activity_entity.dart';
import '../../activity/presentation/controllers/activity_controller.dart';
import '../domain/zone_entity.dart';
import '../domain/zone_rules.dart';

/// Všechny zóny včetně archivovaných, seřazené podle názvu.
class ZonesController extends AsyncNotifier<List<ZoneEntity>> {
  @override
  Future<List<ZoneEntity>> build() async {
    final zones = await ref.watch(zoneRepositoryProvider).getAllZones();
    return _sorted(zones);
  }

  List<ZoneEntity> get _current => state.value ?? const <ZoneEntity>[];

  int get _activeCount => _current.where((z) => !z.archived).length;

  /// Přidá zónu. Vrací důvod, když název neprojde kontrolou.
  Future<ZoneNameError?> addZone(
    String name, {
    ZoneType type = ZoneType.other,
  }) async {
    final error = validateZoneName(name, _current);
    if (error != null) return error;
    await _save(
      ZoneEntity(id: ref.read(newIdProvider)(), name: name.trim(), type: type),
    );
    return null;
  }

  /// Uloží více zón najednou (onboarding).
  Future<void> addZones(List<ZoneEntity> zones) async {
    final previous = _current;
    await _mutate(() async {
      final repo = ref.read(zoneRepositoryProvider);
      for (final zone in zones) {
        await repo.saveZone(zone);
      }
      final ids = zones.map((z) => z.id).toSet();
      return _sorted([...previous.where((z) => !ids.contains(z.id)), ...zones]);
    });
  }

  /// Uloží zónu včetně vlastností (formulář zóny, 1.0). Vrací důvod,
  /// když název neprojde kontrolou.
  Future<ZoneNameError?> saveZone(ZoneEntity zone) async {
    final error = validateZoneName(zone.name, _current, exceptId: zone.id);
    if (error != null) return error;
    await _save(zone.copyWith(name: zone.name.trim()));
    return null;
  }

  /// Archivuje zónu nebo ji vrátí z archivu (FR-D3). Vrací false, když
  /// by nezůstala žádná aktivní zóna.
  Future<bool> setArchived(String id, bool archived) async {
    final zone = _byId(id);
    if (zone == null || zone.archived == archived) return true;
    if (archived && !canArchiveZone(activeZoneCount: _activeCount)) {
      return false;
    }
    await _save(zone.copyWith(archived: archived));
    return true;
  }

  /// Smaže zónu, pokud to pravidla dovolí; jinak vrátí důvod a nic nemění.
  Future<ZoneDeleteBlocker?> deleteZone(String id) async {
    // Deník nemusí být ještě načtený; pravidlo se nesmí obejít prázdným seznamem.
    final List<ActivityEntity> activities =
        ref.read(activityControllerProvider).value ??
        await ref.read(activityControllerProvider.future);
    final blocker = zoneDeleteBlocker(
      zoneId: id,
      activeZoneCount: _activeCount,
      isArchived: _byId(id)?.archived ?? false,
      activityCount: activities.where((a) => a.zoneId == id).length,
    );
    if (blocker != null) return blocker;

    final previous = _current;
    await _mutate(() async {
      await ref.read(zoneRepositoryProvider).deleteZone(id);
      return previous.where((z) => z.id != id).toList();
    });
    return null;
  }

  ZoneEntity? _byId(String id) {
    for (final z in _current) {
      if (z.id == id) return z;
    }
    return null;
  }

  Future<void> _save(ZoneEntity zone) async {
    final previous = _current;
    await _mutate(() async {
      await ref.read(zoneRepositoryProvider).saveZone(zone);
      return _sorted([...previous.where((z) => z.id != zone.id), zone]);
    });
  }

  /// Provede zápis a nový seznam dá do stavu. Při chybě stav nese chybu,
  /// ale Riverpod v něm zachová poslední známý seznam, takže obrazovky
  /// nezmizí a volající pozná neúspěch přes `hasError`.
  Future<void> _mutate(Future<List<ZoneEntity>> Function() op) async {
    state = await AsyncValue.guard(op);
  }

  static List<ZoneEntity> _sorted(List<ZoneEntity> zones) =>
      [...zones]
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
}

final zonesControllerProvider =
    AsyncNotifierProvider<ZonesController, List<ZoneEntity>>(
      ZonesController.new,
    );

/// Zóny, které se nabízejí pro nové záznamy a úkoly (bez archivovaných).
final activeZonesProvider = Provider<List<ZoneEntity>>((ref) {
  final zones = ref.watch(zonesControllerProvider).value ?? const [];
  return [
    for (final z in zones)
      if (!z.archived) z,
  ];
});

/// Zóna podle id, nebo null pro neznámé id.
final zoneByIdProvider = Provider.family<ZoneEntity?, String>((ref, zoneId) {
  final zones = ref.watch(zonesControllerProvider).value ?? const [];
  for (final zone in zones) {
    if (zone.id == zoneId) return zone;
  }
  return null;
});

/// Název zóny podle id; null pro neznámé id (UI ukáže „Neznámá zóna“).
final zoneNameProvider = Provider.family<String?, String>(
  (ref, zoneId) => ref.watch(zoneByIdProvider(zoneId))?.name,
);
