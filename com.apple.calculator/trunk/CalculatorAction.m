//
//  CalculatorAction.m
//  Quicksilver
//

#import <QSCore/QSLibrarian.h>
#import <QSCore/QSNotifyMediator.h>
#import "CalculatorAction.h"
#import "CalculatorPrefPane.h"

#define CalculatorDivider @"\n[=====Calculator Divider=====]\n"

@implementation CalculatorActionProvider
- (id) init {
	if ((self = [super init])) {
		[[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:CalculatorDisplayPref]];
		dcStack = [[NSString alloc] initWithString:@""];
	}
	return self;
}

- (void) dealloc {
	[dcStack release];
	[super dealloc];
}

- (QSObject *)calculate:(QSObject *)dObject {
	NSString *value;
	if ([[dObject primaryType] isEqualToString:QSFormulaType]) {
		value = [dObject objectForType:QSFormulaType];
		if ([value hasPrefix:@"="]) {
			value = [value substringFromIndex:1];
		} else if ([value hasPrefix:@" ="]) {
			value = [value substringFromIndex:2];
		}
	} else {
		value = [dObject objectForType:QSTextType];
	}
	value = [value stringByAppendingString:@"\n"];
	NSTask *task = [[NSTask alloc] init];
	NSPipe *inPipe = [[NSPipe alloc] init];
	NSFileHandle *input = [inPipe fileHandleForWriting];
	[task setStandardInput:inPipe];
	NSPipe *outPipe = [[NSPipe alloc] init];
	NSFileHandle *output = [outPipe fileHandleForReading];
	[task setStandardOutput:outPipe];
	[task setStandardError:outPipe];
	int calcEngine = [[NSUserDefaults standardUserDefaults] integerForKey:CalculatorEnginePref];
	if (calcEngine == CalculatorEngineDC) {
		[task setLaunchPath:@"/usr/bin/dc"];
	} else {
		[task setLaunchPath:@"/usr/bin/bc"];
		[task setArguments:[NSArray arrayWithObjects:@"-q",@"-l",nil]];
	}
	[task launch];
	if (calcEngine == CalculatorEngineDC) {
		[input writeData:[dcStack dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]];
		value = [NSString stringWithFormat:@"\n%@\n[%@\n]Pf", value, CalculatorDivider];
	}
	[input writeData:[value dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]];
	[input closeFile];
	[task waitUntilExit];
	NSString *outString = nil;
	int status = [task terminationStatus];
	if (status == 0) {
		NSData *data = [output availableData];
		outString = [NSString stringWithCString:[data bytes] length:[data length]];
	} else {
		outString = @"Error";
	}
	if (calcEngine == CalculatorEngineDC) {
		NSRange divRange = [outString rangeOfString:CalculatorDivider];
		if (divRange.location != NSNotFound) {
			NSString *stack = [outString substringFromIndex:(divRange.location + divRange.length)];
			stack = [[stack stringByTrimmingCharactersInSet:
				[NSCharacterSet whitespaceAndNewlineCharacterSet]] retain];
			// Limit stack to 40 elements
			NSArray *stackArray = [stack componentsSeparatedByString:@"\n"];
			if ([stackArray count] > 40) {
				stackArray = [stackArray subarrayWithRange:NSMakeRange(0,40)];
				stack = [[stackArray componentsJoinedByString:@"\n"] retain];
			}
			[dcStack release];
			dcStack = [stack retain];
			outString = [outString substringToIndex:divRange.location];
		} else {
			[dcStack release];
			dcStack = [[NSString alloc] initWithString:@""];
		}
	}
	outString = [outString stringByTrimmingCharactersInSet:
		[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	QSObject *result = [QSObject objectWithName:outString];
	[result setObject:outString forType:QSTextType];
	[result setObject:outString forType:QSFormulaType];
	[result setPrimaryType:QSTextType];
	
	[task release];
	[inPipe release];
	[outPipe release];
	
	switch ([[[NSUserDefaults standardUserDefaults] objectForKey:CalculatorDisplayPref] intValue]) {
		case CalculatorDisplayNormal:
			// Do nothing - we're popping the result back up
			break;
		case CalculatorDisplayLargeType: {
			// Display result as large type
			QSAction *largeTypeAction = [[QSLibrarian sharedInstance] actionForIdentifier:@"QSLargeTypeAction"];
			[largeTypeAction performOnDirectObject:result indirectObject:nil];
			[[QSReg preferredCommandInterface] selectObject:result];
			result = nil;
			break;
		} case CalculatorDisplayNotification: {
			// Display result as notification
			NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[QSResourceManager imageNamed:@"com.apple.calculator"], QSNotifierIcon, @"Calculation Result", QSNotifierTitle, outString, QSNotifierText, @"QSCalculatorResultNotification", QSNotifierType, nil];
			QSShowNotifierWithAttributes(attributes);
			[[QSReg preferredCommandInterface] selectObject:result];
			result = nil;
		}
	}
	return result;
}

@end
