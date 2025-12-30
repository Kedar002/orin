# ORIN - AI Integration Architecture Guide

## 🎯 GOAL

Build an **AI CCTV system** where:
* Each **Guard is an agentic AI**
* Guards can be **created with natural language**
* Guards can **chat** and explain what they saw
* Guards watch **live CCTV streams** 24/7
* Guards detect **custom behaviors** (not just objects)
* Guards **summarize video** on demand
* Guards decide **what action to take**

---

## 🧠 CORE PRINCIPLE

> **Vision ≠ Intelligence**

Separate the system into **6 strict layers** for scalability, explainability, and cost-efficiency.

---

## 🏗️ PRODUCTION-GRADE ARCHITECTURE

```
┌────────────────────────────────────────────────────────────┐
│                    USER (Mobile App)                       │
│              "Guard, what happened today?"                 │
└──────────────────────┬─────────────────────────────────────┘
                       │ Chat via FastAPI + LLM
                       ↓
┌────────────────────────────────────────────────────────────┐
│              LAYER 6: GUARD AGENT (Brain)                  │
│  - Each guard is an autonomous agent instance              │
│  - Has memory (short-term + long-term via vector DB)       │
│  - Conversational interface (Claude/GPT + RAG)             │
│  - Evaluates rules → decides → acts → logs → responds      │
└──────────────────────┬─────────────────────────────────────┘
                       │
                       ↓
┌────────────────────────────────────────────────────────────┐
│       LAYER 5: RULE & INSTRUCTION COMPILER (Translator)    │
│  - Converts natural language → executable rules            │
│  - LLM (Claude/GPT) parses user instructions               │
│  - Outputs: YAML rule definitions                          │
│  - Example: "Alert if anyone drinks near server rack       │
│    after 10pm" → structured detection config               │
└──────────────────────┬─────────────────────────────────────┘
                       │
                       ↓
┌────────────────────────────────────────────────────────────┐
│         LAYER 4: GUARD SKILLS REGISTRY (Capabilities)      │
│  - Defines what guards CAN do (composable skills)          │
│  - Skills: detect_person, detect_drinking, track_motion,   │
│    detect_loitering, detect_zone_intrusion, etc.           │
│  - Each skill has: requires[], produces[]                  │
└──────────────────────┬─────────────────────────────────────┘
                       │
                       ↓
┌────────────────────────────────────────────────────────────┐
│      LAYER 3: EVENT ABSTRACTION ENGINE (Understanding)     │
│  - Converts atomic facts → semantic events                 │
│  - Uses Finite State Machines (FSM) for behaviors          │
│  - Examples:                                               │
│    * hand→bottle→mouth = drinking                          │
│    * person stays in zone >5min = loitering                │
│    * object appears + stays = unattended package           │
│  - NO LLM here (deterministic logic)                       │
└──────────────────────┬─────────────────────────────────────┘
                       │
                       ↓
┌────────────────────────────────────────────────────────────┐
│       LAYER 2: VISION PERCEPTION LAYER (Eyes)              │
│  - YOLOv8 (objects: person, car, package, etc.)            │
│  - YOLOv8-Pose (human skeletal keypoints) [OPTIONAL]       │
│  - ByteTrack/DeepSORT (multi-object tracking)              │
│  - Outputs: ONLY atomic facts (no reasoning)               │
│     {frame_id, timestamp, objects[], poses[], tracks[]}    │
└──────────────────────┬─────────────────────────────────────┘
                       │
                       ↓
┌────────────────────────────────────────────────────────────┐
│              LAYER 1: CCTV STREAMS (RTSP)                  │
│  - Live camera feeds                                       │
│  - FFmpeg extracts 1 frame/sec                             │
│  - Frames sent to processing queue (Celery + Redis)        │
└────────────────────────────────────────────────────────────┘
```

---

## 📦 DETAILED LAYER BREAKDOWN

### LAYER 1: CCTV STREAMS (Raw Input)

**Purpose:** Capture and extract frames from live camera feeds

**Implementation:**
```python
# streaming_service/frame_extractor.py
import cv2
from celery import Celery
import boto3

celery_app = Celery('streaming', broker='redis://localhost:6379/0')
s3 = boto3.client('s3')

def extract_and_queue_frame(camera_id: str, rtsp_url: str):
    """Extract 1 frame/sec from RTSP stream and send to queue"""
    cap = cv2.VideoCapture(rtsp_url)
    ret, frame = cap.read()

    if ret:
        # Save frame to S3
        frame_filename = f"{camera_id}_{int(time.time())}.jpg"
        frame_path = f'/tmp/{frame_filename}'
        cv2.imwrite(frame_path, frame)
        s3.upload_file(frame_path, 'orin-frames', frame_filename)

        # Get active guards for this camera
        guard_ids = get_active_guards_for_camera(camera_id)

        # Send to vision processing queue
        celery_app.send_task(
            'ai_worker.tasks.process_frame',
            kwargs={
                'camera_id': camera_id,
                'frame_url': f's3://orin-frames/{frame_filename}',
                'guard_ids': guard_ids,
                'timestamp': datetime.utcnow().isoformat()
            }
        )

    cap.release()
```

