import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/di/providers.dart';
import '../domain/zone_entity.dart';

/// Seznam zón seřazený podle názvu.
class ZonesController extends AsyncNotifier<List<ZoneEntity>> {
  @override
  Future<List<ZoneEntity>> build() async {
    final zones = await ref.watch(zoneRepositoryProvider).getAllZones();
    return _sorted(zones);
  }

  Future<void> addZone(String name) async {
    final zone = ZoneEntity(id: const Uuid().v4(), name: name.trim());
    await _save(zone);
  }

  /// Uloží více zón najednou (onboarding).
  Future<void> addZones(List<ZoneEntity> zones) async {
    final previous = state.value ?? const <ZoneEntity>[];
    await _mutate(() async {
      final repo = ref.read(zoneRepositoryProvider);
      for (final zone in zones) {
        await repo.saveZone(zone);
      }
      final ids = zones.map((z) => z.id).toSet();
      return _sorted([...previous.where((z) => !ids.contains(z.id)), ...zones]);
    });
  }

  Future<void> renameZone(String id, String name) =>
      _save(ZoneEntity(id: id, name: name.trim()));

  Future<void> deleteZone(String id) async {
    final previous = state.value ?? const <ZoneEntity>[];
    await _mutate(() async {
      await ref.read(zoneRepositoryProvider).deleteZone(id);
      return previous.where((z) => z.id != id).toList();
    });
  }

  Future<void> _save(ZoneEntity zone) async {
    final previous = state.value ?? const <ZoneEntity>[];
    await _mutate(() async {
      await ref.read(zoneRepositoryProvider).saveZone(zone);
      return _sorted([...previous.where((z) => z.id != zone.id), zone]);
    });
  }

  /// Provede zápis a nový seznam dá do stavu. Při chybě stav nese chybu,
  /// ale zachová poslední známý seznam, takže obrazovky nezmizí.
  Future<void> _mutate(Future<List<ZoneEntity>> Function() op) async {
    state = (await AsyncValue.guard(op)).copyWithPrevious(state);
  }

  static List<ZoneEntity> _sorted(List<ZoneEntity> zones) =>
      [...zones]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
}

final zonesControllerProvider =
    AsyncNotifierProvider<ZonesController, List<ZoneEntity>>(ZonesController.new);

/// Název zóny podle id; pro neznámé id vrací „Neznámá zóna“.
final zoneNameProvider = Provider.family<String, String>((ref, zoneId) {
  final zones = ref.watch(zonesControllerProvider).value ?? const <ZoneEntity>[];
  for (final zone in zones) {
    if (zone.id == zoneId) return zone.name;
  }
  return 'Neznámá zóna';
});
