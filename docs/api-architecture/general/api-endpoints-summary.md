# ORIN - Complete API Endpoints Summary

This document lists all API endpoints used across the ORIN application, organized by functional domain.

---

## Authentication & User Management

### Authentication
| Method | Endpoint | Purpose | Screen |
|--------|----------|---------|--------|
| GET | `/api/v1/auth/check-session` | Check if user has valid session | Splash |
| POST | `/api/v1/auth/login` | Login with email/password | Login |
| POST | `/api/v1/auth/logout` | Sign out current session | Settings |
| POST | `/api/v1/auth/forgot-password` | Initiate password reset | Login |
| POST | `/api/v1/auth/resend-verification` | Resend email verification | Login |

### User Profile
| Method | Endpoint | Purpose | Screen |
|--------|----------|---------|--------|
| GET | `/api/v1/user/profile` | Get user profile | Settings |
| PUT | `/api/v1/user/profile` | Update user profile | Settings |
| POST | `/api/v1/user/change-password` | Change password | Settings |
| GET | `/api/v1/user/onboarding-status` | Check onboarding completion | Splash |

### User Sessions
| Method | Endpoint | Purpose | Screen |
|--------|----------|---------|--------|
| GET | `/api/v1/user/sessions` | Get active sessions | Settings |
| DELETE | `/api/v1/user/sessions/{sessionId}` | Revoke session | Settings |

---

## Dashboard & Command Center

| Method | Endpoint | Purpose | Screen |
|--------|----------|---------|--------|
| GET | `/api/v1/dashboard/overview` | Get dashboard data (cameras, guards, events) | Command Center |
| GET | `/api/v1/cameras/status` | Get real-time camera status | Command Center |
| WS | `wss://api.orin.app/v1/ws/dashboard` | WebSocket for real-time updates | Command Center |

---

## Spaces Management

| Method | Endpoint | Purpose | Screen |
|--------|----------|---------|--------|
| GET | `/api/v1/spaces` | Get all spaces | Spaces |
| POST | `/api/v1/spaces` | Create new space | Spaces |
| GET | `/api/v1/spaces/{spaceId}` | Get space details | Space Detail |
| PUT | `/api/v1/spaces/{spaceId}` | Update space | Space Detail |
| DELETE | `/api/v1/spaces/{spaceId}` | Delete space | Spaces |
| GET | `/api/v1/spaces/{spaceId}/stats` | Get space statistics | Space Detail |
| GET | `/api/v1/spaces/{spaceId}/events` | Get events for space | Space Detail |
| POST | `/api/v1/spaces/{spaceId}/cameras/{cameraId}` | Add camera to space | Space Detail |
| DELETE | `/api/v1/spaces/{spaceId}/cameras/{cameraId}` | Remove camera from space | Space Detail |

---

## Camera Management

| Method | Endpoint | Purpose | Screen |
|--------|----------|---------|--------|
| GET | `/api/v1/cameras` | Get all cameras | Create Guard |
| GET | `/api/v1/cameras/unassigned` | Get unassigned cameras | Spaces |
| GET | `/api/v1/cameras/{cameraId}` | Get camera details | Camera Viewer |
| GET | `/api/v1/cameras/{cameraId}/stream` | Get HLS stream URL | Camera Viewer |
| GET | `/api/v1/cameras/{cameraId}/thumbnail` | Get latest camera thumbnail | Command Center |
| POST | `/api/v1/cameras/{cameraId}/summarize` | Generate AI summary | Camera Viewer |
| POST | `/api/v1/cameras/{cameraId}/download` | Download video clip | Camera Viewer |
| GET | `/api/v1/cameras/{cameraId}/snapshots` | Get recent snapshots | Camera Viewer |
| POST | `/api/v1/cameras/{cameraId}/share` | Create share link | Camera Viewer |

---

## Guards Management

