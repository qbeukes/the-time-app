import 'package:the_time_app/models/timeunit/lunar_time_unit.dart';
import 'package:the_time_app/models/lunar/luach/luach_interpreter.dart';
import '../time_layer.dart';

/// Base class for all lunar time layers.
///
/// Requires a [LunarTimeUnit] as its moment — all time-related
/// decisions are delegated to the unit's Jean Meeus calculations.
abstract class LunarTimeLayer extends TimeLayer {
  const LunarTimeLayer(LunarTimeUnit super.moment);

  /// The [LunarTimeUnit] powering this layer.
  LunarTimeUnit get unit => moment as LunarTimeUnit;

  /// Fractional days since the most recent full moon (Meeus accuracy).
  double get moonAge => unit.moonAge;

  /// Integer day within the current moon cycle, measured from the full moon.
  int get dayOfMoon => moonAge.floor();

  /// Sequential full-moon number from J2000 (January 1, 2000).
  ///
  /// This is a universal counter anchored to the standard astronomical epoch.
  /// The full moon nearest to J2000 is moon number 1.
  int get sequentialMoonNumber {
    // J2000 corresponds to Meeus full-moon index 0
    return (unit.fullMoonIndex + 1).clamp(1, 999999999);
  }

  /// The pure mathematical month within the 12TRA cycle (1–13).
  ///
  /// This calculates the month based on the 19-year Metonic cycle, ensuring
  /// that leap moons (month 13) are mathematically inserted to stay aligned
  /// with solar seasons without relying on Luach calendar data.
  int get traMonthInYear {
    // 276 is the sequentialMoonNumber for 2022-04-17 (Start of Year 1)
    int offset = (sequentialMoonNumber - 276) % 235;
    if (offset < 0) offset += 235;

    const leapYears = {3, 6, 8, 11, 14, 17, 19};
    int moonCount = 0;

    for (int y = 1; y <= 19; y++) {
      int moonsThisYear = leapYears.contains(y) ? 13 : 12;
      if (offset < moonCount + moonsThisYear) {
        return offset - moonCount + 1;
      }
      moonCount += moonsThisYear;
    }
    return 1;
  }

  /// The Metonic cycle year (1–19).
  int get traMetonicYear {
    int offset = (sequentialMoonNumber - 276) % 235;
    if (offset < 0) offset += 235;

    const leapYears = {3, 6, 8, 11, 14, 17, 19};
    int moonCount = 0;

    for (int y = 1; y <= 19; y++) {
      int moonsThisYear = leapYears.contains(y) ? 13 : 12;
      if (offset < moonCount + moonsThisYear) {
        return y;
      }
      moonCount += moonsThisYear;
    }
    return 1;
  }

  /// The moon's positional number (1–13) within the current Luach year.
  ///
  /// Delegates to [LuachInterpreter] which parses dates.txt to determine
  /// which Luach year we're in and which moon position this is.
  /// Returns 0 if Luach data is not yet loaded.
  int get luachMoonNumberInYear {
    final interpreter = LuachInterpreter();
    if (!interpreter.isLoaded) return 0;
    final moon = interpreter.getMoonForMoment(moment);
    return moon?.moonNumberInYear ?? 0;
  }

  /// The Luach year type label (e.g. "Wisdom", "Understanding", "Knowledge").
  ///
  /// Returns null if Luach data is not yet loaded.
  String? get lunarYearType {
    final interpreter = LuachInterpreter();
    if (!interpreter.isLoaded) return null;
    final moon = interpreter.getMoonForMoment(moment);
    return moon?.yearType;
  }

  @override
  String toDisplayValue() {
    return 'Moon Number: $sequentialMoonNumber\nMoon Age: ${moonAge.toStringAsFixed(2)} days';
  }
}
