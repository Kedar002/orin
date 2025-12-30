# ORIN - Technology Stack & AI Integration Recommendations

## Executive Summary

This document provides detailed technology recommendations for building ORIN's backend and AI-powered guard system, with a focus on scalability, maintainability, and AI integration.

---

## 🎯 Recommended Backend Technology Stack

### **RECOMMENDED: Python + FastAPI** ✅

#### Why Python?

**Advantages:**
1. **AI/ML Integration**: Python is the dominant language for AI/ML (PyTorch, TensorFlow, OpenCV)
2. **Single Language**: Use same language for backend AND AI processing (simplified deployment)
3. **Rich Ecosystem**: Extensive libraries for video processing, computer vision, data science
4. **Async Support**: FastAPI provides async/await for high-performance APIs
5. **Type Safety**: Pydantic provides runtime type checking and validation
6. **Team Efficiency**: ML engineers and backend engineers can share code

**Disadvantages:**
1. Slower than Node.js for pure I/O operations (mitigated by async)
2. Higher memory footprint

#### Technology Stack Details

```
Backend: FastAPI 0.104+
├── Web Framework: FastAPI (async, high-performance)
├── ORM: SQLAlchemy 2.0 (async support)
├── Migration: Alembic
├── Validation: Pydantic v2
├── Authentication: python-jose (JWT), passlib (password hashing)
├── Task Queue: Celery 5.3+ with Redis
├── WebSocket: FastAPI native WebSocket support
├── Testing: pytest, pytest-asyncio
└── API Docs: Auto-generated Swagger/OpenAPI
```

### Alternative: Node.js + TypeScript (If you prefer)

```
Backend: Node.js 20+ with TypeScript
├── Framework: Express.js or Fastify
├── ORM: Prisma or TypeORM
├── Validation: Zod
├── Authentication: jsonwebtoken, bcrypt
├── Task Queue: Bull (Redis-based)
├── WebSocket: Socket.IO
└── API Docs: Swagger/OpenAPI
```

**Note**: If choosing Node.js, you'll still need Python for AI processing as a separate microservice.

---

## 🤖 AI/ML Technology Stack

### Computer Vision & Detection

```
AI/ML Stack:
├── Framework: PyTorch 2.1+ (Recommended) or TensorFlow 2.x
├── Computer Vision: OpenCV 4.8+
├── Object Detection: YOLOv8 (Ultralytics) or YOLOv5
├── Video Processing: FFmpeg, imageio
├── Face Detection: MediaPipe or face_recognition
├── License Plate: EasyOCR or Tesseract
├── Model Serving: TorchServe or FastAPI
└── GPU Acceleration: CUDA 12.x
```

### Why YOLOv8?

1. **Real-time Performance**: 30-60 FPS on GPU
2. **Pre-trained Models**: Ready for people, vehicles, packages
3. **Easy Fine-tuning**: Custom training with your data
4. **Multiple Sizes**: YOLOv8n (nano) to YOLOv8x (extra-large)
5. **Active Community**: Excellent documentation and support

---

## 🏗️ Backend & AI Architecture

### Architecture Pattern: Microservices with Message Queue

