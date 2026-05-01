import '../time_layer.dart';

/// Lunar time layer.
abstract class LunarTimeLayer extends TimeLayer {
  const LunarTimeLayer(super.moment);

  DateTime getLunarEpoch();

  double get moonAge {
    final daysSinceFirstMoon = _dateSinceLunarEpoch();
    const lunarCycleLength = 29.53059;
    return daysSinceFirstMoon % lunarCycleLength;
  }

  int get moonNumber {
    final daysSinceLunarEpoch = _dateSinceLunarEpoch();
    const lunarCycleLength = 29.53059;
    return (daysSinceLunarEpoch / lunarCycleLength).floor() + 1;
  }

  double _dateSinceLunarEpoch() {
    return _secondsSinceLunarEpoch() / 86400.0;
  }

  int _secondsSinceLunarEpoch() {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(
      moment.epochMilliseconds,
      isUtc: true,
    );

    final lunarEpoch = getLunarEpoch();

    return dateTime.difference(lunarEpoch).inSeconds;
  }

  @override
  String toDisplayValue() {
    return 'Moon Number: $moonNumber\nMoon Age: ${moonAge.toStringAsFixed(2)} days';
  }
}
