import 'solar_time.dart';

/// Enochian solar calendar: 13 months × 28 days = 364 days.
///
/// The first 364 days of the Gregorian year map directly to the
/// Enochian grid (Month 1 Day 1 through Month 13 Day 28).
///
/// Day 365 is always a "Day out of Time".
/// Day 366 (leap years only) is a second "Day out of Time".
///
/// The Enochian calendar has no daytime element — just the date.
class EnochianSolarTime extends SolarTime {
  const EnochianSolarTime(super.moment);

  DateTime get _dateTime => DateTime.fromMillisecondsSinceEpoch(
        moment.epochMilliseconds,
        isUtc: true,
      );

  /// Whether the current year is a Gregorian leap year.
  bool get isLeapYear {
    final y = _dateTime.year;
    return (y % 4 == 0 && y % 100 != 0) || y % 400 == 0;
  }

  /// The Gregorian day-of-year (1-indexed).
  @override
  int get dayOfYear {
    final dt = _dateTime;
    final startOfYear = DateTime.utc(dt.year, 1, 1);
    return dt.difference(startOfYear).inDays + 1;
  }

  /// Whether this date falls outside the 364-day Enochian grid.
  bool get isOutOfTime => dayOfYear > 364;

  /// The "Day out of Time" number (1 or 2), or 0 if not out of time.
  ///
  /// Day 365 = Day out of Time 1 (every year).
  /// Day 366 = Day out of Time 2 (leap years only).
  int get outOfTimeDayNumber {
    if (!isOutOfTime) return 0;
    return dayOfYear - 364;
  }

  /// Total number of Days out of Time this year.
  int get totalOutOfTimeDays => isLeapYear ? 2 : 1;

  /// The Enochian day number within the 364-day grid (1–364),
  /// or -1 if this date is a Day out of Time.
  int get enochianDayOfYear {
    if (isOutOfTime) return -1;
    return dayOfYear;
  }

  /// The Enochian month (1–13), or -1 if Day out of Time.
  int get enochianMonth {
    final ed = enochianDayOfYear;
    if (ed < 0) return -1;
    return ((ed - 1) ~/ 28) + 1;
  }

  /// The day within the Enochian month (1–28), or -1 if Day out of Time.
  int get enochianDay {
    final ed = enochianDayOfYear;
    if (ed < 0) return -1;
    final rem = ed % 28;
    return rem == 0 ? 28 : rem;
  }

  /// Progress through the current Enochian month (0.0 – 1.0).
  double get monthProgress {
    final d = enochianDay;
    if (d < 0) return 0.0;
    return d / 28.0;
  }

  /// Progress through the Enochian year (0.0 – 1.0), based on 364 days.
  double get yearProgress {
    final ed = enochianDayOfYear;
    if (ed < 0) return 1.0; // Days out of Time are past the grid
    return ed / 364.0;
  }

  @override
  String toDisplayValue() {
    if (isOutOfTime) {
      return 'Day out of Time${totalOutOfTimeDays > 1 ? ' ($outOfTimeDayNumber of $totalOutOfTimeDays)' : ''}';
    }
    return 'Month $enochianMonth, Day $enochianDay';
  }
}
