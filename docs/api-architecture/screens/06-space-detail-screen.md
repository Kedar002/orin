# Space Detail Screen - API Documentation

## Screen Overview
**File**: `lib/screens/spaces/space_detail_screen.dart`
**Purpose**: View and manage cameras within a specific space
**Navigation**: From Spaces Screen → Tap space card
**Design**: Camera grid with live previews for selected space

## Screen Components

### Header Section
- Back button
- Space name as title
- Space icon
- Camera count subtitle (e.g., "3 cameras")
- Edit space button (top-right menu)

### Cameras Grid
- 2-column grid of cameras in this space
- Each camera card shows:
  - Live video preview/thumbnail
  - Camera name
  - Status badge (LIVE/OFFLINE)
  - Tap → Navigate to CameraViewerScreen
  - Long press → Show quick actions menu

### Actions Menu
- Edit Space Details
- Add Cameras to Space
- Remove Space
- Manage Space Settings

### Floating Action Button (FAB)
- Plus icon
- Tap → Show "Add Camera to Space" bottom sheet

### Empty State
- Shown when space has no cameras
- Icon + message: "No cameras in this space"
- Subtitle: "Add cameras to start monitoring"
- Add Camera button

---

## API Requirements

### 1. Get Space Details
**Endpoint**: `GET /api/v1/spaces/{spaceId}`
**Timing**: Called on screen mount
**Purpose**: Fetch space details with all cameras

#### Request
```http
GET /api/v1/spaces/space_abc123?includeCameras=true&includeStats=true
Headers:
  Authorization: Bearer <access_token>
```

#### Response - Success (200)
```json
{
  "success": true,
  "data": {
    "space": {
      "id": "space_abc123",
      "name": "Hospital A",
      "icon": "hospital",
      "description": "Main hospital building",
      "cameraCount": 3,
      "onlineCameraCount": 3,
      "offlineCameraCount": 0,
      "createdAt": "2025-01-01T00:00:00Z",
      "updatedAt": "2025-12-30T10:00:00Z",
      "address": {
        "street": "123 Hospital Rd",
        "city": "Boston",
        "state": "MA",
        "zipCode": "02101",
        "country": "USA"
      },
      "timezone": "America/New_York",
      "cameras": [
        {
          "id": "cam_001",
          "name": "Main Entrance",
          "status": "online",
          "thumbnailUrl": "https://cdn.orin.app/thumbnails/cam_001_latest.jpg",
          "streamUrl": "https://stream.orin.app/live/cam_001/index.m3u8",
          "resolution": "1080p",
          "fps": 30,
          "lastSeen": "2025-12-30T10:29:55Z",
          "isRecording": true,
          "assignedGuards": ["grd_001", "grd_002"],
          "addedToSpaceAt": "2025-01-01T00:00:00Z"
        },
        {
          "id": "cam_002",
          "name": "Parking Lot",
          "status": "online",
          "thumbnailUrl": "https://cdn.orin.app/thumbnails/cam_002_latest.jpg",
          "streamUrl": "https://stream.orin.app/live/cam_002/index.m3u8",
          "resolution": "1080p",
          "fps": 30,
          "lastSeen": "2025-12-30T10:29:50Z",
          "isRecording": true,
          "assignedGuards": [],
          "addedToSpaceAt": "2025-01-01T00:00:00Z"
        },
        {
          "id": "cam_003",
          "name": "Lobby",
          "status": "online",
          "thumbnailUrl": "https://cdn.orin.app/thumbnails/cam_003_latest.jpg",
          "streamUrl": "https://stream.orin.app/live/cam_003/index.m3u8",
          "resolution": "720p",
          "fps": 25,
          "lastSeen": "2025-12-30T10:29:58Z",
          "isRecording": true,
          "assignedGuards": ["grd_001"],
          "addedToSpaceAt": "2025-01-02T00:00:00Z"
        }
      ],
      "stats": {
        "totalRecordingTime": "720h",
        "storageUsed": "156.5 GB",
        "eventsLast7Days": 45,
        "mostActiveCamera": {
          "id": "cam_001",
          "name": "Main Entrance",
          "eventCount": 25
        }
      }
    }
  }
}
```

