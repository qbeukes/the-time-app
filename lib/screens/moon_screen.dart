import 'package:flutter/material.dart';
import 'package:inner_time/models/lunar/full_moon_based_layer.dart';
import 'package:inner_time/models/lunar/new_moon_based_layer.dart';
import 'package:inner_time/models/lunar/lunar_moment.dart';

class MoonScreen extends StatelessWidget {
  const MoonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final moment = LunarMoment.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Moon Time'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.nightlight_round,
              size: 100,
              color: Colors.blueGrey,
            ),

            const SizedBox(height: 20),
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
      ),
    );
  }
}
