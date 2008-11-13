//
//  QSStikkitPlugIn_Source.m
//  QSStikkitPlugIn
//
//  Created by Nicholas Jitkoff on 9/18/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//

#import "QSStikkitPlugIn.h"
#import <QSCore/QSCore.h>

#import <QSEffects/QSShading.h>

#include <openssl/bio.h>
#include <openssl/evp.h>

#define QSURLEncode(s) [(NSString*)CFURLCreateStringByAddingPercentEscapes(NULL,s,NULL,@":@/=+&?", kCFStringEncodingUTF8) autorelease]

@interface NSData(Base64Encode)
- (NSString*) stikkitEncodeBase64;
@end

@implementation NSData(Base64Encode)
- (NSString*) stikkitEncodeBase64
{
  BIO* b64 = BIO_new(BIO_f_base64());
  BIO* io = BIO_push(b64, BIO_new(BIO_s_mem()));
  BIO_write(io, [self bytes], [self length]);
  BIO_flush(io);
  
  char* ptr;
  size_t len = BIO_get_mem_data(io, &ptr);
  NSString* result = [NSString stringWithCString: ptr
                                          length: len-1];
  BIO_free_all(io);
  
  return result;
}
@end



@implementation QSStikkitPlugIn
+ (void)initialize{
	[self setKeys:[NSArray arrayWithObject:@"selection"] triggerChangeNotificationsForDependentKey:@"currentPassword"];
}

- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry{
	return -[indexDate timeIntervalSinceNow] < 6*60*60;
}

- (BOOL)isVisibleSource{return YES;}

- (NSImage *) iconForEntry:(NSDictionary *)dict{
    return [[NSBundle bundleForClass:[self class]]imageNamed:@"stikkit"];
}

- (NSString *)identifierForObject:(id <QSObject>)object{
    return nil;
}

- (NSView *) settingsView{
    if (![super settingsView]){
        [NSBundle loadNibNamed:@"QSStikkitPlugInSource" owner:self];
    }
    return [super settingsView];
}

