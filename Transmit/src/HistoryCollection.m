#import "HistoryCollection.h"
#import "Favorite.h"
#import "LocaleMacros.h"


@implementation HistoryCollection

- (TRFavoriteType)type
{
	return kHistoryType;
}

@end
