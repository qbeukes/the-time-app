import 'lunar_time_layer.dart';

class NewMoonBasedLayer extends LunarTimeLayer {
  const NewMoonBasedLayer(super.moment);

  @override
  DateTime getLunarEpoch() {
    return DateTime.utc(2026, 4, 17);
  }
}
