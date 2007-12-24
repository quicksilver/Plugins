//
//  AppController.m
//  DictProtocolTest
//
//  Created by Kevin Ballard on 11/2/04.
//  Copyright 2004 Kevin Ballard. All rights reserved.
//

#import "AppController.h"

@implementation AppController
- (id) init {
	if (self = [super init]) {
		urlString = @"";
		urlConnection = nil;
		urlData = nil;
	}
	return self;
}

- (void) dealloc {
	[urlString release];
	[urlConnection release];
	[urlData release];
	
	[super dealloc];
}


- (NSString *)urlString {
	return [[urlString retain] autorelease];
}

- (void) setUrlString:(NSString *)string {
	NSString *temp = [string copy];
	[urlString release];
	urlString = temp;
}

- (IBAction) query:(id)sender {
	[queryButton setTitle:@"Cancel"];
	[queryButton setKeyEquivalent:@"\e"];
	[queryButton setAction:@selector(stopQuery:)];
	//[progressIndicator startAnimation:self];
	
	NSURL *url = [NSURL URLWithString:urlString];
	if (!url) {
		NSBeep();
		[self stopQuery:self];
		[resultText setString:@"Error: Invalid URL"];
		return;
	}
	
	[urlData release];
	urlData = [[NSMutableData alloc] init];
	NSURLRequest *request = [NSURLRequest requestWithURL:url
											 cachePolicy:NSURLRequestReloadIgnoringCacheData
										 timeoutInterval:60];
	urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	if (!urlConnection) {
		NSBeep();
		[self stopQuery:self];
		[resultText setString:@"Error: Unsupported URL scheme"];
	}
}

- (IBAction) stopQuery:(id)sender {
	[urlConnection cancel];
	[urlConnection release];
	urlConnection = nil;
	
	[queryButton setTitle:@"Query"];
	[queryButton setKeyEquivalent:@"\r"];
	[queryButton setAction:@selector(query:)];
	//[progressIndicator stopAnimation:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	[resultText setString:[NSString stringWithFormat:@"Error: %@", [error localizedDescription]]];
	[self stopQuery:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[urlData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[self stopQuery:self];
	NSString *text = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
	[resultText setString:text];
	[text release];
}

-(NSCachedURLResponse *)connection:(NSURLConnection *)connection
				 willCacheResponse:(NSCachedURLResponse *)cachedResponse {
	// We don't want a cache
	return nil;
}
@end
