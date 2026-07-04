import 'package:the_time_app/models/lunar/full_moon_based_layer.dart';
import 'package:the_time_app/models/timeunit/lunar_time_unit.dart';
import 'luach_interpreter.dart';
import 'luach_metadata.dart';

class LuachLayer extends FullMoonBasedLayer {
  LuachLayer(LunarTimeUnit super.moment) {
    LuachInterpreter().loadIfNeeded();
  }

  // ─── Named moon from dates.txt ────────────────────────────────────────────

  /// Returns the current named LuachMoon from the dates.txt data file.
  LuachMoon? get currentMoon {
    final interpreter = LuachInterpreter();
    if (!interpreter.isLoaded) return null;
    return interpreter.getMoonForMoment(moment);
  }

  /// Returns the metadata for the current moon's number (1-13).
  LuachMoonMetadata? get currentMetadata {
    final moon = currentMoon;
    if (moon == null) return null;
    return LuachMoonMetadata.getByNumber(moon.moonNumberInYear);
  }

  // ─── Time via LunarTimeUnit ───────────────────────────────────────────────

  /// Integer day within the current moon cycle, measured from the full moon
  /// (Meeus accuracy) — matches the 12TRA reference point.
  int get dayOfMoon => unit.moonAge.floor();

  /// Macro-phase index (0–3) within the current moon:
  ///   0 = East · 1 = South · 2 = West · 3 = North
  ///
  /// Parallel to 12TRA — both measure from the full moon.
  int get macroPhaseIndex {
    const quarterLength = 29.53059 / 4.0;
    return (unit.moonAge / quarterLength).floor().clamp(0, 3);
  }

  /// Progress (0.0–1.0) through the current cardinal quarter.
  ///
  /// Fractional days give continuous, second-level precision.
  double get macroPhaseProgress {
    const quarterLength = 29.53059 / 4.0;
    final dayInCycle = unit.moonAge % quarterLength;
    return (dayInCycle / quarterLength).clamp(0.0, 1.0);
  }

  @override
  String toDisplayValue() {
    final moon = currentMoon;
    final meta = currentMetadata;

    if (moon == null) {
      return 'Loading Luach data...';
    }

    final metadataString = meta != null
        ? '\nDirection: ${meta.direction}\nGemstone: ${meta.gemstone}'
        : '';

    return '${moon.name}\n'
        'Moon ${moon.moonNumberInYear} in year of ${moon.yearType}\n'
        'Day $dayOfMoon$metadataString';
  }
}