- (NSData *)cachedBookmarkDataForUser:(NSString *)username{
	NSString *cachePath=[QSApplicationSupportSubPath(@"Caches/stikkit/",NO) stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.xml",username]];
	return [NSData dataWithContentsOfFile:cachePath];
}
- (NSString *)passwordForUser:(NSString *)username{
  
	NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"http://%@@www.stikkit.com/",QSURLEncode(username)]];
  NSString *pass = [url keychainPassword];
  if (pass) return pass;
  url=[NSURL URLWithString:[NSString stringWithFormat:@"http://%@@stikkit.com/",QSURLEncode(username)]];
  pass = [url keychainPassword];
	return pass;	
}
- (NSData *)bookmarkDataForUser:(NSString *)username onSite:(int)isMagnolia{

	NSString *password=[self passwordForUser:username];
	//if (VERBOSE)
		
	//NSLog(@"Downloading Stikkits for %@ %d",username, isMagnolia);
	//NSString *count=[[self currentEntry] objectForKey:@"QSStikkitRecentCount"];
	
	if (!username || !password) {
    NSLog(@"Username or password incorrect");
    return nil;
  }
	//if (!count)count=@"50";

	
	NSString *apiurl=@"api.stikkit.com"; //isMagnolia?MAGNOLIA_API_URL:Stikkit_API_URL;
	
	NSXMLDocument *mainDocument = nil;
	NSXMLDocument *pageDocument = nil;
	
	
	
	NSData *data;
	int i;
	for (i = 1; i < 100 ; i++) {
		NSError *error;
		NSURL *url=[NSURL URLWithString:
			[NSString stringWithFormat:@"http://%@/stikkits.atom?page=%d", apiurl, i]];
		
		NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:url
																cachePolicy:NSURLRequestUseProtocolCachePolicy
															timeoutInterval:60.0];
//		[theRequest setValue:@"Quicksilver (Blacktree,MacOSX)" forHTTPHeaderField:@"User-Agent"]; 
//    
//    
    NSString* s;
    s = [NSString stringWithFormat: @"%@:%@", username, password];
    s = [NSString stringWithFormat: @"Basic %@", [[s dataUsingEncoding: NSASCIIStringEncoding] stikkitEncodeBase64]];
    [theRequest setValue: s forHTTPHeaderField: @"Authorization"];

  // NSString *tmp = [NSString stringWithFormat:@"%@:%@", username, password];
//    tmp = [[tmp dataUsingEncoding:NSASCIIStringEncoding] stikkitEncodeBase64];
//    
//    
//    tmp = [[[NSString alloc] initWithData:data 
//                              encoding:[NSString defaultCStringEncoding]] autorelease];
//    [theRequest addValue:[NSString stringWithFormat:@"Basic %@", tmp] forHTTPHeaderField:@"Authorization"];
//    //
     //NSLog(@"base %@", [NSString stringWithFormat:@"Basic %@", s]);
    //    
//    [theRequest setValue:[NSString stringWithFormat:@"basic %@:%@", QSURLEncode(username),password]
//      forHTTPHeaderField:@"Authorization"];

		NSHTTPURLResponse *response = nil;
		data = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&error];
		
		if ([response statusCode] != 200) break;
		pageDocument=[[[NSXMLDocument alloc] initWithData:data
															 options:0
															   error:nil] autorelease];
		if (!mainDocument) {
			mainDocument = pageDocument;
		} else {
			NSXMLElement *root = [mainDocument rootElement];
			NSArray *entries = [[pageDocument rootElement] elementsForName:@"entry"];
			[entries makeObjectsPerformSelector:@selector(detach)];
//			[root setChildren:nil];
			[root insertChildren:entries
						 atIndex:[[root children] count]];
		
				if ([entries count] < 25) break;
			//NSLog(@"fetching another");
		}
			
	}
	
	if (mainDocument != pageDocument) data = [mainDocument XMLData];
	
	NSString *cachePath=[QSApplicationSupportSubPath(@"Caches/Stikkit/",YES) stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.xml",username]];
	[data writeToFile:cachePath atomically:NO];	
	return data;
}
-(void)connection:(NSURLConnection *)connection 
didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge 
                                   *)challenge
{
  NSLog(@"Auth Request");
  if ([challenge previousFailureCount] == 0) {
    NSURLCredential *newCredential;
    newCredential=[NSURLCredential credentialWithUser:(NSString 
                                                       *)@"<email_removed>"
                                             password:(NSString 
                                                       *)@"yeyinde99"
                   
                                          persistence:NSURLCredentialPersistenceForSession];
    [[challenge sender] useCredential:newCredential
           forAuthenticationChallenge:challenge];
  } else {
    [[challenge sender] cancelAuthenticationChallenge:challenge];
    // inform the user that the user name and password
    // in the preferences are incorrect
    //[self showPreferencesCredentialsAreIncorrectPanel:self];
  }
}
- (QSObject *)objectForPost:(NSXMLElement *)post{
	
//	<entry>
//    <title>stikkit title</title>
//    <summary>contents of the stikkit</summary>
//    <content type="html">contents of the stikkit</content>
//    <id>http://api.stikkit.com/stikkits/155157</id>
//    <published>2007-02-02T04:06:41Z</published>
//    <updated>2007-02-02T04:24:22Z</updated>
//    <link href="http://api.stikkit.com/stikkits/[stikkit id]" rel="alternate" type="text/html"/>
//	</entry>
//	
//	
	
	NSString *link = [[[[post elementsForName:@"link"] lastObject] attributeForName:@"href"] stringValue];
	NSString *title = [[[post elementsForName:@"title"] lastObject] stringValue];
		NSString *ident = [[[post elementsForName:@"id"] lastObject] stringValue];
	NSString *summary = [[[post elementsForName:@"summary"] lastObject] stringValue];
	NSString *content = [[[post elementsForName:@"content"] lastObject] stringValue];
	
	QSObject *newObject=[QSObject makeObjectWithIdentifier:ident];
	[newObject setObject:link
				 forType:QSURLType];
	[newObject setName:title];
	[newObject setDetails:@""];
	[newObject setObject:summary forType:QSTextType];
	[newObject setObject:content forType:kQSStikkitHTMLType];
	[newObject setObject:ident forType:kQSStikkitStikkitType];
	[newObject setPrimaryType:kQSStikkitStikkitType];
	//NSDate *date=[NSCalendarDate dateWithString:[post objectForKey:@"time"] 
	//							 calendarFormat:@"%Y-%m-%dT%H:%M:%SZ"];
	//[date setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	//[newObject setObject:date forMeta:kQSObjectCreationDate];
	return newObject;
}

- (NSArray *) objectsForEntry:(NSDictionary *)theEntry{
	NSString *username=[theEntry objectForKey:@"username"];
	[[NSUserDefaults standardUserDefaults] setObject:username forKey:@"QSStikkitUsername"];
	
	
	NSData *data = nil;//[self cachedBookmarkDataForUser:username];
	if (![data length]) data=[self bookmarkDataForUser:username onSite:[[theEntry objectForKey:@"site"]intValue]];
	
	NSString *string=[[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]autorelease];

	NSXMLDocument *document=[[[NSXMLDocument alloc] initWithData:data
														options:0
														  error:nil] autorelease];
	
	NSArray *posts = [[document rootElement] elementsForName:@"entry"];

    NSMutableArray *objects=[NSMutableArray arrayWithCapacity:1];
    QSObject *newObject;
	NSEnumerator *e=[posts objectEnumerator];
	NSXMLElement *post;
	NSMutableSet *tagSet=[NSMutableSet set];
	while(post=[e nextObject]){
		newObject=[self objectForPost:post];
		
		NSArray *tags = [[[post elementsForName:@"category"]
			arrayByPerformingSelector:@selector(attributeForName:) withObject:@"term"] 
			valueForKey:@"stringValue"];
		[tagSet addObjectsFromArray:tags];
		[objects addObject:newObject];
	}
	NSString *tag;
	e=[tagSet objectEnumerator];
	if ([[theEntry objectForKey:@"includeTags"]boolValue]){
		while(tag=[e nextObject]){
			NSString *tagURLString = [NSString stringWithFormat:@"http://www.stikkit.com/stikkits?query=&commit=search&tags=%@&dates=&done=",QSURLEncode(tag)];
			newObject=[QSObject makeObjectWithIdentifier:[NSString stringWithFormat:@"[stikkit tag]:%@",tag]];
			[newObject setObject:tag forType:kQSStikkitTagType];
			[newObject setObject:tagURLString forType:QSURLType];
			[newObject setObject:username forMeta:@"com.stikkit.username"];
			[newObject setName:tag];
			[newObject setPrimaryType:kQSStikkitTagType];
			[newObject setDetails:@"Stikkit tag"];
			[objects addObject:newObject];
		}
	}
	
    return objects;
    
}

