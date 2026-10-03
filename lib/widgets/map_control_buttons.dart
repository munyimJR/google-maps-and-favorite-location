import 'package:flutter/material.dart';

/// Reusable widget for custom Zoom and My Location controls
class MapControlButtons extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onMyLocation;
  final bool isLoadingLocation;

  const MapControlButtons({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onMyLocation,
    this.isLoadingLocation = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Zoom In Button
        FloatingActionButton.small(
          heroTag: 'btn_zoom_in',
          tooltip: 'Zoom In',
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.primary,
          onPressed: onZoomIn,
          child: const Icon(Icons.add),
        ),
        const SizedBox(height: 8),

        // Zoom Out Button
        FloatingActionButton.small(
          heroTag: 'btn_zoom_out',
          tooltip: 'Zoom Out',
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.primary,
          onPressed: onZoomOut,
          child: const Icon(Icons.remove),
        ),
        const SizedBox(height: 12),

        // My Location Button
        FloatingActionButton(
          heroTag: 'btn_my_location',
          tooltip: 'My Location',
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          onPressed: isLoadingLocation ? null : onMyLocation,
          child: isLoadingLocation
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.my_location),
        ),
      ],
    );
  }
}
