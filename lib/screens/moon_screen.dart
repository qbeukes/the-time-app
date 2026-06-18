import 'package:flutter/material.dart';
import 'package:the_time_app/models/lunar/full_moon_based_layer.dart';
import 'package:the_time_app/models/lunar/new_moon_based_layer.dart';
import 'package:the_time_app/models/lunar/luach/luach_layer.dart';
import 'package:the_time_app/models/lunar/lunar_time_unit.dart';
import 'package:the_time_app/models/moment.dart';
import 'package:the_time_app/models/tra/tra_layer.dart';
import 'package:the_time_app/models/tra/tra_archetype.dart';
import 'package:apsl_sun_calc/apsl_sun_calc.dart';
import '../widgets/stylized_moon.dart';


class MoonScreen extends StatelessWidget {
  final DateTime date;
  final double? latitude;
  final double? longitude;

  // Toggle flags — controlled by the burger menu in main.dart
  final bool showTra;
  final bool showLuach;
  final bool showMoonBase;
  final bool useLocalTilt;

  const MoonScreen({
    super.key,
    required this.date,
    this.latitude,
    this.longitude,
    this.showTra = true,
    this.showLuach = true,
    this.showMoonBase = true,
    this.useLocalTilt = true,
  });

  @override
  Widget build(BuildContext context) {
    final moment = LunarTimeUnit.fromDateTime(date);
    final illumination = SunCalc.getMoonIllumination(date);
    final currentPhase = illumination['phase']?.toDouble() ?? 0.0;
    final fraction = illumination['fraction']?.toDouble() ?? 0.0;
    final angle = illumination['angle']?.toDouble() ?? 0.0;

    double tilt = 0.0;
    if (useLocalTilt && latitude != null && longitude != null) {
      final position = SunCalc.getMoonPosition(date, latitude!, longitude!);
      final parallacticAngle = position['parallacticAngle']?.toDouble() ?? 0.0;
      tilt = parallacticAngle - angle;
    }

    final traLayer = TraLayer(moment);
    final luachLayer = LuachLayer(moment);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StylizedMoon(phase: currentPhase, size: 180, tilt: tilt),

              const SizedBox(height: 16),
              Text(
                '${(fraction * 100).toStringAsFixed(1)}% Illuminated',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
              ),

              const SizedBox(height: 12),
              Text(
                'Date: ${date.toLocal().toString().split('.')[0]}',
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),

              const SizedBox(height: 8),

              // ── 12TRA Card ────────────────────────────────────────────
              if (showTra) ...[
                _buildTraCard(traLayer),
                const SizedBox(height: 16),
              ],

              // ── Luach Card ────────────────────────────────────────────
              if (showLuach) ...[
                _buildLuachCard(context, luachLayer),
                const SizedBox(height: 16),
              ],

              // ── Moon Base Card ─────────────────────────────────────
              if (showMoonBase) ...[
                _buildMoonBaseCard(context, moment),
                const SizedBox(height: 16),
              ],

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoonBaseCard(BuildContext context, Moment moment) {
    const amberColor = Color(0xFFFFC107);
    const blueColor = Color(0xFF42A5F5);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0x22FFC107), // amber tint
            Color(0x0E42A5F5), // blue tint
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: const Color(0x55FFC107),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26FFC107),
            blurRadius: 24,
            spreadRadius: -4,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [amberColor, blueColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x66FFC107),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🌕', style: TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MOON CYCLE BASES',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: amberColor,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Lunar Anchors',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(height: 24, color: Colors.white24),

