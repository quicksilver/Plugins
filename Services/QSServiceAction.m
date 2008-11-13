

#import "QSServiceAction.h"

#import <QSCore/QSCore.h>
#import <QSCore/QSObject_Pasteboard.h>
#import <QSCore/QSLibrarian.h>
#import <QSCore/QSExecutor.h>
#import <QSFoundation/NSWorkspace_BLTRExtensions.h>

#define NSServicesKey	 		@"NSServices"
#define NSMenuItemKey	 		@"NSMenuItem"
#define NSMenuItemDisabledKey 		@"NSMenuItem (Disabled)"

#define NSSendTypesKey	 		@"NSSendTypes"
#define NSReturnTypesKey	 	@"NSReturnTypes"

#define DefaultKey	 		@"default"
#define NSKeyEquivalentKey 		@"NSKeyEquivalent"
#define infoPath			@"Contents/Info.plist"

NSMutableArray *servicesForBundle(NSString *path){
    if (path){
        NSString *dictPath=[path stringByAppendingPathComponent:infoPath];
        NSMutableDictionary *infoDictionary=[NSMutableDictionary dictionaryWithContentsOfFile:dictPath];
        return [infoDictionary objectForKey:NSServicesKey];
    }
    return nil;
}
NSArray *providersAtPath(NSString *path){
    //NSLog(path);
    NSFileManager *manager=[NSFileManager defaultManager];
    //NSWorkspace *workspace=[NSWorkspace sharedWorkspace];
    
    path=[path stringByStandardizingPath];
    
    NSMutableArray *providers=[NSMutableArray arrayWithCapacity:1];
    NSString *itemPath;
    
    NSArray *subPaths=[manager subpathsAtPath:path];
    int i;
    
    for (i=0;i<[subPaths count];i++){
        itemPath=[subPaths objectAtIndex:i];
        if ([itemPath hasSuffix:infoPath]){
            itemPath=[path stringByAppendingPathComponent:itemPath];
            if ([[NSMutableDictionary dictionaryWithContentsOfFile:itemPath] objectForKey:NSServicesKey]){
                [providers addObject:[[itemPath stringByDeletingLastPathComponent]stringByDeletingLastPathComponent]];
            }
        }
    }
    return providers;
    
}


NSArray *applicationProviders(){
    NSMutableArray *providers=[NSMutableArray arrayWithCapacity:1];
    NSString *itemPath;
    
    int i;
    
    
    NSArray *apps = [[NSWorkspace sharedWorkspace]allApplications];
    
    for (i=0;i<[apps count];i++){
        itemPath=[apps objectAtIndex:i];
        if ([[NSMutableDictionary dictionaryWithContentsOfFile:[itemPath stringByAppendingPathComponent:infoPath]] objectForKey:NSServicesKey]){
            [providers addObject:itemPath];
        }
    }
    return providers;
}

@implementation QSServiceActions

+(void)loadPlugIn{
	[NSThread detachNewThreadSelector:@selector(loadServiceActions) toTarget:self withObject:nil];
}
+(void)loadServiceActions{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[[QSTaskController sharedInstance] updateTask:@"Load Actions" status:@"Loading Application Services" progress:-1];
    NSArray *serviceActions= [QSServiceActions allServiceActions];
    int i;
    for (i=0;i<[serviceActions count];i++){
		[QSExec performSelectorOnMainThread:@selector(addActions:) withObject:[[serviceActions objectAtIndex:i]actions] waitUntilDone:YES];
	}
	//NSLog(@"Services Loaded");
	[[QSTaskController sharedInstance] removeTask:@"Load Actions"];
    [pool release];
}


+ (NSArray *) allServiceActions{
    
    NSMutableSet *providerSet=[NSMutableSet setWithCapacity:1];
    [providerSet addObjectsFromArray:applicationProviders()];
    [providerSet addObjectsFromArray:providersAtPath(@"/System/Library/Services/")];
    [providerSet addObjectsFromArray:providersAtPath(@"/Library/Services/")];
    [providerSet addObjectsFromArray:providersAtPath(@"~/Library/Services/")];
    NSArray *providerArray=[providerSet allObjects];
    NSMutableArray *actionObjects=[NSMutableArray arrayWithCapacity:[providerArray count]];
    
    int i;
    for (i=0;i<[providerArray count];i++)
        [actionObjects addObject:[[self class] serviceActionsForBundle:[providerArray objectAtIndex:i]]];
    
    return actionObjects;
    
}


+ (QSServiceActions *) serviceActionsForBundle:(NSString *)path{
    //NSLog(@"Loading Actions for Bundle: %@",path);
    return [[[[self class] alloc]initWithBundlePath:path]autorelease];
}

- (id) initWithBundlePath:(NSString *)path{
    if (self=[super init]){
        serviceBundle=[path copy];
        serviceArray=[servicesForBundle(path) retain];
        NSString *bundleIdentifier=[[NSBundle bundleWithPath:path]bundleIdentifier];
        modificationsDictionary=[[[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"NSServiceModifications" ofType:@"plist"]]objectForKey:bundleIdentifier]retain];
    }
    return self;
}

- (NSArray *) types{return nil;}

