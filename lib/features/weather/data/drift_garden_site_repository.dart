import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/garden_site.dart';
import '../domain/weather.dart';

/// Klíč nastavení s posledním staženým počasím (jen v tomto telefonu).
const weatherCacheSettingKey = 'weather_cache';

/// Klíč nastavení zálivky (automatické odkládání).
const weatherPrefsSettingKey = 'weather_prefs';

/// Poloha a výška v řádku zahrady, počasí a nastavení v telefonu.
class DriftGardenSiteRepository implements GardenSiteRepository {
  DriftGardenSiteRepository(this._db, this._gardenId, this._clock);

  final AppDatabase _db;
  final String _gardenId;
  final DateTime Function() _clock;

  @override
  Future<GardenSite> loadSite() async {
    final row = await (_db.select(
      _db.gardens,
    )..where((g) => g.id.equals(_gardenId))).getSingleOrNull();
    final lat = row?.locationLat;
    final lng = row?.locationLng;
    return GardenSite(
      location: lat == null || lng == null ? null : GardenLocation(lat, lng),
      altitudeM: row?.altitudeM,
    );
  }

  @override
  Future<void> saveSite(GardenSite site) async {
    await (_db.update(_db.gardens)..where((g) => g.id.equals(_gardenId))).write(
      GardensCompanion(
        locationLat: Value(site.location?.lat),
        locationLng: Value(site.location?.lng),
        altitudeM: Value(site.altitudeM),
        updatedAt: Value(_clock().toUtc()),
      ),
    );
  }

  @override
  Future<CachedWeather?> loadCache() async {
    final json = await _db.readSetting(weatherCacheSettingKey);
    if (json == null) return null;
    try {
      return CachedWeather.fromJson(jsonDecode(json));
    } on FormatException {
      return null;
    }
  }

  @override
  Future<void> saveCache(CachedWeather? cache) => _db.writeSetting(
    weatherCacheSettingKey,
    cache == null ? null : jsonEncode(cache.toJson()),
  );

  @override
  Future<WeatherPrefs> loadPrefs() async {
    final json = await _db.readSetting(weatherPrefsSettingKey);
    if (json == null) return const WeatherPrefs();
    try {
      return WeatherPrefs.fromJson(jsonDecode(json));
    } on FormatException {
      return const WeatherPrefs();
    }
  }

  @override
  Future<void> savePrefs(WeatherPrefs prefs) =>
      _db.writeSetting(weatherPrefsSettingKey, jsonEncode(prefs.toJson()));
}
