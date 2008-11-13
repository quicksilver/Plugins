

#import "QSNNWSource.h"

#import <QSCore/QSCore.h>

#import <QSCore/QSBadgeImage.h>
#define QSNNWSubscriptionType @"QSNNWSubscriptionType"
#define QSNNWHeadlineType @"QSNNWHeadlineType"

#define mailScript [[self classBundle]scriptNamed:@"NetNewsWire"]
@implementation QSNNWSource

// Object Source Methods
- (NSImage *) iconForEntry:(NSDictionary *)dict{
    return [QSResourceManager imageNamed:@"com.ranchero.NetNewsWire"];
}

- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry{
    NSDate *modDate=[[[NSFileManager defaultManager] fileAttributesAtPath:[@"~/Library/Preferences/com.ranchero.NetNewsWire.plist" stringByStandardizingPath] traverseLink:YES]fileModificationDate];
    return [modDate compare:indexDate]==NSOrderedAscending;
}
- (NSString *)identifierForObject:(id <QSObject>)object{
    return [@"[NNW Subscription]:"stringByAppendingString:[object objectForType:QSNNWSubscriptionType]];
}

- (NSArray *)objectsForSubscriptionArray:(NSArray *)array{
    NSMutableArray *objects=[NSMutableArray arrayWithCapacity:1];
    QSObject *newObject;
    NSDictionary *thisChannel;
    NSEnumerator *subEnum=[array objectEnumerator];
    while(thisChannel=[subEnum nextObject]){
        
        if ([thisChannel objectForKey:@"isContainer"]){
            NSArray *children=[thisChannel objectForKey:@"childrenArray"];
            [objects addObjectsFromArray:[self objectsForSubscriptionArray:children]];
        }else{
            newObject=[QSObject objectWithName:[thisChannel objectForKey:@"name"]];
            if ([thisChannel objectForKey:@"rss"])[newObject setObject:[thisChannel objectForKey:@"rss"] forType:QSNNWSubscriptionType];
            if ([thisChannel objectForKey:@"home"])[newObject setObject:[thisChannel objectForKey:@"home"] forType:NSURLPboardType];
            [newObject setPrimaryType:QSNNWSubscriptionType];
            [objects addObject:newObject];
        }
    }
    return objects;
}


- (NSArray *) objectsForEntry:(NSDictionary *)theEntry{
    NSArray *subscriptions= (NSArray *)CFPreferencesCopyAppValue((CFStringRef)@"Subscriptions",(CFStringRef) @"com.ranchero.NetNewsWire");
    [subscriptions autorelease];
   
    NSMutableArray *objects=[NSMutableArray arrayWithCapacity:1];
    
    if (CFPreferencesGetAppBooleanValue((CFStringRef)@"displayNewItemsAsFeed",(CFStringRef) @"com.ranchero.NetNewsWire", nil)){
        NSString *newSubs=@"New Headlines";
        QSObject *newObject=[QSObject objectWithName:newSubs];
        [newObject setObject:@"" forType:QSNNWSubscriptionType];
        [newObject setPrimaryType:QSNNWSubscriptionType];
        [objects addObject:newObject];
    }
    [objects addObjectsFromArray:[self objectsForSubscriptionArray:subscriptions]];
    return objects;
    
}

