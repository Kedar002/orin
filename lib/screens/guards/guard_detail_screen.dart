import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/widgets/clean_card.dart';
import '../../core/widgets/mono_status_dot.dart';
import '../../core/theme/app_colors.dart';
import '../../models/guard_model.dart';
import '../../models/catch_model.dart';
import '../../repositories/guards_repository.dart';
import '../../repositories/catches_repository.dart';
import '../cameras/camera_viewer_screen.dart';
import '../events/event_detail_screen.dart';
import 'catches_screen.dart';
import 'edit_guard_screen.dart';

/// Guard detail screen
/// Think like Steve Jobs: A Guard is your AI assistant for security.
/// You chat with it. It watches cameras. It tells you what matters.
/// This is a conversation, not a settings page.
class GuardDetailScreen extends StatefulWidget {
  final String guardId;
  final String guardName;
  final String guardSpace;
  final String guardDescription;
  final bool isActive;

  const GuardDetailScreen({
    super.key,
    required this.guardId,
    required this.guardName,
    required this.guardSpace,
    required this.guardDescription,
    required this.isActive,
  });

  @override
  State<GuardDetailScreen> createState() => _GuardDetailScreenState();
}

class _GuardDetailScreenState extends State<GuardDetailScreen> {
  final GuardsRepository _guardsRepository = GuardsRepository();
  final CatchesRepository _catchesRepository = CatchesRepository();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late Guard _guard;
  List<Catch> _recentCatches = [];

  @override
  void initState() {
    super.initState();
    _loadGuardData();
  }

