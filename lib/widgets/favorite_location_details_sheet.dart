import 'package:flutter/material.dart';
import '../models/favorite_location.dart';

/// Reusable modal bottom sheet to display details of a selected favorite location
class FavoriteLocationDetailsSheet extends StatelessWidget {
  final FavoriteLocation location;
  final VoidCallback? onFocusLocation;

  const FavoriteLocationDetailsSheet({
    super.key,
    required this.location,
    this.onFocusLocation,
  });

  /// Helper static method to show this bottom sheet
  static Future<void> show(
    BuildContext context,
    FavoriteLocation location, {
    VoidCallback? onFocusLocation,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => FavoriteLocationDetailsSheet(
        location: location,
        onFocusLocation: onFocusLocation,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 48,
              height: 5,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.star_rounded,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Favorite Location',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    Text(
                      location.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),

          // Information tiles as required by assignment:
          // ID, Name, Latitude, Longitude
          _buildInfoRow(
            icon: Icons.tag,
            label: 'Location ID',
            value: location.id.toString(),
            theme: theme,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            icon: Icons.place_outlined,
            label: 'Name',
            value: location.name,
            theme: theme,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            icon: Icons.explore_outlined,
            label: 'Latitude',
            value: location.latitude.toStringAsFixed(6),
            theme: theme,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            icon: Icons.explore_outlined,
            label: 'Longitude',
            value: location.longitude.toStringAsFixed(6),
            theme: theme,
          ),

          if (location.description != null && location.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.info_outline,
              label: 'Description',
              value: location.description!,
              theme: theme,
            ),
          ],

          const SizedBox(height: 24),

          // Focus on Location Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                onFocusLocation?.call();
              },
              icon: const Icon(Icons.my_location),
              label: const Text(
                'Focus on Map',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        SizedBox(
          width: 90,
          child: Text(
            '$label:',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
