//
//  QSGoogleCalendarPlugInAction.m
//  QSGoogleCalendarPlugIn
//
//  Created by Nicholas Jitkoff on 4/30/06.
//  Copyright __MyCompanyName__ 2006. All rights reserved.
//

#import "QSGoogleCalendarPlugInAction.h"
#import <QSCore/QSNotifyMediator.h>
@implementation QSGoogleCalendarPlugInAction


#define kQSGoogleCalendarPlugInAction @"QSGoogleCalendarPlugInAction"
- (IBAction)endPanel:(id)sender{
	[NSApp stopModalWithCode:[sender tag]];
}

-(NSString *)authWithLogin:(NSString *)login pass:(NSString *)pass{
	NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys: 
		login,@"Email",
		pass,@"Passwd",
		@"blacktree-quicksilver-1",@"source",
		 @"HOSTED_OR_GOOGLE", @"accountType",
		@"cl",@"service",
		nil];
	
	NSMutableArray *arguments=[NSMutableArray array];
	NSEnumerator * e = [dict keyEnumerator];
	NSString *key=nil;
	while(key=[e nextObject]){
		[arguments addObject:[NSString stringWithFormat:@"%@=%@",key,[[dict objectForKey:key]URLEncoding]]];
	}
	
	NSMutableString *url=[NSString stringWithFormat:@"https://www.google.com/accounts/ClientLogin?%@",[arguments componentsJoinedByString:@"&"]];
	NSMutableURLRequest *postRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
															 cachePolicy:NSURLRequestUseProtocolCachePolicy
														 timeoutInterval:30.0];
	[postRequest setHTTPMethod:@"POST"];
	//NSLog(@"url %@", url);
	NSURLResponse *resp = nil;
	NSError *err = nil;
	NSData *returnedData = [NSURLConnection sendSynchronousRequest: postRequest returningResponse: &resp error: &err];
	NSString *result=[[[NSString alloc]initWithData:returnedData encoding:NSUTF8StringEncoding]autorelease];
	if ([result rangeOfString:@"Error"].location!=NSNotFound){
		return nil;
	}else{
		NSString *newauth=[[result componentsSeparatedByString:@"Auth="]lastObject];
		newauth=[newauth stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		//NSLog(@"authenth %@\r%@",result,resp);
		return newauth;	
	}
	return nil;
	
}

#define QSURLEncode(s) [(NSString*)CFURLCreateStringByAddingPercentEscapes(NULL,s,NULL,@":@/=+&?", kCFStringEncodingUTF8) autorelease]

-(NSString *)loginToCalendar{
	if (!auth){
		
		
		NSString *login=[[NSUserDefaults standardUserDefaults]stringForKey:@"QSGoogleCalendarUser"];
		NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"http://%@@calendar.google.com",QSURLEncode(login)]];
		NSString *pass=[url keychainPassword];
		if (pass)
			auth=[[self authWithLogin:login pass:pass]retain];
		
		while (!auth){
			if (!loginPanel)
				[NSBundle loadNibNamed:@"QSGoogleCalendarPasswordAlert" owner:self];
			
			[NSApp activateIgnoringOtherApps:YES];
			[loginPanel center];
			[loginPanel makeKeyAndOrderFront:nil];
			
			if (![NSApp runModalForWindow:loginPanel]) break;
			login=[loginField stringValue];
			pass=[passField stringValue];
			
			[indicator startAnimation:nil];
			auth=[[self authWithLogin:login pass:pass]retain];
			[indicator stopAnimation:nil];
			
			if (auth){
				//NSLog(@"auth %@",auth);
				[[NSUserDefaults standardUserDefaults]setObject:login forKey:@"QSGoogleCalendarUser"];
				NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%@@calendar.google.com",QSURLEncode(login),QSURLEncode(pass)]];
																				  //NSLog(@"url %@ %@",url,[url user]);
				if ([pass length])
					[url addPasswordToKeychain];
				//NSLog(@"saving password %@",url);
			}
			
			
		}
		[loginPanel orderOut:nil];
		[loginPanel release];
		loginPanel=nil;
		
	}
	return auth;
}

- (NSDictionary *)processNaturalLanguage:(NSString *)string{
	NSURL *url=[NSURL URLWithString:
		[NSString stringWithFormat:@"http://www.google.com/calendar/compose?ctext=%@",[string URLEncoding]]];
	
	NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:url
															cachePolicy:NSURLRequestUseProtocolCachePolicy
														timeoutInterval:10.0];
	
	[theRequest setValue:@"Quicksilver (Blacktree,MacOSX)" forHTTPHeaderField:@"User-Agent"]; 
	NSError *error;
	NSData *data=[NSURLConnection sendSynchronousRequest:theRequest returningResponse:nil error:&error];
	
	NSString *result=[[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]autorelease];
	
	NSString *title=nil;
	NSDate *startDate=nil;
	NSDate *endDate=nil;
	NSMutableDictionary *dict=[NSMutableDictionary dictionary];
	//result=nil;
	if ([result hasPrefix:@"["]) {
		if (VERBOSE) NSLog(@"Parse result %@",result);
		
		result=[result stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"[]"]];
		
		NSArray *resultComponents=[result componentsSeparatedByString:@","];
		if ([resultComponents count]<6)return nil;
		