```
┌─────────────────────────────────────────────────────────────────┐
│                         MOBILE APP                              │
└────────────────┬────────────────────────────────────────────────┘
                 │
                 │ HTTPS/WSS
                 ↓
┌─────────────────────────────────────────────────────────────────┐
│                      API GATEWAY (NGINX)                        │
│              - Load Balancing                                   │
│              - Rate Limiting                                    │
│              - SSL Termination                                  │
└────────────────┬────────────────────────────────────────────────┘
                 │
      ┌──────────┼──────────┐
      │          │          │
┌─────▼─────┐ ┌──▼──────┐ ┌▼──────────┐
│  FastAPI  │ │ FastAPI │ │  FastAPI  │
│  Service  │ │ Service │ │  Service  │
│  (Pod 1)  │ │ (Pod 2) │ │  (Pod 3)  │
└─────┬─────┘ └──┬──────┘ └┬──────────┘
      │          │          │
      └──────────┼──────────┘
                 │
        ┌────────┼────────┬──────────────┐
        │        │        │              │
   ┌────▼───┐ ┌─▼─────┐ ┌▼──────────┐ ┌─▼────────────┐
   │ PostgreSQL│ Redis │ │ RabbitMQ  │ │     S3       │
   │ Database  │ Cache │ │ (Message  │ │  (Videos)    │
   │           │       │ │  Queue)   │ │              │
   └───────────┘ └──────┘ └─┬─────────┘ └──────────────┘
                            │
                            │ AI Processing Queue
                            │
                  ┌─────────▼──────────┐
                  │  AI WORKER SERVICE │
                  │   (Celery Worker)  │
                  │                    │
                  │  ┌──────────────┐  │
                  │  │  YOLOv8      │  │
                  │  │  Detection   │  │
                  │  │  Engine      │  │
                  │  └──────────────┘  │
                  │                    │
                  │  ┌──────────────┐  │
                  │  │  Custom      │  │
                  │  │  Models      │  │
                  │  └──────────────┘  │
                  └────────────────────┘
                           │
                           │ Results
                           ↓
                    ┌──────────────┐
                    │  PostgreSQL  │
                    │  (Events)    │
                    └──────────────┘
```

---

## 🔄 How Backend & AI Connect

### Pattern 1: Message Queue (RECOMMENDED) ✅

**Flow:**
```
1. Camera sends video frame to Streaming Service
2. Streaming Service extracts frame every 1-2 seconds
3. Frame published to RabbitMQ queue
4. AI Worker picks up frame from queue
5. AI Worker runs YOLOv8 detection
6. If guard rules match → Create event in PostgreSQL
7. Notification sent to user via WebSocket
```

**Advantages:**
- ✅ Decoupled architecture (backend and AI are independent)
- ✅ Scalable (add more AI workers as needed)
- ✅ Resilient (if AI worker crashes, messages are not lost)
- ✅ Load balancing (multiple workers share the load)

**Implementation:**

```python
# backend/api/services/camera_service.py
from celery import Celery
import redis

celery_app = Celery('orin', broker='redis://localhost:6379/0')

@celery_app.task
def process_camera_frame(camera_id: str, frame_url: str, guard_ids: list):
    """
    Send frame to AI processing queue
    """
    return {
        'camera_id': camera_id,
        'frame_url': frame_url,
        'guard_ids': guard_ids,
        'timestamp': datetime.utcnow().isoformat()
    }
```

```python
# ai_worker/tasks.py
import cv2
from ultralytics import YOLO
from celery import Celery

celery_app = Celery('ai_worker', broker='redis://localhost:6379/0')
model = YOLO('yolov8n.pt')  # Load model once at startup

@celery_app.task
def detect_objects(camera_id: str, frame_url: str, guard_ids: list):
    # Download frame from S3
    frame = download_frame(frame_url)

    # Run YOLOv8 detection
    results = model(frame)

    # Process detections
    for guard_id in guard_ids:
        guard = get_guard_config(guard_id)

        # Check if detection matches guard rules
        if matches_guard_criteria(results, guard):
            # Create event in database
            create_event(
                guard_id=guard_id,
                camera_id=camera_id,
                detections=results,
                confidence=results.confidence
            )

            # Send real-time notification
            send_websocket_notification(guard.user_id, event)

    return {'processed': True}
```

### Pattern 2: REST API Call (Not Recommended for Real-time)

**Flow:**
```
Backend → HTTP POST → AI Service → Response
```

**Issues:**
- Slow for real-time processing
- Backend waits for AI response (blocking)
- No automatic retry on failure

---

## 🎨 Customized Guards Architecture

### Guard Types & Implementation

#### 1. **Pre-defined Guards (Standard)**

These use pre-trained YOLOv8 models:

