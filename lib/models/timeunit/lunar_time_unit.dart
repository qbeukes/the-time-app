import '../moment.dart';

/// Abstract interface for lunar phase computations.
///
/// Implementations provide the astronomical algorithms to compute
/// new-moon and full-moon instants. Consumers should depend on this
/// interface rather than any concrete implementation.
abstract class LunarTimeUnit extends Moment {
  const LunarTimeUnit(super.epochMilliseconds);

  // ── Phase navigation ────────────────────────────────────────────
  LunarTimeUnit previousFullMoon();
  LunarTimeUnit nextFullMoon();
  LunarTimeUnit previousNewMoon();
  LunarTimeUnit nextNewMoon();

  // ── Derived properties ──────────────────────────────────────────

  /// Fractional days since the most recent full moon.
  double get moonAge;

  /// Fractional days since the most recent new moon.
  double get daysSinceNewMoon;

  /// The universal full-moon counter, anchored to an epoch offset.
  int get fullMoonIndex;

  /// UTC DateTime for this moment.
  DateTime get dateTime;
}
