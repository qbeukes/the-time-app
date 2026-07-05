void main() {
  int moonAt2017 = 83235; // Month 4 (RAuwaben)
  int yearStartMoonAt2017 = moonAt2017 - 3; // 83232, Month 1 (Yahudah)
  
  // Year calculation (1-based)
  // If year 1 starts at moon 0:
  int yearOf2017 = (yearStartMoonAt2017 / 12).floor() + 1;
  print('Year of 2017: $yearOf2017'); // 6937
  
  // Year cycle
  // 1 = Wisdom, 2 = Understanding, 3 = Knowledge
  List<String> types = ['Knowledge', 'Wisdom', 'Understanding'];
  // Because 1 % 3 = 1 (Wisdom), 2 % 3 = 2 (Understanding), 3 % 3 = 0 (Knowledge)
  String type2017 = types[yearOf2017 % 3];
  print('Type of 2017: $type2017'); // Should be Wisdom
  
  // Now for J0:
  int moonAtJ0 = 1; // First moon after J0
  int monthAtJ0 = (moonAtJ0 % 12) + 1;
  int yearStartMoonAtJ0 = moonAtJ0 - monthAtJ0 + 1; // 1 - 2 + 1 = 0
  int yearOfJ0 = (yearStartMoonAtJ0 / 12).floor() + 1;
  print('Year of J0: $yearOfJ0');
  
  String typeJ0 = types[yearOfJ0 % 3];
  print('Type of J0: $typeJ0');
}
