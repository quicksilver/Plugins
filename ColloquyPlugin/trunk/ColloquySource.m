//
//  ColloquySource.m
//  Quicksilver
//

#import <Carbon/Carbon.h>

#import "ColloquySource.h"

#import <QSCore/QSResourceManager.h>
#import <QSCore/QSObject.h>
#import <QSCore/QSObject_Pasteboard.h>
#import <QSCore/NSPasteboard_BLTRExtensions.h>
#import <QSCore/QSLibrarian.h>
#import <QSCore/QSTextProxy.h>
#import <QSCore/QSTypes.h>

#define kFavoritesFolder @"~/Library/Application Support/Colloquy/Favorites/"

#define ColloquyServerType @"ColloquyServerType"
#define ColloquyRoomType @"ColloquyRoomType"

@implementation ColloquySource
- (id) init {
	if (self = [super init]) {
		servers = nil;
		objectChildren = [[NSMutableDictionary alloc] init];
		NSBundle *plugin = [NSBundle bundleForClass:[self class]];
		roomImage = [[NSImage alloc] initByReferencingFile:
			[plugin pathForResource:@"room" ofType:@"tif"]];
		personImage = [[NSImage alloc] initByReferencingFile:
			[plugin pathForResource:@"directChat" ofType:@"tif"]];
		bookmarkImage = [[NSImage alloc] initByReferencingFile:
			[plugin pathForResource:@"autoRoom" ofType:@"tif"]];
		entryImage = [[NSImage alloc] initByReferencingFile:
			[plugin pathForResource:@"Colloquy" ofType:@"icns"]];
	}
	return self;
}

- (void) dealloc {
	[servers release];
	[objectChildren release];
	[roomImage release];
	[bookmarkImage release];
	[personImage release];
	[super dealloc];
}

- (BOOL) indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry {
	static BOOL hasCached = NO;
	if (hasCached) {
		NSDate *modDate = [[[NSFileManager defaultManager] fileAttributesAtPath:[kFavoritesFolder stringByStandardizingPath] traverseLink:YES] fileModificationDate];
		if ([modDate compare:indexDate]!=NSOrderedAscending)
			return NO;
		NSString *prefPath = [@"~/Library/Preferences/cc.javelin.colloquy.plist" stringByExpandingTildeInPath];
		modDate = [[[NSFileManager defaultManager] fileAttributesAtPath:prefPath traverseLink:YES] fileModificationDate];
		return [modDate compare:indexDate]==NSOrderedAscending;
	} else {
		hasCached = YES;
		return NO;
	}
}

- (NSImage *) iconForEntry:(NSDictionary *)dict {
	//return [QSResourceManager imageNamed:@"cc.javelin.colloquy"];
	return entryImage;
}

- (NSString *) nameForEntry:(NSDictionary *)dict {
	return @"Colloquy Favorites";
}

