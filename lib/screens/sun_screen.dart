import 'package:flutter/material.dart';
import '../models/moment.dart';
import '../models/solar/gregorian_solar_time.dart';
import '../models/solar/enochian_solar_time.dart';class SunScreen extends StatelessWidget {
  const SunScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final moment = Moment.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Solar Time'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
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
              'Gregorian: ${moment.toDisplayValue(GregorianSolarTime.new)}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Text(
              'Enochian: ${moment.toDisplayValue(EnochianSolarTime.new)}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}
