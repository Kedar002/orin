import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Reusable video thumbnail widget
/// Shows a paused frame from the video
class VideoThumbnail extends StatefulWidget {
  const VideoThumbnail({super.key});

  @override
  State<VideoThumbnail> createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<VideoThumbnail> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.asset('assets/videos/camera_feed.mp4');
    await _controller.initialize();
    // Seek to a specific frame for thumbnail
    await _controller.seekTo(const Duration(seconds: 2));
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Icon(
            Icons.play_circle_outline,
            color: Colors.white.withOpacity(0.3),
            size: 32,
          ),
        ),
      );
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _controller.value.size.width,
          height: _controller.value.size.height,
          child: VideoPlayer(_controller),
        ),
      ),
    );
  }
}
