//
//  QSYojimboPlugInSource.m
//  QSYojimboPlugIn
//
//  Created by Nicholas Jitkoff on 5/14/06.
//  Copyright __MyCompanyName__ 2006. All rights reserved.
//

#import "QSYojimboPlugInSource.h"
#import <QSCore/QSObject.h>
#import "QSYojimboPlugInDefines.h"


@implementation QSYojimboPlugInSource
- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry{
    NSString *path = [@"~/Library/Caches/Metadata/com.barebones.yojimbo" stringByStandardizingPath];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSDate *modified = [[manager fileAttributesAtPath:path traverseLink:YES] fileModificationDate];
    
    return [indexDate compare:modified] == NSOrderedDescending;
}

- (NSImage *) iconForEntry:(NSDictionary *)dict{
    return [QSResourceManager imageNamed:@"com.barebones.yojimbo"];
}


// Return a unique identifier for an object (if you haven't assigned one before)
//- (NSString *)identifierForObject:(id <QSObject>)object{
//    return nil;
//}
- (BOOL)loadChildrenForObject:(QSObject *)object{
    [object setChildren:[self objectsForEntry:nil]];
    return TRUE;
}

- (NSArray *) objectsForEntry:(NSDictionary *)theEntry{
    NSString *path = [@"~/Library/Caches/Metadata/com.barebones.yojimbo" stringByStandardizingPath];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *contents = [manager directoryContentsAtPath:path];
    
    NSMutableArray *objects=[NSMutableArray arrayWithCapacity:1];
    QSObject *newObject = nil;
    QSObject *tagObject = nil;
    NSMutableDictionary *tags = [NSMutableDictionary dictionaryWithCapacity:1];
    
    for (NSString *topLevelDir in contents) {
        topLevelDir = [path stringByAppendingPathComponent:topLevelDir];
        for (NSString *secondLevelDir in [manager directoryContentsAtPath:topLevelDir]) {
            secondLevelDir = [topLevelDir stringByAppendingPathComponent:secondLevelDir];
            for (NSString *yojimboItem in [manager directoryContentsAtPath:secondLevelDir]) {
                if ([yojimboItem rangeOfString:@"yojimbo"].location == NSNotFound) continue;
                yojimboItem = [secondLevelDir stringByAppendingPathComponent:yojimboItem];
                NSDictionary *item = [NSDictionary dictionaryWithContentsOfFile:yojimboItem];
                newObject = nil;
                
                @try {
                    if ([[item valueForKey:@"itemKind"] isEqualToString:@"com.barebones.yojimbo.yojimbobookmark"]) {
                        // Christ, BareBones! You can't settle on a capitalization scheme for dictionary keys?
                        NSString *URLString;
                        if ([item valueForKey:@"URLString"]) {
                            URLString = [item valueForKey:@"URLString"];
                        } else if ([item valueForKey:@"urlString"]) {
                            URLString = [item valueForKey:@"urlString"];
                        }
                        newObject = [QSObject URLObjectWithURL:URLString title:[item valueForKey:@"name"]];
                    } else {
                        newObject=[QSObject objectWithName:[item valueForKey:@"name"]];
                    }
                    
                    // [newObject setName:[item valueForKey:@"name"]];
                    [newObject setDetails:[item valueForKey:@"itemKind"]];
                    if ([[item valueForKey:@"encrypted"]boolValue]){
                        [newObject setDetails:@"Encrypted"];
                    }                    [newObject setIdentifier:[item valueForKey:@"uuid"]];
                    [newObject setObject:[item valueForKey:@"uuid"] forType:kQSYojimboPlugInType];
                    // store the type of Yojimbo item
                    [newObject setObject:[item valueForKey:@"itemKind"] forMeta:@"itemKind"];
                    
                    // get a list of all tags and the associated items
                    for (NSString *tag in [item valueForKey:@"tags"])
                    {
                        if ([[tags allKeys] containsObject:tag])
                        {
                            // append to the list
                            [[tags objectForKey:tag] addObject:[item valueForKey:@"uuid"]];
                        } else {
                            // create a list of items for this tag
                            NSMutableArray *itemsForTag = [NSMutableArray arrayWithObject:[item valueForKey:@"uuid"]];
                            [tags setObject:itemsForTag forKey:tag];
                        }
                    }
                    
                    if (newObject)
                        [objects addObject:newObject];
                }
                @catch (id theException) {
                    NSLog(@"error with: %@ %@", item, theException);
                }
            }
        }
    }
    // add tags to the catalog
    for (NSString *tag in [tags allKeys])
    {
        NSString *ident = [NSString stringWithFormat:@"yojimbotag:%@", tag];
        tagObject = [QSObject objectWithName:tag];
        [tagObject setIdentifier:ident];
        [tagObject setObject:tag forType:kQSYojimboTagType];
        [tagObject setObject:[tags objectForKey:tag] forMeta:@"items"];
        // tags don't have an official itemKind, but I'm making one up for consitency
        [tagObject setObject:kQSYojimboTagType forMeta:@"itemKind"];
        [tagObject setDetails:@"Yojimbo Tag"];
        [objects addObject:tagObject];
    }
    return objects;
}
//
//- (NSArray *) objectsForEntry:(NSDictionary *)theEntry{
//	NSManagedObjectContext *moc=[self managedObjectContext];	
//	[moc reset];
//
//	NSEntityDescription *entityDescription = [NSEntityDescription
//    entityForName:@"Item" inManagedObjectContext:moc];
//	//NSLog(@"entity %@",entityDescription);
//	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
//	[request setEntity:entityDescription];
//	
//	// Set example predicate and sort orderings...
//	//	NSPredicate *predicate = [NSPredicate predicateWithFormat:
//	//		@"lastName LIKE[c] 'Worsley'"];
//	//	[request setPredicate:predicate];
//	
//	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
//    initWithKey:@"name" ascending:YES];
//	[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
//	[sortDescriptor release];
//	
//	NSError *error = nil;
//	NSArray *array = [moc executeFetchRequest:request error:&error];
//
//	
//	
//	NSMutableArray *objects=[NSMutableArray arrayWithCapacity:1];
//    QSObject *newObject;
//	
//	foreach(item,array){
//		NSString *entityName=[[item entity]name];
//		newObject=nil;
//		//NSLog(@"entity %@",entityName);
//		//if ([[item valueForKey:@"encrypted"]boolValue])continue;
//		@try{
//		if ([[item valueForKey:@"encrypted"]boolValue]){
//			newObject=[QSObject objectWithName:[item valueForKey:@"name"]];
//			[newObject setDetails:@"Encrypted"];
//		//	NSLog(@"encrypt %@",newObject);
//			
//		}	else if ([entityName isEqualToString:@"Note"]){
//			NSString *string=[item valueForKeyPath:@"blob.string"];
//			if (string)
//				newObject=[QSObject objectWithString:string];
//				[newObject setDetails:@"Note"];
////			NSLog(@"entity %@",[[[NSString alloc]initWithData:[item valueForKeyPath:@"blob.bytes"]encoding:NSUTF8StringEncoding]autorelease]);
//		}else if ([entityName isEqualToString:@"Password"]){
//			//newObject=[QSObject objectWithString:[item valueForKey:@"password"]];
//				[newObject setDetails:@"Password"];
//		}else if ([entityName isEqualToString:@"WebArchive"]){
//			newObject=[QSObject URLObjectWithURL:[item valueForKey:@"sourceUrlString"] title:@""];
//				[newObject setDetails:@"Web Archive"];
//		}else if ([entityName isEqualToString:@"WebBookmark"]){
//			newObject=[QSObject URLObjectWithURL:[item valueForKey:@"urlString"] title:@""];
//		}else if ([entityName isEqualToString:@"PDFArchive"]){
//				newObject=[QSObject objectWithName:[item valueForKey:@"name"]];
//	[newObject setDetails:@"PDF archive"];			
//		}
//		
//		[newObject setName:[item valueForKey:@"name"]];
//		[newObject setIdentifier:[item valueForKey:@"uuid"]];
//		[newObject setObject:[item valueForKey:@"uuid"] forType:kQSYojimboPlugInType];
//		//[newObject setPrimaryType:kQSYojimboPlugInType];
//		//NSLog(@"got %@",newObject);
//		
//		if (newObject)
//			[objects addObject:newObject];
//			}
//			@catch (id theException) {
//			NSLog(@"error with: %@ %@", item, theException);
//			}
//	}
//    return objects;
//    
//}


