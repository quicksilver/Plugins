//
//  FindModule.h
//  FindModule
//
//  Created by Kevin Ballard on 8/5/04.
//  Copyright TildeSoft 2004. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FindModulePrefPane.h"


@interface FindModule : QSActionProvider
{
	NSTask *findTask;
	NSString *findStatus;
	NSImage *findImage;
	NSMutableData *buffer;
	NSMutableArray *incrementalResults;
}
@end
