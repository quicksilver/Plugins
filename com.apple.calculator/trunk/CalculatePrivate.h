//
//  CalculatePrivate.h
//  Calculate.framework
//
//  Created by Nicholas Jitkoff on 3/19/08.
//

// These are really just guesses, just pass 1
enum {
  CalculateUnknown1 = 1 << 0,
  CalculateTreatInputAsIntegers = 1 << 1,
  CalculateMoreAccurate = 1 << 2
} CalculateFlags;

// Returns 1 on success
int CalculatePerformExpression(char *expr, int significantDigits, int flags, char *answer);
