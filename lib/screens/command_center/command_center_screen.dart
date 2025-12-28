import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/security_colors.dart';
import '../cameras/camera_viewer_screen.dart';
import '../cameras/cameras_grid_screen.dart';

/// Command Center - YouTube-style home feed
/// Shows recent cameras, guards, events in scrollable feed
class CommandCenterScreen extends StatefulWidget {
  const CommandCenterScreen({super.key});

  @override
  State<CommandCenterScreen> createState() => _CommandCenterScreenState();
}

class _CommandCenterScreenState extends State<CommandCenterScreen> {
  // Get stream URL based on camera ID
  // TODO: Replace these demo HLS URLs with your backend's HLS stream URLs
  String _getStreamUrlForCamera(String cameraId) {
    final number = int.tryParse(cameraId.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    // VERIFIED WORKING HLS (.m3u8) test streams (HTTPS)
    // These simulate what your backend media server will provide
    // Architecture: CCTV (RTSP) → Backend/Media Server → HLS (.m3u8) → Mobile App
    final demoStreams = [
      // Apple Developer Test Streams (HTTPS, verified working)
      'https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_adv_example_hevc/master.m3u8',

      // Akamai Live Test Streams (HTTPS, verified working)
      'https://cph-p2p-msl.akamaized.net/hls/live/2000341/test/master.m3u8',
      'https://moctobpltc-i.akamaihd.net/hls/live/571329/eight/playlist.m3u8',

      // Bitdash Test Stream (HTTPS, verified working)
      'https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8',

      // Unified Streaming Test (HTTPS, verified working)
      'https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.mp4/.m3u8',

      // Mux Test Stream (HTTPS, verified working)
      'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
    ];

    return demoStreams[number % demoStreams.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SecurityColors.primaryBackground,
      body: Column(
        children: [
          // Simple header - YouTube style
          _buildHeader(),

          // Scrollable feed
          Expanded(
            child: _buildFeed(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: SecurityColors.primaryBackground,
        border: Border(
          bottom: BorderSide(
            color: SecurityColors.divider,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Logo
          Text(
            'ORIN',
            style: GoogleFonts.orbitron(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
              color: SecurityColors.primaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeed() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          // Recent Camera Activity
          _buildSection(
            title: 'Recent Camera Activity',
            child: _buildHorizontalCameraList(),
          ),

          const SizedBox(height: 32),

          // Active Guards
          _buildSection(
            title: 'Active Guards',
            child: _buildGuardsList(),
          ),

          const SizedBox(height: 32),

          // Recent Events
          _buildSection(
            title: 'Recent Events',
            child: _buildEventsList(),
          ),

          const SizedBox(height: 32),

          // All Cameras
          _buildSection(
            title: 'All Cameras',
            action: TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CamerasGridScreen(),
                  ),
                );
              },
              child: const Text(
                'View all',
                style: TextStyle(
                  color: SecurityColors.secondaryAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            child: _buildCameraGrid(),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
    Widget? action,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: SecurityColors.primaryText,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (action != null) action,
            ],
          ),
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildHorizontalCameraList() {
    final recentCameras = [
      {'id': 'CAM-01', 'name': 'Main Entrance', 'time': '2m ago', 'active': true},
      {'id': 'CAM-05', 'name': 'Parking Lot A', 'time': '5m ago', 'active': true},
      {'id': 'CAM-12', 'name': 'Server Room', 'time': '15m ago', 'active': false},
      {'id': 'CAM-03', 'name': 'Lobby', 'time': '1h ago', 'active': true},
    ];

    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: recentCameras.length,
        itemBuilder: (context, index) {
          final camera = recentCameras[index];
          return _buildHorizontalCameraCard(camera);
        },
      ),
    );
  }

  Widget _buildHorizontalCameraCard(Map<String, dynamic> camera) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CameraViewerScreen(
              cameraId: camera['id'],
              cameraName: camera['name'],
              location: 'Main Building',
            ),
          ),
        );
      },
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Camera preview
            Container(
              height: 158,
              decoration: BoxDecoration(
                color: SecurityColors.secondarySurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
              children: [
                // Static placeholder (memory optimization - no live video in preview)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF1a1a1a),
                          const Color(0xFF2d2d2d),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.videocam,
                        color: SecurityColors.accent.withOpacity(0.3),
                        size: 40,
                      ),
                    ),
                  ),
                ),

                // Status indicator
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: camera['active']
                          ? SecurityColors.statusOnline
                          : SecurityColors.statusOffline,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                // Time badge
                if (camera['active'])
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: SecurityColors.accent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Camera info
          Text(
            camera['name'],
            style: const TextStyle(
              color: SecurityColors.primaryText,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${camera['id']} • ${camera['time']}',
            style: const TextStyle(
              color: SecurityColors.secondaryText,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildGuardsList() {
    final guards = [
      {'name': 'Motion Detection', 'status': 'Active', 'cameras': 3},
      {'name': 'Person Detection', 'status': 'Active', 'cameras': 5},
      {'name': 'Vehicle Detection', 'status': 'Paused', 'cameras': 2},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: guards.map((guard) => _buildGuardCard(guard)).toList(),
      ),
    );
  }

  Widget _buildGuardCard(Map<String, dynamic> guard) {
    final isActive = guard['status'] == 'Active';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SecurityColors.secondarySurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: SecurityColors.divider,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isActive
                  ? SecurityColors.statusOnline.withOpacity(0.1)
                  : SecurityColors.secondaryText.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.shield_outlined,
              color: isActive
                  ? SecurityColors.statusOnline
                  : SecurityColors.secondaryText,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  guard['name'],
                  style: const TextStyle(
                    color: SecurityColors.primaryText,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${guard['cameras']} cameras',
                  style: const TextStyle(
                    color: SecurityColors.secondaryText,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: isActive
                  ? SecurityColors.statusOnline.withOpacity(0.1)
                  : SecurityColors.secondaryText.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              guard['status'],
              style: TextStyle(
                color: isActive
                    ? SecurityColors.statusOnline
                    : SecurityColors.secondaryText,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList() {
    final events = [
      {
        'title': 'Motion detected',
        'subtitle': 'CAM-05 • Parking Lot A',
        'time': '2m ago',
        'type': 'motion',
      },
      {
        'title': 'Person detected',
        'subtitle': 'CAM-01 • Main Entrance',
        'time': '15m ago',
        'type': 'person',
      },
      {
        'title': 'Camera offline',
        'subtitle': 'CAM-12 • Server Room',
        'time': '1h ago',
        'type': 'offline',
      },
      {
        'title': 'Recording started',
        'subtitle': 'CAM-03 • Lobby',
        'time': '2h ago',
        'type': 'recording',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: events.map((event) => _buildEventCard(event)).toList(),
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SecurityColors.secondarySurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: SecurityColors.divider,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getEventColor(event['type']).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getEventIcon(event['type']),
              color: _getEventColor(event['type']),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title'],
                  style: const TextStyle(
                    color: SecurityColors.primaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event['subtitle'],
                  style: const TextStyle(
                    color: SecurityColors.secondaryText,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Text(
            event['time'],
            style: const TextStyle(
              color: SecurityColors.secondaryText,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraGrid() {
    final cameras = _generateMockCameras(6);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 16 / 9,
        ),
        itemCount: cameras.length,
        itemBuilder: (context, index) {
          return _buildCameraGridCard(cameras[index]);
        },
      ),
    );
  }

  Widget _buildCameraGridCard(Map<String, dynamic> camera) {
    final isOnline = camera['isOnline'] as bool;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CameraViewerScreen(
              cameraId: camera['id'],
              cameraName: camera['name'],
              location: camera['location'],
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: SecurityColors.secondarySurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: SecurityColors.divider,
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
          fit: StackFit.expand,
          children: [
            // Static placeholder (memory optimization - no live video in grid)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isOnline
                      ? [
                          const Color(0xFF1a1a1a),
                          const Color(0xFF2d2d2d),
                        ]
                      : [
                          const Color(0xFFF5F5F5),
                          const Color(0xFFF5F5F5),
                        ],
                ),
              ),
              child: Center(
                child: Icon(
                  isOnline ? Icons.videocam : Icons.videocam_off_outlined,
                  color: isOnline
                      ? SecurityColors.accent.withOpacity(0.3)
                      : SecurityColors.statusOffline.withOpacity(0.2),
                  size: 32,
                ),
              ),
            ),

            // Status indicator
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isOnline
                      ? SecurityColors.statusOnline
                      : SecurityColors.statusOffline,
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Camera info
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.6),
                    ],
                  ),
                ),
                child: Text(
                  camera['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  IconData _getEventIcon(String type) {
    switch (type) {
      case 'motion':
        return Icons.motion_photos_on_outlined;
      case 'person':
        return Icons.person_outline;
      case 'offline':
        return Icons.videocam_off_outlined;
      case 'recording':
        return Icons.fiber_manual_record_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getEventColor(String type) {
    switch (type) {
      case 'offline':
        return SecurityColors.statusOffline;
      case 'motion':
      case 'person':
        return SecurityColors.accent;
      default:
        return SecurityColors.secondaryText;
    }
  }

  List<Map<String, dynamic>> _generateMockCameras(int count) {
    final locations = [
      'Main Entrance',
      'Parking Lot A',
      'Lobby',
      'Corridor 2F',
      'Loading Bay',
      'Server Room',
    ];

    return List.generate(count, (index) {
      return {
        'id': 'CAM-${(index + 1).toString().padLeft(2, '0')}',
        'name': 'CAM-${(index + 1).toString().padLeft(2, '0')}',
        'location': locations[index % locations.length],
        'isOnline': index != 2,
      };
    });
  }
}
