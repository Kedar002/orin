import 'package:flutter/material.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/widgets/clean_card.dart';
import '../../core/theme/app_colors.dart';
import 'space_detail_screen.dart';

/// Spaces screen - Camera spaces list
/// Card-based layout with space name and status
class SpacesScreen extends StatelessWidget {
  const SpacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Mock data
    final spaces = [
      {'name': 'Living Room', 'cameras': 2, 'status': 'normal'},
      {'name': 'Front Door', 'cameras': 1, 'status': 'normal'},
      {'name': 'Backyard', 'cameras': 3, 'status': 'normal'},
      {'name': 'Garage', 'cameras': 1, 'status': 'normal'},
    ];

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Large title
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
                      style: theme.textTheme.displayLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Your monitored areas',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Space cards
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final space = spaces[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: CleanCard(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => SpaceDetailScreen(
                                spaceName: space['name'] as String,
                              ),
                            ),
                          );
                        },
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Row(
                          children: [
                            // Status indicator
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),

                            // Space info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    space['name'] as String,
                                    style: theme.textTheme.displaySmall,
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    '${space['cameras']} camera${space['cameras'] == 1 ? '' : 's'}',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondaryLight,
                                    ),
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
                  childCount: spaces.length,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Mock action - add new space
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Space'),
      ),
    );
  }
}
