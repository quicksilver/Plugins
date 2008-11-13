//
//  Dialer.m
//  BuddyPop
//
//  Created by Yann Bizeul on Wed May 26 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "Dialer.h"
#import "BuddyPop.h"
#import "RollOverButton.h"

#define SHARED [[self class] sharedDialer]
@interface Dialer (Private)
- (void)_dial:(NSString*)number;
@end

@implementation Dialer
Dialer *dialer = nil;
+ (id)sharedDialer
{    
    if (!dialer)
	dialer = [[[self class] alloc]init];

    return dialer;
}
- (id)init
{
    self = [super init];    
    return self;
}

#pragma mark -
#pragma mark Methods that can be override by subclasses

+ (BOOL)isAvailable
{
    return YES;   
}
+ (BOOL)isReady
{
    return YES;   
}

#pragma mark -
#pragma mark Heart of the class

+ (void)dial:(NSString*)aNumber
{
    NSString *localizedNumber = [[self class]localizedNumber:aNumber];
    [SHARED setNumber: localizedNumber];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"DialerWillStartDialingNotification" object:SHARED userInfo: [SHARED userInfo]];
    if ([SHARED respondsToSelector:@selector(dialerWillStartDialing)])
	[SHARED dialerWillStartDialing];
    [NSTimer scheduledTimerWithTimeInterval:[SHARED timeout]
				      target:SHARED
				    selector:@selector(cancel:)
				    userInfo:nil
				     repeats:NO];
    NSThread *thread = [NSThread detachNewThreadSelector:@selector(dial:) 
						toTarget:SHARED 
					      withObject:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self 
					    selector:@selector(dialingThreadExited:) 
						name:@"NSThreadWillExitNotification" 
					      object:thread];
}
+ (void)dialingThreadExited:(NSNotification*)aNotification
{
    [[NSNotificationCenter defaultCenter]removeObserver: self];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"DialerDidEndDialingNotification" object:SHARED];
    [dialer release];
    dialer = nil;
}
- (void)dialerWillStartDialing
{
    return;    
}
- (void)setNumber:(NSString*)aNumber
{
    number = [aNumber retain];   
}
- (IBAction)buttonPushed:(id)sender
{
    [self cancel];
}
- (void)cancel
{
    CANCEL=YES;   
}
- (void)cancel:(NSTimer*)aTimer;
{
    [self cancel];
}
- (int)timeout
{
    return 10;
}
+ (void)setUserInfo:(NSDictionary*)aDictionary;
{
    [SHARED setUserInfo:aDictionary];
}
- (void)setUserInfo:(NSDictionary*)aDictionary;
{
    [aDictionary retain];
    [userInfo release];
    userInfo = aDictionary;
}
- (NSDictionary*)userInfo
{
    return userInfo;   
}
#pragma mark -
#pragma mark Class methods
+ (NSString*)localizedNumber:(NSString*)aNumber
{
    NSMutableString *dialingString = [[aNumber mutableCopy] autorelease];
    
    NSString *localIntPrefix = [NSString stringWithFormat: @"+%@",[self countryCode]];
    NSString *intPrefix=@"00";
    
    [dialingString deleteCharactersNotInCharacterSet:[NSCharacterSet phoneNumberCharacterSet]];
    
    if ([dialingString hasPrefix: localIntPrefix])
	dialingString = [NSString stringWithFormat: @"0%@",[dialingString substringWithRange:NSMakeRange([localIntPrefix length],[dialingString length]-[localIntPrefix length])]];
    else if ([dialingString hasPrefix: @"+"])
	dialingString = [NSString stringWithFormat: @"%@%@",intPrefix,[dialingString substringWithRange:NSMakeRange(1,[dialingString length]-1)]];
    
    dialingString = [NSString stringWithFormat: @"%@%@",[self prefix],dialingString];
    
    if ([[[NSUserDefaults standardUserDefaults]objectForKey: @"DEBUG"]boolValue])
	NSLog(@"localizedNumber : %@",dialingString);
    
    return dialingString;
}
+(IBAction)buttonPushed:(id)sender
{
    [SHARED buttonPushed:sender];   
}
+(void)cancel
{
    if (dialer)
	[SHARED cancel];   
}   
/*
+ (NSView*)dialerViewForNumber:(NSString*)aNumber contact:(BPContact*)aContact;
{
    dialer = [[self alloc]init];
    NSView *view = [[[DialerView alloc]initWithNumber: aNumber contact:aContact showButton:[self showButton] buttonTitle:[self buttonTitle] attributes:[self buttonAttributes] dialer:dialer]autorelease];
    
    return view;
}

+ (NSDictionary*)buttonAttributes
{
    NSColor *textColor = [(BuddyPop*)NSApp textColor];
    NSFont *font = [ NSFont boldSystemFontOfSize: 14];
    NSMutableParagraphStyle *paragraph = [[[NSParagraphStyle defaultParagraphStyle]mutableCopy]autorelease];
    [paragraph setAlignment:NSCenterTextAlignment];
    return  [NSDictionary dictionaryWithObjectsAndKeys:
	font,NSFontAttributeName,
	textColor,NSForegroundColorAttributeName,
	paragraph,NSParagraphStyleAttributeName,
	nil];   
}
*/

#pragma mark -
#pragma mark Preferences
+ (void)setCountryCode:(NSString*)aString;
{
    [[NSUserDefaults standardUserDefaults]setObject: aString forKey: @"DialerCountryCode"];
}
+ (NSString*)countryCode;
{
    NSString *countryCode = [[NSUserDefaults standardUserDefaults]objectForKey: @"DialerCountryCode"];
    return countryCode ? countryCode : @"";
}
+ (void)setPrefix:(NSString*)aString;
{
    [[NSUserDefaults standardUserDefaults]setObject: aString forKey: @"DialerPrefix"];
}

+ (NSString*)prefix;
{
    NSString *prefix = [[NSUserDefaults standardUserDefaults]objectForKey: @"DialerPrefix"];
    return prefix ? prefix : @"";
}
+ (void)setEnableSpeaker:(BOOL)flag;
{
    [[NSUserDefaults standardUserDefaults]setObject: [NSNumber numberWithBool: flag] forKey: @"DialerModemSpeaker"];
}
+ (BOOL)enableSpeaker
{
    BOOL speaker = [[[NSUserDefaults standardUserDefaults]objectForKey: @"DialerModemSpeaker"] boolValue];
    return speaker;
}


#pragma mark -
#pragma mark Misc
- (void)dealloc
{
    [number release];
}
@end