/*
- (NSArray *) objectsForEntry:(NSDictionary *)theEntry{
    NSWorkspace *workspace=[NSWorkspace sharedWorkspace];
  //  NSLog(@"nnw");
   // if (![workspace applicationIsRunning:@"NewNewsWire"])return nil;
    NSAppleScript *contactScript=[[NSAppleScript alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"NetNewsWire" ofType:@"scpt"]] error:nil];
    
    NSDictionary *errorDict=nil;
    NSAppleEventDescriptor *desc=[contactScript executeSubroutine:@"get_subscriptions" arguments:nil error:&errorDict];
    if (errorDict) NSLog(@"Execute Error: %@",errorDict);
    
    NSArray *contactRecords=[desc objectValue];
    //NSLog(@"recs %@",contactRecords);
    NSArray *ids=[contactRecords objectAtIndex:0];
    NSArray *names=[contactRecords objectAtIndex:1];
    NSArray *urls=[contactRecords objectAtIndex:2];
    NSMutableArray *objects=[NSMutableArray arrayWithCapacity:[ids count]];
    
    int i;
    QSObject *newObject;
    for (i=0;i<[ids count];i++){
        newObject=[QSObject objectWithName:[names objectAtIndex:i]];
        [newObject setObject:[ids objectAtIndex:i] forType:QSNNWSubscriptionType];
        if ([(NSString *)[urls objectAtIndex:i]length])
            [newObject setObject:[urls objectAtIndex:i] forType:NSURLPboardType];
        [newObject setPrimaryType:QSNNWSubscriptionType];
        [objects addObject:newObject];
    }
    
    return objects;
}
*/

// Object Handler Methods
// Object Handler Methods

- (void)setQuickIconForObject:(QSObject *)object{
    [object setIcon:[QSResourceManager imageNamed:@"com.ranchero.NetNewsWire"]];
}
/*
- (BOOL)loadIconForObject:(QSObject *)object{

    [object setIcon:[NSImage imageNamed:@"com.ranchero.NetNewsWire"]];
    return YES;
}
*/

- (BOOL)drawIconForObject:(QSObject *)object inRect:(NSRect)rect flipped:(BOOL)flipped{
	if(NSWidth(rect)<=32) return NO;
	
	if ([object objectForType:QSNNWSubscriptionType]){
		NSImage *image=[QSResourceManager imageNamed:@"com.ranchero.NetNewsWire"];
		
		[image setSize:[[image bestRepresentationForSize:rect.size] size]];
		//[image adjustSizeToDrawAtSize:rect.size];
		[image setFlipped:flipped];
		[image drawInRect:rect fromRect:rectFromSize([image size]) operation:NSCompositeSourceOver fraction:1.0];
		
		if ([object iconLoaded]){
			NSImage *cornerBadge=[object icon];
			if (cornerBadge!=image){
				[cornerBadge setFlipped:flipped]; 
				NSImageRep *bestBadgeRep=[cornerBadge bestRepresentationForSize:rect.size];    
				[cornerBadge setSize:[bestBadgeRep size]];
				NSRect badgeRect=rectFromSize([cornerBadge size]);
				
				//NSPoint offset=rectOffset(badgeRect,rect,2);
				badgeRect=centerRectInRect(badgeRect,rect);
				badgeRect=NSOffsetRect(badgeRect,0,-NSHeight(rect)/6);
				
				[[NSColor colorWithDeviceWhite:1.0 alpha:0.8]set];
				NSRectFillUsingOperation(NSInsetRect(badgeRect,-3,-3),NSCompositeSourceOver);
				[[NSColor colorWithDeviceWhite:0.75 alpha:1.0]set];
				NSFrameRectWithWidth(NSInsetRect(badgeRect,-5,-5),2);
				[cornerBadge drawInRect:badgeRect fromRect:rectFromSize([cornerBadge size]) operation:NSCompositeSourceOver fraction:1.0];
			}
		}
		return YES;
	}else{
		
		if (![object objectForType:QSProcessType])return nil;
		
		int count=[[mailScript executeSubroutine:@"unread_count"
											  arguments:nil
												  error:nil]int32Value];
		//NSLog(@"count %d",count);
		NSImage *icon=[object icon];
		[icon setFlipped:flipped];
		NSImageRep *bestBadgeRep=[icon bestRepresentationForSize:rect.size];    
		[icon setSize:[bestBadgeRep size]];
		[icon drawInRect:rect fromRect:NSMakeRect(0,0,[bestBadgeRep size].width,[bestBadgeRep size].height) operation:NSCompositeSourceOver fraction:1.0];
		
		QSCountBadgeImage *countImage=[QSCountBadgeImage badgeForCount:count];
		
		[countImage drawBadgeForIconRect:rect];				
		
		return YES;		
	}
	return nil;
}

