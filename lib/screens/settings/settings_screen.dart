import 'package:flutter/material.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';

/// Settings screen
/// Pure iOS style. Clean. Minimal. Functional.
/// Steve Jobs would approve: no decoration, just content.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Large title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.xl,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: Text(
                  'Settings',
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Account section
            _buildSection(
              context,
              title: 'ACCOUNT',
              items: [
                _SettingsItem(title: 'Profile', onTap: () {}),
                _SettingsItem(title: 'Password & Security', onTap: () {}),
              ],
            ),

            // Notifications section
            _buildSection(
              context,
              title: 'NOTIFICATIONS',
              items: [
                _SettingsItem(title: 'Alert Preferences', onTap: () {}),
                _SettingsItem(title: 'Quiet Hours', onTap: () {}),
              ],
            ),

            // Devices section
            _buildSection(
              context,
              title: 'DEVICES',
              items: [
                _SettingsItem(title: 'Manage Cameras', onTap: () {}),
                _SettingsItem(title: 'Network Settings', onTap: () {}),
              ],
            ),

            // Billing section
            _buildSection(
              context,
              title: 'BILLING',
              items: [
                _SettingsItem(title: 'Payment Method', onTap: () {}),
                _SettingsItem(title: 'Subscription', onTap: () {}),
              ],
            ),

            // System section
            _buildSection(
              context,
              title: 'SYSTEM',
              items: [
                _SettingsItem(title: 'System Health', onTap: () {}),
                _SettingsItem(title: 'Storage', onTap: () {}),
                _SettingsItem(title: 'About', onTap: () {}),
              ],
            ),

            // Sign out
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.xl,
                  AppSpacing.lg,
                  AppSpacing.xl,
                ),
                child: Center(
                  child: TextButton(
                    onPressed: () {
                      // Mock action - sign out
                    },
                    child: Text(
                      'Sign Out',
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.xl),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<_SettingsItem> items,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SliverMainAxisGroup(
      slivers: [
        // Section header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.xs,
            ),
            child: Text(
              title,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),

        // Section items
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final item = items[index];
              final isLast = index == items.length - 1;
              return _buildSettingsRow(context, item, isDark, isLast);
            },
            childCount: items.length,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsRow(
    BuildContext context,
    _SettingsItem item,
    bool isDark,
    bool isLast,
  ) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: item.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isLast
                  ? Colors.transparent
                  : (isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.06)),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                item.title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsItem {
  final String title;
  final VoidCallback onTap;

  _SettingsItem({
    required this.title,
    required this.onTap,
  });
}