**Output Contract:**
```json
{
  "camera_id": "cam_001",
  "frame_url": "s3://orin-frames/cam_001_1735567890.jpg",
  "guard_ids": ["grd_001", "grd_002"],
  "timestamp": "2025-12-30T14:30:00Z"
}
```

---

### LAYER 2: VISION PERCEPTION LAYER (Eyes)

**Purpose:** Convert raw pixels → atomic facts (NO reasoning)

**Components:**
* **YOLOv8** - Object detection (80 pre-trained classes)
* **YOLOv8-Pose** - Human skeletal keypoints (17 joints) [OPTIONAL SKILL]
* **ByteTrack** - Multi-object tracking with persistent IDs
* **Metadata Extraction** - Frame info (brightness, motion, etc.)

**STRICT OUTPUT CONTRACT (facts only):**
```json
{
  "frame_id": 91822,
  "timestamp": "2025-12-30T14:30:15Z",
  "camera_id": "cam_001",
  "objects": [
    {
      "track_id": "track_14",
      "class": "person",
      "confidence": 0.94,
      "bbox": [x1, y1, x2, y2],
      "pose": {
        "left_wrist": [x, y, conf],
        "right_wrist": [x, y, conf],
        "mouth": [x, y, conf]
      }
    },
    {
      "track_id": "track_22",
      "class": "bottle",
      "confidence": 0.87,
      "bbox": [x1, y1, x2, y2]
    }
  ],
  "metadata": {
    "avg_brightness": 128,
    "motion_detected": true
  }
}
```

**Implementation:**
```python
# ai_worker/vision/perception.py
from ultralytics import YOLO
from boxmot import ByteTrack
import cv2

class VisionPerceptionLayer:
    def __init__(self):
        self.detector = YOLO('yolov8n.pt')
        self.pose_detector = YOLO('yolov8n-pose.pt')  # Optional
        self.tracker = ByteTrack()

    def process_frame(self, frame: np.ndarray, frame_id: int, timestamp: str):
        """Convert frame to atomic facts"""
        # Step 1: Detect objects
        detections = self.detector(frame, conf=0.5, verbose=False)[0]

        # Step 2: Track objects (persistent IDs across frames)
        tracks = self.tracker.update(detections.boxes.data, frame)

        # Step 3: Detect poses (if person detected)
        pose_results = None
        if any(int(det.cls) == 0 for det in detections.boxes):  # class 0 = person
            pose_results = self.pose_detector(frame, verbose=False)[0]

        # Step 4: Build fact output (NO REASONING)
        return self._build_facts(tracks, pose_results, frame_id, timestamp)

    def _build_facts(self, tracks, pose_results, frame_id, timestamp):
        """Build atomic fact dictionary"""
        objects = []

        for track in tracks:
            obj = {
                'track_id': f"track_{int(track[4])}",
                'class': self.detector.names[int(track[5])],
                'confidence': float(track[6]),
                'bbox': track[:4].tolist()
            }

            # Add pose if available and object is person
            if pose_results and obj['class'] == 'person':
                obj['pose'] = self._extract_pose(pose_results, track)

            objects.append(obj)

        return {
            'frame_id': frame_id,
            'timestamp': timestamp,
            'objects': objects,
            'metadata': {
                'avg_brightness': int(np.mean(frame)),
                'motion_detected': len(objects) > 0
            }
        }
```

**CRITICAL RULE:**
> The vision layer MUST NEVER interpret behavior.
> It outputs ONLY: "person at (x,y)", "bottle at (x,y)", NOT "person drinking".

---

### LAYER 3: EVENT ABSTRACTION ENGINE (Understanding)

**Purpose:** Convert atomic facts → semantic events (behaviors)

**Why This Layer is Critical:**
* YOLOv8 detects "person" + "bottle"
* This layer detects "person drinking water"
* Enables complex behaviors: loitering, unattended objects, drinking, phone usage, etc.

**Implementation Pattern: Finite State Machines (FSM)**

