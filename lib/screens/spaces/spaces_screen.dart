import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/widgets/clean_card.dart';
import '../../core/theme/app_colors.dart';
import '../../models/space_model.dart';
import 'space_detail_screen.dart';

/// Spaces Screen - Clean Apple-style minimal design
class SpacesScreen extends StatefulWidget {
  const SpacesScreen({super.key});

  @override
  State<SpacesScreen> createState() => _SpacesScreenState();
}

class _SpacesScreenState extends State<SpacesScreen> {
  List<SpaceItem> _spaces = [
    SpaceItem(
      id: 'SPACE-001',
      name: 'Hospital A',
      icon: Icons.local_hospital,
      color: const Color(0xFF6B4CE6),
      level: 0,
      cameras: [
        CameraItem(
          id: 'CAM-001',
          name: 'Main Entrance',
          location: 'Hospital A',
          streamUrl: 'https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_adv_example_hevc/master.m3u8',
        ),
        CameraItem(
          id: 'CAM-002',
          name: 'Emergency Room',
          location: 'Hospital A',
          streamUrl: 'https://cph-p2p-msl.akamaized.net/hls/live/2000341/test/master.m3u8',
        ),
      ],
    ),
    SpaceItem(
      id: 'SPACE-002',
      name: 'Hospital B',
      icon: Icons.local_hospital,
      color: const Color(0xFF0EA5E9),
      level: 0,
      cameras: [
        CameraItem(
          id: 'CAM-003',
          name: 'Reception',
          location: 'Hospital B',
          streamUrl: 'https://cph-p2p-msl.akamaized.net/hls/live/2000341/test/master.m3u8',
        ),
      ],
    ),
    SpaceItem(
      id: 'SPACE-003',
      name: 'Hospital C',
      icon: Icons.local_hospital,
      color: const Color(0xFF10B981),
      level: 0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final totalCameras = _spaces.fold<int>(0, (sum, space) => sum + space.totalCameraCount);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spaces',
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '$totalCameras Cameras',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Spaces List
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final space = _spaces[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _buildSpaceRow(context, space),
                    );
                  },
                  childCount: _spaces.length,
                ),
              ),
            ),

            // Bottom spacing
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSpaceSheet(context),
        child: const Icon(CupertinoIcons.add),
      ),
    );
  }

  Widget _buildSpaceRow(BuildContext context, SpaceItem space) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return CleanCard(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SpaceDetailScreen(
              space: space,
              breadcrumbs: const [],
            ),
          ),
        );
      },
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          // Simple icon circle
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              space.icon,
              size: 20,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Space info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  space.name,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${space.totalCameraCount} cameras',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          // Chevron
          Icon(
            CupertinoIcons.chevron_right,
            size: 20,
            color: isDark
                ? AppColors.textTertiaryDark
                : AppColors.textTertiaryLight,
          ),
        ],
      ),
    );
  }

  void _showAddSpaceSheet(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Icon options
    final icons = [
      Icons.local_hospital,
      Icons.business,
      Icons.home,
      Icons.apartment,
      Icons.store,
      Icons.location_city,
    ];

    IconData selectedIcon = Icons.local_hospital;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.textTertiaryDark
                          : AppColors.textTertiaryLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                Text(
                  'New Space',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Space name
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'e.g., Hospital A',
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Icon selection
                Text(
                  'Icon',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: icons.map((icon) {
                    final isSelected = selectedIcon == icon;
                    return Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: InkWell(
                        onTap: () {
                          setModalState(() {
                            selectedIcon = icon;
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1))
                                : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            icon,
                            color: isDark ? Colors.white70 : Colors.black54,
                            size: 22,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Create button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Mock action - create space
                    },
                    child: const Text('Create Space'),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
