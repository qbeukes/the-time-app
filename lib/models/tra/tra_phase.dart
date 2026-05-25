enum TraPhase {
  initiation(
    number: 1,
    name: 'Initiation',
    description: 'Emergence of raw intent, sparking new trajectories, and gathering momentum.',
  ),
  development(
    number: 2,
    name: 'Development',
    description: 'Deepening structural absorption, active cultivation, and building functional pathways.',
  ),
  progression(
    number: 3,
    name: 'Progression',
    description: 'Targeted system execution, peak expression, and systemic integration.',
  ),
  completion(
    number: 4,
    name: 'Completion',
    description: 'Auditing outputs, balancing systemic charge, and preparing for transition.',
  );

  final int number;
  final String name;
  final String description;

  const TraPhase({
    required this.number,
    required this.name,
    required this.description,
  });

  static TraPhase fromNumber(int num) {
    final index = (num - 1) % values.length;
    return values[index < 0 ? index + values.length : index];
  }
}
