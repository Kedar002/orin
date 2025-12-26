import 'package:flutter/material.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/widgets/clean_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/theme/app_colors.dart';
import 'event_detail_screen.dart';

/// Events screen - Timeline of important events
/// Vertical timeline with event cards
/// Only meaningful alerts, no clutter
class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Mock events data
    final events = [
      {
        'title': 'Package delivered',
        'space': 'Front Door',
        'time': '2 hours ago',
        'description': 'Package Watch detected a delivery',
      },
      {
        'title': 'Motion detected',
        'space': 'Backyard',
        'time': 'Yesterday, 3:45 PM',
        'description': 'Pool Safety noticed movement near the pool',
      },
      {
        'title': 'All clear',
        'space': 'All Spaces',
        'time': 'Yesterday, 8:00 AM',
        'description': 'Night Watch completed with no alerts',
      },
    ];

    if (events.isEmpty) {
      return const Scaffold(
        body: EmptyState(
          title: 'No events yet',
          subtitle: 'When your Guards detect something important, you\'ll see it here',
        ),
      );
    }

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
                      'Events',
                      style: theme.textTheme.displayLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Important moments from your Guards',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Event cards
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final event = events[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: CleanCard(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => EventDetailScreen(
                                eventTitle: event['title'] as String,
                                eventSpace: event['space'] as String,
                                eventTime: event['time'] as String,
                                eventDescription: event['description'] as String,
                              ),
                            ),
                          );
                        },
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Thumbnail placeholder
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
                                Icons.notifications_outlined,
                                color: isDark
                                    ? AppColors.textTertiaryDark
                                    : AppColors.textTertiaryLight,
                              ),
                            ),

                            const SizedBox(width: AppSpacing.md),

                            // Event info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event['title'] as String,
                                    style: theme.textTheme.headlineMedium,
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    event['space'] as String,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondaryLight,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    event['time'] as String,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: isDark
                                          ? AppColors.textTertiaryDark
                                          : AppColors.textTertiaryLight,
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
                  childCount: events.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
