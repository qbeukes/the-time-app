import 'package:flutter/material.dart';
import '../models/moment.dart';
import '../models/solar/gregorian_solar_time.dart';
import '../models/solar/enochian_solar_time.dart';
import '../widgets/seconds_timer.dart';

class SunScreen extends StatelessWidget {
  final DateTime date;
  final bool showSeconds;

  const SunScreen({
    super.key,
    required this.date,
    this.showSeconds = false,
  });

  @override
  Widget build(BuildContext context) {
    final moment = Moment(date.millisecondsSinceEpoch);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.wb_sunny,
                size: 100,
                color: Colors.amber,
              ),
              const SizedBox(height: 20),
              Text(
                'Date: ${date.toLocal().toString().split(' ')[0]}',
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 20),
              Text(
                'Gregorian: ${moment.toDisplayValue(GregorianSolarTime.new)}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              Text(
                'Enochian: ${moment.toDisplayValue(EnochianSolarTime.new)}',
                style: Theme.of(context).textTheme.titleLarge,
              ),

              // ── Seconds / Meditation Timer ──────────────────────────
              if (showSeconds) ...[
                const SizedBox(height: 24),
                const SecondsTimer(),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
