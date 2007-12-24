//
//  CalculatorPrefPane.m
//  CalculatorPlugin
//
//  Created by Kevin Ballard on 7/27/04.
//  Copyright 2004 TildeSoft. All rights reserved.
//

#import "CalculatorPrefPane.h"
#import "CalculatorAction.h"

NSString *CalculatorDisplayPref = @"Calculator Results Display";
NSString *CalculatorEnginePref = @"CalculatorEngine";

@implementation CalculatorPrefPane

- (id) init {
	if ((self = [super init])) {
		[[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:CalculatorDisplayNormal], CalculatorDisplayPref, [NSNumber numberWithInt:CalculatorEngineBC], CalculatorEnginePref, nil]];
	}
	return self;
}

- (IBAction)viewManPage:(id)sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"x-man-page://%@", ([[NSUserDefaults standardUserDefaults] integerForKey:@"CalculatorEngine"] == CalculatorEngineDC) ? @"dc" : @"bc"]]];
}

- (NSString *)helpPage {
	return @"quicksilver/plug-ins/calculator_plug-in";
}

@end
