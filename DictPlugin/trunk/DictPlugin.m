//
//  DictPlugin.m
//  DictPlugin
//
//  Created by Kevin Ballard on 8/1/04.
//  Copyright TildeSoft 2004. All rights reserved.
//

#import "DictPlugin.h"
#import "NSMutableStringAdditions.h"
#import <QSCore/QSObject.h>
#import <QSCore/QSNotifyMediator.h>
#import <QSCore/QSObject_PropertyList.h>
#import <QSFoundation/NSGeometry_BLTRExtensions.h>
#import <QSCore/QSTaskController.h>
#import <QSEffects/QSWindow.h>

#define kDictPluginDefineAction @"DictPluginDefineAction"
#define kDictTaskID @"DictModule-Define"
#define kDictWindowName @"Dict Results Window"

static NSArray *parseDictOutput(NSString *input);
void showResultsWindow(NSString *input, NSString *title, id delegate);

@implementation DictPlugin

- (id) init {
	if (self = [super init]) {
		dictTask = nil;
		dictTaskStatus = nil;
		NSBundle *plugin = [NSBundle bundleForClass:[self class]];
		dictIcon = [[NSImage alloc] initByReferencingFile:[plugin pathForResource:@"dict" ofType:@"jpg"]];
	}
	return self;
}

- (void) dealloc {
	[dictTask release];
	[dictTaskStatus release];
	[dictIcon release];
	[super dealloc];
}

- (QSObject *) define:(QSObject *)dObject{
	if (dictTask != nil) {
		// Definition is currently being fetched
		NSBeep();
		NSDictionary *notif = [NSDictionary dictionaryWithObjectsAndKeys:
			@"Define in progress", QSNotifierTitle,
			@"Wait until complete", QSNotifierText,
			dictIcon, QSNotifierIcon,
			nil];
		QSShowNotifierWithAttributes(notif);
		return nil;
	}
	// Create a task
	dictTaskStatus = [[NSString alloc] initWithFormat:@"Define: %@",
													  [dObject objectForType:NSStringPboardType]];
	[[QSTaskController sharedInstance] updateTask:kDictTaskID status:dictTaskStatus progress:0];
	// Start a new definition
	dictTask = [[NSTask alloc] init];
	NSPipe *pipe = [NSPipe pipe];
	[dictTask setStandardOutput:pipe];
	[dictTask setLaunchPath:@"/usr/bin/curl"];
	// We need to construct a properly-quoted, properly-escaped string
	NSMutableString *word = [[dObject objectForType:NSStringPboardType] mutableCopy];
	NSMutableCharacterSet *escapeSet = [[NSCharacterSet characterSetWithCharactersInString:@"\"\\"]
											mutableCopy];
	[escapeSet formUnionWithCharacterSet:[NSCharacterSet controlCharacterSet]];
	[word escapeCharactersInSet:escapeSet];
	[word insertString:@"\"" atIndex:0];
	[word appendString:@"\""];
	[dictTask setArguments:[NSArray arrayWithObjects:
		@"--fail", @"--silent", @"--globoff",
		[NSString stringWithFormat:@"dict://dict.org/d:%@:*", word], nil]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(definitionFinished:)
												 name:NSTaskDidTerminateNotification object:dictTask];
	NSFileHandle *handle = [pipe fileHandleForReading];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataAvailable:)
												 name:NSFileHandleDataAvailableNotification object:handle];
	buffer = [[NSMutableData alloc] init];
	[dictTask launch];
	[handle waitForDataInBackgroundAndNotify];
	return nil;
}

- (void) definitionFinished:(NSNotification *)aNotification {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSTaskDidTerminateNotification
												  object:dictTask];
	NSFileHandle *handle = [[[aNotification object] standardOutput] fileHandleForReading];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleDataAvailableNotification
												  object:handle];
	[buffer appendData:[handle availableData]];
	[self processBuffer];
}

