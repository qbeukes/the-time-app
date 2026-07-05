void main() {
  // Leap years in a 19-year cycle (1-based index)
  // Standard Hebrew cycle leap years: 3, 6, 8, 11, 14, 17, 19
  final leapYears = {3, 6, 8, 11, 14, 17, 19};
  
  List<int> moonsPerYear = [];
  for (int y = 1; y <= 19; y++) {
    moonsPerYear.add(leapYears.contains(y) ? 13 : 12);
  }
  
  // Verify total moons
  int totalMoons = moonsPerYear.reduce((a, b) => a + b);
  print('Total moons in cycle: \$totalMoons'); // Should be 235
  
  // We want to anchor the cycle mathematically.
  // In the user's Luach, 2022 is Year 1 of the cycle.
  // Let's find the sequentialMoonNumber for 2022-04-17 (Yahúdah).
  // 2017-07-09 was seq = 217.
  // We can calculate the exact seq for 2022-04-17 later.
  
  // Let's generate the mapping from moon index (0-234) to [Year (1-19), Month (1-13)]
  print('  static const List<int> metonicYearMap = [');
  int moonCount = 0;
  for (int y = 1; y <= 19; y++) {
    int moons = leapYears.contains(y) ? 13 : 12;
    for (int m = 1; m <= moons; m++) {
      print('    \$y, // Moon \$moonCount (Month \$m)');
      moonCount++;
    }
  }
  print('  ];');
  
  print('  static const List<int> metonicMonthMap = [');
  moonCount = 0;
  for (int y = 1; y <= 19; y++) {
    int moons = leapYears.contains(y) ? 13 : 12;
    for (int m = 1; m <= moons; m++) {
      print('    \$m, // Moon \$moonCount (Year \$y)');
      moonCount++;
    }
  }
  print('  ];');
}
