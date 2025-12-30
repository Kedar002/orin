# Guards Screen - API Documentation

## Screen Overview
**File**: `lib/screens/guards/guards_screen.dart`
**Purpose**: View and manage AI security guards that monitor cameras
**Tab**: Third tab in AppShell bottom navigation
**Design**: List view of guards with status and statistics

## Screen Components

### Header Section
- Title: "Guards"
- Subtitle: "Your AI security team"

### Guards List
- List of all guards (active and paused)
- Each guard card shows:
  - Guard type icon (packages, people, vehicles, pets, motion, custom)
  - Guard name (e.g., "Package Guard")
  - Status dot (Active: green | Paused: gray)
  - Catches this week count (e.g., "8 catches this week")
  - Last activity time (e.g., "Active 2h ago")
  - Chevron for navigation
  - Tap → Navigate to GuardDetailScreen

### Floating Action Button (FAB)
- Plus icon button
- Tap → Navigate to CreateGuardScreen

### Empty State
- Shown when no guards exist
- Icon + message: "No guards yet"
- Subtitle: "Create a guard to start monitoring"
- Create Guard button

### Guard Types
- **Packages**: Monitor for package deliveries
- **People**: Detect persons in view
- **Vehicles**: Track vehicles entering/leaving
- **Pets**: Detect pets in areas
- **Motion**: General motion detection
- **Custom**: User-defined detection rules

---

## API Requirements

### 1. Get All Guards
**Endpoint**: `GET /api/v1/guards`
**Timing**: Called on screen mount and pull-to-refresh
**Purpose**: Fetch all user's guards with statistics

#### Request
```http
GET /api/v1/guards?includeStats=true&includeC ameras=true
Headers:
  Authorization: Bearer <access_token>
```

#### Query Parameters
- `includeStats`: Include statistics (default: true)
- `includeCameras`: Include camera details (default: false)
- `status`: Filter by `active` | `paused` | `all` (default: all)
- `sort`: `name` | `created_at` | `catches` (default: created_at)
- `order`: `asc` | `desc` (default: desc)

#### Response - Success (200)
```json
{
  "success": true,
  "data": {
    "guards": [
      {
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
        "cameraIds": ["cam_001"],
        "cameraNames": ["Main Entrance"],
        "cameraCount": 1,
        "successRate": 92
      },
      {
        "id": "grd_002",
        "name": "Visitor Monitor",
        "description": "Monitor visitors at entrance during business hours",
        "type": "people",
        "isActive": true,
        "sensitivity": 0.7,
        "catchesThisWeek": 15,
        "savedCatchesCount": 5,
        "totalCatches": 120,
        "lastDetectionAt": "2025-12-30T10:20:00Z",
        "createdAt": "2025-01-05T00:00:00Z",
        "updatedAt": "2025-12-30T10:20:00Z",
        "notifyOnDetection": true,
        "cameraIds": ["cam_001", "cam_003"],
        "cameraNames": ["Main Entrance", "Lobby"],
        "cameraCount": 2,
        "successRate": 88
      },
      {
        "id": "grd_003",
        "name": "Parking Monitor",
        "description": "Track vehicles entering parking lot",
        "type": "vehicles",
        "isActive": false,
        "sensitivity": 0.75,
        "catchesThisWeek": 0,
        "savedCatchesCount": 2,
        "totalCatches": 30,
        "lastDetectionAt": "2025-12-28T14:30:00Z",
        "createdAt": "2025-01-10T00:00:00Z",
        "updatedAt": "2025-12-29T08:00:00Z",
        "notifyOnDetection": false,
        "cameraIds": ["cam_002"],
        "cameraNames": ["Parking Lot"],
        "cameraCount": 1,
        "successRate": 85
      }
    ],
    "summary": {
      "totalGuards": 3,
      "activeGuards": 2,
      "pausedGuards": 1,
      "totalCatchesThisWeek": 23,
      "totalCatchesAllTime": 195
    }
  }
}
```

---

