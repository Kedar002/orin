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
  String _selectedAction = 'other'; // Default: other cameras
  final TextEditingController _chatController = TextEditingController();
  final List<Map<String, dynamic>> _chatMessages = [
    {
      'isUser': false,
      'message': 'Hello! I can help you analyze this camera feed. What would you like to know?',
      'time': '10:30 AM',
    },
  ];

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

  void _onActionSelected(String action) {
    setState(() {
      _selectedAction = action;
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _chatController.dispose();
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
                    _buildDynamicContent(),
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
            _buildActionButton(Icons.video_library_outlined, 'Other', 'other'),
            const SizedBox(width: 8),
            _buildActionButton(Icons.auto_awesome, 'Summarize', 'summarize'),
            const SizedBox(width: 8),
            _buildActionButton(Icons.download_outlined, 'Download', 'download'),
            const SizedBox(width: 8),
            _buildActionButton(Icons.camera_alt_outlined, 'Snapshot', 'snapshot'),
            const SizedBox(width: 8),
            _buildActionButton(Icons.share_outlined, 'Share', 'share'),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, String action) {
    final isSelected = _selectedAction == action;

    return GestureDetector(
      onTap: () => _onActionSelected(action),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? SecurityColors.accent
              : SecurityColors.secondarySurface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Colors.white
                  : SecurityColors.primaryText,
              size: 18,
            ),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : SecurityColors.primaryText,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicContent() {
    switch (_selectedAction) {
      case 'other':
        return _buildRelatedCameras();
      case 'summarize':
        return _buildSummarizeContent();
      case 'download':
        return _buildDownloadContent();
      case 'snapshot':
        return _buildSnapshotContent();
      case 'share':
        return _buildShareContent();
      default:
        return _buildRelatedCameras();
    }
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

  Widget _buildSummarizeContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AI Summary',
            style: TextStyle(
              color: SecurityColors.primaryText,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SecurityColors.secondarySurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: SecurityColors.divider,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: SecurityColors.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: SecurityColors.accent,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Activity Overview',
                      style: TextStyle(
                        color: SecurityColors.primaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'No significant activity detected in the last 24 hours. Camera feed shows normal traffic patterns with 3 motion events recorded.',
                  style: TextStyle(
                    color: SecurityColors.secondaryText,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(color: SecurityColors.divider, height: 1),
                const SizedBox(height: 12),
                _buildSummaryItem('Total Events', '3'),
                const SizedBox(height: 8),
                _buildSummaryItem('Motion Detected', '2'),
                const SizedBox(height: 8),
                _buildSummaryItem('People Detected', '1'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Chat with AI button
          GestureDetector(
            onTap: _showChatBottomSheet,
            child: Container(
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
                      color: SecurityColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.chat_bubble_outline,
                      color: SecurityColors.accent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chat with AI',
                          style: TextStyle(
                            color: SecurityColors.primaryText,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Ask questions about this camera feed',
                          style: TextStyle(
                            color: SecurityColors.secondaryText,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: SecurityColors.secondaryText,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: SecurityColors.secondaryText,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: SecurityColors.primaryText,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Download Options',
            style: TextStyle(
              color: SecurityColors.primaryText,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildDownloadOption(
            Icons.video_file_outlined,
            'Download Full Video',
            '18:45 • 245 MB',
          ),
          const SizedBox(height: 8),
          _buildDownloadOption(
            Icons.cut_outlined,
            'Download Clip',
            'Select time range',
          ),
          const SizedBox(height: 8),
          _buildDownloadOption(
            Icons.high_quality_outlined,
            'Download HD Quality',
            '18:45 • 680 MB',
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadOption(IconData icon, String title, String subtitle) {
    return Container(
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
              color: SecurityColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: SecurityColors.accent,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: SecurityColors.primaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: SecurityColors.secondaryText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.file_download_outlined,
            color: SecurityColors.secondaryText,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildSnapshotContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Snapshots',
                style: TextStyle(
                  color: SecurityColors.primaryText,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: SecurityColors.accent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Capture',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  color: SecurityColors.secondarySurface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: SecurityColors.divider,
                    width: 1,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        Icons.image_outlined,
                        color: SecurityColors.secondaryText.withOpacity(0.3),
                        size: 32,
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${index + 1}h',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
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

  Widget _buildShareContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Share Options',
            style: TextStyle(
              color: SecurityColors.primaryText,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildShareOption(Icons.link, 'Copy Link', 'Share video link'),
          const SizedBox(height: 8),
          _buildShareOption(Icons.qr_code, 'QR Code', 'Generate QR code'),
          const SizedBox(height: 8),
          _buildShareOption(Icons.email_outlined, 'Email', 'Send via email'),
          const SizedBox(height: 8),
          _buildShareOption(Icons.share_outlined, 'More', 'Other sharing options'),
        ],
      ),
    );
  }

  Widget _buildShareOption(IconData icon, String title, String subtitle) {
    return Container(
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
              color: SecurityColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: SecurityColors.accent,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: SecurityColors.primaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: SecurityColors.secondaryText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: SecurityColors.secondaryText,
            size: 20,
          ),
        ],
      ),
    );
  }

  void _showChatBottomSheet() {
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
            decoration: const BoxDecoration(
              color: SecurityColors.primaryBackground,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Drag handle
                Container(
                  margin: const EdgeInsets.only(top: 8, bottom: 4),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: SecurityColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: SecurityColors.divider,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: SecurityColors.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: SecurityColors.accent,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI Assistant',
                              style: TextStyle(
                                color: SecurityColors.primaryText,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Ask anything about this camera',
                              style: TextStyle(
                                color: SecurityColors.secondaryText,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: SecurityColors.secondaryText,
                          size: 24,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                // Messages
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _chatMessages.length,
                    itemBuilder: (context, index) {
                      final message = _chatMessages[index];
                      return _buildChatMessage(
                        message['message'],
                        message['isUser'],
                        message['time'],
                      );
                    },
                  ),
                ),
                // Input field
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: SecurityColors.primaryBackground,
                    border: Border(
                      top: BorderSide(
                        color: SecurityColors.divider,
                        width: 1,
                      ),
                    ),
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: SecurityColors.secondarySurface,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: SecurityColors.divider,
                                width: 1,
                              ),
                            ),
                            child: TextField(
                              controller: _chatController,
                              style: const TextStyle(
                                color: SecurityColors.primaryText,
                                fontSize: 14,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Ask a question...',
                                hintStyle: TextStyle(
                                  color: SecurityColors.secondaryText,
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              maxLines: null,
                              textInputAction: TextInputAction.send,
                              onSubmitted: (value) => _sendMessage(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _sendMessage,
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: SecurityColors.accent,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_upward,
                              color: Colors.white,
                              size: 20,
                            ),
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

  void _sendMessage() {
    if (_chatController.text.trim().isEmpty) return;

    setState(() {
      _chatMessages.add({
        'isUser': true,
        'message': _chatController.text,
        'time': '10:${30 + _chatMessages.length} AM',
      });

      // Mock AI response
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          _chatMessages.add({
            'isUser': false,
            'message': 'I can help you with that. Based on the camera feed analysis, I can provide insights about activity patterns, detected objects, and security alerts.',
            'time': '10:${31 + _chatMessages.length} AM',
          });
        });
      });
    });

    _chatController.clear();
  }

  Widget _buildChatMessage(String message, bool isUser, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: SecurityColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: SecurityColors.accent,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser
                        ? SecurityColors.accent
                        : SecurityColors.secondarySurface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    message,
                    style: TextStyle(
                      color: isUser
                          ? Colors.white
                          : SecurityColors.primaryText,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    time,
                    style: const TextStyle(
                      color: SecurityColors.secondaryText,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: SecurityColors.secondaryText.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.person,
                color: SecurityColors.secondaryText,
                size: 16,
              ),
            ),
          ],
        ],
      ),
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
