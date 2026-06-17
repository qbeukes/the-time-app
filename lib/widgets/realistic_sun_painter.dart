import 'package:flutter/material.dart';
import 'dart:math' as math;

class RealisticSun extends StatefulWidget {
  final double size;
  final bool animate;

  const RealisticSun({super.key, this.size = 280, this.animate = true});

  @override
  State<RealisticSun> createState() => _RealisticSunState();
}

class _RealisticSunState extends State<RealisticSun>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 25), // slow natural feel
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: SunPainter(
              animationValue: widget.animate ? _controller.value : 0.0,
            ),
          );
        },
      ),
    );
  }
}

class SunPainter extends CustomPainter {
  final double animationValue;

  SunPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.42;

    // 1. Outer soft corona glow
    final outerGlowPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.1,
        colors: [Colors.orange.withOpacity(0.25), Colors.transparent],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.6));
    canvas.drawCircle(center, radius * 1.65, outerGlowPaint);

    // 2. Medium glow layer
    final mediumGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.yellow.withOpacity(0.35),
          Colors.orange.withOpacity(0.15),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.35));
    canvas.drawCircle(center, radius * 1.35, mediumGlow);

    // 3. Main Sun Body with gradient
    final sunPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.2, -0.2),
        radius: 0.9,
        colors: const [
          Color(0xFFFFF7B5), // hot white-yellow core
          Color(0xFFFFE14D), // bright yellow
          Color(0xFFFFB300), // orange
          Color(0xFFFF7A00), // deeper orange
        ],
        stops: const [0.1, 0.4, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, sunPaint);

    // 4. Surface turbulence / granulation (subtle dots)
    final random = math.Random(42);
    final surfacePaint = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 180; i++) {
      final angle = random.nextDouble() * math.pi * 2;
      final dist = random.nextDouble() * radius * 0.85;
      final x = center.dx + math.cos(angle) * dist;
      final y = center.dy + math.sin(angle) * dist;
      final dotSize = random.nextDouble() * 3.5 + 1.2;

      canvas.drawCircle(Offset(x, y), dotSize, surfacePaint);
    }

    // 5. Subtle moving highlights (gives "alive" feeling)
    final highlightPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment(
          math.sin(animationValue * math.pi * 4) * 0.3,
          -0.4 + math.cos(animationValue * math.pi * 3) * 0.2,
        ),
        radius: 0.6,
        colors: [Colors.white.withOpacity(0.45), Colors.transparent],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.7));

    canvas.drawCircle(center, radius * 0.92, highlightPaint);
  }

  @override
  bool shouldRepaint(SunPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}
