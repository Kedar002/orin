import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/constants/security_colors.dart';
import 'camera_viewer_screen.dart';

/// Full Screen Grid View of All Cameras
class CamerasGridScreen extends StatefulWidget {
  const CamerasGridScreen({super.key});

  @override
  State<CamerasGridScreen> createState() => _CamerasGridScreenState();
}

class _CamerasGridScreenState extends State<CamerasGridScreen> {
  int _crossAxisCount = 2; // Default: 2 columns
  bool _showOnlineOnly = false;

  // Get stream URL based on camera ID
  String _getStreamUrlForCamera(String cameraId) {
    final number = int.tryParse(cameraId.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    // VERIFIED WORKING HLS (.m3u8) test streams (HTTPS)
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
    final cameras = _generateAllCameras();
    final filteredCameras = _showOnlineOnly
        ? cameras.where((c) => c['isOnline'] as bool).toList()
        : cameras;

    return Scaffold(
      backgroundColor: SecurityColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: SecurityColors.primaryBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            CupertinoIcons.back,
            color: SecurityColors.primaryText,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'All Cameras',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: SecurityColors.primaryText,
          ),
        ),
        actions: [
          // Grid size toggle
          PopupMenuButton<int>(
            icon: const Icon(
              CupertinoIcons.square_grid_2x2,
              color: SecurityColors.primaryText,
            ),
            onSelected: (value) {
              setState(() {
                _crossAxisCount = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 1,
                child: Row(
                  children: [
                    Icon(Icons.view_agenda, size: 20),
                    SizedBox(width: 12),
                    Text('1 Column'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 2,
                child: Row(
                  children: [
                    Icon(Icons.grid_on, size: 20),
                    SizedBox(width: 12),
                    Text('2 Columns'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 3,
                child: Row(
                  children: [
                    Icon(Icons.grid_view, size: 20),
                    SizedBox(width: 12),
                    Text('3 Columns'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 4,
                child: Row(
                  children: [
                    Icon(Icons.apps, size: 20),
                    SizedBox(width: 12),
                    Text('4 Columns'),
                  ],
                ),
              ),
            ],
          ),
          // Filter toggle
          IconButton(
            icon: Icon(
              _showOnlineOnly ? CupertinoIcons.slider_horizontal_3 : CupertinoIcons.slider_horizontal_3,
              color: _showOnlineOnly
                  ? SecurityColors.accent
                  : SecurityColors.primaryText,
            ),
            onPressed: () {
              setState(() {
                _showOnlineOnly = !_showOnlineOnly;
              });
            },
          ),
        ],
      ),
      body: filteredCameras.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.videocam,
                    size: 64,
                    color: SecurityColors.secondaryText.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No cameras found',
                    style: TextStyle(
                      color: SecurityColors.secondaryText,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: _crossAxisCount == 1 ? 16 / 9 : 1.0,
              ),
              itemCount: filteredCameras.length,
              itemBuilder: (context, index) {
                return _buildCameraCard(filteredCameras[index]);
              },
            ),
    );
  }

  Widget _buildCameraCard(Map<String, dynamic> camera) {
    final isOnline = camera['isOnline'] as bool;

    return GestureDetector(
      onTap: () {
        if (isOnline) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CameraViewerScreen(
                cameraId: camera['id'],
                cameraName: camera['name'],
                location: camera['location'],
                streamUrl: _getStreamUrlForCamera(camera['id'] as String),
              ),
            ),
          );
        }
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
              // Static placeholder instead of live video (memory optimization)
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
                            SecurityColors.secondarySurface,
                            SecurityColors.secondarySurface,
                          ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    isOnline ? CupertinoIcons.videocam_fill : CupertinoIcons.videocam,
                    color: isOnline
                        ? SecurityColors.accent.withOpacity(0.3)
                        : SecurityColors.secondaryText.withOpacity(0.3),
                    size: _crossAxisCount == 1 ? 48 : 32,
                  ),
                ),
              ),

              // Gradient overlay for text readability
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.all(_crossAxisCount == 1 ? 12 : 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              camera['name'],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: _crossAxisCount == 1 ? 14 : 12,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isOnline
                                  ? SecurityColors.statusOnline
                                  : SecurityColors.statusOffline,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      if (_crossAxisCount <= 2) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${camera['id']} • ${camera['location']}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: _crossAxisCount == 1 ? 12 : 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // LIVE badge for online cameras
              if (isOnline)
                Positioned(
                  top: 8,
                  left: 8,
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

              // Offline overlay
              if (!isOnline)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.videocam,
                            color: Colors.white,
                            size: 24,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'OFFLINE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
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
    );
  }

  List<Map<String, dynamic>> _generateAllCameras() {
    final locations = [
      'Main Entrance',
      'Parking Lot A',
      'Lobby',
      'Corridor 2F',
      'Loading Bay',
      'Server Room',
      'Reception',
      'Parking Lot B',
      'Emergency Exit',
      'Conference Room',
      'Cafeteria',
      'Warehouse',
      'Office Floor 1',
      'Office Floor 2',
      'Rooftop',
      'Storage Area',
      'Main Gate',
      'Side Entrance',
      'Elevator Hall',
      'Stairwell A',
    ];

    return List.generate(20, (index) {
      return {
        'id': 'CAM-${(index + 1).toString().padLeft(2, '0')}',
        'name': 'CAM-${(index + 1).toString().padLeft(2, '0')}',
        'location': locations[index % locations.length],
        'isOnline': index != 2 && index != 7 && index != 12, // Some offline cameras
      };
    });
  }
}
