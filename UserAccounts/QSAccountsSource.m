

#import "QSAccountsSource.h"
#import <QSCore/QSCore.h>

#define userAttributes [NSArray arrayWithObjects:@"uid",@"name",@"realname",@"home",@"sharedDir",@"picture",nil]

@implementation QSAccountsSource

- (NSImage *) iconForEntry:(NSDictionary *)dict{
	return [[NSBundle bundleForClass:[self class]] imageNamed:@"User"];
}

- (void)dealloc{
	[super dealloc];
}
- (NSString *)identifierForObject:(QSObject*)object{
    return [@"[uid]:"stringByAppendingString:[[object objectForType:QSUserPboardType]objectForKey:@"uid"]];
}

- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry{
	NSDate *modDate=[[[NSFileManager defaultManager] fileAttributesAtPath:@"/var/db/netinfo/local.nidb" traverseLink:YES]fileModificationDate];
	return [modDate compare:indexDate]==NSOrderedAscending;
//    return [[NSDate date]timeIntervalSinceDate:indexDate]>60*60*24;
}
- (NSArray *) objectsForEntry:(NSDictionary *)theEntry{
    

    if ( (bool)getenv("USERBREAK")){
        NSLog(@"Skipping User Accounts");
        return nil;
    }
    
  //  NSWorkspace *workspace=[NSWorkspace sharedWorkspace];
    
   //  nireport local@localhost /users uid name realname home sharedDir
     NSTask *getUsersTask=[[[NSTask alloc] init]autorelease];

	NSPipe *output=[NSPipe pipe];
	if (output)
		[getUsersTask setStandardOutput:output];
	else
		NSLog(@"Couldn't get pipe");
     [getUsersTask setLaunchPath:@"/usr/bin/nireport"];
     [getUsersTask setArguments:[[NSArray arrayWithObjects:@"local@localhost", @"/users",nil]arrayByAddingObjectsFromArray:userAttributes]];
     [getUsersTask launch];
     [getUsersTask waitUntilExit];
     
     
     NSString *string=[[[NSString alloc]initWithData:[[output fileHandleForReading] readDataToEndOfFile] encoding:NSUTF8StringEncoding]autorelease];
     
     NSArray *users=[string componentsSeparatedByString:@"\n"];
     
     NSMutableArray *objects=[NSMutableArray arrayWithCapacity:[users count]];
     
     int i;
     QSObject *newObject;
     int attributeCount=[userAttributes count];
     NSArray *attributes=nil;
     
     for (i=0;i<[users count];i++){
         
         attributes=[[users objectAtIndex:i]componentsSeparatedByString:@"\t"];
         if ([attributes count]<attributeCount) continue;
         
         NSDictionary *userDictionary=[NSDictionary dictionaryWithObjects:[attributes subarrayWithRange:NSMakeRange(0,attributeCount)]
                                                                  forKeys:userAttributes];
         NSString *name=[userDictionary objectForKey:@"name"];
         NSString *realname=[userDictionary objectForKey:@"realname"];
         
         if (!name)continue;
         if ([[userDictionary objectForKey:@"uid"]intValue]<500)continue;
         newObject=[QSObject objectWithName:name];
         if(realname) [newObject setLabel:realname];
         [newObject setObject:userDictionary forType:QSUserPboardType];
         [newObject setPrimaryType:QSUserPboardType];
         [objects addObject:newObject];

     }
     
     return objects;
     return nil;
}

// Object Handler Methods

- (BOOL)loadIconForObject:(QSObject *)object{
    NSString *imagePath=[[object objectForType:QSUserPboardType] objectForKey:@"picture"];
    
    NSImage *image=nil;
    if (imagePath) image=[[[NSImage alloc]initWithContentsOfFile:imagePath]autorelease];
    if (!image) image=[[NSBundle bundleForClass:[self class]] imageNamed:@"User"];
    [image createIconRepresentations];
    [object setIcon:image];
    return YES;
}



- (QSObject *) switchToUser:(QSObject *)dObject{
    
    NSString *uid=[[dObject objectForType:QSUserPboardType] objectForKey:@"uid"];
    NSTask *getUsersTask=[[[NSTask alloc] init]autorelease];
    [getUsersTask setStandardOutput:[NSPipe pipe]];
    [getUsersTask setLaunchPath:@"/System/Library/CoreServices/Menu Extras/User.menu/Contents/Resources/CGSession"];
    [getUsersTask setArguments:[NSArray arrayWithObjects:@"-switchToUserID",uid,nil]];
    [getUsersTask launch];    
    return nil;
    ///System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -switchToUserID $USERID
}


@end