#warning this will mess up with commas and quotes!
		
		NSCharacterSet *quoteSet=[NSCharacterSet characterSetWithCharactersInString:@"'"];
		
		title=[[resultComponents objectAtIndex:1]stringByTrimmingCharactersInSet:quoteSet];
		
		NSString *startString=[[resultComponents objectAtIndex:4]stringByTrimmingCharactersInSet:quoteSet];
		NSString *endString=[[resultComponents objectAtIndex:5]stringByTrimmingCharactersInSet:quoteSet];
		
		
		if (![startString hasPrefix:@"?"]){
			if ([startString rangeOfString:@"?"].location!=NSNotFound){
				startDate=[NSCalendarDate dateWithString:startString calendarFormat:@"%Y%m%dT"];
				
				[dict setObject:[NSNumber numberWithBool:YES] forKey:@"startDateIsDay"];
			}else{
				startDate=[NSCalendarDate dateWithString:startString calendarFormat:@"%Y%m%dT%H%M%S"];
			}
		}
		if (!startDate)startDate=[NSCalendarDate date];
		
		if (![endString hasPrefix:@"?"]){
			if ([endString rangeOfString:@"?"].location!=NSNotFound){
				endDate=[NSCalendarDate dateWithString:endString calendarFormat:@"%Y%m%dT"];
				[dict setObject:[NSNumber numberWithBool:YES] forKey:@"endDateIsDay"];
			}else{
				endDate=[NSCalendarDate dateWithString:endString calendarFormat:@"%Y%m%dT%H%M%S"];
			}
		}
		
	}else{
		NSDate *date=[NSCalendarDate dateWithNaturalLanguageString:string];
		if(![[date timeZone]isEqualToTimeZone:[NSTimeZone localTimeZone]])
			date=[date addTimeInterval:-[[NSTimeZone localTimeZone]secondsFromGMTForDate:date]];
		if (!date) date=[NSDate date];
		
		startDate=date;
		//NSLog(@"falling back on NSDate parser %@",date);
	}
	if (!title) title=string;
	if (title)[dict setObject:title forKey:@"title"];
	if (startDate)[dict setObject:startDate forKey:@"startDate"];
	if (endDate)[dict setObject:endDate forKey:@"endDate"];
	
	
	//[['_SpawnQuickAddEvent','eat at','','','20060501T170000','20060501T200000',[],'',null,[],[]]]
	
	return dict;
	
}


