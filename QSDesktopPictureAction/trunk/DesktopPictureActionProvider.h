//
//  DesktopPictureAction.h
//  DesktopPictureAction
//
//  Created by Tim Kingman on 8/3/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//

#import <QSCore/QSObject.h>
#import "DesktopPictureActionProvider.h"

@interface DesktopPictureActionProvider : NSObject
{
	NSString *urlString;
	NSURLConnection *urlConnection;
	NSMutableData *urlData;
    int targetDisplayNumber;
}
// Methods here to avoid compilation warnings, probably not entirely necessary...
- (IBAction) stopQuery:(id)sender;
- (QSObject *) setDesktopViaURL:(QSObject *)dObject onScreen:(QSObject *)iObject;
@end

