//
//  QSYojimboPlugInSource.h
//  QSYojimboPlugIn
//
//  Created by Nicholas Jitkoff on 5/14/06.
//  Copyright __MyCompanyName__ 2006. All rights reserved.
//

#import <QSCore/QSObjectSource.h>

@interface QSYojimboPlugInSource : QSObjectSource
{
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
//	@property BOOL enabled;
}
@end

