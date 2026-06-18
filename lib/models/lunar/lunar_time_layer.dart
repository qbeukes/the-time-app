import 'package:the_time_app/models/lunar/lunar_time_unit.dart';
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

  /// Sequential full-moon number from the 12TRA reference epoch.
  int get moonNumber => unit.moonNumber;

  @override
  String toDisplayValue() {
    return 'Moon Number: $moonNumber\nMoon Age: ${moonAge.toStringAsFixed(2)} days';
  }
}
