import 'time_layer.dart';

/// Represents a specific moment in time since the unix epoch (1970-01-01).
class Moment {
  final int epochMilliseconds;

  const Moment(this.epochMilliseconds);

  factory Moment.now() {
    return Moment(DateTime.now().millisecondsSinceEpoch);
  }

  /// Outputs the date according to how that time represents in that epoch moment,
  /// interpreted through a specific [TimeLayer].
  String toDisplayValue(TimeLayer Function(Moment) layerBuilder) {
    final layer = layerBuilder(this);
    return layer.toDisplayValue();
  }
}
