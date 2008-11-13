//
//  NSFileManager+ExtendedAttributes.h
//  QSExtendedAttributesPlugIn
//
//  Created by Nicholas Jitkoff on 5/3/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>



@interface QSExtendedAttributes : NSObject {
	NSString *path;
}
+ (id)extendedAttributesWithPath:(NSString *)path;
- (id)initWithPath:(NSString *)path;
- (id)attributeForKey:(NSString *)key;
- (void)setAttribute:(id)attr forKey:(NSString *)key;
@end

@interface NSFileManager (QSExtendedAttributes)
- (QSExtendedAttributes *)extendedAttributesAtPath:(NSString *)path;
@end
