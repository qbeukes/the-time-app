import 'package:flutter/material.dart';
import '../models/moment.dart';
import '../models/solar/gregorian_solar_time.dart';
import '../models/solar/enochian_solar_time.dart';

class SunScreen extends StatelessWidget {
  final DateTime date;
  final bool showGregorian;
  final bool showEnochian;
  final bool showLocalTime;

  const SunScreen({
    super.key,
    required this.date,
    this.showGregorian = true,
    this.showEnochian = true,
    this.showLocalTime = true,
  });

  @override
  Widget build(BuildContext context) {
    // Use the navigable date for Gregorian and Enochian cards
    final moment = Moment(date.millisecondsSinceEpoch);
    final gregorian = GregorianSolarTime(moment);
    final enochian = EnochianSolarTime(moment);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/static_sun_transparent_bg.png',
                width: 320,
                height: 320,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),

              // ── Gregorian Card ──────────────────────────────────
              if (showGregorian) ...[
                _buildGregorianCard(gregorian),
                const SizedBox(height: 16),
              ],

              // ── Enochian Card ───────────────────────────────────
              if (showEnochian) ...[
                _buildEnochianCard(enochian),
                const SizedBox(height: 16),
              ],

              // ── localTime Card ───────────────────────
              if (showLocalTime) ...[
                _buildLocalTimeCard(gregorian),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // localTime Card (Daily Clock)
  // ═══════════════════════════════════════════════════════════════

  Widget _buildLocalTimeCard(GregorianSolarTime greg) {
    const accentColor = Color(0xFF00E5FF); // neon cyan
    const secondaryColor = Color(0xFF2979FF); // electric blue

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0x2200E5FF), Color(0x0E2979FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0x5500E5FF), width: 1.5),
        boxShadow: const [
          BoxShadow(color: Color(0x2600E5FF), blurRadius: 24, spreadRadius: -4),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [accentColor, secondaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x6600E5FF),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('⏰', style: TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Time of Day',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: accentColor.withOpacity(0.85),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        greg.timeZoneHeader,
                        style: const TextStyle(
                          fontSize: 18,
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
            Center(
              child: Text(
                greg.formattedTime,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 4,
                  color: Colors.white,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Gregorian Solar Calendar Card
  // ═══════════════════════════════════════════════════════════════

  Widget _buildGregorianCard(GregorianSolarTime greg) {
    const accentColor = Color(0xFFFFA726); // warm amber
    const secondaryColor = Color(0xFFFFD54F); // lighter gold

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0x22FFA726), Color(0x0EFFD54F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0x55FFA726), width: 1.5),
        boxShadow: const [
          BoxShadow(color: Color(0x26FFA726), blurRadius: 24, spreadRadius: -4),
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
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [accentColor, secondaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x66FFA726),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('☀️', style: TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GREGORIAN SOLAR CALENDAR',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: accentColor.withOpacity(0.85),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${greg.day} ${greg.monthName}, ${greg.year}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        greg.weekdayName,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white54,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(height: 24, color: Colors.white24),

            // ── Month progress ───────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${greg.day} ${greg.monthName}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: accentColor.withOpacity(0.9),
                  ),
                ),
                Text(
                  () {
                    final daysInMonth = DateUtils.getDaysInMonth(greg.year, greg.month);
                    return '${(greg.day / daysInMonth * 100).toStringAsFixed(1)}%';
                  }(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Month progress bar — day fraction within current month
            Builder(builder: (context) {
              final daysInMonth = DateUtils.getDaysInMonth(greg.year, greg.month);
              final monthProgress = greg.day / daysInMonth;
              return Container(
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: Colors.white10,
                ),
                clipBehavior: Clip.antiAlias,
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: monthProgress,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [accentColor, secondaryColor],
                      ),
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),

            // ── Year progress ────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'DAY ${greg.dayOfYear} OF ${greg.daysInYear}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: Colors.white54,
                  ),
                ),
                Text(
                  '${(greg.dayOfYear / greg.daysInYear * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: accentColor.withOpacity(0.9),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Year progress bar — 12 segments, one per month
            Row(
              children: List.generate(12, (index) {
                final m = index + 1; // month 1–12
                final daysInMonth = DateUtils.getDaysInMonth(greg.year, m);
                final isPast = m < greg.month;
                final isCurrent = m == greg.month;
                double segmentVal = 0.0;

                if (isPast) {
                  segmentVal = 1.0;
                } else if (isCurrent) {
                  segmentVal = greg.day / daysInMonth;
                }

                return Expanded(
                  flex: daysInMonth, // proportional to days in month
                  child: Container(
                    height: 6,
                    margin: EdgeInsets.only(
                      left: index == 0 ? 0.0 : 1.5,
                      right: index == 11 ? 0.0 : 1.5,
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
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [accentColor, secondaryColor],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Enochian Solar Calendar Card
  // ═══════════════════════════════════════════════════════════════

  Widget _buildEnochianCard(EnochianSolarTime enoch) {
    if (enoch.isOutOfTime) {
      return _buildOutOfTimeCard(enoch);
    }
    return _buildNormalEnochianCard(enoch);
  }

  Widget _buildNormalEnochianCard(EnochianSolarTime enoch) {
    const accentColor = Color(0xFF7C4DFF); // deep indigo-violet
    const secondaryColor = Color(0xFFB388FF); // lighter lavender

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0x227C4DFF), Color(0x0EB388FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0x557C4DFF), width: 1.5),
        boxShadow: const [
          BoxShadow(color: Color(0x267C4DFF), blurRadius: 24, spreadRadius: -4),
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
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [accentColor, secondaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x667C4DFF),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      '✦',
                      style: TextStyle(fontSize: 22, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ENOCHIAN SOLAR CALENDAR',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: accentColor.withOpacity(0.85),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Month ${enoch.enochianMonth}, Day ${enoch.enochianDay}',
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

            const Divider(height: 24, color: Colors.white24),

            // Month progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'MONTH ${enoch.enochianMonth} OF 13',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: Colors.white54,
                  ),
                ),
                Text(
                  'DAY ${enoch.enochianDay} OF 28',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: accentColor.withOpacity(0.9),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Month progress bar
            Container(
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: Colors.white10,
              ),
              clipBehavior: Clip.antiAlias,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: enoch.monthProgress,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accentColor, secondaryColor],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Year progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ENOCHIAN DAY ${enoch.enochianDayOfYear} OF 364',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: Colors.white54,
                  ),
                ),
                Text(
                  '${(enoch.yearProgress * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: secondaryColor.withOpacity(0.9),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Segmented year progress bar (13 segments for 13 months)
            Row(
              children: List.generate(13, (index) {
                final isCurrent = index == enoch.enochianMonth - 1;
                final isPast = index < enoch.enochianMonth - 1;
                double segmentVal = 0.0;

                if (isPast) {
                  segmentVal = 1.0;
                } else if (isCurrent) {
                  segmentVal = enoch.monthProgress;
                }

                return Expanded(
                  child: Container(
                    height: 6,
                    margin: EdgeInsets.only(
                      left: index == 0 ? 0.0 : 2.0,
                      right: index == 12 ? 0.0 : 2.0,
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
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [accentColor, secondaryColor],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ── "Day out of Time" variant ────────────────────────────────

  Widget _buildOutOfTimeCard(EnochianSolarTime enoch) {
    const accentColor = Color(0xFFFFD740); // golden amber
    const secondaryColor = Color(0xFFFF6D00); // deep orange

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0x22FFD740), Color(0x0EFF6D00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0x55FFD740), width: 1.5),
        boxShadow: const [
          BoxShadow(color: Color(0x33FFD740), blurRadius: 24, spreadRadius: -4),
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
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [accentColor, secondaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x66FFD740),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      '◇',
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ENOCHIAN SOLAR CALENDAR',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: accentColor.withOpacity(0.85),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Day out of Time',
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

            // Day out of time info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accentColor.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (enoch.totalOutOfTimeDays > 1) ...[
                    Text(
                      'Day ${enoch.outOfTimeDayNumber} of ${enoch.totalOutOfTimeDays}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                  const Text(
                    'This day falls outside the 364-day Enochian grid. '
                    'The calendar pauses to realign with the solar year before '
                    'a new cycle begins.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Year complete indicator — full bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'ENOCHIAN YEAR COMPLETE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: Colors.white54,
                  ),
                ),
                Text(
                  '364 / 364',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Full progress bar
            Container(
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: Colors.white10,
              ),
              clipBehavior: Clip.antiAlias,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 1.0,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accentColor, secondaryColor],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