```python
GUARD_TYPES = {
    'packages': {
        'yolo_classes': [24, 26, 28],  # suitcase, handbag, backpack
        'confidence_threshold': 0.7
    },
    'people': {
        'yolo_classes': [0],  # person
        'confidence_threshold': 0.8
    },
    'vehicles': {
        'yolo_classes': [2, 3, 5, 7],  # car, motorcycle, bus, truck
        'confidence_threshold': 0.75
    },
    'pets': {
        'yolo_classes': [16, 17],  # dog, cat
        'confidence_threshold': 0.7
    }
}
```

#### 2. **Custom Guards (Advanced)**

For custom detection scenarios, use a hybrid approach:

**Option A: Rule-Based Filtering (Simple)**

User describes: "Alert me when a package is left unattended for more than 5 minutes"

```python
class CustomGuardProcessor:
    def __init__(self, guard_config):
        self.guard = guard_config
        self.detected_objects = {}  # Track objects over time

    def process(self, detections, timestamp):
        # Run standard YOLOv8 detection
        packages = [d for d in detections if d.class_id in [24, 26, 28]]

        # Apply custom rules
        for package in packages:
            object_id = self.get_object_id(package)

            if object_id not in self.detected_objects:
                self.detected_objects[object_id] = {
                    'first_seen': timestamp,
                    'last_moved': timestamp
                }

            # Check if stationary for 5 minutes
            if self.is_stationary(package, object_id):
                time_stationary = timestamp - self.detected_objects[object_id]['last_moved']

                if time_stationary > timedelta(minutes=5):
                    return self.create_alert('Unattended package detected')

        return None
```

**Option B: Natural Language Processing (AI-Powered)**

User input: "Alert me when a package is delivered to the front door"

```python
from transformers import pipeline

nlp_model = pipeline("text-classification", model="bert-base-uncased")

def parse_guard_instructions(instructions: str):
    """
    Use NLP to extract intent from user instructions
    """
    # Example: Extract action, object, location, time
    parsed = {
        'action': 'alert',
        'object': 'package',
        'location': 'front door',
        'time_constraint': None,
        'conditions': ['delivered']
    }

    # Map to YOLOv8 classes and rules
    detection_config = {
        'yolo_classes': [24, 26, 28],  # packages
        'zone': 'front_door_zone',  # spatial filtering
        'trigger': 'appears',  # new object detected
        'confidence_threshold': 0.75
    }

    return detection_config
```

**Option C: Fine-tuned Model (Advanced - Future)**

For truly custom objects (e.g., "detect my red car"):

```python
from ultralytics import YOLO

# Start with base YOLOv8 model
base_model = YOLO('yolov8n.pt')

# Fine-tune on user's custom dataset
def train_custom_guard(guard_id: str, training_images: list):
    """
    Fine-tune YOLOv8 on user's images
    """
    # User provides 50-100 labeled images
    dataset_path = prepare_dataset(guard_id, training_images)

    # Fine-tune model
    results = base_model.train(
        data=f'{dataset_path}/data.yaml',
        epochs=50,
        imgsz=640,
        batch=16
    )

    # Save custom model
    custom_model_path = f'models/custom_{guard_id}.pt'
    base_model.save(custom_model_path)

    return custom_model_path
```

---

## 🔧 Complete Implementation Example

### Backend Service (FastAPI)

```python
# backend/main.py
from fastapi import FastAPI, WebSocket
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from contextlib import asynccontextmanager

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    await database.connect()
    yield
    # Shutdown
    await database.disconnect()

app = FastAPI(title="ORIN API", version="1.0.0", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
from routers import auth, guards, cameras, events, spaces
app.include_router(auth.router, prefix="/api/v1/auth", tags=["auth"])
app.include_router(guards.router, prefix="/api/v1/guards", tags=["guards"])
app.include_router(cameras.router, prefix="/api/v1/cameras", tags=["cameras"])
app.include_router(events.router, prefix="/api/v1/events", tags=["events"])
app.include_router(spaces.router, prefix="/api/v1/spaces", tags=["spaces"])
```

