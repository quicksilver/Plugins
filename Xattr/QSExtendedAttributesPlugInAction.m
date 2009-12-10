//
//  QSExtendedAttributesPlugInAction.m
//  QSExtendedAttributesPlugIn
//
//  Created by Nicholas Jitkoff on 5/3/05.
//  Copyright __MyCompanyName__ 2005. All rights reserved.
//

#import "QSExtendedAttributesPlugInAction.h"

#import "NSFileManager+ExtendedAttributes.h"
@implementation QSExtendedAttributesPlugInAction
#define QSExtendedAttributesType @"qs.file.extendedAttributes"

#define kQSExtendedAttributesPlugInAction @"QSExtendedAttributesPlugInAction"

- (QSObject *)showExtendedAttributesForFile:(QSObject *)dObject{
	
	QSExtendedAttributes *attrs=[[NSFileManager defaultManager]extendedAttributesAtPath:[dObject singleFilePath]];
	
	NSLog(@"attr %@",[attrs allNames]);
	
	id controller=[[NSApp delegate]interfaceController];
	
	NSMutableArray *array=[NSMutableArray array];
	for(NSString * attr in [attrs allNames]){
		QSObject *object=[QSObject objectWithType:QSExtendedAttributesType value:[attrs attributeForKey:attr] name:[attrs attributeForKey:attr]];
		
		[object setDetails:attr];
		[array addObject:object];
	}
	[controller showArray:array];
	
	return nil;
}
@end
