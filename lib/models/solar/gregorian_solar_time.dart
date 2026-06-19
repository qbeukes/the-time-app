import 'solar_time.dart';

/// Gregorian implementation of SolarTime with rich date/time accessors.
class GregorianSolarTime extends SolarTime {
  const GregorianSolarTime(super.moment);

  DateTime get _dateTime => DateTime.fromMillisecondsSinceEpoch(
        moment.epochMilliseconds,
      );

  @override
  int get dayOfYear {
    final dt = _dateTime;
    final startOfYear = DateTime(dt.year, 1, 1);
    return dt.difference(startOfYear).inDays + 1;
  }

  int get year => _dateTime.year;
  int get month => _dateTime.month;
  int get day => _dateTime.day;
  int get hour => _dateTime.hour;
  int get minute => _dateTime.minute;
  int get second => _dateTime.second;
  int get weekday => _dateTime.weekday; // 1=Monday … 7=Sunday

  bool get isLeapYear {
    final y = year;
    return (y % 4 == 0 && y % 100 != 0) || y % 400 == 0;
  }

  int get daysInYear => isLeapYear ? 366 : 365;

  static const _weekdayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  String get weekdayName => _weekdayNames[weekday - 1];
  String get monthName => _monthNames[month - 1];

  /// Formatted time string "HH:MM:SS"
  String get formattedTime =>
      '${hour.toString().padLeft(2, '0')}:'
      '${minute.toString().padLeft(2, '0')}:'
      '${second.toString().padLeft(2, '0')}';

  /// Formatted date string "Wednesday, 17 June 2026"
  String get formattedDate => '$weekdayName, $day $monthName $year';

  /// Formatted timezone offset and timezone abbreviation (e.g. "UTC+02:00 (SAST)")
  String get timeZoneHeader {
    final offset = _dateTime.timeZoneOffset;
    final hours = offset.inHours.abs().toString().padLeft(2, '0');
    final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
    final sign = offset.isNegative ? '-' : '+';
    final tzName = _dateTime.timeZoneName;
    return 'UTC$sign$hours:$minutes ($tzName)';
  }

  @override
  String toDisplayValue() {
    return '$formattedDate — $formattedTime';
  }
}
