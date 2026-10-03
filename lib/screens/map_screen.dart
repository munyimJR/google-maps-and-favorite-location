import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../data/favorite_locations_data.dart';
import '../models/favorite_location.dart';
import '../services/location_service.dart';
import '../widgets/favorite_location_details_sheet.dart';
import '../widgets/favorite_locations_list_sheet.dart';
import '../widgets/map_control_buttons.dart';

/// Main Screen displaying Google Map with Favorite Locations & GPS Location features
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;

  // Initial Camera position centered around Khulna University
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(22.8026, 89.3709),
    zoom: 13.0,
  );

  final Set<Marker> _markers = {};
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _initializeFavoriteMarkers();
  }

  /// Initializes the markers for all favorite locations
  void _initializeFavoriteMarkers() {
    for (final location in favoriteLocationsList) {
      _markers.add(
        Marker(
          markerId: MarkerId('fav_${location.id}'),
          position: location.latLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: InfoWindow(
            title: location.name,
            snippet: 'ID: ${location.id} (Tap to view details)',
            onTap: () => _onFavoriteMarkerTapped(location),
          ),
          onTap: () => _onFavoriteMarkerTapped(location),
        ),
      );
    }
  }

  /// Called when a favorite marker is tapped
  void _onFavoriteMarkerTapped(FavoriteLocation location) {
    FavoriteLocationDetailsSheet.show(
      context,
      location,
      onFocusLocation: () => _animateCameraTo(location.latLng, zoom: 16.0),
    );
  }

  /// Moves the map camera smoothly to a given LatLng
  Future<void> _animateCameraTo(LatLng target, {double zoom = 15.0}) async {
    if (_mapController != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: target, zoom: zoom),
        ),
      );
    }
  }

  /// Fetches user's current GPS location and animates camera to it
  Future<void> _handleGetCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // 1. Get current position via LocationService
      final position = await LocationService.getCurrentLocation();
      final userLatLng = LatLng(position.latitude, position.longitude);

      setState(() {
        // Add or update User Location Marker
        _markers.removeWhere((m) => m.markerId.value == 'user_current_location');
        _markers.add(
          Marker(
            markerId: const MarkerId('user_current_location'),
            position: userLatLng,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: const InfoWindow(
              title: 'Your Location',
              snippet: 'You are here',
            ),
          ),
        );
      });

      // 2. Move camera to user's location
      await _animateCameraTo(userLatLng, zoom: 16.0);

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
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  /// Opens the modal list displaying all favorite locations
  void _openFavoriteLocationsList() {
    FavoriteLocationsListSheet.show(
      context,
      locations: favoriteLocationsList,
      onSelectLocation: (selectedLocation) {
        _animateCameraTo(selectedLocation.latLng, zoom: 16.0);
        _onFavoriteMarkerTapped(selectedLocation);
      },
    );
  }

  /// Zooms in by 1 step
  void _zoomIn() {
    _mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  /// Zooms out by 1 step
  void _zoomOut() {
    _mapController?.animateCamera(CameraUpdate.zoomOut());
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
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
          // 1. Google Map Widget
          GoogleMap(
            initialCameraPosition: _initialCameraPosition,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false, // Using our custom button
            zoomControlsEnabled: false, // Using our custom zoom buttons
            onMapCreated: (controller) {
              _mapController = controller;
            },
          ),

          // 2. Top Banner / Favorite Locations Button
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  elevation: 6,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: _openFavoriteLocationsList,
                icon: const Text('📍', style: TextStyle(fontSize: 18)),
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

          // 3. Right-side Custom Control Buttons (Zoom In/Out + My Location)
          Positioned(
            bottom: 24,
            right: 16,
            child: MapControlButtons(
              onZoomIn: _zoomIn,
              onZoomOut: _zoomOut,
              onMyLocation: _handleGetCurrentLocation,
              isLoadingLocation: _isLoadingLocation,
            ),
          ),
        ],
      ),
    );
  }
}
