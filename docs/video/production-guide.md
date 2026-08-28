# 12TRA Video — Production Guide & Tool Research

## Cost Comparison Matrix

### Video Generation Tools

| Tool | Free Tier | Clips/Day (Free) | Quality | Image-to-Video | Best For | Paid Starting At |
|------|-----------|-------------------|---------|----------------|----------|------------------|
| **Kling AI** | ✅ 66 credits/day | ~3–6 clips (5s each) | 720p, watermark | ✅ Yes | Budget option, decent quality | $8.80/mo (Standard) |
| **Runway Gen-4.5** | ⚠️ One-time 125 credits | ~5–8 clips total | High, watermark | ✅ Yes | Best image-to-video fidelity | $15/mo (Standard) |
| **Pika 2.5** | ✅ 80 credits/month | ~8–10 clips/month | 480p, watermark | ✅ Yes | Simple motion on stills | $8/mo (Standard) |
| **Luma Ray 3.2** | ✅ ~80 credits/day | ~3–5 clips/day | Medium, watermark | ✅ Yes | Quick iterations | $30/mo (Plus) |
| **Veo 3.1 (Google)** | ❌ Pay-per-use | N/A | Best cinematic quality | ✅ Yes | Premium cosmic scenes | $0.03–$0.60/sec |

### Narration Tools

| Tool | Free Tier | Free Duration | Quality | Commercial Rights | Paid Starting At |
|------|-----------|---------------|---------|-------------------|------------------|
| **ElevenLabs** | ✅ 10,000 chars/month | ~10 min | Excellent, most natural | ❌ Free = non-commercial | $5/mo (Starter, commercial OK) |
| Google Cloud TTS | ✅ 1M chars/month | Generous | Good, slightly robotic | ✅ Yes | Pay-as-you-go after |

### Assembly / Editing

| Tool | Free | Watermarks | Timeline | Text Overlays | Best For |
|------|------|------------|----------|---------------|----------|
| **CapCut (web/desktop)** | ✅ | Only on Pro assets | Multi-track | ✅ (avoid Pro templates) | Quick assembly, easy UI |
| **DaVinci Resolve** | ✅ Full version | None | Professional | ✅ Full control | Professional-grade editing |

---

## Recommended Pipeline (Budget-Optimized)

> [!TIP]
> **Total minimum cost: $0 (with watermarks) or ~$14–24/mo for clean output**

### Strategy: Kling (free) + ElevenLabs (free/$5) + CapCut (free)

This pipeline works within free tiers. The trade-offs are watermarks and 720p resolution. For a clean YouTube video, upgrading Kling to Standard ($8.80/mo) removes watermarks and gives 1080p.

| Phase | Tool | Tier | Cost | Notes |
|-------|------|------|------|-------|
| **1. Narration** | ElevenLabs | Free or Starter | $0–$5/mo | ~310 words ≈ ~1,800 chars. Free tier covers this easily. Starter for commercial rights. |
| **2. Video clips** | Kling AI | Free | $0 | 66 credits/day resets. Generate ~3–5 scenes/day across 3 days. |
| **3. Assembly** | CapCut | Free | $0 | Combine clips + narration + text overlays + music. Avoid Pro-tagged templates. |
| **4. Music** | YouTube Audio Library | Free | $0 | Royalty-free ambient tracks. |

### Alternative: Premium Route

If you want the highest quality and no watermarks:

| Phase | Tool | Tier | Cost |
|-------|------|------|------|
| **1. Narration** | ElevenLabs | Starter | $5/mo |
| **2. Video clips** | Runway Gen-4.5 | Standard | $15/mo |
| **3. Assembly** | DaVinci Resolve | Free | $0 |
| **Total** | | | **$20/mo** |

---

## Execution Checklist

### Day 1 — Narration

- [ ] Sign up for ElevenLabs (elevenlabs.io)
- [ ] Choose a voice (recommend: "Adam" or "Rachel" for warmth)
- [ ] Generate narration for each scene separately (see prompts below)
- [ ] Download WAV/MP3 files per scene
- [ ] Time each clip — this locks your scene durations

### Day 2 — Video Clips (Scenes 1–4)

- [ ] Sign up for Kling AI (klingai.com)
- [ ] Upload `banner.png` → generate Scene 1 clip (slow zoom, 5s)
- [ ] Upload `scene_earth_time.png` → generate Scene 2 clip (slow pan, 10s)
- [ ] Upload `scene_sun_closeup.png` → generate Scene 3a clip (4s)
- [ ] Upload `scene_new_moon_gravity.png` → generate Scene 3b clip (5s)
- [ ] Upload `scene_full_moon_gravity.png` → generate Scene 3c clip (5s)
- [ ] Upload `scene_lunar_cycle.png` → generate Scene 3d clip (8s)

### Day 3 — Video Clips (Scenes 5–7) + App Screenshots

