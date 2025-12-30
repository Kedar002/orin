# ORIN - Scalable Database Design

## Overview

This document outlines a scalable, production-ready database architecture for ORIN, a CCTV surveillance application with AI-powered guards. The design emphasizes performance, scalability, and data integrity.

### Technology Stack
- **Primary Database**: PostgreSQL 15+ (ACID compliance, robust indexing, JSON support)
- **Cache Layer**: Redis 7+ (Session management, real-time data, rate limiting)
- **File Storage**: AWS S3 or equivalent (Video clips, snapshots, thumbnails)
- **Search Engine**: Elasticsearch (Optional, for advanced event search)
- **Time-Series DB**: TimescaleDB extension (Event metrics, camera uptime)

---

## Database Schema Design

### 1. Users Table

Stores user account information.

```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    phone_number VARCHAR(20),
    phone_verified BOOLEAN DEFAULT FALSE,
    email_verified BOOLEAN DEFAULT FALSE,
    profile_picture_url TEXT,
    role VARCHAR(20) DEFAULT 'owner' CHECK (role IN ('owner', 'admin', 'viewer')),
    timezone VARCHAR(50) DEFAULT 'UTC',
    language VARCHAR(10) DEFAULT 'en',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login_at TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT TRUE,
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- Indexes
CREATE INDEX idx_users_email ON users(email) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_created_at ON users(created_at DESC);
CREATE INDEX idx_users_is_active ON users(is_active) WHERE is_active = TRUE;
```

---

### 2. User Sessions Table

Tracks active user sessions across devices.

```sql
CREATE TABLE user_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    access_token_hash VARCHAR(255) NOT NULL,
    refresh_token_hash VARCHAR(255) NOT NULL,
    device_id VARCHAR(255),
    device_name VARCHAR(255),
    device_platform VARCHAR(50),
    device_os_version VARCHAR(50),
    ip_address INET,
    user_agent TEXT,
    location_city VARCHAR(100),
    location_country VARCHAR(100),
    fcm_token TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_active_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_sessions_user_id ON user_sessions(user_id);
CREATE INDEX idx_sessions_access_token ON user_sessions(access_token_hash);
CREATE INDEX idx_sessions_expires_at ON user_sessions(expires_at) WHERE is_active = TRUE;
CREATE INDEX idx_sessions_device_id ON user_sessions(device_id);
```

---

### 3. Subscriptions Table

Manages user subscription plans and billing.

```sql
CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    plan VARCHAR(50) NOT NULL CHECK (plan IN ('free', 'basic', 'premium', 'enterprise')),
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'cancelled', 'expired', 'suspended')),
    billing_cycle VARCHAR(20) DEFAULT 'monthly' CHECK (billing_cycle IN ('monthly', 'yearly')),
    amount DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    stripe_subscription_id VARCHAR(255),
    stripe_customer_id VARCHAR(255),
    current_period_start TIMESTAMP WITH TIME ZONE NOT NULL,
    current_period_end TIMESTAMP WITH TIME ZONE NOT NULL,
    cancel_at_period_end BOOLEAN DEFAULT FALSE,
    cancelled_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE UNIQUE INDEX idx_subscriptions_user_id ON subscriptions(user_id) WHERE status = 'active';
CREATE INDEX idx_subscriptions_status ON subscriptions(status);
CREATE INDEX idx_subscriptions_period_end ON subscriptions(current_period_end);
```

---

### 4. Spaces Table

Organizes cameras by physical locations.

```sql
CREATE TABLE spaces (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    icon VARCHAR(50) DEFAULT 'home' CHECK (icon IN ('hospital', 'business', 'home', 'apartment', 'store', 'city')),
    description TEXT,
    address_street VARCHAR(255),
    address_city VARCHAR(100),
    address_state VARCHAR(100),
    address_zip_code VARCHAR(20),
    address_country VARCHAR(100),
    timezone VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT unique_space_name_per_user UNIQUE (user_id, name) WHERE deleted_at IS NULL
);

-- Indexes
CREATE INDEX idx_spaces_user_id ON spaces(user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_spaces_created_at ON spaces(created_at DESC);
```

---

### 5. Cameras Table

Stores camera devices and configuration.

