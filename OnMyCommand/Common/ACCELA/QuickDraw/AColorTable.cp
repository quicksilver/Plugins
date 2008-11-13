#include "AColorTable.h"

#include <stdlib.h>
#include <cstdlib>

// ---------------------------------------------------------------------------

RGBColor
AColorTable::ClosestColor(
		const RGBColor &inColor) const
{
	const SInt16 colorCount = Count();
	SInt16 i;
	RGBColor bestColor = GetIndColor(0);
	unsigned long bestDiff = 0xFFFFFFFF;
	
	for (i = 0; i < colorCount; i++) {
		const RGBColor indColor = GetIndColor(i);
		unsigned long diff = 0;
		
		diff += std::abs(inColor.red - indColor.red);
		diff += std::abs(inColor.green - indColor.green);
		diff += std::abs(inColor.blue - indColor.blue);
		if (diff == 0) {
			bestColor = indColor;
			break;
		}
		if (diff < bestDiff) {
			bestDiff = diff;
			bestColor = indColor;
		}
	}
	return bestColor;
}