  void _loadGuardData() {
    final guard = _guardsRepository.getById(widget.guardId);
    if (guard != null) {
      setState(() {
        _guard = guard;
        _recentCatches = _catchesRepository.getByGuardId(widget.guardId);
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _toggleActive() async {
    await _guardsRepository.toggleActive(widget.guardId);
    _loadGuardData();
  }

  // Get stream URL for camera - mock data, in production this comes from backend
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

  // Mock cameras where this guard is watching - in production, load from camera repository
  List<Map<String, dynamic>> _getCameras() {
    return _guard.cameraIds.map((id) {
      // Map camera IDs to names - in production, this would come from a camera repository
      String name;
      switch (id) {
        case 'CAM-001':
          name = 'Main Entrance';
          break;
        case 'CAM-002':
          name = 'Backyard Pool';
          break;
        case 'CAM-003':
          name = 'Front Door';
          break;
        case 'CAM-004':
          name = 'Garage';
          break;
        case 'CAM-005':
          name = 'Side Entrance';
          break;
        default:
          name = 'Camera ${id.replaceAll('CAM-', '')}';
      }

      return {
        'name': name,
        'id': id,
        'status': 'online',
      };
    }).toList();
  }

  // Mock chat messages
  List<Map<String, dynamic>> _getMessages() {
    return [
      {
        'text': 'Hi! I\'m watching ${_guard.cameraIds.length} camera${_guard.cameraIds.length == 1 ? '' : 's'} for ${_guard.type.displayName.toLowerCase()}. I\'ll let you know when I see something.',
        'isGuard': true,
        'time': '10:30 AM',
      },
      {
        'text': 'What did you catch today?',
        'isGuard': false,
        'time': '2:15 PM',
      },
      {
        'text': 'I detected ${_guard.catchesThisWeek} event${_guard.catchesThisWeek == 1 ? '' : 's'} this week. ${_recentCatches.isNotEmpty ? 'The most recent was "${_recentCatches.first.title}".' : ''}',
        'isGuard': true,
        'time': '2:15 PM',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final messages = _getMessages();

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_guard.name),
            Row(
              children: [
                MonoStatusDot(
                  type: _guard.isActive ? MonoStatusType.active : MonoStatusType.warning,
                  size: 6,
                ),
                const SizedBox(width: 4),
                Text(
                  _guard.statusText,
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
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.info_circle),
            onPressed: () {
              _showGuardInfo(context);
            },
          ),
        ],
        elevation: 0,
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return _buildMessageBubble(
                  context,
                  message['text'] as String,
                  message['isGuard'] as bool,
                  isDark,
                );
              },
            ),
          ),

          // Message input
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.06),
                  width: 0.5,
                ),
              ),
            ),
            padding: EdgeInsets.only(
              left: AppSpacing.md,
              right: AppSpacing.md,
              top: AppSpacing.sm,
              bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.sm,
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Message',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.black.withOpacity(0.05),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        isDense: true,
                      ),
                      maxLines: null,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.mono100Dark : AppColors.mono0,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        CupertinoIcons.arrow_up,
                        color: isDark ? AppColors.mono0Dark : AppColors.mono100,
                      ),
                      onPressed: () {
                        // Send message logic
                        _messageController.clear();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showGuardInfo(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cameras = _getCameras();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              const SizedBox(height: AppSpacing.md),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.textTertiaryDark
                      : AppColors.textTertiaryLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  children: [
                    // Guard name and status
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _guard.name,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(CupertinoIcons.pencil),
                          onPressed: () async {
                            Navigator.pop(context); // Close the info sheet first
                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => EditGuardScreen(guard: _guard),
                              ),
                            );

                            // Reload guard data if changes were made
                            if (result == true) {
                              _loadGuardData();
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        MonoStatusDot(
                          type: _guard.isActive ? MonoStatusType.active : MonoStatusType.warning,
                          size: 8,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          _guard.statusText,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                        const Spacer(),
                        Switch(
                          value: _guard.isActive,
                          onChanged: (value) async {
                            await _toggleActive();
                            if (mounted) {
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Statistics
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            context,
                            '${_guard.catchesThisWeek}',
                            'This week',
                            isDark,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            '${_guard.totalCatches}',
                            'All time',
                            isDark,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Cameras section
                    Text(
                      'Cameras',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (cameras.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                        child: Text(
                          'No cameras assigned',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: cameras.length,
                          itemBuilder: (context, index) {
                            final camera = cameras[index];
                            return Padding(
                              padding: EdgeInsets.only(
                                right: index < cameras.length - 1 ? AppSpacing.sm : 0,
                              ),
                              child: _buildCameraCard(context, camera, isDark),
                            );
                          },
                        ),
                      ),

                    const SizedBox(height: AppSpacing.xl),

                    // Recent catches with View All
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent catches',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_recentCatches.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => CatchesScreen(
                                    guardId: _guard.id,
                                    guardName: _guard.name,
                                  ),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                Text(
                                  'View All',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  CupertinoIcons.chevron_right,
                                  size: 16,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (_recentCatches.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                        child: Text(
                          'No catches yet',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      )
                    else
                      ..._recentCatches.take(5).map((catch_) => _buildCatchRow(
                            context,
                            catch_,
                            isDark,
                            catch_ == _recentCatches.take(5).last,
                          )),

                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String value, String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCatchRow(BuildContext context, Catch catch_, bool isDark, bool isLast) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EventDetailScreen(
              eventTitle: catch_.title,
              eventSpace: catch_.cameraName,
              eventTime: catch_.formattedTime,
              eventGuard: _guard.name,
              eventDescription: catch_.description,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
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
            Icon(
              _getCatchIcon(catch_.type),
              size: 20,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                catch_.title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            Text(
              catch_.relativeTime,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Icon(
              CupertinoIcons.chevron_right,
              size: 16,
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCatchIcon(CatchType type) {
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

  Widget _buildCameraCard(BuildContext context, Map<String, dynamic> camera, bool isDark) {
    final isOnline = camera['status'] == 'online';
    final cameraId = camera['id'] as String;
    final cameraName = camera['name'] as String;

    return CleanCard(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CameraViewerScreen(
              cameraId: cameraId,
              cameraName: cameraName,
              location: _guard.name, // Show guard name as location
              streamUrl: _getStreamUrlForCamera(cameraId),
            ),
          ),
        );
      },
      padding: EdgeInsets.zero,
      enablePressAnimation: true,
      child: SizedBox(
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Camera preview
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.black.withOpacity(0.03),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        CupertinoIcons.videocam,
                        size: 32,
                        color: isDark
                            ? Colors.white.withOpacity(0.3)
                            : Colors.black.withOpacity(0.2),
                      ),
                    ),
                    if (isOnline)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: MonoStatusDot(
                          type: MonoStatusType.active,
                          size: 8,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Camera name
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Text(
                camera['name'] as String,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, String text, bool isGuard, bool isDark) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment: isGuard ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (isGuard) ...[
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm + 2,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                text,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ] else ...[
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm + 2,
              ),
              decoration: BoxDecoration(
                color: isDark ? AppColors.mono100Dark : AppColors.mono0,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.mono0Dark : AppColors.mono100,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
