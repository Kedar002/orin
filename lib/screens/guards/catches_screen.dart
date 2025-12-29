import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/widgets/clean_card.dart';
import '../../core/theme/app_colors.dart';

/// Recent Catches Screen
/// Shows detailed list of all catches made by a guard
/// Pure Apple design - clean, minimal, focused on content
class CatchesScreen extends StatefulWidget {
  final String guardName;

  const CatchesScreen({
    super.key,
    required this.guardName,
  });

  @override
  State<CatchesScreen> createState() => _CatchesScreenState();
}

class _CatchesScreenState extends State<CatchesScreen> {
  // Mock detailed catches data
  List<Map<String, dynamic>> _getCatches() {
    return [
      {
        'title': 'Package delivered',
        'camera': 'Front Door',
        'cameraId': 'CAM-003',
        'timestamp': '2:10 PM',
        'date': 'Today',
        'description': 'Amazon package detected at front door',
        'type': 'delivery',
      },
      {
        'title': 'Person detected',
        'camera': 'Main Entrance',
        'cameraId': 'CAM-001',
        'timestamp': '11:45 AM',
        'date': 'Today',
        'description': 'Unknown person approaching entrance',
        'type': 'person',
      },
      {
        'title': 'Motion detected',
        'camera': 'Driveway',
        'cameraId': 'CAM-002',
        'timestamp': '9:32 AM',
        'date': 'Today',
        'description': 'Vehicle motion detected in driveway',
        'type': 'motion',
      },
      {
        'title': 'Package picked up',
        'camera': 'Front Door',
        'cameraId': 'CAM-003',
        'timestamp': '6:22 PM',
        'date': 'Yesterday',
        'description': 'Package removed from front door area',
        'type': 'delivery',
      },
      {
        'title': 'Person detected',
        'camera': 'Main Entrance',
        'cameraId': 'CAM-001',
        'timestamp': '3:15 PM',
        'date': 'Yesterday',
        'description': 'Delivery person detected',
        'type': 'person',
      },
      {
        'title': 'Motion detected',
        'camera': 'Driveway',
        'cameraId': 'CAM-002',
        'timestamp': '8:05 AM',
        'date': 'Yesterday',
        'description': 'Morning activity detected',
        'type': 'motion',
      },
    ];
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'delivery':
        return CupertinoIcons.cube_box;
      case 'person':
        return CupertinoIcons.person;
      case 'motion':
        return CupertinoIcons.location;
      default:
        return CupertinoIcons.bell;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final catches = _getCatches();

    // Group catches by date
    final todayCatches = catches.where((c) => c['date'] == 'Today').toList();
    final yesterdayCatches = catches.where((c) => c['date'] == 'Yesterday').toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('Recent Catches'),
        elevation: 0,
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header info
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.guardName,
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${catches.length} catches in the last 48 hours',
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

            // Today section
            if (todayCatches.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: Text(
                    'TODAY',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _buildCatchCard(context, todayCatches[index], isDark),
                      );
                    },
                    childCount: todayCatches.length,
                  ),
                ),
              ),
            ],

            // Yesterday section
            if (yesterdayCatches.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: Text(
                    'YESTERDAY',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _buildCatchCard(context, yesterdayCatches[index], isDark),
                      );
                    },
                    childCount: yesterdayCatches.length,
                  ),
                ),
              ),
            ],

            // Bottom spacing
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCatchCard(BuildContext context, Map<String, dynamic> catch_, bool isDark) {
    final theme = Theme.of(context);

    return CleanCard(
      onTap: () {
        // Could navigate to camera viewer or event detail
      },
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          // Icon circle
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
              _getIconForType(catch_['type']),
              size: 20,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Catch details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  catch_['title'] as String,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),

                // Camera and time
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.videocam,
                      size: 12,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      catch_['camera'] as String,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 2,
                      height: 2,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      catch_['timestamp'] as String,
                      style: theme.textTheme.bodySmall?.copyWith(
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
}
