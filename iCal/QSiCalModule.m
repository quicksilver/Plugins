//
//  QSiCalModule.m
//  QSiCalModule
//
//  Created by Nicholas Jitkoff on 9/12/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//

#import "QSiCalModule.h"
#import <QSCore/QSLibrarian.h>
#import <CalendarStore/CalendarStore.h>


#define dayAttributes [NSDictionary dictionaryWithObjectsAndKeys:style,NSParagraphStyleAttributeName,[NSFont fontWithName:@"Helvetica Bold" size:54], NSFontAttributeName,[NSColor colorWithCalibratedWhite:0.2 alpha:1.0],NSForegroundColorAttributeName,nil]
#define monthAttributes [NSDictionary dictionaryWithObjectsAndKeys:style2,NSParagraphStyleAttributeName,[NSNumber numberWithFloat:0.0],NSKernAttributeName,[NSFont fontWithName:@"Helvetica Bold" size:14], NSFontAttributeName,[NSColor whiteColor],NSForegroundColorAttributeName,nil]

@implementation QSiCalModule

- (BOOL)drawIconForObject:(QSObject *)object inRect:(NSRect)rect flipped:(BOOL)flipped{
	
	NSImage *icon=[QSResourceManager imageNamed:@"iCal-Empty"];
	[icon setFlipped:flipped];
	NSImageRep *bestBadgeRep=[icon bestRepresentationForSize:rect.size];    
	[icon setSize:[bestBadgeRep size]];
	[icon drawInRect:rect fromRect:NSMakeRect(0,0,[bestBadgeRep size].width,[bestBadgeRep size].height) operation:NSCompositeSourceOver fraction:1.0];
	
	NSMutableParagraphStyle *style=[[[NSParagraphStyle defaultParagraphStyle]mutableCopy]autorelease];
	NSMutableParagraphStyle *style2=[[[NSParagraphStyle defaultParagraphStyle]mutableCopy]autorelease];
	[style setAlignment:NSCenterTextAlignment];
	[style2 setFirstLineHeadIndent:1.0];
    [style2 setHeadIndent:1.0];
	
	
	NSGraphicsContext *context=[NSGraphicsContext currentContext];
	[context saveGraphicsState];
	NSAffineTransform *transform=[NSAffineTransform transform];
	
	[transform translateXBy:NSMinX(rect) yBy:NSMinY(rect)];
	[transform rotateByDegrees:11]; // 10.25 would be correct
	[transform concat]; 
	
	NSCalendarDate *date=[NSCalendarDate date];
	NSRect dayRect=NSMakeRect(25,10,92,54);
	
	NSRect monthRect=NSMakeRect(30,67,44,24);
	
	NSString *dayString=[NSString stringWithFormat:@"%d",[date dayOfMonth]];
	NSString *monthString=[[date descriptionWithCalendarFormat:@"%b"]uppercaseString];
	
	dayRect.size.height=[dayString sizeWithAttributes:dayAttributes].height;
	monthRect.size.height=[monthString sizeWithAttributes:monthAttributes].height;
	
	[[NSColor blackColor]set];
	[dayString drawInRect:dayRect withAttributes:dayAttributes];
	[monthString drawInRect:monthRect withAttributes:monthAttributes];
	
	[context restoreGraphicsState];
	
	return YES;	
}

- (void)addNodesFromList:(NSArray *)list toArray:(NSMutableArray *)array{
	
	// get the list of calendars using CalCalendarStore
	NSArray *listOfCalendars = [[CalCalendarStore defaultCalendarStore] calendars];
	
	if (!listOfCalendars) {
		[[NSAlert alertWithMessageText:@"iCal Error" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"You need to upgrade your calendars to a format compatible with Mac OS X Leopard by opening iCal first"] runModal];
	}
	for (CalCalendar *eachItem in listOfCalendars)
	{
		if(!([[eachItem type] isEqualToString:@"Birthday"]))
		{

		QSObject *object = [QSObject objectWithName:[eachItem title]];
		[object setDetails:@"Calendar"];
		[object setIcon:[[[NSImage alloc] initByReferencingFile:[[NSBundle bundleWithIdentifier:@"com.apple.iCal"] pathForResource:@"bookmark" ofType:@"icns"]] autorelease]];
		[object setObject:[eachItem title] forType:@"QSICalCalendar"];
		[array addObject:object];
		
		
		}
	}
		}

