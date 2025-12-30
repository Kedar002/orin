# ORIN - API & Database Architecture Documentation

## 📋 Overview

This comprehensive documentation provides a complete API and database architecture design for **ORIN**, a premium CCTV surveillance mobile application with AI-powered security guards.

**Document Version**: 1.0.0
**Last Updated**: 2025-12-30
**Author**: Senior Software Architect

---

## 📱 Application Overview

**ORIN** is a Visual Intelligence Command Center that allows users to:
- Monitor multiple CCTV cameras across properties
- Deploy AI-powered "Guards" that intelligently detect specific events
- Receive smart alerts (not spam) based on what matters
- Review timeline of events with video clips and snapshots
- Organize cameras by physical spaces/locations
- Access live HLS video streams with minimal latency

---

## 🗂️ Documentation Structure

### 📺 Screen-by-Screen API Documentation

Each screen has detailed API specifications including endpoints, request/response schemas, error handling, and analytics events.

| # | Screen | File | Description |
|---|--------|------|-------------|
| 01 | **Splash Screen** | [01-splash-screen.md](./screens/01-splash-screen.md) | Session check, app config, navigation logic |
| 02 | **Onboarding** | [02-onboarding-screen.md](./screens/02-onboarding-screen.md) | 3-page onboarding flow, tracking APIs |
| 03 | **Login** | [03-login-screen.md](./screens/03-login-screen.md) | Authentication, password reset, device registration |
| 04 | **Command Center** | [04-command-center.md](./screens/04-command-center.md) | Dashboard overview, WebSocket real-time updates |
| 05 | **Spaces** | [05-spaces-screen.md](./screens/05-spaces-screen.md) | Space management, camera organization |
| 06 | **Space Detail** | [06-space-detail-screen.md](./screens/06-space-detail-screen.md) | Camera grid per space, space statistics |
| 07 | **Guards** | [07-guards-screen.md](./screens/07-guards-screen.md) | AI guard list, statistics, toggle status |
| 08 | **Create Guard** | [08-create-guard-screen.md](./screens/08-create-guard-screen.md) | 3-step wizard, AI instruction validation |
| 09 | **Guard Detail** | [09-guard-detail-screen.md](./screens/09-guard-detail-screen.md) | Guard info, recent catches, AI chat |
| 10 | **Events** | [10-events-screen.md](./screens/10-events-screen.md) | Timeline of events, filtering, grouping |
| 11 | **Camera Viewer** | [11-camera-viewer-screen.md](./screens/11-camera-viewer-screen.md) | Video player, AI summary, download, share |
| 12 | **Settings** | [12-settings-screen.md](./screens/12-settings-screen.md) | Profile, notifications, billing, system health |

---

### 🏗️ General Architecture Documentation

| Document | File | Description |
|----------|------|-------------|
| **Database Design** | [database-design.md](./general/database-design.md) | Complete scalable database schema with PostgreSQL, Redis, S3 |
| **API Endpoints Summary** | [api-endpoints-summary.md](./general/api-endpoints-summary.md) | Comprehensive list of all 64 API endpoints |
| **Architecture Overview** | [architecture-overview.md](./general/architecture-overview.md) | System architecture, microservices, deployment, scaling |

---

## 🔑 Key Features

### Database Design Highlights
- **PostgreSQL 15+** with TimescaleDB extension for time-series data
- **Monthly partitioning** for events table (handles millions of rows)
- **Redis caching** for session management and real-time data
- **S3 storage** for video clips, thumbnails, and snapshots
- **Comprehensive indexing strategy** for sub-second queries
- **Backup and disaster recovery** plan with 99.9% uptime

### API Architecture Highlights
- **64 REST endpoints** + 1 WebSocket endpoint
- **JWT authentication** with access/refresh token rotation
- **Rate limiting** to prevent abuse
- **Pagination, filtering, and sorting** for all list endpoints
- **Real-time updates** via WebSocket for dashboard
- **AI-powered features**: Guard instruction validation, video summarization

