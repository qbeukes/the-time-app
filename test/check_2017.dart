import 'package:the_time_app/models/timeunit/lunar_time_unit_factory.dart';
import 'package:the_time_app/models/lunar/lunar_time_layer.dart';
import 'package:the_time_app/models/timeunit/lunar_time_unit.dart';

class TestLayer extends LunarTimeLayer {
  TestLayer(LunarTimeUnit super.moment);
  @override
  String toDisplayValue() => '';
}

void main() {
  final dt = DateTime.utc(2017, 7, 10);
  final factory = LunarTimeUnitFactory();
  final unit = factory.fromDateTime(dt);
  final layer = TestLayer(unit);
  
  print('Date: \${dt.toIso8601String()}');
  print('Sequential Moon Number: \${layer.sequentialMoonNumber}');
  print('TRA Month In Year: \${layer.traMonthInYear}');
}
