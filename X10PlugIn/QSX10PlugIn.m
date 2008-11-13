//
//  QSX10PlugIn.m
//  QSX10PlugIn
//
//  Created by Nicholas Jitkoff on 11/11/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//

#import "QSX10PlugIn.h"

@implementation QSX10PlugIn

- (void)sendAction:(NSString *)action toDevice:(NSString *)device{
	//curl -m 1  http://192.168.10.224/0?{2F=A,3L=1,3E=On}>/dev/null;
	
	NSString *houseCode=@"http://192.168.10.224/0?2F=A";
	NSString *unitCode=@"http://192.168.10.224/0?3L=1";
	NSString *actionCode=@"http://192.168.10.224/0?3E=On";
	
	NSMutableURLRequest *houseRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:houseCode]
															  cachePolicy:NSURLRequestReloadIgnoringCacheData
														  timeoutInterval:3.0];
	NSMutableURLRequest *unitRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:unitCode]
															 cachePolicy:NSURLRequestReloadIgnoringCacheData
														 timeoutInterval:3.0];
	NSMutableURLRequest *actionRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:actionCode]
															   cachePolicy:NSURLRequestReloadIgnoringCacheData
														   timeoutInterval:3.0];
	
	NSDictionary *error=nil;
	NSData *data=[NSURLConnection sendSynchronousRequest:houseRequest returningResponse:nil error:&error];
	NSLog(@"data %@ %@",data,error);
	[NSURLConnection sendSynchronousRequest:unitRequest returningResponse:nil error:&error];
	[NSURLConnection sendSynchronousRequest:actionRequest returningResponse:nil error:&error];
	
	
}


@end
