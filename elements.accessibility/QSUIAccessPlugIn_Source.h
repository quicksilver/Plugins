//
//  QSUIAccessPlugIn_Source.h
//  QSUIAccessPlugIn
//
//  Created by Nicholas Jitkoff on 9/25/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//

#import "QSUIAccessPlugIn_Source.h"
#define kWindowsType @"WindowsType"

@interface QSUIAccessPlugIn_Source : NSObject {}
- (NSString *)identifierForObject:(id <QSObject>)object;
- (void)setQuickIconForObject:(QSObject *)object;
- (BOOL)objectHasChildren:(QSObject *)object;
- (NSString *)detailsOfObject:(QSObject *)object;
- (NSArray *)childrenForElement:(AXUIElementRef)element;
- (NSArray *)objectsForElements:(NSArray *)elements process:(NSDictionary *)process;
- (BOOL)loadChildrenForObject:(QSObject *)object;
@end

@interface QSObject (UIElement)
+ (QSObject *)objectForUIElement:(id)element name:(NSString *)name process:(NSDictionary *)process;
@end

@interface QSObject (Windows)
+ (QSObject *)objectForWindow:(id)element name:(NSString *)name process:(NSDictionary *)process;
@end

