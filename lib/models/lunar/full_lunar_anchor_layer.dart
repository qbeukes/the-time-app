import 'package:the_time_app/models/timeunit/lunar_time_unit.dart';
import 'lunar_time_layer.dart';

/// A lunar layer anchored to full moons.
///
/// [moonAge] measures days since the previous full moon (0 at full moon).
/// [sequentialMoonNumber] counts full moons from Julian Day 0.
class FullLunarAnchorLayer extends LunarTimeLayer {
  const FullLunarAnchorLayer(LunarTimeUnit super.moment);

  @override
  String toDisplayValue() {
    final prevFull = unit.previousFullMoon().dateTime;
    final nextFull = unit.nextFullMoon().dateTime;
    return 'Moon Number: $sequentialMoonNumber\n'
        'Moon Age: ${moonAge.toStringAsFixed(2)} days\n'
        'Prev Full: ${prevFull.toIso8601String().substring(0, 16)} UTC\n'
        'Next Full: ${nextFull.toIso8601String().substring(0, 16)} UTC';
  }
}