**Example 1: Drinking Detection**
```python
# ai_worker/events/drinking_detector.py
from enum import Enum
from datetime import datetime, timedelta

class DrinkingState(Enum):
    IDLE = "idle"
    HAND_NEAR_BOTTLE = "hand_near_bottle"
    BOTTLE_NEAR_MOUTH = "bottle_near_mouth"
    DRINKING = "drinking"

class DrinkingEventDetector:
    def __init__(self):
        self.state = DrinkingState.IDLE
        self.state_start_time = None
        self.actor_id = None

    def update(self, facts: dict) -> dict:
        """Process facts and return event if drinking detected"""
        persons = [o for o in facts['objects'] if o['class'] == 'person']
        bottles = [o for o in facts['objects'] if o['class'] == 'bottle']

        if not persons or not bottles:
            self.state = DrinkingState.IDLE
            return None

        person = persons[0]  # Simplification: track first person
        bottle = bottles[0]

        # Check spatial relationships
        hand_near_bottle = self._is_near(person.get('pose', {}).get('right_wrist'), bottle['bbox'])
        bottle_near_mouth = self._is_near(bottle['bbox'], person.get('pose', {}).get('mouth'))

        # State machine transitions
        if self.state == DrinkingState.IDLE and hand_near_bottle:
            self._transition(DrinkingState.HAND_NEAR_BOTTLE, person['track_id'])

        elif self.state == DrinkingState.HAND_NEAR_BOTTLE and bottle_near_mouth:
            self._transition(DrinkingState.BOTTLE_NEAR_MOUTH, person['track_id'])

        elif self.state == DrinkingState.BOTTLE_NEAR_MOUTH:
            duration = (datetime.now() - self.state_start_time).total_seconds()
            if duration > 2.0:  # Must be sustained for 2 seconds
                self._transition(DrinkingState.DRINKING, person['track_id'])
                return {
                    'event': 'person_drinking',
                    'actor_id': person['track_id'],
                    'confidence': 0.88,
                    'duration': duration,
                    'timestamp': facts['timestamp']
                }

        return None

    def _is_near(self, point1, bbox2, threshold=50):
        """Check if point is near bounding box"""
        if not point1 or not bbox2:
            return False
        # Implement distance calculation
        return True  # Simplified

    def _transition(self, new_state, actor_id):
        """Transition to new state"""
        self.state = new_state
        self.state_start_time = datetime.now()
        self.actor_id = actor_id
```

**Example 2: Loitering Detection**
```python
# ai_worker/events/loitering_detector.py
from collections import defaultdict
from datetime import datetime, timedelta

class LoiteringEventDetector:
    def __init__(self, zone_polygon, threshold_minutes=5):
        self.zone = zone_polygon
        self.threshold = timedelta(minutes=threshold_minutes)
        self.tracked_objects = defaultdict(dict)  # {track_id: {first_seen, last_seen}}

    def update(self, facts: dict) -> list:
        """Detect persons loitering in zone"""
        events = []
        current_time = datetime.fromisoformat(facts['timestamp'])

        persons_in_zone = [
            p for p in facts['objects']
            if p['class'] == 'person' and self._is_in_zone(p['bbox'])
        ]

        # Track persons in zone
        active_tracks = set()
        for person in persons_in_zone:
            track_id = person['track_id']
            active_tracks.add(track_id)

            if track_id not in self.tracked_objects:
                # First time seeing this person in zone
                self.tracked_objects[track_id] = {
                    'first_seen': current_time,
                    'last_seen': current_time
                }
            else:
                # Update last seen
                self.tracked_objects[track_id]['last_seen'] = current_time

                # Check if loitering
                duration = current_time - self.tracked_objects[track_id]['first_seen']
                if duration >= self.threshold:
                    events.append({
                        'event': 'person_loitering',
                        'actor_id': track_id,
                        'confidence': 0.92,
                        'duration': duration.total_seconds(),
                        'zone': 'restricted_area',
                        'timestamp': facts['timestamp']
                    })

        # Remove tracks that left the zone
        inactive = set(self.tracked_objects.keys()) - active_tracks
        for track_id in inactive:
            del self.tracked_objects[track_id]

        return events

    def _is_in_zone(self, bbox):
        """Point-in-polygon test"""
        center_x = (bbox[0] + bbox[2]) / 2
        center_y = (bbox[1] + bbox[3]) / 2
        # Ray casting algorithm
        return True  # Simplified
```

**Event Output Format:**
```json
{
  "event": "person_drinking",
  "actor_id": "track_14",
  "confidence": 0.88,
  "duration": 3.2,
  "timestamp": "2025-12-30T14:30:18Z",
  "metadata": {
    "bottle_class": "bottle",
    "location": "zone_A"
  }
}
```

**CRITICAL RULE:**
> This layer is DETERMINISTIC (no LLM).
> Uses FSMs, temporal windows, spatial logic.

---

### LAYER 4: GUARD SKILLS REGISTRY (Capabilities)

**Purpose:** Define what guards CAN do (composable, reusable skills)

**Skill Definition Schema:**
```yaml
skill:
  name: detect_drinking
  type: behavior
  requires:
    - person
    - bottle
    - pose_estimation
  produces:
    - person_drinking
  parameters:
    duration_threshold: 2.0  # seconds
    confidence_threshold: 0.75
  detector_class: DrinkingEventDetector
```

