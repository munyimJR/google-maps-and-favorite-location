import 'package:flutter/material.dart';
import '../models/favorite_location.dart';

/// Reusable modal sheet displaying the list of favorite locations
class FavoriteLocationsListSheet extends StatelessWidget {
  final List<FavoriteLocation> locations;
  final ValueChanged<FavoriteLocation> onSelectLocation;

  const FavoriteLocationsListSheet({
    super.key,
    required this.locations,
    required this.onSelectLocation,
  });

  /// Helper static method to display the modal bottom sheet
  static Future<void> show(
    BuildContext context, {
    required List<FavoriteLocation> locations,
    required ValueChanged<FavoriteLocation> onSelectLocation,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FavoriteLocationsListSheet(
        locations: locations,
        onSelectLocation: onSelectLocation,
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
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.only(top: 16, bottom: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 48,
            height: 5,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.redAccent, size: 28),
                const SizedBox(width: 8),
                Text(
                  'Favorite Locations',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(),

          // Locations List
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: locations.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final location = locations[index];
                return ListTile(
                  leading: const Text(
                    '⭐',
                    style: TextStyle(fontSize: 22),
                  ),
                  title: Text(
                    location.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    'Lat: ${location.latitude.toStringAsFixed(4)}, Lng: ${location.longitude.toStringAsFixed(4)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.pop(context);
                    onSelectLocation(location);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
