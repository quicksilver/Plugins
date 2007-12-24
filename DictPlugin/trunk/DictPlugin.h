//
//  DictPlugin.h
//  DictPlugin
//
//  Created by Kevin Ballard on 8/1/04.
//  Copyright TildeSoft 2004. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QSCore/QSObject.h>
#import <QSCore/QSActionProvider.h>

@interface DictPlugin : QSActionProvider
{
	NSTask *dictTask;
	NSImage *dictIcon;
	NSString *dictTaskStatus;
	NSMutableData *buffer;
}
- (QSObject *) define:(QSObject *)dObject;
- (void) definitionFinished:(NSNotification *)aNotification;
- (void) dataAvailable:(NSNotification *)aNotification;
- (void) processBuffer;

@end
