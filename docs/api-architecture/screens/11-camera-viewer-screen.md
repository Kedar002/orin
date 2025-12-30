# Camera Viewer Screen - API Documentation

## Screen Overview
**File**: `lib/screens/cameras/camera_viewer_screen.dart`
**Purpose**: Full-screen video playback with camera controls and actions
**Navigation**: From Command Center/Spaces → Tap camera card
**Design**: Premium video player with action bar and camera info

## Screen Components

### Video Player Section
- Full-screen HLS video player
- Auto-hiding controls (fade after 3 seconds)
- Play/pause button
- Seek bar with progress
- Current time / Total duration
- LIVE badge (always visible)
- Landscape orientation support

### Top Action Bar (overlay)
- Back button
- Camera name
- Menu button (3 dots)

### Below Video: Camera Info
- Camera name, ID, location
- Status (Online/Recording)
- Last seen timestamp

### Action Bar (5 quick actions)
1. **Info** - View camera details & assigned guards
2. **Summarize** - AI-generated summary with key moments
3. **Download** - Download video/clip/HD quality
4. **Snapshot** - View recent snapshots grid
5. **Share** - Share camera link/QR/email

### Other Cameras (Horizontal Scroll)
- Thumbnails of other cameras in same space
- Tap to switch camera

---

## API Requirements

### 1. Get Camera Stream URL
**Endpoint**: `GET /api/v1/cameras/{cameraId}/stream`
**Timing**: Called on screen mount
**Purpose**: Get HLS stream URL for video playback

#### Request
```http
GET /api/v1/cameras/cam_001/stream?quality=auto
Headers:
  Authorization: Bearer <access_token>
```

#### Query Parameters
- `quality`: `auto` | `1080p` | `720p` | `480p` | `360p` (default: auto)
- `live`: `true` | `false` (default: true for live stream)

#### Response - Success (200)
```json
{
  "success": true,
  "data": {
    "cameraId": "cam_001",
    "streamUrl": "https://stream.orin.app/live/cam_001/index.m3u8",
    "streamType": "hls",
    "isLive": true,
    "qualities": [
      {
        "resolution": "1080p",
        "bitrate": 4000,
        "fps": 30,
        "streamUrl": "https://stream.orin.app/live/cam_001/1080p/index.m3u8"
      },
      {
        "resolution": "720p",
        "bitrate": 2500,
        "fps": 30,
        "streamUrl": "https://stream.orin.app/live/cam_001/720p/index.m3u8"
      }
    ],
    "expiresAt": "2025-12-30T12:00:00Z"
  }
}
```

---

### 2. Get Camera Details
**Endpoint**: `GET /api/v1/cameras/{cameraId}`
**Timing**: Called on screen mount
**Purpose**: Fetch camera information and assigned guards

#### Request
```http
GET /api/v1/cameras/cam_001?includeGuards=true&includeStats=true
Headers:
  Authorization: Bearer <access_token>
```

#### Response - Success (200)
```json
{
  "success": true,
  "data": {
    "camera": {
      "id": "cam_001",
      "name": "Main Entrance",
      "spaceId": "space_abc123",
      "spaceName": "Hospital A",
      "status": "online",
      "isRecording": true,
      "resolution": "1080p",
      "fps": 30,
      "lastSeen": "2025-12-30T11:59:55Z",
      "uptime": "99.8%",
      "storageUsed": "45.2 GB",
      "recordingDuration": "240h",
      "addedAt": "2025-01-01T00:00:00Z",
      "assignedGuards": [
        {
          "id": "grd_001",
          "name": "Package Guard",
          "type": "packages",
          "isActive": true
        },
        {
          "id": "grd_002",
          "name": "Visitor Monitor",
          "type": "people",
          "isActive": true
        }
      ],
      "stats": {
        "eventsLast7Days": 35,
        "averageEventsPerDay": 5,
        "lastEventAt": "2025-12-30T10:20:00Z"
      }
    }
  }
}
```

---

### 3. Generate AI Summary
**Endpoint**: `POST /api/v1/cameras/{cameraId}/summarize`
**Timing**: Called when user taps "Summarize" action
**Purpose**: AI-generated summary of recent activity

