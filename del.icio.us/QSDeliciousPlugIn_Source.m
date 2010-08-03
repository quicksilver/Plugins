//
//  QSDeliciousPlugIn_Source.m
//  QSDeliciousPlugIn
//
//  Created by Nicholas Jitkoff on 9/18/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//

#import "QSDeliciousPlugIn_Source.h"
#import <QSCore/QSCore.h>

#import <Security/Security.h>

@implementation QSDeliciousPlugIn_Source

+ (void)initialize {
	[self setKeys:[NSArray arrayWithObject:@"selection"] triggerChangeNotificationsForDependentKey:@"currentPassword"];
}

- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry {
	return -[indexDate timeIntervalSinceNow] < 24 * 60 * 60;
}

- (BOOL)isVisibleSource{ return YES; }

- (NSImage *) iconForEntry:(NSDictionary *)dict {
    return [[NSBundle bundleForClass:[self class]]imageNamed:@"bookmark_icon"];
}

- (NSString *) mainNibName {
	return @"QSDeliciousPrefPane";
}

- (void)populateFields {
	NSLog(@"populating: %@/%@", [[selection info] objectForKey:@"username"], [[selection info] objectForKey:@"site"]);
}

- (NSView *) settingsView {
    if (![super settingsView])
        [NSBundle loadNibNamed:@"QSDeliciousPlugInSource" owner:self];
    return [super settingsView];
}

// Keychain Access -- The QS Built-in ones seems to be broken

- (SecProtocolType)protocolTypeForString:(NSString *)protocol {
	if ([protocol isEqualToString:@"ftp"]) return kSecProtocolTypeFTP;
	else if ([protocol isEqualToString:@"http"]) return kSecProtocolTypeHTTP;
	else if ([protocol isEqualToString:@"sftp"]) return kSecProtocolTypeFTPS;
	else if ([protocol isEqualToString:@"eppc"]) return kSecProtocolTypeEPPC;
	else if ([protocol isEqualToString:@"afp"]) return kSecProtocolTypeAFP;
	else if ([protocol isEqualToString:@"smb"]) return kSecProtocolTypeSMB;
	else if ([protocol isEqualToString:@"ssh"]) return kSecProtocolTypeSSH;
	else if ([protocol isEqualToString:@"telnet"]) return kSecProtocolTypeTelnet;	
	return 0;
}

- (NSString *)passwordForHost:(NSString *)host user:(NSString *)user andType:(SecProtocolType)type {
	const char 		*buffer;
	UInt32 			length = 0;
	OSErr			err;
	
	err = SecKeychainFindInternetPassword(NULL,
										  [host length], [host UTF8String],
										  0,
										  NULL,
										  [user length], [user UTF8String],
										  0, NULL,
										  0,
										  type,
										  0,
										  &length, (void**)&buffer,
										  NULL);
	
	if (err == noErr) {
		NSString *password = [[[NSString alloc] initWithCString:buffer length:length] autorelease];
		SecKeychainItemFreeContent(NULL,(void *)buffer);
		return password;
	}
	return nil;
}

- (NSString *)passwordForHost:(NSString *)host user:(NSString *)user andScheme:(NSString *)scheme {
	NSString *password = nil;
	
	SecProtocolType type = [self protocolTypeForString:scheme];
	
	password = [self passwordForHost:host user:user andType:type];
	
	if (!password && type == kSecProtocolTypeFTP)
		password = [self passwordForHost:host user:user andType:kSecProtocolTypeFTPAccount]; // Workaround for Transmit's old type usage
	if ( !password )
		password = [self passwordForHost:host user:user andType:0];
	if ( !password )
		NSLog(@"Couldn't find password. URL:%@ %@ %@", host, user,scheme );
	return password;
}

- (NSString *)keychainPasswordForURL:(NSURL *)url {
	return [self passwordForHost:[url host] user:[url user] andScheme:[url scheme]];
}

