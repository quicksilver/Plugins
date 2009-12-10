//
//  QSDeliciousLibraryModule_Source.m
//  QSDeliciousLibraryModule
//
//  Created by Nicholas Jitkoff on 11/8/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//

#import "QSDeliciousLibraryModule_Source.h"
#import <QSCore/QSObject.h>


#define QSAmazonItemType @"com.amazon.asin"

#define QSDeliciousLibraryItemType @"qs.deliciouslibrary.item"
#define QSDeliciousLibraryShelfType @"qs.deliciouslibrary.shelf"

#define DELICIOUS_FILE [@"~/Library/Application Support/Delicious Library/Library Media Data.xml" stringByStandardizingPath]
#define DELICIOUS_IMAGES [@"~/Library/Application Support/Delicious Library/Images/" stringByStandardizingPath]
#define DELICIOUS_TYPES [NSArray arrayWithObjects:@"book",@"movie",@"game",@"music",nil]
@implementation QSDeliciousLibraryModule_Source
- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry{
    return NO;
}

- (NSImage *) iconForEntry:(NSDictionary *)dict{
    return [QSResourceManager imageNamed:@"com.delicious-monster.library"];
}

- (NSString *)identifierForObject:(id <QSObject>)object{
    return nil;
}

- (NSDictionary *)library{
	if (!library){
		NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
		
		NSData *data=[NSData dataWithContentsOfFile:DELICIOUS_FILE];
		
		NSString *string=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
		//NSLog(@"data %@",string,error);
		
		NSXMLParser *itemParser=[[[NSXMLParser alloc]initWithData:data]autorelease];
		
		items=[NSMutableArray arrayWithCapacity:1];
		shelves=[NSMutableArray arrayWithCapacity:1];
		
		
		[itemParser setDelegate:self];
		[itemParser parse];
		
		NSDictionary *keyedItems=[NSDictionary dictionaryWithObjects:items forKeys:[items valueForKey:@"uuid"]];
		NSDictionary *keyedShelves=[NSDictionary dictionaryWithObjects:shelves forKeys:[shelves valueForKey:@"uuid"]];
		
		
		library=[[NSDictionary alloc]initWithObjectsAndKeys:items,@"items",keyedItems,@"keyedItems",shelves,@"shelves",keyedShelves,@"keyedShelves",nil];
	}
	return library;
}
- (NSArray *)childrenForShelfUUID:(NSString *)uuid{
	NSArray *itemUUIDs=[[[[self library] objectForKey:@"keyedShelves"]objectForKey:uuid]objectForKey:@"items"];
	NSArray *children=[[[self library] objectForKey:@"keyedItems"]objectsForKeys:itemUUIDs notFoundMarker:[NSNull null]];
	children=[self performSelector:@selector(objectForItemDict:) onObjectsInArray:children returnValues:YES];
	return children;
}

- (id)objectForShelfDict:(NSDictionary *)dict{
	QSObject *newObject;
	NSString *name=[dict objectForKey:@"name"];
	
	if (!name)name=@"untitled shelf";
	newObject=[QSObject makeObjectWithIdentifier:[dict objectForKey:@"uuid"]];
	[newObject setObject:[dict objectForKey:@"uuid"] forType:QSDeliciousLibraryShelfType];	
	[newObject setName:name];
	[newObject setPrimaryType:QSDeliciousLibraryShelfType];
	return newObject;
}
- (id)objectForItemDict:(NSDictionary *)dict{
	QSObject *newObject;
	NSString *name=[dict objectForKey:@"title"];
	if (name) name = [(NSString *) CFXMLCreateStringByUnescapingEntities(NULL, (CFStringRef) name, NULL) autorelease];
	newObject=[QSObject makeObjectWithIdentifier:[dict objectForKey:@"uuid"]];
	[newObject setObject:[dict objectForKey:@"uuid"] forType:QSDeliciousLibraryItemType];	
	[newObject setObject:[dict objectForKey:@"asin"] forType:QSAmazonItemType];
	[newObject setName:name];
	[newObject setPrimaryType:QSDeliciousLibraryItemType];
	return newObject;
}


