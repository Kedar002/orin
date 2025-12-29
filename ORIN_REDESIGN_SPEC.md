# ORIN: COMMAND CENTER REDESIGN
**Presented to Steve Jobs for Final Approval**

---

## THE FUNDAMENTAL PROBLEM

The current app is organized like surveillance software:
- Spaces (technical concept)
- Guards (technical concept)
- Events (database thinking)
- Settings (every app has this)

**Steve, this is wrong.**

The user doesn't want to manage spaces, configure guards, or browse events.

**The user wants two things:**
1. "What's happening right now?"
2. "What happened before?"

That's it.

---

## THE SOLUTION: TWO TABS, NOT FOUR

### Current Navigation (REJECTED):
```
[Spaces] [Events] [Guards] [Settings]
```
Four equal tabs. No hierarchy. No focus.

### Redesigned Navigation (APPROVED):
```
[Home] [Timeline]
```

**Home** = What's happening now (the command center)
**Timeline** = What happened (AI-summarized history)

Settings → Profile icon (top right)
Guards → Invisible (they work in background)
Spaces → Gone (just containers, user doesn't care)

**Reasoning**: If you can't explain why something deserves a tab in one sentence, it shouldn't be a tab.

---

## HOME SCREEN: THE COMMAND CENTER

### Philosophy
"Everything is fine" should be the default state.

Most security apps assault you with grids, status lights, and noise.
**Orin says nothing when there's nothing to say.**

### Default State (All Clear)

```
┌─────────────────────────────────┐
│                                 │
│                                 │
│         All clear               │  ← Display, Bold, 34pt
│                                 │
│    Last checked 2 minutes ago   │  ← Caption, Regular, 13pt, 60% opacity
│                                 │
│                                 │
│                                 │
│                                 │
│      [White space]              │
│                                 │
│                                 │
│                                 │
│                                 │
└─────────────────────────────────┘
    [Home]              [Timeline]
```

**What you see**: Peace. Calm. Nothing demanding attention.

**What you don't see**:
- ❌ No camera grid
- ❌ No status indicators
- ❌ No "online" badges
- ❌ No guard states
- ❌ No space list

**Why**: If everything is working, show nothing. The absence of information IS information.

### Active State (Something Needs Attention)

```
┌─────────────────────────────────┐
│                                 │
│   ┌─────────────────────────┐  │
│   │                         │  │
│   │                         │  │
│   │    Camera Feed          │  │  ← Single camera, large
│   │    (Front Door)         │  │
│   │                         │  │
│   │                         │  │
│   └─────────────────────────┘  │
│                                 │
│   Package delivered             │  ← AI message (Semibold, 20pt)
│   Front door • 2 minutes ago    │  ← Context (Regular, 15pt, gray)
│                                 │
│           [View Video]          │  ← One action (Blue button)
│                                 │
└─────────────────────────────────┘
    [Home]              [Timeline]
```

**What changed**:
- Camera appears (only the relevant one)
- AI explains in plain English
- One action button (not five)
- Everything else stays hidden

**The rule**: One camera, one message, one action. Never more.

### When User Wants to See All Cameras

**Trigger**: Pull down on "All clear" screen
**Result**: Sheet slides up from bottom showing camera grid

```
┌─────────────────────────────────┐
│        ──  (handle)             │  ← Sheet handle
│                                 │
│   Cameras                       │  ← Title (Semibold, 20pt)
│                                 │
│   ┌──────────┐  ┌──────────┐  │
│   │          │  │          │  │  ← 2-column grid
│   │ Front    │  │ Backyard │  │     (only when requested)
│   │ Door     │  │          │  │
│   └──────────┘  └──────────┘  │
│                                 │
│   ┌──────────┐  ┌──────────┐  │
│   │          │  │          │  │
│   │ Driveway │  │ Office   │  │
│   │          │  │          │  │
│   └──────────┘  └──────────┘  │
└─────────────────────────────────┘
```

**Critical**: This is hidden by default. User must explicitly ask to see it.

---

## TIMELINE SCREEN: NOT A LOG FILE, A STORY

### Philosophy
AI has already filtered noise. User sees only what matters.

### Default View

```
┌─────────────────────────────────┐
│                                 │
│   Timeline                      │  ← Large title (Bold, 34pt)
│                                 │
│   Today                         │  ← Section (Semibold, 20pt)
│                                 │
│   Normal activity. 23 people    │  ← AI summary
│   detected, no alerts.          │     (Regular, 17pt, gray)
│                                 │
│   ─────────────────────────     │  ← Divider (subtle)
│                                 │
│   Package delivered             │  ← Event (Semibold, 17pt)
│   Front door • 2:34 PM          │     (Regular, 15pt, gray)
│                                 │
│   ─────────────────────────     │
│                                 │
│   Person detected               │
│   Driveway • 11:20 AM           │
│                                 │
│   ─────────────────────────     │
│                                 │
│   Yesterday                     │  ← Section
│                                 │
│   All clear                     │  ← AI summary
│   No activity detected          │
│                                 │
└─────────────────────────────────┘
```

**What you see**:
- AI summary for each day
- Short, human-readable events
- Clean separators

**What you don't see**:
- ❌ No thumbnails (unless tapped)
- ❌ No event type badges
- ❌ No guard names in list
- ❌ No "motion detected" spam
- ❌ No colored indicators
- ❌ No chevron icons

**Tap any event** → Sheet with video + AI details

---

## CAMERA VIEWER: WATCHING, NOT MONITORING

### Philosophy
Like looking through a window, not at a monitor.

### Default View (Video Playing)

```
┌─────────────────────────────────┐
│  ←                          ⋯  │  ← Minimal controls
│                                 │     (fade after 3 sec)
│                                 │
│                                 │
│        [Video Feed]             │  ← Full screen
│                                 │
│                                 │
│        ▶ LIVE                   │  ← Only badge visible
│                                 │
│                                 │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━  │  ← Progress (when visible)
│                                 │
└─────────────────────────────────┘
```

**What you see**: Just the video. Clean.

**What you don't see**:
- ❌ No persistent control bar
- ❌ No action buttons (share, download, etc.)
- ❌ No info overlay
- ❌ No "other cameras" list below

**Controls appear only when**:
- User taps screen
- User needs to do something
- Then fade after 3 seconds

### Action Sheet (When User Taps ⋯)

```
┌─────────────────────────────────┐
│        ──  (handle)             │
│                                 │
│   What do you want to do?       │  ← Simple question
│                                 │
│   Get AI summary                │  ← Action 1 (most common)
│   Share this video              │  ← Action 2
│   View camera details           │  ← Action 3
│                                 │
└─────────────────────────────────┘
```

**Removed**:
- ❌ Download (merged into Share)
- ❌ Snapshot (merged into Share)
- ❌ Info button (merged into details)
- ❌ Chat (too complex)

**Three actions. That's it.**

---

## AI COMMUNICATION: CALM, CONFIDENT, BRIEF

### Current Problems:
- Guards have names and personalities (too much)
- Chat interfaces (too complex)
- Technical language ("motion detected")
- Constant notifications

### Redesigned AI Language

**Bad** (technical):
```
Motion detected by Guard-01
Zone: Front Door
Confidence: 87%
Event ID: EVT-2847
```

**Good** (human):
```
Someone's at the front door
```

**AI Message Rules**:
1. One sentence maximum
2. No technical terms
3. No percentages or IDs
4. Action verb + location
5. Present tense

**Examples**:

| Event | Current | Redesigned |
|-------|---------|------------|
| Package delivery | "Motion Guard detected object at 14:32" | "Package delivered" |
| Person detected | "Person Detection triggered in Driveway" | "Someone's in the driveway" |
| All clear | "No events in last 24h" | "All clear" |
| Camera offline | "CAM-03 status: offline" | "Office camera needs attention" |

**Guards are invisible**:
- No guard names in UI
- No chat with guards
- No guard status toggles
- AI just works silently

If user asks "How does this work?" → Settings → About → Simple explanation

---

## COLOR PALETTE: TRUST & CALM

### Primary Neutral

**Light Mode**: Pure White `#FFFFFF`
**Dark Mode**: True Black `#000000`

**Why pure, not gray**:
- Maximum calm
- Maximum clarity
- Reduces eye fatigue during long monitoring sessions
- Evokes trust and cleanliness
- Like Apple Watch faces, not dashboards

### Accent Color (ONLY ONE)

**Light Mode**: System Blue `#007AFF`
**Dark Mode**: Light Blue `#0A84FF`

**Used exclusively for**:
- Primary action buttons ("View Video")
- AI indicators (subtle blue dot = AI is watching)
- Important state (LIVE badge)

**Forbidden uses**:
- ❌ Not for navigation icons (gray only)
- ❌ Not for decorative elements
- ❌ Not for multiple states

### Warning Color (RARE)

**Amber**: `#FF9500`

**Used only when**:
- Camera offline for >1 hour
- User decision required
- Something broken

**NOT used for**:
- Normal notifications
- Motion detected
- Events

### Red (ALMOST FORBIDDEN)

**Used only for**:
- Delete account
- Stop recording permanently
- Critical destructive actions

**Never used for**:
- Error messages
- Offline status
- Alerts

### Psychological Reasoning

**Why this works**:
1. **White/Black = Peace**: No constant visual noise
2. **Blue = Intelligence**: Calm, trustworthy, technical without being cold
3. **Amber = Caution**: Warm warning, not panic
4. **Red = Danger**: Reserved for real danger only

**Where color is FORBIDDEN**:
- ❌ Event type indicators (no green for person, red for alert)
- ❌ Camera status dots (no green online / red offline)
- ❌ Guard active states (no green active / gray inactive)
- ❌ Tab bar icons (all gray, selection via weight)

**Color replaces text**:
- Blue button = "This is what to do next"
- Amber text = "Look at this, but not urgent"
- Red text = "Stop and think"

---

## TYPOGRAPHY: INVISIBLE INTELLIGENCE

### Font Family

**SF Pro** (San Francisco) - Apple's system font

**Why**:
- Users already trust it (iPhone, Watch, Mac)
- Optimized for readability at all sizes
- Feels human, not corporate
- Invisible (doesn't call attention to itself)

### Hierarchy (Weight-Based Only)

| Level | Style | Usage | Example |
|-------|-------|-------|---------|
| **Display** | SF Pro Display, Bold, 34pt | Primary message | "All clear" |
| **Title** | SF Pro Text, Semibold, 20pt | Section headers | "Timeline" |
| **Body** | SF Pro Text, Regular, 17pt | Normal content | Event descriptions |
| **Caption** | SF Pro Text, Regular, 13pt, 60% opacity | Timestamps, metadata | "2 minutes ago" |

### Rules

**Forbidden**:
- ❌ All-caps (except tiny labels like "LIVE")
- ❌ Italic
- ❌ Underline
- ❌ Multiple fonts
- ❌ Decorative weights (light, ultra-bold)

**Typography replaces UI chrome**:

**Bad** (needs container):
```
┌─────────────────┐
│  All Clear      │  ← Box needed to show importance
└─────────────────┘
```

**Good** (weight shows importance):
```
All clear            ← 34pt Bold (obviously important)
Last checked 2m ago  ← 13pt Regular (supporting info)
```

**Size hierarchy IS the interface**:
- Large = important now
- Medium = standard information
- Small = context/metadata
- Tiny = system labels

---

## ICONOGRAPHY: LESS THAN LESS

### The Rule

**If text works, remove the icon.**
**If icon works, remove the text.**
**Never both.**

### Stroke Rules (When Icons Exist)

- **Style**: SF Symbols
- **Weight**: Regular (matches text)
- **Size**: 20pt (most common), 24pt (navigation)
- **Stroke**: 2pt
- **Corners**: Rounded (4pt radius)

### When Icons ARE Used

**Navigation** (bottom tabs):
- Home: House outline
- Timeline: Clock outline

**Actions** (minimal):
- Play: Triangle
- Share: Square with arrow
- Close: X

**AI Presence** (rare):
- Sparkle: ✨ (only when AI has insight)

### When Icons Are FORBIDDEN

❌ **Next to every label**:
```
Bad:
📷 Front Door
👤 Person detected
📦 Package delivered
```

✅ **Just the text**:
```
Good:
Front Door
Person detected
Package delivered
```

❌ **Status indicators**:
```
Bad:
🟢 Camera online
🔴 Camera offline
```

✅ **Words instead**:
```
Good:
Front Door (no indicator = working)
Office camera needs attention (when offline)
```

❌ **Event types**:
```
Bad:
[👤 icon] Person
[📦 icon] Package
```

✅ **Description only**:
```
Good:
Someone's at the door
Package delivered
```

### Examples Approved

**Navigation** (icons only, no labels):
```
[🏠]        [🕐]
Home      Timeline
```

**Camera controls** (icons only, brief appearance):
```
[←]  (back)
[⋯]  (more)
[▶]  (play/pause)
```

**Action sheet** (text only):
```
Get AI summary
Share this video
View camera details
```

---

## LAYOUT: COMMAND CENTER WITHOUT CHAOS

### Grid System

**Base unit**: 8pt
**Common spacing**: 16pt, 24pt, 32pt, 48pt

**Margins**:
- Screen edges: 20pt
- Content blocks: 16pt between elements
- Sections: 32pt between sections

**Why 8pt grid**:
- Aligns perfectly with Apple's HIG
- Scales across devices
- Creates natural rhythm

### Safe Zones

```
┌─────────────────────────────────┐
│     ← 48pt top safe zone        │
│                                 │
│  20pt → ┌──────────────┐  ← 20pt
│         │              │        │
│         │   Content    │        │
│         │              │        │
│         └──────────────┘        │
│                                 │
│     32pt bottom safe zone →    │
└─────────────────────────────────┘
```

**Camera safe zone**:
- Cameras never touch screen edges
- Minimum 12pt breathing room
- Maintains 16:9 or 4:3 aspect (no stretching)

### Screen Structure: One Primary Focus

**Home Screen** (default):
```
┌─────────────────────────────────┐
│          48pt space             │  ← Safe zone
│                                 │
│         All clear               │  ← Primary (Display Bold)
│                                 │
│    Last checked 2m ago          │  ← Secondary (Caption)
│                                 │
│          32pt space             │
│                                 │
│                                 │  ← Intentional white space
│     [Everything else hidden]    │
│                                 │
│                                 │
│          32pt space             │  ← Bottom safe zone
└─────────────────────────────────┘
```

**Home Screen** (active):
```
┌─────────────────────────────────┐
│          48pt space             │
│   ┌─────────────────────────┐  │
│   │                         │  │  ← Camera (primary focus)
│   │      Video Feed         │  │     Takes 60% of height
│   │                         │  │
│   └─────────────────────────┘  │
│          16pt space             │
│   Package delivered             │  ← AI message (secondary)
│   Front door • 2m ago           │  ← Context (tertiary)
│          24pt space             │
│        [View Video]             │  ← Action (clear)
│          32pt space             │
└─────────────────────────────────┘
```

### Content Rhythm

**Rule**: One hero, everything else supports.

**Bad** (competing elements):
```
┌────────┐  ┌────────┐  ┌────────┐
│Camera 1│  │Camera 2│  │Camera 3│  ← Equal weight
└────────┘  └────────┘  └────────┘
  Status      Status      Status   ← Visual noise
```

**Good** (clear hierarchy):
```
       ┌──────────────────┐
       │                  │
       │   Camera Feed    │          ← Hero
       │                  │
       └──────────────────┘

       Package delivered             ← Supporting text
       Front door • 2m ago

            [Action]                 ← Clear next step
```

### White Space is Mandatory

**Philosophy**: Empty space is not wasted. It's restful.

**Minimum white space requirements**:
- Between elements: 16pt (never less)
- Around camera: 20pt
- Top/bottom of screen: 48pt / 32pt
- Inside cards: 16pt padding minimum

**Why this matters**:
- Reduces anxiety (not crowded)
- Increases focus (eye knows where to look)
- Feels premium (not cheap dashboard)

---

## MOTION: CAUSE AND EFFECT ONLY

### Philosophy

Motion exists only to:
1. **Explain**: "Here's where this came from"
2. **Confirm**: "I received your action"
3. **Calm**: "This transition is smooth, not jarring"

**No animation for delight.** This is a command center, not a game.

### Timing

| Speed | Duration | Usage |
|-------|----------|-------|
| **Quick** | 200ms | Button press, toggle switch |
| **Standard** | 300ms | Screen transition, sheet appearance |
| **Slow** | 500ms | State change (all clear → alert) |

**Easing**: `ease-in-out` for everything

**Forbidden**:
- ❌ Bounce
- ❌ Spring (except pull-to-refresh)
- ❌ Elastic
- ❌ Custom curves

### Motion That Exists

**1. Explain (Sheet slides up)**
```
User taps "More cameras"
→ Sheet slides from bottom (300ms ease-in-out)
→ User understands: "This was hidden below"
```

**2. Confirm (Button feedback)**
```
User taps "View Video"
→ Button scales 1.0 → 0.95 → 1.0 (200ms)
→ User knows: "Tap was registered"
→ Screen transitions
```

**3. Calm (State crossfade)**
```
State changes from "All clear" to "Alert"
→ Elements fade out (300ms)
→ New elements fade in (300ms)
→ No jarring pop, smooth transition
```

### Motion That is REMOVED

❌ **Animated icons**: No pulsing, no spinning, no breathing
❌ **Loading spinners**: Use indeterminate progress only
❌ **Celebration**: No confetti, no checkmarks flying
❌ **Attention grabbers**: No shaking, no bouncing
❌ **Progress bars**: Use simple fade if loading needed
❌ **Parallax**: No fancy scrolling effects

### How AI "Presence" is Felt Without Movement

**Instead of**: Animated AI assistant character
**We use**: Subtle text fade-in

**Instead of**: Pulsing "AI is thinking" indicator
**We use**: Brief pause, then answer appears

**Instead of**: Robot avatar
**We use**: Simple sparkle icon (✨) when AI adds insight

**The AI feels present because**:
- Answers appear quickly (< 1 second)
- Language is confident ("Someone's at the door" not "Possibly a person detected")
- Timing is natural (not instant, not slow)

### Examples

**Screen Transition** (Home → Timeline):
```
User taps Timeline tab
→ Current screen fades to 0.7 opacity (150ms)
→ New screen fades in from 0 → 1 (150ms)
→ Total: 300ms, smooth crossfade
```

**Alert Appearance**:
```
Camera detects package
→ "All clear" fades out (300ms)
→ Camera view fades in (300ms, starts when text fades halfway)
→ AI message slides up from below camera (200ms)
→ Feels like: information revealing naturally, not interrupting
```

---

## REMOVAL & SIMPLIFICATION AUDIT

### REMOVED ENTIRELY

#### From Navigation:
- ❌ **Spaces tab**: Merged into Home
  *Why*: Users don't think in "spaces", they think "what's happening"

- ❌ **Guards tab**: Guards are now invisible
  *Why*: Guards are a technical implementation, not a user concept

- ❌ **Settings tab**: Moved to profile icon
  *Why*: Most users never touch settings. Hide them.

#### From Home Screen (was Spaces):
- ❌ **List of all spaces**: Show only active/relevant
  *Why*: If nothing's happening, show nothing

- ❌ **"Add Space" button**: Moved to settings
  *Why*: Setup happens once, shouldn't clutter daily view

- ❌ **Camera grid by default**: Hidden until requested
  *Why*: Grids are overwhelming. One camera when needed.

- ❌ **Status badges** (Online, LIVE, etc.): Assumed working
  *Why*: Green dots everywhere = visual noise. Only show problems.

- ❌ **Camera IDs** (CAM-001, CAM-002): Removed
  *Why*: Technical identifier, not helpful to user

- ❌ **Location breadcrumbs** (Space > Camera): Simplified
  *Why*: User knows where their front door is

#### From Timeline (was Events):
- ❌ **Event type badges** (colored circles): Removed
  *Why*: Color coding requires learning. Use words.

- ❌ **Thumbnail images for every event**: Hidden by default
  *Why*: List becomes too heavy. Show on demand.

- ❌ **Guard name in list view**: Moved to detail
  *Why*: User doesn't care which guard caught it

- ❌ **Chevron icons** on every row: Removed
  *Why*: Whole row is tappable. Icon is redundant.

- ❌ **"Today/Yesterday/This Week" in all-caps**: Lowercase
  *Why*: Less shouting, more calm

#### From Guards:
- ❌ **Guards as visible concept**: Made invisible
  *Why*: User wants outcome, not process

- ❌ **Chat interface with guards**: Removed
  *Why*: Too complex. AI just gives answers.

- ❌ **Guard status toggles**: Auto-managed
  *Why*: Guards should manage themselves

- ❌ **Guard descriptions** in list: Removed
  *Why*: Tell user what it does when it does it, not upfront

#### From Settings:
- ❌ **"Network Settings"**: Removed
  *Why*: Power users only. Hide in Advanced.

- ❌ **"System Health"**: Removed
  *Why*: If broken, we'll tell you. Otherwise don't worry.

- ❌ **"Storage"**: Removed
  *Why*: Cloud handles it. User doesn't need to know.

- ❌ **"About" section**: Simplified to version number in profile
  *Why*: Legal info only when needed.

- ❌ **Icons next to every setting row**: Removed
  *Why*: Text is clearer than icon + text

#### From Camera Viewer:
- ❌ **Action bar with 5 buttons**: Reduced to 3
  *Why*: Download + Snapshot + Share = Just "Share"

- ❌ **"Other Cameras" horizontal scroll**: Removed
  *Why*: If watching one camera, stay focused

- ❌ **Separate Info / Summarize / Chat sheets**: Combined
  *Why*: One "What happened" is enough

- ❌ **Technical info** (Resolution, Frame Rate, Uptime): Hidden
  *Why*: User doesn't care about FPS

- ❌ **LIVE badge** when not live: Removed
  *Why*: Only show "LIVE" when actually live

### MERGED / COMBINED

**Spaces + Guards + Live State** → **Home**
*Before*: 3 separate concepts
*After*: One intelligent command center

**Camera Info + AI Summary + Technical Details** → **What Happened**
*Before*: Multiple sheets with overlapping info
*After*: One sheet with relevant info only

**Download + Share + Snapshot** → **Share**
*Before*: 3 different actions
*After*: System share sheet handles all

**Profile + Account + Password & Security** → **Account**
*Before*: Scattered across settings
*After*: One screen for identity

### SIMPLIFIED (Made Simpler)

**Event descriptions**:
*Before*: "Motion Guard detected person in Driveway at 2:34 PM"
*After*: "Someone's in the driveway"

**AI communication**:
*Before*: Chat interface with back-and-forth
*After*: Instant answers, no conversation

**Camera selection**:
*Before*: Always show all cameras in grid
*After*: Show one when needed, grid on request

**Navigation**:
*Before*: 4 equal-weight tabs
*After*: 2 tabs with clear hierarchy

**Color palette**:
*Before*: Multiple accent colors (blue, green, red, amber)
*After*: One blue, amber for warnings only

---

## WHAT CHANGED VS WHAT STAYED

### WHAT CHANGED

| Component | Before | After | Why |
|-----------|--------|-------|-----|
| **Navigation** | 4 tabs | 2 tabs | Focus. User wants "now" or "before" |
| **Home Screen** | Spaces list → Camera grid | Single intelligent view | Calm default. Show only what matters |
| **AI Communication** | Named guards + chat | Anonymous AI + statements | Guards are implementation detail |
| **Camera Display** | Always in grid | Contextual single view | Grids are overwhelming |
| **Events** | Technical log | AI-narrated timeline | Humans need stories, not data |
| **Settings** | Full tab | Profile sheet | Settings are rarely used |
| **Color System** | Multiple accents | One blue + amber | Consistency reduces cognitive load |
| **Typography** | Mixed weights | Strict hierarchy | Size and weight replace UI chrome |
| **Iconography** | Icons everywhere | Icons only when necessary | Text is clearer than symbols |
| **Motion** | Various transitions | 3 timings only | Predictable, not fancy |
| **Default State** | Show everything | Show nothing | Peace unless action needed |

### WHAT STAYED (Because It's Right)

| Component | Why It Stayed |
|-----------|--------------|
| **Minimal aesthetic** | Already Apple-style, no decoration |
| **Dark mode support** | Essential for long monitoring sessions |
| **Clean typography** | SF Pro is correct choice |
| **Simple transitions** | Fades over slides was already right |
| **Card-based UI** | CleanCard component is good foundation |
| **No gradients/shadows** | Already removed, correctly |

---

## IMPLEMENTATION PLAN

### Phase 1: Core Redesign (Foundation)

**Files to modify**:
1. `app_shell.dart` - Reduce navigation from 4 to 2 tabs
2. Create `home_screen.dart` - New command center (replaces spaces)
3. Rename `events_screen.dart` → `timeline_screen.dart`
4. Remove `guards_screen.dart` - Make guards invisible
5. Convert `settings_screen.dart` → Profile sheet

**New components needed**:
- `CommandCenterView` - Home screen default state
- `ActiveAlertView` - Home screen active state
- `TimelineSummary` - AI daily summaries
- `SimpleEventRow` - Minimal event display

### Phase 2: AI Language (Intelligence Layer)

**Files to create**:
1. `ai_messages.dart` - Convert technical events to human language
2. `ai_filter.dart` - Decide what's important enough to show
3. `ai_summary.dart` - Daily summaries for timeline

**Logic changes**:
- Events labeled "motion detected" → Filtered unless relevant
- Camera status "online" → Invisible (only show offline)
- Guard names → Removed from user-facing text

### Phase 3: Visual Polish (Refinement)

**Files to modify**:
1. `app_colors.dart` - Reduce to pure white/black + blue + amber
2. `app_theme.dart` - Enforce typography hierarchy
3. `camera_viewer_screen.dart` - Hide controls by default
4. Remove all status badges from camera cards

**Component updates**:
- Remove all color-coded status indicators
- Enforce 8pt grid spacing throughout
- Remove icons from text labels

### Phase 4: Motion & Interaction (Feel)

**Files to modify**:
1. `app_shell.dart` - Crossfade transitions between tabs
2. `home_screen.dart` - Subtle fades for state changes
3. `camera_viewer_screen.dart` - Control auto-hide timing

**Animation standards**:
- All transitions: 300ms ease-in-out
- All confirmations: 200ms scale
- All state changes: 500ms crossfade

---

## STEVE JOBS FINAL TEST

### Q1: Would Steve Jobs say "This is obvious"?

**YES.**

A non-technical user opens the app:
- Sees "All clear"
- Understands immediately: Nothing needs attention
- Knows where to look if something happens
- Can find history in Timeline

No manual needed. No tutorial required. **Obvious.**

### Q2: Would a non-technical user trust this?

**YES.**

The app speaks plain English:
- "Package delivered" (not "Motion Guard detected object")
- "Someone's at the door" (not "Person Detection triggered")
- "All clear" (not "0 events in last 24h")

The AI doesn't announce itself. It just works.
The user trusts it **because it's calm and confident.**

### Q3: Does the AI feel invisible but powerful?

**YES.**

The user never sees:
- Guard configuration
- Technical settings
- Processing indicators
- "AI is thinking" loaders

The user only sees:
- Relevant camera when needed
- Plain English explanations
- One clear action

**The AI is felt through its silence and its accuracy.**

### Q4: Did we remove more than we added?

**YES.**

**Removed**:
- 2 navigation tabs (Spaces, Guards, Settings as tabs)
- Camera grids by default
- Status badges (online, LIVE everywhere)
- Event type indicators
- Guard names and chat
- Technical info (FPS, resolution, uptime in main UI)
- Action buttons (5 → 3)
- Icons next to text
- All-caps headers
- Multiple accent colors

**Added**:
- "All clear" default state
- AI natural language
- Contextual camera focus
- Daily summaries in timeline

**Net**: Massive reduction. Removed ~15 concepts. Added ~4 states.

---

## FINAL DESIGN THESIS

**The camera is not the product.**
**The AI is not the product.**
**Clarity is the product.**

Most security apps show you everything and make you figure out what matters.

**Orin shows you nothing until something matters.**

This is not surveillance software.
This is not a technical dashboard.
This is a calm, intelligent assistant that watches quietly and speaks only when necessary.

Like a great security guard: **Always watching. Rarely talking. Never panicking.**

---

**Steve, this is ready to ship.**

The app does two things:
1. Shows what's happening now
2. Shows what happened before

Everything else is hidden.
The AI is invisible.
The interface is inevitable.

**Simple. Obvious. Calm.**