### Scalability Features
- **Horizontal scaling**: Kubernetes with auto-scaling
- **Read replicas**: 2-3 PostgreSQL replicas for read-heavy operations
- **CDN integration**: CloudFront for video delivery
- **Message queue**: RabbitMQ for async processing
- **Microservices architecture**: Independent scaling per service

---

## 📊 Technology Stack

### Frontend
- **Mobile**: Flutter 3.x (iOS/Android)
- **State Management**: Riverpod/Bloc
- **Local Database**: Hive/SQLite
- **Video Player**: video_player/flutter_vlc_player

### Backend
- **API**: FastAPI (Python) or Express.js (Node.js)
- **Database**: PostgreSQL 15+ with TimescaleDB
- **Cache**: Redis 7+
- **Storage**: AWS S3 or MinIO
- **Queue**: RabbitMQ or AWS SQS

### AI/ML
- **Framework**: PyTorch/TensorFlow
- **Computer Vision**: OpenCV, YOLO, MediaPipe
- **Model Serving**: TorchServe

### Infrastructure
- **Container Orchestration**: Kubernetes
- **CI/CD**: GitHub Actions
- **Monitoring**: Prometheus + Grafana
- **Logging**: ELK Stack or Datadog

---

## 🗄️ Database Schema Summary

### Core Tables
| Table | Purpose | Rows (Est.) | Partitioned |
|-------|---------|-------------|-------------|
| `users` | User accounts | 100K | No |
| `cameras` | Camera devices | 500K | No |
| `spaces` | Physical locations | 200K | No |
| `guards` | AI security guards | 500K | No |
| `events` | Detected events/catches | 50M+ | **Yes (Monthly)** |
| `recordings` | Video recordings metadata | 10M+ | **Yes (Monthly)** |
| `notifications` | User notifications | 20M+ | **Yes (Monthly)** |
| `snapshots` | Camera snapshots | 5M+ | **Yes (Monthly)** |

### Relationships
- `users` ← 1:N → `cameras`
- `users` ← 1:N → `spaces`
- `users` ← 1:N → `guards`
- `spaces` ← 1:N → `cameras`
- `guards` ← M:N → `cameras` (via `guard_camera_assignments`)
- `guards` ← 1:N → `events`

---

## 🔗 API Endpoint Categories

| Category | Endpoints | Description |
|----------|-----------|-------------|
| **Authentication** | 5 | Login, logout, password reset |
| **User Management** | 6 | Profile, preferences, sessions |
| **Dashboard** | 3 | Overview, real-time updates |
| **Spaces** | 9 | CRUD operations, assignments |
| **Cameras** | 9 | Stream URLs, thumbnails, sharing |
| **Guards** | 13 | CRUD, AI validation, statistics |
| **Events** | 9 | Timeline, filtering, marking read/saved |
| **Notifications** | 2 | Preferences, quiet hours |
| **Billing** | 1 | Subscription details |
| **System** | 3 | Health checks, configuration |

**Total**: 64 REST endpoints + 1 WebSocket

---

## 📈 Performance Targets

| Metric | Target | Notes |
|--------|--------|-------|
| API Response Time (p95) | < 200ms | For read operations |
| API Response Time (p99) | < 500ms | For complex queries |
| WebSocket Latency | < 100ms | Real-time updates |
| Video Stream Startup | < 2 seconds | HLS stream initialization |
| Database Query Time | < 50ms | With proper indexing |
| Cache Hit Rate | > 85% | Redis cache |
| System Uptime | 99.9% | ~8.7 hours downtime/year |

---

## 🔒 Security Measures

### Authentication & Authorization
- JWT tokens with RS256 signing
- Access token (1 hour) + Refresh token (30 days)
- Token rotation on refresh
- Session revocation on logout

### Data Protection
- AES-256 encryption at rest
- TLS 1.3 for all connections
- bcrypt password hashing (cost factor: 12)
- Signed URLs for media files with expiry