- (BOOL)loadIconForObject:(QSObject *)object{
    NSString *url=[object objectForType:NSURLPboardType];
    if (![url hasPrefix:@"http://"])return NO;
    url=[[[url substringWithRange:NSMakeRange(7,[url length]-7)] componentsSeparatedByString:@"/"]objectAtIndex:0];
    url=[url stringByReplacing:@"." with:@"_"];
    
    NSImage *icon=[[[NSImage alloc]initWithContentsOfFile:
        [[NSString stringWithFormat:@"~/Library/Application Support/NetNewsWire/Favicons/%@.ico",url]stringByStandardizingPath]]autorelease];

    if (icon){
        [object setIcon:icon];
        return YES;
    }
    return NO;
}

- (BOOL)loadChildrenForObject:(QSObject *)object{
    NSArray *children=[self childrenForObject:object];
    
    if (children){
        [object setChildren:children];
        return YES;   
    }
    return NO;
}

- (BOOL)objectHasChildren:(QSObject *)object{
	if ([[object primaryType]isEqualToString:QSNNWSubscriptionType]){
		return YES;
	}
	return NO;
}
- (NSArray *)childrenForObject:(QSObject *)object{
    if ([[object primaryType]isEqualToString:QSNNWSubscriptionType]){
        
        NSString *subID=[object objectForType:QSNNWSubscriptionType];
        
        NSAppleScript *contactScript=[[NSAppleScript alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle bundleForClass:[QSNNWSource class]]pathForResource:@"NetNewsWire" ofType:@"scpt"]] error:nil];
        
        NSDictionary *errorDict=nil;
        NSAppleEventDescriptor *desc=[contactScript executeSubroutine:@"get_headlines" arguments:subID error:&errorDict];
        if (errorDict) NSLog(@"Execute Error: %@",errorDict);
        
        NSArray *contactRecords=[desc objectValue];
        //NSLog(@"recs %@",contactRecords);
        NSArray *names=[contactRecords objectAtIndex:0];
        NSArray *urls=[contactRecords objectAtIndex:1];
        NSArray *details=[contactRecords objectAtIndex:2];
        NSMutableArray *objects=[NSMutableArray arrayWithCapacity:[names count]];
        
        int i;
        QSObject *newObject;
        for (i=0;i<[names count];i++){
            newObject=[QSObject objectWithName:[names objectAtIndex:i]];
            [newObject setObject:[names objectAtIndex:i] forType:QSNNWHeadlineType];
            if ([(NSString *)[urls objectAtIndex:i]length])
                [newObject setObject:[urls objectAtIndex:i] forType:NSURLPboardType];
            [newObject setPrimaryType:QSNNWHeadlineType];
            [newObject setObject:[details objectAtIndex:i] forMeta:kQSObjectDetails];
            [objects addObject:newObject];
        }
        
        return objects;
    }
    return nil;
}



// Action Provider Methods
- (NSArray *) types{
    return [NSArray arrayWithObject:QSNNWSubscriptionType];
}
- (NSArray *) actions{
    
    return nil;
//QSAction *action=[QSAction actionWithIdentifier:kQSNUTDContactShowAction];
//[action setIcon:[QSResourceManager imageNamed:@"NowContactIcon"]];
//[action setProvider:self];
//[action setAction:@selector(showContact:)];
//[action setArgumentCount:1];
//return [NSArray arrayWithObject:action];
}

- (NSArray *)validActionsForDirectObject:(QSObject *)dObject indirectObject:(QSObject *)iObject{
    return nil;// return [NSArray arrayWithObject:kQSNUTDContactShowAction];
}

@end
