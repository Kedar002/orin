import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/theme/app_colors.dart';
import 'event_detail_screen.dart';

/// Events screen - Timeline of important events
/// Clean, simple list. No decoration, just content.
/// Steve Jobs would approve: minimal, focused, functional.
class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  List<Map<String, dynamic>> _getAllEvents() {
    return [
      {
        'title': 'Package delivered',
        'space': 'Front Door',
        'time': '2 hours ago',
        'guard': 'Package Watch',
        'description': 'Package Watch detected a delivery',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      },
      {
        'title': 'Person detected',
        'space': 'Main Entrance',
        'time': '4 hours ago',
        'guard': 'Entrance Guard',
        'description': 'Entrance Guard detected a person approaching',
        'timestamp': DateTime.now().subtract(const Duration(hours: 4)),
      },
      {
        'title': 'Motion detected',
        'space': 'Backyard',
        'time': 'Yesterday, 3:45 PM',
        'guard': 'Pool Safety',
        'description': 'Pool Safety noticed movement near the pool',
        'timestamp': DateTime.now().subtract(const Duration(days: 1, hours: 4)),
      },
      {
        'title': 'All clear',
        'space': 'All Spaces',
        'time': 'Yesterday, 8:00 AM',
        'guard': 'Night Watch',
        'description': 'Night Watch completed with no alerts',
        'timestamp': DateTime.now().subtract(const Duration(days: 1, hours: 16)),
      },
      {
        'title': 'Vehicle detected',
        'space': 'Driveway',
        'time': '3 days ago',
        'guard': 'Driveway Guard',
        'description': 'Driveway Guard noticed a vehicle',
        'timestamp': DateTime.now().subtract(const Duration(days: 3)),
      },
    ];
  }

  Map<String, List<Map<String, dynamic>>> _groupEventsByTime() {
    final events = _getAllEvents();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final thisWeek = today.subtract(const Duration(days: 7));

    Map<String, List<Map<String, dynamic>>> grouped = {
      'Today': [],
      'Yesterday': [],
      'This Week': [],
      'Earlier': [],
    };

    for (var event in events) {
      final timestamp = event['timestamp'] as DateTime;
      final eventDay = DateTime(timestamp.year, timestamp.month, timestamp.day);

      if (eventDay == today) {
        grouped['Today']!.add(event);
      } else if (eventDay == yesterday) {
        grouped['Yesterday']!.add(event);
      } else if (timestamp.isAfter(thisWeek)) {
        grouped['This Week']!.add(event);
      } else {
        grouped['Earlier']!.add(event);
      }
    }

    // Remove empty sections
    grouped.removeWhere((key, value) => value.isEmpty);
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final groupedEvents = _groupEventsByTime();

    if (_getAllEvents().isEmpty) {
      return const Scaffold(
        body: EmptyState(
          title: 'No events yet',
          subtitle: 'When your Guards detect something important, you\'ll see it here',
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Large title - simple and clean
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.xl,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: Text(
                  'Events',
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Event sections grouped by time
            ...groupedEvents.entries.map((entry) {
              final sectionTitle = entry.key;
              final sectionEvents = entry.value;

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
                        sectionTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  // Section events - clean list
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final event = sectionEvents[index];
                        final isLast = index == sectionEvents.length - 1;

                        return _buildEventRow(context, event, isDark, isLast);
                      },
                      childCount: sectionEvents.length,
                    ),
                  ),
                ],
              );
            }).toList(),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.xxxl),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventRow(BuildContext context, Map<String, dynamic> event, bool isDark, bool isLast) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EventDetailScreen(
              eventTitle: event['title'] as String,
              eventSpace: event['space'] as String,
              eventTime: event['time'] as String,
              eventGuard: event['guard'] as String,
              eventDescription: event['description'] as String,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md + 2,
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
            // Small, subtle thumbnail
            Container(
              width: 60,
              height: 45,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.06)
                    : Colors.black.withOpacity(0.04),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                CupertinoIcons.play_circle,
                size: 24,
                color: isDark
                    ? Colors.white.withOpacity(0.4)
                    : Colors.black.withOpacity(0.3),
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            // Event info - typography does the work
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['title'] as String,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    event['guard'] as String,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w400,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '${event['space']} • ${event['time']}',
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

            // Simple chevron
            Icon(
              CupertinoIcons.chevron_right,
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
