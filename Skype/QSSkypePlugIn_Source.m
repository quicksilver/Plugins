//
//  QSSkypePlugIn_Source.m
//  QSSkypePlugIn
//
//  Created by Nicholas Jitkoff on 11/17/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//

#import "QSSkypePlugIn_Source.h"
#import <QSCore/QSObject.h>
#import <Skype/Skype.h>


@implementation QSSkypePlugIn_Source
- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry{
    return YES;
}

- (NSImage *) iconForEntry:(NSDictionary *)dict{
    return nil;
}

- (NSString *)identifierForObject:(id <QSObject>)object{
    return nil;
}
- (NSArray *) objectsForEntry:(NSDictionary *)theEntry{
	return nil;
	[SkypeAPI setSkypeDelegate:self];
	[SkypeAPI connect];
	
    NSMutableArray *objects=[NSMutableArray arrayWithCapacity:1];
    QSObject *newObject;
	
	newObject=[QSObject objectWithName:@"TestObject"];
	[newObject setObject:@"" forType:@"com.skype.skypeuser"];
	[newObject setPrimaryType:@"com.skype.skypeuser"];
	[objects addObject:newObject];
  
    return objects;
    
}
/////////////////////////////////////////////////////////////////////////////////////
// optional delegate method

- (void)skypeNotificationReceived:(NSString*)string{
	NSLog(@"SkypeNotif: %@",string);
	if ([string hasPrefix:@"USERS "]){
		string=[string substringFromIndex:6];
		NSArray *handles=[string componentsSeparatedByString:@", "];
		NSLog(@"contacts %@",handles);
		foreach(handle,handles){
			[SkypeAPI sendSkypeCommand:[NSString stringWithFormat:@"GET USER %@ DISPLAYNAME",handle]];
			[SkypeAPI sendSkypeCommand:[NSString stringWithFormat:@"GET USER %@ FULLNAME",handle]];
		}
	}
}
- (void)skypeAttachResponse:(unsigned)aAttachResponseCode{
	NSLog(@"SkypeAttach:%d",aAttachResponseCode);
	[SkypeAPI sendSkypeCommand:@"SEARCH FRIENDS"];
}				// 0 - failed, 1 - success
//- (void)skypeBecameAvailable:(NSNotification*)aNotification{NSLog(@"SkypeN:%d",aNotification);}
//- (void)skypeBecameUnavailable:(NSNotification*)aNotification{NSLog(@"SkypeN:%d",aNotification);}

- (NSString*)clientApplicationName{
return @"Quicksilver";
}

// Object Handler Methods

/*
- (void)setQuickIconForObject:(QSObject *)object{
    [object setIcon:nil]; // An icon that is either already in memory or easy to load
}
- (BOOL)loadIconForObject:(QSObject *)object{
	return NO;
    id data=[object objectForType:QSSkypePlugInType];
	[object setIcon:nil];
    return YES;
}
*/
@end