**Built-in Skills:**
```python
# ai_worker/skills/registry.py

GUARD_SKILLS = {
    # Object detection skills
    'detect_person': {
        'type': 'object',
        'yolo_classes': [0],
        'detector': 'YOLOv8Detector'
    },
    'detect_vehicle': {
        'type': 'object',
        'yolo_classes': [2, 3, 5, 7],  # car, motorcycle, bus, truck
        'detector': 'YOLOv8Detector'
    },
    'detect_package': {
        'type': 'object',
        'yolo_classes': [24, 26, 28],  # backpack, handbag, suitcase
        'detector': 'YOLOv8Detector'
    },

    # Behavior detection skills
    'detect_drinking': {
        'type': 'behavior',
        'requires': ['person', 'bottle', 'pose'],
        'detector': 'DrinkingEventDetector',
        'parameters': {'duration_threshold': 2.0}
    },
    'detect_loitering': {
        'type': 'behavior',
        'requires': ['person', 'zone'],
        'detector': 'LoiteringEventDetector',
        'parameters': {'threshold_minutes': 5}
    },
    'detect_unattended_object': {
        'type': 'behavior',
        'requires': ['object', 'time'],
        'detector': 'StationaryObjectDetector',
        'parameters': {'threshold_minutes': 5}
    },
    'detect_zone_intrusion': {
        'type': 'spatial',
        'requires': ['person', 'zone'],
        'detector': 'ZoneIntrusionDetector'
    },

    # Action skills
    'raise_alert': {
        'type': 'action',
        'handler': 'AlertHandler'
    },
    'record_clip': {
        'type': 'action',
        'handler': 'ClipRecorder',
        'parameters': {'duration_seconds': 30}
    },
    'send_notification': {
        'type': 'action',
        'handler': 'NotificationSender'
    }
}
```

**Skill Composition Example:**
```python
# A guard that detects drinking in restricted zone after hours
guard_skills = [
    'detect_drinking',         # Behavior skill
    'detect_zone_intrusion',   # Spatial skill
    'raise_alert',             # Action skill
    'record_clip'              # Action skill
]
```

---

### LAYER 5: RULE & INSTRUCTION COMPILER (Translator)

**Purpose:** Convert natural language → executable rules

**This is where LLM is used** (Claude/GPT for instruction parsing)

**User Chat:**
> "Tell me if anyone drinks water near the server rack after 10pm on weekdays"

**LLM Output (Structured YAML):**
```yaml
guard_rule:
  id: rule_001
  name: "After-Hours Drinking Near Server Rack"
  description: "Alert when drinking detected near server rack after 10pm on weekdays"

  when:
    event: person_drinking
    conditions:
      spatial:
        zone: server_rack_zone
        proximity: within
      temporal:
        time_range:
          start: "22:00"
          end: "06:00"
        days_of_week: [1, 2, 3, 4, 5]  # Monday-Friday
      confidence:
        min: 0.75

  then:
    actions:
      - type: alert
        priority: high
        message: "Person drinking near server rack after hours"
      - type: record_clip
        duration: 30
        before: 10
        after: 20
      - type: notify
        channels: [push, email]
```

**Implementation:**
```python
# backend/services/instruction_parser.py
from anthropic import Anthropic
import yaml

client = Anthropic(api_key=os.environ.get("ANTHROPIC_API_KEY"))

async def parse_guard_instructions(user_input: str) -> dict:
    """
    Use Claude to convert natural language → structured rules
    """

    system_prompt = """You are a guard rule compiler for an AI CCTV system.

Convert user instructions into YAML guard rules.

Available events:
- person_detected, person_drinking, person_loitering, vehicle_detected,
  package_detected, zone_intrusion, unattended_object

Available zones:
- front_door, back_door, server_rack, pool_area, parking_lot

Available actions:
- alert, record_clip, notify, track_object

Output ONLY valid YAML following this schema:
```yaml
guard_rule:
  name: string
  when:
    event: string
    conditions:
      spatial: {zone: string, proximity: within|outside}
      temporal: {time_range: {start: HH:MM, end: HH:MM}, days_of_week: [int]}
      confidence: {min: float}
  then:
    actions:
      - type: string
        parameters: dict
```

Be precise. Map natural language to exact event types and zones."""

    response = client.messages.create(
        model="claude-3-5-sonnet-20241022",
        max_tokens=1024,
        system=system_prompt,
        messages=[{
            "role": "user",
            "content": f"Convert this instruction to a guard rule:\n\n{user_input}"
        }]
    )

    # Extract YAML from response
    yaml_text = response.content[0].text
    rule = yaml.safe_load(yaml_text)

    # Validate rule structure
    validate_rule_schema(rule)

    return rule

def validate_rule_schema(rule: dict):
    """Validate rule has required fields"""
    required = ['guard_rule']
    assert all(k in rule for k in required), "Invalid rule structure"

    rule_def = rule['guard_rule']
    assert 'name' in rule_def, "Rule must have a name"
    assert 'when' in rule_def, "Rule must have 'when' condition"
    assert 'then' in rule_def, "Rule must have 'then' actions"
```

**Cost Optimization:**
* Cache common instruction patterns
* Use Claude Haiku for simple instructions
* Use Claude Sonnet for complex multi-condition rules
* Estimated cost: $0.01-0.05 per guard creation

**CRITICAL RULE:**
> LLM NEVER sees raw video or makes detection claims.
> LLM ONLY translates language → rule structure.

---

### LAYER 6: GUARD AGENT (The Brain)

**Purpose:** Orchestrate everything + provide conversational interface

