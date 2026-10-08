import 'package:equatable/equatable.dart';

import 'weather.dart';

/// Kde zahrada leží: poloha pro počasí a výška pro fenologický
/// kalendář (spec 8.1 `gardens.location_lat/lng`, `altitude_m`).
class GardenSite extends Equatable {
  const GardenSite({this.location, this.altitudeM});

  final GardenLocation? location;

  /// Nadmořská výška zadaná uživatelem (m n. m.).
  final int? altitudeM;

  @override
  List<Object?> get props => [location, altitudeM];
}

/// Počasí uložené v telefonu, aby karta fungovala i bez signálu.
class CachedWeather extends Equatable {
  const CachedWeather(this.location, this.report);

  /// Pro jakou polohu se počasí stáhlo (po změně polohy neplatí).
  final GardenLocation location;
  final WeatherReport report;

  Map<String, Object?> toJson() => {
    'lat': location.lat,
    'lng': location.lng,
    'report': report.toJson(),
  };

  static CachedWeather? fromJson(Object? json) {
    if (json is! Map) return null;
    final lat = json['lat'];
    final lng = json['lng'];
    final report = WeatherReport.fromJson(json['report']);
    if (lat is! num || lng is! num || report == null) return null;
    return CachedWeather(
      GardenLocation(lat.toDouble(), lng.toDouble()),
      report,
    );
  }

  @override
  List<Object?> get props => [location, report];
}

/// Nastavení zálivky (FR-W3): automatické odkládání a kdy naposledy
/// proběhlo (nejvýš jednou denně, aby se úkol neposouval pořád dál).
class WeatherPrefs extends Equatable {
  const WeatherPrefs({this.autoPostpone = false, this.autoPostponedOn});

  final bool autoPostpone;

  /// Den (`YYYY-MM-DD`), kdy automatika naposledy odkládala.
  final String? autoPostponedOn;

  WeatherPrefs copyWith({
    bool? autoPostpone,
    String? Function()? autoPostponedOn,
  }) => WeatherPrefs(
    autoPostpone: autoPostpone ?? this.autoPostpone,
    autoPostponedOn: autoPostponedOn != null
        ? autoPostponedOn()
        : this.autoPostponedOn,
  );

  Map<String, Object?> toJson() => {
    'autoPostpone': autoPostpone,
    'autoPostponedOn': autoPostponedOn,
  };

  static WeatherPrefs fromJson(Object? json) {
    if (json is! Map) return const WeatherPrefs();
    return WeatherPrefs(
      autoPostpone: json['autoPostpone'] == true,
      autoPostponedOn: json['autoPostponedOn'] as String?,
    );
  }

  @override
  List<Object?> get props => [autoPostpone, autoPostponedOn];
}

/// Poloha a výška v řádku zahrady (synchronizuje se), počasí
/// a nastavení zálivky jen v tomto telefonu.
abstract interface class GardenSiteRepository {
  Future<GardenSite> loadSite();
  Future<void> saveSite(GardenSite site);
  Future<CachedWeather?> loadCache();
  Future<void> saveCache(CachedWeather? cache);
  Future<WeatherPrefs> loadPrefs();
  Future<void> savePrefs(WeatherPrefs prefs);
}

/// Proč nejde zjistit polohu telefonu.
enum DeviceLocationFailure { unsupported, serviceDisabled, denied, failed }

class DeviceLocationException implements Exception {
  const DeviceLocationException(this.failure);

  final DeviceLocationFailure failure;

  @override
  String toString() => 'DeviceLocationException($failure)';
}

/// Přibližná poloha telefonu (jen na klepnutí „Použít polohu telefonu“).
abstract interface class DeviceLocation {
  /// Hází [DeviceLocationException].
  Future<GardenLocation> current();
}

class UnsupportedDeviceLocation implements DeviceLocation {
  const UnsupportedDeviceLocation();

  @override
  Future<GardenLocation> current() => Future.error(
    const DeviceLocationException(DeviceLocationFailure.unsupported),
  );
}
