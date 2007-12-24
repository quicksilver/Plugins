//
//  FindModulePrefPane.h
//  FindModule
//
//  Created by Kevin Ballard on 8/5/04.
//  Copyright 2004 TildeSoft. All rights reserved.
//

#import "FindModule.h"

extern NSString *FindModuleComplexityPref;

enum {
	FindModuleComplexitySimple = 0,
	FindModuleComplexityGlob = 1,
};

@interface FindModulePrefPane : QSPreferencePane {
	NSImage *findImage;
}

@end
