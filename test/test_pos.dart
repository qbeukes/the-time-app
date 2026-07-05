import 'package:apsl_sun_calc/apsl_sun_calc.dart';

void main() {
  final now = DateTime.now();
  final lat = 51.5; // London
  final lng = -0.1;

  final illum = SunCalc.getMoonIllumination(now);
  final pos = SunCalc.getMoonPosition(now, lat, lng);
  
  print('Illum: $illum');
  print('Pos: $pos');
}
