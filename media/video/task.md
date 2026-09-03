# 12TRA Video — Production Tracker

> **Pipeline:** Kling AI (free) → ElevenLabs → CapCut (free) → YouTube Audio Library
> **Target:** ~2:30 video, non-commercial, watermarks acceptable
> **Note:** ElevenLabs free tier no longer exists. Alternatives: FreeTTS.ai (unlimited, no signup) or Google AI Studio TTS (free tier, steerable narration with style tags). ElevenLabs Starter is $5/mo if preferred.

---

## Phase 1 — Narration (ElevenLabs Free)

- [x] Sign up at elevenlabs.io
- [x] Choose narrator voice
- [x] Generate Scene 1 narration: *"The Time App… because Time is of the Essence."*
- [x] Generate Scene 2 narration: *"We measure time constantly…"*
- [x] Generate Scene 3 narration: *"The Sun drives our daily rhythm…"*
- [x] Generate Scene 4 narration: *"This is what 12TRA proposes…"*
- [x] Generate Scene 5 narration: *"12TRA doesn't predict your mood…"*
- [x] Generate Scene 6 narration: *"Imagine being able to see where you are…"*
- [x] Generate Scene 7 narration: *"The Time App. Synchronize with the architecture of change."*
- [x] Download all audio clips — saved to `docs/video/audio/`
- [x] Time each clip (timings recorded below and in `video-script.md`)

### ✅ Phase 1 Complete — Narration Timings

| Scene | File | Duration |
|-------|------|----------|
| 1 | `scene-01-narration.mp3` | 4.4s |
| 2 | `scene-02-narration.mp3` | 13.4s |
| 3 | `scene-03-narration.mp3` | 30.3s |
| 4 | `scene-04-narration.mp3` | 34.4s |
| 5 | `scene-05-narration.mp3` | 37.7s |
| 6 | `scene-06-narration.mp3` | 33.7s |
| 7 | `scene-07-narration.mp3` | 35.3s |
| **Total** | | **~3:09** |

## Phase 2 — Video Clips (Kling AI Free, ~3 days)

### Day 1: Cosmic scenes
- [x] Sign up at klingai.com
- [x] Scene 1: Upload `banner.png` → generated 6s zoom-in clip → `scene-01-video.mp4`
- [x] Scene 2: `scene_earth_time.png` animated in CapCut via Ken Burns zoom (13.4s)
- [x] Scene 3a: Upload `scene_sun_closeup.png` → generated 5s clip → `scene-03a-video.mp4`
- [x] Scene 3b: Upload `scene_new_moon_gravity.png` → generated 5s clip → `scene-03b-video.mp4`

### Day 2: More cosmic + archetype wheel
- [x] Scene 3c: Upload `scene_full_moon_gravity.png` → generated 5s clip → `scene-03c-video.mp4`
- [x] Scene 3d: Upload `scene_lunar_cycle.png` → generated 5s clip → `scene-03d-video.mp4`
- [x] Scene 4: Upload `scene_archetypes_wheel.png` → generated 5s clip → `scene-04-video.mp4`

### Day 3: Closing + re-dos
- [x] Scene 7: Upload `banner.png` → generated clip → `scene-07-video.mp4`

### ✅ Phase 2 Complete — AI Video Generation

All primary animated video clips generated!

---

## Phase 3 — Static Screenshot Animation & Setup (CapCut)

> These don't need Kling — use Ken Burns effects in the editor

- [ ] `app_moon_screen.png` — slow zoom into archetype section
- [ ] `app_solar_screen.png` — slow zoom showing day progress
- [ ] `app_seconds_screen.png` — gentle pan across the timer
- [ ] `hypothesis_header.png` — brief 3s reveal
- [ ] `hypothesis_archetypes.png` — slow scroll/pan
- [ ] `hypothesis_emotional_weather.png` — slow pan
- [ ] `hypothesis_time_machine.png` — slow pan
- [ ] `hypothesis_toc.png` — sweep/scroll effect
- [ ] `hypothesis_conclusion.png` — slow reveal

## Phase 4 — Assembly & Editing (CapCut)

- [x] Import all Kling video clips
- [x] Import all narration audio files
- [x] Import static screenshots
- [x] Arrange clips on timeline per [video-script.md](file:///home/x90/personal/projects/the-time-app/docs/video/video-script.md)
- [ ] Apply Ken Burns effects to static screenshots
- [ ] Add text overlays:
  - [ ] "THE HYPOTHESIS: Change has structure…" at ~0:45
  - [ ] Archetype sequence (SPARK → ANALYST → …) at ~1:05
  - [ ] "Observe → Understand → Predict → Leverage" at ~2:00
  - [ ] "Available on Android · thetimeapp.co.za" at ~2:10
- [ ] Add 2s dissolve transitions between scenes
- [ ] Add ambient music from YouTube Audio Library
- [x] Export at 720p 30fps

## Phase 5 — Review & Upload

- [ ] Watch full video — check pacing and flow
- [ ] Run Gemini validation prompt (see [production_guide.md](file:///home/x90/.gemini/antigravity-ide/brain/b7786ee5-1913-47ee-a20d-93f472116550/production_guide.md))
- [ ] Make adjustments based on feedback
- [x] Upload to YouTube
- [ ] Set title: "What If Change Has Structure? | The 12 Temporal Resonance Architecture"
- [x] Add description, tags, and thumbnail
- [ ] Publish

---

## Asset Locations

| Asset Type | Path |
|-----------|------|
| All screenshots & scenes | `docs/video/screenshots/` |
| Video script | `docs/video/video-script.md` |
| Per-scene Kling prompts | Production guide (this conversation) |
| Validation prompt | Production guide (this conversation) |
