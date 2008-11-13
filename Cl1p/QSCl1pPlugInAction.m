//
//  QSCl1pPlugInAction.m
//  QSCl1pPlugIn
//
//  Created by Nicholas Jitkoff on 4/12/06.
//  Copyright __MyCompanyName__ 2006. All rights reserved.
//

#import "QSCl1pPlugInAction.h"

@implementation QSCl1pPlugInAction

#define CL1PDOWNLOAD @"http://download.cl1p.net/%@"
#define CL1PACCESS @"http://cl1p.net/%@"
#define CL1PVIEW @"http://d.cl1p.net/%@"

#define kQSCl1pPlugInAction @"QSCl1pPlugInAction"
NSArray *formElementArray(NSDictionary *dict,NSString *boundary){
	
	
	//NSString* boundary = @"0194784892923";
	NSArray* keys = [dict allKeys];
	NSString* result = [[NSString alloc] initWithString: @""];
	int i;
	for (i = 0; i < [keys count]; i++) {
		result = [result stringByAppendingString:
			[@"--" stringByAppendingString:
				[boundary stringByAppendingString:
					[@"\nContent-Disposition: form-data; name=\"" stringByAppendingString:
						[[keys objectAtIndex: i] stringByAppendingString:
							[@"\"\n\n" stringByAppendingString:
								[[dict valueForKey: [keys objectAtIndex: i]] stringByAppendingString: @"\n"]]]]]]];
	}
	result = [result stringByAppendingString: 
		[@"\n--" stringByAppendingString:
			[boundary stringByAppendingString:
				@"--\n"]]];
	return result;
}


- (QSObject *)uploadToClip:(QSObject *)dObject usingName:(QSObject *)iObject{
	NSString *path=[dObject singleFilePath];
	NSString *text=path?[NSString stringWithFormat:@"File: %@",[path lastPathComponent]]:[dObject stringValue];
	NSString *name=[iObject stringValue];
	if (![name length])
		name=[NSString uniqueString];
	NSLog(@"upload %@ %@ as %@",path,text,name);
	
	
	NSString *url=[NSString stringWithFormat:CL1PACCESS,[name URLEncoding]];
	
		
	NSMutableURLRequest *postRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
															cachePolicy:NSURLRequestUseProtocolCachePolicy
														timeoutInterval:30.0];
	
	NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys: 
                      @"",@"p1",
                      @"",@"p2",
                      @"1",@"viewMode",
		text,@"ctrlcv",
		nil];
	

	//adding header information:
	[postRequest setHTTPMethod:@"POST"];
	
	NSString *stringBoundary = [NSString stringWithString:@"0xKhTmLbOuNdArY"];
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",stringBoundary];
	[postRequest addValue:contentType forHTTPHeaderField: @"Content-Type"];
	

	//setting up the body:
	NSMutableData *postBody = [NSMutableData data];
	[postBody appendData:[[NSString stringWithFormat:@"--%@",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	NSEnumerator * e = [dict keyEnumerator];
	NSString *key=nil;
	while(key=[e nextObject]){
		[postBody appendData:[[NSString stringWithFormat:@"\r\nContent-Disposition: form-data; name=\"%@\"\r\n\r\n",key] dataUsingEncoding:NSUTF8StringEncoding]];
		[postBody appendData:[[dict objectForKey:key] dataUsingEncoding:NSUTF8StringEncoding]];
		[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
		
	}

	if (path){
		[postBody appendData:[[NSString stringWithFormat:@"\r\nContent-Disposition: form-data; name=\"uploadFile\"; filename=\"%@\"\r\n",[path lastPathComponent]] dataUsingEncoding:NSUTF8StringEncoding]];
		[postBody appendData:[[NSString stringWithString:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
		[postBody appendData:[NSData dataWithContentsOfFile:path]];
		[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	}
	
	[postBody appendData:[[NSString stringWithFormat:@"--\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	NSLog(@"body  %@ %@",url, [[NSString alloc]initWithData:postBody  encoding:NSUTF8StringEncoding]);
	[postRequest setHTTPBody:postBody];
	
	NSURLResponse *resp = nil;
	NSError *err = nil;
	NSData *returnedData = [NSURLConnection sendSynchronousRequest: postRequest returningResponse: &resp error: &err];
	NSLog(@"resp err %@ %@ %@",resp,err,[[NSString alloc]initWithData:returnedData  encoding:NSUTF8StringEncoding]);
	//	[postRequest setHTTPBodyStream:[NSInputStream inputStreamWithFileAtPath:filePath]];
	

	if (err) {
		NSBeep();
		return nil;
	}

	[[NSWorkspace sharedWorkspace]openURL:[NSURL URLWithString:url]];
	//NSLog(@"url %@",url);
	
	if (path){
		url=[NSString stringWithFormat:CL1PACCESS,[name URLEncoding]];
	}else{
		url=[NSString stringWithFormat:CL1PVIEW,[name URLEncoding]];
	}
//	return nil;
	return [QSObject URLObjectWithURL:url title:@"Cl1p URL"];
	
}


- (NSArray *)validIndirectObjectsForAction:(NSString *)action directObject:(QSObject *)dObject{
	QSObject *textObject=[QSObject textProxyObjectWithDefaultValue:@""];
	return [NSArray arrayWithObject:textObject];
}
@end
