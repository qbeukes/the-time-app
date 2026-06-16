import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:geolocator/geolocator.dart';
import 'package:inner_time/screens/moon_screen.dart';
import 'package:inner_time/screens/sun_screen.dart';

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
  bool _moonShowSeconds = false;
  bool _moonUseLocalTilt = true;

  // ── Sun toggles ───────────────────────────────────────────────
  bool _sunShowSeconds = false;

  @override
  void initState() {
    super.initState();
    _globalMomentNotifier = ValueNotifier<DateTime>(DateTime.now());
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
    } catch (e) {
      // Ignore location errors gracefully
    }
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
    if (picked != null) {
      _globalMomentNotifier.value = picked;
    }
  }

  void _handleHorizontalDragUpdate(DragUpdateDetails details) {
    if (details.primaryDelta != null) {
      final double deltaDays = -details.primaryDelta! / 10.0;
      final int deltaMs = (deltaDays * 24 * 60 * 60 * 1000).round();
      final newTime =
          _globalMomentNotifier.value.add(Duration(milliseconds: deltaMs));
      _globalMomentNotifier.value = newTime;
    }
  }

  // ── Burger menu content ───────────────────────────────────────
  void _showMenuForMoon(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: const Color(0xFF12121E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _MoonMenuSheet(
        showTra: _moonShowTra,
        showLuach: _moonShowLuach,
        showSeconds: _moonShowSeconds,
        useLocalTilt: _moonUseLocalTilt,
        hasLocation: _latitude != null && _longitude != null,
        onChanged: (tra, luach, seconds, tilt) {
          setState(() {
            _moonShowTra = tra;
            _moonShowLuach = luach;
            _moonShowSeconds = seconds;
            _moonUseLocalTilt = tilt;
          });
        },
      ),
    );
  }

  void _showMenuForSun(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: const Color(0xFF12121E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _SunMenuSheet(
        showSeconds: _sunShowSeconds,
        onChanged: (seconds) {
          setState(() {
            _sunShowSeconds = seconds;
          });
        },
      ),
    );
  }

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
            showSeconds: _moonShowSeconds,
            useLocalTilt: _moonUseLocalTilt,
          ),
          SunScreen(
            date: globalDate,
            showSeconds: _sunShowSeconds,
          ),
        ];

        return Scaffold(
          appBar: AppBar(
            title: Text(_currentIndex == 0 ? 'Moon Time' : 'Solar Time'),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              // Calendar picker
              IconButton(
                icon: const Icon(Icons.calendar_month),
                onPressed: _pickDate,
              ),
              // Section options burger menu
              Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.menu_rounded),
                  tooltip: 'Section options',
                  onPressed: () {
                    if (_currentIndex == 0) {
                      _showMenuForMoon(ctx);
                    } else {
                      _showMenuForSun(ctx);
                    }
                  },
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
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.nightlight_round),
                label: 'Moon',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.wb_sunny),
                label: 'Sun',
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Moon options bottom sheet
// ─────────────────────────────────────────────────────────────
class _MoonMenuSheet extends StatefulWidget {
  final bool showTra;
  final bool showLuach;
  final bool showSeconds;
  final bool useLocalTilt;
  final bool hasLocation;
  final void Function(bool tra, bool luach, bool seconds, bool tilt) onChanged;

  const _MoonMenuSheet({
    required this.showTra,
    required this.showLuach,
    required this.showSeconds,
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
  late bool _seconds;
  late bool _tilt;

  @override
  void initState() {
    super.initState();
    _tra = widget.showTra;
    _luach = widget.showLuach;
    _seconds = widget.showSeconds;
    _tilt = widget.useLocalTilt;
  }

  void _emit() => widget.onChanged(_tra, _luach, _seconds, _tilt);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '🌙  MOON OPTIONS',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),
            _ToggleRow(
              label: '12TRA Layer',
              subtitle: 'Lunar resonance archetypes',
              icon: '✦',
              iconColor: Colors.deepPurpleAccent,
              value: _tra,
              onChanged: (v) {
                setState(() => _tra = v);
                _emit();
              },
            ),
            _ToggleRow(
              label: 'Luach Layer',
              subtitle: 'Hebrew lunar calendar',
              icon: '🌙',
              iconColor: Colors.tealAccent,
              value: _luach,
              onChanged: (v) {
                setState(() => _luach = v);
                _emit();
              },
            ),
            _ToggleRow(
              label: 'Seconds',
              subtitle: 'Meditation timer',
              icon: '⏳',
              iconColor: Colors.indigoAccent,
              value: _seconds,
              onChanged: (v) {
                setState(() => _seconds = v);
                _emit();
              },
            ),
            if (widget.hasLocation)
              _ToggleRow(
                label: 'Local Tilt',
                subtitle: 'Adjust moon tilt for your location',
                icon: '📍',
                iconColor: Colors.amberAccent,
                value: _tilt,
                onChanged: (v) {
                  setState(() => _tilt = v);
                  _emit();
                },
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Sun options bottom sheet
// ─────────────────────────────────────────────────────────────
class _SunMenuSheet extends StatefulWidget {
  final bool showSeconds;
  final void Function(bool seconds) onChanged;

  const _SunMenuSheet({
    required this.showSeconds,
    required this.onChanged,
  });

  @override
  State<_SunMenuSheet> createState() => _SunMenuSheetState();
}

class _SunMenuSheetState extends State<_SunMenuSheet> {
  late bool _seconds;

  @override
  void initState() {
    super.initState();
    _seconds = widget.showSeconds;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '☀️  SUN OPTIONS',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),
            _ToggleRow(
              label: 'Seconds',
              subtitle: 'Meditation timer',
              icon: '⏳',
              iconColor: Colors.indigoAccent,
              value: _seconds,
              onChanged: (v) {
                setState(() => _seconds = v);
                widget.onChanged(_seconds);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Shared toggle row widget
// ─────────────────────────────────────────────────────────────
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
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: Colors.white38),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: iconColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