- (NSArray *) objectsForEntry:(NSDictionary *)theEntry {
	QSObject *newObject;
	NSMutableArray *objects = [NSMutableArray array];
	NSMutableArray *serverURLs = [NSMutableArray array];
	if (servers) [servers release];
	servers = [[NSMutableDictionary alloc] init];
	
	// First lets add the bookmarks
	NSArray *bookmarks = [(NSArray *)CFPreferencesCopyAppValue((CFStringRef)@"MVChatBookmarks",(CFStringRef)@"cc.javelin.colloquy") autorelease];
	NSEnumerator *e = [bookmarks objectEnumerator];
	NSDictionary *bookmark;
	while (bookmark = [e nextObject]) {
		NSString *url = [bookmark objectForKey:@"url"];
		if (url == nil) {
			NSString *serverStr = [bookmark objectForKey:@"server"];
			NSString *nickStr = [[bookmark objectForKey:@"nickname"]
					stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			NSNumber *port = [bookmark objectForKey:@"port"];
			url = [NSString stringWithFormat:@"irc://%@@%@:%@/", nickStr, serverStr, port];
		}
		NSURL *bookmarkURL = [[NSURL URLWithString:url] standardizedURL];
		if (bookmarkURL == nil) {
			NSLog(@"Nil bookmark URL: %@", url);
		} else {
			if (![serverURLs containsObject:bookmarkURL])
				[serverURLs addObject:bookmarkURL];
			NSMutableArray *rooms = [servers objectForKey:url];
			if (!rooms) {
				rooms = [NSMutableArray array];
				[servers setObject:rooms forKey:url];
			}
			NSArray *autoRooms = [bookmark objectForKey:@"rooms"];
			if (!autoRooms) autoRooms = [NSArray array];
			NSEnumerator *en = [autoRooms objectEnumerator];
			NSString *item;
			while (item = [en nextObject]) {
				// we want a nice path of "/" if there's no path
				NSString *temp = item;
				if ([[bookmarkURL path] length] == 0)
					temp = [@"/" stringByAppendingString:item];
				temp = [temp stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
				
				// We need to manually de-encode # (%23) to work around a Colloquy bug
				NSMutableString *temp2 = [temp mutableCopy];
				[temp2 replaceOccurrencesOfString:@"%23" withString:@"#" options:NSLiteralSearch
											range:NSMakeRange(0, [temp2 length])];
				temp = temp2;
				
				NSString *roomURL = [[NSURL URLWithString:temp relativeToURL:bookmarkURL] absoluteString];
				newObject = [[[QSObject alloc] init] autorelease];
				[newObject setName:item];
				[newObject setObject:roomURL forType:QSURLType];
				[newObject setIdentifier:roomURL];
				[newObject setObject:roomURL forMeta:kQSObjectDetails];
				[newObject setObject:@"cc.javelin.colloquy" forMeta:@"QSPreferredApplication"];
				[newObject setObject:@"Bookmark" forType:ColloquyRoomType];
				[newObject setPrimaryType:ColloquyRoomType];
				
				if (newObject == nil) {
					NSLog(@"Nil room object: %@", roomURL);
				} else {
					[rooms addObject:newObject];
				}
			}
		}
	}
	
	// Lets add the favorites
	e = [[NSFileManager defaultManager] enumeratorAtPath:[kFavoritesFolder stringByStandardizingPath]];
	NSString *item;
	while (item = [e nextObject]) {
		if( [[item pathExtension] isEqualToString:@"inetloc"] ) {
			NSString *path = [[kFavoritesFolder stringByAppendingPathComponent:item] stringByStandardizingPath];
			
			newObject = [[[QSObject alloc] init] autorelease];
			[newObject addContentsOfPasteboard:[NSPasteboard pasteboardByFilteringClipping:path] types:[NSArray arrayWithObject:QSURLType]];
			if (![newObject objectForType:QSURLType])
				continue;
			
			// Scan the URL
			NSURL *ircURL = [[NSURL URLWithString:[newObject objectForType:QSURLType]] standardizedURL];
			NSString *room, *server, *scheme, *user, *pass, *urlPath;
			NSMutableString *serverURL;
			NSNumber *port;
			scheme = [ircURL scheme];
			// Make sure this is an irc:// URL
			if ([scheme isEqualToString:@"irc"]) {
				port = [ircURL port];
				server = [ircURL host];
				user = [ircURL user];
				pass = [ircURL password];
				urlPath = [ircURL path];
				if (urlPath) {
					if ([urlPath hasPrefix:@"/"])
						urlPath = [urlPath substringFromIndex:1];
				} else
					urlPath = [NSString string];
				// construct the room from the URL path and fragment
				if ([[ircURL fragment] length] > 0)
					room = [urlPath stringByAppendingFormat:@"#%@", [ircURL fragment]];
				else
					room = urlPath;
				// construct a URL for the server itself
				serverURL = [NSMutableString stringWithFormat:@"%@://", scheme];
				if (user)
					[serverURL appendString:
						[user stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
				if (pass)
					[serverURL appendFormat:@":%@", 
						[pass stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
				if (user || pass)
					[serverURL appendString:@"@"];
				[serverURL appendString:server];
				
				NSURL *url = [NSURL URLWithString:serverURL];
				NSEnumerator *en = [serverURLs objectEnumerator];
				NSURL *aServer;
				while (aServer = [en nextObject]) {
					if ([url matchesURL:aServer]) {
						serverURL = [[aServer absoluteString] mutableCopy];
						break;
					}
				}
				
				if (room && [room length] > 0) {
					[newObject setName:room];
					[newObject setIdentifier:[newObject objectForType:QSURLType]];
					[newObject setObject:[newObject objectForType:QSURLType]
								 forMeta:kQSObjectDetails];
					[newObject setObject:@"cc.javelin.colloquy" forMeta:@"QSPreferredApplication"];
					[newObject setObject:@"Favorite" forType:ColloquyRoomType];
					[newObject setPrimaryType:ColloquyRoomType];
					
					if (newObject == nil) {
						NSLog(@"Nil favorite: %@", room);
						continue;
					}
					
					NSMutableArray *rooms = [servers objectForKey:serverURL];
					if (!rooms) {
						rooms = [NSMutableArray array];
						[rooms addObject:newObject];
						[servers setObject:rooms forKey:serverURL];
					} else {
						[rooms addObject:newObject];
					}
				} else {
					NSMutableArray *rooms = [servers objectForKey:serverURL];
					if (!rooms) {
						rooms = [NSMutableArray array];
						[servers setObject:rooms forKey:serverURL];
					}
				}
			}
		}
	}
	
	e = [servers keyEnumerator];
	while (item = [e nextObject]) {
		newObject = [[[QSObject alloc] init] autorelease];
		NSURL *serverURL = [NSURL URLWithString:item];
		[newObject setName:[serverURL host]];
		[newObject setObject:item forType:QSURLType];
		[newObject setObject:item forMeta:kQSObjectDetails];
		[newObject setObject:@"cc.javelin.colloquy" forMeta:@"QSPreferredApplication"];
		[newObject setIdentifier:item];
		[newObject setObject:@"Server" forType:ColloquyServerType];
		[newObject setPrimaryType:ColloquyServerType];
		
		[objects addObject:newObject];
	}
	
	// Reset the children dictionary
	// Do it in one step in case we're threaded (I don't like locks :P)
	NSMutableDictionary *tempDict = objectChildren;
	objectChildren = [[NSMutableDictionary alloc] init];
	[tempDict release];
	
	return objects;
}

- (BOOL) objectHasValidChildren:(QSObject *)object {
	BOOL result = ([objectChildren objectForKey:[object identifier]] != nil);
	return result;
}

- (BOOL) objectHasChildren:(QSObject *)object {
	if ([[object primaryType] isEqualToString:ColloquyServerType]) {
		NSArray *rooms = [servers objectForKey:[object identifier]];
		return (rooms != nil && [rooms count] > 0);
	} else if ([[object primaryType] isEqualToString:NSFilenamesPboardType]) {
		NSDictionary *theEntry = [QSLib entryForID:@"QSPresetColloquyFavorites"];
		NSArray *newChildren = [QSLib objectsForEntry:theEntry scanIfNeeded:YES];
		return (newChildren != nil && [newChildren count] > 0);
	} else
		return NO;
}

- (BOOL) loadChildrenForObject:(QSObject *)object {
	if ([[object primaryType] isEqualToString:ColloquyServerType]) {
		NSMutableArray *rooms = [servers objectForKey:[object identifier]];
		if (rooms) {
			[objectChildren setObject:rooms forKey:[object identifier]];
			[object setChildren:rooms];
			return YES;
		} else {
			[objectChildren removeObjectForKey:[object identifier]];
			return NO;
		}
	} else if ([[object primaryType] isEqualToString:NSFilenamesPboardType]) {
		NSDictionary *theEntry = [QSLib entryForID:@"QSPresetColloquyFavorites"];
		NSArray *newChildren = [QSLib objectsForEntry:theEntry scanIfNeeded:YES];
		if (newChildren) {
			[objectChildren setObject:newChildren forKey:[object identifier]];
			[object setChildren:newChildren];
			return YES;
		} else {
			[objectChildren removeObjectForKey:[object identifier]];
			return NO;
		}
	} else
		return NO;
}

// Object Handler Methods
- (void) setQuickIconForObject:(QSObject *)object {
	if ([[object primaryType] isEqualToString:ColloquyServerType]) {
		[object setIcon:[QSResourceManager imageNamed:@"com.apple.Terminal"]];
	} else if ([[object primaryType] isEqualToString:ColloquyRoomType]) {
		if ([[object objectForType:ColloquyRoomType] isEqualToString:@"Bookmark"]) {
			[object setIcon:bookmarkImage];
		} else {
			if ([[object name] hasPrefix:@"#"] || [[object name] hasPrefix:@"&"] ||
				[[object name] hasPrefix:@"+"] || [[object name] hasPrefix:@"!"]) {
				[object setIcon:roomImage];
			} else {
				[object setIcon:personImage];
			}
		}
	}
}

@end

@implementation NSURL (TSURLAdditions)
- (BOOL) matchesURL:(NSURL *)other {
	if (![[self scheme] isEqualToString:[other scheme]]) return NO;
	if (![[self host] isEqualToString:[other host]]) return NO;
	if ([self port] && [other port] && ![[self port] isEqual:[other port]]) return NO;
	if ([self user] && [other user] && ![[self user] isEqualToString:[other user]]) return NO;
	if ([self password] && [other password] && ![[self password] isEqualToString:[other password]]) return NO;
	if ([self path] || [other path]) {
		NSString *selfPath = [self path];
		NSString *otherPath = [other path];
		if (!selfPath) selfPath = @"";
		if (!otherPath) otherPath = @"";
		if ([selfPath hasPrefix:@"/"]) selfPath = [selfPath substringFromIndex:1];
		if ([otherPath hasPrefix:@"/"]) otherPath = [otherPath substringFromIndex:1];
		if (![selfPath isEqualToString:otherPath]) return NO;
	}
	if ([self fragment] || [other fragment]) {
		if ([self fragment] && [other fragment]) {
			if (![[self fragment] isEqualToString:[other fragment]]) return NO;
		} else
			return NO;
	}
	if ([self query] || [other query]) {
		if ([self query] && [other query]) {
			if (![[self query] isEqualToString:[other query]]) return NO;
		} else
			return NO;
	}
	return YES;
}
@end

#define ColloquyServerJoinAction @"ColloquyServerJoinAction"
#define ColloquyServerMsgAction @"ColloquyServerMsgAction"

@implementation ColloquyActionProvider
- (id) init {
	if (self = [super init]) {
		NSBundle *plugin = [NSBundle bundleForClass:[self class]];
		roomImage = [[NSImage alloc] initByReferencingFile:
			[plugin pathForResource:@"room" ofType:@"tif"]];
		chatImage = [[NSImage alloc] initByReferencingFile:
			[plugin pathForResource:@"directChat" ofType:@"tif"]];
	}
	return self;
}

- (void) dealloc {
	[roomImage release];
	[super dealloc];
}

- (NSArray *) types {
	return [NSArray arrayWithObject:ColloquyServerType];
}

- (NSArray *) actions {
	NSBundle *plugin = [NSBundle bundleForClass:[self class]];
	NSMutableArray *actionArray = [NSMutableArray array];
	QSAction *action;
	
	action = [QSAction actionWithIdentifier:ColloquyServerJoinAction bundle:plugin];
	[action setIcon:roomImage];
	[action setProvider:self];
	[action setAction:@selector(tellServer:joinRoom:)];
	[action setArgumentCount:2];
	[action setDetails:@"Joins the specified room in this server"];
	[actionArray addObject:action];
	
	action = [QSAction actionWithIdentifier:ColloquyServerMsgAction bundle:plugin];
	[action setIcon:chatImage];
	[action setProvider:self];
	[action setAction:@selector(tellServer:msgUser:)];
	[action setArgumentCount:2];
	[action setDetails:@"Messages the selected user on this server"];
	[actionArray addObject:action];
	
	return actionArray;
}

- (NSArray *) validActionsForDirectObject:(QSObject *)dObject indirectObject:(QSObject *)iObject{
	return [NSArray arrayWithObjects:ColloquyServerJoinAction, ColloquyServerMsgAction, nil];
}

- (NSArray *)validIndirectObjectsForAction:(NSString *)action directObject:(QSObject *)dObject {
	return [NSArray arrayWithObject:[QSObject textProxyObjectWithDefaultValue:@""]];
}

- (QSObject *) tellServer:(QSObject *)dObject joinRoom:(QSObject *)iObject {
	NSURL *baseURL = [NSURL URLWithString:[dObject objectForType:QSURLType]];
	NSString *room = [iObject objectForType:QSTextType];
	if (![room hasPrefix:@"#"] && ![room hasPrefix:@"&"] &&
		![room hasPrefix:@"+"] && ![room hasPrefix:@"!"]) {
		room = [@"#" stringByAppendingString:room];
	}
	NSURL *fullURL = [NSURL URLWithString:room relativeToURL:baseURL];
	[[NSWorkspace sharedWorkspace] openURLs:[NSArray arrayWithObject:fullURL]
					withAppBundleIdentifier:@"cc.javelin.colloquy"
									options:NSWorkspaceLaunchDefault
			 additionalEventParamDescriptor:nil
						  launchIdentifiers:nil];
	
	return nil;
}

- (QSObject *) tellServer:(QSObject *)dObject msgUser:(QSObject *)iObject {
	NSURL *baseURL = [NSURL URLWithString:[dObject objectForType:QSURLType]];
	NSString *room = [iObject objectForType:QSTextType];
	if ([room hasPrefix:@"#"] || [room hasPrefix:@"&"] ||
		[room hasPrefix:@"+"] || [room hasPrefix:@"!"]) {
		room = [room substringFromIndex:1];
	}
	NSURL *fullURL = [NSURL URLWithString:room relativeToURL:baseURL];
	[[NSWorkspace sharedWorkspace] openURLs:[NSArray arrayWithObject:fullURL]
					withAppBundleIdentifier:@"cc.javelin.colloquy"
									options:NSWorkspaceLaunchDefault
			 additionalEventParamDescriptor:nil
						  launchIdentifiers:nil];
	
	return nil;
}

@end
