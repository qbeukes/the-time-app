import 'dart:math';
import 'package:the_time_app/models/moment.dart';

/// A lunar time unit anchored to the current platform moment.
///
/// Uses the Jean Meeus algorithm ("Astronomical Algorithms", 2nd ed.,
/// Chapter 49) to compute new-moon and full-moon instants to within
/// a few seconds over centuries.
///
/// Extends [Moment] so it can be used wherever a [Moment] is expected
/// while providing first-class lunar-phase navigation.
class LunarTimeUnit extends Moment {
  const LunarTimeUnit(super.epochMilliseconds);

  /// Create a [LunarTimeUnit] representing right now.
  factory LunarTimeUnit.now() =>
      LunarTimeUnit(DateTime.now().millisecondsSinceEpoch);

  /// Create a [LunarTimeUnit] from any [DateTime].
  factory LunarTimeUnit.fromDateTime(DateTime dt) =>
      LunarTimeUnit(dt.millisecondsSinceEpoch);

  // ─── Internal epoch helpers ───────────────────────────────────────────────

  /// J2000.0 Julian Day Number (2000-01-01 12:00:00 UTC)
  static const double _j2000JDE = 2451545.0;

  /// J2000.0 as Unix milliseconds (2000-01-01 12:00:00 UTC)
  static const int _j2000Ms = 946728000000;

  /// Meeus k=0 new-moon reference JDE (≈ 2000-01-06 14:21 UTC)
  static const double _k0JDE = 2451550.09766;

  /// Mean synodic month in days (Meeus Table 49.a)
  static const double _synodicMonth = 29.530588861;

  static double _msToJDE(int ms) =>
      (ms - _j2000Ms) / 86400000.0 + _j2000JDE;

  static int _jdeToMs(double jde) =>
      ((jde - _j2000JDE) * 86400000.0 + _j2000Ms).round();

  // ─── Continuous k value ───────────────────────────────────────────────────

  /// Continuous k for this moment (k integer ≡ new moon; k+0.5 ≡ full moon).
  double _kContinuous() =>
      (_msToJDE(epochMilliseconds) - _k0JDE) / _synodicMonth;

  // ─── Jean Meeus phase computation (Chapter 49) ───────────────────────────

  static double _norm360(double deg) => ((deg % 360.0) + 360.0) % 360.0;
  static double _rad(double deg) => deg * pi / 180.0;

  /// Compute the JDE of a lunar phase.
  ///
  /// [kInt] is an **integer** base; the actual k used is:
  ///   - new moon  : k = kInt
  ///   - full moon : k = kInt + 0.5
  static double _phaseJDE(int kInt, {required bool fullMoon}) {
    final double k = fullMoon ? kInt + 0.5 : kInt.toDouble();
    final T = k / 1236.85;
    final T2 = T * T;
    final T3 = T2 * T;
    final T4 = T3 * T;

    // Mean JDE
    double JDE = _k0JDE
        + _synodicMonth * k
        + 0.00015437 * T2
        - 0.000000150 * T3
        + 0.00000000073 * T4;

    // Earth's orbital eccentricity correction
    final E = 1.0 - 0.002516 * T - 0.0000074 * T2;

    // Argument angles (degrees → radians, normalised to [0°, 360°])
    final M  = _rad(_norm360(  2.5534       + 29.10535670  * k - 0.0000014  * T2 - 0.00000011 * T3));
    final Mp = _rad(_norm360(201.5643       + 385.81693528 * k + 0.0107582  * T2 + 0.00001238 * T3 - 0.000000058 * T4));
    final F  = _rad(_norm360(160.7108       + 390.67050284 * k - 0.0016118  * T2 - 0.00000227 * T3 + 0.000000011 * T4));
    final Om = _rad(_norm360(124.7746       -   1.56375588 * k + 0.0020672  * T2 + 0.00000215 * T3));

    if (!fullMoon) {
      // ── New-moon planetary corrections ─────────────────────────────────
      JDE +=
          -0.40720 * sin(Mp)
        + 0.17241 * E        * sin(M)
        + 0.01608 * sin(2 * Mp)
        + 0.01039 * sin(2 * F)
        + 0.00739 * E        * sin(Mp - M)
        - 0.00514 * E        * sin(Mp + M)
        + 0.00208 * E * E    * sin(2 * M)
        - 0.00111 * sin(Mp - 2 * F)
        - 0.00057 * sin(Mp + 2 * F)
        + 0.00056 * E        * sin(2 * Mp + M)
        - 0.00042 * sin(3 * Mp)
        + 0.00042 * E        * sin(M + 2 * F)
        + 0.00038 * E        * sin(M - 2 * F)
        - 0.00024 * E        * sin(2 * Mp - M)
        - 0.00017 * sin(Om)
        - 0.00007 * sin(Mp + 2 * M)
        + 0.00004 * sin(2 * Mp - 2 * F)
        + 0.00004 * sin(3 * M)
        + 0.00003 * sin(Mp + M - 2 * F)
        + 0.00003 * sin(2 * Mp + 2 * F)
        - 0.00003 * sin(Mp + M + 2 * F)
        + 0.00003 * sin(Mp - M + 2 * F)
        - 0.00002 * sin(Mp - M - 2 * F)
        - 0.00002 * sin(3 * Mp + M)
        + 0.00002 * sin(4 * Mp);
    } else {
      // ── Full-moon planetary corrections ────────────────────────────────
      JDE +=
          -0.40614 * sin(Mp)
        + 0.17302 * E        * sin(M)
        + 0.01614 * sin(2 * Mp)
        + 0.01043 * sin(2 * F)
        + 0.00734 * E        * sin(Mp - M)
        - 0.00515 * E        * sin(Mp + M)
        + 0.00209 * E * E    * sin(2 * M)
        - 0.00111 * sin(Mp - 2 * F)
        - 0.00057 * sin(Mp + 2 * F)
        + 0.00056 * E        * sin(2 * Mp + M)
        - 0.00042 * sin(3 * Mp)
        + 0.00042 * E        * sin(M + 2 * F)
        + 0.00038 * E        * sin(M - 2 * F)
        - 0.00024 * E        * sin(2 * Mp - M)
        - 0.00017 * sin(Om)
        - 0.00007 * sin(Mp + 2 * M)
        + 0.00004 * sin(2 * Mp - 2 * F)
        + 0.00004 * sin(3 * M)
        + 0.00003 * sin(Mp + M - 2 * F)
        + 0.00003 * sin(2 * Mp + 2 * F)
        - 0.00003 * sin(Mp + M + 2 * F)
        + 0.00003 * sin(Mp - M + 2 * F)
        - 0.00002 * sin(Mp - M - 2 * F)
        - 0.00002 * sin(3 * Mp + M)
        + 0.00002 * sin(4 * Mp);

      // Additional planetary term W, specific to full moon (Meeus §49)
      final W = 0.00306
          - 0.00038 * E * cos(M)
          + 0.00026 * cos(Mp)
          - 0.00002 * cos(Mp - M)
          + 0.00002 * cos(Mp + M)
          + 0.00002 * cos(2 * F);
      JDE += W;
    }

    return JDE;
  }

