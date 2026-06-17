import 'package:the_time_app/models/lunar/full_moon_based_layer.dart';
import 'package:the_time_app/models/moment.dart';
import 'luach_interpreter.dart';
import 'luach_metadata.dart';

class LuachLayer extends FullMoonBasedLayer {
  LuachLayer(super.moment) {
    LuachInterpreter().loadIfNeeded();
  }

  /// Returns the current loaded LuachMoon for the active moment.
  LuachMoon? get currentMoon {
    final interpreter = LuachInterpreter();
    if (!interpreter.isLoaded) return null;
    return interpreter.getMoonForMoment(moment);
  }

  /// Returns the metadata associated with the current moon's number (1-13).
  LuachMoonMetadata? get currentMetadata {
    final moon = currentMoon;
    if (moon == null) return null;
    return LuachMoonMetadata.getByNumber(moon.moonNumberInYear);
  }

  /// Returns the 0-based day number since the start of the current moon.
  int get dayOfMoon {
    final moon = currentMoon;
    if (moon == null) return 0;

    final momentDate = DateTime.fromMillisecondsSinceEpoch(
      moment.epochMilliseconds,
      isUtc: true,
    );
    final moonDateUtc = DateTime.utc(
      moon.date.year,
      moon.date.month,
      moon.date.day,
    );

    return momentDate.difference(moonDateUtc).inDays;
  }

  @override
  String toDisplayValue() {
    final moon = currentMoon;
    final meta = currentMetadata;

    if (moon == null) {
      return 'Loading Luach data...';
    }

    final dayNumber = dayOfMoon;
    final metadataString = meta != null
        ? '\nDirection: ${meta.direction}\nGemstone: ${meta.gemstone}'
        : '';

    return '${moon.name}\n'
        'Moon ${moon.moonNumberInYear} in year of ${moon.yearType}\n'
        'Day $dayNumber$metadataString';
  }
}
