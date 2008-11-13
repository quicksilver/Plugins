

#import "QSShelfSource.h"

#import "QSShelfController.h"
//#import "QSPasteboardController.h"
#import <QSBase/QSLibrarian.h>
#define QSShelfPboardType @"qs.shelf"

#define kQSShelfShowAction @"QSShelfShowAction"
#define kQSPutOnShelfAction @"QSPutOnShelfAction"


@implementation QSShelfSource

- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry{
    return YES;
}
- (NSImage *) iconForEntry:(NSDictionary *)dict{
    return [QSResourceManager imageNamed:@"prefsCatalog"];
}
- (NSArray *) objectsForEntry:(NSDictionary *)theEntry{
   NSDictionary *nameDict=[NSDictionary dictionaryWithObjectsAndKeys:
        @"Shelf",@"General",
         @"Clipboard History",@"QSPasteboardHistory",
        nil];
    
    NSMutableArray *objects=[NSMutableArray arrayWithCapacity:1];
    QSObject *newObject;
    NSString *name;
    NSString *key;
    NSEnumerator *objectEnumerator=[[QSLib shelfArrays]keyEnumerator];
   
    while(key=[objectEnumerator nextObject]){
        name=[nameDict objectForKey:key];

        newObject=[QSObject objectWithName:name];
        [newObject setObject:key forType:QSShelfPboardType];
        [newObject setPrimaryType:QSShelfPboardType];
        [objects addObject:newObject];
    }
    return objects;
}


// Object Handler Methods
- (NSString *)identifierForObject:(id <QSObject>)object{
    return [@"[Shelf]:" stringByAppendingString:[object objectForType:QSShelfPboardType]];
}

- (BOOL)loadIconForObject:(QSObject *)object{
    NSImage *icon=nil;
    if ([[object objectForType:QSShelfPboardType] isEqualToString:@"General"])
        icon=[QSResourceManager imageNamed:@"prefsCatalog"];
    else if ([[object objectForType:QSShelfPboardType] isEqualToString:@"QSPasteboardHistory"]){
	    icon=[[QSReg bundleForClassName:@"QSPasteboardController"] imageNamed:@"Clipboard"];
		
	}

    if (icon){
        [object setIcon:icon];
        return YES;
    }
    return NO;
}

- (BOOL)objectHasChildren:(id <QSObject>)object{
    return YES;
}
- (BOOL)objectHasValidChildren:(id <QSObject>)object{
    return YES;
}
- (BOOL)loadChildrenForObject:(QSObject *)object{
    NSArray *children=[self childrenForObject:object];
    
    if (children){
        [object setChildren:children];
        return YES;   
    }
    return NO;
}

- (NSArray *)childrenForObject:(QSObject *)object{
   return [QSLib shelfNamed:[object objectForType:QSShelfPboardType]];
}



// Action Provider Methods
- (NSArray *) types{
    return nil;
}
- (NSArray *) actions{
    
    QSAction *action=[QSAction actionWithIdentifier:kQSShelfShowAction];
    [action setIcon:[QSResourceManager imageNamed:@"prefsCatalog"]];
    [action setProvider:self];
    [action setAction:@selector(show:)];
    [action setArgumentCount:1];
    
    QSAction *action2=[QSAction actionWithIdentifier:kQSPutOnShelfAction];
    [action2 setIcon:[QSResourceManager imageNamed:@"prefsCatalog"]];
    [action2 setProvider:self];
    [action2 setAction:@selector(putObjectOnShelf:)];
    [action2 setArgumentCount:1];
    
    return [NSArray arrayWithObjects:action,action2,nil];
}

- (NSArray *)validActionsForDirectObject:(QSObject *)dObject indirectObject:(QSObject *)iObject{
    if ([dObject objectForType:QSShelfPboardType]){
        return [NSArray arrayWithObject:kQSShelfShowAction];
    }
//	else if (dObject && fBETA){
//        return [NSArray arrayWithObjects:kQSPutOnShelfAction,nil];
//    }
    return nil;
}

- (NSArray *)validIndirectObjectsForAction:(NSString *)action directObject:(QSObject *)dObject{return nil;}

- (NSWindowController *)controllerForShelf:(NSString *)shelfName{
    if ([shelfName isEqualToString:@"General"])
        return [QSShelfController sharedInstance];
    else if ([shelfName isEqualToString:@"QSPasteboardHistory"])
		return [QSReg getClassInstance:@"QSPasteboardController"];
//        NSLog(@"[QSPasteboardController sharedInstance] FIX ME"); //return [QSPasteboardController sharedInstance];
    return nil;
}

- (QSObject *) show:(QSObject *)dObject{
    [(QSDockingWindow *)[[self controllerForShelf:[dObject objectForType:QSShelfPboardType]]window]toggle:self];
    return nil;
}

- (QSObject *) putObjectOnShelf:(QSObject *)dObject{
	dObject=[dObject resolvedObject];
    [[QSShelfController sharedInstance]addObject:dObject atIndex:0];   
    return nil;
}


@end