//
//  QSTransmitModule_Source.m
//  QSTransmitModule
//
//  Created by Nicholas Jitkoff on 7/12/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//
#import "src/FavoriteCollection.h"
#import "Favorite.h"

#import "QSTransmitModule_Source.h"
#import <QSCore/QSCore.h>

#import <QSFoundation/QSFoundation.h>

#define TRANSMIT_ID @"com.panic.Transmit3"
#define QSTransmitSiteType @"QSTransmitSiteType"

@implementation FavoriteCollection (BLTRConvenience)
+ (FavoriteCollection *)mainCollection{
	NSString *prefsPath = [@"~/Library/Preferences/com.panic.Transmit3.plist" stringByStandardizingPath];
	NSDictionary *prefsDict = [NSDictionary dictionaryWithContentsOfFile:prefsPath];
	if ( prefsDict )
	{
		NSData *storedData = [prefsDict objectForKey:@"Collections2"];
		if ( storedData )
		{		
			return [NSKeyedUnarchiver unarchiveObjectWithData:storedData];
		}
	}
	return nil;
}

@end

//NSURLPboardType
@implementation QSTransmitSource
- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry{
	NSDate *modDate=[[[NSFileManager defaultManager] fileAttributesAtPath:[@"~/Library/Preferences/com.panic.Transmit3.plist" stringByStandardizingPath] traverseLink:YES]fileModificationDate];
	return [modDate compare:indexDate]==NSOrderedAscending;
}

- (void)setQuickIconForObject:(QSObject *)object{
	[object setIcon:[QSResourceManager imageNamed:@"com.panic.Transmit3"]];	
}

- (NSImage *) iconForEntry:(NSDictionary *)dict{
    return [QSResourceManager imageNamed:TRANSMIT_ID];
}
- (BOOL)loadChildrenForObject:(QSObject *)object{
	if ([object containsType:QSFilePathType]){
		[object setChildren:[self objectsForEntry:nil]];
		return YES;   	
	}else{
		
		if([object objectForMeta:@"QSObjectSubpath"])return NO;
		NSString *uuid=[object objectForType:QSTransmitSiteType];
			Favorite *fav=[[FavoriteCollection mainCollection]itemWithUUID:uuid];
		NSArray *paths=[fav remotePathShortcuts];
		//NSLog(@"path %@ %@ %@",uuid,[FavoriteCollection mainCollection],paths);
		NSMutableArray *objects=[NSMutableArray array];
		foreach(path,paths){
			QSObject *newObject=[self objectForFavorite:fav subpath:path];
			[objects addObject:newObject];
		}
		[object setChildren:objects];
		return YES;
	}
	return NO;
}

//- (NSString *)identifierForObject:(id <QSObject>)object{
//   return [@"[Sherlock Channel]:"stringByAppendingString:[object objectForType:QSSherlockChannelIDType]];
//}


- (NSArray *) objectsForEntry:(NSDictionary *)theEntry{
	NSFileManager *fm=[NSFileManager defaultManager];
	NSString *metadataPath=[@"~/Library/Caches/Metadata/Transmit" stringByStandardizingPath];
	
	NSDirectoryEnumerator *de=[fm enumeratorAtPath:metadataPath];
	
	NSMutableArray *objects=[NSMutableArray arrayWithCapacity:1];
	QSObject *newObject;
	NSString *key;
	
	//
	//	NSString *path;
	//	while (path=[de nextObject]){
	//		NSDictionary *dict=[NSDictionary dictionaryWithContentsOfFile:[metadataPath stringByAppendingPathComponent:path]];
	//		
	//		newObject=[QSObject objectWithName:[dict objectForKey:@"com_panic_transmit_nickname"]];
	//		NSString *url=[self URLForNewTransmitDict:dict];
	//		
	//		[newObject setObject:dict forType:QSTransmitSiteType];
	//		[newObject setObject:url forType:QSURLType];
	//		[newObject setPrimaryType:QSURLType];
	//		[newObject setObject:TRANSMIT_ID forMeta:@"QSPreferredApplication"];
	//		[objects addObject:newObject];
	//	}
	
	{
		FavoriteCollection *rootCollection=[FavoriteCollection mainCollection];
		NSEnumerator *enumerator = [[rootCollection allObjects] objectEnumerator];
		FavoriteCollection *curCollection;
		
		//NSLog(@"Loaded favorites");
		
		while ( (curCollection = [enumerator nextObject]) != nil )
		{
			//	NSLog([curCollection name]);
			
			NSEnumerator *subEnumerator = [[curCollection allObjects] objectEnumerator];
			Favorite *curFavorite;
			if ([curCollection type]!=kFolderType) continue;
			
			while ( (curFavorite = [subEnumerator nextObject]) != nil )
			{
				
				newObject=[self objectForFavorite:curFavorite subpath:nil];
				[objects addObject:newObject];
				
				
				//NSLog(@"\t%@", [curFavorite nickname]);
			}
		}
	}
	
	return objects;
}


