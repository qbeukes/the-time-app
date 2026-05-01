import '../lunar_moment.dart';

/// A local library for calculating approximate lunar phases based on the mean synodic month.
class LunarCalculator {
  // Mean synodic month in milliseconds: 29.53058770576 days
  static const double _lunarCycleMs = 29.53058770576 * 24 * 60 * 60 * 1000;
  
  // A known New Moon epoch: 2000-01-06 18:14:00 UTC
  // Epoch calculated exactly: 947182440000 ms
  static const int _knownNewMoonEpochMs = 947182440000;

  static LunarMoment findPreviousNewMoon(LunarMoment moment) {
    final diffMs = moment.epochMilliseconds - _knownNewMoonEpochMs;
    final cycles = diffMs / _lunarCycleMs;
    final previousCycles = cycles.floor();
    final ms = _knownNewMoonEpochMs + (previousCycles * _lunarCycleMs).round();
    return LunarMoment(ms);
  }

  static LunarMoment findNextNewMoon(LunarMoment moment) {
    final diffMs = moment.epochMilliseconds - _knownNewMoonEpochMs;
    final cycles = diffMs / _lunarCycleMs;
    final nextCycles = cycles.ceil();
    final ms = _knownNewMoonEpochMs + (nextCycles * _lunarCycleMs).round();
    return LunarMoment(ms);
  }

  static LunarMoment findPreviousFullMoon(LunarMoment moment) {
    // Full moon is exactly half a cycle ahead of new moon
    final halfCycle = _lunarCycleMs / 2;
    // Shift epoch back by half a cycle so that full moons act like new moons
    final knownFullMoonEpoch = _knownNewMoonEpochMs + halfCycle;
    
    final diffMs = moment.epochMilliseconds - knownFullMoonEpoch;
    final cycles = diffMs / _lunarCycleMs;
    final previousCycles = cycles.floor();
    final ms = knownFullMoonEpoch + (previousCycles * _lunarCycleMs);
    return LunarMoment(ms.round());
  }

  static LunarMoment findNextFullMoon(LunarMoment moment) {
    final halfCycle = _lunarCycleMs / 2;
    final knownFullMoonEpoch = _knownNewMoonEpochMs + halfCycle;
    
    final diffMs = moment.epochMilliseconds - knownFullMoonEpoch;
    final cycles = diffMs / _lunarCycleMs;
    final nextCycles = cycles.ceil();
    final ms = knownFullMoonEpoch + (nextCycles * _lunarCycleMs);
    return LunarMoment(ms.round());
  }
}