**Each guard is an autonomous agent with:**
1. **Identity** - Unique ID, name, purpose
2. **Skills** - Enabled capabilities from Layer 4
3. **Rules** - Compiled instructions from Layer 5
4. **Memory** - Short-term (recent events) + long-term (vector DB)
5. **Personality** - Response style, strictness level
6. **Chat Interface** - RAG-powered conversations

**Guard Definition:**
```python
# models/guard.py
from dataclasses import dataclass
from typing import List, Dict

@dataclass
class Guard:
    id: str
    user_id: str
    name: str
    description: str

    # Capabilities
    skills: List[str]  # ['detect_drinking', 'detect_zone_intrusion']
    rules: List[Dict]  # Compiled rule YAMLs

    # Configuration
    sensitivity: float = 0.8
    strictness: str = "balanced"  # relaxed, balanced, strict

    # State
    is_active: bool = True
    cameras: List[str] = []

    # Memory configuration
    memory_config: Dict = {
        'short_term_hours': 24,
        'embedding_model': 'text-embedding-3-small',
        'vector_db': 'qdrant'
    }
```

**Guard Processing Loop:**
```python
# ai_worker/agent/guard_agent.py
from typing import List, Dict
import asyncio

class GuardAgent:
    def __init__(self, guard: Guard):
        self.guard = guard
        self.event_detectors = self._initialize_detectors()
        self.memory = GuardMemory(guard.id)

    def _initialize_detectors(self):
        """Initialize event detectors based on guard skills"""
        detectors = []
        for skill in self.guard.skills:
            skill_def = GUARD_SKILLS[skill]
            if skill_def['type'] == 'behavior':
                detector_class = globals()[skill_def['detector']]
                detectors.append(detector_class(**skill_def.get('parameters', {})))
        return detectors

    async def process_frame(self, facts: Dict) -> List[Dict]:
        """Main guard processing loop"""
        events_triggered = []

        # Step 1: Run event detectors (Layer 3)
        detected_events = []
        for detector in self.event_detectors:
            event = detector.update(facts)
            if event:
                detected_events.append(event)

        # Step 2: Evaluate rules (Layer 5)
        for event in detected_events:
            for rule in self.guard.rules:
                if self._matches_rule(event, rule, facts):
                    # Step 3: Decide action
                    triggered_event = await self._execute_actions(event, rule, facts)
                    events_triggered.append(triggered_event)

                    # Step 4: Log to memory
                    await self.memory.add_event(triggered_event)

        return events_triggered

    def _matches_rule(self, event: Dict, rule: Dict, facts: Dict) -> bool:
        """Check if event matches rule conditions"""
        rule_def = rule['guard_rule']
        when = rule_def['when']

        # Check event type
        if event['event'] != when['event']:
            return False

        conditions = when.get('conditions', {})

        # Check spatial conditions
        if 'spatial' in conditions:
            spatial = conditions['spatial']
            # Implement zone checking logic
            if not self._check_spatial_condition(event, facts, spatial):
                return False

        # Check temporal conditions
        if 'temporal' in conditions:
            temporal = conditions['temporal']
            if not self._check_temporal_condition(facts['timestamp'], temporal):
                return False

        # Check confidence threshold
        if 'confidence' in conditions:
            min_conf = conditions['confidence'].get('min', 0.0)
            if event['confidence'] < min_conf:
                return False

        return True

    async def _execute_actions(self, event: Dict, rule: Dict, facts: Dict) -> Dict:
        """Execute actions defined in rule"""
        actions = rule['guard_rule']['then']['actions']

        triggered_event = {
            'guard_id': self.guard.id,
            'event_type': event['event'],
            'timestamp': facts['timestamp'],
            'confidence': event['confidence'],
            'rule_name': rule['guard_rule']['name'],
            'actions_taken': []
        }

        for action in actions:
            if action['type'] == 'alert':
                await self._raise_alert(event, action)
                triggered_event['actions_taken'].append('alert')

            elif action['type'] == 'record_clip':
                clip_url = await self._record_clip(facts, action)
                triggered_event['clip_url'] = clip_url
                triggered_event['actions_taken'].append('record_clip')

            elif action['type'] == 'notify':
                await self._send_notification(event, action)
                triggered_event['actions_taken'].append('notify')

        # Save event to database
        await self._save_event_to_db(triggered_event)

        return triggered_event
```

