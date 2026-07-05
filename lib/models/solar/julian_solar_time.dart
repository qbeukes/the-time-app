import 'solar_time.dart';

/// Julian implementation of SolarTime with rich date/time accessors.
class JulianSolarTime extends SolarTime {
  const JulianSolarTime(super.moment);

  DateTime get _dateTime => DateTime.fromMillisecondsSinceEpoch(
        moment.epochMilliseconds,
      );

  // Helper method to convert the Gregorian _dateTime into JDN
  int get _jdn {
    final dt = _dateTime;
    final y = dt.year;
    final m = dt.month;
    final d = dt.day;

    final a = (14 - m) ~/ 12;
    final y2 = y + 4800 - a;
    final m2 = m + 12 * a - 3;
    return d +
        ((153 * m2 + 2) ~/ 5) +
        365 * y2 +
        (y2 ~/ 4) -
        (y2 ~/ 100) +
        (y2 ~/ 400) -
        32045;
  }

  // Gets the Julian Year, Month, and Day as a List [year, month, day]
  List<int> get _julianDate {
    final c = _jdn + 32082;
    final d2 = (4 * c + 3) ~/ 1461;
    final e = c - (1461 * d2) ~/ 4;
    final m3 = (5 * e + 2) ~/ 153;

    final d = e - (153 * m3 + 2) ~/ 5 + 1;
    final m = m3 + 3 - 12 * (m3 ~/ 10);
    final y = d2 - 4800 + (m3 ~/ 10);

    return [y, m, d];
  }

  int get year => _julianDate[0];
  int get month => _julianDate[1];
  int get day => _julianDate[2];

  @override
  int get dayOfYear {
    final y = year;
    // JDN of Jan 1st of the current Julian year:
    final a = (14 - 1) ~/ 12; // 1
    final y2 = y + 4800 - a; // y + 4799
    final m2 = 1 + 12 * a - 3; // 10
    // JDN formula for Julian calendar:
    final jdnJan1 = 1 + ((153 * m2 + 2) ~/ 5) + 365 * y2 + (y2 ~/ 4) - 32083;
    return _jdn - jdnJan1 + 1;
  }

  int get hour => _dateTime.hour;
  int get minute => _dateTime.minute;
  int get second => _dateTime.second;
  int get weekday => (_jdn % 7) + 1; // 1=Monday … 7=Sunday

  bool get isLeapYear {
    return year % 4 == 0;
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

  @override
  String toDisplayValue() {
    return '$formattedDate — $formattedTime';
  }
}
