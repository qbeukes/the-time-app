# Plan 01 — Introduce Settings, About & Reworked Navigation

## Context

This is a Flutter app called **The Time App** — a time and temporal resonance tool built on the **12 Temporal Resonance Architecture (12TRA)**. The main entry point is `lib/main.dart` (~1333 lines), which contains `_MainNavigationScreenState` — the root state manager for the app.

The app has three tabs (Lunar, Solar, Seconds) managed via a `NavigationBar` at the bottom. The AppBar currently has:
- A **live/play button** on the left (shown conditionally when date is not live)
- A centered **tab title**
- On the right: a **calendar icon** (hidden on Seconds tab) and a **burger icon** that opens a per-screen options bottom sheet

The per-screen options sheets are:
- **Moon options** (`_MoonMenuSheet`): toggles for TRA layer, Luach layer, Luach/TRA overlap, Local Tilt, and Lunar Anchors
- **Sun options** (`_SunMenuSheet`): toggles for Gregorian, Enochian, Julian
- **Seconds / Timer Profiles** (`_SecondsMenuSheet`): profile list management + profile-scoped Reset button

All app state is persisted via `shared_preferences`. The app already has `shared_preferences`, `geolocator`, `audioplayers`, `wakelock_plus`, and `device_preview` as dependencies. It does **not** have `package_info_plus` or `url_launcher`.

---

## Task

Implement the following changes to introduce a global **Settings** screen, an **About** screen, and a reworked **AppBar navigation** pattern.

---

## UI Layout Change (AppBar)

### Current
```
[ ▶ (live) ]   Lunar Time   [ 📅 calendar ] [ ☰ options ]
```

### New
```
[ ▶ (live) ]   Lunar Time   [ 📅 calendar* ] [ ☰ menu ]
```

`*` The calendar icon is **always shown** on all tabs. On the **Seconds tab** it is greyed out and `onPressed` is `null` (disabled), since date navigation doesn't apply there.

> The live/play button on the left remains exactly as it is — shown conditionally when the user has navigated away from live time.

---

## Feature: Burger Menu (Global Navigation Sheet)

The burger icon (`Icons.menu_rounded`) opens a **modal bottom sheet** with three ordered entries:

```
┌──────────────────────────────────────────┐
│         ──── drag handle ────            │
│                                          │
│  Configure Screen                    →   │
│  Settings                            →   │
│  About                               →   │
│                                          │
└──────────────────────────────────────────┘
```

**Entry 1 — Configure Screen:**
- The label updates dynamically based on the active tab:
  - Lunar tab → "Configure Lunar"
  - Solar tab → "Configure Solar"
  - Seconds tab → "Configure Timer"
- Tapping dismisses the bottom sheet, then opens the existing per-screen options bottom sheet for the current tab
- The existing `_openBurgerMenu(ctx)` method is renamed to `_openScreenConfigSheet(ctx)` (internal rename only, behaviour unchanged)

**Entry 2 — Settings:**
- Tapping pushes `SettingsScreen` via `Navigator.push`

**Entry 3 — About:**
- Tapping pushes `AboutScreen` via `Navigator.push`

---

## Feature: About Screen (`lib/screens/about_screen.dart`)

A full-screen `Scaffold` page pushed via `Navigator.push` from the burger menu.

| Section | Content |
|---|---|
| App name / branding | "The Time App" |
| Version | Read dynamically via `package_info_plus` |
| Website | Tappable link → `https://time.veryeasy.co.za` |
| Copyright | Tappable link → `https://time.veryeasy.co.za/copyright` |
| Privacy Policy | Tappable link → `https://time.veryeasy.co.za/privacy.html` |
| Hypothesis of Time & Change | 1-paragraph summary + tappable link → `https://time.veryeasy.co.za/hypothesis.html` |

**Hypothesis paragraph to use:**
> *The Hypothesis of Change proposes that Time has an underlying architecture — a twelve-segment cycle called the 12 Temporal Resonance Architecture (12TRA) — derived from anthropological and astronomical patterns observed across history. Each segment carries distinct qualities of Change that repeat with each cycle, offering a framework for navigating life with greater awareness of the temporal forces shaping each moment.*

All links open in an external browser using `url_launcher` (`launchUrl`).

---

## Feature: Settings Screen (`lib/screens/settings_screen.dart`)

A full-screen `Scaffold` page pushed via `Navigator.push` from the burger menu.

### Section: Developer Features

| Field | Detail |
|---|---|
| Label | Enable Developer Features |
| Subtitle | Unlocks advanced display options across all screens |
| Widget | `Switch` |
| SharedPreferences key | `developerFeaturesEnabled` (bool, default `false`) |
| Effect | When enabled, the "Show Lunar Anchors" toggle becomes visible in the Moon options sheet |

