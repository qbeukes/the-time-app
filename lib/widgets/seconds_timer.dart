import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class SecondsTimer extends StatefulWidget {
  const SecondsTimer({super.key});

  @override
  State<SecondsTimer> createState() => _SecondsTimerState();
}

class _SecondsTimerState extends State<SecondsTimer>
    with TickerProviderStateMixin {
  // Timer state
  int _totalSeconds = 300; // default 5 min
  int _remainingSeconds = 300;
  bool _isRunning = false;
  bool _isPaused = false;
  Timer? _timer;

  // Preset durations (label, seconds)
  static const List<(String, int)> _presets = [
    ('1 min', 60),
    ('3 min', 180),
    ('5 min', 300),
    ('10 min', 600),
    ('15 min', 900),
    ('20 min', 1200),
    ('30 min', 1800),
  ];

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _breathController;
  late Animation<double> _pulseAnim;
  late Animation<double> _breathAnim;

  // Custom time editing
  final TextEditingController _minutesCtrl = TextEditingController(text: '5');
  final TextEditingController _secondsCtrl = TextEditingController(text: '0');

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _breathAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _breathController.dispose();
    _minutesCtrl.dispose();
    _secondsCtrl.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_isPaused) {
      // Resume
      setState(() {
        _isRunning = true;
        _isPaused = false;
      });
    } else {
      // Fresh start — read from fields
      final mins = int.tryParse(_minutesCtrl.text) ?? 5;
      final secs = int.tryParse(_secondsCtrl.text) ?? 0;
      final total = mins * 60 + secs;
      if (total <= 0) return;
      setState(() {
        _totalSeconds = total;
        _remainingSeconds = total;
        _isRunning = true;
        _isPaused = false;
      });
    }

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remainingSeconds <= 0) {
        t.cancel();
        setState(() {
          _isRunning = false;
          _isPaused = false;
        });
        _onComplete();
        return;
      }
      setState(() {
        _remainingSeconds--;
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isPaused = true;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    final mins = int.tryParse(_minutesCtrl.text) ?? 5;
    final secs = int.tryParse(_secondsCtrl.text) ?? 0;
    setState(() {
      _totalSeconds = mins * 60 + secs;
      _remainingSeconds = _totalSeconds;
      _isRunning = false;
      _isPaused = false;
    });
  }

  void _onComplete() {
    // Trigger completion effect — could add haptic / sound later
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '🕊️ Session Complete',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'Well done. Take a moment to return to the present.',
          style: TextStyle(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Close',
              style: TextStyle(color: Colors.deepPurpleAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _applyPreset(int seconds) {
    _timer?.cancel();
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    _minutesCtrl.text = mins.toString();
    _secondsCtrl.text = secs.toString();
    setState(() {
      _totalSeconds = seconds;
      _remainingSeconds = seconds;
      _isRunning = false;
      _isPaused = false;
    });
  }

  String _formatTime(int secs) {
    final m = secs ~/ 60;
    final s = secs % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  double get _progress =>
      _totalSeconds > 0 ? 1.0 - (_remainingSeconds / _totalSeconds) : 0.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            Colors.deepPurple.shade900.withOpacity(0.5),
            Colors.indigo.shade900.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Colors.deepPurpleAccent.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.2),
            blurRadius: 24,
            spreadRadius: -4,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.deepPurpleAccent, Colors.indigoAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurpleAccent.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('⏳', style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MEDITATION TIMER',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                        color: Colors.deepPurpleAccent,
                      ),
                    ),
                    Text(
                      'Seconds',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Circular Timer Display
            AnimatedBuilder(
              animation: Listenable.merge([_pulseAnim, _breathAnim]),
              builder: (context, child) {
                return Transform.scale(
                  scale: _isRunning ? _pulseAnim.value : 1.0,
                  child: SizedBox(
                    width: 180,
                    height: 180,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer glow ring (breath)
                        if (_isRunning)
                          Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color.lerp(
                                    Colors.deepPurple.withOpacity(0.2),
                                    Colors.indigoAccent.withOpacity(0.4),
                                    _breathAnim.value,
                                  )!,
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                          ),
                        // Progress arc
                        CustomPaint(
                          size: const Size(180, 180),
                          painter: _ArcPainter(
                            progress: _progress,
                            color: _isRunning
                                ? Color.lerp(
                                    Colors.deepPurpleAccent,
                                    Colors.cyanAccent,
                                    _breathAnim.value,
                                  )!
                                : Colors.deepPurpleAccent.withOpacity(0.6),
                          ),
                        ),
                        // Time text
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _formatTime(_remainingSeconds),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w200,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                            if (_isRunning)
                              Text(
                                'breath and witness',
                                style: TextStyle(
                                  fontSize: 11,
                                  letterSpacing: 1.5,
                                  color: Colors.white.withOpacity(0.4),
                                ),
                              ),
                            if (!_isRunning && !_isPaused)
                              Text(
                                'ready',
                                style: TextStyle(
                                  fontSize: 11,
                                  letterSpacing: 1.5,
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                            if (_isPaused)
                              Text(
                                'paused',
                                style: TextStyle(
                                  fontSize: 11,
                                  letterSpacing: 1.5,
                                  color: Colors.amberAccent.withOpacity(0.6),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Reset
                _ControlButton(
                  icon: Icons.refresh_rounded,
                  color: Colors.white30,
                  onTap: _resetTimer,
                ),
                const SizedBox(width: 16),
                // Play/Pause (main)
                GestureDetector(
                  onTap: _isRunning ? _pauseTimer : _startTimer,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 64,
                    height: 64,
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
                              ? Colors.amber.withOpacity(0.4)
                              : Colors.deepPurple.withOpacity(0.5),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isRunning
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Stop / restart
                _ControlButton(
                  icon: Icons.stop_rounded,
                  color: Colors.redAccent.withOpacity(0.6),
                  onTap: () {
                    _timer?.cancel();
                    final mins = int.tryParse(_minutesCtrl.text) ?? 5;
                    final secs = int.tryParse(_secondsCtrl.text) ?? 0;
                    setState(() {
                      _totalSeconds = mins * 60 + secs;
                      _remainingSeconds = _totalSeconds;
                      _isRunning = false;
                      _isPaused = false;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Custom duration input
            if (!_isRunning)
              AnimatedOpacity(
                opacity: _isRunning ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: Column(
                  children: [
                    const Text(
                      'SET DURATION',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                        color: Colors.white38,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _TimeField(
                          controller: _minutesCtrl,
                          label: 'min',
                          onChanged: _syncFromFields,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            ':',
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.white54,
                              fontWeight: FontWeight.w200,
                            ),
                          ),
                        ),
                        _TimeField(
                          controller: _secondsCtrl,
                          label: 'sec',
                          onChanged: _syncFromFields,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Preset chips
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 6,
                      children: _presets.map((p) {
                        final isSelected =
                            _totalSeconds == p.$2 && !_isRunning && !_isPaused;
                        return GestureDetector(
                          onTap: () => _applyPreset(p.$2),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: isSelected
                                  ? Colors.deepPurpleAccent.withOpacity(0.3)
                                  : Colors.white.withOpacity(0.05),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.deepPurpleAccent.withOpacity(0.7)
                                    : Colors.white.withOpacity(0.1),
                              ),
                            ),
                            child: Text(
                              p.$1,
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected
                                    ? Colors.deepPurpleAccent
                                    : Colors.white54,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _syncFromFields() {
    if (_isRunning || _isPaused) return;
    final mins = int.tryParse(_minutesCtrl.text) ?? 0;
    final secs = int.tryParse(_secondsCtrl.text) ?? 0;
    setState(() {
      _totalSeconds = mins * 60 + secs;
      _remainingSeconds = _totalSeconds;
    });
  }
}

// ─────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.15),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final VoidCallback onChanged;

  const _TimeField({
    required this.controller,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 64,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.w300,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 10,
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.06),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.deepPurpleAccent),
              ),
            ),
            onChanged: (_) => onChanged(),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.white38),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Arc painter for circular progress
// ─────────────────────────────────────────────────────────────
class _ArcPainter extends CustomPainter {
  final double progress;
  final Color color;

  const _ArcPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    // Background track
    final trackPaint = Paint()
      ..color = Colors.white.withOpacity(0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    if (progress > 0) {
      final arcPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        2 * pi * progress,
        false,
        arcPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.progress != progress || old.color != color;
}
