//
//  CalculatorPrefPane.h
//  CalculatorPlugin
//
//  Created by Kevin Ballard on 7/27/04.
//  Copyright 2004 TildeSoft. All rights reserved.
//

#import <QSInterface/QSPreferencePane.h>

extern NSString *CalculatorDisplayPref;

#define CalculatorDisplayNormal 0
#define CalculatorDisplayLargeType 1
#define CalculatorDisplayNotification 2


@interface CalculatorPrefPane : QSPreferencePane {}
@end
