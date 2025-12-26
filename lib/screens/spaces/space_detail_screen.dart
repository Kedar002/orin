import 'package:flutter/material.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/widgets/clean_card.dart';
import '../../core/theme/app_colors.dart';
import 'live_camera_screen.dart';

/// Space detail screen
/// Shows list of cameras in a space
class SpaceDetailScreen extends StatelessWidget {
  final String spaceName;

  const SpaceDetailScreen({
    super.key,
    required this.spaceName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Mock camera data based on space
    final cameras = [
      {'name': '$spaceName - Main View', 'status': 'online'},
      if (spaceName == 'Living Room') {'name': '$spaceName - Corner', 'status': 'online'},
      if (spaceName == 'Backyard') ...[
        {'name': '$spaceName - Pool', 'status': 'online'},
        {'name': '$spaceName - Gate', 'status': 'online'},
      ],
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(spaceName),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: cameras.length,
        itemBuilder: (context, index) {
          final camera = cameras[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: CleanCard(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => LiveCameraScreen(
                      cameraName: camera['name'] as String,
                    ),
                  ),
                );
              },
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  // Camera thumbnail placeholder
                  Container(
                    width: 80,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceDark
                          : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.videocam,
                      color: isDark
                          ? AppColors.textTertiaryDark
                          : AppColors.textTertiaryLight,
                    ),
                  ),

                  const SizedBox(width: AppSpacing.md),

                  // Camera info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          camera['name'] as String,
                          style: theme.textTheme.headlineMedium,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              'Online',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Chevron
                  Icon(
                    Icons.chevron_right,
                    color: isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiaryLight,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