- (QSObject *)objectForFavorite:(Favorite *)curFavorite subpath:(NSString *)subpath{
	NSString *url=[self URLForFavorite:curFavorite subpath:subpath];
	NSString *name=[curFavorite nickname];
	if (subpath)name=[name stringByAppendingFormat:@" - %@",[subpath lastPathComponent]];
	QSObject *newObject=[QSObject objectWithName:name];
				//NSString *url=[self URLForNewTransmitDict:dict];
				
				[newObject setObject:[curFavorite UUID] forType:QSTransmitSiteType];
				[newObject setObject:url forType:QSURLType];
				[newObject setPrimaryType:QSTransmitSiteType];
				[newObject setObject:TRANSMIT_ID forMeta:@"QSPreferredApplication"];
				[newObject setObject:subpath forMeta:@"QSObjectSubpath"];
				[newObject setIdentifier:[curFavorite UUID]];
				
				[newObject setDetails:subpath?subpath:[url stringByReplacing:@":PasswordInKeychain" with:@""]];
				return newObject;
}


- (NSArray *) alternateObjectsForEntry:(NSDictionary *)theEntry{
	NSFileManager *fm=[NSFileManager defaultManager];
	NSString *metadataPath=[@"~/Library/Caches/Metadata/Transmit" stringByStandardizingPath];
	
	NSDirectoryEnumerator *de=[fm enumeratorAtPath:metadataPath];
	
	NSMutableArray *objects=[NSMutableArray arrayWithCapacity:1];
	QSObject *newObject;
	NSString *key;
	
	
	NSString *path;
	while (path=[de nextObject]){
		NSDictionary *dict=[NSDictionary dictionaryWithContentsOfFile:[metadataPath stringByAppendingPathComponent:path]];
		
		newObject=[QSObject objectWithName:[dict objectForKey:@"com_panic_transmit_nickname"]];
		NSString *url=[self URLForNewTransmitDict:dict];
		
		[newObject setObject:dict forType:QSTransmitSiteType];
		[newObject setObject:url forType:QSURLType];
		[newObject setPrimaryType:QSURLType];
		[newObject setObject:TRANSMIT_ID forMeta:@"QSPreferredApplication"];
		[objects addObject:newObject];
	}
	
    return objects;
    
}



//- (NSArray *) anotheroldobjectsForEntry:(NSDictionary *)theEntry{
//    NSArray *collections= (NSArray *)CFPreferencesCopyAppValue((CFStringRef)@"Collections",(CFStringRef) TRANSMIT_ID);
//	
//	//NSLog(@"collections %@",[NSKeyedUnarchiver unarchiveObjectWithData:collections]);
//    [collections autorelease];
//	NSMutableArray *objects=[NSMutableArray arrayWithCapacity:1];
//	QSObject *newObject;
//	NSString *key;
//	
//	foreach(collection, collections){
//		NSArray *contents=[collection objectForKey:@"CollectionContents"];
//		NSDictionary *thisFavorite;
//		NSEnumerator *e=[contents objectEnumerator];
//		while(thisFavorite=[e nextObject]){
//			newObject=[QSObject objectWithName:[thisFavorite objectForKey:@"Nickname"]];
//			NSString *url=[self URLForTransmitDict:thisFavorite];
//			
//			[newObject setObject:thisFavorite forType:QSTransmitSiteType];
//			[newObject setObject:url forType:QSURLType];
//			[newObject setPrimaryType:QSURLType];
//			[newObject setObject:TRANSMIT_ID forMeta:@"QSPreferredApplication"];
//			[objects addObject:newObject];
//		}
//	}
//    return objects;
//    
//}
/*
 - (NSArray *) oldObjectsForEntry:(NSDictionary *)theEntry{
	 NSArray *favorites= (NSArray *)CFPreferencesCopyAppValue((CFStringRef)@"Favorites",(CFStringRef) TRANSMIT_ID);
	 [favorites autorelease];
	 
	 
	 NSMutableArray *objects=[NSMutableArray arrayWithCapacity:1];
	 QSObject *newObject;
	 NSString *key;
	 NSDictionary *thisFavorite;
	 NSEnumerator *e=[favorites objectEnumerator];
	 while(thisFavorite=[e nextObject]){
		 newObject=[QSObject objectWithName:[thisFavorite objectForKey:@"Nickname"]];
		 NSString *url=[self URLForTransmitDict:thisFavorite];
		 
		 [newObject setObject:thisFavorite forType:QSTransmitSiteType];
		 [newObject setObject:url forType:QSURLType];
		 [newObject setPrimaryType:QSURLType];
		 [newObject setObject:TRANSMIT_ID forMeta:@"QSPreferredApplication"];
		 [objects addObject:newObject];
	 }
	 return objects;
	 
 }
 */