-(void)postEvent:(NSData *)eventData withAuth:(NSString *)auth{
	NSString *url=@"http://www.google.com/calendar/feeds/default/private/full";
	
	NSMutableURLRequest *postRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
															 cachePolicy:NSURLRequestUseProtocolCachePolicy
														 timeoutInterval:30.0];
	
	[postRequest setHTTPMethod:@"POST"];
	[postRequest addValue:[NSString stringWithFormat:@"GoogleLogin auth=%@",auth]
	   forHTTPHeaderField: @"Authorization"];
	
	[postRequest setHTTPBody:eventData];
	[postRequest addValue:[NSString stringWithFormat:@"%d", [eventData length]] forHTTPHeaderField:@"Content-Length"];
	[postRequest addValue:@"application/atom+xml" forHTTPHeaderField: @"Content-Type"];
	
	
	NSURLResponse *resp = nil;
	NSError *err = nil;
	NSData *returnedData = [NSURLConnection sendSynchronousRequest: postRequest returningResponse: &resp error: &err];
	
	if (VERBOSE)NSLog(@"%@",[[NSString alloc]initWithData:returnedData encoding:NSUTF8StringEncoding],[postRequest allHTTPHeaderFields],err);
}
- (NSData *)eventDataForString:(NSString *)string{
	NSDictionary *dict=[self processNaturalLanguage:string];
	NSString *title=[dict objectForKey:@"title"];
	NSDate *startDate=[dict objectForKey:@"startDate"];
	NSDate *endDate=[dict objectForKey:@"endDate"];
	BOOL startDateIsDay=[dict objectForKey:@"startDateIsDay"];
	BOOL endDateIsDay=[dict objectForKey:@"endDateIsDay"];
	if (!startDate)return nil;
	
	if (!endDate && !startDateIsDay)
		endDate=[startDate dateByAddingYears:0 months:0 
										days:0 hours:1 minutes:0 seconds:0];
	NSString *startString=[startDate descriptionWithCalendarFormat:startDateIsDay?@"%Y-%m-%d":@"%Y-%m-%dT%H:%M:%SZ" 
														  timeZone:[NSTimeZone timeZoneWithName:@"GMT"] locale:nil];
	NSString *endString=[endDate descriptionWithCalendarFormat:endDateIsDay?@"%Y-%m-%d":@"%Y-%m-%dT%H:%M:%SZ" 
													  timeZone:[NSTimeZone timeZoneWithName:@"GMT"] locale:nil];
	
	//NSLog(@"Create Event %@",dict);
	//	NSLog(@"from \n%@ to %@\n",startString,endString);
	NSError *error=nil;
	NSXMLElement *entry = [NSXMLElement elementWithName:@"entry"];
	[entry addAttribute:[NSXMLNode attributeWithName:@"xmlns" stringValue:@"http://www.w3.org/2005/Atom"]];
	[entry addAttribute:[NSXMLNode attributeWithName:@"xmlns:gd" stringValue:@"http://schemas.google.com/g/2005"]];
	
	NSXMLElement *node;
	
	node=[NSXMLElement elementWithName:@"category"];
	[node addAttribute:[NSXMLNode attributeWithName:@"scheme" stringValue:@"http://schemas.google.com/g/2005#kind"]];
	[node addAttribute:[NSXMLNode attributeWithName:@"term" stringValue:@"http://schemas.google.com/g/2005#event"]];
	[entry addChild:node];
	
	if (title){
		node=[NSXMLElement elementWithName:@"title"];
		[node addAttribute:[NSXMLNode attributeWithName:@"type" stringValue:@"text"]];
		[node setStringValue:title];
		[entry addChild:node];
		//		node=[NSXMLElement elementWithName:@"content"];
		//		[node addAttribute:[NSXMLNode attributeWithName:@"type" stringValue:@"text"]];
		//		[node setStringValue:title];
		//		[entry addChild:node];
	}
	
	//	node=[NSXMLElement elementWithName:@"author"];
	//	[node addChild:[NSXMLElement elementWithName:@"name" stringValue:@"quicksilver"]];
	//	[node addChild:[NSXMLElement elementWithName:@"email" stringValue:@"quicksilver@blacktree.com"]];
	//	[entry addChild:node];
	
	//	node=[NSXMLElement elementWithName:@"gd:transparency"];
	//	[node addAttribute:[NSXMLNode attributeWithName:@"value" stringValue:@"http://schemas.google.com/g/2005#event.opaque"]];
	//	[entry addChild:node];
	//	node=[NSXMLElement elementWithName:@"gd:eventStatus"];
	//	[node addAttribute:[NSXMLNode attributeWithName:@"value" stringValue:@"http://schemas.google.com/g/2005#event.confirmed"]];
	//	[entry addChild:node];
	
	//	node=[NSXMLElement elementWithName:@"gd:where"];
	//	[node addAttribute:[NSXMLNode attributeWithName:@"valueString" stringValue:@""]];
	//	[entry addChild:node];
	
	
	
	if (startString){	
		node=[NSXMLElement elementWithName:@"gd:when"];
		[node addAttribute:[NSXMLNode attributeWithName:@"startTime" stringValue:startString]];
		if (endString)[node addAttribute:[NSXMLNode attributeWithName:@"endTime" stringValue:endString]];
		[entry addChild:node];
	}
	
	
	
	
	
	//	NSXMLDocument *xmlDoc = [[NSXMLDocument alloc] initWithRootElement:root];
	//	[xmlDoc setVersion:@"1.0"];
	//	[xmlDoc setCharacterEncoding:@"UTF-8"];
	NSString *entryText=[entry XMLStringWithOptions:NSXMLNodeUseSingleQuotes];
	if (VERBOSE) NSLog(@"entry \n%@\n\n",entryText);
	//entryText=@"<entry xmlns='http://www.w3.org/2005/Atom'    xmlns:gd='http://schemas.google.com/g/2005'>  <category scheme='http://schemas.google.com/g/2005#kind'    term='http://schemas.google.com/g/2005#event'></category>  <title type='text'>Tennis with Beth</title>  <content type='text'>Meet for a quick lesson.</content>  <author>    <name>Jo March</name>    <email>jo@gmail.com</email>  </author>  <gd:transparency    value='http://schemas.google.com/g/2005#event.opaque'>  </gd:transparency>  <gd:eventStatus    value='http://schemas.google.com/g/2005#event.confirmed'>  </gd:eventStatus>  <gd:where valueString='Rolling Lawn Courts'></gd:where>  <gd:when startTime='2006-04-17T15:00:00.000Z'    endTime='2006-04-17T17:00:00.000Z'></gd:when></entry>";
	return [entryText dataUsingEncoding:NSUTF8StringEncoding];
	
	//	NSData *xmlData = [xmlDoc XMLDataWithOptions:NSXMLNodePrettyPrint];
	//   	NSLog(@"data %@",[[[NSString alloc]initWithData:xmlData encoding:NSUTF8StringEncoding]autorelease]);
	
	//	<content type='text'>Meet for a quick lesson.</content>
	//		<author>
	//		<name>Jo March</name>
	//		<email>jo@gmail.com</email>
	//		</author>
	//		<gd:transparency
	//		value='http://schemas.google.com/g/2005#event.opaque'>
	//			</gd:transparency>
	//			<gd:eventStatus
	//			value='http://schemas.google.com/g/2005#event.confirmed'>
	//			</gd:eventStatus>
	//			<gd:where valueString='Rolling Lawn Courts'></gd:where>
	//			<gd:when startTime='2006-04-17T15:00:00.000Z'
	//			endTime='2006-04-17T17:00:00.000Z'></gd:when>
	//			</entry>	
	return nil;
}

