import 'package:geolocator/geolocator.dart';

/// Service to handle device GPS location & permissions cleanly
class LocationService {
  /// Checks permissions and returns current [Position]
  /// Throws an [Exception] with an informative message if permission is denied or service is disabled.
  static Future<Position> getCurrentLocation() async {
    // 1. Check whether location service is enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception(
        'Location services are disabled on your device. Please turn on GPS.',
      );
    }

    // 2. Check location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission was denied by the user.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permission is permanently denied. Please grant permission from app settings.',
      );
    }

    // 3. Return current position
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }
}