| Method | Endpoint | Purpose | Screen |
|--------|----------|---------|--------|
| GET | `/api/v1/guards` | Get all guards | Guards |
| POST | `/api/v1/guards` | Create new guard | Create Guard |
| GET | `/api/v1/guards/{guardId}` | Get guard details | Guard Detail |
| PUT | `/api/v1/guards/{guardId}` | Update guard | Edit Guard |
| DELETE | `/api/v1/guards/{guardId}` | Delete guard | Guards |
| PATCH | `/api/v1/guards/{guardId}/status` | Toggle guard active/paused | Guards, Guard Detail |
| GET | `/api/v1/guards/{guardId}/stats` | Get guard statistics | Guards |
| GET | `/api/v1/guards/{guardId}/catches` | Get guard catches/events | Guard Detail |
| GET | `/api/v1/guards/active` | Get active guards only | Command Center |
| GET | `/api/v1/guards/performance` | Get performance metrics | Guards |
| POST | `/api/v1/guards/validate-instructions` | Validate guard instructions (AI) | Create Guard |
| POST | `/api/v1/guards/recommend-type` | Get guard type recommendation (AI) | Create Guard |
| POST | `/api/v1/guards/{guardId}/chat` | AI chat with guard (future) | Guard Detail |

---

## Events/Catches Management

| Method | Endpoint | Purpose | Screen |
|--------|----------|---------|--------|
| GET | `/api/v1/events` | Get all events (paginated, grouped) | Events |
| GET | `/api/v1/events/recent` | Get recent events (limited) | Command Center |
| GET | `/api/v1/events/{eventId}` | Get event details | Event Detail |
| POST | `/api/v1/events/{eventId}/mark-read` | Mark event as read | Events, Event Detail |
| POST | `/api/v1/events/mark-all-read` | Mark all events as read | Events |
| POST | `/api/v1/events/{eventId}/toggle-save` | Save/unsave event | Events |
| DELETE | `/api/v1/events/{eventId}` | Delete event | Events |
| POST | `/api/v1/events/{eventId}/note` | Add note to event | Events |
| GET | `/api/v1/events/stats` | Get event statistics | Events |

---

## Notifications

| Method | Endpoint | Purpose | Screen |
|--------|----------|---------|--------|
| GET | `/api/v1/user/notifications/preferences` | Get notification preferences | Settings |
| PUT | `/api/v1/user/notifications/preferences` | Update notification preferences | Settings |

---

## Devices

| Method | Endpoint | Purpose | Screen |
|--------|----------|---------|--------|
| POST | `/api/v1/devices/register` | Register device for push notifications | Login |

---

## Billing & Subscription

| Method | Endpoint | Purpose | Screen |
|--------|----------|---------|--------|
| GET | `/api/v1/billing/subscription` | Get subscription details | Settings |

---

## System & Configuration

| Method | Endpoint | Purpose | Screen |
|--------|----------|---------|--------|
| GET | `/api/v1/config/app` | Get app configuration & feature flags | Splash |
| GET | `/api/v1/system/health` | Get system health status | Settings |
| GET | `/api/v1/health` | API health check | Login |

---

## Onboarding & Analytics

| Method | Endpoint | Purpose | Screen |
|--------|----------|---------|--------|
| POST | `/api/v1/user/onboarding/track` | Track onboarding progress | Onboarding |
| POST | `/api/v1/user/onboarding/complete` | Mark onboarding as complete | Onboarding |
| GET | `/api/v1/assets/prefetch` | Prefetch assets for next screen | Onboarding |

---

## API Endpoint Statistics

### Total Endpoints by Category
- **Authentication**: 5 endpoints
- **User Management**: 6 endpoints
- **Dashboard**: 3 endpoints
- **Spaces**: 9 endpoints
- **Cameras**: 9 endpoints
- **Guards**: 13 endpoints
- **Events**: 9 endpoints
- **Notifications**: 2 endpoints
- **Devices**: 1 endpoint
- **Billing**: 1 endpoint
- **System**: 3 endpoints
- **Onboarding**: 3 endpoints