### 2. Get Guard Statistics
**Endpoint**: `GET /api/v1/guards/{guardId}/stats`
**Timing**: Called when user views guard details
**Purpose**: Fetch detailed statistics for a specific guard

#### Request
```http
GET /api/v1/guards/grd_001/stats?period=7d
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
    "guardId": "grd_001",
    "guardName": "Package Guard",
    "period": "7d",
    "stats": {
      "totalCatches": 8,
      "savedCatches": 3,
      "averageCatchesPerDay": 1.14,
      "peakDay": "Monday",
      "peakHour": "14:00",
      "successRate": 92,
      "falsePositiveRate": 8,
      "catchesByDay": [
        { "date": "2025-12-24", "count": 2 },
        { "date": "2025-12-25", "count": 0 },
        { "date": "2025-12-26", "count": 1 },
        { "date": "2025-12-27", "count": 3 },
        { "date": "2025-12-28", "count": 1 },
        { "date": "2025-12-29", "count": 0 },
        { "date": "2025-12-30", "count": 1 }
      ],
      "catchesByHour": {
        "00:00": 0, "01:00": 0, "02:00": 0, "03:00": 0,
        "09:00": 1, "10:00": 2, "14:00": 3, "18:00": 2
      },
      "topCameras": [
        {
          "cameraId": "cam_001",
          "cameraName": "Main Entrance",
          "catches": 8
        }
      ]
    }
  }
}
```

---

### 3. Toggle Guard Status (Active/Paused)
**Endpoint**: `PATCH /api/v1/guards/{guardId}/status`
**Timing**: Called when user toggles guard on/off
**Purpose**: Activate or pause guard monitoring

#### Request
```http
PATCH /api/v1/guards/grd_001/status
Headers:
  Authorization: Bearer <access_token>
  Content-Type: application/json

Body:
{
  "isActive": false
}
```

#### Response - Success (200)
```json
{
  "success": true,
  "data": {
    "guardId": "grd_001",
    "guardName": "Package Guard",
    "isActive": false,
    "updatedAt": "2025-12-30T10:50:00Z"
  },
  "message": "Guard paused successfully"
}
```

---

### 4. Delete Guard
**Endpoint**: `DELETE /api/v1/guards/{guardId}`
**Timing**: Called when user deletes a guard
**Purpose**: Remove guard and optionally its events

#### Request
```http
DELETE /api/v1/guards/grd_001?deleteEvents=false
Headers:
  Authorization: Bearer <access_token>
```

#### Query Parameters
- `deleteEvents`: Delete all events/catches associated with guard (default: false)

#### Response - Success (200)
```json
{
  "success": true,
  "data": {
    "guardId": "grd_001",
    "deletedAt": "2025-12-30T10:55:00Z",
    "eventsRetained": 45
  },
  "message": "Guard deleted successfully. Events were retained."
}
```

---

### 5. Get Guard Performance Metrics
**Endpoint**: `GET /api/v1/guards/performance`
**Timing**: Called for analytics dashboard (future feature)
**Purpose**: Get performance comparison across all guards

#### Request
```http
GET /api/v1/guards/performance?period=30d
Headers:
  Authorization: Bearer <access_token>
```

#### Response - Success (200)
```json
{
  "success": true,
  "data": {
    "period": "30d",
    "guards": [
      {
        "guardId": "grd_001",
        "guardName": "Package Guard",
        "totalCatches": 32,
        "successRate": 92,
        "averageCatchesPerDay": 1.07,
        "performance": "excellent"
      },
      {
        "guardId": "grd_002",
        "guardName": "Visitor Monitor",
        "totalCatches": 120,
        "successRate": 88,
        "averageCatchesPerDay": 4.0,
        "performance": "good"
      }
    ],
    "totalCatches": 152,
    "averageSuccessRate": 90,
    "mostActiveGuard": {
      "guardId": "grd_002",
      "guardName": "Visitor Monitor",
      "catches": 120
    }
  }
}
```

---

## Navigation Logic Flow

