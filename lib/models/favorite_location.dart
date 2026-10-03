import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Model representing a predefined favorite location
class FavoriteLocation {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String? description;

  const FavoriteLocation({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.description,
  });

  /// Helper to get LatLng for Google Maps
  LatLng get latLng => LatLng(latitude, longitude);
}
