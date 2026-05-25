import 'lunar_time_layer.dart';

class NewMoonBasedLayer extends LunarTimeLayer {
  const NewMoonBasedLayer(super.moment);

  @override
  DateTime getLunarEpoch() {
    return DateTime.utc(2017, 6, 24, 02, 31, 0);
  }
}