### Guard Creation Endpoint

```python
# backend/routers/guards.py
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from typing import List
from tasks import process_guard_instructions

router = APIRouter()

class CreateGuardRequest(BaseModel):
    name: str
    description: str
    cameraIds: List[str]
    sensitivity: float = 0.8
    notifyOnDetection: bool = True

@router.post("/")
async def create_guard(
    request: CreateGuardRequest,
    db: AsyncSession = Depends(get_db),
    user_id: str = Depends(get_current_user_id)
):
    # Parse natural language instructions using AI
    detection_config = await parse_instructions(request.description)

    # Create guard in database
    guard = Guard(
        user_id=user_id,
        name=request.name,
        description=request.description,
        guard_type=detection_config['type'],
        sensitivity=request.sensitivity,
        detection_config=detection_config,
        is_active=True
    )

    db.add(guard)
    await db.commit()

    # Create camera assignments
    for camera_id in request.cameraIds:
        assignment = GuardCameraAssignment(
            guard_id=guard.id,
            camera_id=camera_id
        )
        db.add(assignment)

    await db.commit()

    # Start monitoring this guard
    await start_guard_monitoring(guard.id)

    return {"success": True, "data": {"guard": guard.to_dict()}}
```

### AI Worker Service

```python
# ai_worker/main.py
from celery import Celery
from ultralytics import YOLO
import cv2
import numpy as np
from sqlalchemy import create_engine
from models import Event, Guard

celery_app = Celery('ai_worker', broker='redis://localhost:6379/0')

# Load models at startup
models = {
    'yolov8n': YOLO('yolov8n.pt'),
    'yolov8s': YOLO('yolov8s.pt'),
}

@celery_app.task
def process_video_frame(camera_id: str, frame_data: dict, guard_ids: list):
    """
    Process a single video frame for all assigned guards
    """
    # Decode frame
    frame = decode_frame(frame_data['url'])

    # Get guard configurations
    guards = get_guards(guard_ids)

    # Run detection
    results = models['yolov8n'](frame, conf=0.5)

    # Check each guard's criteria
    for guard in guards:
        if guard_matches(results, guard):
            # Create event
            event = create_event(
                guard_id=guard.id,
                camera_id=camera_id,
                detections=results.boxes,
                frame=frame,
                timestamp=frame_data['timestamp']
            )

            # Save thumbnail to S3
            thumbnail_url = save_thumbnail(event.id, frame, results.boxes)
            event.thumbnail_url = thumbnail_url

            # Send notification
            notify_user(guard.user_id, event)

    return {'processed': True, 'detections_count': len(results.boxes)}

def guard_matches(results, guard):
    """
    Check if detection results match guard criteria
    """
    config = guard.detection_config

    # Filter by class
    relevant_detections = [
        box for box in results.boxes
        if int(box.cls) in config['yolo_classes']
        and float(box.conf) >= guard.sensitivity
    ]

    if not relevant_detections:
        return False

    # Apply custom rules (zone, time, etc.)
    if 'zone' in config:
        relevant_detections = filter_by_zone(relevant_detections, config['zone'])

    if 'time_constraint' in config:
        if not check_time_constraint(config['time_constraint']):
            return False

    return len(relevant_detections) > 0
```

---

## 🚀 Deployment Architecture

### Docker Compose (Development)

```yaml
version: '3.8'

services:
  api:
    build: ./backend
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql://user:pass@postgres:5432/orin
      - REDIS_URL=redis://redis:6379/0
    depends_on:
      - postgres
      - redis

  ai-worker:
    build: ./ai_worker
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]
    environment:
      - CELERY_BROKER_URL=redis://redis:6379/0
      - DATABASE_URL=postgresql://user:pass@postgres:5432/orin
    depends_on:
      - redis
      - postgres

  postgres:
    image: postgres:15
    environment:
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=pass
      - POSTGRES_DB=orin
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
  redis_data:
```