- (NSArray *)validIndirectObjectsForAction:(NSString *)action directObject:(QSObject *)dObject{
	NSFileManager *fm=[NSFileManager defaultManager];
	NSMutableArray *array=[NSMutableArray array];
	NSString *path=[@"~/Library/Calendars" stringByStandardizingPath];
	NSMutableArray *list=[NSMutableArray array];
	
	// Get contents of calendars folder
	NSArray *dirArray = [fm directoryContentsAtPath:path];
	
	//NSLog(@"dirArray: %@", dirArray);
	int i = 0;
	for(NSString *path in dirArray)
	{
		//NSLog(@"path: %@", path);
		if([[dirArray objectAtIndex:i] rangeOfString:@".calendar"].location != NSNotFound)
		{
			
			[list addObject:path];
		}
		i += 1;
	}
	
	//NSLog(@"list is: %@", list);
	
	//NSDictionary *nodes=[NSDictionary dictionaryWithContentsOfFile:[path stringByAppendingPathComponent:@"nodes.plist"]];
	//NSArray *list=[nodes objectForKey:@"List"];
	
	[self addNodesFromList:list toArray:array];
	
	//NSMutableArray *objects=[QSLib scoredArrayForString:nil inSet:[NSSet setWithArray:array]];
	return array;
}
- (NSAppleScript *)script{
	NSString *path=[[NSBundle bundleForClass:[self class]]pathForResource:@"iCal" ofType:@"scpt"];
	NSAppleScript *script=nil;
	if (path)
		script=[[[NSAppleScript alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:nil]autorelease];	
}

//NSLog(@"objects %@ %@",dObject,iObject);	
-(QSObject *)createEvent:(QSObject *)dObject inCalendar:(QSObject *)iObject{
	NSString *calendar=iObject?[iObject objectForType:@"QSICalCalendar"]:@"";
	NSString *dateString=[dObject stringValue];
	NSString *subjectString=dateString;
	NSArray *components=[dateString componentsSeparatedByString:@"--"];
	if ([components count]>1){
		dateString=[components objectAtIndex:0];
		subjectString=[[components objectAtIndex:1]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	}
	NSDate *date=[NSCalendarDate dateWithNaturalLanguageString:dateString];
	if(![[date timeZone]isEqualToTimeZone:[NSTimeZone localTimeZone]])
		date=[date addTimeInterval:-[[NSTimeZone localTimeZone]secondsFromGMTForDate:date]];
	if (!date) date=[NSDate date];
	
	NSArray *arguments=[NSArray arrayWithObjects:date,subjectString,calendar,nil];
	//-----
	NSDictionary *dict=nil;
	[[self script] executeSubroutine:@"create_event" arguments:arguments error:&dict];
	if (dict)NSLog(@"Create Error: %@",dict);
	return nil;
}

-(QSObject *)createToDo:(QSObject *)dObject inCalendar:(QSObject *)iObject{
	NSString *calendar=iObject?[iObject objectForType:@"QSICalCalendar"]:@"";
	NSString *dateString=[dObject stringValue];
	NSString *subjectString=dateString;
	NSArray *components=[dateString componentsSeparatedByString:@"--"];
	if ([components count]>1){
		dateString=[components objectAtIndex:0];
		subjectString=[[components objectAtIndex:1]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	}
	NSDate *date=[NSCalendarDate dateWithNaturalLanguageString:dateString];
	
	if(![[date timeZone]isEqualToTimeZone:[NSTimeZone localTimeZone]])
		date=[date addTimeInterval:-[[NSTimeZone localTimeZone]secondsFromGMTForDate:date]];
	if ([date yearOfCommonEra]>3000) date=[NSDate date];
	if (!date) date=[NSDate date];
	
	NSLog(@"date %@",date);
	int priority=0;
	while([subjectString hasPrefix:@"!"]){
		subjectString=[subjectString substringFromIndex:1];
		priority++;
	}
	
	
	NSArray *arguments=[NSArray arrayWithObjects:date,subjectString,[NSNumber numberWithInt:MIN(priority,3)],calendar,nil];
	
	//-----
	NSDictionary *dict=nil;
	[[self script] executeSubroutine:@"create_todo" arguments:arguments error:&dict];
	if (dict) NSLog(@"Create Error: %@",dict);
	
	return nil;
}


@end