            // Full Moon Base row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: amberColor.withOpacity(0.12),
                    border: Border.all(
                        color: amberColor.withOpacity(0.4), width: 1.5),
                  ),
                  child: const Center(
                    child: Text('○', style: TextStyle(fontSize: 16, color: amberColor)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'FULL MOON BASE',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: amberColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        moment.toDisplayValue((m) => FullMoonBasedLayer(m as LunarTimeUnit)),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // New Moon Base row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: blueColor.withOpacity(0.12),
                    border: Border.all(
                        color: blueColor.withOpacity(0.4), width: 1.5),
                  ),
                  child: const Center(
                    child: Text('●', style: TextStyle(fontSize: 14, color: blueColor)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'NEW MOON BASE',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: blueColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        moment.toDisplayValue((m) => NewMoonBasedLayer(m as LunarTimeUnit)),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTraCard(TraLayer tra) {
    final monthly = tra.monthlyArchetype;
    final daily = tra.dailyArchetype;
    final phase = tra.phase;
    final progress = tra.phaseProgress;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            monthly.color.withOpacity(0.14),
            monthly.secondaryColor.withOpacity(0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: monthly.color.withOpacity(0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: monthly.color.withOpacity(0.15),
            blurRadius: 24,
            spreadRadius: -4,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [monthly.color, monthly.secondaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: monthly.color.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      monthly.symbol,
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '12TRA LUNAR RESONANCE [MOON ${tra.moonNumber}]',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: monthly.color.withOpacity(0.85),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${monthly.name} Archetype',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Monthly Description
            Text(
              monthly.description,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white70,
                fontStyle: FontStyle.italic,
              ),
            ),
            const Divider(height: 24, color: Colors.white24),
            // Macro Phase Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'MACRO PHASE: ${phase.name.toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: Colors.white54,
                  ),
                ),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}% Progress',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: monthly.color.withOpacity(0.9),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Segmented Progress Bar
            Row(
              children: List.generate(4, (index) {
                final isCurrent = index == phase.index;
                final isPast = index < phase.index;
                double segmentVal = 0.0;

                if (isPast) {
                  segmentVal = 1.0;
                } else if (isCurrent) {
                  segmentVal = progress;
                } else {
                  segmentVal = 0.0;
                }

                return Expanded(
                  child: Container(
                    height: 6,
                    margin: EdgeInsets.only(
                      left: index == 0 ? 0.0 : 4.0,
                      right: index == 3 ? 0.0 : 4.0,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: Colors.white10,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: segmentVal,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [monthly.color, monthly.secondaryColor],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            // Daily Archetype Details
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(
                    daily.symbol,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 12, color: Colors.white70),
                        children: [
                          const TextSpan(
                            text: 'Daily Active Mode: ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white54),
                          ),
                          TextSpan(
                            text: '${daily.name} — ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: daily.color,
                            ),
                          ),
                          TextSpan(text: daily.description),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLuachCard(BuildContext context, LuachLayer luach) {
    final moon = luach.currentMoon;
    final meta = luach.currentMetadata;
    final dayNumber = luach.dayOfMoon;

    if (moon == null || meta == null) {
      return const SizedBox.shrink();
    }

    // Correlate to 12TRA archetype by number for visual look and colors
    final archetype = TraArchetype.fromNumber(moon.moonNumberInYear);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            archetype.color.withOpacity(0.14),
            archetype.secondaryColor.withOpacity(0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: archetype.color.withOpacity(0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: archetype.color.withOpacity(0.15),
            blurRadius: 24,
            spreadRadius: -4,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [archetype.color, archetype.secondaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: archetype.color.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      '🌙',
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LUACH LUNAR LAYER [MOON ${moon.moonNumberInYear} • DAY $dayNumber]',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: archetype.color.withOpacity(0.85),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Month of ${meta.name}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Structural Axes & Gemstone Row
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'LUACH DIRECTION (STRUCTURAL AXIS)',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: Colors.white38,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          meta.direction,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: archetype.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '12TRA PHASE (PARALLEL AXIS)',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: Colors.white38,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          meta.traPhase,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Gemstone Badge
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: archetype.color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: archetype.color.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Text(
                    '💎',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                          fontSize: 13, color: Colors.white70),
                      children: [
                        const TextSpan(
                          text: 'Gemstone: ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white54),
                        ),
                        TextSpan(
                          text: meta.gemstone,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: archetype.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 24, color: Colors.white24),

            // Macro Phase Section
            Builder(builder: (context) {
              const phaseNames = ['East', 'South', 'West', 'North'];
              final phaseIdx = luach.macroPhaseIndex;
              final progress = luach.macroPhaseProgress;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'MACRO PHASE: ${phaseNames[phaseIdx].toUpperCase()}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          color: Colors.white54,
                        ),
                      ),
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}% Progress',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: archetype.color.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(4, (index) {
                      final isCurrent = index == phaseIdx;
                      final isPast = index < phaseIdx;
                      double segmentVal = 0.0;
                      if (isPast) {
                        segmentVal = 1.0;
                      } else if (isCurrent) {
                        segmentVal = progress;
                      }
                      return Expanded(
                        child: Container(
                          height: 6,
                          margin: EdgeInsets.only(
                            left: index == 0 ? 0.0 : 4.0,
                            right: index == 3 ? 0.0 : 4.0,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: Colors.white10,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: segmentVal,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    archetype.color,
                                    archetype.secondaryColor,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }),

            // Meaning Sections
            const Text(
              'LUACH ARCHETYPAL MEANING',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: Colors.white38,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              meta.archetypalSummary,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                const Text(
                  '12TRA FUNCTIONAL MEANING ',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: Colors.white38,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'NO. ${meta.number} CORRELATION',
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Colors.white54,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              meta.traFunctionalSummary,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white70,
              ),
            ),

            const Divider(height: 24, color: Colors.white24),

            // Resonance Alignment
            const Text(
              'PARALLEL RESONANCE ALIGNMENT',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              meta.cardDescription,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