### Section: App Data

| Field | Detail |
|---|---|
| Label | Reset to Defaults |
| Subtitle | Removes all customizations and restores all settings and timer profiles to their defaults |
| Style | Destructive — red accent |
| Action | Shows a confirmation dialog; on confirm, calls `_resetAllToDefaults()` callback passed from parent |

---

## Lunar Anchors Gating (Developer Feature)

The "Show Lunar Anchors" toggle row in `_MoonMenuSheet` is currently always visible. After this change:

- `developerFeaturesEnabled == false` → the toggle row is **hidden**; `_moonShowLunarAnchor` is coerced to `false`
- `developerFeaturesEnabled == true` → the toggle row is **visible**; saved preference is respected

**On-load coercion:** In `_loadPrefs()`, after reading all preferences, if `developerFeaturesEnabled` is `false`, force `_moonShowLunarAnchor = false`. This prevents lunar anchors from remaining visible if the user disables developer features between sessions.

`_MoonMenuSheet` must receive `developerFeaturesEnabled` as a new required parameter to conditionally render the Lunar Anchors row.

---

## Seconds Sheet: Profile Reset (Unchanged)

The **Reset** button in `_SecondsMenuSheet` resets timer profiles only. It is **kept as-is** — it is scoped and distinct from the global Reset to Defaults in Settings.

---

## Global Reset to Defaults

Add a `_resetAllToDefaults()` method to `_MainNavigationScreenState`:

```dart
Future<void> _resetAllToDefaults() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  setState(() {
    _moonShowTra = true;
    _moonShowLuach = true;
    _moonShowLuachTraOverlap = true;
    _moonShowLunarAnchor = false;
    _moonUseLocalTilt = true;
    _sunShowGregorian = true;
    _sunShowEnochian = true;
    _sunShowJulian = true;
    _sunShowLocalTime = true;
    _profiles = TimerProfile.defaults;
    _activeProfileIndex = 1;
    _developerFeaturesEnabled = false;
    _currentIndex = 0;
  });
}
```

This is passed as a `VoidCallback` to `SettingsScreen`.

---

## State Management

Add to `_MainNavigationScreenState`:

```dart
bool _developerFeaturesEnabled = false;
```

- **Load** in `_loadPrefs()`: `_developerFeaturesEnabled = prefs.getBool('developerFeaturesEnabled') ?? false;`
- **Save** in `_savePrefs()`: `await prefs.setBool('developerFeaturesEnabled', _developerFeaturesEnabled);`
- **Reset** in `_resetAllToDefaults()`: set to `false`
- **Pass** to `SettingsScreen` as a value+callback pair; changes made in `SettingsScreen` call back to update state and save prefs

---

## Files to Create

| File | Purpose |
|---|---|
| `lib/screens/about_screen.dart` | About full-screen page |
| `lib/screens/settings_screen.dart` | Settings full-screen page |

## Files to Modify

| File | Changes |
|---|---|
| `lib/main.dart` | Rework AppBar actions; add global burger menu sheet; rename `_openBurgerMenu` → `_openScreenConfigSheet`; add `_developerFeaturesEnabled` state + load/save/reset; add `developerFeaturesEnabled` param to `_MoonMenuSheet`; lunar anchor gating |
| `pubspec.yaml` | Add `package_info_plus` and `url_launcher` |

## New Dependencies

```yaml
package_info_plus: ^8.3.0   # app version in About screen
url_launcher: ^6.3.1         # web links in About screen
```

---

## Verification Checklist

- [ ] Burger menu opens a bottom sheet with 3 entries: Configure Screen / Settings / About
- [ ] "Configure Screen" label is dynamic per active tab
- [ ] "Configure Screen" opens the correct per-screen options sheet
- [ ] Calendar icon always visible; greyed out and disabled on the Seconds tab
- [ ] Live/play button on AppBar left still functions correctly
- [ ] About screen renders all sections with correct content and working links
- [ ] Settings screen toggle for `developerFeaturesEnabled` is persisted across restarts
- [ ] "Show Lunar Anchors" toggle hidden in Moon options when developer features disabled
- [ ] "Show Lunar Anchors" toggle visible in Moon options when developer features enabled
- [ ] Disabling developer features coerces `_moonShowLunarAnchor` to `false` immediately
- [ ] Reset to Defaults shows a confirmation dialog before acting
- [ ] Reset to Defaults resets all prefs, profiles, and `developerFeaturesEnabled` to defaults
- [ ] Seconds sheet "Reset" button still works (profile-scoped reset, unchanged)