**Total**: 64 REST endpoints + 1 WebSocket endpoint

---

## HTTP Methods Distribution

- **GET**: 35 endpoints (54.7%)
- **POST**: 20 endpoints (31.2%)
- **PUT**: 4 endpoints (6.2%)
- **DELETE**: 4 endpoints (6.2%)
- **PATCH**: 1 endpoint (1.6%)

---

## Authentication Requirements

### Public Endpoints (No Auth)
- `GET /api/v1/health`
- `POST /api/v1/auth/login`
- `POST /api/v1/auth/forgot-password`
- `POST /api/v1/auth/resend-verification`

### Authenticated Endpoints (Bearer Token)
All other endpoints require `Authorization: Bearer <access_token>` header.

---

## Rate Limiting Recommendations

| Endpoint Category | Rate Limit |
|-------------------|------------|
| Authentication | 5 requests/min per IP |
| Login Attempts | 5 attempts/15 min per email |
| Guard Creation | 10 requests/hour per user |
| Space Creation | 10 requests/hour per user |
| Event Queries | 100 requests/min per user |
| Dashboard | 30 requests/min per user |
| Video Downloads | 10 downloads/hour per user |
| AI Summarize | 20 requests/hour per user |

---

## Versioning Strategy

All endpoints are versioned with `/v1/` in the path:
- Current version: `v1`
- Future versions: `v2`, `v3`, etc.
- Deprecation notice: 6 months before removing old version

---

## Response Format

All API responses follow this structure:

### Success Response
```json
{
  "success": true,
  "data": { /* response data */ },
  "message": "Optional success message"
}
```

### Error Response
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message",
    "field": "fieldName",
    "validationErrors": []
  }
}
```

---

## Common HTTP Status Codes

| Code | Meaning | Usage |
|------|---------|-------|
| 200 | OK | Successful GET, PUT, PATCH, DELETE |
| 201 | Created | Successful POST (resource created) |
| 400 | Bad Request | Validation error, malformed request |
| 401 | Unauthorized | Missing or invalid authentication token |
| 403 | Forbidden | User doesn't have permission |
| 404 | Not Found | Resource not found |
| 409 | Conflict | Duplicate resource (e.g., email exists) |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Internal Server Error | Server-side error |
| 503 | Service Unavailable | Maintenance mode |

---

## Pagination

Endpoints that return lists support pagination:

### Query Parameters
- `page`: Page number (default: 1)
- `limit`: Items per page (default: 20, max: 100)

### Response Format
```json
{
  "success": true,
  "data": {
    "items": [],
    "pagination": {
      "currentPage": 1,
      "totalPages": 10,
      "totalItems": 200,
      "hasNextPage": true,
      "hasPreviousPage": false
    }
  }
}
```

---

## Filtering & Sorting

Many endpoints support filtering and sorting:

### Common Query Parameters
- `sort`: Field to sort by (e.g., `created_at`, `name`)
- `order`: `asc` or `desc` (default: `desc`)
- `filter`: JSON string for complex filtering

### Example
```
GET /api/v1/events?sort=timestamp&order=desc&type=delivery
```

---

## WebSocket Protocol

### Connection
```
URL: wss://api.orin.app/v1/ws/dashboard
Headers: Authorization: Bearer <access_token>
```

### Message Types
- `camera_status`: Real-time camera status updates
- `event_detected`: New event/catch detected
- `guard_status_changed`: Guard activated/paused
- `ping/pong`: Heartbeat

---

## Notes

1. All timestamps are in ISO 8601 format with timezone (e.g., `2025-12-30T10:30:00Z`)
2. All UUIDs are version 4 (random)
3. File URLs (thumbnails, videos) are signed with expiry timestamps
4. Implement request/response logging for debugging
5. Use correlation IDs for request tracing across services
6. Implement API documentation with Swagger/OpenAPI