```mermaid
graph TD
    A[Guards Screen] --> B[GET /api/v1/guards]
    B --> C{Has Guards?}
    C -->|Yes| D[Display Guards List]
    C -->|No| E[Show Empty State]
    D --> F{User Action}
    F -->|Tap Guard| G[Navigate to GuardDetailScreen]
    F -->|Toggle Status| H[PATCH /api/v1/guards/{id}/status]
    F -->|Tap FAB| I[Navigate to CreateGuardScreen]
    F -->|Long Press| J[Show Delete/Edit Menu]
    J --> K{Select Action}
    K -->|Delete| L[DELETE /api/v1/guards/{id}]
    K -->|Edit| M[Navigate to EditGuardScreen]
    E --> N[Tap Create Button]
    N --> I
```

---

## Local Storage Requirements

### Data to Cache
1. **Guards List** - Cache for 2 minutes
2. **Guard Statistics** - Cache for 5 minutes
3. **Active Guard Count** - Quick access for UI

### Cache Keys (Hive)
```dart
const String CACHE_GUARDS_LIST = 'cache_guards_list';
const String CACHE_GUARDS_TIMESTAMP = 'cache_guards_timestamp';
const String CACHE_ACTIVE_GUARD_COUNT = 'cache_active_guard_count';
```

---

## Error Handling

### Network Errors
- **No Internet**: Show cached guards with offline indicator
- **Timeout**: Retry once, show error with refresh button
- **Server Error (5xx)**: Show error message with retry

### Empty States
- **No Guards**: Show "Create your first guard" empty state
- **All Guards Paused**: Show info message

---

## Analytics Events

```dart
// Guards Screen Viewed
{
  "event": "guards_screen_viewed",
  "timestamp": "2025-12-30T10:30:00Z",
  "userId": "usr_abc123xyz",
  "totalGuards": 3,
  "activeGuards": 2
}

// Guard Toggled
{
  "event": "guard_status_toggled",
  "guardId": "grd_001",
  "guardName": "Package Guard",
  "newStatus": "paused",
  "timestamp": "2025-12-30T10:50:00Z"
}

// Guard Deleted
{
  "event": "guard_deleted",
  "guardId": "grd_001",
  "guardType": "packages",
  "totalCatches": 45,
  "timestamp": "2025-12-30T10:55:00Z"
}
```

---

## Testing Scenarios

1. **Normal Load**: Show guards list
2. **Empty State**: No guards → Show create prompt
3. **Toggle Guard**: Switch on/off → Update status
4. **Delete Guard**: Confirm deletion → Remove from list
5. **Offline Mode**: Show cached guards
6. **Pull to Refresh**: Reload guards list
7. **Mixed Status**: Some active, some paused → Show correctly

---

## Security Considerations

1. **Authorization**: Users can only see/modify their own guards
2. **Soft Delete**: Implement soft delete for recovery
3. **Event Retention**: Clarify event deletion policy

---

## UI/UX Notes

- **Status Indicator**: Green dot for active, gray for paused
- **Last Activity**: Show relative time (e.g., "Active 2h ago")
- **Catches Badge**: Highlight weekly catches count
- **Swipe Actions**: Swipe left for delete, right for edit
- **Confirmation Dialog**: Ask before deleting guard
- **Success Feedback**: Show snackbar on status toggle

---

## Dependencies

- `http` or `dio` - HTTP client
- `hive` - Local caching
- `flutter_slidable` - Swipe actions
- `intl` - Date/time formatting

---

## Future Enhancements

1. **Guard Templates**: Pre-configured guard types
2. **Guard Scheduling**: Time-based activation
3. **Guard Zones**: Specific detection zones in camera view
4. **Guard Sharing**: Share guards with other users
5. **Bulk Actions**: Select multiple guards for bulk operations
6. **Performance Insights**: AI-powered recommendations

---

## Notes

- Guards are the core AI feature of ORIN
- Each guard can monitor multiple cameras
- Sensitivity range: 0.0 (low) to 1.0 (high)
- Success rate calculated from user feedback on catches
- Consider limiting max guards per user (e.g., 20 for free tier)