### Kubernetes (Production)

```yaml
# ai-worker-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ai-worker
spec:
  replicas: 3
  selector:
    matchLabels:
      app: ai-worker
  template:
    metadata:
      labels:
        app: ai-worker
    spec:
      containers:
      - name: ai-worker
        image: orin/ai-worker:latest
        resources:
          limits:
            nvidia.com/gpu: 1
            memory: "8Gi"
            cpu: "4"
          requests:
            nvidia.com/gpu: 1
            memory: "4Gi"
            cpu: "2"
        env:
        - name: CELERY_BROKER_URL
          value: "redis://redis:6379/0"
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: url
      nodeSelector:
        cloud.google.com/gke-accelerator: nvidia-tesla-t4
```

---

## 📊 Performance Optimization

### GPU Selection for AI Processing

| GPU | FPS (YOLOv8n) | Cost/Hour | Recommended For |
|-----|---------------|-----------|-----------------|
| NVIDIA T4 | 60-80 | $0.35 | Development, 1-10 cameras |
| NVIDIA A10 | 120-150 | $1.00 | Production, 10-50 cameras |
| NVIDIA A100 | 200-250 | $3.00 | Large scale, 50+ cameras |

### Optimization Techniques

1. **Batch Processing**: Process multiple frames in parallel
```python
# Process 8 frames at once
results = model(frames_batch, batch=8)
```

2. **Model Quantization**: Reduce model size
```python
# Export to TensorRT for faster inference
model.export(format='engine', device=0)
```

3. **Frame Sampling**: Process every Nth frame
```python
# Process 1 frame per second instead of all 30
if frame_count % 30 == 0:
    process_frame(frame)
```

---

## 💰 Cost Estimation

### AI Processing Costs (Monthly)

| Cameras | Frames/Day | GPU Hours | Cost |
|---------|------------|-----------|------|
| 10 | 864,000 | 120 | $300 |
| 50 | 4,320,000 | 600 | $1,500 |
| 100 | 8,640,000 | 1,200 | $3,000 |

**Assumptions**: 1 frame/sec, YOLOv8n, T4 GPU

---

## 🎯 Implementation Roadmap

### Phase 1: MVP (4-6 weeks)
- ✅ FastAPI backend with authentication
- ✅ PostgreSQL database setup
- ✅ Basic guard CRUD
- ✅ YOLOv8 integration for pre-defined guards
- ✅ Celery + Redis for async processing
- ✅ WebSocket for real-time notifications

### Phase 2: Custom Guards (6-8 weeks)
- ✅ NLP instruction parsing
- ✅ Rule-based custom guards
- ✅ Zone-based detection
- ✅ Time-based filtering

### Phase 3: Advanced AI (8-12 weeks)
- ✅ Custom model fine-tuning
- ✅ Multi-object tracking
- ✅ Behavioral analysis
- ✅ Performance optimization

---

## 📚 Learning Resources

### FastAPI
- Official Docs: https://fastapi.tiangolo.com/
- Full Stack FastAPI: https://github.com/tiangolo/full-stack-fastapi-template

### YOLOv8
- Official Docs: https://docs.ultralytics.com/
- Tutorial: https://www.youtube.com/watch?v=gRAyOPjQ9_s

### Celery
- Official Docs: https://docs.celeryq.dev/
- Best Practices: https://celery.school/

---

## ✅ Final Recommendation

**GO WITH:**
1. **Backend**: Python + FastAPI
2. **AI**: PyTorch + YOLOv8
3. **Queue**: Celery + Redis
4. **Database**: PostgreSQL + TimescaleDB
5. **Deployment**: Docker + Kubernetes

This stack provides the best balance of:
- AI/ML integration
- Performance
- Scalability
- Developer experience
- Community support

**Next Steps:**
1. Set up FastAPI backend
2. Integrate YOLOv8 for basic detection
3. Implement Celery workers
4. Deploy to cloud with GPU support
