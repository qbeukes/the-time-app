import 'solar_time.dart';

/// Gregorian implementation of SolarTime.
class GregorianSolarTime extends SolarTime {
  const GregorianSolarTime(super.moment);

  @override
  int get dayOfYear {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(
      moment.epochMilliseconds,
      isUtc: true, // Using UTC for standardized calculation
    );
    final startOfYear = DateTime.utc(dateTime.year, 1, 1);
    // +1 because January 1st is day 1, not day 0
    return dateTime.difference(startOfYear).inDays + 1;
  }

  @override
  String toDisplayValue() {
    return 'Gregorian Day: $dayOfYear';
  }
}
