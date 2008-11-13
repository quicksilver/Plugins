#import <Cocoa/Cocoa.h>

typedef enum
{
	kFolderType,
	kBonjourType,
	kDotMacType,
	kHistoryType
} TRFavoriteType;

@class Favorite;

@interface FavoriteCollection : NSObject
{
	NSMutableDictionary *syncEntity;
	
	NSMutableArray *contents;
	
@private
	NSString *name;
	NSString *uuid;
	
	BOOL needsSyncing;
}

- (id)initWithCoder:(NSCoder*)coder;

- (void)collectionDidLoad;

- (NSString*)name;
- (BOOL)needsSyncing;
- (TRFavoriteType)type;
- (NSString*)UUID;

- (void)setName:(NSString*)aName;
- (void)setNeedsSyncing:(BOOL)flag;
- (void)setUUID:(NSString*)newUUID;

- (void)sortByName;

- (BOOL)containsFavoriteWithNickname:(NSString*)aNickname;
- (BOOL)containsFavoriteWithUUID:(NSString*)aUUID;
- (Favorite*)favoriteWithNickname:(NSString*)aNickname;
- (Favorite*)favoriteWithUUID:(NSString*)aUUID;
- (id)itemWithUUID:(NSString*)aUUID;

// array type methods

- (void)addObject:(id)object;
- (NSArray*)allObjects;
- (BOOL)containsObject:(id)object;
- (int)count;
- (int)indexOfObject:(id)object;
- (void)insertObject:(id)object atIndex:(int)index;
- (id)objectAtIndex:(int)index;
- (void)removeAllObjects;
- (void)removeObject:(id)object;
- (void)removeObjectAtIndex:(int)index;
- (void)removeObjectsInArray:(NSArray*)objects;

@end
