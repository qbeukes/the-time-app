import 'lunar_time_layer.dart';

class FullMoonBasedLayer extends LunarTimeLayer {
  const FullMoonBasedLayer(super.moment);

  @override
  DateTime getLunarEpoch() {
    return DateTime.utc(2026, 4, 3);
  }
}
