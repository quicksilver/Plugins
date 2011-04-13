//
//  QSUIAccessPlugIn_Source.h
//  QSUIAccessPlugIn
//
//  Created by Nicholas Jitkoff on 9/25/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//


#import "QSUIAccessPlugIn_Source.h"
#define kWindowsType @"WindowsType"
@interface QSUIAccessPlugIn_Source : NSObject{
}
@end

@interface QSObject (UIElement)
+(QSObject *)objectForUIElement:(id)element;
@end

@interface QSObject (Windows)
+ (QSObject *)objectForWindow:(id)aWindow;
@end
