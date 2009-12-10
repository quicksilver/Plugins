//
//  QSIndigoPlugIn_Source.m
//  QSIndigoPlugIn
//
//  Created by Nicholas Jitkoff on 10/19/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//

#import <QSCore/QSCore.h>
#import "QSIndigoPlugIn_Source.h"
#import "QSIndigo.h"


@implementation QSIndigoPlugIn_Source
 - (void)setQuickIconForObject:(QSObject *)object{
	[object setIcon:[QSResourceManager imageNamed:@"com.perceptiveautomation.indigo"]]; // An icon that is either already in memory or easy to load
 }

- (BOOL)loadChildrenForObject:(QSObject *)object{
	return NO;	
}

@end




NSString *X10AddressFromInt(int a){
	char codes[]={'M','E','C','K','O','G','A','I','N','F','D','L','P','H','B','J'};
	int devices[]={13,5,3,11,15,7,1,9,14,6,4,12,16,8,2,10};
	char code=codes[a >> 4];
	int device=devices[a & 0xF];
	//NSLog(@"ADDRESS: %c%d",code,device);
	return [NSString stringWithFormat:@"%c%d",code,device];
}





@implementation QSIndigoDBParser

- (BOOL)validParserForPath:(NSString *)path{
    return [[path pathExtension]isEqualToString:@"indiDb"];
}

- (NSArray *)objectsFromPath:(NSString *)path withSettings:(NSDictionary *)settings{
	// NSDictionary *dict=[NSDictionary dictionaryWithContentsOfFile: [path stringByStandardizingPath]];
	
	
	NSXMLParser *parser=[[NSXMLParser alloc]initWithData:[NSData dataWithContentsOfFile:path]];
	[parser setDelegate:self];
	//posts=[NSMutableArray arrayWithCapacity:1];
	[parser parse];
	
	
	NSMutableArray *objects=[NSMutableArray arrayWithCapacity:1];
	
	QSObject *newObject;
	NSEnumerator *e=[deviceList objectEnumerator];
	NSDictionary *device;
	while(device=[e nextObject]){
		newObject=[QSObject makeObjectWithIdentifier:[device objectForKey:@"Address"]];
		[newObject setObject:X10AddressFromInt([[device objectForKey:@"Address"]intValue]) forType:kQSX10AddressType];
		[newObject setName:[device objectForKey:@"Name"]];
		[newObject setDetails:[device objectForKey:@"Description"]];
		[newObject setPrimaryType:kQSX10AddressType];
		[objects addObject:newObject];
	}
	[deviceList release];
	deviceList=nil;
	
    return objects;
}



// XML Stuff
- (void)parser:(NSXMLParser*)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if ( [elementName isEqualToString:@"DeviceList"]) {
		if (!deviceList)
			deviceList = [[NSMutableArray alloc] init];
        return;
    }
	if ( [elementName isEqualToString:@"Device"] ) {
		currentDevice = [[NSMutableDictionary alloc] init];
		return;
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (!currentStringValue) {
        currentStringValue = [[NSMutableString alloc] initWithCapacity:50];
    }
    [currentStringValue appendString:string];
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	// ignore root and empty elements
    if (( [elementName isEqualToString:@"DeviceList"]) ||
        ( [elementName isEqualToString:@"Database"] )) return;
	
    if ( [elementName isEqualToString:@"Device"] ) {
        [deviceList addObject:currentDevice];
        [currentDevice release];
		currentDevice=nil;
        return;
    }
	//    NSString *prop = elementName;//[self currentProperty];
    if (currentDevice )
		[currentDevice setValue:[currentStringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
						 forKey:elementName];
	
    [currentStringValue release];
    currentStringValue = nil;
}


@end