```sql
CREATE TABLE cameras (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    space_id UUID REFERENCES spaces(id) ON DELETE SET NULL,
    name VARCHAR(255) NOT NULL,
    device_id VARCHAR(255) UNIQUE,
    status VARCHAR(20) DEFAULT 'offline' CHECK (status IN ('online', 'offline', 'error')),
    stream_url TEXT,
    rtsp_url TEXT,
    resolution VARCHAR(20),
    fps INTEGER,
    is_recording BOOLEAN DEFAULT TRUE,
    recording_schedule JSONB,
    storage_location VARCHAR(50) DEFAULT 's3',
    storage_path TEXT,
    last_seen_at TIMESTAMP WITH TIME ZONE,
    uptime_percentage DECIMAL(5, 2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT unique_camera_name_per_user UNIQUE (user_id, name) WHERE deleted_at IS NULL
);

-- Indexes
CREATE INDEX idx_cameras_user_id ON cameras(user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_cameras_space_id ON cameras(space_id);
CREATE INDEX idx_cameras_status ON cameras(status);
CREATE INDEX idx_cameras_device_id ON cameras(device_id);
```

---

### 6. Guards Table

AI security guards that monitor cameras.

```sql
CREATE TABLE guards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    guard_type VARCHAR(50) NOT NULL CHECK (guard_type IN ('packages', 'people', 'vehicles', 'pets', 'motion', 'custom')),
    is_active BOOLEAN DEFAULT TRUE,
    sensitivity DECIMAL(3, 2) DEFAULT 0.80 CHECK (sensitivity >= 0.0 AND sensitivity <= 1.0),
    notify_on_detection BOOLEAN DEFAULT TRUE,
    detection_config JSONB,
    ai_model_version VARCHAR(50),
    success_rate DECIMAL(5, 2),
    total_catches INTEGER DEFAULT 0,
    false_positive_count INTEGER DEFAULT 0,
    last_detection_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT unique_guard_name_per_user UNIQUE (user_id, name) WHERE deleted_at IS NULL
);

-- Indexes
CREATE INDEX idx_guards_user_id ON guards(user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_guards_is_active ON guards(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_guards_type ON guards(guard_type);
CREATE INDEX idx_guards_created_at ON guards(created_at DESC);
```

---

### 7. Guard Camera Assignments Table

Many-to-many relationship between guards and cameras.

```sql
CREATE TABLE guard_camera_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    guard_id UUID NOT NULL REFERENCES guards(id) ON DELETE CASCADE,
    camera_id UUID NOT NULL REFERENCES cameras(id) ON DELETE CASCADE,
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    CONSTRAINT unique_guard_camera UNIQUE (guard_id, camera_id)
);

-- Indexes
CREATE INDEX idx_guard_camera_guard_id ON guard_camera_assignments(guard_id);
CREATE INDEX idx_guard_camera_camera_id ON guard_camera_assignments(camera_id);
```

---

### 8. Events Table (Catches/Detections)

**CRITICAL: This table will grow rapidly and requires partitioning.**

```sql
CREATE TABLE events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    guard_id UUID NOT NULL REFERENCES guards(id) ON DELETE CASCADE,
    camera_id UUID NOT NULL REFERENCES cameras(id) ON DELETE CASCADE,
    event_type VARCHAR(50) NOT NULL CHECK (event_type IN ('delivery', 'person', 'vehicle', 'pet', 'motion', 'other')),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    confidence DECIMAL(5, 4) NOT NULL CHECK (confidence >= 0.0 AND confidence <= 1.0),
    timestamp TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    thumbnail_url TEXT,
    video_clip_url TEXT,
    video_clip_duration INTEGER,
    metadata JSONB,
    is_saved BOOLEAN DEFAULT FALSE,
    is_read BOOLEAN DEFAULT FALSE,
    user_note TEXT,
    user_feedback VARCHAR(20) CHECK (user_feedback IN ('correct', 'false_positive', 'missed')),
    read_at TIMESTAMP WITH TIME ZONE,
    saved_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
) PARTITION BY RANGE (timestamp);

-- Create partitions (monthly partitioning)
CREATE TABLE events_2025_01 PARTITION OF events
    FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');

CREATE TABLE events_2025_02 PARTITION OF events
    FOR VALUES FROM ('2025-02-01') TO ('2025-03-01');

-- Continue creating partitions...

-- Indexes (created on each partition)
CREATE INDEX idx_events_user_id ON events(user_id, timestamp DESC);
CREATE INDEX idx_events_guard_id ON events(guard_id, timestamp DESC);
CREATE INDEX idx_events_camera_id ON events(camera_id, timestamp DESC);
CREATE INDEX idx_events_timestamp ON events(timestamp DESC);
CREATE INDEX idx_events_is_read ON events(is_read) WHERE is_read = FALSE;
CREATE INDEX idx_events_is_saved ON events(is_saved) WHERE is_saved = TRUE;
CREATE INDEX idx_events_type ON events(event_type, timestamp DESC);
```

---

### 9. Event Snapshots Table

Stores individual frames/snapshots from camera feed.

