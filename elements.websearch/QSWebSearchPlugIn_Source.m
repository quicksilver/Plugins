//
//  QSWebSearchPlugIn_Source.m
//  QSWebSearchPlugIn
//
//  Created by Nicholas Jitkoff on 11/24/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//

#import "QSWebSearchPlugIn_Source.h"


@implementation QSWebSearchSource



- (BOOL)isVisibleSource{return YES;}

- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry{
		  NSDate *specDate=[NSDate dateWithTimeIntervalSinceReferenceDate:[[theEntry objectForKey:kItemModificationDate]floatValue]];

	//NSLog(@"spec %d",([specDate compare:indexDate]==NSOrderedDescending));   
	return ([specDate compare:indexDate]==NSOrderedDescending);
	
	   
    return NO;
}

- (NSImage *) iconForEntry:(NSDictionary *)dict{
    return [QSResourceManager imageNamed:@"Find"];
}

- (NSString *)identifierForObject:(id <QSObject>)object{
    return nil;
}
- (NSArray *) objectsForEntry:(NSDictionary *)theEntry{
	
	NSMutableArray *urlArray=[theEntry objectForKey:@"queryList"];
    NSMutableArray *objects=[NSMutableArray arrayWithCapacity:1];
    QSObject *newObject;
	for(NSDictionary * urlDict,urlArray){
		newObject=[QSObject URLObjectWithURL:[urlDict objectForKey:@"url"] title:[urlDict objectForKey:@"name"]];
		NSNumber *encoding=[urlDict objectForKey:@"encoding"];
		if (encoding)
			[newObject setObject:encoding forMeta:kQSStringEncoding];
		if (newObject)[objects addObject:newObject];
	}
	
	
	
    return objects;
    
}
- (NSView *) settingsView{
    if (![super settingsView]){
        [NSBundle loadNibNamed:NSStringFromClass([self class]) owner:self];
        
	}
    return [super settingsView];
}

- (void)populateFields{
    [self willChangeValueForKey:@"urlArray"];
	[self didChangeValueForKey:@"urlArray"];
	
	
	[encodingCell setMenu:[self encodingMenu]];
		
	
	
	
}
static NSMenu *encodingMenu=nil;
- (NSMenu *)encodingMenu{
	if (!encodingMenu){	
		encodingMenu=[[NSMenu alloc]initWithTitle:@"Encodings"];
		//[[encodingMenu addItemWithTitle:@"Default" action:nil keyEquivalent:@""]setTag:0];
		//NSMenuItem *separator=[NSMenuItem separatorItem];
		//[separator setTag:-1];
		//[encodingMenu addItem:separator];
		
		const CFStringEncoding *encodings;
		encodings = CFStringGetListOfAvailableEncodings();
		int i=0;
		for (i=0; encodings[i] != kCFStringEncodingInvalidId;i++) {
			NSString *encodingName=(NSString *)CFStringGetNameOfEncoding(encodings[i]);
			
			if (i && encodings[i]-encodings[i-1]>16){
				[encodingMenu addItem:[NSMenuItem separatorItem]];
				
			//	NSLog(@"-");				
			}			
		//				NSLog(@"Enc: %d %@",encodings[i],encodingName);
			[[encodingMenu addItemWithTitle:encodingName action:nil keyEquivalent:@""]setTag:encodings[i]];
			
			
		}
	}
	return encodingMenu;  
}

- (void)objectDidEndEditing:(id)editor{
//	NSLog(@"edited %@",editor);
	[self updateCurrentEntryModificationDate];
	[[NSNotificationCenter defaultCenter] postNotificationName:QSCatalogEntryChanged object:[self currentEntry]];
	//[QSLib scanItem:[self currentEntry] force:YES];
}

- (void)setUrlArray:(id)array{
	
	NSMutableDictionary *entry=[self currentEntry];
	[entry setObject:array forKey:@"queryList"];
}
- (NSMutableArray *)urlArray{
	NSMutableDictionary *entry=[self currentEntry];
	NSMutableArray *urlArray=[entry objectForKey:@"queryList"];
	if (!urlArray){
		urlArray=[NSMutableArray array];
		[entry setObject:urlArray forKey:@"queryList"];
	}
	return urlArray;
}

@end