- (NSArray *) actions{
    // NSLog(@"load actions");
    NSMutableArray *newActions=[NSMutableArray arrayWithCapacity:1];
    NSImage *icon=[[NSWorkspace sharedWorkspace] iconForFile:serviceBundle];
    [icon setSize:NSMakeSize(16,16)];
    int i;
    
    for (i=0;i<[serviceArray count];i++){
		NSDictionary *thisService=[serviceArray objectAtIndex:i];
        NSString *serviceString=[[thisService objectForKey:NSMenuItemKey]objectForKey:DefaultKey];
       // NSLog(@"serviceString %@ %@",serviceString, serviceBundle);
        NSDictionary *serviceModifications=[modificationsDictionary objectForKey:serviceString];
        if ([[serviceModifications objectForKey:@"disabled"]boolValue])continue;
        
        QSAction *serviceObject=[QSAction actionWithIdentifier:serviceString bundle:[NSBundle bundleForClass:[self class]]];
        NSMutableDictionary *dict=[serviceObject actionDict];
		
        if ([serviceModifications objectForKey:@"name"])
            [serviceObject setName:[serviceModifications objectForKey:@"name"]];
		
		NSSet *sendTypes=[thisService objectForKey:NSSendTypesKey];
		
		if (sendTypes){
			[dict setObject:sendTypes forKey:kActionDirectTypes];
		}
		
		[serviceObject setIcon:icon];
		[serviceObject setProvider:self];
		[serviceObject setDisplaysResult:YES];
		[serviceObject setDetails:[NSString stringWithFormat:@"A service of %@",[serviceBundle lastPathComponent]]];
		
		[newActions addObject:serviceObject];
    }
	//  NSLog(@"Actions (%@)", [newActions componentsJoinedByString:@", "]);
	//   [self setActions:newActions];
	return newActions;
}

- (NSArray *)validActionsForDirectObject:(QSObject *)dObject indirectObject:(QSObject *)iObject{
    
    BOOL fileType=[[dObject primaryType]isEqualToString:NSFilenamesPboardType];
    if (fileType && ![dObject validPaths]) return nil;
	NSMutableArray *newActions=[NSMutableArray arrayWithCapacity:1];
    
    NSString *menuItem;
    int i;
	// NSLog(@"services%@", serviceArray);
    for (i=0;i<[serviceArray count];i++){
        NSDictionary *thisService=[serviceArray objectAtIndex:i];
        menuItem=[[thisService objectForKey:NSMenuItemKey]objectForKey:DefaultKey];
        
        BOOL disabled=[[[modificationsDictionary objectForKey:menuItem] objectForKey:@"disabled"]boolValue];
        if (menuItem && !disabled){//!disabled
                                   //NSLog(menuItem);
            NSSet *sendTypes=[NSSet setWithArray:[thisService objectForKey:NSSendTypesKey]];
            NSSet *availableTypes=[NSSet setWithArray:[dObject types]];
            
            // Add if they intersect, but ignore ex
            if ([sendTypes intersectsSet:availableTypes]){
                if (fileType && ![sendTypes containsObject:NSFilenamesPboardType]) continue;
				
                [newActions addObject:menuItem];
				//  NSLog(menuItem);
            }
        }
    }
	
    return newActions;
}


- (QSObject *) performAction:(QSAction *)action directObject:(QSBasicObject *)dObject indirectObject:(QSBasicObject *)iObject{
    NSPasteboard *pboard=[NSPasteboard pasteboardWithUniqueName];
    NSDictionary *thisService=nil;
	//NSLog(@"perform %@ %@ %@",[action actionDict],serviceArray,self);
    int i;
    for (i=0;i<[serviceArray count];i++){
        thisService=[serviceArray objectAtIndex:i];
       // NSLog(@"'%@' '%@'",[action identifier],[[thisService objectForKey:NSMenuItemKey]objectForKey:DefaultKey]);
        
        if ([[[thisService objectForKey:NSMenuItemKey]objectForKey:DefaultKey] isEqualToString:[action identifier]]){
            NSArray *sendTypes=[thisService objectForKey:NSSendTypesKey];
            [dObject putOnPasteboard:pboard declareTypes:sendTypes includeDataForTypes:sendTypes];
           // NSLog(@"types %@",[pboard types]);
            
            break;
        }
    }
    BOOL success=NSPerformService([action identifier], pboard);
	//   BOOL success=[self performSelectorOnMainThread:@selector(performServiceWithNameAndPasteboard:) withObject:[NSArray arrayWithObjects:action,pboard,nil] waitUntilDone:YES];
    if (success){
        QSObject *entry=nil;
        if ([thisService objectForKey:NSReturnTypesKey])
            entry=[[QSObject alloc]initWithPasteboard:pboard types:[thisService objectForKey:NSReturnTypesKey]];
        //  [pboard releaseGlobally];
        return entry;
    }
    //  [pboard releaseGlobally];
	 	 NSLog(@"PerformServiceFailed: %@, %@\r%@\r%@",action, dObject,serviceBundle,[[pboard types]componentsJoinedByString:@", "]);
    return nil;
}

- (BOOL)performServiceWithNameAndPasteboard:(NSArray *)array{
    return NSPerformService([array objectAtIndex:0],[array lastObject]);
}

@end
