# Events Screen - API Documentation

## Screen Overview
**File**: `lib/screens/events/events_screen.dart`
**Purpose**: Timeline view of all detected events/catches across all guards
**Tab**: Fourth tab in AppShell bottom navigation
**Design**: Grouped timeline list with event cards

## Screen Components

### Header
- Title: "Events"
- Filter button (top-right)
- Unread badge count

### Event Timeline
- Events grouped by time periods:
  - **Today**
  - **Yesterday**
  - **This Week**
  - **Earlier**
- Each event shows:
  - Thumbnail with play icon
  - Event title (e.g., "Package Delivered")
  - Guard name that detected it
  - Location (camera/space name)
  - Relative time (e.g., "2h ago")
  - Unread indicator dot
  - Tap → Navigate to EventDetailScreen

### Filter Options (Modal)
- Filter by guard type
- Filter by camera/space
- Filter by time range
- Show only unread
- Show only saved

### Empty State
- Shown when no events exist
- Icon + message: "No events yet"
- Subtitle: "Events will appear here when your guards detect something"

---

## API Requirements

### 1. Get All Events
**Endpoint**: `GET /api/v1/events`
**Timing**: Called on screen mount and pull-to-refresh
**Purpose**: Fetch all events with grouping support

#### Request
```http
GET /api/v1/events?limit=50&page=1&groupBy=date&includeRead=true
Headers:
  Authorization: Bearer <access_token>
```

#### Query Parameters
- `limit`: Number of events per page (default: 50, max: 100)
- `page`: Page number (default: 1)
- `groupBy`: `date` | `guard` | `camera` | `none` (default: date)
- `includeRead`: Include read events (default: true)
- `saved`: Filter by saved status (optional)
- `guardId`: Filter by specific guard (optional)
- `cameraId`: Filter by specific camera (optional)
- `type`: Filter by event type (delivery, person, vehicle, etc.)
- `startDate`: ISO 8601 date (optional)
- `endDate`: ISO 8601 date (optional)
- `sortOrder`: `desc` | `asc` (default: desc)

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
        "spaceId": "space_abc123",
        "spaceName": "Hospital A",
        "type": "delivery",
        "title": "Package Delivered",
        "description": "A package was delivered to the main entrance",
        "timestamp": "2025-12-30T09:15:00Z",
        "thumbnailUrl": "https://cdn.orin.app/events/evt_001_thumb.jpg",
        "videoClipUrl": "https://cdn.orin.app/events/evt_001_clip.mp4",
        "confidence": 0.95,
        "isSaved": false,
        "isRead": true,
        "userNote": null,
        "dateGroup": "today"
      },
      {
        "id": "evt_002",
        "guardId": "grd_002",
        "guardName": "Visitor Monitor",
        "cameraId": "cam_001",
        "cameraName": "Main Entrance",
        "spaceId": "space_abc123",
        "spaceName": "Hospital A",
        "type": "person",
        "title": "Person Detected",
        "description": "Person detected at entrance",
        "timestamp": "2025-12-29T14:30:00Z",
        "thumbnailUrl": "https://cdn.orin.app/events/evt_002_thumb.jpg",
        "videoClipUrl": "https://cdn.orin.app/events/evt_002_clip.mp4",
        "confidence": 0.88,
        "isSaved": true,
        "isRead": false,
        "userNote": "Important visitor",
        "dateGroup": "yesterday"
      }
    ],
    "groupedEvents": {
      "today": [
        {
          "id": "evt_001",
          "title": "Package Delivered",
          "timestamp": "2025-12-30T09:15:00Z"
        }
      ],
      "yesterday": [
        {
          "id": "evt_002",
          "title": "Person Detected",
          "timestamp": "2025-12-29T14:30:00Z"
        }
      ],
      "thisWeek": [],
      "earlier": []
    },
    "pagination": {
      "currentPage": 1,
      "totalPages": 10,
      "totalEvents": 487,
      "hasNextPage": true
    },
    "summary": {
      "totalEvents": 487,
      "unreadEvents": 12,
      "savedEvents": 23,
      "eventsToday": 8,
      "eventsThisWeek": 56
    }
  }
}
```

---

### 2. Mark Event as Read
**Endpoint**: `POST /api/v1/events/{eventId}/mark-read`
**Timing**: Called when user views event details
**Purpose**: Update read status

#### Request
```http
POST /api/v1/events/evt_001/mark-read
Headers:
  Authorization: Bearer <access_token>
```

#### Response - Success (200)
```json
{
  "success": true,
  "data": {
    "eventId": "evt_001",
    "isRead": true,
    "readAt": "2025-12-30T11:00:00Z"
  }
}
```

---

### 3. Mark All Events as Read
**Endpoint**: `POST /api/v1/events/mark-all-read`
**Timing**: Called from menu option
**Purpose**: Bulk update all unread events

#### Request
```http
POST /api/v1/events/mark-all-read
Headers:
  Authorization: Bearer <access_token>
```

#### Response - Success (200)
```json
{
  "success": true,
  "data": {
    "eventsMarked": 12,
    "markedAt": "2025-12-30T11:05:00Z"
  },
  "message": "All events marked as read"
}
```

---

### 4. Toggle Save Event
**Endpoint**: `POST /api/v1/events/{eventId}/toggle-save`
**Timing**: Called when user saves/unsaves event
**Purpose**: Save important events for later review

#### Request
```http
POST /api/v1/events/evt_001/toggle-save
Headers:
  Authorization: Bearer <access_token>
