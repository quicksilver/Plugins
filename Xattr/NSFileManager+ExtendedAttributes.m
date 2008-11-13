//
//  NSFileManager+ExtendedAttributes.m
//  QSExtendedAttributesPlugIn
//
//  Created by Nicholas Jitkoff on 5/3/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "NSFileManager+ExtendedAttributes.h"
#include <sys/xattr.h>

@implementation NSFileManager (QSExtendedAttributes)
- (QSExtendedAttributes *)extendedAttributesAtPath:(NSString *)path{
	return [QSExtendedAttributes extendedAttributesWithPath:path];
}
@end


@implementation QSExtendedAttributes
+ (id)extendedAttributesWithPath:(NSString *)aPath;
{
	return [[[self alloc]initWithPath:aPath]autorelease];	
}

- (id)initWithPath:(NSString *)aPath;
{	
	self = [super init];
	if (self != nil) {
		path=[[aPath stringByStandardizingPath] retain];
	}
	return self;
}
- (void) dealloc {
	[path release];
	[super dealloc];
}

-(NSArray *)allNames{
	char *keys = 0x00; size_t size = 0x00; int options = 0x00;
	size=listxattr([path fileSystemRepresentation], keys, size, options);
	keys = calloc(size, sizeof(*keys));
	size = listxattr([path fileSystemRepresentation], keys, size, options);
	
	char *key = 0x00;
	int sLen = 0x00; 
	
	NSMutableArray *array=[NSMutableArray array];
	for(key = keys; key < keys + size; key += 0x01 + sLen)
	{
		sLen = strlen(key);
		[array addObject:[NSString stringWithUTF8String:key]];
	}
	free(keys);
	
	return array;
}
- (id)valueForUndefinedKey:(NSString *)key{
	return [self attributeForKey:key];
}
- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
	[self setAttribute:value forKey:key];
}
- (void)setNilValueForKey:(NSString *)key{
	[self setAttribute:nil forKey:key];	
}
- (id)attributeForKey:(NSString *)key;
{
	id value=nil;
	UInt8 *bytes = 0x00; size_t bSize = 0x00;
	bSize = getxattr([path fileSystemRepresentation], [key UTF8String], (void *)bytes, bSize, 0, 0);
	
	if(bSize > 0x00)
	{
		bytes = calloc(bSize + 0x01, sizeof(*bytes));
		bSize = getxattr([path fileSystemRepresentation], [key UTF8String], (void *)bytes, bSize, 0, 0);

		if(bSize > 0 && bSize!=-1)
		{
			value=[NSData dataWithBytes:bytes length:bSize];
		}
		free(bytes);
		if (bSize==-1) return nil;
		
		
		NSString *stringRepresentation=[[[NSString alloc]initWithData:value encoding:NSUTF8StringEncoding]autorelease];
		if (stringRepresentation)
			return stringRepresentation;
		
		return value;
	}
}
	
- (void)setAttribute:(id)attr forKey:(NSString *)key;
{
	if (!attr){
		removexattr([path fileSystemRepresentation], [key UTF8String],0);
		return;
	}
	
	if ([attr isKindOfClass:[NSString class]])
		attr=[attr dataUsingEncoding:NSUTF8StringEncoding];

	size_t size = setxattr([path fileSystemRepresentation], [key UTF8String], [attr bytes], [attr length], 0, 0);
}

@end
