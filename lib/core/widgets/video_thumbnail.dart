import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:video_player/video_player.dart';

/// Reusable video thumbnail widget
/// Shows a paused frame from the video stream
class VideoThumbnail extends StatefulWidget {
  final String? streamUrl;

  const VideoThumbnail({
    super.key,
    this.streamUrl,
  });

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
    // Default HLS demo stream if none provided
    final streamUrl = widget.streamUrl ??
        'https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_adv_example_hevc/master.m3u8';

    _controller = VideoPlayerController.networkUrl(Uri.parse(streamUrl));
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
            CupertinoIcons.play_circle,
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
