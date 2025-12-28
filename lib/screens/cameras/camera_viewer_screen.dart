import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/security_colors.dart';

/// YouTube-style Camera Viewing Screen
/// Full-screen video player with controls and related cameras
class CameraViewerScreen extends StatefulWidget {
  final String cameraId;
  final String cameraName;
  final String location;

  const CameraViewerScreen({
    super.key,
    required this.cameraId,
    required this.cameraName,
    required this.location,
  });

  @override
  State<CameraViewerScreen> createState() => _CameraViewerScreenState();
}

class _CameraViewerScreenState extends State<CameraViewerScreen> {
  bool _showControls = true;
  bool _isPlaying = true;
  double _progress = 0.3; // Mock progress

  @override
  void initState() {
    super.initState();
    // Lock to portrait or landscape as needed
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SecurityColors.primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Video player section
            _buildVideoPlayer(),

            // Camera info and controls
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCameraInfo(),
                    _buildActionButtons(),
                    const Divider(
                      color: SecurityColors.divider,
                      height: 8,
                      thickness: 1,
                    ),
                    _buildRelatedCameras(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return GestureDetector(
      onTap: _toggleControls,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: Colors.black,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Video placeholder (will be replaced with actual video)
              Container(
                color: Colors.black,
                child: Center(
                  child: Icon(
                    Icons.videocam,
                    color: Colors.white.withOpacity(0.3),
                    size: 80,
                  ),
                ),
              ),

              // Gradient overlay
              if (_showControls)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                      stops: const [0.0, 0.3, 0.7, 1.0],
                    ),
                  ),
                ),

              // Top controls
              if (_showControls)
                Positioned(
                  top: 8,
                  left: 8,
                  right: 8,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(
                          Icons.more_vert,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),

              // Center play/pause button
              if (_showControls)
                Center(
                  child: GestureDetector(
                    onTap: _togglePlayPause,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                ),

              // Bottom controls
              if (_showControls)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildVideoControls(),
                ),

              // LIVE badge
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: SecurityColors.statusOffline,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
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
      ),
    );
  }

  Widget _buildVideoControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress bar
          Row(
            children: [
              Text(
                '5:23',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 2,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 12,
                    ),
                  ),
                  child: Slider(
                    value: _progress,
                    onChanged: (value) {
                      setState(() {
                        _progress = value;
                      });
                    },
                    activeColor: SecurityColors.statusOffline,
                    inactiveColor: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '18:45',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(
                  Icons.fullscreen,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: () {
                  // Toggle fullscreen
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCameraInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.cameraName,
            style: const TextStyle(
              color: SecurityColors.primaryText,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${widget.cameraId} • ${widget.location}',
            style: const TextStyle(
              color: SecurityColors.secondaryText,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildActionButton(Icons.camera_alt_outlined, 'Snapshot'),
            const SizedBox(width: 8),
            _buildActionButton(Icons.download_outlined, 'Download'),
            const SizedBox(width: 8),
            _buildActionButton(Icons.share_outlined, 'Share'),
            const SizedBox(width: 8),
            _buildActionButton(Icons.auto_awesome, 'Summarize'),
            const SizedBox(width: 8),
            _buildActionButton(Icons.more_horiz, 'Other'),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: SecurityColors.secondarySurface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: SecurityColors.primaryText,
            size: 18,
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: SecurityColors.primaryText,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRelatedCameras() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            'Other Cameras',
            style: TextStyle(
              color: SecurityColors.primaryText,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...List.generate(5, (index) => _buildRelatedCameraItem(index)),
      ],
    );
  }

  Widget _buildRelatedCameraItem(int index) {
    final cameras = [
      {'id': 'CAM-02', 'name': 'Parking Lot A', 'location': 'Level 1'},
      {'id': 'CAM-03', 'name': 'Main Hallway', 'location': 'Floor 2'},
      {'id': 'CAM-04', 'name': 'Loading Bay', 'location': 'Warehouse'},
      {'id': 'CAM-05', 'name': 'Office Floor 2', 'location': 'East Wing'},
      {'id': 'CAM-06', 'name': 'Storage Room', 'location': 'Basement'},
    ];

    final camera = cameras[index];

    return InkWell(
      onTap: () {
        Navigator.of(context).pushReplacement(
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Container(
              width: 110,
              height: 62,
              decoration: BoxDecoration(
                color: SecurityColors.secondarySurface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.videocam_outlined,
                        color: Colors.black.withOpacity(0.1),
                        size: 28,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 3,
                    right: 3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 3,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: const Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    camera['name']!,
                    style: const TextStyle(
                      color: SecurityColors.primaryText,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${camera['id']} • ${camera['location']}',
                    style: const TextStyle(
                      color: SecurityColors.secondaryText,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.more_vert,
              color: SecurityColors.secondaryText,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
