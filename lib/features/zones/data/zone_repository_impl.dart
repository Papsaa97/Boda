import 'package:hive_ce/hive.dart';

import '../domain/zone_entity.dart';
import '../domain/zone_repository.dart';

/// Zóny v Hive boxu: klíč je id zóny, hodnota její název.
class ZoneRepositoryImpl implements ZoneRepository {
  final Box<String> _box;

  ZoneRepositoryImpl(this._box);

  @override
  Future<List<ZoneEntity>> getAllZones() async {
    return _box.keys
        .cast<String>()
        .map((id) => ZoneEntity(id: id, name: _box.get(id)!))
        .toList();
  }

  @override
  Future<void> saveZone(ZoneEntity zone) => _box.put(zone.id, zone.name);

  @override
  Future<void> deleteZone(String id) => _box.delete(id);

  @override
  Future<void> seedDefaultsIfEmpty() async {
    if (_box.isNotEmpty) return;
    await _box.putAll({for (final z in defaultZones) z.id: z.name});
  }
}