-(QSObject *)createEvent:(QSObject *)dObject{
	[self createEvent:dObject inCalendar:nil];
}

-(QSObject *)createEvent:(QSObject *)dObject inCalendar:(QSObject *)iObject{
	//NSLog(@"objects %@ %@",dObject,iObject);	
	NSString *auth=[self loginToCalendar];
	if (!auth)return nil;
	NSData *eventData=[self eventDataForString:[dObject stringValue]];
	if (!eventData){
		NSBeep();
		return nil;
	}
	
	NSError *error;
	[self postEvent:eventData withAuth:auth];
	//	return data;
	
	
	//	POST http://www.google.com/calendar/feeds/default/private/full
	
	//	NSString *calendar=iObject?[iObject objectForType:@"QSICalCalendar"]:@"";
	//	NSString *dateString=[dObject stringValue];
	//	NSString *subjectString=dateString;
	//	NSArray *components=[dateString componentsSeparatedByString:@"--"];
	//	if ([components count]>1){
	//		dateString=[components objectAtIndex:0];
	//		subjectString=[[components objectAtIndex:1]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	//	}
	//	NSDate *date=[NSCalendarDate dateWithNaturalLanguageString:dateString];
	//	if(![[date timeZone]isEqualToTimeZone:[NSTimeZone localTimeZone]])
	//		date=[date addTimeInterval:-[[NSTimeZone localTimeZone]secondsFromGMTForDate:date]];
	//	if (!date) date=[NSDate date];
	//	
	//	NSArray *arguments=[NSArray arrayWithObjects:date,subjectString,calendar,nil];
	//	//-----
	//	NSDictionary *dict=nil;
	//	[[self script] executeSubroutine:@"create_event" arguments:arguments error:&dict];
	//	if (dict)NSLog(@"Create Error: %@",dict);
	QSShowNotifierWithAttributes(
								 [NSDictionary dictionaryWithObjectsAndKeys:
									 @"QSEventAdded",QSNotifierType,
									 @"Event added",QSNotifierTitle,
									 [dObject stringValue],QSNotifierText,
									 [NSImage imageNamed:@"NSApplicationIcon"],QSNotifierIcon,
									 nil]);
	
	return nil;
}
//
- (NSArray *)validIndirectObjectsForAction:(NSString *)action directObject:(QSObject *)dObject{
	NSFileManager *fm=[NSFileManager defaultManager];
	NSMutableArray *array=[NSMutableArray array];
	//	NSString *path=[@"~/Library/Application Support/iCal/Sources/" stringByStandardizingPath];
	//	NSEnumerator *e=[[fm directoryContentsAtPath:path]objectEnumerator];
	//	NSString *subPath;
	//	while(subPath=[e nextObject]){
	//		if (![[subPath pathExtension]isEqualToString:@"calendar"])continue;
	//		subPath=[path stringByAppendingPathComponent:subPath];
	//		NSDictionary *info=[NSDictionary dictionaryWithContentsOfFile:[subPath stringByAppendingPathComponent:@"Info.plist"]];
	//		NSString *name=[info objectForKey:@"Title"];
	//		QSObject *object=[QSObject fileObjectWithPath:[subPath stringByAppendingPathComponent:@"corestorage.ics"]];
	//		[object setName:name];
	//		[object setObject:name forType:@"QSICalCalendar"];
	//		[array addObject:object];
	//		
	//	}
	return array;
	
}

@end
