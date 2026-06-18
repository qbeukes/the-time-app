import 'package:the_time_app/models/lunar/lunar_time_unit.dart';
import 'lunar_time_layer.dart';

/// A lunar layer anchored to new moons.
///
/// [moonAge] here represents days since the previous **new** moon
/// (overrides the full-moon default from [LunarTimeLayer]).
class NewMoonBasedLayer extends LunarTimeLayer {
  const NewMoonBasedLayer(LunarTimeUnit super.moment);

  /// Days since the previous new moon (0 at new moon).
  @override
  double get moonAge => unit.daysSinceNewMoon;

  @override
  String toDisplayValue() {
    final prevNew = unit.previousNewMoon().dateTime;
    final nextNew = unit.nextNewMoon().dateTime;
    return 'Days Since New Moon: ${moonAge.toStringAsFixed(2)}\n'
        'Prev New: ${prevNew.toIso8601String().substring(0, 16)} UTC\n'
        'Next New: ${nextNew.toIso8601String().substring(0, 16)} UTC';
  }
}
