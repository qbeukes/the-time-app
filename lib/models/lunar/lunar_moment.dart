import '../moment.dart';
import 'lunar_calc/lunar_calculator.dart';

class LunarMoment extends Moment {
  const LunarMoment(super.epochMilliseconds);

  factory LunarMoment.fromMoment(Moment moment) {
    return LunarMoment(moment.epochMilliseconds);
  }

  factory LunarMoment.now() {
    return LunarMoment(DateTime.now().millisecondsSinceEpoch);
  }

  /// Returns the LunarMoment of the new moon that immediately precedes this moment.
  LunarMoment previousNewMoon() {
    return LunarCalculator.findPreviousNewMoon(this);
  }

  /// Returns the LunarMoment of the full moon that immediately precedes this moment.
  LunarMoment previousFullMoon() {
    return LunarCalculator.findPreviousFullMoon(this);
  }

  /// Returns the LunarMoment of the new moon that immediately follows this moment.
  LunarMoment nextNewMoon() {
    return LunarCalculator.findNextNewMoon(this);
  }

  /// Returns the LunarMoment of the full moon that immediately follows this moment.
  LunarMoment nextFullMoon() {
    return LunarCalculator.findNextFullMoon(this);
  }
}
