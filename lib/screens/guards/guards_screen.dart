import 'package:flutter/material.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/widgets/clean_card.dart';
import '../../core/theme/app_colors.dart';
import 'guard_detail_screen.dart';

/// Guards screen - Virtual Guards list
/// Card-based layout showing guard name, assigned space, and status
class GuardsScreen extends StatelessWidget {
  const GuardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Mock guards data
    final guards = [
      {
        'name': 'Package Watch',
        'space': 'Front Door',
        'status': 'active',
        'description': 'Alerts when packages are delivered',
      },
      {
        'name': 'Pool Safety',
        'space': 'Backyard',
        'status': 'active',
        'description': 'Monitors pool area for safety',
      },
      {
        'name': 'Night Watch',
        'space': 'Living Room',
        'status': 'paused',
        'description': 'Active during night hours only',
      },
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
                      'Guards',
                      style: theme.textTheme.displayLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Your AI-powered watchers',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Guards cards
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final guard = guards[index];
                    final isActive = guard['status'] == 'active';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: CleanCard(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => GuardDetailScreen(
                                guardName: guard['name'] as String,
                                guardSpace: guard['space'] as String,
                                guardDescription: guard['description'] as String,
                                isActive: isActive,
                              ),
                            ),
                          );
                        },
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Guard name and status
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    guard['name'] as String,
                                    style: theme.textTheme.displaySmall,
                                  ),
                                ),
                                // Status indicator
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: AppSpacing.xs,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? AppColors.success.withOpacity(0.1)
                                        : AppColors.warning.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    isActive ? 'Active' : 'Paused',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: isActive
                                          ? AppColors.success
                                          : AppColors.warning,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: AppSpacing.sm),

                            // Assigned space
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 16,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  guard['space'] as String,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: AppSpacing.sm),

                            // Description
                            Text(
                              guard['description'] as String,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isDark
                                    ? AppColors.textTertiaryDark
                                    : AppColors.textTertiaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: guards.length,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Mock action - create new guard
        },
        icon: const Icon(Icons.add),
        label: const Text('New Guard'),
      ),
    );
  }
}
