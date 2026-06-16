import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:geolocator/geolocator.dart';
import 'package:inner_time/screens/moon_screen.dart';
import 'package:inner_time/screens/sun_screen.dart';
import 'package:inner_time/screens/seconds_screen.dart';
import 'package:inner_time/models/timer_profile.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => const InnerTimeApp(),
    ),
  );
}

class InnerTimeApp extends StatelessWidget {
  const InnerTimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      title: 'Inner Time',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  late final ValueNotifier<DateTime> _globalMomentNotifier;
  double? _latitude;
  double? _longitude;

  // ── Moon toggles ──────────────────────────────────────────────
  bool _moonShowTra = true;
  bool _moonShowLuach = true;
  bool _moonUseLocalTilt = true;

  // ── Seconds / profiles ────────────────────────────────────────
  late List<TimerProfile> _profiles;
  int _activeProfileIndex = 0;

  @override
  void initState() {
    super.initState();
    _globalMomentNotifier = ValueNotifier<DateTime>(DateTime.now());
    _profiles = TimerProfile.defaults;
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _globalMomentNotifier.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _globalMomentNotifier.value,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) _globalMomentNotifier.value = picked;
  }

  void _handleHorizontalDragUpdate(DragUpdateDetails details) {
    // Only swipe on Moon / Sun tabs (not Seconds)
    if (_currentIndex == 2) return;
    if (details.primaryDelta != null) {
      final int deltaMs =
          (-details.primaryDelta! / 10.0 * 24 * 60 * 60 * 1000).round();
      _globalMomentNotifier.value =
          _globalMomentNotifier.value.add(Duration(milliseconds: deltaMs));
    }
  }

  // ── Burger menus ──────────────────────────────────────────────

  void _openBurgerMenu(BuildContext ctx) {
    switch (_currentIndex) {
      case 0:
        _showMoonMenu(ctx);
        break;
      case 1:
        // Sun has no current toggles — nothing to show
        break;
      case 2:
        _showSecondsMenu(ctx);
        break;
    }
  }

  void _showMoonMenu(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: const Color(0xFF12121E),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _MoonMenuSheet(
        showTra: _moonShowTra,
        showLuach: _moonShowLuach,
        useLocalTilt: _moonUseLocalTilt,
        hasLocation: _latitude != null && _longitude != null,
        onChanged: (tra, luach, tilt) {
          setState(() {
            _moonShowTra = tra;
            _moonShowLuach = luach;
            _moonUseLocalTilt = tilt;
          });
        },
      ),
    );
  }

  void _showSecondsMenu(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: const Color(0xFF12121E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _SecondsMenuSheet(
        profiles: _profiles,
        activeIndex: _activeProfileIndex,
        onSelectProfile: (i) {
          setState(() => _activeProfileIndex = i);
        },
        onAddProfile: (p) {
          setState(() => _profiles = [..._profiles, p]);
        },
        onUpdateProfile: (i, p) {
          setState(() {
            _profiles = List.from(_profiles)..[i] = p;
          });
        },
        onDeleteProfile: (i) {
          setState(() {
            _profiles = List.from(_profiles)..removeAt(i);
            if (_activeProfileIndex >= _profiles.length) {
              _activeProfileIndex = _profiles.length - 1;
            }
          });
        },
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DateTime>(
      valueListenable: _globalMomentNotifier,
      builder: (context, globalDate, _) {
        final List<Widget> screens = [
          MoonScreen(
            date: globalDate,
            latitude: _latitude,
            longitude: _longitude,
            showTra: _moonShowTra,
            showLuach: _moonShowLuach,
            useLocalTilt: _moonUseLocalTilt,
          ),
          SunScreen(date: globalDate),
          SecondsScreen(
            profiles: _profiles,
            activeProfileIndex: _activeProfileIndex,
            onProfileChanged: (i) => setState(() => _activeProfileIndex = i),
          ),
        ];

        // Hide burger on Sun (no toggles yet)
        final showBurger = _currentIndex != 1;

        return Scaffold(
          appBar: AppBar(
            title: Text(
                ['Moon Time', 'Solar Time', 'Seconds'][_currentIndex]),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              if (_currentIndex != 2)
                IconButton(
                  icon: const Icon(Icons.calendar_month),
                  onPressed: _pickDate,
                ),
              if (showBurger)
                Builder(
                  builder: (ctx) => IconButton(
                    icon: const Icon(Icons.menu_rounded),
                    tooltip: 'Options',
                    onPressed: () => _openBurgerMenu(ctx),
                  ),
                ),
            ],
          ),
          body: GestureDetector(
            onHorizontalDragUpdate: _handleHorizontalDragUpdate,
            behavior: HitTestBehavior.opaque,
            child: IndexedStack(
              index: _currentIndex,
              children: screens,
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.nightlight_round), label: 'Moon'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.wb_sunny), label: 'Sun'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.hourglass_bottom_rounded),
                  label: 'Seconds'),
            ],
          ),
        );
      },
    );
  }
}

