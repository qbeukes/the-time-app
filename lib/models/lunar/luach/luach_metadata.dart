import 'package:inner_time/models/tra/tra_archetype.dart';
import 'package:inner_time/models/tra/tra_phase.dart';

class LuachMoonMetadata {
  final int number;
  final String name;
  final String direction;
  final String gemstone;
  final String archetypalSummary;
  final String traFunctionalSummary;
  final String cardDescription;
  final String traPhase;
  final String traArchetype;

  const LuachMoonMetadata({
    required this.number,
    required this.name,
    required this.direction,
    required this.gemstone,
    required this.archetypalSummary,
    required this.traFunctionalSummary,
    required this.cardDescription,
    required this.traPhase,
    required this.traArchetype,
  });

  /// Map containing metadata for all 12 canonical moons plus the 13th leap moon (Berúwkah).
  static final Map<int, LuachMoonMetadata> moons = {
    1: const LuachMoonMetadata(
      number: 1,
      name: 'Yahúdah',
      direction: 'East',
      gemstone: 'Odem',
      archetypalSummary: 'Yahúdah represents activation, kingship, emergence, first illumination, and the bringing of structure into visible form.',
      traFunctionalSummary: 'Spark represents ignition, beginning, first movement, energetic emergence, and the initiation of a new temporal cycle.',
      cardDescription: 'Yahúdah and Spark align as the first movement of the cycle: the moment where light, will, identity, and temporal action begin.',
      traPhase: 'Initiation',
      traArchetype: 'Spark',
    ),
    2: const LuachMoonMetadata(
      number: 2,
      name: 'Yishshakkar',
      direction: 'East',
      gemstone: 'Pitdah',
      archetypalSummary: 'Yishshakkar represents discernment of cycles, assembled knowledge, timing, counting, ordering, and recognition of pattern.',
      traFunctionalSummary: 'Analyst represents observation, distinction, classification, measurement, and structural understanding.',
      cardDescription: 'Yishshakkar and Analyst align as the intelligence that reads the structure of time and recognizes how the parts fit together.',
      traPhase: 'Initiation',
      traArchetype: 'Analyst',
    ),
    3: const LuachMoonMetadata(
      number: 3,
      name: 'Zebúwlan',
      direction: 'East',
      gemstone: 'Bareketh',
      archetypalSummary: 'Zebúwlan represents knowledge exchange, movement between domains, fruitful labor, extension, and circulation.',
      traFunctionalSummary: 'Connector represents relational linkage, transmission, exchange, network formation, and bridging between separated elements.',
      cardDescription: 'Zebúwlan and Connector align as the movement of knowledge into relationship, trade, expression, and fruitful contact.',
      traPhase: 'Initiation',
      traArchetype: 'Connector',
    ),
    4: const LuachMoonMetadata(
      number: 4,
      name: 'RAúwaben',
      direction: 'South',
      gemstone: 'Nofech',
      archetypalSummary: 'RAúwaben represents seeing, perception, revelation, foundations, hidden structure, and the opening of inner sight.',
      traFunctionalSummary: 'Visionary represents future-sight, pattern projection, imaginative perception, and the ability to see beyond the immediately visible.',
      cardDescription: 'RAúwaben and Visionary align as the eye of the cycle: the capacity to perceive what is forming beneath the surface.',
      traPhase: 'Development',
      traArchetype: 'Visionary',
    ),
    5: const LuachMoonMetadata(
      number: 5,
      name: 'Shamoúnn',
      direction: 'South',
      gemstone: 'Sappir',
      archetypalSummary: 'Shamoúnn represents hearing, reception, obedience to signal, understanding through listening, and inward resonance.',
      traFunctionalSummary: 'Hearer represents receptive intelligence, attunement, signal detection, listening, and resonance awareness.',
      cardDescription: 'Shamoúnn and Hearer align as the receptive chamber of the cycle: the ability to hear what time is communicating.',
      traPhase: 'Development',
      traArchetype: 'Hearer',
    ),
    6: const LuachMoonMetadata(
      number: 6,
      name: 'Gad',
      direction: 'South',
      gemstone: 'Yahalom',
      archetypalSummary: 'Gad represents speech, words, articulation, wisdom expressed through the mouth, and manifestation through utterance.',
      traFunctionalSummary: 'Speaker represents expression, declaration, verbalization, communication, and the conversion of inner structure into outward signal.',
      cardDescription: 'Gad and Speaker align as the voice of the cycle: what has been seen and heard now becomes articulated.',
      traPhase: 'Development',
      traArchetype: 'Speaker',
    ),
    7: const LuachMoonMetadata(
      number: 7,
      name: 'Aparryim',
      direction: 'West',
      gemstone: 'Leshem',
      archetypalSummary: 'Aparryim represents habitation, cultivation, enclosure, covering, settlement, growth, and the ordering of space.',
      traFunctionalSummary: 'Architect represents structure, design, system-building, framework creation, and the making of inhabitable order.',
      cardDescription: 'Aparryim and Architect align as the builder of the cycle: the stage where resonance becomes structure.',
      traPhase: 'Progression',
      traArchetype: 'Architect',
    ),
    8: const LuachMoonMetadata(
      number: 8,
      name: 'Maneshayh',
      direction: 'West',
      gemstone: 'Shevo',
      archetypalSummary: 'Maneshayh represents refinement, restraint, message integration, disciplined communication, and harmonized understanding.',
      traFunctionalSummary: 'Integrator represents synthesis, alignment, reconciliation, coherence-building, and the joining of separate parts into a working whole.',
      cardDescription: 'Maneshayh and Integrator align as the harmonizing intelligence of the cycle: many messages are refined into one coherent pattern.',
      traPhase: 'Progression',
      traArchetype: 'Integrator',
    ),
    9: const LuachMoonMetadata(
      number: 9,
      name: 'Beniyman',
      direction: 'West',
      gemstone: 'Achlamah',
      archetypalSummary: 'Beniyman represents return, renewal, chambers, restoration, right-hand action, and the reorganization of movement through cycles.',
      traFunctionalSummary: 'Strategist represents planning, orientation, sequencing, adaptive movement, and purposeful navigation through complexity.',
      cardDescription: 'Beniyman and Strategist align as the tactical intelligence of the cycle: return and renewal become directed movement.',
      traPhase: 'Progression',
      traArchetype: 'Strategist',
    ),
    10: const LuachMoonMetadata(
      number: 10,
      name: 'Dan',
      direction: 'North',
      gemstone: 'Tarshish',
      archetypalSummary: 'Dan represents judgment, thresholds, openings, paths, transitions, testing, strengthening, and decision.',
      traFunctionalSummary: 'Evaluator represents assessment, discernment, testing, correction, judgment, and decision-making.',
      cardDescription: 'Dan and Evaluator align as the judging gate of the cycle: what has formed must now be tested, opened, corrected, or closed.',
      traPhase: 'Completion',
      traArchetype: 'Evaluator',
    ),
    11: const LuachMoonMetadata(
      number: 11,
      name: 'Ayshshur',
      direction: 'North',
      gemstone: 'Shoham',
      archetypalSummary: 'Ayshshur represents establishment, maturity, completion of instruction, stability, recompense, and settled capability.',
      traFunctionalSummary: 'Harmonizer represents balance, stabilization, agreement, relational coherence, and the restoration of internal and external equilibrium.',
      cardDescription: 'Ayshshur and Harmonizer align as the stabilizing power of the cycle: what has been tested is matured into balance.',
      traPhase: 'Completion',
      traArchetype: 'Harmonizer',
    ),
    12: const LuachMoonMetadata(
      number: 12,
      name: 'Nephetli',
      direction: 'North',
      gemstone: 'Yashpheh',
      archetypalSummary: 'Nephetli represents culmination, wisdom synthesis, transmission, perfected sayings, completion, and the drawing out of strength.',
      traFunctionalSummary: 'Inspirer represents uplift, transmission, renewal of vision, final synthesis, and the release of completed meaning into the next cycle.',
      cardDescription: 'Nephetli and Inspirer align as the completing breath of the cycle: wisdom is drawn out, transmitted, and prepared to become new initiation.',
      traPhase: 'Completion',
      traArchetype: 'Inspirer',
    ),
    13: const LuachMoonMetadata(
      number: 13,
      name: 'Berúwkah',
      direction: 'Leap / Intercalary',
      gemstone: 'Beryl',
      archetypalSummary: 'Berúwkah represents blessing, transition, systemic alignment, and the balancing of the solar-lunar offset.',
      traFunctionalSummary: 'An extra-cyclical adjustment node ensuring synchronization across multi-year cycles.',
      cardDescription: 'Berúwkah serves as the intercalary transition: a periodic adjustment phase resetting the alignment between lunar months and solar years.',
      traPhase: 'Leap',
      traArchetype: 'None / Intercalary',
    ),
  };

  static LuachMoonMetadata? getByNumber(int num) {
    return moons[num];
  }
}
