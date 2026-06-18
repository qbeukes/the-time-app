import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../models/timer_profile.dart';

class SecondsScreen extends StatefulWidget {
  final List<TimerProfile> profiles;
  final int activeProfileIndex;
  final ValueChanged<int> onProfileChanged;

  const SecondsScreen({
    super.key,
    required this.profiles,
    required this.activeProfileIndex,
    required this.onProfileChanged,
  });

  @override
  State<SecondsScreen> createState() => _SecondsScreenState();
}

class _SecondsScreenState extends State<SecondsScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  int _elapsedSeconds = 0;
  bool _isRunning = false;
  bool _isPaused = false;
  Timer? _tickTimer;
  final Set<int> _firedBells = {};

  // Wall-clock tracking variables
  DateTime? _timerStartDateTime;
  int _elapsedAtStart = 0;

  // Lock overlay state
  OverlayEntry? _lockOverlayEntry;
  final ValueNotifier<int> _remainingNotifier = ValueNotifier<int>(0);
  final ValueNotifier<bool> _isLockedNotifier = ValueNotifier<bool>(false);

  // Bell cycling: bell1 → bell2 → bell3 → bell1 → …
  int _bellCount = 0;
  static const List<String> _bellAssets = [
    'sounds/bell1.wav',
    'sounds/bell2.wav',
    'sounds/bell3.wav',
  ];
  final AudioPlayer _audioPlayer = AudioPlayer();

  late AnimationController _pulseCtrl;
  late AnimationController _breathCtrl;
  late AnimationController _bellFlashCtrl;
  late Animation<double> _pulseAnim;
  late Animation<double> _breathAnim;
  late Animation<double> _bellFlashAnim;

  TimerProfile get _profile => widget.profiles[widget.activeProfileIndex];

  int get _remaining =>
      (_profile.durationSeconds - _elapsedSeconds).clamp(0, _profile.durationSeconds);

  double get _progress => _profile.durationSeconds > 0
      ? (_elapsedSeconds / _profile.durationSeconds).clamp(0.0, 1.0)
      : 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.97, end: 1.03).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _breathCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 4))
      ..repeat(reverse: true);
    _breathAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _breathCtrl, curve: Curves.easeInOut));

    _bellFlashCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _bellFlashAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _bellFlashCtrl, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(SecondsScreen old) {
    super.didUpdateWidget(old);
    if (old.activeProfileIndex != widget.activeProfileIndex ||
        old.profiles[old.activeProfileIndex].id !=
            widget.profiles[widget.activeProfileIndex].id) {
      _reset();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_isRunning && _timerStartDateTime != null) {
        final diff = DateTime.now().difference(_timerStartDateTime!).inSeconds;
        final newElapsed = _elapsedAtStart + diff;

        bool missedBell = false;
        for (int s = _elapsedSeconds + 1; s <= newElapsed; s++) {
          if (_profile.bellAtSeconds.contains(s) && !_firedBells.contains(s)) {
            missedBell = true;
            _firedBells.add(s);
          }
        }

        setState(() {
          _elapsedSeconds = newElapsed;
          _remainingNotifier.value = _remaining;
        });

        if (missedBell) {
          _ringBell();
        }

        if (_elapsedSeconds >= _profile.durationSeconds) {
          _tickTimer?.cancel();
          setState(() {
            _isRunning = false;
            _isPaused = false;
          });
          WakelockPlus.disable();
          _unlockScreen();
          _onComplete();
        }
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tickTimer?.cancel();
    _audioPlayer.dispose();
    _pulseCtrl.dispose();
    _breathCtrl.dispose();
    _bellFlashCtrl.dispose();
    WakelockPlus.disable();
    _unlockScreen();
    _remainingNotifier.dispose();
    _isLockedNotifier.dispose();
    super.dispose();
  }

  // ── Timer logic ───────────────────────────────────────────────

  void _start() {
    // Fire start bell if at second 0
    if (!_isPaused &&
        _profile.bellAtSeconds.contains(0) &&
        !_firedBells.contains(0)) {
      _ringBell(); // fire-and-forget
      _firedBells.add(0);
    }

    _timerStartDateTime = DateTime.now();
    _elapsedAtStart = _elapsedSeconds;

    setState(() {
      _isRunning = true;
      _isPaused = false;
      _remainingNotifier.value = _remaining;
    });

    WakelockPlus.enable();

    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (!mounted) return;
      
      final diff = DateTime.now().difference(_timerStartDateTime!).inSeconds;
      final newElapsed = _elapsedAtStart + diff;

      if (newElapsed != _elapsedSeconds) {
        setState(() {
          _elapsedSeconds = newElapsed;
          _remainingNotifier.value = _remaining;
        });

        if (_profile.bellAtSeconds.contains(_elapsedSeconds) &&
            !_firedBells.contains(_elapsedSeconds)) {
          _ringBell(); // fire-and-forget
          _firedBells.add(_elapsedSeconds);
        }

        if (_elapsedSeconds >= _profile.durationSeconds) {
          _tickTimer?.cancel();
          setState(() {
            _isRunning = false;
            _isPaused = false;
          });
          WakelockPlus.disable();
          _unlockScreen();
          _onComplete();
        }
      }
    });
  }

  void _pause() {
    _tickTimer?.cancel();
    if (_timerStartDateTime != null) {
      final diff = DateTime.now().difference(_timerStartDateTime!).inSeconds;
      _elapsedSeconds = _elapsedAtStart + diff;
    }
    setState(() {
      _isRunning = false;
      _isPaused = true;
      _remainingNotifier.value = _remaining;
    });
    WakelockPlus.disable();
  }

  void _reset() {
    _tickTimer?.cancel();
    setState(() {
      _elapsedSeconds = 0;
      _isRunning = false;
      _isPaused = false;
      _firedBells.clear();
      _bellCount = 0;
      _timerStartDateTime = null;
      _elapsedAtStart = 0;
      _remainingNotifier.value = _profile.durationSeconds;
    });
    WakelockPlus.disable();
    _unlockScreen();
  }

  void _lockScreen() {
    if (_lockOverlayEntry != null) return;

    _isLockedNotifier.value = true;
    _lockOverlayEntry = OverlayEntry(
      builder: (context) {
        return _LockOverlay(
          remainingNotifier: _remainingNotifier,
          isLockedNotifier: _isLockedNotifier,
          breathAnim: _breathAnim,
          onUnlock: _unlockScreen,
        );
      },
    );
    Overlay.of(context).insert(_lockOverlayEntry!);
  }

  void _unlockScreen() {
    if (_lockOverlayEntry == null) return;
    _isLockedNotifier.value = false;
    _lockOverlayEntry?.remove();
    _lockOverlayEntry = null;
  }

  Future<void> _ringBell() async {
    HapticFeedback.mediumImpact();
    _bellFlashCtrl.forward(from: 0.0).then((_) => _bellFlashCtrl.reverse());

    // Cycle through bell1 → bell2 → bell3 → bell1 → …
    final asset = _bellAssets[_bellCount % _bellAssets.length];
    _bellCount++;

    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(asset));
    } catch (_) {
      // Gracefully ignore audio errors (e.g. unsupported platform)
    }
  }

  void _onComplete() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '🕊️  Session Complete',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Text(
          '"${_profile.name}" is done.\nTake a moment to return to the present.',
          style: const TextStyle(color: Colors.white70, height: 1.5),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _reset();
            },
            child: const Text('Close',
                style: TextStyle(color: Colors.deepPurpleAccent)),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────

  String _fmt(int secs) {
    if (secs < 0) secs = 0;
    return '${(secs ~/ 60).toString().padLeft(2, '0')}:'
        '${(secs % 60).toString().padLeft(2, '0')}';
  }

  int? get _nextBell {
    for (final b in _profile.bellAtSeconds) {
      if (b > _elapsedSeconds) return b;
    }
    return null;
  }

  // ── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final nb = _nextBell;

    return AnimatedBuilder(
      animation: _bellFlashAnim,
      builder: (context, child) {
        return Stack(
          children: [
            // Soft bell flash overlay
            if (_bellFlashAnim.value > 0)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    color: Colors.white.withOpacity(
                        (_bellFlashAnim.value * (1 - _bellFlashAnim.value) * 4)
                            .clamp(0.0, 0.12)),
                  ),
                ),
              ),
            child!,
          ],
        );
      },
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            children: [
              // ── Profile selector ──────────────────────────────
              _buildProfileChips(),
              const SizedBox(height: 8),

              // ── Profile name & duration ───────────────────────
              Text(
                _profile.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _profile.durationLabel,
                style: const TextStyle(
                    fontSize: 12, color: Colors.white38, letterSpacing: 1.2),
              ),
              const SizedBox(height: 28),

              // ── Circular timer ────────────────────────────────
              _buildCircularTimer(),
              const SizedBox(height: 20),

              // ── Next bell pill ────────────────────────────────
              AnimatedOpacity(
                opacity: (nb != null && _isRunning) ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 400),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.deepPurple.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🔔',
                          style: TextStyle(fontSize: 13)),
                      const SizedBox(width: 6),
                      Text(
                        nb != null
                            ? 'Next bell in ${_fmt(nb - _elapsedSeconds)}'
                            : ' ',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.white54),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // ── Controls ──────────────────────────────────────
              _buildControls(),
              const SizedBox(height: 36),

              // ── Bell schedule ─────────────────────────────────
              _buildBellSchedule(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Profile chip selector
  // ─────────────────────────────────────────────────────────────
  Widget _buildProfileChips() {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: widget.profiles.length,
        itemBuilder: (context, i) {
          final active = i == widget.activeProfileIndex;
          return GestureDetector(
            onTap: () {
              if (!_isRunning) widget.onProfileChanged(i);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: active
                    ? Colors.deepPurpleAccent.withOpacity(0.2)
                    : Colors.white.withOpacity(0.05),
                border: Border.all(
                  color: active
                      ? Colors.deepPurpleAccent.withOpacity(0.7)
                      : Colors.white.withOpacity(0.1),
                ),
              ),
              child: Text(
                widget.profiles[i].name,
                style: TextStyle(
                  fontSize: 13,
                  color: active
                      ? Colors.deepPurpleAccent
                      : Colors.white38,
                  fontWeight:
                      active ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Circular timer display
  // ─────────────────────────────────────────────────────────────
  Widget _buildCircularTimer() {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnim, _breathAnim]),
      builder: (_, __) {
        return Transform.scale(
          scale: _isRunning ? _pulseAnim.value : 1.0,
          child: SizedBox(
            width: 210,
            height: 210,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Ambient glow when running
                if (_isRunning)
                  Container(
                    width: 210,
                    height: 210,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color.lerp(
                            Colors.deepPurple.withOpacity(0.1),
                            Colors.indigoAccent.withOpacity(0.35),
                            _breathAnim.value,
                          )!,
                          blurRadius: 48,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),
                // Arc progress
                CustomPaint(
                  size: const Size(210, 210),
                  painter: _ArcPainter(
                    progress: _progress,
                    color: _isRunning
                        ? Color.lerp(Colors.deepPurpleAccent,
                            Colors.cyanAccent, _breathAnim.value)!
                        : Colors.deepPurpleAccent.withOpacity(0.55),
                  ),
                ),
                // Center text
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _fmt(_remaining),
                      style: const TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w200,
                        color: Colors.white,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isRunning
                          ? (_breathAnim.value > 0.5 ? 'exhale' : 'inhale')
                          : _isPaused
                              ? 'paused'
                              : 'ready',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 2,
                        color: _isPaused
                            ? Colors.amberAccent.withOpacity(0.6)
                            : Colors.white.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Playback controls
  // ─────────────────────────────────────────────────────────────
  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _CircleBtn(
          icon: Icons.refresh_rounded,
          color: Colors.white30,
          onTap: _isRunning ? null : _reset,
        ),
        const SizedBox(width: 20),
        GestureDetector(
          onTap: _isRunning ? _pause : _start,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: _isRunning
                    ? [Colors.amberAccent, Colors.orange]
                    : [Colors.deepPurpleAccent, Colors.indigoAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isRunning
                      ? Colors.amber.withOpacity(0.45)
                      : Colors.deepPurple.withOpacity(0.5),
                  blurRadius: 22,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              _isRunning
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
        ),
        const SizedBox(width: 20),
        _CircleBtn(
          icon: Icons.stop_rounded,
          color: Colors.redAccent.withOpacity(0.55),
          onTap: (_isRunning || _isPaused) ? _reset : null,
        ),
        const SizedBox(width: 20),
        _CircleBtn(
          icon: Icons.lock_outline_rounded,
          color: Colors.tealAccent.withOpacity(0.65),
          onTap: (_isRunning || _isPaused) ? _lockScreen : null,
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Bell schedule card
  // ─────────────────────────────────────────────────────────────
  Widget _buildBellSchedule() {
    if (_profile.bellAtSeconds.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.035),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'BELL SCHEDULE',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.5,
              color: Colors.white38,
            ),
          ),
          const SizedBox(height: 14),

          // Timeline bar with bell markers
          LayoutBuilder(builder: (ctx, box) {
            final trackW = box.maxWidth;
            return SizedBox(
              height: 28,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Track
                  Positioned(
                    top: 12,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Progress fill
                  Positioned(
                    top: 12,
                    left: 0,
                    width: trackW * _progress,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Colors.deepPurpleAccent,
                            Colors.cyanAccent
                          ],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Bell dots
                  ..._profile.bellAtSeconds.map((b) {
                    final frac = _profile.durationSeconds > 0
                        ? b / _profile.durationSeconds
                        : 0.0;
                    final x =
                        (frac * trackW - 7).clamp(0.0, trackW - 14);
                    final fired = _firedBells.contains(b);
                    return Positioned(
                      top: 6,
                      left: x,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: fired
                              ? Colors.deepPurpleAccent
                              : Colors.black54,
                          border: Border.all(
                            color: fired
                                ? Colors.deepPurpleAccent
                                : Colors.white38,
                            width: 1.5,
                          ),
                          boxShadow: fired
                              ? [
                                  BoxShadow(
                                    color: Colors.deepPurpleAccent
                                        .withOpacity(0.55),
                                    blurRadius: 8,
                                  )
                                ]
                              : null,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          }),

          const SizedBox(height: 14),

          // Bell time labels
          Wrap(
            spacing: 10,
            runSpacing: 6,
            children: _profile.bellAtSeconds.map((b) {
              final fired = _firedBells.contains(b);
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: fired
                      ? Colors.deepPurpleAccent.withOpacity(0.15)
                      : Colors.white.withOpacity(0.04),
                  border: Border.all(
                    color: fired
                        ? Colors.deepPurpleAccent.withOpacity(0.4)
                        : Colors.white.withOpacity(0.07),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '🔔',
                      style: TextStyle(
                          fontSize: 11,
                          color: fired ? null : const Color(0x44FFFFFF)),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _fmt(b),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: fired
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: fired
                            ? Colors.deepPurpleAccent
                            : Colors.white38,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Small helpers
// ─────────────────────────────────────────────────────────────

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _CircleBtn(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: enabled ? 1.0 : 0.35,
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.1),
            border: Border.all(color: color, width: 1.5),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  final Color color;

  const _ArcPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 7;

    // Track ring
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withOpacity(0.07)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );

    // Progress arc
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        2 * pi * progress,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.progress != progress || old.color != color;
}

class _LockOverlay extends StatelessWidget {
  final ValueNotifier<int> remainingNotifier;
  final ValueNotifier<bool> isLockedNotifier;
  final Animation<double> breathAnim;
  final VoidCallback onUnlock;

  const _LockOverlay({
    required this.remainingNotifier,
    required this.isLockedNotifier,
    required this.breathAnim,
    required this.onUnlock,
  });

  String _fmt(int secs) {
    if (secs < 0) secs = 0;
    return '${(secs ~/ 60).toString().padLeft(2, '0')}:'
        '${(secs % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black, // True black OLED screen
      child: PopScope(
        canPop: false, // Prevent physical back button from popping
        child: SafeArea(
          child: Stack(
            children: [
              // Breathing glow effect
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: breathAnim,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.center,
                          radius: 1.0,
                          colors: [
                            Color.lerp(
                              Colors.deepPurple.withOpacity(0.06),
                              Colors.cyan.withOpacity(0.12),
                              breathAnim.value,
                            )!,
                            Colors.black,
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // UI Content
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onDoubleTap: onUnlock,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Padlock icon
                      AnimatedBuilder(
                        animation: breathAnim,
                        builder: (context, child) {
                          return Icon(
                            Icons.lock_outline_rounded,
                            color: Colors.white.withOpacity(
                              0.15 + (breathAnim.value * 0.1),
                            ),
                            size: 32,
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // Ticking time display
                      ValueListenableBuilder<int>(
                        valueListenable: remainingNotifier,
                        builder: (context, remaining, _) {
                          return Text(
                            _fmt(remaining),
                            style: TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.w100,
                              color: Colors.white.withOpacity(0.35),
                              letterSpacing: 4,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),

                      // Breath guide
                      AnimatedBuilder(
                        animation: breathAnim,
                        builder: (context, child) {
                          return Text(
                            breathAnim.value > 0.5 ? 'exhale' : 'inhale',
                            style: TextStyle(
                              fontSize: 12,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w300,
                              color: Colors.white.withOpacity(
                                0.15 + (breathAnim.value * 0.15),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 120),

                      // Unlock instruction
                      Text(
                        'Double-tap to unlock',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1.5,
                          color: Colors.white.withOpacity(0.12),
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
