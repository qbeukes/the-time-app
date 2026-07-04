import 'package:the_time_app/models/lunar/full_moon_based_layer.dart';
import 'package:the_time_app/models/timeunit/lunar_time_unit.dart';
import 'tra_archetype.dart';
import 'tra_phase.dart';

class TraLayer extends FullMoonBasedLayer {
  const TraLayer(LunarTimeUnit super.moment);

  /// Gets the Monthly Archetype resonance based on the sequential moon number.
  TraArchetype get monthlyArchetype {
    return TraArchetype.fromNumber(moonNumber);
  }

  /// Gets the Daily Archetype resonance based on the current floor of the moon age.
  TraArchetype get dailyArchetype {
    return TraArchetype.fromNumber(moonAge.floor() + 1);
  }

  /// Gets the Macro Temporal Phase based on the moon age's progress through the synodic month.
  TraPhase get phase {
    const quarterLength = 29.53059 / 4.0;
    final index = (moonAge / quarterLength).floor().clamp(0, 3);
    return TraPhase.values[index];
  }

  /// Gets the progress percentage (0.0 to 1.0) through the active macro temporal phase.
  double get phaseProgress {
    const quarterLength = 29.53059 / 4.0;
    final currentQuarterAge = moonAge % quarterLength;
    return (currentQuarterAge / quarterLength).clamp(0.0, 1.0);
  }

  @override
  String toDisplayValue() {
    final mArchetype = monthlyArchetype;
    final dArchetype = dailyArchetype;
    final p = phase;
    final progressPct = (phaseProgress * 100).toStringAsFixed(0);

    return 'Month Mode: ${mArchetype.name} (${mArchetype.symbol})\n'
        'Day Mode: ${dArchetype.name} (${dArchetype.symbol})\n'
        'Phase: ${p.name} ($progressPct%)';
  }
}
