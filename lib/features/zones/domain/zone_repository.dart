import 'zone_entity.dart';

abstract class ZoneRepository {
  Future<List<ZoneEntity>> getAllZones();
  Future<void> saveZone(ZoneEntity zone);
  Future<void> deleteZone(String id);

  /// Naplní seznam výchozími zónami, pokud je prázdný.
  Future<void> seedDefaultsIfEmpty();
}
