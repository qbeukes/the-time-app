import 'package:flutter/material.dart';
import 'dart:math' as math;

class StylizedMoon extends StatelessWidget {
  final double phase; // 0.0 to 1.0
  final double size;
  final double tilt; // Rotation in radians based on location

  const StylizedMoon({super.key, required this.phase, this.size = 200, this.tilt = 0.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF0F172A), // Base deep space color
        // The Bloom / Glow Effect
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.15),
            blurRadius: 40,
            spreadRadius: 5,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias, // Ensure square images are clipped to a perfect circle
      child: Transform.rotate(
        angle: tilt,
        child: Stack(
          children: [
            // 1. Earthshine (Dark side of the moon texture)
            // We tint the image to look like the unilluminated dark side
            ColorFiltered(
              colorFilter: const ColorFilter.mode(
                Color(0xFF1E293B), // Dark slate blue
                BlendMode.multiply,
              ),
              child: Opacity(
                opacity: 0.6,
                child: Image.asset(
                  'assets/images/moon.png',
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback if image fails to load
                    return Container(color: const Color(0xFF1E293B));
                  },
                ),
              ),
            ),
            
            // 2. The Lit side (Bright moon texture)
            // Clipped mathematically to the exact crescent/gibbous shape
            ClipPath(
              clipper: _MoonPhaseClipper(phase: phase),
              child: Image.asset(
                'assets/images/moon.png',
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(color: const Color(0xFFF8FAFC));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoonPhaseClipper extends CustomClipper<Path> {
  final double phase; // 0.0 to 1.0

  _MoonPhaseClipper({required this.phase});

  @override
  Path getClip(Size size) {
    final r = size.width / 2;
    final center = Offset(r, r);
    Path path = Path();

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
  bool shouldReclip(covariant _MoonPhaseClipper oldClipper) {
    return oldClipper.phase != phase;
  }
}
