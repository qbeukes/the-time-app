void main() {
  int kAtJDN0 = -83018; // Full moon just after JDN 0
  int kAt2017 = 216; // 2017-07-09 full moon
  
  int seqNum2017 = kAt2017 - kAtJDN0 + 1; 
  print('Seq number at 2017: $seqNum2017'); // 83235
  
  // If Month 1 is exactly at seqNum 1 (the first full moon after JDN 0):
  int currentMonthIfJ0IsEpoch = ((seqNum2017 - 1) % 12) + 1;
  print('Month at 2017 if J0 is epoch (Month 1): $currentMonthIfJ0IsEpoch');
  // It would be 3 (Zebúwlan). But the original 12TRA design had 2017-07-09 as RAúwaben (Month 4).
  
  // If we want 2017-07-09 to remain Month 4, the cycle offset must be:
  int monthAt2017Original = (seqNum2017 % 12) + 1;
  print('Month at 2017 with current logic: $monthAt2017Original');
  
  // What was the month of the first full moon (seqNum 1) with the current logic?
  print('Month of seqNum 1 with current logic: ${(1 % 12) + 1}'); // 2
}
