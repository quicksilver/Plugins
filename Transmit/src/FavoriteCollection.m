#import "FavoriteCollection.h"
#import "Favorite.h"
#import "LocaleMacros.h"
///#import "NSString-UUID.h"


//static NSImage *genericFolderImage = nil;

int CompareByName(id obj1, id obj2, void* context)
{
	NSString*	name1	= nil;
	NSString*	name2	= nil;
	int			result	= NSOrderedSame;
	
	if ( YES == [obj1 isKindOfClass:[Favorite class]] )
		name1 = [(Favorite*)obj1 nickname];
	else // Another collection
		name1 = [(FavoriteCollection*)obj1 name];
	
	if ( YES == [obj2 isKindOfClass:[Favorite class]] )
		name2 = [(Favorite*)obj2 nickname];
	else
		name2 = [(FavoriteCollection*)obj2 name];
	
	if ( nil != name1 &&
		 nil != name2 )
		result = [name1 caseInsensitiveCompare:name2];
	
	return result;
}


@implementation FavoriteCollection


- (id)initWithCoder:(NSCoder*)coder
{
	self = [super init]; 
	
	if ( self )
	{
		name = [[coder decodeObjectForKey:@"name"] retain];
		
		contents = [coder decodeObjectForKey:@"contents"];
		
		// make contents mutable
		
		if ( nil != contents )
			contents = [[NSMutableArray alloc] initWithArray:contents];
		else
			contents = [[NSMutableArray alloc] initWithCapacity:5];
		
		uuid = [[coder decodeObjectForKey:@"uuid"] retain];
		
		//if ( uuid == nil )
		//	uuid = [[NSString UUIDString] retain];
		
		needsSyncing = [coder decodeBoolForKey:@"needsSyncing"];
		
		[self collectionDidLoad];
	}
	
	return self;
}


- (void)dealloc
{
	[name release];
	[contents release];
	[uuid release];
	
	[syncEntity release];
	
	[super dealloc];
}


- (void)addObject:(id)object
{
	[contents addObject:object];
}


- (NSArray*)allObjects
{
	return contents;
}


- (void)collectionDidLoad
{
	// does nothing
}


- (BOOL)containsFavoriteWithNickname:(NSString*)aNickname
{
	return ( [self favoriteWithNickname:aNickname] != nil);
}


- (BOOL)containsFavoriteWithUUID:(NSString*)aUUID
{
	return ( [self favoriteWithUUID:aUUID] != nil);
}


- (BOOL)containsObject:(id)object
{
	return [contents containsObject:object];
}


- (int)count
{
	return [contents count];
}


- (Favorite*)favoriteWithNickname:(NSString*)aNickname
{
	NSEnumerator *enumerator = [contents objectEnumerator];
	id curObject = nil;
	
	while ( (curObject = [enumerator nextObject]) != nil )
	{
		if ( [curObject isKindOfClass:[Favorite class]] )
		{
			if ( [[curObject nickname] isEqualToString:aNickname] )
			{
				break;
			}
		}
	}
	
	return curObject;
}


- (Favorite*)favoriteWithUUID:(NSString*)aUUID
{
	NSEnumerator *enumerator = [contents objectEnumerator];
	id curObject = nil;
	
	while ( (curObject = [enumerator nextObject]) != nil )
	{
		if ( [curObject isKindOfClass:[Favorite class]] )
		{
			if ( [[curObject UUID] isEqualToString:aUUID] )
			{
				break;
			}
		}
	}
	
	return curObject;
}


- (int)indexOfObject:(id)object
{
	return [contents indexOfObject:object];
}


- (void)insertObject:(id)object atIndex:(int)index
{
	[contents insertObject:object atIndex:index];
}


- (id)itemWithUUID:(NSString*)aUUID
{
	NSEnumerator *enumerator = [contents objectEnumerator];
	id curObject = nil;
	
	while ( (curObject = [enumerator nextObject]) != nil )
	{
		if ( [[curObject UUID] isEqualToString:aUUID] )
		{
			break;
		}
		
		if ( [curObject isKindOfClass:[FavoriteCollection class]] )
		{
			id subObject = [curObject itemWithUUID:aUUID];
			
			if ( subObject )
			{
				curObject = subObject;
				break;
			}
		}
	}
	
	return curObject;
}


- (NSString*)name
{
	return name;
}


- (BOOL)needsSyncing
{
	return NO;
}


- (id)objectAtIndex:(int)index
{
	return [contents objectAtIndex:index];
}


- (void)removeAllObjects
{
	NSMutableArray *oldContents = contents;
	
	contents = [[NSMutableArray alloc] init];
	
	[oldContents release];
}


- (void)removeObject:(id)object
{
	[contents removeObject:object];
}


- (void)removeObjectAtIndex:(int)index
{
	[contents removeObjectAtIndex:index];
}


- (void)removeObjectsInArray:(NSArray*)objects
{
	[contents removeObjectsInArray:objects];
}


- (void)setName:(NSString*)aName
{
	[name autorelease];
	name = [aName retain];
}


- (void)setNeedsSyncing:(BOOL)flag
{
	needsSyncing = flag;
}


- (void)setUUID:(NSString*)newUUID
{
	[uuid release];
	uuid = [newUUID retain];
}


- (void)sortByName
{
	[contents sortUsingFunction:CompareByName context:nil];
}


- (TRFavoriteType)type
{
	return kFolderType;
}


- (NSString*)UUID
{
	return uuid;
}

@end