#### Request
```http
POST /api/v1/cameras/cam_001/summarize
Headers:
  Authorization: Bearer <access_token>
  Content-Type: application/json

Body:
{
  "period": "24h",
  "includeKeyMoments": true
}
```

#### Response - Success (200)
```json
{
  "success": true,
  "data": {
    "cameraId": "cam_001",
    "cameraName": "Main Entrance",
    "period": "24h",
    "summary": "Today at Main Entrance, there were 8 notable events. Package Guard detected 3 package deliveries (9:15 AM, 11:30 AM, 2:45 PM). Visitor Monitor detected 5 people entering the building, with peak activity around 2:00 PM.",
    "keyMoments": [
      {
        "timestamp": "2025-12-30T09:15:00Z",
        "title": "Package Delivered",
        "description": "Large package delivered by courier",
        "thumbnailUrl": "https://cdn.orin.app/events/evt_001_thumb.jpg",
        "importance": "high"
      },
      {
        "timestamp": "2025-12-30T14:00:00Z",
        "title": "High Activity Period",
        "description": "Multiple visitors entering building",
        "thumbnailUrl": "https://cdn.orin.app/events/evt_005_thumb.jpg",
        "importance": "medium"
      }
    ],
    "stats": {
      "totalEvents": 8,
      "eventsByType": {
        "delivery": 3,
        "person": 5
      }
    }
  }
}
```

---

### 4. Download Video Clip
**Endpoint**: `POST /api/v1/cameras/{cameraId}/download`
**Timing**: Called when user requests download
**Purpose**: Generate downloadable video file

#### Request
```http
POST /api/v1/cameras/cam_001/download
Headers:
  Authorization: Bearer <access_token>
  Content-Type: application/json

Body:
{
  "downloadType": "clip",
  "startTime": "2025-12-30T09:00:00Z",
  "endTime": "2025-12-30T10:00:00Z",
  "quality": "1080p"
}
```

#### Response - Success (200)
```json
{
  "success": true,
  "data": {
    "downloadId": "dl_abc123",
    "downloadUrl": "https://cdn.orin.app/downloads/cam_001_clip_abc123.mp4",
    "expiresAt": "2025-12-30T13:00:00Z",
    "fileSize": "1.2 GB",
    "duration": "1:00:00",
    "quality": "1080p"
  },
  "message": "Download ready"
}
```

---

### 5. Get Recent Snapshots
**Endpoint**: `GET /api/v1/cameras/{cameraId}/snapshots`
**Timing**: Called when user taps "Snapshot" action
**Purpose**: Fetch recent snapshots for review

#### Request
```http
GET /api/v1/cameras/cam_001/snapshots?limit=12&interval=1h
Headers:
  Authorization: Bearer <access_token>
```

#### Query Parameters
- `limit`: Number of snapshots (default: 12, max: 24)
- `interval`: Time between snapshots (1h, 30m, 15m, 5m)
- `startDate`: ISO 8601 date (optional)

#### Response - Success (200)
```json
{
  "success": true,
  "data": {
    "snapshots": [
      {
        "id": "snap_001",
        "cameraId": "cam_001",
        "capturedAt": "2025-12-30T11:00:00Z",
        "thumbnailUrl": "https://cdn.orin.app/snapshots/cam_001_snap_001_thumb.jpg",
        "fullUrl": "https://cdn.orin.app/snapshots/cam_001_snap_001_full.jpg",
        "width": 1920,
        "height": 1080
      },
      {
        "id": "snap_002",
        "cameraId": "cam_001",
        "capturedAt": "2025-12-30T10:00:00Z",
        "thumbnailUrl": "https://cdn.orin.app/snapshots/cam_001_snap_002_thumb.jpg",
        "fullUrl": "https://cdn.orin.app/snapshots/cam_001_snap_002_full.jpg",
        "width": 1920,
        "height": 1080
      }
    ],
    "totalSnapshots": 24
  }
}
```

---

### 6. Share Camera Access
**Endpoint**: `POST /api/v1/cameras/{cameraId}/share`
**Timing**: Called when user creates share link
**Purpose**: Generate shareable link with access control

#### Request
```http
POST /api/v1/cameras/cam_001/share
Headers:
  Authorization: Bearer <access_token>
  Content-Type: application/json

Body:
{
  "shareType": "link",
  "expiresIn": 86400,
  "permissions": {
    "canViewLive": true,
    "canViewRecordings": false,
    "canDownload": false
  },
  "password": "optional_password_123"
}
```

