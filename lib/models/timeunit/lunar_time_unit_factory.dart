import 'lunar_time_unit.dart';
import 'meeus_lunar_time_unit.dart';

/// Available lunar computation algorithms.
enum LunarAlgorithm {
  /// Jean Meeus "Astronomical Algorithms" Chapter 49.
  /// Accurate to within seconds over centuries.
  meeus,
}

/// Factory for creating [LunarTimeUnit] instances using a specific algorithm.
class LunarTimeUnitFactory {
  final LunarAlgorithm algorithm;

  const LunarTimeUnitFactory({this.algorithm = LunarAlgorithm.meeus});

  /// Create a [LunarTimeUnit] from epoch milliseconds.
  LunarTimeUnit create(int epochMilliseconds) {
    switch (algorithm) {
      case LunarAlgorithm.meeus:
        return MeeusLunarTimeUnit(epochMilliseconds);
    }
  }

  /// Create a [LunarTimeUnit] for the current moment.
  LunarTimeUnit now() => create(DateTime.now().millisecondsSinceEpoch);

  /// Create a [LunarTimeUnit] from a [DateTime].
  LunarTimeUnit fromDateTime(DateTime dt) => create(dt.millisecondsSinceEpoch);
}
