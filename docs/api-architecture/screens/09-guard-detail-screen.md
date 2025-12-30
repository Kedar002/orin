# Guard Detail Screen - API Documentation

## Screen Overview
**File**: `lib/screens/guards/guard_detail_screen.dart`
**Purpose**: View guard details, recent catches, and interact with AI chat
**Navigation**: From Guards Screen → Tap guard card
**Design**: Conversation-style interface with guard info and catches

## Screen Components

### Header
- Back button
- Guard name as title
- Status toggle (Active/Paused)
- Edit button (top-right menu)

### Guard Info Card
- Guard type icon
- Guard name
- Description/Instructions
- Cameras assigned (with icons/names)
- Statistics (catches this week, success rate)

### Recent Catches Section
- List of recent catches from this guard (last 10)
- Each catch shows:
  - Thumbnail with play icon
  - Event title
  - Camera name & timestamp
  - Tap → Navigate to EventDetailScreen

### AI Chat Interface (Future Feature)
- Draggable bottom sheet
- Chat input field
- Ask questions about guard's performance
- Examples: "What did you catch today?", "Show me the most important catches"

---

## API Requirements

### 1. Get Guard Details
**Endpoint**: `GET /api/v1/guards/{guardId}`
**Timing**: Called on screen mount
**Purpose**: Fetch complete guard information

#### Request
```http
GET /api/v1/guards/grd_001?includeCameras=true&includeStats=true&includeRecentCatches=true
Headers:
  Authorization: Bearer <access_token>
```

#### Response - Success (200)
```json
{
  "success": true,
  "data": {
    "guard": {
      "id": "grd_001",
      "name": "Package Guard",
      "description": "Alert me when packages are delivered to the front door",
      "type": "packages",
      "isActive": true,
      "sensitivity": 0.8,
      "catchesThisWeek": 8,
      "savedCatchesCount": 3,
      "totalCatches": 45,
      "lastDetectionAt": "2025-12-30T09:15:00Z",
      "createdAt": "2025-01-01T00:00:00Z",
      "updatedAt": "2025-12-30T09:15:00Z",
      "notifyOnDetection": true,
      "successRate": 92,
      "cameras": [
        {
          "id": "cam_001",
          "name": "Main Entrance",
          "spaceId": "space_abc123",
          "spaceName": "Hospital A",
          "status": "online"
        }
      ],
      "recentCatches": [
        {
          "id": "evt_001",
          "cameraId": "cam_001",
          "cameraName": "Main Entrance",
          "type": "delivery",
          "title": "Package Delivered",
          "timestamp": "2025-12-30T09:15:00Z",
          "thumbnailUrl": "https://cdn.orin.app/events/evt_001_thumb.jpg",
          "confidence": 0.95,
          "isSaved": false
        }
      ],
      "stats": {
        "averageCatchesPerDay": 1.07,
        "peakDay": "Monday",
        "peakHour": "14:00",
        "falsePositiveRate": 8
      }
    }
  }
}
```

---

### 2. Get Guard Catches
**Endpoint**: `GET /api/v1/guards/{guardId}/catches`
**Timing**: Called on screen mount and pagination
**Purpose**: Fetch all catches from this guard

#### Request
```http
GET /api/v1/guards/grd_001/catches?limit=20&page=1&saved=false
Headers:
  Authorization: Bearer <access_token>
```

#### Query Parameters
- `limit`: Number of catches per page (default: 20, max: 50)
- `page`: Page number (default: 1)
- `saved`: Filter by saved status (optional)
- `startDate`: ISO 8601 date (optional)
- `endDate`: ISO 8601 date (optional)

#### Response - Success (200)
```json
{
  "success": true,
  "data": {
    "catches": [
      {
        "id": "evt_001",
        "guardId": "grd_001",
        "cameraId": "cam_001",
        "cameraName": "Main Entrance",
        "type": "delivery",
        "title": "Package Delivered",
        "description": "A package was delivered",
        "timestamp": "2025-12-30T09:15:00Z",
        "thumbnailUrl": "https://cdn.orin.app/events/evt_001_thumb.jpg",
        "videoClipUrl": "https://cdn.orin.app/events/evt_001_clip.mp4",
        "confidence": 0.95,
        "isSaved": false,
        "userNote": null
      }
    ],
    "pagination": {
      "currentPage": 1,
      "totalPages": 3,
      "totalCatches": 45,
      "hasNextPage": true
    }
  }
}
```