#### Response - Success (200)
```json
{
  "success": true,
  "data": {
    "shareId": "share_abc123",
    "shareUrl": "https://orin.app/share/cam_001/share_abc123",
    "qrCodeUrl": "https://api.orin.app/qr/share_abc123.png",
    "expiresAt": "2025-12-31T12:00:00Z",
    "accessCode": "ORIN-1234-5678"
  }
}
```

---

### 7. Get Other Cameras in Space
**Endpoint**: `GET /api/v1/spaces/{spaceId}/cameras?exclude={cameraId}`
**Timing**: Called to show other cameras in horizontal scroll
**Purpose**: Allow quick camera switching

(See Space Detail Screen documentation for details)

---

## Navigation Logic Flow

```mermaid
graph TD
    A[Camera Viewer Screen] --> B[GET /api/v1/cameras/{id}/stream]
    B --> C[GET /api/v1/cameras/{id}]
    C --> D[Display Video Player & Info]
    D --> E{User Action}
    E -->|Tap Info| F[Show Camera Details Modal]
    E -->|Tap Summarize| G[POST /api/v1/cameras/{id}/summarize]
    E -->|Tap Download| H[POST /api/v1/cameras/{id}/download]
    E -->|Tap Snapshot| I[GET /api/v1/cameras/{id}/snapshots]
    E -->|Tap Share| J[POST /api/v1/cameras/{id}/share]
    E -->|Switch Camera| K[Load Different Camera Stream]
```

---

## Video Player Features

### Controls
- Play/Pause toggle
- Seek bar with current time/duration
- Quality selector (1080p, 720p, 480p)
- Fullscreen toggle
- Volume control

### Auto-Hide
- Controls fade after 3 seconds of inactivity
- Tap anywhere to show controls
- LIVE badge always visible

### Orientation
- Support landscape mode for better viewing
- Auto-rotate option in settings

---

## Analytics Events

```dart
// Camera Viewer Opened
{
  "event": "camera_viewer_opened",
  "cameraId": "cam_001",
  "cameraName": "Main Entrance",
  "timestamp": "2025-12-30T12:00:00Z"
}

// Video Played
{
  "event": "video_played",
  "cameraId": "cam_001",
  "quality": "1080p",
  "isLive": true,
  "timestamp": "2025-12-30T12:00:05Z"
}

// Summary Generated
{
  "event": "camera_summary_generated",
  "cameraId": "cam_001",
  "period": "24h",
  "keyMomentsCount": 5,
  "timestamp": "2025-12-30T12:05:00Z"
}

// Video Downloaded
{
  "event": "video_downloaded",
  "cameraId": "cam_001",
  "downloadType": "clip",
  "quality": "1080p",
  "duration": 3600,
  "timestamp": "2025-12-30T12:10:00Z"
}
```

---

## Testing Scenarios

1. **Normal Load**: Stream loads and plays
2. **Network Issues**: Handle buffering/connection loss
3. **Offline Camera**: Show error message
4. **Quality Switch**: Change video quality on-the-fly
5. **Download**: Generate and download clip
6. **Share**: Create share link with QR code
7. **Summary**: Generate AI summary successfully
8. **Camera Switch**: Switch between cameras smoothly

---

## Performance Optimizations

1. **Adaptive Streaming**: Auto-adjust quality based on bandwidth
2. **Preload**: Prefetch camera details while stream loads
3. **Buffer**: Implement video buffering
4. **Lazy Load**: Load other cameras on demand

---

## Security Considerations

1. **Stream URLs**: Sign URLs with expiry timestamps
2. **Share Links**: Implement access control and passwords
3. **Download Limits**: Rate limit downloads to prevent abuse

---

## Dependencies

- `video_player` - Video playback
- `chewie` - Video player UI (optional)
- `flutter_vlc_player` - Alternative HLS player
- `share_plus` - Share functionality
- `qr_flutter` - QR code generation

---

## Notes

- HLS streams provide adaptive quality
- LIVE badge indicates real-time streaming
- Consider implementing Picture-in-Picture mode
- Snapshots are generated server-side at intervals
- Download URLs expire after 1 hour for security
- Share links can be password-protected