// ═════════════════════════════════════════════════════════════
// Moon options bottom sheet
// ═════════════════════════════════════════════════════════════

class _MoonMenuSheet extends StatefulWidget {
  final bool showTra;
  final bool showLuach;
  final bool useLocalTilt;
  final bool hasLocation;
  final void Function(bool tra, bool luach, bool tilt) onChanged;

  const _MoonMenuSheet({
    required this.showTra,
    required this.showLuach,
    required this.useLocalTilt,
    required this.hasLocation,
    required this.onChanged,
  });

  @override
  State<_MoonMenuSheet> createState() => _MoonMenuSheetState();
}

class _MoonMenuSheetState extends State<_MoonMenuSheet> {
  late bool _tra;
  late bool _luach;
  late bool _tilt;

  @override
  void initState() {
    super.initState();
    _tra = widget.showTra;
    _luach = widget.showLuach;
    _tilt = widget.useLocalTilt;
  }

  void _emit() => widget.onChanged(_tra, _luach, _tilt);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _sheetHandle(),
            const SizedBox(height: 20),
            const Text('🌙  MOON OPTIONS', style: _sheetTitleStyle),
            const SizedBox(height: 16),
            _ToggleRow(
              label: '12TRA Layer',
              subtitle: 'Lunar resonance archetypes',
              icon: '✦',
              iconColor: Colors.deepPurpleAccent,
              value: _tra,
              onChanged: (v) { setState(() => _tra = v); _emit(); },
            ),
            _ToggleRow(
              label: 'Luach Layer',
              subtitle: 'Hebrew lunar calendar',
              icon: '🌙',
              iconColor: Colors.tealAccent,
              value: _luach,
              onChanged: (v) { setState(() => _luach = v); _emit(); },
            ),
            if (widget.hasLocation)
              _ToggleRow(
                label: 'Local Tilt',
                subtitle: 'Adjust moon tilt for your location',
                icon: '📍',
                iconColor: Colors.amberAccent,
                value: _tilt,
                onChanged: (v) { setState(() => _tilt = v); _emit(); },
              ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// Seconds / profile manager bottom sheet
// ═════════════════════════════════════════════════════════════

class _SecondsMenuSheet extends StatefulWidget {
  final List<TimerProfile> profiles;
  final int activeIndex;
  final ValueChanged<int> onSelectProfile;
  final ValueChanged<TimerProfile> onAddProfile;
  final void Function(int index, TimerProfile profile) onUpdateProfile;
  final ValueChanged<int> onDeleteProfile;

  const _SecondsMenuSheet({
    required this.profiles,
    required this.activeIndex,
    required this.onSelectProfile,
    required this.onAddProfile,
    required this.onUpdateProfile,
    required this.onDeleteProfile,
  });

  @override
  State<_SecondsMenuSheet> createState() => _SecondsMenuSheetState();
}

class _SecondsMenuSheetState extends State<_SecondsMenuSheet> {
  late List<TimerProfile> _profiles;
  late int _activeIndex;

  @override
  void initState() {
    super.initState();
    _profiles = List.from(widget.profiles);
    _activeIndex = widget.activeIndex;
  }

  void _openEditor({TimerProfile? existing, int? index}) async {
    final result = await showDialog<TimerProfile>(
      context: context,
      builder: (_) => _ProfileEditorDialog(profile: existing),
    );
    if (result == null) return;
    if (index != null) {
      widget.onUpdateProfile(index, result);
      setState(() => _profiles[index] = result);
    } else {
      widget.onAddProfile(result);
      setState(() => _profiles.add(result));
    }
  }

  void _delete(int i) {
    if (_profiles.length <= 1) return; // keep at least one
    widget.onDeleteProfile(i);
    setState(() {
      _profiles.removeAt(i);
      if (_activeIndex >= _profiles.length) {
        _activeIndex = _profiles.length - 1;
        widget.onSelectProfile(_activeIndex);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _sheetHandle(),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('⏳  TIMER PROFILES', style: _sheetTitleStyle),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _openEditor(),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('New'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.deepPurpleAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Profile list
            ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _profiles.length,
                itemBuilder: (ctx, i) {
                  final p = _profiles[i];
                  final isActive = i == _activeIndex;
                  return _ProfileListTile(
                    profile: p,
                    isActive: isActive,
                    onSelect: () {
                      setState(() => _activeIndex = i);
                      widget.onSelectProfile(i);
                    },
                    onEdit: () => _openEditor(existing: p, index: i),
                    onDelete:
                        _profiles.length > 1 ? () => _delete(i) : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Profile list tile
// ─────────────────────────────────────────────────────────────

class _ProfileListTile extends StatelessWidget {
  final TimerProfile profile;
  final bool isActive;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  const _ProfileListTile({
    required this.profile,
    required this.isActive,
    required this.onSelect,
    required this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isActive
              ? Colors.deepPurpleAccent.withOpacity(0.12)
              : Colors.white.withOpacity(0.04),
          border: Border.all(
            color: isActive
                ? Colors.deepPurpleAccent.withOpacity(0.5)
                : Colors.white.withOpacity(0.07),
          ),
        ),
        child: Row(
          children: [
            // Active indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive
                    ? Colors.deepPurpleAccent
                    : Colors.white24,
              ),
            ),
            const SizedBox(width: 12),
            // Name & info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? Colors.white
                          : Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${profile.durationLabel}  •  '
                    '${profile.bellAtSeconds.length} bell'
                    '${profile.bellAtSeconds.length != 1 ? 's' : ''}',
                    style: const TextStyle(
                        fontSize: 11, color: Colors.white38),
                  ),
                ],
              ),
            ),
            // Edit button
            IconButton(
              icon: const Icon(Icons.edit_rounded,
                  size: 18, color: Colors.white38),
              onPressed: onEdit,
              tooltip: 'Edit profile',
            ),
            // Delete button
            if (onDelete != null)
              IconButton(
                icon: Icon(Icons.delete_outline_rounded,
                    size: 18,
                    color: Colors.redAccent.withOpacity(0.6)),
                onPressed: onDelete,
                tooltip: 'Delete profile',
              ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// Profile editor dialog
// ═════════════════════════════════════════════════════════════

class _ProfileEditorDialog extends StatefulWidget {
  final TimerProfile? profile;
  const _ProfileEditorDialog({this.profile});

  @override
  State<_ProfileEditorDialog> createState() => _ProfileEditorDialogState();
}

class _ProfileEditorDialogState extends State<_ProfileEditorDialog> {
  late TextEditingController _nameCtrl;
  late TextEditingController _minCtrl;
  late TextEditingController _secCtrl;
  late List<int> _bells; // mutable list of bell times

  // Bell adder
  final TextEditingController _bellMinCtrl = TextEditingController();
  final TextEditingController _bellSecCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    final dur = p?.durationSeconds ?? 300;
    _minCtrl = TextEditingController(text: '${dur ~/ 60}');
    _secCtrl = TextEditingController(text: '${dur % 60}');
    _bells = p != null ? List<int>.from(p.bellAtSeconds) : [0, dur];
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _minCtrl.dispose();
    _secCtrl.dispose();
    _bellMinCtrl.dispose();
    _bellSecCtrl.dispose();
    super.dispose();
  }

  int get _durationSecs {
    final m = int.tryParse(_minCtrl.text) ?? 5;
    final s = int.tryParse(_secCtrl.text) ?? 0;
    return (m * 60 + s).clamp(1, 99 * 60);
  }

  String _fmt(int secs) {
    return '${(secs ~/ 60).toString().padLeft(2, '0')}:'
        '${(secs % 60).toString().padLeft(2, '0')}';
  }

  void _addBell() {
    final m = int.tryParse(_bellMinCtrl.text) ?? 0;
    final s = int.tryParse(_bellSecCtrl.text) ?? 0;
    final t = m * 60 + s;
    if (t < 0) return;
    setState(() {
      if (!_bells.contains(t)) {
        _bells.add(t);
        _bells.sort();
      }
      _bellMinCtrl.clear();
      _bellSecCtrl.clear();
    });
  }

  void _removeBell(int t) {
    setState(() => _bells.remove(t));
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    final p = TimerProfile(
      id: widget.profile?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      durationSeconds: _durationSecs,
      bellAtSeconds: _bells,
    );
    Navigator.pop(context, p);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF12121E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              widget.profile == null ? 'New Profile' : 'Edit Profile',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            // Name
            const _Label('NAME'),
            const SizedBox(height: 6),
            TextField(
              controller: _nameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecor('e.g. Morning Sit'),
            ),
            const SizedBox(height: 20),

            // Duration
            const _Label('DURATION'),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minCtrl,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecor('min'),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(':',
                      style: TextStyle(
                          fontSize: 20, color: Colors.white54)),
                ),
                Expanded(
                  child: TextField(
                    controller: _secCtrl,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecor('sec'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Bell times
            Row(
              children: [
                const _Label('BELL TIMES'),
                const Spacer(),
                Text(
                  '(seconds from start)',
                  style: TextStyle(
                      fontSize: 9,
                      color: Colors.white.withOpacity(0.25)),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Existing bells
            if (_bells.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: _bells.map((b) {
                  return Chip(
                    backgroundColor:
                        Colors.deepPurpleAccent.withOpacity(0.15),
                    side: BorderSide(
                        color: Colors.deepPurpleAccent.withOpacity(0.4)),
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🔔 ',
                            style: TextStyle(fontSize: 12)),
                        Text(_fmt(b),
                            style: const TextStyle(
                                fontSize: 12,
                                color: Colors.deepPurpleAccent)),
                      ],
                    ),
                    deleteIcon: const Icon(Icons.close_rounded,
                        size: 14, color: Colors.white38),
                    onDeleted: () => _removeBell(b),
                  );
                }).toList(),
              ),
            const SizedBox(height: 10),

            // Add bell row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _bellMinCtrl,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 14),
                    decoration: _inputDecor('min'),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Text(':',
                      style: TextStyle(
                          fontSize: 18, color: Colors.white38)),
                ),
                Expanded(
                  child: TextField(
                    controller: _bellSecCtrl,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 14),
                    decoration: _inputDecor('sec'),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addBell,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.deepPurpleAccent.withOpacity(0.25),
                    foregroundColor: Colors.deepPurpleAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                  ),
                  child: const Icon(Icons.add_rounded, size: 20),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.white38)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecor(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.06),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.12))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.12))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: Colors.deepPurpleAccent)),
      );
}

// ═════════════════════════════════════════════════════════════
// Shared helpers
// ═════════════════════════════════════════════════════════════

Widget _sheetHandle() => Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(2)),
      ),
    );

const _sheetTitleStyle = TextStyle(
  fontSize: 13,
  fontWeight: FontWeight.bold,
  letterSpacing: 2,
  color: Colors.white70,
);

class _ToggleRow extends StatelessWidget {
  final String label;
  final String subtitle;
  final String icon;
  final Color iconColor;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withOpacity(0.12),
              border: Border.all(color: iconColor.withOpacity(0.25)),
            ),
            child:
                Center(child: Text(icon, style: const TextStyle(fontSize: 16))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 11, color: Colors.white38)),
              ],
            ),
          ),
          Switch(value: value, activeColor: iconColor, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: Colors.white38),
      );
}
