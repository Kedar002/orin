import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/clean_card.dart';
import '../../core/widgets/video_thumbnail.dart';

/// Apple-style Camera Viewer
/// Content-first: video is the hero, everything else is secondary
class CameraViewerScreen extends StatefulWidget {
  final String cameraId;
  final String cameraName;
  final String location;
  final String? streamUrl;

  const CameraViewerScreen({
    super.key,
    required this.cameraId,
    required this.cameraName,
    required this.location,
    this.streamUrl,
  });

  @override
  State<CameraViewerScreen> createState() => _CameraViewerScreenState();
}

class _CameraViewerScreenState extends State<CameraViewerScreen> {
  bool _showControls = true;
  bool _isPlaying = true;
  double _progress = 0.0;
  String _selectedTab = 'other';
  final TextEditingController _chatController = TextEditingController();
  final List<Map<String, dynamic>> _chatMessages = [
    {
      'isUser': false,
      'message': 'Hello! I can help you analyze this camera feed. What would you like to know?',
      'time': '10:30 AM',
    },
  ];
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    String streamUrl = widget.streamUrl ?? _getStreamUrlForCamera(widget.cameraId);

    _videoController = VideoPlayerController.networkUrl(Uri.parse(streamUrl));
    await _videoController.initialize();
    _videoController.setLooping(true);
    _videoController.play();

    _videoController.addListener(() {
      if (_videoController.value.isInitialized) {
        setState(() {
          _progress = _videoController.value.position.inMilliseconds /
              _videoController.value.duration.inMilliseconds;
          _isPlaying = _videoController.value.isPlaying;
        });
      }
    });