- (NSArray *)objectsForTag:(NSString *)tag username:(NSString *)username{
	NSData *data=[self cachedBookmarkDataForUser:username];
	
	NSXMLDocument *document=[[[NSXMLDocument alloc] initWithData:data
														 options:0
														   error:nil] autorelease];
	NSArray *posts = [[document rootElement] nodesForXPath:[NSString stringWithFormat:@".//entry[category/@term=\"%@\"]", tag]
									error:nil];	
	return [self performSelector:@selector(objectForPost:) onObjectsInArray:posts];

}

// XML Stuff
//- (void)parser:(NSXMLParser*)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
//	//	NSLog(@"started %@ %@ %@ %@",elementName,namespaceURI,qName,attributeDict);
//	
//	if ([elementName isEqualToString:@"post"] && attributeDict)
//		[posts addObject:attributeDict];
//}
//
//- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
//	//	NSLog(@"ended %@ %@ %@ %@",elementName,namespaceURI,qName);
//}
//






// Object Handler Methods

/*
 - (void)setQuickIconForObject:(QSObject *)object{
	 [object setIcon:nil]; // An icon that is either already in memory or easy to load
 }
 - (BOOL)loadIconForObject:(QSObject *)object{
	 return NO;
	 id data=[object objectForType:QSStikkitPlugInType];
	 [object setIcon:nil];
	 return YES;
 }
 */





- (NSString *) mainNibName{
	return @"QSStikkitPrefPane";
}

- (void)populateFields{
}
- (NSString *)currentPassword{
	NSString *account=[[self currentEntry] objectForKey:@"username"];
	if (!account)return nil;
	NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"http://%@@www.stikkit.com/",QSURLEncode(account)]];
	NSString *password=[url keychainPassword];
	return password;
}
- (void)setCurrentPassword:(NSString *)newPassword{
	NSString *account=[[self currentEntry] objectForKey:@"username"];
	NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%@@www.stikkit.com/",QSURLEncode(account),newPassword]];
	if ([newPassword length])
		[url addPasswordToKeychain];
	[self updateCurrentEntryModificationDate];
	
	[self invalidateSelf];
}









- (void)setQuickIconForObject:(QSObject *)object{
	[object setIcon:[[NSBundle bundleForClass:[self class]]imageNamed:@"stikkit"]];
}

- (BOOL)drawIconForObject:(QSObject *)object inRect:(NSRect)rect flipped:(BOOL)flipped{ 
	if ([[object primaryType] isEqualToString:kQSStikkitStikkitType]) {
		//NSData *html = [[object objectForType:kQSStikkitHTMLType] dataUsingEncoding:NSUTF8StringEncoding];
		
		NSDictionary *documentAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
			[NSFont systemFontOfSize:10.0],
			NSFontAttributeName,
			nil];
			
			
		//NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithHTML:html
//														   documentAttributes:nil];
//		
		[NSGraphicsContext saveGraphicsState];
		[[NSBezierPath bezierPathWithRect:rect] addClip];
		NSColor *topColor = [NSColor colorWithCalibratedHue:61.0/360.0
												 saturation:0.33
												 brightness:0.99
													  alpha:1.00];
		
		NSColor *bottomColor = [NSColor colorWithCalibratedHue:49.0/360.0
													saturation:0.63
													brightness:0.98
														 alpha:1.00];
		
		QSFillRectWithGradientFromEdge(rect, topColor, bottomColor, NSMaxYEdge);
		
		//NSBezierPath *QSGlossClipPathForRectAndStyle(NSRect rect,QSGlossStyle style);
		
		
		
//		NSRectFill(rect);
		
		[(NSString *)[object objectForType:QSTextType] drawInRect:NSInsetRect(rect, 7, 7)
											  withAttributes:documentAttributes];
			[NSGraphicsContext restoreGraphicsState];
			[topColor set];
			
			NSFrameRect(rect);
		return YES;	
	}
	//NSLog(@"draw?");

	return NO;
	
}
- (BOOL)loadChildrenForObject:(QSObject *)object{
	
	if ([object containsType:kQSStikkitTagType]) {
		[object setChildren:
			[self objectsForTag:[object objectForType:kQSStikkitTagType] 
					   username:[object objectForMeta:@"com.stikkit.username"]]];
		return YES;
	} else {
		return [[QSReg getClassInstance:@"QSStringObjectHandler"] loadChildrenForObject:object];
	}
}





@end
