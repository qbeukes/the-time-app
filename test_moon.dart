import 'package:apsl_sun_calc/apsl_sun_calc.dart';

void main() {
  final now = DateTime.now();
  final illumination = SunCalc.getMoonIllumination(now);
  print(illumination);
}