---

### 2. Get Space Statistics
**Endpoint**: `GET /api/v1/spaces/{spaceId}/stats`
**Timing**: Called on screen mount or pull-to-refresh
**Purpose**: Fetch detailed analytics for space

#### Request
```http
GET /api/v1/spaces/space_abc123/stats?period=7d
Headers:
  Authorization: Bearer <access_token>
```

#### Query Parameters
- `period`: `24h` | `7d` | `30d` | `all` (default: 7d)

#### Response - Success (200)
```json
{
  "success": true,
  "data": {
    "spaceId": "space_abc123",
    "period": "7d",
    "stats": {
      "totalEvents": 45,
      "eventsByType": {
        "delivery": 8,
        "person": 25,
        "vehicle": 10,
        "motion": 2
      },
      "averageEventsPerDay": 6.4,
      "peakHour": "14:00",
      "storageUsed": "156.5 GB",
      "recordingTime": "720h",
      "cameraUptime": {
        "cam_001": "99.8%",
        "cam_002": "98.5%",
        "cam_003": "100%"
      },
      "mostActiveGuard": {
        "id": "grd_002",
        "name": "Visitor Monitor",
        "eventCount": 25
      }
    }
  }
}
```

---

### 3. Add Camera to Space
**Endpoint**: `POST /api/v1/spaces/{spaceId}/cameras/{cameraId}`
**Timing**: Called when user adds camera from unassigned list
**Purpose**: Assign an unassigned camera to this space

#### Request
```http
POST /api/v1/spaces/space_abc123/cameras/cam_004
Headers:
  Authorization: Bearer <access_token>
```

#### Response - Success (200)
```json
{
  "success": true,
  "data": {
    "spaceId": "space_abc123",
    "cameraId": "cam_004",
    "addedAt": "2025-12-30T10:35:00Z"
  },
  "message": "Camera added to space successfully"
}
```

---

### 4. Remove Camera from Space
**Endpoint**: `DELETE /api/v1/spaces/{spaceId}/cameras/{cameraId}`
**Timing**: Called when user removes camera from space
**Purpose**: Unassign camera (becomes unassigned)

#### Request
```http
DELETE /api/v1/spaces/space_abc123/cameras/cam_001
Headers:
  Authorization: Bearer <access_token>
```

#### Response - Success (200)
```json
{
  "success": true,
  "data": {
    "spaceId": "space_abc123",
    "cameraId": "cam_001",
    "removedAt": "2025-12-30T10:40:00Z"
  },
  "message": "Camera removed from space"
}
```

---

### 5. Update Space Details
**Endpoint**: `PUT /api/v1/spaces/{spaceId}`
**Timing**: Called from edit space modal
**Purpose**: Update space name, icon, description

#### Request
```http
PUT /api/v1/spaces/space_abc123
Headers:
  Authorization: Bearer <access_token>
  Content-Type: application/json

Body:
{
  "name": "Hospital A - Main Building",
  "icon": "hospital",
  "description": "Updated description",
  "address": {
    "street": "123 Hospital Rd",
    "city": "Boston",
    "state": "MA",
    "zipCode": "02101",
    "country": "USA"
  }
}
```

#### Response - Success (200)
```json
{
  "success": true,
  "data": {
    "space": {
      "id": "space_abc123",
      "name": "Hospital A - Main Building",
      "icon": "hospital",
      "description": "Updated description",
      "updatedAt": "2025-12-30T10:45:00Z"
    }
  },
  "message": "Space updated successfully"
}
```

---

### 6. Get Recent Events for Space
**Endpoint**: `GET /api/v1/spaces/{spaceId}/events`
**Timing**: Called to show recent activity in space
**Purpose**: Fetch events from all cameras in this space

#### Request
```http
GET /api/v1/spaces/space_abc123/events?limit=10&page=1
Headers:
  Authorization: Bearer <access_token>
```