  // ─── Public navigation API ────────────────────────────────────────────────

  /// The most recent full moon at or before this moment.
  LunarTimeUnit previousFullMoon() {
    final thisJDE = _msToJDE(epochMilliseconds);
    int kInt = (_kContinuous() - 0.5).floor();
    double jde = _phaseJDE(kInt, fullMoon: true);
    if (jde > thisJDE) {
      jde = _phaseJDE(--kInt, fullMoon: true);
    }
    return LunarTimeUnit(_jdeToMs(jde));
  }

  /// The next full moon strictly after this moment.
  LunarTimeUnit nextFullMoon() {
    final thisJDE = _msToJDE(epochMilliseconds);
    int kInt = (_kContinuous() - 0.5).ceil();
    double jde = _phaseJDE(kInt, fullMoon: true);
    if (jde <= thisJDE) {
      jde = _phaseJDE(++kInt, fullMoon: true);
    }
    return LunarTimeUnit(_jdeToMs(jde));
  }

  /// The most recent new moon at or before this moment.
  LunarTimeUnit previousNewMoon() {
    final thisJDE = _msToJDE(epochMilliseconds);
    int kInt = _kContinuous().floor();
    double jde = _phaseJDE(kInt, fullMoon: false);
    if (jde > thisJDE) {
      jde = _phaseJDE(--kInt, fullMoon: false);
    }
    return LunarTimeUnit(_jdeToMs(jde));
  }

  /// The next new moon strictly after this moment.
  LunarTimeUnit nextNewMoon() {
    final thisJDE = _msToJDE(epochMilliseconds);
    int kInt = _kContinuous().ceil();
    double jde = _phaseJDE(kInt, fullMoon: false);
    if (jde <= thisJDE) {
      jde = _phaseJDE(++kInt, fullMoon: false);
    }
    return LunarTimeUnit(_jdeToMs(jde));
  }

  // ─── Derived time properties ──────────────────────────────────────────────

  /// Fractional days elapsed since the most recent full moon.
  ///
  /// 0.0 at a full moon, ~29.5 just before the next full moon.
  double get moonAge {
    final prev = previousFullMoon();
    return (epochMilliseconds - prev.epochMilliseconds) / 86400000.0;
  }

  /// Fractional days elapsed since the most recent new moon.
  ///
  /// 0.0 at a new moon, ~29.5 just before the next new moon.
  double get daysSinceNewMoon {
    final prev = previousNewMoon();
    return (epochMilliseconds - prev.epochMilliseconds) / 86400000.0;
  }

  /// Sequential full-moon number, 1-based from the 12TRA reference epoch.
  ///
  /// The reference is the full moon of **2017-07-09 ~04:07 UTC**
  /// (Meeus k-integer 216), so moonNumber == 1 on that date and
  /// increments with every subsequent full moon — matching the
  /// historical [FullMoonBasedLayer] numbering.
  int get moonNumber {
    // kInt of the 12TRA reference full moon ≈ 2017-07-09 04:07 UTC
    const int kRefInt = 216;
    final kNowInt = (_kContinuous() - 0.5).floor();
    return (kNowInt - kRefInt + 1).clamp(1, 999999);
  }

  /// [DateTime] representation of this unit in UTC.
  DateTime get dateTime =>
      DateTime.fromMillisecondsSinceEpoch(epochMilliseconds, isUtc: true);
}
