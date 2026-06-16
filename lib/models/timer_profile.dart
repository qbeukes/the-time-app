/// A meditation timer profile.
/// [bellAtSeconds] is a sorted list of moments (in seconds from start) when
/// a bell sound should ring. E.g. [0, 300] means bell at start and at 5 min.
class TimerProfile {
  final String id;
  String name;
  int durationSeconds;
  List<int> bellAtSeconds; // sorted, seconds from start

  TimerProfile({
    required this.id,
    required this.name,
    required this.durationSeconds,
    required this.bellAtSeconds,
  });

  TimerProfile copyWith({
    String? id,
    String? name,
    int? durationSeconds,
    List<int>? bellAtSeconds,
  }) {
    return TimerProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      bellAtSeconds:
          bellAtSeconds != null ? List<int>.from(bellAtSeconds) : List<int>.from(this.bellAtSeconds),
    );
  }

  String get durationLabel {
    final m = durationSeconds ~/ 60;
    final s = durationSeconds % 60;
    if (s == 0) return '${m}m';
    return '${m}m ${s}s';
  }

  static List<TimerProfile> get defaults => [
        TimerProfile(
          id: 'default_simple',
          name: 'Simple',
          durationSeconds: 300,
          bellAtSeconds: [0, 300],
        ),
        TimerProfile(
          id: 'default_breath',
          name: 'Breath Cycles',
          durationSeconds: 900,
          bellAtSeconds: [0, 300, 600, 900],
        ),
        TimerProfile(
          id: 'default_deep',
          name: 'Deep 20',
          durationSeconds: 1200,
          bellAtSeconds: [0, 600, 1200],
        ),
      ];
}