    setState(() {
      _isVideoInitialized = true;
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
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _chatController.dispose();
    _videoController.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_videoController.value.isPlaying) {
        _videoController.pause();
      } else {
        _videoController.play();
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Video - THE HERO, always full width
            _buildVideoPlayer(isDark),

            // Content below - clean, minimal
            Expanded(
              child: Container(
                color: theme.scaffoldBackgroundColor,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCameraInfo(theme, isDark),
                      _buildTabs(theme, isDark),
                      _buildTabContent(theme, isDark),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer(bool isDark) {
    return GestureDetector(
      onTap: _toggleControls,
      child: AspectRatio(
        aspectRatio: _isVideoInitialized ? _videoController.value.aspectRatio : 16 / 9,
        child: Container(
          color: Colors.black,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Video
              _isVideoInitialized
                  ? VideoPlayer(_videoController)
                  : const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),

              // Subtle gradient only when controls visible
              if (_showControls)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.4),
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withOpacity(0.4),
                      ],
                      stops: const [0.0, 0.2, 0.8, 1.0],
                    ),
                  ),
                ),

              // Top bar - minimal
              if (_showControls)
                Positioned(
                  top: 8,
                  left: 8,
                  right: 8,
                  child: Row(
                    children: [
                      _buildControlButton(Icons.chevron_left, () => Navigator.pop(context)),
                      const Spacer(),
                      _buildControlButton(Icons.more_horiz, () {}),
                    ],
                  ),
                ),

              // Center play/pause - minimal
              if (_showControls)
                Center(
                  child: _buildControlButton(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    _togglePlayPause,
                    size: 56,
                  ),
                ),

              // Progress bar at bottom - minimal
              if (_showControls)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildProgressBar(),
                ),

              // LIVE badge - subtle, always visible
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.success.withOpacity(0.5),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton(IconData icon, VoidCallback onTap, {double size = 32}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: size * 0.6,
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final position = _isVideoInitialized ? _videoController.value.position : Duration.zero;
    final duration = _isVideoInitialized ? _videoController.value.duration : Duration.zero;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          Text(
            _formatDuration(position),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 3,
                activeTrackColor: Colors.white,
                inactiveTrackColor: Colors.white.withOpacity(0.3),
                thumbColor: Colors.white,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              ),
              child: Slider(
                value: _progress.clamp(0.0, 1.0),
                onChanged: (value) {
                  setState(() {
                    _progress = value;
                    final newPosition = duration * value;
                    _videoController.seekTo(newPosition);
                  });
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _formatDuration(duration),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraInfo(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.cameraName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.cameraId}  ·  ${widget.location}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(ThemeData theme, bool isDark) {
    final tabs = [
      {'id': 'other', 'label': 'Other', 'icon': Icons.video_library_outlined},
      {'id': 'info', 'label': 'Info', 'icon': Icons.info_outline},
      {'id': 'summarize', 'label': 'Summarize', 'icon': Icons.auto_awesome},
      {'id': 'download', 'label': 'Download', 'icon': Icons.arrow_downward},
      {'id': 'snapshot', 'label': 'Snapshot', 'icon': Icons.camera_alt_outlined},
      {'id': 'share', 'label': 'Share', 'icon': Icons.square_outlined},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: tabs.map((tab) {
          final isSelected = _selectedTab == tab['id'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = tab['id'] as String),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.08))
                      : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tab['icon'] as IconData,
                      size: 18,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      tab['label'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: () {
        switch (_selectedTab) {
          case 'other':
            return _buildOtherCameras(theme, isDark);
          case 'info':
            return _buildInfo(theme, isDark);
          case 'summarize':
            return _buildSummarize(theme, isDark);
          case 'download':
            return _buildDownload(theme, isDark);
          case 'snapshot':
            return _buildSnapshot(theme, isDark);
          case 'share':
            return _buildShare(theme, isDark);
          default:
            return _buildOtherCameras(theme, isDark);
        }
      }(),
    );
  }

  Widget _buildOtherCameras(ThemeData theme, bool isDark) {
    final cameras = [
      {'id': 'CAM-02', 'name': 'Parking Lot A', 'location': 'Level 1'},
      {'id': 'CAM-03', 'name': 'Main Hallway', 'location': 'Floor 2'},
      {'id': 'CAM-04', 'name': 'Loading Bay', 'location': 'Warehouse'},
      {'id': 'CAM-05', 'name': 'Office Floor 2', 'location': 'East Wing'},
      {'id': 'CAM-06', 'name': 'Storage Room', 'location': 'Basement'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            'OTHER CAMERAS',
            style: theme.textTheme.labelSmall?.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...cameras.map((camera) => _buildCameraRow(camera, theme, isDark)),
      ],
    );
  }

  Widget _buildInfo(ThemeData theme, bool isDark) {
    final assignedGuards = [
      {'id': 'G-01', 'name': 'Motion Guard', 'type': 'Motion Detection', 'active': true},
      {'id': 'G-02', 'name': 'Person Guard', 'type': 'Person Detection', 'active': true},
      {'id': 'G-03', 'name': 'Intrusion Guard', 'type': 'Area Protection', 'active': false},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Camera Details Card
          CleanCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Camera Details',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppSpacing.md),
                _buildInfoRow('Status', 'Online', AppColors.success, theme, isDark),
                const SizedBox(height: AppSpacing.sm),
                _buildInfoRow('Resolution', '1920x1080', null, theme, isDark),
                const SizedBox(height: AppSpacing.sm),
                _buildInfoRow('Frame Rate', '30 fps', null, theme, isDark),
                const SizedBox(height: AppSpacing.sm),
                _buildInfoRow('Uptime', '12d 5h 23m', null, theme, isDark),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Assigned Guards Section
          Text(
            'ASSIGNED GUARDS',
            style: theme.textTheme.labelSmall?.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Guards List
          ...assignedGuards.map((guard) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: CleanCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  // Guard Icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.shield_outlined,
                      size: 20,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),

                  // Guard Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          guard['name'] as String,
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${guard['id']}  ·  ${guard['type']}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status Dot
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: (guard['active'] as bool)
                          ? AppColors.success
                          : isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color? valueColor, ThemeData theme, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        Row(
          children: [
            if (valueColor != null)
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: valueColor,
                  shape: BoxShape.circle,
                ),
              ),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCameraRow(Map<String, String> camera, ThemeData theme, bool isDark) {
    return InkWell(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CameraViewerScreen(
              cameraId: camera['id']!,
              cameraName: camera['name']!,
              location: camera['location']!,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
        child: Row(
          children: [
            Container(
              width: 120,
              height: 68,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: VideoThumbnail(streamUrl: _getStreamUrlForCamera(camera['id']!)),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    camera['name']!,
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${camera['id']}  ·  ${camera['location']}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarize(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CleanCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.auto_awesome,
                        size: 18,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Activity Overview',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'No significant activity detected in the last 24 hours. Camera feed shows normal traffic patterns with 3 motion events recorded.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Divider(height: 1, color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1)),
                const SizedBox(height: AppSpacing.md),
                _buildStat('Total Events', '3', theme, isDark),
                const SizedBox(height: AppSpacing.sm),
                _buildStat('Motion Detected', '2', theme, isDark),
                const SizedBox(height: AppSpacing.sm),
                _buildStat('People Detected', '1', theme, isDark),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          CleanCard(
            onTap: _showChatSheet,
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.chat_bubble_outline,
                    size: 20,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Chat with AI', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      Text(
                        'Ask questions about this feed',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, size: 20, color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, ThemeData theme, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildDownload(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          _buildOption(Icons.video_file_outlined, 'Download Full Video', '18:45  ·  245 MB', theme, isDark),
          const SizedBox(height: AppSpacing.sm),
          _buildOption(Icons.cut_outlined, 'Download Clip', 'Select time range', theme, isDark),
          const SizedBox(height: AppSpacing.sm),
          _buildOption(Icons.high_quality_outlined, 'Download HD', '18:45  ·  680 MB', theme, isDark),
        ],
      ),
    );
  }

  Widget _buildSnapshot(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RECENT SNAPSHOTS',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.camera_alt, size: 14, color: isDark ? Colors.white70 : Colors.black87),
                    const SizedBox(width: 4),
                    Text(
                      'Capture',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: AppSpacing.sm,
              mainAxisSpacing: AppSpacing.sm,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 32,
                        color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1),
                      ),
                    ),
                    Positioned(
                      bottom: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          '${index + 1}h',
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildShare(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          _buildOption(Icons.link, 'Copy Link', 'Share video link', theme, isDark),
          const SizedBox(height: AppSpacing.sm),
          _buildOption(Icons.qr_code, 'QR Code', 'Generate QR code', theme, isDark),
          const SizedBox(height: AppSpacing.sm),
          _buildOption(Icons.mail_outline, 'Email', 'Send via email', theme, isDark),
          const SizedBox(height: AppSpacing.sm),
          _buildOption(Icons.more_horiz, 'More', 'Other options', theme, isDark),
        ],
      ),
    );
  }

  Widget _buildOption(IconData icon, String title, String subtitle, ThemeData theme, bool isDark) {
    return CleanCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: isDark ? Colors.white70 : Colors.black54),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, size: 20, color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight),
        ],
      ),
    );
  }

  void _showChatSheet() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8, bottom: 4),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.auto_awesome, size: 18, color: isDark ? Colors.white70 : Colors.black54),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('AI Assistant', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                            Text(
                              'Ask about this camera',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close, size: 18, color: isDark ? Colors.white70 : Colors.black54),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1)),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: _chatMessages.length,
                    itemBuilder: (context, index) {
                      final msg = _chatMessages[index];
                      return _buildChatMessage(msg['message'], msg['isUser'], msg['time'], theme, isDark);
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                      ),
                    ),
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: TextField(
                              controller: _chatController,
                              style: theme.textTheme.bodyMedium,
                              decoration: InputDecoration(
                                hintText: 'Message',
                                hintStyle: TextStyle(
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _sendMessage,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.arrow_upward, size: 18, color: isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatMessage(String message, bool isUser, String time, ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.auto_awesome, size: 14, color: isDark ? Colors.white70 : Colors.black54),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isUser
                        ? (isDark ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.08))
                        : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03)),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(message, style: theme.textTheme.bodyMedium?.copyWith(height: 1.4)),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person, size: 14, color: isDark ? Colors.white70 : Colors.black54),
            ),
          ],
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_chatController.text.trim().isEmpty) return;

    setState(() {
      _chatMessages.add({
        'isUser': true,
        'message': _chatController.text,
        'time': '10:${30 + _chatMessages.length} AM',
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          _chatMessages.add({
            'isUser': false,
            'message': 'I can help analyze this feed for activity patterns, detected objects, and security alerts.',
            'time': '10:${31 + _chatMessages.length} AM',
          });
        });
      });
    });

    _chatController.clear();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}';
  }
}
