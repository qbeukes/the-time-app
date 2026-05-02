import 'package:flutter/material.dart';
import 'package:inner_time/models/lunar/full_moon_based_layer.dart';
import 'package:inner_time/models/lunar/new_moon_based_layer.dart';
import 'package:inner_time/models/lunar/lunar_moment.dart';
import 'package:apsl_sun_calc/apsl_sun_calc.dart';
import '../widgets/stylized_moon.dart';

class MoonScreen extends StatefulWidget {
  final DateTime date;
  final double? latitude;
  final double? longitude;

  const MoonScreen({super.key, required this.date, this.latitude, this.longitude});

  @override
  State<MoonScreen> createState() => _MoonScreenState();
}

class _MoonScreenState extends State<MoonScreen> {
  bool _useLocalTilt = true;

  @override
  Widget build(BuildContext context) {
    final moment = LunarMoment(widget.date.millisecondsSinceEpoch);
    final illumination = SunCalc.getMoonIllumination(widget.date);
    final currentPhase = illumination['phase']?.toDouble() ?? 0.0;
    final fraction = illumination['fraction']?.toDouble() ?? 0.0;
    final angle = illumination['angle']?.toDouble() ?? 0.0;

    double tilt = 0.0;
    if (_useLocalTilt && widget.latitude != null && widget.longitude != null) {
      final position = SunCalc.getMoonPosition(widget.date, widget.latitude!, widget.longitude!);
      final parallacticAngle = position['parallacticAngle']?.toDouble() ?? 0.0;
      tilt = parallacticAngle - angle;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StylizedMoon(
            phase: currentPhase,
            size: 180,
            tilt: tilt,
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
            'Date: ${widget.date.toLocal().toString().split(' ')[0]}',
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
          
          if (widget.latitude != null && widget.longitude != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Location: ${widget.latitude!.toStringAsFixed(2)}, ${widget.longitude!.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 12, color: Colors.white38),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: _useLocalTilt,
                    onChanged: (val) {
                      setState(() {
                        _useLocalTilt = val;
                      });
                    },
                  ),
                  const Text('Local Tilt', style: TextStyle(fontSize: 12, color: Colors.white38)),
                ],
              ),
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