- [ ] Upload `scene_archetypes_wheel.png` → generate Scene 4 clip (12s slow rotation)
- [ ] For app screenshots: use CapCut's Ken Burns (pan/zoom) — no video gen needed
- [ ] Upload `scene_lunar_cycle.png` → generate Scene 6a clip (6s)
- [ ] Upload `banner.png` → generate Scene 7 clip (zoom out, 8s)

### Day 4 — Assembly

- [ ] Import all clips + narration into CapCut or DaVinci Resolve
- [ ] Arrange on timeline per script
- [ ] Add text overlays (use Inter or similar sans-serif font)
- [ ] Add transitions (2s dissolves between scenes)
- [ ] Add ambient music from YouTube Audio Library
- [ ] Add 10s black end screen
- [ ] Export at 1080p, 30fps

### Day 5 — Review & Upload

- [ ] Run the validation prompt (see below) with Gemini
- [ ] Make adjustments
- [ ] Upload to YouTube with suggested metadata

---

## Per-Scene Generation Prompts

These prompts are optimized for **Kling AI image-to-video**. Upload the referenced image, then paste the prompt.

### Scene 1 — Banner (5 seconds)

**Input image:** `banner.png`
```
Slow, elegant zoom-in on this banner image. Subtle twinkling star particles drift in the dark background behind the moon. The clock hands move very slightly. Cinematic, smooth, premium feel. Camera slowly pushes forward. Dark cosmic atmosphere.
```

### Scene 2 — Earth (10 seconds)

**Input image:** `scene_earth_time.png`
```
Slow cinematic push toward Earth from space. The planet rotates very slowly. City lights on the dark side twinkle gently. The atmosphere glows along the terminator line. The Moon in the background drifts slightly. Deep space, stars visible. Smooth, documentary-style camera movement.
```

### Scene 3a — Sun Close-up (4 seconds)

**Input image:** `scene_sun_closeup.png`
```
Solar surface alive with churning plasma and subtle solar flares. Corona shimmers and dances. Deep black space behind. Slow, dramatic push toward the surface. Cinematic and awe-inspiring.
```

### Scene 3b — New Moon Alignment (5 seconds)

**Input image:** `scene_new_moon_gravity.png`
```
The gravitational field lines between Earth, Moon, and Sun pulse gently with translucent energy. The dark Moon drifts very slightly in its orbit. The Sun blazes in the background. Subtle wave-like ripples flow along the field lines. Cinematic space scene.
```

### Scene 3c — Full Moon (5 seconds)

**Input image:** `scene_full_moon_gravity.png`
```
The fully illuminated Moon glows brightly above Earth. Subtle gravitational arcs shimmer between the celestial bodies. Earth's atmosphere creates a thin blue glow. Stars twinkle in deep space. Slow, majestic camera drift. Cinematic, contemplative.
```

### Scene 3d — Lunar Cycle Arc (8 seconds)

**Input image:** `scene_lunar_cycle.png`
```
The arc of Moon phases glows softly against the night sky. Each Moon phase subtly pulses with light. The silhouetted human figure stands still in contemplation. The Milky Way shimmers behind the arc. Slow, meditative camera movement, very slight push in. Night desert landscape, serene and timeless.
```

### Scene 4 — Archetype Wheel (12 seconds)

**Input image:** `scene_archetypes_wheel.png`
```
The twelve-segment wheel slowly rotates clockwise in space. Each segment pulses gently with its own color — warm golds, cool blues, deep purples. The cosmic spiral at the center slowly swirls. The Moon in the background drifts. Mystical, elegant, premium. Slow rotation, cinematic depth of field.
```

### Scene 7 — Banner Closing (8 seconds)

**Input image:** `banner.png`
```
Slow, elegant zoom-out revealing the full banner. The moon-clock glows with a subtle warm pulse. Star particles drift gently in the dark background. Cinematic, peaceful, closing feel. Premium and refined.
```

---

## App Screenshot Handling

For the app screenshots (`app_moon_screen.png`, `app_solar_screen.png`, `app_seconds_screen.png`), **don't use video generation**. Instead:

1. In CapCut/DaVinci, place the screenshot on the timeline
2. Apply a slow Ken Burns effect (gentle zoom-in or pan)
3. Optionally place inside a phone mockup frame
4. Add a subtle glow or shadow around the phone
5. This gives you clean, crisp app footage without wasting video gen credits

Same approach for the hypothesis web page screenshots — slow pan/scroll effects in the editor.

---

## Validation Prompt

Use this prompt with **Gemini 2.5 Pro** (which accepts video uploads) after generating and assembling the final video. Upload the video file along with this prompt:

