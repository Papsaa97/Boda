import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/di/providers.dart';
import '../../activity/domain/activity_entity.dart';
import '../../activity/presentation/controllers/activity_controller.dart';
import '../domain/zone_entity.dart';
import '../domain/zone_rules.dart';

/// Seznam zón seřazený podle názvu.
class ZonesController extends AsyncNotifier<List<ZoneEntity>> {
  @override
  Future<List<ZoneEntity>> build() async {
    final zones = await ref.watch(zoneRepositoryProvider).getAllZones();
    return _sorted(zones);
  }

  List<ZoneEntity> get _current => state.value ?? const <ZoneEntity>[];

  /// Přidá zónu. Vrací chybovou hlášku, když název neprojde kontrolou.
  Future<String?> addZone(String name) async {
    final error = validateZoneName(name, _current);
    if (error != null) return error;
    await _save(ZoneEntity(id: const Uuid().v4(), name: name.trim()));
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

  /// Přejmenuje zónu. Vrací chybovou hlášku, když název neprojde kontrolou.
  Future<String?> renameZone(String id, String name) async {
    final error = validateZoneName(name, _current, exceptId: id);
    if (error != null) return error;
    await _save(ZoneEntity(id: id, name: name.trim()));
    return null;
  }

  /// Smaže zónu, pokud to pravidla dovolí; jinak vrátí důvod a nic nemění.
  Future<ZoneDeleteBlocker?> deleteZone(String id) async {
    // Deník nemusí být ještě načtený; pravidlo se nesmí obejít prázdným seznamem.
    final List<ActivityEntity> activities =
        ref.read(activityControllerProvider).value ??
        await ref.read(activityControllerProvider.future);
    final blocker = zoneDeleteBlocker(
      zoneId: id,
      zoneCount: _current.length,
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

/// Název zóny podle id; pro neznámé id vrací „Neznámá zóna“.
final zoneNameProvider = Provider.family<String, String>((ref, zoneId) {
  final zones =
      ref.watch(zonesControllerProvider).value ?? const <ZoneEntity>[];
  for (final zone in zones) {
    if (zone.id == zoneId) return zone.name;
  }
  return 'Neznámá zóna';
});
