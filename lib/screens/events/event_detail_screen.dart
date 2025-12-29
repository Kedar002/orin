import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';

/// Event detail screen
/// Video placeholder, explanation text, and action buttons
class EventDetailScreen extends StatelessWidget {
  final String eventTitle;
  final String eventSpace;
  final String eventTime;
  final String eventGuard;
  final String eventDescription;

  const EventDetailScreen({
    super.key,
    required this.eventTitle,
    required this.eventSpace,
    required this.eventTime,
    required this.eventGuard,
    required this.eventDescription,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Video placeholder
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.play_circle,
                      size: 64,
                      color: isDark
                          ? AppColors.textTertiaryDark
                          : AppColors.textTertiaryLight,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Video Clip',
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
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                // Event title
                Text(
                  eventTitle,
                  style: theme.textTheme.displaySmall,
                ),

                const SizedBox(height: AppSpacing.xs),

                // Guard name
                Text(
                  eventGuard,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Space and time
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.location,
                      size: 16,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      eventSpace,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Icon(
                      CupertinoIcons.clock,
                      size: 16,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      eventTime,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

                // Description
                Text(
                  'What happened',
                  style: theme.textTheme.headlineMedium,
                ),

                const SizedBox(height: AppSpacing.sm),

                Text(
                  eventDescription,
                  style: theme.textTheme.bodyLarge,
                ),

                const SizedBox(height: AppSpacing.xl),

                // Action buttons
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Mock action - download clip
                    },
                    icon: const Icon(CupertinoIcons.arrow_down_circle),
                    label: const Text('Save Clip'),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () {
                      // Mock action - share
                    },
                    icon: const Icon(CupertinoIcons.share),
                    label: const Text('Share'),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () {
                      // Mock action - delete
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(CupertinoIcons.trash),
                    label: const Text('Delete Event'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
