import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

class StylizedMoon extends StatelessWidget {
  final double phase; // 0.0 to 1.0
  final double size;

  const StylizedMoon({super.key, required this.phase, this.size = 200});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // The Bloom / Glow Effect
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.1),
            blurRadius: 40,
            spreadRadius: 10,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: CustomPaint(
        size: Size(size, size),
        painter: _MoonPhasePainter(phase: phase),
      ),
    );
  }
}

class _MoonPhasePainter extends CustomPainter {
  final double phase; // 0.0 to 1.0

  _MoonPhasePainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final center = Offset(r, r);

    // 1. Draw base dark moon (Earthshine) with a subtle 3D sphere gradient
    final darkPaint = Paint()
      ..shader = ui.Gradient.radial(
        center,
        r,
        [const Color(0xFF2F3E46), const Color(0xFF1A1F24)],
        [0.0, 1.0],
      )
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, r, darkPaint);

    // Get the illuminated path
    Path litPath = _getLitPath(r, phase);

    // 2. Draw lit hemisphere with a bright 3D sphere gradient
    final lightPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(r * 0.7, r * 0.7), // Offset the highlight for 3D effect
        r * 1.5,
        [const Color(0xFFFFFFFF), const Color(0xFFD0D5DB)],
        [0.0, 1.0],
      )
      ..style = PaintingStyle.fill;

    canvas.drawPath(litPath, lightPaint);
  }

  Path _getLitPath(double r, double phase) {
    Path path = Path();
    final center = Offset(r, r);

    if (phase == 0.0 || phase == 1.0) return path;
    if (phase == 0.5) {
      path.addOval(Rect.fromCircle(center: center, radius: r));
      return path;
    }

    final isWaxing = phase <= 0.5;
    final rect = Rect.fromCircle(center: center, radius: r);

    Path hemi = Path();
    if (isWaxing) {
      hemi.addArc(rect, -math.pi / 2, math.pi);
    } else {
      hemi.addArc(rect, math.pi / 2, math.pi);
    }
    hemi.close();

    final c = math.cos(2 * math.pi * phase);
    final ellipseWidth = r * c.abs();

    if (ellipseWidth < 0.1) return hemi;

    Path ellipse = Path();
    final ellipseRect = Rect.fromCenter(
        center: center, width: ellipseWidth * 2, height: r * 2);

    if (phase <= 0.25) {
      ellipse.addArc(ellipseRect, -math.pi / 2, math.pi);
      ellipse.close();
      return Path.combine(PathOperation.difference, hemi, ellipse);
    } else if (phase <= 0.5) {
      ellipse.addArc(ellipseRect, math.pi / 2, math.pi);
      ellipse.close();
      return Path.combine(PathOperation.union, hemi, ellipse);
    } else if (phase <= 0.75) {
      ellipse.addArc(ellipseRect, -math.pi / 2, math.pi);
      ellipse.close();
      return Path.combine(PathOperation.union, hemi, ellipse);
    } else {
      ellipse.addArc(ellipseRect, math.pi / 2, math.pi);
      ellipse.close();
      return Path.combine(PathOperation.difference, hemi, ellipse);
    }
  }

  @override
  bool shouldRepaint(covariant _MoonPhasePainter oldDelegate) {
    return oldDelegate.phase != phase;
  }
}
