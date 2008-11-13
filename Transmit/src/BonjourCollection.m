#import "BonjourCollection.h"
#import "Favorite.h"
#import "LocaleMacros.h"

@implementation BonjourCollection


- (id)initWithCoder:(NSCoder*)coder
{
	self = [super initWithCoder:coder];
	
	if ( nil != self )
	{
		// Fixes vocab for those who had prefs saved from before Rendezvous
		// was changed to Bonjour.
		
		if ( YES == [[self name] isEqualToString:@"Rendezvous"] )
			[self setName:LOCAL(@"Bonjour")];
	}
	
	return self;
}

- (TRFavoriteType)type
{
	return kBonjourType;
}


@end


@implementation BonjourFavorite


+ (id)favorite
{
	return [[[BonjourFavorite alloc] init] autorelease];
}

- (FavoriteType)type
{
	return kBonjourFavoriteType;
}


@end