- (OSErr)addURLPasswordToKeychain:(NSURL *)url {
	OSErr			err;
	
	NSString *host = [url host];
	NSString *user = [url user];
	NSString *pass = [url password];
	
	SecProtocolType type = [self protocolTypeForString:[url scheme]];
	
	SecKeychainItemRef existing = NULL;
	
	err = SecKeychainFindInternetPassword(NULL,
										  [host length], [host UTF8String],
										  0, NULL,
										  [user length], [user UTF8String],
										  0, NULL,
										  0,
										  type,
										  0,
										  NULL,NULL,
										  &existing);
	
	if ( !err ) {
		err = SecKeychainItemModifyContent( existing, NULL, [pass length], [pass UTF8String] );
		CFRelease( existing );
	} else {
		err = SecKeychainAddInternetPassword(NULL,
                                             [host length], [host UTF8String],
                                             0, NULL,
                                             [user length], [user UTF8String],
                                             0, NULL,
                                             0,
                                             type,
                                             0,
                                             [pass length], [pass UTF8String],
                                             NULL);
    }
	
	return err;
}

// Site Index/API/URL

- (int)siteIndex {
	return [[selection info] objectForKey:@"site"] != nil ? [[[selection info] objectForKey:@"site"] integerValue] : 0;
}

- (NSString *)siteURLForIndex:(int)siteIndex {
	if (siteIndex == 0) return @"del.icio.us";
	else if (siteIndex == 1) return @"ma.gnolia.com";
	else if (siteIndex == 2) return @"pinboard.in";
	else return nil;
}

- (NSString *)reversedSiteURLForIndex:(int)siteIndex {
	if (siteIndex == 0) return @"us.icio.del";
	else if (siteIndex == 1) return @"com.gnolia.ma";
	else if (siteIndex == 2) return @"in.pinboard";
	else return nil;
}

- (NSString *)tagURLForIndex:(int)siteIndex {
	return [NSString stringWithFormat:@"%2.%2", [self reversedSiteURLForIndex:[self siteIndex]], @"tag"];
}

- (NSString *)apiURLForIndex:(int)siteIndex {
	if (siteIndex == 0) return @"api.del.icio.us/v1";
	else if (siteIndex == 1) return @"ma.gnolia.com/api/mirrord/v1";
	else if (siteIndex == 2) return @"api.pinboard.in/v1";
	else return nil;
}

// Current Site/API URL

- (NSString *)currentSiteURL {
	return [self siteURLForIndex:[self siteIndex]];
}

- (NSString *)currentAPIURL {
	return [self apiURLForIndex:[self siteIndex]];
}

// Useranme

- (NSString *)currentUsername {
	return [[selection info] objectForKey:@"username"];
}

// Password Related

- (NSString *)currentPassword {
	NSString *account = [self currentUsername];
	if (!account) return nil;
	
	NSURL *keychainURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@@%@/", account, [self currentSiteURL]]];
	NSString *password = [self keychainPasswordForURL:keychainURL];
	
	return password;
}

- (void)setCurrentPassword:(NSString *)newPassword {
	NSString *account = [self currentUsername];
	if (!account) return;
	if ([newPassword length] <= 0) return;
	
	NSURL *keychainURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%@@%@/", account, newPassword, [self currentSiteURL]]];
	
	[self addURLPasswordToKeychain:keychainURL];
}

// Bookarmk/Caching

- (NSData *)cachedBookmarkData {
	NSString *cachePath=[QSApplicationSupportSubPath([NSString stringWithFormat:@"Caches/%@/", [self currentSiteURL]], NO) stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.xml", [self currentUsername]]];
	return [NSData dataWithContentsOfFile:cachePath];
}

- (NSData *)bookmarkData {
	if (![self currentUsername] || ![self currentPassword]) return nil;
	
	NSString *urlString = [NSString stringWithFormat:@"https://%@:%@@%@/posts/all?", [self currentUsername], [self currentPassword], [self currentAPIURL]];
	NSURL *requestURL = [NSURL URLWithString:urlString];
	
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:requestURL
															  cachePolicy:NSURLRequestUseProtocolCachePolicy
														  timeoutInterval:60.0];
	[theRequest setHTTPMethod:@"POST"];
	[theRequest setValue:@"text/xml" forHTTPHeaderField:@"Content-type"];
	[theRequest setValue:@"Quicksilver (Blacktree,MacOSX)" forHTTPHeaderField:@"User-Agent"]; 
	
	NSError *error;
	NSData *data = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:nil error:&error];
	
	NSString *cachePath = [QSApplicationSupportSubPath([NSString stringWithFormat:@"Caches/%@/", [self currentSiteURL]], YES) stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.xml", [self currentUsername]]];
	[data writeToFile:cachePath atomically:NO];	
	
	return data;
}