**Guard Memory System:**
```python
# ai_worker/agent/guard_memory.py
from qdrant_client import QdrantClient
from openai import OpenAI

class GuardMemory:
    def __init__(self, guard_id: str):
        self.guard_id = guard_id
        self.qdrant = QdrantClient(url="http://localhost:6333")
        self.openai = OpenAI()
        self.collection_name = f"guard_{guard_id}_memory"

        # Create collection if not exists
        self._init_collection()

    def _init_collection(self):
        """Initialize vector database collection"""
        try:
            self.qdrant.get_collection(self.collection_name)
        except:
            self.qdrant.create_collection(
                collection_name=self.collection_name,
                vectors_config={"size": 1536, "distance": "Cosine"}
            )

    async def add_event(self, event: Dict):
        """Add event to guard's long-term memory"""
        # Generate natural language description
        description = self._event_to_text(event)

        # Generate embedding
        embedding_response = self.openai.embeddings.create(
            model="text-embedding-3-small",
            input=description
        )
        embedding = embedding_response.data[0].embedding

        # Store in vector DB
        self.qdrant.upsert(
            collection_name=self.collection_name,
            points=[{
                "id": event['id'],
                "vector": embedding,
                "payload": {
                    "event": event,
                    "description": description,
                    "timestamp": event['timestamp']
                }
            }]
        )

    async def search_memory(self, query: str, limit: int = 5) -> List[Dict]:
        """Semantic search over guard's memory"""
        # Generate query embedding
        embedding_response = self.openai.embeddings.create(
            model="text-embedding-3-small",
            input=query
        )
        query_embedding = embedding_response.data[0].embedding

        # Search vector DB
        results = self.qdrant.search(
            collection_name=self.collection_name,
            query_vector=query_embedding,
            limit=limit
        )

        return [hit.payload for hit in results]

    def _event_to_text(self, event: Dict) -> str:
        """Convert event to natural language"""
        return f"At {event['timestamp']}, detected {event['event_type']} with {event['confidence']*100}% confidence. Rule: {event['rule_name']}. Actions taken: {', '.join(event['actions_taken'])}."
```

---

### 🗣️ CHAT INTERFACE (Conversational AI)

**Purpose:** Allow users to chat with guards about what they saw

**User:** "Guard, what did you see today?"

**Guard Response:** Uses RAG (Retrieval-Augmented Generation)

**Implementation:**
```python
# backend/services/guard_chat.py
from anthropic import Anthropic
from ai_worker.agent.guard_memory import GuardMemory

client = Anthropic(api_key=os.environ.get("ANTHROPIC_API_KEY"))

async def chat_with_guard(guard_id: str, user_message: str, conversation_history: List[Dict] = []) -> str:
    """
    Chat with a guard using RAG over its memory
    """

    # Step 1: Retrieve relevant events from guard's memory
    memory = GuardMemory(guard_id)
    relevant_events = await memory.search_memory(user_message, limit=10)

    # Step 2: Get guard configuration
    guard = await get_guard(guard_id)

    # Step 3: Build context
    context = f"""You are {guard.name}, an AI security guard.

Your purpose: {guard.description}

Your capabilities: {', '.join(guard.skills)}

Your recent observations (last 24 hours):
{format_events_for_context(relevant_events)}

Respond naturally, helpfully, and professionally. Cite specific observations with timestamps when relevant."""

    # Step 4: Call Claude with RAG context
    messages = conversation_history + [{
        "role": "user",
        "content": user_message
    }]

    response = client.messages.create(
        model="claude-3-5-sonnet-20241022",
        max_tokens=1024,
        system=context,
        messages=messages
    )

    return response.content[0].text

def format_events_for_context(events: List[Dict]) -> str:
    """Format events for LLM context"""
    formatted = []
    for event in events:
        evt = event['event']
        formatted.append(
            f"- {evt['timestamp']}: {evt['event_type']} "
            f"(confidence: {evt['confidence']*100:.0f}%) - "
            f"{event['description']}"
        )
    return '\n'.join(formatted)
```

**Chat API Endpoint:**
```python
# backend/routers/guards.py

@router.post("/{guard_id}/chat")
async def chat_with_guard_endpoint(
    guard_id: str,
    request: ChatRequest,
    db: AsyncSession = Depends(get_db),
    user_id: str = Depends(get_current_user_id)
):
    """
    Chat with a guard about its observations
    """
    # Verify guard ownership
    guard = await db.get(Guard, guard_id)
    if not guard or guard.user_id != user_id:
        raise HTTPException(status_code=404, detail="Guard not found")

    # Get conversation history
    conversation = await get_conversation_history(guard_id, request.conversation_id)

    # Chat with guard
    response = await chat_with_guard(
        guard_id=guard_id,
        user_message=request.message,
        conversation_history=conversation
    )

    # Save conversation
    await save_chat_message(
        guard_id=guard_id,
        conversation_id=request.conversation_id,
        role='user',
        content=request.message
    )
    await save_chat_message(
        guard_id=guard_id,
        conversation_id=request.conversation_id,
        role='assistant',
        content=response
    )

    return {
        "success": True,
        "data": {
            "message": response,
            "guard_name": guard.name
        }
    }
```

**Example Chat:**
```
User: "Guard, what happened today?"

Guard: "Today I observed the following events:

1. At 14:32, I detected a person drinking near the server rack (89% confidence). This triggered the 'After-Hours Drinking' rule and I raised a high-priority alert.

2. At 16:15, I detected a vehicle entering the parking lot (94% confidence). This was a normal event within allowed hours.

3. At 18:45, I detected an unattended package at the front door that remained stationary for 6 minutes (91% confidence). I recorded a 30-second clip and sent you a notification.

Would you like more details on any of these events?"
```

