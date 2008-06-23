//
//  CalculatorPrefPane.h
//  CalculatorPlugin
//
//  Created by Kevin Ballard on 7/27/04.
//  Copyright 2004 TildeSoft. All rights reserved.
//

#import <QSInterface/QSPreferencePane.h>

extern NSString *CalculatorDisplayPref;
extern NSString *CalculatorEnginePref;

#define CalculatorDisplayNormal 0
#define CalculatorDisplayLargeType 1
#define CalculatorDisplayNotification 2

#define CalculatorEngineBC 0
#define CalculatorEngineDC 1

@interface CalculatorPrefPane : QSPreferencePane {}
- (IBAction) viewManPage:(id)sender;
@end
