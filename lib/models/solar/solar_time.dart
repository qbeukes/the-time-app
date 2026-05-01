import '../time_layer.dart';

/// Solar time layer representing the day of the solar year.
abstract class SolarTime extends TimeLayer {
  const SolarTime(super.moment);

  /// The calculated day of the solar year.
  int get dayOfYear;
}
