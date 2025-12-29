import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/widgets/clean_card.dart';
import '../../core/theme/app_colors.dart';
import 'guard_detail_screen.dart';

/// Guards screen - Virtual Guards list
/// Premium UI design matching command center and spaces
class GuardsScreen extends StatefulWidget {
  const GuardsScreen({super.key});

  @override
  State<GuardsScreen> createState() => _GuardsScreenState();
}

class _GuardsScreenState extends State<GuardsScreen> {
  // Mock guards data with icons and colors
  final List<Map<String, dynamic>> _guards = [
    {
      'name': 'Package Watch',
      'space': 'Front Door',
      'status': 'active',
      'description': 'Alerts when packages are delivered',
      'icon': Icons.inventory_2_outlined,
      'color': const Color(0xFF6B4CE6),
      'alertsToday': 3,
    },
    {
      'name': 'Pool Safety',
      'space': 'Backyard',
      'status': 'active',
      'description': 'Monitors pool area for safety',
      'icon': Icons.pool_outlined,
      'color': const Color(0xFF2196F3),
      'alertsToday': 0,
    },
    {
      'name': 'Night Watch',
      'space': 'Living Room',
      'status': 'paused',
      'description': 'Active during night hours only',
      'icon': Icons.nightlight_outlined,
      'color': const Color(0xFF7C4DFF),
      'alertsToday': 12,
    },
    {
      'name': 'Pet Monitor',
      'space': 'Kitchen',
      'status': 'active',
      'description': 'Watches for pet activity',
      'icon': Icons.pets_outlined,
      'color': const Color(0xFFFF9800),
      'alertsToday': 8,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final activeGuards = _guards.where((g) => g['status'] == 'active').length;

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
                      'Guards',
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '$activeGuards Active',
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

            // Guards List
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final guard = _guards[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _buildGuardRow(context, guard),
                    );
                  },
                  childCount: _guards.length,
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
        onPressed: () => _showAddGuardSheet(context),
        child: const Icon(CupertinoIcons.add),
      ),
    );
  }

  Widget _buildGuardRow(BuildContext context, Map<String, dynamic> guard) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isActive = guard['status'] == 'active';

    return CleanCard(
      onTap: () => _navigateToGuardDetail(context, guard),
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
              guard['icon'] as IconData,
              size: 20,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Guard info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        guard['name'] as String,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.success : AppColors.warning,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  guard['space'] as String,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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

  void _navigateToGuardDetail(BuildContext context, Map<String, dynamic> guard) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GuardDetailScreen(
          guardName: guard['name'] as String,
          guardSpace: guard['space'] as String,
          guardDescription: guard['description'] as String,
          isActive: guard['status'] == 'active',
        ),
      ),
    );
  }

  void _showAddGuardSheet(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
                'New Guard',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Guard name
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'e.g., Package Watch',
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Where to watch
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Location',
                  hintText: 'e.g., Front Door',
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // What to watch for
              TextField(
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'What to watch for',
                  hintText: 'Describe what this guard should monitor...',
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Create button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Mock action - create guard
                  },
                  child: const Text('Create Guard'),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}
