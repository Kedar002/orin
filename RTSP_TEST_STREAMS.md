# Streaming Test URLs for Development

## ✅ Current Architecture: HLS Streaming

Your app now uses **HLS (.m3u8)** streams - the industry standard for CCTV mobile apps!

### Architecture Flow:
```
CCTV Camera (RTSP) → Backend/Media Server → HLS (.m3u8) → Mobile App ✅
```

### Why HLS?
- ✅ Works on **both iOS and Android**
- ✅ **HTTPS** - secure, no cleartext issues
- ✅ **Adaptive bitrate** - adjusts to network
- ✅ **Industry standard** - used by YouTube, Netflix
- ✅ **CDN compatible** - easy to scale

## 🎥 Verified Working HLS Test Streams (HTTPS)

Your app currently uses these **verified working** test streams:

### 1. Apple Developer Streams
```
https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_adv_example_hevc/master.m3u8
```
- Status: ✅ Active
- Quality: High (HEVC)
- Source: Apple Inc.

### 2. Akamai Live Streams
```
https://cph-p2p-msl.akamaized.net/hls/live/2000341/test/master.m3u8
https://moctobpltc-i.akamaihd.net/hls/live/571329/eight/playlist.m3u8
```
- Status: ✅ Active
- Type: Live stream
- Source: Akamai CDN

### 3. Bitdash Test Stream
```
https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8
```
- Status: ✅ Active
- Content: Sintel (Blender movie)
- Quality: Multi-bitrate

### 4. Unified Streaming
```
https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.mp4/.m3u8
```
- Status: ✅ Active
- Content: Tears of Steel
- Format: MP4 to HLS

### 5. Mux Test Stream
```
https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8
```
- Status: ✅ Active
- Source: Mux (video infrastructure)
- Purpose: Developer testing

All streams above are:
- ✅ HTTPS (secure)
- ✅ Verified working (January 2025)
- ✅ Free to use for testing
- ✅ Work on iOS and Android

## 🔄 Old RTSP Section (For Reference Only)

## Free Public RTSP Test Streams

### Working Public Streams (as of 2025):

1. **Big Buck Bunny (Wowza)**
   ```
   rtsp://wowzaec2demo.streamlock.net/vod/mp4:BigBuckBunny_115k.mp4
   ```

2. **Pattern Stream**
   ```
   rtsp://rtsp.stream/pattern
   ```

3. **NASA TV (when available)**
   ```
   rtsp://rtsp.stream/nasa
   ```

4. **Test Pattern**
   ```
   rtsp://rtsp.stream/test
   ```

## Alternative: Use HTTP/HLS Streams (Already in your code)

These work reliably and are currently set as demo streams:
```dart
'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4'
'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4'
```

## Create Your Own Local RTSP Stream

### Method 1: Using VLC Media Player

1. **Download VLC**: https://www.videolan.org/vlc/
2. **Stream a video file via RTSP**:
   - Open VLC
   - Media → Stream
   - Add any video file
   - Click "Stream"
   - Click "Next"
   - Select "RTSP" as destination
   - Set port (e.g., 8554)
   - Click "Next" → "Stream"
   - Your RTSP URL: `rtsp://your-ip:8554/stream`

### Method 2: Using FFmpeg

```bash
# Install FFmpeg first
# Windows: Download from https://ffmpeg.org/
# Mac: brew install ffmpeg
# Linux: sudo apt install ffmpeg

# Stream a video file as RTSP
ffmpeg -re -stream_loop -1 -i your_video.mp4 -f rtsp rtsp://localhost:8554/stream
```

### Method 3: Using MediaMTX (Recommended for Testing)

1. **Download MediaMTX**: https://github.com/bluenviron/mediamtx/releases
2. **Run it** (creates RTSP server on port 8554)
3. **Publish a stream** using FFmpeg:
   ```bash
   ffmpeg -re -stream_loop -1 -i video.mp4 -f rtsp rtsp://localhost:8554/mystream
   ```
4. **Access stream**: `rtsp://your-ip:8554/mystream`

### Method 4: Using Docker (Easiest)

```bash
# Run RTSP Simple Server
docker run --rm -it -p 8554:8554 aler9/rtsp-simple-server

# In another terminal, publish a stream
ffmpeg -re -stream_loop -1 -i video.mp4 -f rtsp rtsp://localhost:8554/mystream
```

## Online RTSP Stream Simulators

### IPCamLive (Online IP Camera Simulator)
- Visit: https://ipcamlive.com/
- Provides free test RTSP streams
- Multiple camera feeds available

### RTSP.me (may require subscription)
- Provides managed RTSP test streams
- Good for development/testing

## Mobile Apps to Create RTSP Streams

### Android:
- **IP Webcam** - Turn phone into IP camera
  - Download from Play Store
  - Streams via RTSP: `rtsp://phone-ip:8086/h264_ulaw.sdp`

- **DroidCam** - Turn phone camera into RTSP stream
  - Provides RTSP URL after setup

### iOS:
- **EpocCam** - Turn iPhone into RTSP camera
- **iVCam** - Stream iPhone camera via RTSP

## Recommended for Your Testing:

### Option 1: Use MediaMTX + Your Own Video (Most Realistic)

```bash
# 1. Download MediaMTX for Windows
# https://github.com/bluenviron/mediamtx/releases
# Download mediamtx_v1.x.x_windows_amd64.zip

# 2. Extract and run mediamtx.exe

# 3. Get a sample CCTV-like video (security camera footage)
# Download from: https://www.pexels.com/search/videos/security%20camera/

# 4. Stream it with FFmpeg
ffmpeg -re -stream_loop -1 -i security_footage.mp4 -c copy -f rtsp rtsp://localhost:8554/camera1
ffmpeg -re -stream_loop -1 -i parking_lot.mp4 -c copy -f rtsp rtsp://localhost:8554/camera2
```

### Option 2: Use Your Phone (Quickest)

1. Install "IP Webcam" on Android
2. Start server
3. Get RTSP URL (shown in app)
4. Use in your Flutter app

### Option 3: Public Test Streams (No Setup)

Just use these working public streams:
```dart
final demoStreams = [
  'rtsp://wowzaec2demo.streamlock.net/vod/mp4:BigBuckBunny_115k.mp4',
  'rtsp://rtsp.stream/pattern',
  // Fallback to HTTP if RTSP doesn't work
  'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
];
```

## Testing RTSP URL Before Using in App

### Using VLC:
1. Open VLC
2. Media → Open Network Stream
3. Paste your RTSP URL
4. If it plays, it will work in your app

### Using FFplay (comes with FFmpeg):
```bash
ffplay rtsp://your-rtsp-url
```

## Important Notes:

- **RTSP on iOS**: Limited support, HLS might work better
- **RTSP on Android**: Works well with most players
- **Network**: Both devices must be on same network for local RTSP
- **Firewall**: May need to allow port 554 (RTSP default) or 8554

## When You Get Real Cameras:

Most IP cameras provide RTSP URLs in their settings:
1. Log into camera web interface
2. Look for "Streaming" or "Network" settings
3. Find RTSP URL (usually shows format)
4. Common default port: 554
5. You'll need username/password from camera settings
