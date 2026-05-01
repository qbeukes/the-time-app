import 'solar_time.dart';

/// Enochian implementation of SolarTime.
class EnochianSolarTime extends SolarTime {
  const EnochianSolarTime(super.moment);

  @override
  int get dayOfYear {
    // TODO: Implement actual Enochian solar year calculation.
    // For now, mirroring Gregorian calculation as a placeholder.
    final dateTime = DateTime.fromMillisecondsSinceEpoch(
      moment.epochMilliseconds,
      isUtc: true,
    );
    final startOfYear = DateTime.utc(dateTime.year, 1, 1);
    return dateTime.difference(startOfYear).inDays + 1;
  }

  @override
  String toDisplayValue() {
    return 'Enochian Day: $dayOfYear';
  }
}