/*
 tell application "Transmit"
	run
	set theDocument to make new document
	ignoring application responses
 connect (theDocument) to "macsavants.com" as user "nicholas" with password "PasswordInKeychain" with connection type FTP
 activate
	end ignoring
 end tell
 
 */

- (NSString *)URLForTransmitDict:(NSDictionary *)dict{
	NSString *initialPath=[dict objectForKey:@"InitialPath"];
	NSString *protocol=[dict objectForKey:@"Protocol"];
	NSString *remoteHost=[dict objectForKey:@"RemoteHost"];
	NSString *remotePassword=[dict objectForKey:@"RemotePassword"];
	NSString *remotePort=[dict objectForKey:@"RemotePort"];
	NSString *remoteUser=[dict objectForKey:@"RemoteUser"];
	
	//	if ([remotePassword isEqualToString:@"PasswordInKeychain"])remotePassword=@"";
	
	NSString *authent=nil;
	if ([remoteUser length]){
		if ([remotePassword length]) authent=[NSString stringWithFormat:@"%@:%@",[remoteUser stringByReplacing:@"@" with:@"%40"],remotePassword];
		else authent=remoteUser;
	}
	
	NSString *string=[NSString stringWithFormat:@"%@://%@%@%@%@",
		[protocol lowercaseString],
		([authent length]?[authent stringByAppendingString:@"@"]:@""),
		remoteHost,
		(remotePort?[@":" stringByAppendingString:remotePort]:@""),
		([initialPath length]?[@"/" stringByAppendingString:initialPath]:@"")
		];
}
- (NSString *)URLForFavorite:(Favorite *)fav subpath:(NSString *)subpath{
	NSString *initialPath=subpath?subpath:[fav initialRemotePath];
	if (![initialPath hasPrefix:@"/"])initialPath=[@"/" stringByAppendingString:initialPath];
	NSString *protocol=[fav protocol];
	NSString *remoteHost=[fav server];
	NSString *remotePassword=nil;
	NSString *remotePort=[fav port]?[NSString stringWithFormat:@"%d",[fav port]]:nil;
	NSString *remoteUser=[fav username];
	BOOL prompt=[fav promptForPassword];
	if (!prompt)
		remotePassword=@"PasswordInKeychain";
	
	//	if ([remotePassword isEqualToString:@"PasswordInKeychain"])remotePassword=@"";
	
	NSString *authent=nil;
	if ([remoteUser length]){
		if ([remotePassword length]) authent=[NSString stringWithFormat:@"%@:%@",[remoteUser stringByReplacing:@"@" with:@"%40"],remotePassword];
		else authent=remoteUser;
	}
	
	NSString *string=[NSString stringWithFormat:@"%@://%@%@%@%@",
		[protocol lowercaseString],
		([authent length]?[authent stringByAppendingString:@"@"]:@""),
		remoteHost,
		(remotePort?[@":" stringByAppendingString:remotePort]:@""),
		([initialPath length]?[initialPath URLEncoding]:@"")
		];
}



- (NSString *)URLForNewTransmitDict:(NSDictionary *)dict{
	NSString *initialPath=[dict objectForKey:@"com_panic_transmit_remotePath"];
	NSString *protocol=[dict objectForKey:@"com_panic_transmit_protocol"];
	NSString *remoteHost=[dict objectForKey:@"com_panic_transmit_server"];
	NSString *remotePassword=nil; //[dict objectForKey:@"RemotePassword"];
	BOOL prompt=[[dict objectForKey:@"com_panic_transmit_promptPassword"]boolValue];
	if (!prompt)
		remotePassword=@"PasswordInKeychain";
	NSString *remotePort=[dict objectForKey:@"com_panic_transmit_port"];
	NSString *remoteUser=[dict objectForKey:@"com_panic_transmit_username"];
	
	//	if ([remotePassword isEqualToString:@"PasswordInKeychain"])remotePassword=@"";
	
	NSString *authent=nil;
	if ([remoteUser length]){
		if ([remotePassword length]) authent=[NSString stringWithFormat:@"%@:%@",[remoteUser stringByReplacing:@"@" with:@"%40"],remotePassword];
		else authent=remoteUser;
	}
	
	NSString *string=[NSString stringWithFormat:@"%@://%@%@%@%@",
		[protocol lowercaseString],
		([authent length]?[authent stringByAppendingString:@"@"]:@""),
		remoteHost,
		(remotePort?remotePort:@""),
		([initialPath length]?[@"/" stringByAppendingString:initialPath]:@"")
		];
}