- (NSArray *) objectsForEntry:(NSDictionary *)theEntry{
	NSDictionary *lib=[self library];
	
    NSMutableArray *objects=[NSMutableArray arrayWithCapacity:1];
	
	NSEnumerator *e=[[lib objectForKey:@"shelves"] objectEnumerator];
	NSDictionary *item;
	
	while(item=[e nextObject]){
		[objects addObject:[self objectForShelfDict:item]];
	}
	
	e=[[lib objectForKey:@"items"] objectEnumerator];
	while(item=[e nextObject]){
		[objects addObject:[self objectForItemDict:item]];
	}
	
	
	
    return objects;
    
}



// XML Stuff
- (void)parser:(NSXMLParser*)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	//	NSLog(@"started %@ %@ %@ %@",elementName,namespaceURI,qName,attributeDict);
	
	if ([DELICIOUS_TYPES containsObject:elementName] && !inRecommendations){
		NSMutableDictionary *dict=[[[NSMutableDictionary alloc]initWithDictionary:attributeDict]autorelease];
		[dict setObject:elementName forKey:@"type"];	
		currentItem=dict;
	}
	if ([elementName isEqualToString:@"recommendations"])
		inRecommendations=YES;
	
	if ([elementName isEqualToString:@"shelf"]){
		NSMutableDictionary *dict=[[[NSMutableDictionary alloc]initWithDictionary:attributeDict]autorelease];
		[dict setObject:[NSMutableArray array] forKey:@"items"];	
		
		currentShelf=dict;
	}
	
	if ([elementName isEqualToString:@"linkto"]){
		[[currentShelf objectForKey:@"items"]addObject:[attributeDict objectForKey:@"uuid"]];	
		
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	//	NSLog(@"ended %@ %@ %@ %@",elementName,namespaceURI,qName);
	if ([DELICIOUS_TYPES containsObject:elementName]&&!inRecommendations){
		[items addObject:currentItem];
		currentItem=nil;
	}
	
	if ([elementName isEqualToString:@"recommendations"])
		inRecommendations=NO;
	
	if ([elementName isEqualToString:@"shelf"]){
		[shelves addObject:currentShelf];
		currentShelf=nil;
	}
}

- (BOOL)objectHasChildren:(QSObject *)object{
	if ([[object primaryType]isEqualToString:QSDeliciousLibraryShelfType]){return YES;}	
}
- (BOOL)loadChildrenForObject:(QSObject *)object{
	if ([[object primaryType]isEqualToString:QSDeliciousLibraryShelfType]){		
		[object setChildren:[self childrenForShelfUUID:[object objectForType:QSDeliciousLibraryShelfType]]];
		return YES;
	}else if ([object singleFilePath]){
		[object setChildren:[self objectsForEntry:nil]];
		return YES;
	}
	return NO;
}

// Object Handler Methods


- (NSString *)detailsOfObject:(QSObject *)object{
	return nil;
	NSString *uuid=[object objectForType:QSDeliciousLibraryItemType];
	return;
}

- (void)setQuickIconForObject:(QSObject *)object{
	if ([[object primaryType]isEqualToString:QSDeliciousLibraryShelfType]){
		[object setIcon:[QSResourceManager imageNamed:@"DeliciousLibraryShelf"]]; // An icon that is either already in memory or easy to load
		
	}
}
- (BOOL)loadIconForObject:(QSObject *)object{
	if ([[object primaryType]isEqualToString:QSDeliciousLibraryItemType]){
		NSString *uuid=[object objectForType:QSDeliciousLibraryItemType];
		NSFileManager *fm=[NSFileManager defaultManager];
		
		
		NSString *imagePath=DELICIOUS_IMAGES;
		imagePath=[imagePath stringByAppendingPathComponent:@"Medium Covers"];
		imagePath=[imagePath stringByAppendingPathComponent:uuid];
		
		if (![fm fileExistsAtPath:imagePath]){
			imagePath=DELICIOUS_IMAGES;
			imagePath=[imagePath stringByAppendingPathComponent:@"Plain Covers"];
			imagePath=[imagePath stringByAppendingPathComponent:uuid];
			imagePath=[imagePath stringByAppendingPathExtension:@"jpg"];
		}
		//	NSLog(imagePath);
		
		NSImage *icon=[[[NSImage alloc]initWithContentsOfFile:imagePath]autorelease];
		if (icon){
			[object setIcon:icon];
			return YES;
		}
		
	}
	return NO;
}

@end
