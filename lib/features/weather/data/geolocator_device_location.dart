import 'package:geolocator/geolocator.dart';

import '../domain/garden_site.dart';
import '../domain/weather.dart';

/// Přibližná poloha telefonu (stačí ~1 km, ukládá se zaokrouhlená).
class GeolocatorDeviceLocation implements DeviceLocation {
  const GeolocatorDeviceLocation();

  @override
  Future<GardenLocation> current() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw const DeviceLocationException(
          DeviceLocationFailure.serviceDisabled,
        );
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw const DeviceLocationException(DeviceLocationFailure.denied);
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 20),
        ),
      );
      return GardenLocation(position.latitude, position.longitude);
    } on DeviceLocationException {
      rethrow;
    } catch (_) {
      throw const DeviceLocationException(DeviceLocationFailure.failed);
    }
  }
}
