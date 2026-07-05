void main() {
  int seqMoon = 217; // 2017-07-09
  
  int offset = (seqMoon - 276) % 235;
  if (offset < 0) offset += 235;

  const leapYears = {3, 6, 8, 11, 14, 17, 19};
  int moonCount = 0;

  int month = 1;
  int year = 1;
  for (int y = 1; y <= 19; y++) {
    int moonsThisYear = leapYears.contains(y) ? 13 : 12;
    if (offset < moonCount + moonsThisYear) {
      month = offset - moonCount + 1;
      year = y;
      break;
    }
    moonCount += moonsThisYear;
  }
  
  print('Seq 217 (2017-07-09) -> Year: \$year, Month: \$month');
  
  // Seq 276 (2022-04-17)
  seqMoon = 276;
  offset = (seqMoon - 276) % 235;
  if (offset < 0) offset += 235;
  moonCount = 0;
  for (int y = 1; y <= 19; y++) {
    int moonsThisYear = leapYears.contains(y) ? 13 : 12;
    if (offset < moonCount + moonsThisYear) {
      month = offset - moonCount + 1;
      year = y;
      break;
    }
    moonCount += moonsThisYear;
  }
  print('Seq 276 (2022-04-17) -> Year: \$year, Month: \$month');
}
