import 'moment.dart';

/// Abstract base class for time layers that interpret a Moment.
abstract class TimeLayer {
  final Moment moment;

  const TimeLayer(this.moment);

  /// Outputs the formatted date for this layer.
  String toDisplayValue();
}