#### Query Parameters
- `limit`: Number of events per page (default: 10, max: 50)
- `page`: Page number (default: 1)
- `type`: Filter by event type (optional)
- `startDate`: ISO 8601 date (optional)
- `endDate`: ISO 8601 date (optional)

#### Response - Success (200)
```json
{
  "success": true,
  "data": {
    "events": [
      {
        "id": "evt_001",
        "guardId": "grd_001",
        "guardName": "Package Guard",
        "cameraId": "cam_001",
        "cameraName": "Main Entrance",
        "type": "delivery",
        "title": "Package Delivered",
        "description": "A package was delivered",
        "timestamp": "2025-12-30T09:15:00Z",
        "thumbnailUrl": "https://cdn.orin.app/events/evt_001_thumb.jpg",
        "videoClipUrl": "https://cdn.orin.app/events/evt_001_clip.mp4",
        "confidence": 0.95
      }
    ],
    "pagination": {
      "currentPage": 1,
      "totalPages": 5,
      "totalEvents": 45,
      "hasNextPage": true,
      "hasPreviousPage": false
    }
  }
}
```

---

## Navigation Logic Flow

```mermaid
graph TD
    A[Space Detail Screen] --> B[GET /api/v1/spaces/{spaceId}]
    B --> C{Has Cameras?}
    C -->|Yes| D[Display Camera Grid]
    C -->|No| E[Show Empty State]
    D --> F{User Action}
    F -->|Tap Camera| G[Navigate to CameraViewerScreen]
    F -->|Long Press Camera| H[Show Quick Actions Menu]
    F -->|Tap FAB| I[Show Add Camera Modal]
    F -->|Tap Edit| J[Show Edit Space Modal]
    H --> K{Select Action}
    K -->|Remove| L[DELETE /api/v1/spaces/{spaceId}/cameras/{cameraId}]
    I --> M[POST /api/v1/spaces/{spaceId}/cameras/{cameraId}]
    J --> N[PUT /api/v1/spaces/{spaceId}]
```

---

## Local Storage Requirements

### Data to Cache
1. **Space Details** - Cache for 3 minutes
2. **Camera List** - Cache for 2 minutes
3. **Space Stats** - Cache for 5 minutes

---

## Error Handling

### Network Errors
- **No Internet**: Show cached data with offline indicator
- **Space Not Found (404)**: Navigate back to spaces list
- **Camera Already Assigned**: Show error message

### Empty States
- **No Cameras**: Show "Add cameras to this space" message
- **All Cameras Offline**: Show warning banner

---

## Analytics Events

```dart
// Space Detail Viewed
{
  "event": "space_detail_viewed",
  "spaceId": "space_abc123",
  "spaceName": "Hospital A",
  "cameraCount": 3,
  "timestamp": "2025-12-30T10:30:00Z"
}

// Camera Added to Space
{
  "event": "camera_added_to_space",
  "spaceId": "space_abc123",
  "cameraId": "cam_004",
  "timestamp": "2025-12-30T10:35:00Z"
}

// Camera Removed from Space
{
  "event": "camera_removed_from_space",
  "spaceId": "space_abc123",
  "cameraId": "cam_001",
  "timestamp": "2025-12-30T10:40:00Z"
}
```

---

## Testing Scenarios

1. **Normal Load**: Space with cameras → Show grid
2. **Empty Space**: No cameras → Show empty state
3. **Add Camera**: Add unassigned camera → Success
4. **Remove Camera**: Remove camera → Becomes unassigned
5. **Edit Space**: Update details → Success
6. **Delete Space**: Delete with cameras → Show warning
7. **Offline Cameras**: Mix of online/offline → Show status
8. **Pull to Refresh**: Reload space data

---

## Notes

- Space detail shows live camera grid similar to Command Center
- Camera thumbnails update every 30 seconds
- Long-press camera for quick remove option
- Consider showing space analytics dashboard (future enhancement)
- Support bulk camera selection for adding/removing (future)