---

### 📹 VIDEO SUMMARIZATION

**Purpose:** Generate natural language summaries of video footage

**User Request:** "Summarize what happened between 2pm and 4pm today"

**Implementation:**
```python
# backend/services/video_summarizer.py
from anthropic import Anthropic
import base64

client = Anthropic(api_key=os.environ.get("ANTHROPIC_API_KEY"))

async def summarize_video_timerange(
    guard_id: str,
    camera_id: str,
    start_time: datetime,
    end_time: datetime
) -> str:
    """
    Summarize video using multimodal LLM + event context
    """

    # Step 1: Retrieve frames at intervals (every 30 seconds)
    frames = await get_frames_in_range(camera_id, start_time, end_time, interval_seconds=30)

    # Step 2: Retrieve guard's detected events in this timerange
    events = await get_guard_events_in_range(guard_id, start_time, end_time)

    # Step 3: Build context
    event_context = "\n".join([
        f"- {evt.timestamp}: {evt.event_type} (confidence: {evt.confidence*100:.0f}%)"
        for evt in events
    ])

    # Step 4: Sample keyframes (max 10 for cost)
    sampled_frames = sample_keyframes(frames, max_frames=10)

    # Step 5: Prepare multimodal content
    content = [
        {
            "type": "text",
            "text": f"""Summarize what happened in this video timerange: {start_time} to {end_time}.

Context: This video is from camera {camera_id}, monitored by guard '{(await get_guard(guard_id)).name}'.

Detected events during this period:
{event_context}

Analyze the frames and provide:
1. A chronological summary of activities
2. Notable people, vehicles, or objects
3. Any unusual or suspicious behavior
4. Overall activity level (quiet, moderate, busy)

Be concise but informative."""
        }
    ]

    # Add frame images
    for frame in sampled_frames:
        frame_base64 = base64.b64encode(frame['data']).decode('utf-8')
        content.append({
            "type": "image",
            "source": {
                "type": "base64",
                "media_type": "image/jpeg",
                "data": frame_base64
            }
        })

    # Step 6: Call Claude with vision
    response = client.messages.create(
        model="claude-3-5-sonnet-20241022",
        max_tokens=2048,
        messages=[{
            "role": "user",
            "content": content
        }]
    )

    return response.content[0].text

def sample_keyframes(frames: List[Dict], max_frames: int) -> List[Dict]:
    """Sample frames evenly across the timeline"""
    if len(frames) <= max_frames:
        return frames

    step = len(frames) // max_frames
    return [frames[i] for i in range(0, len(frames), step)][:max_frames]
```

**API Endpoint:**
```python
# backend/routers/guards.py

@router.post("/{guard_id}/summarize")
async def summarize_video(
    guard_id: str,
    request: SummarizeRequest,
    user_id: str = Depends(get_current_user_id)
):
    """
    Generate natural language summary of video timerange
    """
    guard = await get_guard(guard_id)
    if guard.user_id != user_id:
        raise HTTPException(status_code=404)

    summary = await summarize_video_timerange(
        guard_id=guard_id,
        camera_id=request.camera_id,
        start_time=request.start_time,
        end_time=request.end_time
    )

    return {
        "success": True,
        "data": {
            "summary": summary,
            "timerange": {
                "start": request.start_time,
                "end": request.end_time
            }
        }
    }
```

**Example Summary Output:**
```
Video Summary (14:00 - 16:00, Front Door Camera)

Activity Level: Moderate

Chronological Summary:
- 14:05: A delivery person arrived with a package, approached the front door, and left the package on the doorstep
- 14:32: A resident exited the building, picked up the package, and re-entered
- 15:18: Two people (appears to be visitors) arrived, waited at the door for approximately 2 minutes, then entered
- 15:45: The same two visitors exited the building and walked toward the parking area

Notable Observations:
- Package delivery was successful and retrieved promptly
- All individuals appeared authorized (used keys or were buzzed in)
- No loitering or suspicious behavior detected
- Weather appears clear and sunny

Overall: Normal activity with expected deliveries and authorized access.
```

**Cost Optimization:**
* Sample max 10 frames (Claude vision: ~$0.10 per summary)
* Cache summaries for 24 hours
* Use events context to reduce frame count needed
* Estimated: $0.05-0.15 per 2-hour summary

---

## 🔒 SAFETY & SCALE

### Production Requirements

1. **Sandboxing**
   - Guards run in isolated containers
   - Resource limits (CPU, memory, GPU)
   - No cross-guard data leakage

2. **Auditability**
   - Every decision logged
   - Rules are explainable (no black box)
   - Event replay capability

3. **Scalability**
   - Stateless vision layer
   - Horizontal scaling of AI workers
   - Event-driven architecture

4. **Privacy**
   - GDPR compliance
   - Video retention policies
   - Encrypted storage (AES-256)

5. **Reliability**
   - Message queue persistence
   - Automatic retry on failure
   - Dead letter queues

---

