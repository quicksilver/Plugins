//
//  CalculatorAction.m
//  Quicksilver
//

#import <QSCore/QSLibrarian.h>
#import <QSCore/QSNotifyMediator.h>
#import "CalculatorAction.h"
#import "CalculatorPrefPane.h"
#import "CalculatePrivate.h"

@implementation CalculatorActionProvider
- (id) init {
	if ((self = [super init])) {
		[[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:CalculatorDisplayPref]];
	}
	return self;
}


- (QSObject *)calculate:(QSObject *)dObject {
	NSString *value;
	if ([[dObject primaryType] isEqualToString:QSFormulaType]) {
		value = [dObject objectForType:QSFormulaType];
		value = [[value componentsSeparatedByString:@"="] objectAtIndex:1];
	} else {
		value = [dObject objectForType:QSTextType];
	}
	
	// Taken from QSB Source Code ** BELOW **
	
	// Fix up separators and decimals. The Calculator framework wants
    // '.' for decimals, and no grouping separators.
    NSLocale *locale = [NSLocale autoupdatingCurrentLocale];
    NSString *decimalSeparator = [locale objectForKey:NSLocaleDecimalSeparator];
    NSString *groupingSeparator
	= [locale objectForKey:NSLocaleGroupingSeparator];
    NSMutableString *fixedQuery = [NSMutableString stringWithString:value];
    [fixedQuery replaceOccurrencesOfString:groupingSeparator
                                withString:@""
                                   options:0
                                     range:NSMakeRange(0, [fixedQuery length])];
    [fixedQuery replaceOccurrencesOfString:decimalSeparator
                                withString:@"."
                                   options:0
                                     range:NSMakeRange(0, [fixedQuery length])];

    char answer[1024];
    answer[0] = '\0';
    int success
	= CalculatePerformExpression((char *)[fixedQuery UTF8String],
								 10, 1, answer);
    if (success) {
		NSString *outString = [NSString stringWithUTF8String:answer];

		// Taken from QSB Source Code ** ABOVE **

		QSObject *result = [QSObject objectWithName:outString];
		[result setObject:outString forType:QSTextType];
		[result setObject:outString forType:QSFormulaType];
		[result setPrimaryType:QSTextType];
	switch ([[[NSUserDefaults standardUserDefaults] objectForKey:CalculatorDisplayPref] intValue]) {
		case CalculatorDisplayNormal:
			// Do nothing - we're popping the result back up
			break;
		case CalculatorDisplayLargeType: {
			// Display result as large type
			QSShowLargeType(outString);
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
	return nil;
}

@end