- (void) dataAvailable:(NSNotification *)aNotification {
	[buffer appendData:[[aNotification object] availableData]];
	[[aNotification object] waitForDataInBackgroundAndNotify];
}

- (void) processBuffer {
	if ([dictTask terminationStatus] != 0) {
		[dictTask release];
		dictTask = nil;
		NSDictionary *notif = [NSDictionary dictionaryWithObjectsAndKeys:
			@"Define complete", QSNotifierTitle,
			@"Unknown curl error", QSNotifierText,
			dictIcon, QSNotifierIcon, nil];
		[[QSTaskController sharedInstance] removeTask:kDictTaskID];
		[dictTaskStatus release];
		dictTaskStatus = nil;
		QSShowNotifierWithAttributes(notif);
		return;
	}
	[dictTask release];
	dictTask = nil;
	NSString *curlStr = [[NSString alloc] initWithData:buffer encoding:NSUTF8StringEncoding];
	NSArray *entries = parseDictOutput(curlStr);
	NSEnumerator *e = [entries objectEnumerator];
	NSDictionary *item, *notif;
	NSMutableString *result = [NSMutableString string];
	while (item = [e nextObject]) {
		int code = [[item objectForKey:@"Code"] intValue];
		if (code >= 400) {
			if (code == 500) {
				notif = [NSDictionary dictionaryWithObjectsAndKeys:
					@"Dict plugin error", QSNotifierTitle,
					[item objectForKey:@"Value"], QSNotifierText,
					dictIcon, QSNotifierIcon, nil];
			} else if (code == 501) {
				notif = [NSDictionary dictionaryWithObjectsAndKeys:
					@"Define error", QSNotifierTitle,
					@"Illegal input", QSNotifierText,
					dictIcon, QSNotifierIcon, nil];
			} else if (code == 552) {
				notif = [NSDictionary dictionaryWithObjectsAndKeys:
					@"Define complete", QSNotifierTitle,
					@"No match", QSNotifierText,
					dictIcon, QSNotifierIcon, nil];
			} else {
				notif = [NSDictionary dictionaryWithObjectsAndKeys:
					@"Unknown Define error", QSNotifierTitle,
					[item objectForKey:@"Value"], QSNotifierText,
					dictIcon, QSNotifierIcon, nil];
			}
			[[QSTaskController sharedInstance] removeTask:kDictTaskID];
			[dictTaskStatus release];
			dictTaskStatus = nil;
			QSShowNotifierWithAttributes(notif);
			return;
		} else if (code == 150) {
			int count = [[item objectForKey:@"Count"] intValue];
			if (count == 1)
				[result appendFormat:@"%i definition\n\n", count];
			else
				[result appendFormat:@"%i definitions\n\n", count];
		} else if (code == 151) {
			[result appendFormat:@"%@\n%@\n\n", [item objectForKey:@"Title"], [item objectForKey:@"Value"]];
		}
	}
	NSString *definition = [result stringByTrimmingCharactersInSet:
								[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	[[QSTaskController sharedInstance] removeTask:kDictTaskID];
	showResultsWindow(definition, dictTaskStatus, self);
	[dictTaskStatus release];
	dictTaskStatus = nil;
}

- (void) windowDidResize:(NSNotification *)aNotification {
	[[aNotification object] saveFrameUsingName:kDictWindowName];
}

@end

static NSArray *parseDictOutput(NSString *input) {
	NSMutableArray *result = [NSMutableArray array];
	NSScanner *scanner = [NSScanner scannerWithString:input];
	[scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@""]];
	int code;
	NSDictionary *entry;
	NSString *value;
	while (![scanner isAtEnd]) {
		if (![scanner scanInt:&code])
			return result;
		[scanner scanString:@" " intoString:nil];
		if (code == 150) {
			// count of results
			int count;
			unsigned loc;
			loc = [scanner scanLocation];
			[scanner scanInt:&count];
			[scanner setScanLocation:loc];
			[scanner scanUpToString:@"\r\n" intoString:&value];
			[scanner scanString:@"\r\n" intoString:nil];
			entry = [NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:code], @"Code",
				[NSNumber numberWithInt:count], @"Count",
				value, @"Value", nil];
		} else if (code == 151) {
			NSString *word, *title;
			[scanner scanString:@"\"" intoString:nil];
			[scanner scanUpToString:@"\"" intoString:&word];
			[scanner scanString:@"\"" intoString:nil];
			[scanner scanUpToString:@"\"" intoString:nil];
			[scanner scanString:@"\"" intoString:nil];
			[scanner scanUpToString:@"\"" intoString:&title];
			[scanner scanUpToString:@"\r\n" intoString:nil];
			[scanner scanString:@"\r\n" intoString:nil];
			[scanner scanUpToString:@"\n.\r\n" intoString:&value];
			[scanner scanString:@"\n.\r\n" intoString:nil];
			entry = [NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:code], @"Code",
				word, @"Word",
				title, @"Title",
				value, @"Value", nil];
		} else {
			// standard codes - value is rest of line
			[scanner scanUpToString:@"\r\n" intoString:&value];
			[scanner scanString:@"\r\n" intoString:nil];
			entry = [NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:code], @"Code",
				value, @"Value", nil];
		}
		[result addObject:entry];
	}
	return result;
}