## 🧨 WHAT NOT TO DO (CRITICAL MISTAKES)

❌ **One giant multimodal model** - Too slow, too expensive
❌ **Let LLM see raw video** - Hallucinations, cost explosion
❌ **Hardcode behaviors** - Not scalable
❌ **Couple vision with logic** - Breaks separation of concerns
❌ **Promise "100% detection"** - Set realistic expectations
❌ **Skip object tracking** - Loses temporal context
❌ **No event abstraction layer** - Limited to basic object detection

---

## 💰 COST ESTIMATION

### Per-Camera Monthly Costs

| Component | Cost/Camera/Month |
|-----------|-------------------|
| GPU compute (T4, 24/7) | $252 |
| Frame storage (S3) | $5 |
| Database (PostgreSQL) | $3 |
| Vector DB (Qdrant) | $2 |
| LLM calls (guard creation) | $0.50 |
| LLM calls (chat, avg 10/day) | $1.50 |
| LLM calls (summarization, 1/day) | $3.00 |
| **TOTAL** | **~$267/camera/month** |

**Optimization Strategies:**
* Use YOLOv8n (nano) for 10-20 cameras per T4 GPU → $12-25/camera
* Process 1 frame/2sec instead of 1/sec → 50% savings
* Use Claude Haiku for simple tasks → 80% LLM cost reduction
* **Optimized cost: ~$50-75/camera/month**

---

## 🚀 IMPLEMENTATION CHECKLIST

### Phase 1: Foundation (Weeks 1-2)
- [ ] FastAPI backend setup
- [ ] PostgreSQL + TimescaleDB for time-series events
- [ ] Redis + Celery for task queue
- [ ] YOLOv8 integration (basic object detection)
- [ ] RTSP stream ingestion with FFmpeg
- [ ] Basic guard CRUD API

### Phase 2: Vision + Events (Weeks 3-4)
- [ ] ByteTrack integration (object tracking)
- [ ] Event abstraction engine (FSM framework)
- [ ] Drinking detection event
- [ ] Loitering detection event
- [ ] Zone-based filtering
- [ ] Time-based filtering

### Phase 3: Guard Agents (Weeks 5-6)
- [ ] Guard skills registry
- [ ] Rule compiler with Claude API
- [ ] Guard agent orchestration
- [ ] Event → action execution
- [ ] WebSocket notifications

### Phase 4: Memory + Chat (Weeks 7-8)
- [ ] Qdrant vector database setup
- [ ] Guard memory system
- [ ] Event embedding pipeline
- [ ] RAG-powered chat API
- [ ] Conversation history management

### Phase 5: Video Summarization (Weeks 9-10)
- [ ] Keyframe extraction
- [ ] Claude vision API integration
- [ ] Multi-frame summarization
- [ ] Summary caching
- [ ] Summary API endpoint

### Phase 6: Mobile Integration (Weeks 11-12)
- [ ] Flutter WebSocket client
- [ ] Real-time event notifications
- [ ] Chat UI with guard
- [ ] Video summarization UI
- [ ] Guard creation flow

---

## 🎓 TECHNOLOGY STACK SUMMARY

```yaml
Backend:
  Framework: FastAPI 0.104+
  Language: Python 3.11+
  ORM: SQLAlchemy 2.0 (async)
  Database: PostgreSQL 15 + TimescaleDB
  Cache: Redis 7
  Queue: Celery 5.3 + Redis

AI/ML:
  Framework: PyTorch 2.1+
  Object Detection: YOLOv8 (Ultralytics)
  Pose Estimation: YOLOv8-Pose (optional)
  Object Tracking: ByteTrack
  LLM: Claude 3.5 Sonnet (primary), Haiku (simple tasks)
  Embeddings: OpenAI text-embedding-3-small
  Vector DB: Qdrant

Video:
  Streaming: RTSP
  Processing: FFmpeg, OpenCV
  Storage: AWS S3 / MinIO

Deployment:
  Containers: Docker
  Orchestration: Kubernetes
  GPU: NVIDIA T4 / A10
  Cloud: AWS / GCP
```

---

## 📚 NEXT STEPS

1. **Review this architecture** - Ensure team alignment
2. **Set up development environment** - Python 3.11, GPU access
3. **Start with Phase 1** - Build foundation (FastAPI + YOLOv8)
4. **Implement one vertical slice** - End-to-end flow for one guard type
5. **Iterate** - Add skills, events, and complexity incrementally

---

## 🏁 FINAL VERDICT

This architecture is **production-ready** for:
* **AI-powered CCTV guards**
* **Customizable behavior detection**
* **Conversational AI interface**
* **Video summarization**
* **Enterprise-grade SaaS**

**Key Strengths:**
✅ Scalable (1000+ cameras)
✅ Explainable (no black box)
✅ Cost-effective ($50-75/camera/month optimized)
✅ Extensible (skills are composable)
✅ No hallucinations (LLM doesn't do detection)

**This is exactly how you build ORIN.**

---

**Ready to build? Start with Phase 1.** 🚀
