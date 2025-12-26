import 'package:flutter/material.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/widgets/status_card.dart';

/// Home screen - Command Center
/// Status cards with calm messaging
/// No camera grids, no charts
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Command Center',
                      style: theme.textTheme.displayLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Everything you need to know, right now',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Status cards
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const StatusCard(
                    title: 'All Spaces',
                    message: 'Everything is normal',
                    isGood: true,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const StatusCard(
                    title: 'Active Guards',
                    message: '3 guards watching',
                    isGood: true,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const StatusCard(
                    title: 'Recent Activity',
                    message: 'No alerts in the last 24 hours',
                    isGood: true,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const StatusCard(
                    title: 'System Status',
                    message: 'All cameras online',
                    isGood: true,
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
