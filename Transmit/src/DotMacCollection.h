#import "FavoriteCollection.h"
#import "Favorite.h"

typedef enum
{
	kMyiDisk,
	kOtherUsersPubliciDisk,
	kOtherUsersiDisk
} iDiskDotMacFavoriteType;


@interface DotMacCollection : FavoriteCollection
{

}

@end

@interface DotMacFavorite : Favorite
{
	BOOL isUserFavorite;
	iDiskDotMacFavoriteType iDiskType;
}

- (iDiskDotMacFavoriteType)iDiskFavoriteType;
- (void)setiDiskFavoriteType:(iDiskDotMacFavoriteType)type;

@end