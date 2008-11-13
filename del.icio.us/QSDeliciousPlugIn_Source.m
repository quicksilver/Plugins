//
//  QSDeliciousPlugIn_Source.m
//  QSDeliciousPlugIn
//
//  Created by Nicholas Jitkoff on 9/18/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//

#import "QSDeliciousPlugIn_Source.h"
#import <QSCore/QSCore.h>

#define DELICIOUS_API_URL @"api.del.icio.us/v1"
#define MAGNOLIA_API_URL @"ma.gnolia.com/api/mirrord/v1"

@implementation QSDeliciousPlugIn_Source
+ (void)initialize{
	[self setKeys:[NSArray arrayWithObject:@"selection"] triggerChangeNotificationsForDependentKey:@"currentPassword"];
}
- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry{
	return -[indexDate timeIntervalSinceNow] < 24*60*60;
}

- (BOOL)isVisibleSource{return YES;}

- (NSImage *) iconForEntry:(NSDictionary *)dict{
    return [[NSBundle bundleForClass:[self class]]imageNamed:@"bookmark_icon"];
}

- (NSString *)identifierForObject:(id <QSObject>)object{
    return nil;
}

- (NSView *) settingsView{
    if (![super settingsView]){
        [NSBundle loadNibNamed:@"QSDeliciousPlugInSource" owner:self];
    }
    return [super settingsView];
}

- (NSData *)cachedBookmarkDataForUser:(NSString *)username{
	NSString *cachePath=[QSApplicationSupportSubPath(@"Caches/del.icio.us/",NO) stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.xml",username]];
	return [NSData dataWithContentsOfFile:cachePath];
}
- (NSString *)passwordForUser:(NSString *)username{
	NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"http://%@@del.icio.us/",username]];
	return [url keychainPassword];	
}
- (NSData *)bookmarkDataForUser:(NSString *)username onSite:(int)isMagnolia{

	NSString *password=[self passwordForUser:username];
	if (VERBOSE)NSLog(@"Downloading del.icio.us bookmarks for %@ %d",username, isMagnolia);
	//NSString *count=[[self currentEntry] objectForKey:@"QSDeliciousRecentCount"];
	
	if (!username || !password) return nil;
	//if (!count)count=@"50";

		
	NSString *apiurl=isMagnolia?MAGNOLIA_API_URL:DELICIOUS_API_URL;
	
	NSError *error;
	NSURL *url=[NSURL URLWithString:
		[NSString stringWithFormat:@"https://%@:%@@%@/posts/all?",username,password,apiurl]];
	
	NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:url
															cachePolicy:NSURLRequestUseProtocolCachePolicy
														timeoutInterval:60.0];
	
	[theRequest setValue:@"Quicksilver (Blacktree,MacOSX)" forHTTPHeaderField:@"User-Agent"]; 
	
	
	//	NSURLConnection *theConnection=[[[NSURLConnection alloc] initWithRequest:theRequest delegate:nil];
	
	//NSLog(@"url %@",url);
	NSData *data=[NSURLConnection sendSynchronousRequest:theRequest returningResponse:nil error:&error];
	NSString *cachePath=[QSApplicationSupportSubPath(@"Caches/del.icio.us/",YES) stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.xml",username]];
	[data writeToFile:cachePath atomically:NO];	
	return data;
}
- (QSObject *)objectForPost:(NSDictionary *)post{
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

- (NSArray *) objectsForEntry:(NSDictionary *)theEntry{
	NSString *username=[theEntry objectForKey:@"username"];
	NSData *data=nil;//[self cachedBookmarkDataForUser:username];
		if (![data length]) data=[self bookmarkDataForUser:username onSite:[[theEntry objectForKey:@"site"]intValue]];
	
	//NSString *string=[[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]autorelease];
	//NSLog(@"data %@",string);
	
	NSXMLParser *postParser=[[NSXMLParser alloc]initWithData:data];
	
	[postParser setDelegate:self];
	posts=[NSMutableArray arrayWithCapacity:1];
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
			[newObject setObject:tag forType:kQSDeliciousTagType];
			[newObject setObject:username forMeta:@"us.icio.del.username"];
			[newObject setName:tag];
			[newObject setPrimaryType:kQSDeliciousTagType];
			[objects addObject:newObject];
		}
	}
	[postParser release];
	
    return objects;
    
}

- (NSArray *)objectsForTag:(NSString *)tag username:(NSString *)username{
	NSData *data=[self cachedBookmarkDataForUser:username];
	
	NSXMLParser *postParser=[[NSXMLParser alloc]initWithData:data];
	[postParser setDelegate:self];
	posts=[NSMutableArray arrayWithCapacity:1];
	[postParser parse];
	
    NSMutableArray *objects=[NSMutableArray arrayWithCapacity:1];
    QSObject *newObject;
	NSEnumerator *e=[posts objectEnumerator];
	NSDictionary *post;
	NSMutableSet *tagSet=[NSMutableSet set];
	while(post=[e nextObject]){
		if ([[post objectForKey:@"tag"]rangeOfString:tag].location==NSNotFound)continue;
		newObject=[self objectForPost:post];
		[objects addObject:newObject];
	}
	return objects;
}

// XML Stuff
- (void)parser:(NSXMLParser*)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	//	NSLog(@"started %@ %@ %@ %@",elementName,namespaceURI,qName,attributeDict);
	
	if ([elementName isEqualToString:@"post"] && attributeDict)
		[posts addObject:attributeDict];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	//	NSLog(@"ended %@ %@ %@ %@",elementName,namespaceURI,qName);
}







// Object Handler Methods

/*
 - (void)setQuickIconForObject:(QSObject *)object{
	 [object setIcon:nil]; // An icon that is either already in memory or easy to load
 }
 - (BOOL)loadIconForObject:(QSObject *)object{
	 return NO;
	 id data=[object objectForType:QSDeliciousPlugInType];
	 [object setIcon:nil];
	 return YES;
 }
 */





- (NSString *) mainNibName{
	return @"QSDeliciousPrefPane";
}

- (void)populateFields{
}
- (NSString *)currentPassword{
	NSString *account=[[self currentEntry] objectForKey:@"username"];
	if (!account)return nil;
	NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"http://%@@del.icio.us/",account]];
	NSString *password=[url keychainPassword];
	return password;
}
- (void)setCurrentPassword:(NSString *)newPassword{
	NSString *account=[[self currentEntry] objectForKey:@"username"];
	NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%@@del.icio.us/",account,newPassword]];
	if ([newPassword length])
		[url addPasswordToKeychain];
	
}









- (void)setQuickIconForObject:(QSObject *)object{
	[object setIcon:[[NSBundle bundleForClass:[self class]]imageNamed:@"bookmark_icon"]];
}
- (BOOL)loadChildrenForObject:(QSObject *)object{
	[object setChildren:
		[self objectsForTag:[object objectForType:kQSDeliciousTagType] 
				   username:[object objectForMeta:@"us.icio.del.username"]]];
	return YES;
}





@end
