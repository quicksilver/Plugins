#import "DotMacCollection.h"
#import "Favorite.h"
#import "LocaleMacros.h"


@implementation DotMacCollection


+ (id)collection
{
	return [[[DotMacCollection alloc] initWithName:LOCAL(@"iDisk")] autorelease];
}


- (void)collectionDidLoad
{
	DotMacFavorite *myiDisk = [DotMacFavorite favorite];
	
	[myiDisk setiDiskFavoriteType:kMyiDisk];
	[self addObject:myiDisk];

	DotMacFavorite *otheriDisk = [DotMacFavorite favorite];
		
	[otheriDisk setiDiskFavoriteType:kOtherUsersiDisk];
	[self addObject:otheriDisk];


	DotMacFavorite *otherPubliciDisk = [DotMacFavorite favorite];
	
	[otherPubliciDisk setiDiskFavoriteType:kOtherUsersPubliciDisk];
	[self addObject:otherPubliciDisk];
}


- (TRFavoriteType)type
{
	return kDotMacType;
}


@end


@implementation DotMacFavorite : Favorite


+ (id)favorite
{
	return [[[DotMacFavorite alloc] init] autorelease];
}


- (id)init
{
	self = [super init];
	
	if ( self )
		isUserFavorite = NO;
	
	return self;
}


- (iDiskDotMacFavoriteType)iDiskFavoriteType
{
	return iDiskType;
}


- (void)setiDiskFavoriteType:(iDiskDotMacFavoriteType)type
{
	iDiskType = type;

	[self setServer:@"idisk.mac.com"];
	[self setProtocol:TRItemProtocolWebDAV];

	if ( iDiskType == kMyiDisk )
	{
		//[self setImage:[NSImage systemIcon:kGenericIDiskIcon withSize:NSMakeSize(16,16)]];
		[self setNickname:LOCAL(@"My iDisk")];
	}
	else if ( iDiskType == kOtherUsersiDisk )
	{
		//[self setImage:[NSImage systemIcon:kGenericIDiskIcon withSize:NSMakeSize(16,16)]];
		[self setNickname:LOCAL(@"Other User's iDisk")];

	}
	else if ( iDiskType == kOtherUsersPubliciDisk )
	{
		//[self setImage:[NSImage systemIcon:kUserIDiskIcon withSize:NSMakeSize(16,16)]];
		[self setNickname:LOCAL(@"Other User's Public Folder")];	
	}
}


- (FavoriteType)type
{
	return kDotMacFavoriteType;
}


@end
