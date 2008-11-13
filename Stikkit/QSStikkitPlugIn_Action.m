//
//  QSStikkitPlugIn_Action.m
//  QSStikkitPlugIn
//
//  Created by Nicholas Jitkoff on 9/18/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//

#import "QSStikkitPlugIn_Action.h"
#import <QSCore/QSCore.h>
#import <QSCore/QSNotifyMediator.h>

@implementation QSStikkitPlugIn (Action)

#define kQSStikkitPlugInAction @"QSStikkitPlugInAction"


#define QSURLEncode(s) [(NSString*)CFURLCreateStringByAddingPercentEscapes(NULL,s,NULL,@":@/=+&?", kCFStringEncodingUTF8) autorelease]



- (QSObject *)setContentOfStikkit:(NSString *)stikkitID toString:(NSString *)string {
	NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"QSStikkitUsername"];	
	NSString *password=[self passwordForUser:username];
	
	BOOL create = stikkitID == nil;
	NSString *formatString = create ? @"http://api.stikkit.com/stikkits.atom" 
									: @"http://@api.stikkit.com/stikkits/%@.atom";
		
	
	NSError *error;
	NSURL *url=[NSURL URLWithString:
		[NSString stringWithFormat:formatString, stikkitID]];
	
  
	NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:url
															cachePolicy:NSURLRequestUseProtocolCachePolicy
														timeoutInterval:60.0];
	[theRequest setHTTPMethod: create ?  @"POST" : @"PUT" ];
	
  NSString* s;
  s = [NSString stringWithFormat: @"%@:%@", username, password];
  s = [NSString stringWithFormat: @"Basic %@", [[s dataUsingEncoding: NSASCIIStringEncoding] stikkitEncodeBase64]];
  [theRequest setValue: s forHTTPHeaderField: @"Authorization"];
  [[s dataUsingEncoding: NSASCIIStringEncoding] stikkitEncodeBase64];
  
  
  
	NSString *postString = [NSString stringWithFormat:@"raw_text=%@", QSURLEncode(string)];
	NSData *postData = [postString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	
	[theRequest setValue:[NSString stringWithFormat:@"%d", [postData length]]
	  forHTTPHeaderField:@"Content-Length"];
	
	[theRequest setValue:@"application/x-www-form-urlencoded" 
	  forHTTPHeaderField:@"Content-Type"];
	
	[theRequest setHTTPBody:postData];
	
	//	[theRequest setValue:@"application/atom+xml, */*" forHTTPHeaderField:@"Accept"];
	
	//	[theRequest setValue:@"Quicksilver (Blacktree,MacOSX)" forHTTPHeaderField:@"User-Agent"]; 
	//	[theRequest setValue:[NSString stringWithFormat:@"basic %@:%@", QSURLEncode(username),password]
	//	  forHTTPHeaderField:@"Authorization"];
	
	//	NSURLConnection *theConnection=[[[NSURLConnection alloc] initWithRequest:theRequest delegate:nil];
	
	//NSLog(@"url %@ %@%@",url, [theRequest allHTTPHeaderFields], postString);
	NSURLResponse *response = nil;
	NSData *data=[NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&error];
	NSString *result=[[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]autorelease];
	
	
	//NSLog(@"string [%@] %d %@", result, [response statusCode], [NSHTTPURLResponse localizedStringForStatusCode:[response statusCode]]);
	NSDictionary *notification = [NSDictionary dictionaryWithObjectsAndKeys:
		create ? @"Stikkit Created" : @"Stikkit Updated", QSNotifierTitle,
		[QSResourceManager imageNamed:@"stikkit"], QSNotifierIcon,
		nil];
	
	QSShowNotifierWithAttributes(notification);
	
	return [self objectForPost: [[[[NSXMLDocument alloc] initWithData:data options:0 error:nil] autorelease] rootElement]];
	
	
}

- (QSObject *)appendToStikkit:(QSObject *)dObject withString:(QSObject *)iObject{
	NSString *string = [iObject stringValue];
	NSString *stikkitID = [[dObject identifier] lastPathComponent];
	
	NSString *content = [dObject stringValue];
	string = [content stringByAppendingFormat:@"%@", string];
	
	return [self setContentOfStikkit:stikkitID toString:string];
}


- (QSObject *)prependToStikkit:(QSObject *)dObject withString:(QSObject *)iObject{
	NSString *string = [iObject stringValue];
	NSString *stikkitID = [[dObject identifier] lastPathComponent];
	
	
	NSString *content = [dObject stringValue];
	NSMutableArray *lines = [[[content lines] mutableCopy] autorelease];
	[lines insertObject:string atIndex:[lines count] ? 1 : 0];
	string = [lines componentsJoinedByString:@"\r"];
	
	return [self setContentOfStikkit:stikkitID toString:string];
}

- (QSObject *)editStikkit:(QSObject *)dObject withString:(QSObject *)iObject{
	NSString *string = [iObject stringValue];
	NSString *stikkitID = [[dObject identifier] lastPathComponent];
	return [self setContentOfStikkit:stikkitID toString:string];
}

- (QSObject *)createStikkitWithString:(QSObject *)dObject{
	NSString *string = [dObject stringValue];
	return [self setContentOfStikkit:nil toString:string];
}


- (NSArray *)validIndirectObjectsForAction:(NSString *)action directObject:(QSObject *)dObject{
	NSString *defaultString = @"";
	if ([action isEqualToString:@"QSStikkitEditAction"]) {
		defaultString = [dObject objectForType:QSTextType];
	}
	return [NSArray arrayWithObject:[QSObject textProxyObjectWithDefaultValue:defaultString]];
	return nil;//return [QSLib arrayForType:QSVoodooPadPageType];
}




@end
