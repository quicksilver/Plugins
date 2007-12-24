//
//  DiffModule.h
//  DiffModule
//
//  Created by Kevin Ballard on 8/4/04.
//  Copyright TildeSoft 2004. All rights reserved.
//

#import "DiffModule.h"

#import <Foundation/Foundation.h>

@interface DiffModule : QSActionProvider
{
	NSImage *diffIcon;
}
- (QSObject *) diffLeft:(QSObject *)dObject right:(QSObject *)iObject;
@end

