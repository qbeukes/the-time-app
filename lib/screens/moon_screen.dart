import 'package:flutter/material.dart';
import 'package:inner_time/models/lunar/full_moon_based_layer.dart';
import 'package:inner_time/models/lunar/new_moon_based_layer.dart';
import 'package:inner_time/models/lunar/lunar_moment.dart';
import 'package:apsl_sun_calc/apsl_sun_calc.dart';
import '../widgets/stylized_moon.dart';

class MoonScreen extends StatelessWidget {
  final DateTime date;

  const MoonScreen({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final moment = LunarMoment(date.millisecondsSinceEpoch);
    final illumination = SunCalc.getMoonIllumination(date);
    final currentPhase = illumination['phase']?.toDouble() ?? 0.0;
    final fraction = illumination['fraction']?.toDouble() ?? 0.0;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StylizedMoon(
            phase: currentPhase,
            size: 180,
          ),
          
          const SizedBox(height: 10),
          Text(
            '${(fraction * 100).toStringAsFixed(1)}% Illuminated',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 20),
          Text(
            'Date: ${date.toLocal().toString().split(' ')[0]}',
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),

          const SizedBox(height: 30),
          const Text(
            'Full Moon Base',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.amber,
            ),
          ),

          const SizedBox(height: 8),
          Text(
            moment.toDisplayValue(FullMoonBasedLayer.new),
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 30),
          const Text(
            'New Moon Base',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.blueAccent,
            ),
          ),

          const SizedBox(height: 8),
          Text(
            moment.toDisplayValue(NewMoonBasedLayer.new),
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