### API Security
- Rate limiting per endpoint
- CORS strict origin allowlist
- SQL injection prevention (parameterized queries)
- XSS protection (input sanitization)

---

## 📦 Deployment Architecture

### Environments
- **Development**: Local Docker Compose
- **Staging**: Kubernetes cluster (mirrors production)
- **Production**: Kubernetes cluster (multi-AZ)

### Services
- **API Service**: 4-20 pods (auto-scaling)
- **AI Processing**: 2 GPU instances (p3.2xlarge)
- **Streaming Service**: 4 pods (c5.xlarge)
- **PostgreSQL**: Primary + 2 read replicas
- **Redis**: 3-node cluster

### Infrastructure
- **Cloud Provider**: AWS/GCP/Azure
- **Container Orchestration**: Kubernetes
- **Load Balancer**: AWS ALB / Nginx
- **CDN**: CloudFront / CloudFlare

---

## 💰 Cost Estimation (10,000 users)

| Service | Monthly Cost |
|---------|--------------|
| Kubernetes (Compute) | $2,000 |
| PostgreSQL (RDS) | $800 |
| Redis (ElastiCache) | $300 |
| S3 Storage (30 TB) | $690 |
| CloudFront CDN | $500 |
| AI Processing (GPU) | $1,200 |
| Monitoring & Logs | $200 |
| **Total** | **$5,690** |

**Cost per user**: $0.57/month

---

## 🚀 Getting Started

### For Backend Developers
1. Read [Database Design](./general/database-design.md) to understand schema
2. Review [API Endpoints Summary](./general/api-endpoints-summary.md) for all endpoints
3. Study [Architecture Overview](./general/architecture-overview.md) for system design
4. Implement endpoints screen-by-screen using individual screen docs

### For Frontend Developers
1. Review screen documentation to understand required APIs
2. Implement API clients based on provided schemas
3. Handle error responses as documented
4. Implement local caching strategies as recommended

### For DevOps Engineers
1. Study [Architecture Overview](./general/architecture-overview.md)
2. Set up Kubernetes cluster with HPA
3. Configure PostgreSQL with read replicas
4. Set up Redis cluster for caching
5. Implement CI/CD pipeline as documented

---

## 📝 API Response Format

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

## 🔄 Versioning

All API endpoints are versioned:
- Current version: `/api/v1/`
- Future versions: `/api/v2/`, `/api/v3/`
- Deprecation notice: 6 months before removing old version

---

## 📞 Support & Contact

For questions or clarifications:
- **Architecture Questions**: Review [Architecture Overview](./general/architecture-overview.md)
- **Database Questions**: Review [Database Design](./general/database-design.md)
- **API Questions**: Review specific screen documentation

---

## 🎯 Next Steps

1. ✅ Review this README
2. ✅ Study database design
3. ✅ Review API endpoints summary
4. ✅ Read architecture overview
5. ⬜ Set up development environment
6. ⬜ Implement authentication service
7. ⬜ Implement core API endpoints
8. ⬜ Set up database with migrations
9. ⬜ Implement AI processing service
10. ⬜ Deploy to staging environment

---

## 📚 Additional Resources

- **PostgreSQL Partitioning**: [Official Docs](https://www.postgresql.org/docs/current/ddl-partitioning.html)
- **Redis Best Practices**: [Redis Official Guide](https://redis.io/docs/manual/scaling/)
- **HLS Streaming**: [Apple HLS Spec](https://developer.apple.com/streaming/)
- **JWT Authentication**: [jwt.io](https://jwt.io/)
- **Kubernetes Auto-scaling**: [K8s HPA](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)

---

## 📄 License

This documentation is proprietary and confidential. Unauthorized distribution is prohibited.

---

**Built with precision by a Senior Software Architect specializing in scalable systems.**

© 2025 ORIN - Your Visual Intelligence Partner
