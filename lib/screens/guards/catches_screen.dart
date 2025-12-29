import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/widgets/clean_card.dart';
import '../../core/theme/app_colors.dart';
import '../../models/catch_model.dart';
import '../../repositories/catches_repository.dart';

/// Recent Catches Screen
/// Shows detailed list of all catches made by a guard
/// Pure Apple design - clean, minimal, focused on content
class CatchesScreen extends StatefulWidget {
  final String guardId;
  final String guardName;

  const CatchesScreen({
    super.key,
    required this.guardId,
    required this.guardName,
  });

  @override
  State<CatchesScreen> createState() => _CatchesScreenState();
}

class _CatchesScreenState extends State<CatchesScreen> {
  final CatchesRepository _repository = CatchesRepository();
  List<Catch> _catches = [];

  @override
  void initState() {
    super.initState();
    _loadCatches();
  }

  void _loadCatches() {
    setState(() {
      _catches = _repository.getByGuardId(widget.guardId);
    });
  }

  String _getCameraName(String cameraId) {
    // Map camera IDs to names - in production, this would come from a camera repository
    switch (cameraId) {
      case 'CAM-001':
        return 'Main Entrance';
      case 'CAM-002':
        return 'Backyard Pool';
      case 'CAM-003':
        return 'Front Door';
      case 'CAM-004':
        return 'Garage';
      case 'CAM-005':
        return 'Side Entrance';
      default:
        return 'Camera ${cameraId.replaceAll('CAM-', '')}';
    }
  }

  IconData _getIconForType(CatchType type) {
    switch (type) {
      case CatchType.delivery:
        return Icons.inventory_2_outlined;
      case CatchType.person:
        return Icons.person_outline;
      case CatchType.vehicle:
        return Icons.directions_car_outlined;
      case CatchType.pet:
        return Icons.pets_outlined;
      case CatchType.motion:
        return Icons.motion_photos_on_outlined;
      case CatchType.other:
        return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Group catches by date group
    final todayCatches = _catches.where((c) => c.dateGroup == 'Today').toList();
    final yesterdayCatches = _catches.where((c) => c.dateGroup == 'Yesterday').toList();
    final thisWeekCatches = _catches.where((c) => c.dateGroup == 'This Week').toList();
    final earlierCatches = _catches.where((c) => c.dateGroup == 'Earlier').toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Recent Catches'),
        elevation: 0,
      ),
      body: _catches.isEmpty
          ? _buildEmptyState(context, isDark)
          : SafeArea(
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
                            '${_catches.length} catch${_catches.length == 1 ? '' : 'es'}',
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
                    _buildSectionHeader('TODAY', theme, isDark),
                    _buildCatchesList(todayCatches, isDark),
                  ],

                  // Yesterday section
                  if (yesterdayCatches.isNotEmpty) ...[
                    _buildSectionHeader('YESTERDAY', theme, isDark),
                    _buildCatchesList(yesterdayCatches, isDark),
                  ],

                  // This week section
                  if (thisWeekCatches.isNotEmpty) ...[
                    _buildSectionHeader('THIS WEEK', theme, isDark),
                    _buildCatchesList(thisWeekCatches, isDark),
                  ],

                  // Earlier section
                  if (earlierCatches.isNotEmpty) ...[
                    _buildSectionHeader('EARLIER', theme, isDark),
                    _buildCatchesList(earlierCatches, isDark),
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

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: isDark
                ? AppColors.textTertiaryDark
                : AppColors.textTertiaryLight,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No catches yet',
            style: theme.textTheme.titleLarge?.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Events will appear here',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme, bool isDark) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.sm,
        ),
        child: Text(
          title,
          style: theme.textTheme.labelSmall?.copyWith(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
            letterSpacing: 0.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildCatchesList(List<Catch> catches, bool isDark) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _buildCatchCard(context, catches[index], isDark),
            );
          },
          childCount: catches.length,
        ),
      ),
    );
  }

  Widget _buildCatchCard(BuildContext context, Catch catch_, bool isDark) {
    final theme = Theme.of(context);

    return CleanCard(
      onTap: () {
        // TODO: Could navigate to camera viewer or event detail
        // Could also show save/star and notes functionality here
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
              _getIconForType(catch_.type),
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
                // Title with saved indicator
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        catch_.title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (catch_.isSaved) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.star,
                        size: 16,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ],
                  ],
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
                      _getCameraName(catch_.cameraId),
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
                      catch_.formattedTime,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),

                // User note if present
                if (catch_.userNote != null && catch_.userNote!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    catch_.userNote!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppColors.textTertiaryDark
                          : AppColors.textTertiaryLight,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
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