// Object Handler Methods

/*
 - (void)setQuickIconForObject:(QSObject *)object{
	 [object setIcon:nil]; // An icon that is either already in memory or easy to load
 }
 - (BOOL)loadIconForObject:(QSObject *)object{
	 return NO;
	 id data=[object objectForType:QSTransmitModuleType];
	 [object setIcon:nil];
	 return YES;
 }
 */






- (NSArray *)validIndirectObjectsForAction:(NSString *)action directObject:(QSObject *)iObject{
	return [self objectsForEntry:nil]; 
}

-(QSObject *)uploadFiles:(QSObject *)dObject toSite:(QSObject *)iObject{
	//NSLog(@"objects %@ %@",dObject,iObject);	
	
	NSString *path=[[NSBundle bundleForClass:[self class]]pathForResource:@"Transmit" ofType:@"scpt"];
	NSAppleScript *script=nil;
	if (path)
		script=[[[NSAppleScript alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:nil]autorelease];
	
	NSString *uuid=[iObject objectForType:QSTransmitSiteType];
	Favorite *favorite=[[FavoriteCollection mainCollection]itemWithUUID:uuid];
	
	//NSString *initialPath=[dict objectForKey:@"InitialPath"];
	
	NSString *site=[favorite server];
	NSString *port=[favorite port]?[NSString stringWithFormat:@"%d",[favorite port]]:nil;
	NSString *user=[favorite username];
	
	if (!port)port=@"";
	NSString *pass=@"";//[dict objectForKey:@"RemotePassword"];
		
		BOOL prompt=[favorite promptForPassword];
		if (!prompt)pass=@"PasswordInKeychain";
		
		
		NSString *initialPath=[iObject objectForMeta:@"QSObjectSubpath"];
		if (!initialPath)initialPath=[favorite initialRemotePath];
		
		NSString *protocol=[favorite protocol];
		NSString *your_stuff=@"";
		
		
		NSArray *arguments=[NSArray arrayWithObjects:site,port,user,pass,protocol,initialPath,@"",[dObject validPaths],nil];
		//NSLog(@"args %@",arguments);
		NSDictionary *dict=nil;
		[script executeSubroutine:@"upload_to_site" arguments:arguments error:&dict];
		if (dict)NSLog(@"Upload Error: %@",dict);
		
		return nil;	
}

//-(QSObject *)oldUploadFiles:(QSObject *)dObject toSite:(QSObject *)iObject{
//	NSLog(@"objects %@ %@",dObject,iObject);	
//	
//	NSString *path=[[NSBundle bundleForClass:[self class]]pathForResource:@"Transmit" ofType:@"scpt"];
//	NSAppleScript *script=nil;
//	if (path)
//		script=[[[NSAppleScript alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:nil]autorelease];
//	
//	NSDictionary *dict=[iObject objectForType:QSTransmitSiteType];
//	//NSString *initialPath=[dict objectForKey:@"InitialPath"];
//	
//	NSString *site=[dict objectForKey:@"com_panic_transmit_server"];
//	NSString *port=[dict objectForKey:@"com_panic_transmit_port"];
//	NSString *user=[dict objectForKey:@"com_panic_transmit_username"];
//	
//	if (!port)port=@"";
//	NSString *pass=@"";//[dict objectForKey:@"RemotePassword"];
//		
//		BOOL prompt=[[dict objectForKey:@"com_panic_transmit_promptPassword"]boolValue];
//		if (!prompt)pass=@"PasswordInKeychain";
//		
//		NSString *initialPath=[dict objectForKey:@"com_panic_transmit_remotePath"];
//		
//		NSString *protocol=[dict objectForKey:@"com_panic_transmit_protocol"];
//		NSString *your_stuff=@"";
//		
//		
//		NSArray *arguments=[NSArray arrayWithObjects:site,port,user,pass,protocol,initialPath,@"",[dObject validPaths],nil];
//		dict=nil;
//		[script executeSubroutine:@"upload_to_site" arguments:arguments error:&dict];
//		if (dict)NSLog(@"Upload Error: %@",dict);
//		
//		return nil;	
//}

@end
