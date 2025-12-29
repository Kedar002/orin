import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/widgets/clean_card.dart';
import '../../core/widgets/video_thumbnail.dart';
import '../../core/widgets/mono_live_badge.dart';
import '../../core/widgets/mono_status_dot.dart';
import '../../core/theme/app_colors.dart';
import '../../models/guard_model.dart';
import '../../repositories/guards_repository.dart';
import '../cameras/camera_viewer_screen.dart';
import '../cameras/cameras_grid_screen.dart';
import '../guards/guard_detail_screen.dart';

/// Command Center - Camera-first design (Apple Home style)
/// Cameras are the hero - status shown visually on cards
class CommandCenterScreen extends StatefulWidget {
  const CommandCenterScreen({super.key});

  @override
  State<CommandCenterScreen> createState() => _CommandCenterScreenState();
}

class _CommandCenterScreenState extends State<CommandCenterScreen> {
  final GuardsRepository _guardsRepository = GuardsRepository();
  List<Guard> _activeGuards = [];

  @override
  void initState() {
    super.initState();
    _loadActiveGuards();
  }

  void _loadActiveGuards() {
    setState(() {
      _activeGuards = _guardsRepository.getActive();
    });
  }

  String _getStreamUrlForCamera(String cameraId) {
    final number = int.tryParse(cameraId.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    final demoStreams = [
      'https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_adv_example_hevc/master.m3u8',
      'https://cph-p2p-msl.akamaized.net/hls/live/2000341/test/master.m3u8',
      'https://moctobpltc-i.akamaihd.net/hls/live/571329/eight/playlist.m3u8',
      'https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8',
      'https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.mp4/.m3u8',
      'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
    ];

    return demoStreams[number % demoStreams.length];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cameras = _getCameras();
    final onlineCameras = cameras.where((c) => c['active'] as bool).length;
    final totalCameras = cameras.length;
    final activeGuardsCount = _activeGuards.length;
    final hasAlerts = _getRecentEvents().isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header with subtitle stats
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
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '$onlineCameras/$totalCameras Cameras  ·  $activeGuardsCount on duty',
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

            // Cameras Section Header with View All
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'CAMERAS',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                        letterSpacing: 0.5,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const CamerasGridScreen(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(50, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('View All'),
                    ),
                  ],
                ),
              ),
            ),

            // Camera Grid - THE HERO CONTENT
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return _buildCameraCard(context, cameras[index]);
                  },
                  childCount: cameras.length,
                ),
              ),
            ),

            // Guards Section - Only show if there are active guards
            if (_activeGuards.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: Text(
                    'ON DUTY',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                      letterSpacing: 0.5,
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
                        child: _buildGuardRow(context, _activeGuards[index]),
                      );
                    },
                    childCount: _activeGuards.length,
                  ),
                ),
              ),
            ],

            // Recent Activity - Only if there are alerts
            if (hasAlerts) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: Text(
                    'RECENT ACTIVITY',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final events = _getRecentEvents();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _buildEventRow(context, events[index]),
                      );
                    },
                    childCount: _getRecentEvents().length,
                  ),
                ),
              ),
            ],

            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraCard(BuildContext context, Map<String, dynamic> camera) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isActive = camera['active'] as bool;

    return CleanCard(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CameraViewerScreen(
              cameraId: camera['id'],
              cameraName: camera['name'],
              location: 'Main Building',
              streamUrl: _getStreamUrlForCamera(camera['id']),
            ),
          ),
        );
      },
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Camera Preview Area - LARGER
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Stack(
                children: [
                  // Video Thumbnail
                  if (isActive)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: VideoThumbnail(
                        streamUrl: _getStreamUrlForCamera(camera['id']),
                      ),
                    )
                  else
                    // Placeholder for offline cameras
                    Center(
                      child: Icon(
                        CupertinoIcons.videocam,
                        size: 48,
                        color: isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.black.withOpacity(0.08),
                      ),
                    ),

                  // Monochrome LIVE badge
                  if (isActive)
                    const Positioned(
                      top: 8,
                      left: 8,
                      child: MonoLiveBadge(),
                    ),

                  // Offline overlay
                  if (!isActive)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.videocam,
                                color: Colors.white.withOpacity(0.7),
                                size: 32,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Offline',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Camera Info - Compact
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  camera['name'] as String,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  camera['location'] as String,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuardRow(BuildContext context, Guard guard) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return CleanCard(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => GuardDetailScreen(
              guardId: guard.id,
              guardName: guard.name,
              guardSpace: guard.type.displayName,
              guardDescription: guard.description,
              isActive: guard.isActive,
            ),
          ),
        ).then((_) {
          // Reload guards when returning from detail screen
          _loadActiveGuards();
        });
      },
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              guard.type.icon,
              size: 18,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Guard info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  guard.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Row(
                  children: [
                    Text(
                      guard.type.displayName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                        fontSize: 12,
                      ),
                    ),
                    if (guard.catchesThisWeek > 0) ...[
                      Text(
                        '  •  ${guard.catchesThisWeek} this week',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Monochrome status dot
          MonoStatusDot(
            type: guard.isActive ? MonoStatusType.active : MonoStatusType.inactive,
            size: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildEventRow(BuildContext context, Map<String, dynamic> event) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return CleanCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
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
              CupertinoIcons.bell,
              size: 20,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title'] as String,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  event['subtitle'] as String,
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
    );
  }

  List<Map<String, dynamic>> _getCameras() {
    return [
      {'id': 'CAM-01', 'name': 'Main Entrance', 'location': 'Building A', 'active': true},
      {'id': 'CAM-02', 'name': 'Parking Lot', 'location': 'Outdoor', 'active': true},
      {'id': 'CAM-03', 'name': 'Lobby', 'location': 'Building A', 'active': true},
      {'id': 'CAM-04', 'name': 'Server Room', 'location': 'Building B', 'active': false},
      {'id': 'CAM-05', 'name': 'Cafeteria', 'location': 'Building A', 'active': true},
      {'id': 'CAM-06', 'name': 'Warehouse', 'location': 'Building C', 'active': true},
    ];
  }

  List<Map<String, dynamic>> _getRecentEvents() {
    return [
      {
        'title': 'Motion detected',
        'subtitle': 'CAM-05 • Parking Lot',
        'time': '2m ago',
      },
      {
        'title': 'Camera offline',
        'subtitle': 'CAM-04 • Server Room',
        'time': '15m ago',
      },
    ];
  }
}
