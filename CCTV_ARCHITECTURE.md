# CCTV System Architecture for Mobile App

## 🏗️ Production Architecture

```
┌─────────────────┐
│  CCTV Camera    │  (Hikvision, Dahua, etc.)
│                 │
│  RTSP Stream    │  rtsp://192.168.1.100:554/stream1
└────────┬────────┘
         │ RTSP Protocol
         ↓
┌─────────────────────────────┐
│  Backend / Media Server     │  (Your Server/Cloud)
│                             │
│  • FFmpeg / MediaMTX        │
│  • Converts RTSP to HLS     │
│  • Handles authentication   │
│  • Manages recordings       │
└────────┬────────────────────┘
         │ HLS (.m3u8) / WebRTC
         │ HTTPS Protocol
         ↓
┌─────────────────┐
│  Mobile App     │  (Flutter - This App)
│  (iOS/Android)  │
│                 │
│  HLS Player     │  https://your-server.com/camera1/stream.m3u8
└─────────────────┘
```

## 📊 Streaming Format Comparison

| Format | Use Case | Latency | Mobile Support | Notes |
|--------|----------|---------|----------------|-------|
| **HLS (.m3u8)** | Live + Playback | 10-30s | ✅ Excellent | **Most common for CCTV apps** |
| **WebRTC** | Ultra-low latency | <1s | ✅ Good | Modern apps, complex setup |
| **MJPEG** | Simple preview | Low | ✅ Good | Low quality, high bandwidth |
| **RTSP Direct** | Local network | Low | ⚠️ Android only | Not recommended for mobile |

## ✅ Why HLS for Mobile Apps?

1. **Universal Support**: Works on iOS and Android natively
2. **HTTPS**: Secure, no cleartext issues
3. **Adaptive Bitrate**: Adjusts to network conditions
4. **Industry Standard**: Used by YouTube, Netflix, etc.
5. **Easy to Scale**: Works with CDNs

## 🛠️ Backend Media Server Options

### Option 1: FFmpeg (Simple, Open Source)

**Convert RTSP to HLS:**
```bash
ffmpeg -i rtsp://username:password@camera-ip:554/stream1 \
  -c:v copy -c:a copy \
  -f hls -hls_time 2 -hls_list_size 3 \
  -hls_flags delete_segments \
  /var/www/html/streams/camera1/stream.m3u8
```

**Serve with Nginx:**
```nginx
location /streams/ {
    alias /var/www/html/streams/;
    add_header Cache-Control no-cache;
    add_header Access-Control-Allow-Origin *;
}
```

**Your mobile app URL:**
```
https://your-server.com/streams/camera1/stream.m3u8
```

### Option 2: MediaMTX (Recommended for Multiple Cameras)

1. **Download**: https://github.com/bluenviron/mediamtx/releases
2. **Configure** (`mediamtx.yml`):
```yaml
paths:
  camera1:
    source: rtsp://admin:password@192.168.1.100:554/stream1
    runOnInit: ffmpeg -i rtsp://localhost:$RTSP_PORT/$MTX_PATH -c copy -f hls /path/to/hls/camera1.m3u8

  camera2:
    source: rtsp://admin:password@192.168.1.101:554/stream1
    runOnInit: ffmpeg -i rtsp://localhost:$RTSP_PORT/$MTX_PATH -c copy -f hls /path/to/hls/camera2.m3u8
```

3. **Access streams:**
   - Camera 1: `https://your-server.com/camera1/stream.m3u8`
   - Camera 2: `https://your-server.com/camera2/stream.m3u8`

### Option 3: Node.js + node-media-server

```javascript
const NodeMediaServer = require('node-media-server');

const config = {
  rtmp: {
    port: 1935,
    chunk_size: 60000,
    gop_cache: true,
    ping: 30,
    ping_timeout: 60
  },
  http: {
    port: 8000,
    allow_origin: '*'
  },
  trans: {
    ffmpeg: '/usr/bin/ffmpeg',
    tasks: [
      {
        app: 'live',
        hls: true,
        hlsFlags: '[hls_time=2:hls_list_size=3:hls_flags=delete_segments]',
        dash: true,
        dashFlags: '[f=dash:window_size=3:extra_window_size=5]'
      }
    ]
  }
};

var nms = new NodeMediaServer(config);
nms.run();
```

### Option 4: Cloud Solutions (Managed)

1. **AWS Kinesis Video Streams**
   - Fully managed
   - Auto-scaling
   - HLS output
   - Pay per use

2. **Azure Media Services**
   - Live streaming
   - VOD support
   - CDN integration

3. **Wowza Streaming Cloud**
   - Purpose-built for CCTV
   - RTSP to HLS conversion
   - Recording management

## 🚀 Quick Start for Testing

### Step 1: Set Up Local Media Server (Windows)

1. **Download MediaMTX**: https://github.com/bluenviron/mediamtx/releases
   - Extract `mediamtx_v1.x.x_windows_amd64.zip`
   - Run `mediamtx.exe`

