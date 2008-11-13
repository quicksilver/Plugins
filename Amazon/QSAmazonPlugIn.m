//
//  QSAmazonPlugIn.m
//  QSAmazonPlugIn
//
//  Created by Nicholas Jitkoff on 10/5/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//


#ifndef MAC_OS_X_VERSION_10_4 > MAC_OS_X_VERSION_MAX_ALLOWED
int NSXMLDocumentTidyXML = 1 << 10;  //  Correct value goes here.
#endif


#import "QSAmazonPlugIn.h"

@implementation QSAmazonPlugIn

//-(NSImage *) imageForTrackInfo:(NSDictionary *)info{
	
	
- (NSString *)imageURLForTrackInfo:(NSDictionary *)info{
	NSString *album=[info objectForKey:@"Album"];
	NSString *artist=[info objectForKey:@"Artist"];
	NSString *song=[info objectForKey:@"Name"];

	NSTimeInterval now=[NSDate timeIntervalSinceReferenceDate];
	
	
	if (now-lastHit<1){
		//NSLog(@"sleeping %f",now-lastHit);
		[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceReferenceDate:1+lastHit]];
	}

	lastHit=now;
	//-------------Imported Code
	
	Class XMLDocument = NSClassFromString(@"NSXMLDocument");
	NSImage *artwork = nil;
	NSString *imageURL = nil;
	//NSLog( @"Go go interweb" );
	
	NSString *search = [[NSString stringWithFormat:@"http://aws-beta.amazon.com/onca/xml?Service=AWSProductData&SubscriptionId=013QCK3EPGWMMYTWEF02&Operation=ItemSearch&SearchIndex=Music&Keywords=%s %s&ResponseGroup=Images", [artist UTF8String],[album UTF8String]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSURL *url = [NSURL URLWithString:search];
	
	if ( XMLDocument ) {			// Tiger
		id testXML = [[[XMLDocument alloc] initWithContentsOfURL:url 
														 options:NSXMLDocumentTidyXML 
														   error:NULL] autorelease];
		NSArray *imageArray = [testXML nodesForXPath:@"/ItemSearchResponse[1]/Items[1]/Item/MediumImage[1]/URL[1]" error:NULL];
		if ( [imageArray count] > 0 ) {
			imageURL = [[imageArray objectAtIndex:0] stringValue];
			imageURL = [imageURL substringToIndex:[imageURL length]-1];
			NSLog( @"imageURL(XML) - \"%@\"", imageURL );
		}
	} else {						// Everyone Else
		NSString *xml = [NSString stringWithContentsOfURL:url];
		NSRange open = [xml rangeOfString:@"<MediumImage><URL>"];
		if(open.length != 0) {
			imageURL = [xml substringFromIndex:open.location +open.length];
			[url release];
			
			NSRange close = [imageURL rangeOfString:@"</URL>"];
			imageURL = [imageURL substringToIndex:close.location];
			//NSLog(@"ImageURL(OldStyle): %s",[xml UTF8String]);
		}
	}
	
	return imageURL;
	
	if ( imageURL ) {
		artwork = [[[NSImage alloc] initWithData:[NSData dataWithData:[[NSURL URLWithString:imageURL] resourceDataUsingCache:YES]] ] autorelease];
	}
	
	return artwork;
}


@end
