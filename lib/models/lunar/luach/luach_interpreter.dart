import 'package:flutter/services.dart' show rootBundle;
import 'package:inner_time/models/moment.dart';

class LuachMoon {
  final String name;
  final DateTime date;
  final String yearType;
  final int moonNumberInYear;

  LuachMoon({
    required this.name,
    required this.date,
    required this.yearType,
    required this.moonNumberInYear,
  });
}

class LuachInterpreter {
  static final LuachInterpreter _instance = LuachInterpreter._internal();

  factory LuachInterpreter() {
    return _instance;
  }

  LuachInterpreter._internal();

  bool _isLoaded = false;
  Future<void>? _loadFuture;
  final List<LuachMoon> _moons = [];

  bool get isLoaded => _isLoaded;

  Future<void> loadIfNeeded() {
    if (_isLoaded) return Future.value();
    if (_loadFuture != null) return _loadFuture!;

    _loadFuture = _loadAsync();
    return _loadFuture!;
  }

  Future<void> _loadAsync() async {
    try {
      final contents = await rootBundle.loadString(
        'assets/time/luach/dates.txt',
      );
      _parseContents(contents);
      _isLoaded = true;
    } catch (e) {
      print('Error loading dates.txt: $e');
    } finally {
      _loadFuture = null;
    }
  }

  void _parseContents(String contents) {
    _moons.clear();
    final lines = contents.split('\n');
    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      final parts = line.split(',');
      if (parts.length >= 3) {
        final name = parts[0].trim();
        final dateStr = parts[1].trim();
        final yearType = parts[2].trim();

        final date = DateTime.tryParse(dateStr);
        if (date != null) {
          final moonNumberInYear = _getMoonNumberFromName(name);
          _moons.add(LuachMoon(
            name: name,
            date: date,
            yearType: yearType,
            moonNumberInYear: moonNumberInYear,
          ));
        }
      }
    }
    _moons.sort((a, b) => a.date.compareTo(b.date));
  }

  LuachMoon? getMoonByNumber(int moonNumber) {
    final index = moonNumber - 1;
    if (index >= 0 && index < _moons.length) {
      return _moons[index];
    }
    return null;
  }

  LuachMoon? getMoonForMoment(Moment moment) {
    if (_moons.isEmpty) return null;

    final momentDate = DateTime.fromMillisecondsSinceEpoch(
      moment.epochMilliseconds,
      isUtc: true,
    );

    LuachMoon? currentMoon;
    for (final moon in _moons) {
      final moonDateUtc = DateTime.utc(
        moon.date.year,
        moon.date.month,
        moon.date.day,
      );

      if (moonDateUtc.isBefore(momentDate) ||
          moonDateUtc.isAtSameMomentAs(momentDate)) {
        currentMoon = moon;
      } else {
        break;
      }
    }

    // Fallback to the first moon if the moment is before our earliest recorded date
    return currentMoon ?? _moons.first;
  }

  int _getMoonNumberFromName(String name) {
    final n = name.toLowerCase().trim();
    if (n.contains('yahúdah')) return 1;
    if (n.contains('yishshakkar')) return 2;
    if (n.contains('zebúwlan')) return 3;
    if (n.contains('raúwaben')) return 4;
    if (n.contains('shamoúnn')) return 5;
    if (n.contains('gad')) return 6;
    if (n.contains('aparryim')) return 7;
    if (n.contains('maneshayh') || n.contains('manashayh')) return 8;
    if (n.contains('beniyman')) return 9;
    if (n.contains('dan')) return 10;
    if (n.contains('ayshshur')) return 11;
    if (n.contains('nephetli')) return 12;
    if (n.contains('berúwkah')) return 13;
    return 0; // Unknown
  }
}