// Object Handler Methods

- (void)setQuickIconForObject:(QSObject *)object{
    // set some useful icons depending on the type of object
    if ([[object objectForMeta:@"itemKind"] isEqualToString:@"com.barebones.yojimbo.tag"])
    {
        [object setIcon:[QSResourceManager imageNamed:@"com.barebones.yojimbo"]];
    } else if ([[object objectForMeta:@"itemKind"] isEqualToString:@"com.barebones.yojimbo.yojimbopdfarchive"]) {
        [object setIcon:[[NSWorkspace sharedWorkspace] iconForFileType:@"pdf"]];
    } else {
        [object setIcon:[[NSWorkspace sharedWorkspace] iconForFileType:@"yojimbonote"]];
    }
}
/*
- (BOOL)loadIconForObject:(QSObject *)object{
	return NO;
    id data=[object objectForType:kQSYojimboPlugInType];
	[object setIcon:nil];
    return YES;
}
*/



//
///**
//Returns the support folder for the application, used to store the Core Data
// store file.  This code uses a folder named "QSYojimboPlugInApp" for
// the content, either in the NSApplicationSupportDirectory location or (if the
//																	   former cannot be found), the system's temporary directory.
// */
//
//- (NSString *)applicationSupportFolder {
//	
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
//    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
//    return [basePath stringByAppendingPathComponent:@"Yojimbo"];
//}
//
//
///**
//Creates, retains, and returns the managed object model for the application 
// by merging all of the models found in the application bundle and all of the 
// framework bundles.
// */
//
//- (NSManagedObjectModel *)managedObjectModel {
//	
//    if (managedObjectModel != nil) {
//        return managedObjectModel;
//    }
//	
//   // NSMutableSet *allBundles = [[NSMutableSet alloc] init];
//	//  [allBundles addObject: [NSBundle mainBundle]];
//	// [allBundles addObjectsFromArray: [NSBundle allFrameworks]];
//    
//	NSString *yojimboPath=[[NSWorkspace sharedWorkspace]absolutePathForAppBundleWithIdentifier:@"com.barebones.yojimbo"];
//	//[allBundles addObject: [NSBundle bundleWithPath:yojimboPath]];
//    
//	//NSLog(@"yoj %@",[NSBundle bundleWithPath:yojimboPath]);
//    //managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles: [allBundles allObjects]] retain];
//	NSURL *modelURL = [NSURL fileURLWithPath:[[NSBundle bundleWithPath:yojimboPath] pathForResource:@"YojimboData"
//	 ofType:@"mom"]];
//	managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
//    //[allBundles release];
//    
//	// 	NSLog(@"yoj %@",managedObjectModel);
//	
//	return managedObjectModel;
//}
//
//
///**
//Returns the persistent store coordinator for the application.  This 
// implementation will create and return a coordinator, having added the 
// store for the application to it.  (The folder for the store is created, 
//									if necessary.)
// */
//
//- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {
//	
//    if (persistentStoreCoordinator != nil) {
//        return persistentStoreCoordinator;
//    }
//	
//    NSFileManager *fileManager;
//    NSString *applicationSupportFolder = nil;
//    NSURL *url;
//    NSError *error;
//    
//    fileManager = [NSFileManager defaultManager];
//    applicationSupportFolder = [self applicationSupportFolder];
//    if ( ![fileManager fileExistsAtPath:applicationSupportFolder isDirectory:NULL] ) {
//        [fileManager createDirectoryAtPath:applicationSupportFolder attributes:nil];
//    }
//    
//    url = [NSURL fileURLWithPath: [applicationSupportFolder stringByAppendingPathComponent: @"Database.sqlite"]];
//    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
//    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:nil error:&error]){
//        [[NSApplication sharedApplication] presentError:error];
//    }    
//	
//    return persistentStoreCoordinator;
//}
//
//
///**
//Returns the managed object context for the application (which is already
//														bound to the persistent store coordinator for the application.) 
// */
//
//- (NSManagedObjectContext *) managedObjectContext {
//	
//    if (managedObjectContext != nil) {
//        return managedObjectContext;
//    }
//	
//    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
//    if (coordinator != nil) {
//        managedObjectContext = [[NSManagedObjectContext alloc] init];
//        [managedObjectContext setPersistentStoreCoordinator: coordinator];
//    }
//    
//    return managedObjectContext;
//}


@end
