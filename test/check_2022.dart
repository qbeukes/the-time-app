import 'package:the_time_app/models/timeunit/lunar_time_unit_factory.dart';

void main() {
  final dt = DateTime.utc(2022, 4, 17);
  final factory = LunarTimeUnitFactory();
  final unit = factory.fromDateTime(dt);
  
  int seqMoon = unit.fullMoonIndex + 1;
  print('Sequential Moon for 2022-04-17: ' + seqMoon.toString());
}