- (QSObject *)objectForPost:(NSDictionary *)post {
	QSObject *newObject=[QSObject makeObjectWithIdentifier:[post objectForKey:@"hash"]];
	[newObject setObject:[post objectForKey:@"href"] forType:QSURLType];
	[newObject setName:[post objectForKey:@"description"]];
	[newObject setDetails:[post objectForKey:@"extended"]];
	[newObject setPrimaryType:QSURLType];
	//NSDate *date=[NSCalendarDate dateWithString:[post objectForKey:@"time"] 
	//							 calendarFormat:@"%Y-%m-%dT%H:%M:%SZ"];
	//[date setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	//[newObject setObject:date forMeta:kQSObjectCreationDate];
	return newObject;
}

- (NSArray *)objectsForEntry:(NSDictionary *)theEntry {
	NSData *data = nil;//[self cachedBookmarkData];
		if (![data length]) data = [self bookmarkData];
	
	NSXMLParser *postParser = [[NSXMLParser alloc]initWithData:data];
	[postParser setDelegate:self];
	
	posts = [NSMutableArray arrayWithCapacity:1];
	
	[postParser parse];
	
    NSMutableArray *objects=[NSMutableArray arrayWithCapacity:1];
    QSObject *newObject;
	NSEnumerator *e=[posts objectEnumerator];
	NSDictionary *post;
	NSMutableSet *tagSet=[NSMutableSet set];
	while(post=[e nextObject]){
		newObject=[self objectForPost:post];
		[tagSet addObjectsFromArray:[[post objectForKey:@"tag"]componentsSeparatedByString:@" "]];
		[objects addObject:newObject];
	}
	NSString *tag;
	e=[tagSet objectEnumerator];
	
	if ([[theEntry objectForKey:@"includeTags"]boolValue]){
		while(tag=[e nextObject]){
			newObject=[QSObject makeObjectWithIdentifier:[NSString stringWithFormat:@"[del.icio.us tag]:%@",tag]];
			[newObject setObject:tag forType:[self tagURLForIndex:[self siteIndex]]];
			[newObject setObject:[self currentUsername] forMeta:@"us.icio.del.username"];
			[newObject setName:tag];
			[newObject setPrimaryType:[self tagURLForIndex:[self siteIndex]]];
			[objects addObject:newObject];
		}
	}
	[postParser release];
	
    return objects;
    
}

- (NSArray *)objectsForTag:(NSString *)tag username:(NSString *)username{
	NSData *data=[self cachedBookmarkData];
	
	NSXMLParser *postParser=[[NSXMLParser alloc]initWithData:data];
	[postParser setDelegate:self];
	posts=[NSMutableArray arrayWithCapacity:1];
	[postParser parse];
	
    NSMutableArray *objects=[NSMutableArray arrayWithCapacity:1];
    QSObject *newObject;
	NSEnumerator *e=[posts objectEnumerator];
	NSDictionary *post;
	// NSMutableSet *tagSet=[NSMutableSet set];
	while(post=[e nextObject]){
		if ([[post objectForKey:@"tag"]rangeOfString:tag].location==NSNotFound)continue;
		newObject=[self objectForPost:post];
		[objects addObject:newObject];
	}
	return objects;
}

// Object Handler Methods

/*
- (void)setQuickIconForObject:(QSObject *)object {
	[object setIcon:nil]; // An icon that is either already in memory or easy to load
}

- (BOOL)loadIconForObject:(QSObject *)object {
	return NO;
	id data=[object objectForType:QSDeliciousPlugInType];
	[object setIcon:nil];
	return YES;
}
*/

- (void)setQuickIconForObject:(QSObject *)object {
	[object setIcon:[[NSBundle bundleForClass:[self class]]imageNamed:@"bookmark_icon"]];
}

- (BOOL)loadChildrenForObject:(QSObject *)object {
	[object setChildren:[self objectsForTag:[object objectForType:[self tagURLForIndex:[self siteIndex]]]
								   username:[object objectForMeta:@"us.icio.del.username"]]];
	return YES;
}

// NSXMLParserDelegate Functions

- (void)parser:(NSXMLParser*)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	NSLog(@"XML Parser started %@ %@ %@ %@",elementName,namespaceURI,qName,attributeDict);
	if ([elementName isEqualToString:@"post"] && attributeDict)
		[posts addObject:attributeDict];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	NSLog(@"XML Parser ended %@ %@ %@", elementName, namespaceURI, qName);
}

@end