2. **Download FFmpeg**: https://ffmpeg.org/download.html
   - Add to PATH

3. **Create HLS stream from RTSP camera:**
```bash
# Open Command Prompt
ffmpeg -rtsp_transport tcp -i rtsp://your-camera-ip:554/stream1 ^
  -c:v copy -c:a aac ^
  -f hls -hls_time 2 -hls_list_size 3 ^
  -hls_flags delete_segments ^
  C:\streaming\camera1\stream.m3u8
```

4. **Serve with Python (for testing):**
```bash
cd C:\streaming
python -m http.server 8080
```

5. **Update your Flutter app:**
```dart
final demoStreams = [
  'http://your-computer-ip:8080/camera1/stream.m3u8',
];
```

### Step 2: Production Deployment

1. **Set up Linux server** (Ubuntu recommended)
2. **Install Nginx + FFmpeg**
3. **Configure HTTPS** (Let's Encrypt)
4. **Set up systemd services** for auto-restart
5. **Use HLS URLs** in your Flutter app

## 📱 Flutter App Integration

Your app is already configured! Just update the URLs:

```dart
// In camera_viewer_screen.dart and command_center_screen.dart
String _getStreamUrlForCamera(String cameraId) {
  // Map camera IDs to your backend HLS streams
  final Map<String, String> cameraStreams = {
    'CAM-01': 'https://your-server.com/camera1/stream.m3u8',
    'CAM-02': 'https://your-server.com/camera2/stream.m3u8',
    'CAM-03': 'https://your-server.com/camera3/stream.m3u8',
    'CAM-04': 'https://your-server.com/camera4/stream.m3u8',
  };

  return cameraStreams[cameraId] ??
         'https://your-server.com/default/stream.m3u8';
}
```

## 🔐 Security Considerations

1. **HTTPS Only**: Always use HTTPS for HLS streams
2. **Authentication**:
   - Token-based access to HLS URLs
   - JWT in URL parameters
   - Time-limited signed URLs
3. **Firewall**: Restrict RTSP access to backend server only
4. **Encryption**: Consider encrypting HLS segments (AES-128)

## 📦 Example Backend Stack

### Minimal Production Setup

```
┌─────────────────────────────────┐
│  Nginx (HTTPS, Port 443)        │
│  - SSL/TLS certificates         │
│  - Serves HLS .m3u8 files       │
└──────────┬──────────────────────┘
           │
┌──────────▼──────────────────────┐
│  FFmpeg Processes               │
│  - 1 per camera                 │
│  - RTSP → HLS conversion        │
│  - systemd managed              │
└──────────┬──────────────────────┘
           │
┌──────────▼──────────────────────┐
│  CCTV Cameras (RTSP)            │
│  - 192.168.1.100-110            │
│  - Local network only           │
└─────────────────────────────────┘
```

### systemd Service Example

Create `/etc/systemd/system/camera1-hls.service`:
```ini
[Unit]
Description=Camera 1 HLS Stream
After=network.target

[Service]
Type=simple
User=www-data
ExecStart=/usr/bin/ffmpeg -rtsp_transport tcp \
  -i rtsp://admin:password@192.168.1.100:554/stream1 \
  -c:v copy -c:a aac \
  -f hls -hls_time 2 -hls_list_size 3 \
  -hls_flags delete_segments \
  /var/www/html/hls/camera1/stream.m3u8
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

Enable and start:
```bash
sudo systemctl enable camera1-hls
sudo systemctl start camera1-hls
```

## 🧪 Current Test Setup

Your app currently uses these **verified working** HLS test streams:

1. **Apple Developer Stream**:
   `https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_adv_example_hevc/master.m3u8`

2. **Akamai Live Streams**:
   - `https://cph-p2p-msl.akamaized.net/hls/live/2000341/test/master.m3u8`
   - `https://moctobpltc-i.akamaihd.net/hls/live/571329/eight/playlist.m3u8`

3. **Bitdash Test**:
   `https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8`

4. **Unified Streaming**:
   `https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.mp4/.m3u8`

5. **Mux Test**:
   `https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8`

These streams work across all platforms (Android/iOS) and simulate real CCTV feeds.

## 📝 Next Steps

1. ✅ **Test app with current HLS streams** (already configured)
2. 📹 **Get RTSP URLs from your CCTV cameras**
3. 🖥️ **Set up backend media server** (use one of the options above)
4. 🔄 **Convert RTSP to HLS** using FFmpeg/MediaMTX
5. 🌐 **Deploy with HTTPS** (required for production)
6. 📱 **Update Flutter app URLs** to point to your backend
7. 🚀 **Deploy to production**

## 💡 Tips

- **Start simple**: Use FFmpeg + Python HTTP server for testing
- **Scale gradually**: Move to Nginx + systemd for production
- **Monitor bandwidth**: HLS uses ~1-3 Mbps per camera
- **Consider CDN**: For remote access, use CloudFlare/AWS CloudFront
- **Plan storage**: Recording uses ~1-2 GB/hour per camera (H.264)