---

### 3. Update Guard
**Endpoint**: `PUT /api/v1/guards/{guardId}`
**Timing**: Called from Edit Guard Screen
**Purpose**: Update guard details

#### Request
```http
PUT /api/v1/guards/grd_001
Headers:
  Authorization: Bearer <access_token>
  Content-Type: application/json

Body:
{
  "name": "Updated Package Guard",
  "description": "Updated instructions",
  "sensitivity": 0.9,
  "notifyOnDetection": true,
  "cameraIds": ["cam_001", "cam_002"]
}
```

#### Response - Success (200)
```json
{
  "success": true,
  "data": {
    "guard": {
      "id": "grd_001",
      "name": "Updated Package Guard",
      "updatedAt": "2025-12-30T11:05:00Z"
    }
  },
  "message": "Guard updated successfully"
}
```

---

### 4. Toggle Guard Status
**Endpoint**: `PATCH /api/v1/guards/{guardId}/status`
**Timing**: Called when user toggles status switch
**Purpose**: Activate or pause guard

(See Guards Screen documentation for details)

---

### 5. Delete Guard
**Endpoint**: `DELETE /api/v1/guards/{guardId}`
**Timing**: Called from menu options
**Purpose**: Remove guard

(See Guards Screen documentation for details)

---

### 6. AI Chat with Guard (Future Feature)
**Endpoint**: `POST /api/v1/guards/{guardId}/chat`
**Timing**: Called when user sends chat message
**Purpose**: Natural language queries about guard performance

#### Request
```http
POST /api/v1/guards/grd_001/chat
Headers:
  Authorization: Bearer <access_token>
  Content-Type: application/json

Body:
{
  "message": "What did you catch today?",
  "context": {
    "conversationId": "conv_abc123",
    "previousMessages": []
  }
}
```

#### Response - Success (200)
```json
{
  "success": true,
  "data": {
    "response": "Today I caught 3 package deliveries at the Main Entrance. The first one was at 9:15 AM, the second at 11:30 AM, and the third at 2:45 PM. All were detected with high confidence (>90%).",
    "catches": [
      {
        "id": "evt_001",
        "timestamp": "2025-12-30T09:15:00Z",
        "title": "Package Delivered"
      }
    ],
    "conversationId": "conv_abc123"
  }
}
```

---

## Navigation Logic Flow

```mermaid
graph TD
    A[Guard Detail Screen] --> B[GET /api/v1/guards/{id}]
    B --> C[Display Guard Info & Catches]
    C --> D{User Action}
    D -->|Toggle Status| E[PATCH /api/v1/guards/{id}/status]
    D -->|Tap Edit| F[Navigate to EditGuardScreen]
    D -->|Tap Catch| G[Navigate to EventDetailScreen]
    D -->|Delete Guard| H[DELETE /api/v1/guards/{id}]
    D -->|View All Catches| I[Navigate to CatchesScreen]
```

---

## Analytics Events

```dart
// Guard Detail Viewed
{
  "event": "guard_detail_viewed",
  "guardId": "grd_001",
  "guardName": "Package Guard",
  "catchCount": 45,
  "timestamp": "2025-12-30T11:00:00Z"
}

// Guard Status Toggled
{
  "event": "guard_status_toggled_from_detail",
  "guardId": "grd_001",
  "newStatus": "paused",
  "timestamp": "2025-12-30T11:05:00Z"
}

// Catch Tapped
{
  "event": "catch_tapped_from_guard_detail",
  "guardId": "grd_001",
  "catchId": "evt_001",
  "timestamp": "2025-12-30T11:10:00Z"
}
```

---

## Notes

- Guard detail is the main hub for monitoring a specific guard's activity
- Recent catches section shows last 10 for quick overview
- AI chat feature is planned for future release
- Consider adding performance graphs (catches over time)
- Allow quick navigation to cameras assigned to this guard