```sql
CREATE TABLE snapshots (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    camera_id UUID NOT NULL REFERENCES cameras(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    captured_at TIMESTAMP WITH TIME ZONE NOT NULL,
    thumbnail_url TEXT NOT NULL,
    full_url TEXT NOT NULL,
    width INTEGER,
    height INTEGER,
    file_size_bytes BIGINT,
    storage_path TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
) PARTITION BY RANGE (captured_at);

-- Indexes
CREATE INDEX idx_snapshots_camera_id ON snapshots(camera_id, captured_at DESC);
CREATE INDEX idx_snapshots_user_id ON snapshots(user_id, captured_at DESC);
```

---

### 10. Notifications Table

User notification history.

```sql
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    event_id UUID REFERENCES events(id) ON DELETE CASCADE,
    notification_type VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    data JSONB,
    is_read BOOLEAN DEFAULT FALSE,
    sent_at TIMESTAMP WITH TIME ZONE,
    read_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
) PARTITION BY RANGE (created_at);

-- Indexes
CREATE INDEX idx_notifications_user_id ON notifications(user_id, created_at DESC);
CREATE INDEX idx_notifications_is_read ON notifications(is_read) WHERE is_read = FALSE;
```

---

### 11. User Preferences Table

User-specific app preferences and settings.

```sql
CREATE TABLE user_preferences (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    theme VARCHAR(20) DEFAULT 'light' CHECK (theme IN ('light', 'dark', 'system')),
    language VARCHAR(10) DEFAULT 'en',
    timezone VARCHAR(50) DEFAULT 'UTC',
    notifications_enabled BOOLEAN DEFAULT TRUE,
    push_enabled BOOLEAN DEFAULT TRUE,
    email_enabled BOOLEAN DEFAULT TRUE,
    sms_enabled BOOLEAN DEFAULT FALSE,
    notification_event_types JSONB DEFAULT '{"delivery": true, "person": true, "vehicle": true, "motion": false}',
    quiet_hours_enabled BOOLEAN DEFAULT FALSE,
    quiet_hours_start TIME,
    quiet_hours_end TIME,
    notification_sound VARCHAR(50) DEFAULT 'default',
    vibration_enabled BOOLEAN DEFAULT TRUE,
    video_quality_preference VARCHAR(20) DEFAULT 'auto',
    auto_play_videos BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

---

### 12. Camera Recordings Table

Metadata for stored video recordings.

```sql
CREATE TABLE recordings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    camera_id UUID NOT NULL REFERENCES cameras(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    end_time TIMESTAMP WITH TIME ZONE NOT NULL,
    duration_seconds INTEGER NOT NULL,
    file_size_bytes BIGINT,
    resolution VARCHAR(20),
    fps INTEGER,
    storage_path TEXT NOT NULL,
    storage_url TEXT,
    is_archived BOOLEAN DEFAULT FALSE,
    archived_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
) PARTITION BY RANGE (start_time);

-- Indexes
CREATE INDEX idx_recordings_camera_id ON recordings(camera_id, start_time DESC);
CREATE INDEX idx_recordings_user_id ON recordings(user_id, start_time DESC);
CREATE INDEX idx_recordings_timerange ON recordings(start_time, end_time);
```

---

### 13. Analytics Events Table (Optional)

Track user interactions for product analytics.

```sql
CREATE TABLE analytics_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    event_name VARCHAR(100) NOT NULL,
    event_category VARCHAR(50),
    properties JSONB,
    session_id UUID,
    device_id VARCHAR(255),
    platform VARCHAR(50),
    app_version VARCHAR(20),
    ip_address INET,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
) PARTITION BY RANGE (timestamp);

-- Indexes
CREATE INDEX idx_analytics_user_id ON analytics_events(user_id, timestamp DESC);
CREATE INDEX idx_analytics_event_name ON analytics_events(event_name, timestamp DESC);
CREATE INDEX idx_analytics_timestamp ON analytics_events(timestamp DESC);
```

---

## Scalability Strategies

### 1. Partitioning

**Events Table**: Monthly partitioning by timestamp
- Improves query performance by scanning only relevant partitions
- Easier archival and deletion of old data
- Automatic partition creation via cron job

```sql
-- Auto-create next month's partition
CREATE OR REPLACE FUNCTION create_next_month_partition()
RETURNS void AS $$
DECLARE
    start_date DATE;
    end_date DATE;
    partition_name TEXT;
BEGIN
    start_date := DATE_TRUNC('month', NOW() + INTERVAL '1 month');
    end_date := start_date + INTERVAL '1 month';
    partition_name := 'events_' || TO_CHAR(start_date, 'YYYY_MM');

    EXECUTE format('CREATE TABLE IF NOT EXISTS %I PARTITION OF events FOR VALUES FROM (%L) TO (%L)',
        partition_name, start_date, end_date);