void showResultsWindow(NSString *input, NSString *title, id delegate) {
	NSRect windowRect = NSMakeRect(0, 0, 455, 490);
	NSRect screenRect = [[NSScreen mainScreen] frame];
	QSWindow *window = [[QSWindow alloc] initWithContentRect:windowRect
												   styleMask:(NSTitledWindowMask | NSClosableWindowMask |
															  NSUtilityWindowMask | NSResizableWindowMask |
															  NSNonactivatingPanelMask)
													 backing:NSBackingStoreBuffered defer: NO];
	[window setFrameUsingName:kDictWindowName];
	windowRect = [window frame];
	NSRect centeredRect = centerRectInRect(windowRect, screenRect);
	[window setFrame:centeredRect display:YES];
	[window setOneShot:YES];
	[window setReleasedWhenClosed:YES];
	[window setShowOffset:NSMakePoint(-16, 16)];
	[window setHideOffset:NSMakePoint(16, -16)];
	[window setHidesOnDeactivate:NO];
	[window setMinSize:NSMakeSize(400, 280)];
	[window setMaxSize:NSMakeSize(600, FLT_MAX)];
	[window setTitle:title];
	
	if (delegate)
		[window setDelegate:delegate];
	
	NSScrollView *scrollView = [[[NSScrollView alloc]
						initWithFrame:[[window contentView] frame]] autorelease];
	[scrollView setBorderType:NSNoBorder];
	[scrollView setHasVerticalScroller:YES];
	[scrollView setHasHorizontalScroller:NO];
	[scrollView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
	NSSize contentSize = [scrollView contentSize];
	NSTextView *textView = [[[NSTextView alloc] initWithFrame:(NSRect){{0,0},contentSize}] autorelease];
	[textView setMinSize:NSMakeSize(0.0, contentSize.height)];
	[textView setMaxSize:NSMakeSize(FLT_MAX, FLT_MAX)];
	[textView setVerticallyResizable:YES];
	[textView setHorizontallyResizable:NO];
	[textView setAutoresizingMask:NSViewWidthSizable];
	
	[textView setString:input];
	[textView setEditable:NO];
	[textView setSelectable:YES];
	
	[[textView textContainer] setContainerSize:NSMakeSize(contentSize.width, FLT_MAX)];
	[[textView textContainer] setWidthTracksTextView:YES];
	
	[scrollView setDocumentView:textView];
	[window setContentView:scrollView];
	[[window contentView] display];
	[window setLevel:NSFloatingWindowLevel];
	[window makeKeyAndOrderFront:nil];
	[window setLevel:NSNormalWindowLevel];
	[window makeFirstResponder:textView];
}
