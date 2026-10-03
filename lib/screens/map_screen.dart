import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../data/favorite_locations_data.dart';
import '../models/favorite_location.dart';
import '../services/location_service.dart';
import '../widgets/favorite_location_details_sheet.dart';
import '../widgets/favorite_locations_list_sheet.dart';
import '../widgets/map_control_buttons.dart';

/// Main Screen displaying OpenStreetMap with Favorite Locations & GPS features
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  // Initial center – Khulna University
  static const LatLng _initialCenter = LatLng(22.8026, 89.3709);
  static const double _initialZoom = 13.0;

  final List<Marker> _markers = [];
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _initializeFavoriteMarkers();
  }

  /// Builds markers for all predefined favorite locations
  void _initializeFavoriteMarkers() {
    for (final location in favoriteLocationsList) {
      _markers.add(_buildFavoriteMarker(location));
    }
  }

  /// Creates a styled marker widget for a favorite location
  Marker _buildFavoriteMarker(FavoriteLocation location) {
    return Marker(
      point: location.latLng,
      width: 50,
      height: 50,
      child: GestureDetector(
        onTap: () => _onFavoriteMarkerTapped(location),
        child: const Icon(
          Icons.location_pin,
          color: Colors.blueAccent,
          size: 45,
        ),
      ),
    );
  }

  /// Shows the details bottom sheet for a tapped favorite location
  void _onFavoriteMarkerTapped(FavoriteLocation location) {
    FavoriteLocationDetailsSheet.show(
      context,
      location,
      onFocusLocation: () => _animateCameraTo(location.latLng, zoom: 16.0),
    );
  }

  /// Smoothly moves the map to [target] at the given [zoom] level
  void _animateCameraTo(LatLng target, {double zoom = 15.0}) {
    _mapController.move(target, zoom);
  }

  /// Fetches current GPS location and moves the map camera
  Future<void> _handleGetCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      final Position position = await LocationService.getCurrentLocation();
      final LatLng userLatLng = LatLng(position.latitude, position.longitude);

      // Add / update the "Your Location" marker
      setState(() {
        _markers.removeWhere(
          (m) =>
              m.point.latitude == userLatLng.latitude &&
              m.point.longitude == userLatLng.longitude,
        );
        _markers.add(
          Marker(
            point: userLatLng,
            width: 50,
            height: 50,
            child: GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Your Location: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: const Icon(
                Icons.my_location,
                color: Colors.redAccent,
                size: 40,
              ),
            ),
          ),
        );
      });

      _animateCameraTo(userLatLng, zoom: 16.0);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Location found: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
            ),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red.shade700,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  /// Shows the favorite locations list bottom sheet
  void _openFavoriteLocationsList() {
    FavoriteLocationsListSheet.show(
      context,
      locations: favoriteLocationsList,
      onSelectLocation: (selected) {
        _animateCameraTo(selected.latLng, zoom: 16.0);
        Future.delayed(const Duration(milliseconds: 350), () {
          if (mounted) _onFavoriteMarkerTapped(selected);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Maps & Location'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 2,
      ),
      body: Stack(
        children: [
          // ── OpenStreetMap ──────────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialCenter,
              initialZoom: _initialZoom,
            ),
            children: [
              // Free OpenStreetMap tile layer — no key required
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName:
                    'com.example.google_maps_and_location',
              ),
              // All markers (favorites + user location)
              MarkerLayer(markers: _markers),
            ],
          ),

          // ── Favorite Locations button (top center) ────────────────────
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.surface,
                  foregroundColor:
                      Theme.of(context).colorScheme.primary,
                  elevation: 6,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: _openFavoriteLocationsList,
                icon:
                    const Text('📍', style: TextStyle(fontSize: 18)),
                label: const Text(
                  'Favorite Locations',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // ── Zoom + My Location controls (bottom right) ────────────────
          Positioned(
            bottom: 24,
            right: 16,
            child: MapControlButtons(
              onZoomIn: () => _mapController.move(
                _mapController.camera.center,
                _mapController.camera.zoom + 1,
              ),
              onZoomOut: () => _mapController.move(
                _mapController.camera.center,
                _mapController.camera.zoom - 1,
              ),
              onMyLocation: _handleGetCurrentLocation,
              isLoadingLocation: _isLoadingLocation,
            ),
          ),

          // ── Loading overlay ───────────────────────────────────────────
          if (_isLoadingLocation)
            Container(
              color: Colors.black26,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text('Fetching GPS location…'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