```
You are a video production quality assurance reviewer. I am uploading a completed YouTube video along with the original production script below. Your job is to validate the video follows the script accurately.

Please review the video and provide a detailed report covering:

## SCENE-BY-SCENE VALIDATION

For each scene (1 through 8), evaluate:

1. **Timing**: Does the scene start and end approximately at the scripted timestamps?
2. **Visual Content**: Does the visual match the described imagery? Rate accuracy (1-5):
   - Scene 1 (0:00-0:08): Should show "The Time App" banner with moon-clock, fade from black
   - Scene 2 (0:08-0:28): Should show Earth from space with day/night terminator
   - Scene 3 (0:28-0:55): Should show Sun close-up, then new moon gravitational alignment, then full moon, then lunar cycle arc with human silhouette
   - Scene 4 (0:55-1:20): Should show hypothesis document header, then twelve-segment archetype wheel rotating, then archetype section from website
   - Scene 5 (1:20-1:45): Should show app Moon Time screen, Emotional Weather web section, Solar Time screen, Synchronized Time Machine section
   - Scene 6 (1:45-2:10): Should show lunar cycle arc, app screens, hypothesis document TOC and conclusion
   - Scene 7 (2:10-2:20): Should return to banner with zoom-out
   - Scene 8 (2:20-2:30): Should be solid black (end screen space)

3. **Narration**: Does the voiceover match the scripted text? Flag any deviations.
4. **Text Overlays**: Are the specified text overlays present at the correct moments?
   - "THE HYPOTHESIS: Change has structure..." at ~0:45
   - Archetype sequence (SPARK → ANALYST → ...) at ~1:05
   - "Observe → Understand → Predict → Leverage" at ~2:00
   - "Available on Android · thetimeapp.co.za" at ~2:10

## QUALITY CHECKS

5. **Transitions**: Are dissolve transitions used between scenes (approximately 2 seconds)?
6. **Music**: Is ambient/cosmic music present? Does it build and resolve appropriately?
7. **Pacing**: Is the narration pace comfortable — neither rushed nor too slow?
8. **Visual Consistency**: Is the color palette consistent (deep navy/black, warm gold accents)?
9. **End Screen**: Is there a 10-second black screen at the end for YouTube end cards?

## OVERALL ASSESSMENT

10. **Professional Quality**: Rate overall production quality (1-10)
11. **Issues Found**: List any problems, inconsistencies, or deviations from the script
12. **Recommendations**: Suggest specific improvements

## SCRIPT FOR REFERENCE

Scene 1 narration: "The Time App… because Time is of the Essence."
Scene 2 narration: "We measure time constantly. Clocks, calendars, deadlines. But here's a question most of us never ask: Are we actually synchronized with time… or just counting it?"
Scene 3 narration: "The Sun drives our daily rhythm — light, dark, sleep, waking. That's well-established science. But every twenty-nine and a half days, something else cycles. The Moon passes through its phases — new moon, full moon — and with it, the gravitational geometry between the Sun, Earth, and Moon shifts continuously. What if those cycles affect us more than we realize?"
Scene 4 narration: "This is what 12TRA proposes — the Twelve Temporal Resonance Architecture. It divides the lunar cycle into twelve temporal phases — not personality types, but recurring contexts of change. Initiation, examination, connection, vision, listening, expression, construction, integration, strategy, evaluation, harmony, and renewal. Twelve functions. One cycle. Repeating every moon."
Scene 5 narration: "12TRA doesn't predict your mood or tell you what to do. It offers context. Think of it as emotional weather — a probability of rain doesn't make you wet. But knowing the forecast helps you prepare. The app tracks where you are — in the solar day, in the lunar cycle — and shows which archetype is active. Over time, you begin to see patterns. Your patterns."
Scene 6 narration: "Imagine being able to see where you are within a cycle of change — not just what day it is, but what kind of day it is. Imagine timing your decisions, your creative work, your difficult conversations — not by the clock, but by the current. Further research will deepen our understanding. But the possibility is profound: change itself may have an architecture, and we can learn to work with it."
Scene 7 narration: "The Time App. Synchronize with the architecture of change."
Scene 8: No narration. Black screen for YouTube end cards.
```

---

## Summary: The $0 Path

If budget is the primary concern, here's the simplest route:

1. **ElevenLabs free** — Generate all narration (~1,800 characters, well within 10,000 limit)
2. **Kling AI free** — Generate 3-5 clips/day over 3 days (~15 clips total needed, some scenes reuse assets)
3. **CapCut free** — Assemble everything, add Ken Burns to static screenshots, add text overlays and music
4. **YouTube Audio Library** — Free ambient music
5. **Gemini 2.5 Pro** — Validate the final cut (upload video + validation prompt above)

> [!IMPORTANT]
> The free-tier trade-off: watermarks on Kling clips + 720p max + no commercial rights on ElevenLabs audio. For a clean YouTube video, **Kling Standard ($8.80/mo) + ElevenLabs Starter ($5/mo) = $13.80** gets you watermark-free 1080p with commercial narration rights.
