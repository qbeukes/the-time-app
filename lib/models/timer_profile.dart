/// A meditation timer profile.
/// [bellAtSeconds] is a sorted list of moments (in seconds from start) when
/// a bell sound should ring. E.g. [0, 300] means bell at start and at 5 min.
class TimerProfile {
  final String id;
  String name;
  List<int> bellAtSeconds; // sorted, seconds from start

  TimerProfile({
    required this.id,
    required this.name,
    required this.bellAtSeconds,
  });

  TimerProfile copyWith({
    String? id,
    String? name,
    List<int>? bellAtSeconds,
  }) {
    return TimerProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      bellAtSeconds:
          bellAtSeconds != null ? List<int>.from(bellAtSeconds) : List<int>.from(this.bellAtSeconds),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'bellAtSeconds': bellAtSeconds,
      };

  factory TimerProfile.fromJson(Map<String, dynamic> json) {
    return TimerProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      bellAtSeconds: List<int>.from(json['bellAtSeconds'] as List? ?? []),
    );
  }

  static List<TimerProfile> get defaults => [
        TimerProfile(
          id: 'default_open',
          name: 'Open Space',
          bellAtSeconds: [],
        ),
        TimerProfile(
          id: 'default_intervals',
          name: '5 Min Interval',
          bellAtSeconds: [0, 300, 600, 900],
        ),
        TimerProfile(
          id: 'default_zen',
          name: 'Zen Sit',
          bellAtSeconds: [0, 60, 180, 300, 600],
        ),
      ];
}