```

#### Response - Success (200)
```json
{
  "success": true,
  "data": {
    "eventId": "evt_001",
    "isSaved": true,
    "savedAt": "2025-12-30T11:10:00Z"
  }
}
```

---

### 5. Delete Event
**Endpoint**: `DELETE /api/v1/events/{eventId}`
**Timing**: Called from event options menu
**Purpose**: Remove event from history

#### Request
```http
DELETE /api/v1/events/evt_001
Headers:
  Authorization: Bearer <access_token>
```

#### Response - Success (200)
```json
{
  "success": true,
  "data": {
    "eventId": "evt_001",
    "deletedAt": "2025-12-30T11:15:00Z"
  },
  "message": "Event deleted successfully"
}
```

---

### 6. Add Note to Event
**Endpoint**: `POST /api/v1/events/{eventId}/note`
**Timing**: Called when user adds/updates note
**Purpose**: Add custom notes to events

#### Request
```http
POST /api/v1/events/evt_001/note
Headers:
  Authorization: Bearer <access_token>
  Content-Type: application/json

Body:
{
  "note": "This was the delivery I was expecting"
}
```

#### Response - Success (200)
```json
{
  "success": true,
  "data": {
    "eventId": "evt_001",
    "note": "This was the delivery I was expecting",
    "updatedAt": "2025-12-30T11:20:00Z"
  }
}
```

---

### 7. Get Event Statistics
**Endpoint**: `GET /api/v1/events/stats`
**Timing**: Called for analytics view (future)
**Purpose**: Fetch event statistics and trends

#### Request
```http
GET /api/v1/events/stats?period=7d
Headers:
  Authorization: Bearer <access_token>
```

#### Response - Success (200)
```json
{
  "success": true,
  "data": {
    "period": "7d",
    "stats": {
      "totalEvents": 56,
      "eventsByType": {
        "delivery": 12,
        "person": 28,
        "vehicle": 14,
        "motion": 2
      },
      "eventsByDay": [
        { "date": "2025-12-24", "count": 8 },
        { "date": "2025-12-25", "count": 4 },
        { "date": "2025-12-26", "count": 9 }
      ],
      "peakHour": "14:00",
      "averagePerDay": 8,
      "mostActiveGuard": {
        "guardId": "grd_002",
        "guardName": "Visitor Monitor",
        "eventCount": 28
      },
      "mostActiveCamera": {
        "cameraId": "cam_001",
        "cameraName": "Main Entrance",
        "eventCount": 35
      }
    }
  }
}
```

---

## Navigation Logic Flow

```mermaid
graph TD
    A[Events Screen] --> B[GET /api/v1/events]
    B --> C[Display Grouped Timeline]
    C --> D{User Action}
    D -->|Tap Event| E[Navigate to EventDetailScreen]
    D -->|Long Press| F[Show Quick Actions Menu]
    D -->|Filter| G[Apply Filters & Reload]
    D -->|Mark All Read| H[POST /api/v1/events/mark-all-read]
    F --> I{Select Action}
    I -->|Save| J[POST /api/v1/events/{id}/toggle-save]
    I -->|Delete| K[DELETE /api/v1/events/{id}]
    I -->|Add Note| L[POST /api/v1/events/{id}/note]
```

---

## Local Caching

### Data to Cache
1. **Events List** - Cache for 1 minute
2. **Unread Count** - Cache for 30 seconds
3. **Filter Settings** - Persistent

---

## Analytics Events

```dart
// Events Screen Viewed
{
  "event": "events_screen_viewed",
  "totalEvents": 487,
  "unreadCount": 12,
  "timestamp": "2025-12-30T11:00:00Z"
}

// Event Marked as Read
{
  "event": "event_marked_read",
  "eventId": "evt_001",
  "timestamp": "2025-12-30T11:00:30Z"
}

// Event Saved
{
  "event": "event_saved",
  "eventId": "evt_001",
  "timestamp": "2025-12-30T11:05:00Z"
}

// Filter Applied
{
  "event": "events_filter_applied",
  "filters": {
    "guardId": "grd_001",
    "showUnreadOnly": true
  },
  "timestamp": "2025-12-30T11:10:00Z"
}
```

---

## Testing Scenarios

1. **Normal Load**: Show grouped events
2. **Empty State**: No events → Show empty message
3. **Mark as Read**: Tap event → Mark read
4. **Save Event**: Long press → Save
5. **Filter Events**: Apply filter → Show filtered list
6. **Infinite Scroll**: Scroll to bottom → Load more
7. **Pull to Refresh**: Refresh events list

---

## UI/UX Notes

- **Unread Indicator**: Blue dot for unread events
- **Date Grouping**: Clear section headers
- **Infinite Scroll**: Lazy load on scroll
- **Swipe Actions**: Swipe left to delete, right to save
- **Empty State**: Clear call-to-action
- **Loading State**: Shimmer effect while loading

---

## Notes

- Events are the core output of guard monitoring
- Group by date for better timeline visualization
- Unread count should update in real-time via WebSocket
- Consider implementing search functionality
- Allow bulk actions (delete multiple, mark multiple as read)
- Events older than 30 days may be archived for performance
