import 'package:flutter/material.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';

/// Settings screen
/// Clean list layout with sections
/// Account, Notifications, Devices, Billing, System Health
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                child: Text(
                  'Settings',
                  style: theme.textTheme.displayLarge,
                ),
              ),
            ),

            // Settings list
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // Account section
                  _buildSection(
                    context,
                    title: 'Account',
                    items: [
                      _SettingsItem(
                        icon: Icons.person_outline,
                        title: 'Profile',
                        onTap: () {},
                      ),
                      _SettingsItem(
                        icon: Icons.lock_outline,
                        title: 'Password & Security',
                        onTap: () {},
                      ),
                    ],
                  ),

                  // Notifications section
                  _buildSection(
                    context,
                    title: 'Notifications',
                    items: [
                      _SettingsItem(
                        icon: Icons.notifications_outlined,
                        title: 'Alert Preferences',
                        onTap: () {},
                      ),
                      _SettingsItem(
                        icon: Icons.schedule_outlined,
                        title: 'Quiet Hours',
                        onTap: () {},
                      ),
                    ],
                  ),

                  // Devices section
                  _buildSection(
                    context,
                    title: 'Devices',
                    items: [
                      _SettingsItem(
                        icon: Icons.videocam_outlined,
                        title: 'Manage Cameras',
                        onTap: () {},
                      ),
                      _SettingsItem(
                        icon: Icons.wifi_outlined,
                        title: 'Network Settings',
                        onTap: () {},
                      ),
                    ],
                  ),

                  // Billing section
                  _buildSection(
                    context,
                    title: 'Billing',
                    items: [
                      _SettingsItem(
                        icon: Icons.credit_card_outlined,
                        title: 'Payment Method',
                        onTap: () {},
                      ),
                      _SettingsItem(
                        icon: Icons.receipt_outlined,
                        title: 'Subscription',
                        onTap: () {},
                      ),
                    ],
                  ),

                  // System Health section
                  _buildSection(
                    context,
                    title: 'System',
                    items: [
                      _SettingsItem(
                        icon: Icons.health_and_safety_outlined,
                        title: 'System Health',
                        onTap: () {},
                      ),
                      _SettingsItem(
                        icon: Icons.storage_outlined,
                        title: 'Storage',
                        onTap: () {},
                      ),
                      _SettingsItem(
                        icon: Icons.info_outline,
                        title: 'About',
                        onTap: () {},
                      ),
                    ],
                  ),

                  // Sign out
                  const SizedBox(height: AppSpacing.lg),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          // Mock action - sign out
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.error,
                        ),
                        child: const Text('Sign Out'),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: Text(
            title,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ),

        // Section items
        Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0)
                  Padding(
                    padding: const EdgeInsets.only(left: 56),
                    child: Divider(
                      height: 1,
                      color: isDark
                          ? AppColors.dividerDark
                          : AppColors.dividerLight,
                    ),
                  ),
                _buildSettingsItem(context, items[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(BuildContext context, _SettingsItem item) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Icon(
              item.icon,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                item.title,
                style: theme.textTheme.bodyLarge,
              ),
            ),
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
  }
}

class _SettingsItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  _SettingsItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}
