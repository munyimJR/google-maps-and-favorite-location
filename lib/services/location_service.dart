import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

/// Service to handle device GPS location & permissions cleanly
class LocationService {
  /// Checks permissions and returns current [Position].
  /// Throws an [Exception] with a user-friendly message on any failure.
  static Future<Position> getCurrentLocation() async {
    try {
      // 1. Check whether location service is enabled on the device / emulator
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception(
          'Location services are disabled.\n'
          'Please enable GPS in your device settings and try again.',
        );
      }

      // 2. Check / request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception(
            'Location permission was denied. '
            'Please grant location access to use this feature.',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Location permission is permanently denied. '
          'Please enable it from your device App Settings.',
        );
      }

      // 3. Return current position
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
    } on PlatformException catch (e) {
      // Handles emulator/device errors like "RequestAccess failed"
      if (e.message != null &&
          e.message!.toLowerCase().contains('geolocation service')) {
        throw Exception(
          'Location service is not running on this device.\n'
          'If using an emulator, go to:\n'
          'Extended Controls (⋮) → Location → set a point → Send.',
        );
      }
      throw Exception('Location error: ${e.message ?? e.code}');
    } catch (e) {
      // Re-throw clean Exception messages, wrap anything else
      if (e is Exception) rethrow;
      throw Exception('Unexpected location error: $e');
    }
  }
}