END;
$$ LANGUAGE plpgsql;
```

### 2. Indexing Strategy

- **B-tree indexes** for primary keys, foreign keys, and common queries
- **Partial indexes** for filtered queries (e.g., WHERE is_active = TRUE)
- **Composite indexes** for multi-column queries (user_id, timestamp)
- **GIN indexes** for JSONB columns (metadata, detection_config)

### 3. Caching with Redis

```
# User sessions (TTL: 1 hour)
Key: session:{access_token_hash}
Value: {user_id, permissions, device_id}

# Dashboard overview (TTL: 2 minutes)
Key: dashboard:{user_id}
Value: {cameras, guards, events}

# Camera status (TTL: 30 seconds)
Key: camera:status:{camera_id}
Value: {status, last_seen_at}

# Unread event count (TTL: 1 minute)
Key: events:unread:{user_id}
Value: 12
```

### 4. Read Replicas

- **Primary**: Write operations
- **Replica 1**: Dashboard reads, event queries
- **Replica 2**: Video streaming metadata, analytics

### 5. Connection Pooling

```python
# PostgreSQL connection pool
DATABASE_URL = "postgresql://user:pass@localhost:5432/orin"
engine = create_engine(
    DATABASE_URL,
    pool_size=20,
    max_overflow=40,
    pool_timeout=30,
    pool_recycle=3600
)
```

---

## Data Retention Policy

| Data Type | Retention Period | Archive Strategy |
|-----------|------------------|------------------|
| Events | 90 days (hot), 1 year (warm), 7 years (cold) | Move to S3 Glacier after 90 days |
| Video Clips | 30 days (standard), 1 year (premium) | Delete or archive based on plan |
| Snapshots | 7 days | Delete automatically |
| Notifications | 30 days | Soft delete after 30 days |
| Analytics | 2 years | Aggregate and archive monthly |
| Audit Logs | 7 years (compliance) | Immutable archive in S3 |

---

## Backup Strategy

1. **Full Backup**: Daily at 2 AM (low traffic)
2. **Incremental Backup**: Every 6 hours
3. **Point-in-Time Recovery**: Enabled (14-day window)
4. **Geo-Redundancy**: Multi-region replication
5. **Backup Testing**: Monthly restore drills

---

## Performance Optimizations

1. **Vacuum Strategy**: Auto-vacuum on high-write tables (events, notifications)
2. **Query Optimization**: Use EXPLAIN ANALYZE for slow queries
3. **Materialized Views**: For complex aggregations (guard statistics)
4. **Database Sharding**: Consider sharding by user_id for multi-tenant scaling

---

## Security Measures

1. **Encryption at Rest**: PostgreSQL TDE or filesystem encryption
2. **Encryption in Transit**: SSL/TLS for all connections
3. **Row-Level Security**: Implement RLS policies per user
4. **Audit Logging**: Track all data modifications
5. **Secrets Management**: Use AWS Secrets Manager or Vault

---

## Monitoring & Observability

1. **Metrics to Track**:
   - Query latency (p50, p95, p99)
   - Connection pool utilization
   - Cache hit rate (Redis)
   - Partition growth rate
   - Disk usage per partition

2. **Alerts**:
   - Slow queries (> 1 second)
   - High CPU/Memory usage (> 80%)
   - Failed backups
   - Low disk space (< 20%)
   - Replication lag (> 10 seconds)

---

## Migration Strategy

1. **Schema Versioning**: Use Alembic or Flyway
2. **Zero-Downtime Migrations**: Blue-green deployment
3. **Rollback Plan**: Always maintain rollback scripts
4. **Testing**: Test migrations on staging with production data clone

---

## Estimated Storage Requirements

| Users | Cameras | Events/Month | Storage/Month | Storage/Year |
|-------|---------|--------------|---------------|--------------|
| 1,000 | 5,000 | 500,000 | 250 GB | 3 TB |
| 10,000 | 50,000 | 5,000,000 | 2.5 TB | 30 TB |
| 100,000 | 500,000 | 50,000,000 | 25 TB | 300 TB |

---

## Conclusion

This database design provides a solid foundation for ORIN to scale from prototype to enterprise-level deployment. Key features include:

- **Partitioning** for high-volume tables (events, notifications)
- **Indexing strategy** for optimal query performance
- **Redis caching** for real-time data and session management
- **Automated partition management** for data lifecycle
- **Comprehensive backup and disaster recovery** plan
- **Security and compliance** measures

The design can handle millions of events per day while maintaining sub-second query performance.
