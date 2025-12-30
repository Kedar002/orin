# ORIN - System Architecture Overview

## Executive Summary

ORIN is a cloud-native, AI-powered CCTV surveillance platform designed for scalability, real-time processing, and intelligent monitoring. This document outlines the complete system architecture, technology stack, and deployment strategy.

---

## System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                         CLIENT APPLICATIONS                          │
├─────────────────────────────────────────────────────────────────────┤
│  Flutter Mobile App (iOS/Android)   │   Web App (React/Next.js)    │
└──────────────────┬──────────────────┴───────────────┬───────────────┘
                   │                                   │
                   │         HTTPS/WSS                 │
                   │                                   │
┌──────────────────▼───────────────────────────────────▼───────────────┐
│                          API GATEWAY                                 │
│  - Rate Limiting      - Authentication      - Load Balancing         │
│  - SSL Termination    - Request Routing     - CORS                   │
└──────────────────┬───────────────────────────────────────────────────┘
                   │
       ┌───────────┼───────────┬───────────────────────┐
       │           │           │                       │
┌──────▼──────┐ ┌──▼────────┐ ┌▼──────────────┐ ┌────▼─────────┐
│   Auth      │ │  API      │ │  WebSocket    │ │  Admin       │
│  Service    │ │ Service   │ │   Service     │ │  Service     │
│             │ │           │ │               │ │              │
│ - Login     │ │ - Guards  │ │ - Real-time   │ │ - Analytics  │
│ - Register  │ │ - Cameras │ │ - Events      │ │ - Monitoring │
│ - OAuth     │ │ - Events  │ │ - Status      │ │ - Logs       │
└──────┬──────┘ └──┬────────┘ └┬──────────────┘ └────┬─────────┘
       │           │            │                     │
       └───────────┼────────────┴─────────────────────┘
                   │
        ┌──────────┼──────────┬──────────────────────┐
        │          │          │                      │
  ┌─────▼─────┐ ┌──▼──────┐ ┌▼────────────┐  ┌─────▼──────┐
  │PostgreSQL │ │  Redis  │ │ RabbitMQ    │  │    S3      │
  │ Database  │ │  Cache  │ │ Message     │  │  Storage   │
  │           │ │         │ │ Queue       │  │            │
  │ - Users   │ │-Session │ │ - Jobs      │  │ - Videos   │
  │ - Guards  │ │-Cache   │ │ - Events    │  │ - Thumbs   │
  │ - Events  │ │-Locks   │ │ - Emails    │  │ - Images   │
  └───────────┘ └─────────┘ └─────────────┘  └────────────┘
                                │
                    ┌───────────┴───────────┐
                    │                       │
            ┌───────▼────────┐     ┌───────▼────────┐
            │  AI Processing │     │   Streaming    │
            │    Service     │     │    Service     │
            │                │     │                │
            │ - Detection    │     │ - HLS Encode   │
            │ - Analysis     │     │ - RTSP Input   │
            │ - Training     │     │ - Transcoding  │
            └────────────────┘     └────────────────┘
```

---

## Technology Stack

### Frontend

#### Mobile Application (Flutter)
- **Framework**: Flutter 3.x
- **State Management**: Riverpod / Bloc
- **Local Database**: Hive / SQLite
- **HTTP Client**: Dio
- **Video Player**: video_player / flutter_vlc_player
- **Push Notifications**: Firebase Cloud Messaging (FCM)
- **Analytics**: Firebase Analytics / Mixpanel

#### Web Application (Future)
- **Framework**: Next.js 14 (React)
- **UI Library**: Tailwind CSS / shadcn/ui
- **State Management**: Zustand / Redux Toolkit
- **Video Player**: Video.js / HLS.js
- **Real-time**: Socket.IO

---

### Backend Services

#### API Service (Primary)
- **Language**: Python 3.11+ or Node.js 20+
- **Framework**: FastAPI (Python) or Express.js (Node.js)
- **ORM**: SQLAlchemy (Python) or Prisma (Node.js)
- **Validation**: Pydantic (Python) or Zod (Node.js)
- **Authentication**: JWT (Access/Refresh tokens)
- **API Documentation**: Swagger/OpenAPI

#### AI Processing Service
- **Language**: Python 3.11+
- **ML Framework**: PyTorch / TensorFlow
- **Computer Vision**: OpenCV, YOLO, MediaPipe
- **Model Serving**: TorchServe / TensorFlow Serving
- **GPU Support**: CUDA-enabled for inference

#### Streaming Service
- **Protocol**: RTSP → HLS/DASH conversion
- **Tools**: FFmpeg, GStreamer
- **CDN**: CloudFront / CloudFlare
- **Adaptive Bitrate**: Multiple quality levels

#### WebSocket Service
- **Framework**: Socket.IO / uWebSockets.js
- **Protocol**: WebSocket (WSS)
- **Pub/Sub**: Redis Pub/Sub for scaling
- **Heartbeat**: Ping/Pong every 30 seconds

---

### Databases & Storage

#### PostgreSQL 15+
- **Primary Database**: All structured data
- **Extensions**: TimescaleDB (time-series), pgvector (embeddings)
- **Replication**: Primary + 2 read replicas
- **Connection Pooling**: PgBouncer
- **Backup**: Automated daily backups with PITR

#### Redis 7+
- **Session Store**: User sessions with TTL
- **Cache Layer**: API responses, dashboard data
- **Rate Limiting**: Token bucket algorithm
- **Pub/Sub**: Real-time event distribution
- **Persistence**: RDB + AOF for durability

#### S3-Compatible Storage
- **Provider**: AWS S3 / MinIO / DigitalOcean Spaces
- **Content**: Video recordings, snapshots, thumbnails
- **Lifecycle**: Auto-archive to Glacier after 90 days
- **CDN**: CloudFront for fast delivery
- **Signed URLs**: Temporary access with expiry

#### Elasticsearch (Optional)
- **Use Case**: Advanced event search, full-text search
- **Indexing**: Events, logs, analytics
- **Kibana**: Data visualization

---

### Message Queue & Processing

#### RabbitMQ / AWS SQS
- **Event Processing**: Asynchronous event handling
- **Email Queue**: Transactional emails
- **Notification Queue**: Push notifications
- **AI Processing Queue**: Guard detection jobs
- **Dead Letter Queue**: Failed message handling

#### Celery (Python) or Bull (Node.js)
- **Background Jobs**: Scheduled tasks, cleanup
- **Periodic Tasks**: Partition creation, archival
- **Retry Logic**: Exponential backoff

---

## Microservices Architecture

### Service Breakdown

#### 1. Authentication Service
**Responsibilities**:
- User registration & login
- JWT token issuance & validation
- Password reset & email verification
- OAuth integration (Google, Apple)
- Multi-factor authentication (future)

**API Endpoints**:
- `/api/v1/auth/*`

#### 2. User Service
**Responsibilities**:
- User profile management
- Preferences & settings
- Subscription management
- Session management

**API Endpoints**:
- `/api/v1/user/*`

#### 3. Camera Service
**Responsibilities**:
- Camera CRUD operations
- Stream URL generation
- Camera status monitoring
- Snapshot generation
- Camera sharing

**API Endpoints**:
- `/api/v1/cameras/*`

#### 4. Space Service
**Responsibilities**:
- Space CRUD operations
- Camera-space assignments
- Space statistics

**API Endpoints**:
- `/api/v1/spaces/*`

#### 5. Guard Service
**Responsibilities**:
- Guard CRUD operations
- Guard-camera assignments
- AI instruction validation
- Guard statistics

**API Endpoints**:
- `/api/v1/guards/*`

#### 6. Event Service
**Responsibilities**:
- Event storage & retrieval
- Event filtering & pagination
- Event statistics
- Catch management

**API Endpoints**:
- `/api/v1/events/*`

#### 7. AI Processing Service
**Responsibilities**:
- Video frame analysis
- Object detection (packages, people, vehicles)
- Event confidence scoring
- Model training & updates

**Communication**: RabbitMQ for async processing

#### 8. Streaming Service
**Responsibilities**:
- RTSP to HLS conversion
- Adaptive bitrate streaming
- Video quality optimization
- CDN integration

**Protocols**: RTSP input, HLS/DASH output

#### 9. Notification Service
**Responsibilities**:
- Push notification delivery (FCM)
- Email notifications (SendGrid/SES)
- SMS notifications (Twilio)
- Quiet hours enforcement

**Communication**: RabbitMQ for async delivery

---

## Data Flow

### 1. User Login Flow
```
Mobile App → API Gateway → Auth Service → PostgreSQL
         ↓
    JWT Tokens
         ↓
   Redis (Session Cache)
         ↓
  Return to App (Access Token)
```

### 2. Camera Stream Flow
```
IP Camera → Streaming Service → FFmpeg (RTSP→HLS)
                ↓
            S3 Bucket (HLS segments)
                ↓
            CloudFront CDN
                ↓
         Mobile App (Video Player)
```

### 3. Guard Detection Flow
```
IP Camera → Streaming Service → Frame Extraction
                ↓
        RabbitMQ (AI Queue)
                ↓
     AI Processing Service
       (Object Detection)
                ↓
    PostgreSQL (Event Storage)
                ↓
   WebSocket Service (Real-time)
                ↓
         Mobile App (Event Alert)
```

### 4. Dashboard Load Flow
```
Mobile App → API Gateway → API Service → Redis (Cache)
                                ↓
                          PostgreSQL (if cache miss)
                                ↓
                      Return Dashboard Data
                                ↓
                    WebSocket Connection (Real-time)
```

---

## Security Architecture

### Authentication & Authorization

#### JWT Token Strategy
- **Access Token**: Short-lived (1 hour), signed with RS256
- **Refresh Token**: Long-lived (30 days), stored in database
- **Token Rotation**: Refresh token rotated on each use
- **Revocation**: Session invalidation on logout

#### Password Security
- **Hashing**: bcrypt with salt (cost factor: 12)
- **Policy**: Min 8 chars, complexity requirements
- **Breach Detection**: HaveIBeenPwned API integration

#### API Security
- **Rate Limiting**: Per endpoint, per user limits
- **CORS**: Strict origin allowlist
- **CSRF**: Token-based protection
- **SQL Injection**: Parameterized queries only
- **XSS**: Input sanitization, output encoding

### Data Security

#### Encryption
- **At Rest**: AES-256 encryption for database and S3
- **In Transit**: TLS 1.3 for all connections
- **Key Management**: AWS KMS / HashiCorp Vault

#### Privacy
- **GDPR Compliance**: Data export, right to deletion
- **Data Minimization**: Collect only necessary data
- **Audit Logs**: Track all data access

---

## Scalability Strategy

### Horizontal Scaling

#### API Service
- **Deployment**: Kubernetes pods with HPA (Horizontal Pod Autoscaler)
- **Target**: CPU 70%, scale 2-20 pods
- **Load Balancer**: AWS ALB / Nginx

#### Database Scaling
- **Read Replicas**: 2-3 replicas for read-heavy operations
- **Connection Pooling**: PgBouncer with 200 max connections
- **Sharding**: Future - shard by user_id

#### Cache Scaling
- **Redis Cluster**: 3 master + 3 replica nodes
- **Eviction Policy**: LRU (Least Recently Used)
- **Hit Rate Target**: > 85%

### Vertical Scaling

- **Database**: Up to 32 vCPU, 128 GB RAM
- **API Service**: 4 vCPU, 8 GB RAM per pod
- **AI Service**: GPU instances (Tesla T4 / V100)

---

## Monitoring & Observability

### Metrics (Prometheus + Grafana)
- **Application Metrics**: Request rate, latency, error rate
- **Infrastructure Metrics**: CPU, memory, disk, network
- **Custom Metrics**: Events/min, guards active, cameras online

### Logging (ELK Stack or Datadog)
- **Application Logs**: Structured JSON logs
- **Access Logs**: Nginx/API Gateway logs
- **Error Logs**: Sentry for error tracking
- **Retention**: 30 days for debug, 1 year for audit

### Tracing (Jaeger or Datadog APM)
- **Distributed Tracing**: Track requests across services
- **Latency Analysis**: Identify slow endpoints
- **Dependency Mapping**: Service dependency graph

### Alerts
- **High Priority**: API down, database down, AI service down
- **Medium Priority**: High latency (> 1s), cache miss rate high
- **Low Priority**: Disk space low, certificate expiry

---

## Deployment Architecture

### Infrastructure (AWS/GCP/Azure)

#### Kubernetes Cluster
```yaml
Production Cluster:
  - Node Pool 1: API Services (4x m5.xlarge)
  - Node Pool 2: AI Processing (2x p3.2xlarge GPU)
  - Node Pool 3: Streaming (4x c5.xlarge)

Staging Cluster:
  - Node Pool: Mixed workloads (2x t3.medium)
```

#### Database
- **Primary**: RDS PostgreSQL (db.r5.2xlarge)
- **Replicas**: 2x db.r5.xlarge
- **Redis**: ElastiCache (cache.r5.large, 3 nodes)

#### Storage
- **S3 Buckets**:
  - `orin-videos-prod` (Standard → Glacier)
  - `orin-thumbnails-prod` (Standard)
  - `orin-snapshots-prod` (Standard, 7-day lifecycle)

### CI/CD Pipeline

```
GitHub → GitHub Actions → Build Docker Image → Push to ECR
    ↓
  Run Tests (Unit, Integration, E2E)
    ↓
  Deploy to Staging (Auto)
    ↓
  Run Smoke Tests
    ↓
  Deploy to Production (Manual Approval)
    ↓
  Health Check & Rollback if Failed
```

### Environment Strategy
- **Development**: Local Docker Compose
- **Staging**: Kubernetes cluster (mirrors production)
- **Production**: Kubernetes cluster (multi-AZ)

---

## Disaster Recovery

### Backup Strategy
- **Database**: Daily full backup + PITR (14 days)
- **S3 Objects**: Versioning enabled + cross-region replication
- **Redis**: RDB snapshots every 6 hours

### Recovery Objectives
- **RTO (Recovery Time Objective)**: 1 hour
- **RPO (Recovery Point Objective)**: 5 minutes

### Failover Plan
1. Database failover to replica (automated)
2. Switch API to healthy region (manual/automated)
3. Restore S3 from backup if needed
4. Verify all services operational

---

## Cost Optimization

### Estimated Monthly Costs (10,000 users)

| Service | Cost |
|---------|------|
| Kubernetes (Compute) | $2,000 |
| RDS PostgreSQL | $800 |
| ElastiCache Redis | $300 |
| S3 Storage (30 TB) | $690 |
| CloudFront CDN | $500 |
| AI Processing (GPU) | $1,200 |
| Monitoring & Logging | $200 |
| **Total** | **$5,690/month** |

### Cost per User
- **10,000 users**: $0.57/user/month
- **100,000 users**: $0.35/user/month (economies of scale)

---

## Future Enhancements

### Phase 2 (6-12 months)
- Web application (React/Next.js)
- Multi-user collaboration (shared spaces)
- Advanced AI features (facial recognition, license plate reading)
- Mobile app offline mode
- Custom guard training

### Phase 3 (12-18 months)
- Edge AI processing (on-camera inference)
- Predictive analytics & trends
- Integration with third-party security systems
- White-label solution for enterprises
- Mobile SDK for developers

---

## Conclusion

ORIN's architecture is designed for:
- **Scalability**: Handle millions of events per day
- **Reliability**: 99.9% uptime SLA
- **Security**: Enterprise-grade data protection
- **Performance**: Sub-second API response times
- **Cost-Effectiveness**: Optimized infrastructure usage

The microservices architecture allows independent scaling and deployment of components, while the comprehensive monitoring ensures quick issue detection and resolution.
