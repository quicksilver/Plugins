//
//  NSDICTURLProtocol.m
//  DictProtocolTest
//
//  Created by Kevin Ballard on 11/2/04.
//  Copyright 2004 Kevin Ballard. All rights reserved.
//

#import "NSDICTURLProtocol.h"
#import <netinet/in.h>
#import <arpa/inet.h>
#import <sys/types.h>
#import <sys/socket.h>
#import <netdb.h>
#import <unistd.h>

static void _socketCallback(CFSocketRef s, CFSocketCallBackType callbackType, CFDataRef address, 
							const void *data, void *info);

#pragma mark -

@interface NSDICTURLProtocol (private)
+ (NSArray *) queryFieldsForURL:(NSURL *)url;
//- (void) _socketTimedOut:(NSTimer *)inTimer;
- (BOOL) _receivedResponse;
- (void) _setReceivedResponse:(BOOL)flag;
- (NSArray *) _args;
@end

#pragma mark -

@implementation NSDICTURLProtocol
+ (void) load {
	[NSURLProtocol registerClass:[self class]];
}

+ (BOOL) canInitWithRequest:(NSURLRequest *)request {
	return ([[[request URL] scheme] isEqualToString:@"dict"]);
}

+ (NSURLRequest *) canonicalRequestForRequest:(NSURLRequest *)request {
	// Lets fill in default values for the parameters
	// To get the entire request string we need to scan past everything else
	NSURL *url = [[request URL] standardizedURL];
	NSMutableArray *fields = [[self queryFieldsForURL:url] mutableCopy];
	NSMutableString *result = [NSMutableString stringWithFormat:@"%@://", [url scheme]];
	if ([[url user] length])
		[result appendString:[url user]];
	if ([[url password] length])
		[result appendFormat:@":%@", [url password]];
	if ([[url user] length] || [[url password] length])
		[result appendString:@"@"];
	[result appendString:[url host]];
	if ([url port])
		[result appendFormat:@":%@", [url port]];
	else
		[result appendString:@":2628"];
	if (fields) {
		[result appendString:@"/"];
		if ([[fields objectAtIndex:0] isEqualToString:@"d"]) {
			while ([fields count] < 3)
				[fields addObject:@""];
			if ([(NSString *)[fields objectAtIndex:2] length] == 0)
				[fields replaceObjectAtIndex:2 withObject:@"!"];
		} else if ([[fields objectAtIndex:0] isEqualToString:@"m"]) {
			while ([fields count] < 4)
				[fields addObject:@""];
			if ([(NSString *)[fields objectAtIndex:2] length] == 0)
				[fields replaceObjectAtIndex:2 withObject:@"!"];
			if ([(NSString *)[fields objectAtIndex:3] length] == 0)
				[fields replaceObjectAtIndex:3 withObject:@"."];
		}
		[result appendString:[fields componentsJoinedByString:@":"]];
	}
	NSMutableURLRequest *mutableRequest = [request mutableCopy];
	[mutableRequest setURL:[NSURL URLWithString:result]];
	return mutableRequest;
}

- (id) initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse
				client:(id <NSURLProtocolClient>)client {
	if (self = [super initWithRequest:request cachedResponse:cachedResponse client:client]) {
		socketRef = NULL;
		timeoutTimer = nil;
		responseIndex = nil;
		NSMutableArray *fields = [[NSDICTURLProtocol queryFieldsForURL:[request URL]] mutableCopy];
		if (!fields || !([[fields objectAtIndex:0] isEqualToString:@"d"] ||
						 [[fields objectAtIndex:0] isEqualToString:@"m"])) {
			NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadURL
											 userInfo:nil];
			[client URLProtocol:self didFailWithError:error];
		} else {
			if ([[fields objectAtIndex:0] isEqualToString:@"m"]) {
				action = @"MATCH";
				while ([fields count] < 4)
					[fields addObject:@""];
				if (![(NSString *)[fields objectAtIndex:2] length])
					[fields replaceObjectAtIndex:2 withObject:@"!"];
				if (![(NSString *)[fields objectAtIndex:3] length])
					[fields replaceObjectAtIndex:3 withObject:@"."];
				args = [[NSArray alloc] initWithObjects:[fields objectAtIndex:2],
					[fields objectAtIndex:3], [fields objectAtIndex:1], nil];
				if ([fields count] >= 5)
					responseIndex = [[NSNumber alloc] initWithInt:[[fields objectAtIndex:5] intValue]];
			} else {
				action = @"DEFINE";
				while ([fields count] < 3)
					[fields addObject:@""];
				if (![(NSString *)[fields objectAtIndex:2] length])
					[fields replaceObjectAtIndex:2 withObject:@"!"];
				args = [[NSArray alloc] initWithObjects:[fields objectAtIndex:2],
					[fields objectAtIndex:1], nil];
				if ([fields count] >= 4)
					responseIndex = [[NSNumber alloc] initWithInt:[[fields objectAtIndex:4] intValue]];
			}
		}
	}
	return self;
}

- (void) dealloc {
	if (socketRef)
		CFRelease(socketRef);
	if (socketRunLoopSource) {
		if (CFRunLoopSourceIsValid(socketRunLoopSource))
			CFRunLoopSourceInvalidate(socketRunLoopSource);
		CFRelease(socketRunLoopSource);
	}
	[timeoutTimer release];
	
	[super dealloc];
}

- (void) startLoading {
	NSURL *url = [[self request] URL];
	struct hostent		*socketHost;
	struct sockaddr_in	socketAddress;
	NSData				*socketAddressData;
	CFSocketError		socketError;
	
	// Create the socket
	CFSocketContext socketContext;
	bzero(&socketContext, sizeof(socketContext));
	socketContext.info = self;
	socketRef = CFSocketCreate(kCFAllocatorDefault, 0, 0, 0,
							   kCFSocketDataCallBack | kCFSocketConnectCallBack, &_socketCallback,
							   &socketContext);
	// Schedule it in the run loop
	if (socketRef) {
		socketRunLoopSource = CFSocketCreateRunLoopSource(kCFAllocatorDefault, socketRef , 0);
		if (socketRunLoopSource) {
			CFRunLoopAddSource([[NSRunLoop currentRunLoop] getCFRunLoop], socketRunLoopSource,
							   kCFRunLoopDefaultMode);
		}
	}
	if (!socketRef || !socketRunLoopSource) {
		NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorUnknown
										 userInfo:nil];
		[[self client] URLProtocol:self didFailWithError:error];
		return;
	}
	// Connect to the host
	socketHost = gethostbyname([[url host] cString]);
	if (!socketHost) {
		NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCannotFindHost
										 userInfo:nil];
		[[self client] URLProtocol:self didFailWithError:error];
		return;
	}
	bzero(&socketAddress, sizeof(socketAddress));
	bcopy((char*)socketHost->h_addr, (char*)&socketAddress.sin_addr, socketHost->h_length);
	socketAddress.sin_family = PF_INET;
	socketAddress.sin_port = htons([url port] ? [[url port] unsignedShortValue] : 2628);
	socketAddressData = [NSData dataWithBytes:(void *)&socketAddress length:sizeof(socketAddress)];
	socketError = CFSocketConnectToAddress(socketRef, (CFDataRef)socketAddressData, -1.0);
	if (socketError != kCFSocketSuccess) {
		NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCannotConnectToHost
										 userInfo:nil];
		[[self client] URLProtocol:self didFailWithError:error];
		return;
	}
	/*if ([[self request] timeoutInterval] >= 0.0) {
		timeoutTimer = [[NSTimer scheduledTimerWithTimeInterval:[[self request] timeoutInterval]
														 target:self
													   selector:@selector(_socketTimedOut:)
													   userInfo:nil repeats:NO] retain];
	}*/
}

- (void) stopLoading {
	NSLog(@"stopLoading");
	if (socketRunLoopSource) {
		if (CFRunLoopSourceIsValid(socketRunLoopSource))
			CFRunLoopSourceInvalidate(socketRunLoopSource);
		CFRelease(socketRunLoopSource);
		socketRunLoopSource = NULL;
	}
	if (socketRef) {
		CFSocketInvalidate(socketRef);
		CFRelease(socketRef);
		socketRef = NULL;
	}
}

/*- (void) _socketTimedOut:(NSTimer *)inTimer {
	[self stopLoading];
}*/
@end

#pragma mark -

@implementation NSDICTURLProtocol (private)
+ (NSArray *) queryFieldsForURL:(NSURL *)url {
	url = [url standardizedURL];
	NSString *resourceSpecifier = [url resourceSpecifier];
	NSScanner *scanner = [NSScanner scannerWithString:resourceSpecifier];
	[scanner setCharactersToBeSkipped:nil];
	if (![scanner scanString:@"//" intoString:nil])
		return nil;
	if ([[url user] length]) {
		if (![scanner scanString:[url user] intoString:nil])
			return nil;
	}
	if ([scanner scanString:@":" intoString:nil] && [[url password] length]) {
		if (![scanner scanString:[url password] intoString:nil])
			return nil;
	}
	if (![scanner scanString:@"@" intoString:nil] && ([[url user] length] || [[url password] length]))
		return nil;
	if (![scanner scanString:[url host] intoString:nil] && [[url host] length])
		return nil;
	if (![scanner scanString:@":" intoString:nil] && [url port])
		return nil;
	if ([url port] && ![scanner scanString:[[url port] stringValue] intoString:nil])
		return nil;
	[scanner scanString:@"/" intoString:nil];
	
	// We've scanned up to the query part
	// Now lets scan words separated by ":"
	
	// First make sure we *have* a query part
	if ([scanner isAtEnd])
		return nil;
	
	// Ok, we do. Let's continue
	NSMutableArray *fields = [NSMutableArray array];
	NSCharacterSet *stopSet = [NSCharacterSet characterSetWithCharactersInString:@"\"':\\"];
	NSCharacterSet *dqSet = [NSCharacterSet characterSetWithCharactersInString:@"\"\\"];
	NSCharacterSet *sqSet = [NSCharacterSet characterSetWithCharactersInString:@"'\\"];
	NSString *temp;
	NSMutableString *curToken = [NSMutableString string];
	if ([scanner scanUpToCharactersFromSet:stopSet intoString:&temp])
		[curToken appendString:temp];
	while (![scanner isAtEnd]) {
		unichar foo = [resourceSpecifier characterAtIndex:[scanner scanLocation]];
		[scanner setScanLocation:[scanner scanLocation] + 1];
		if (foo == '"' || foo == '\'') {
			// It's a quoted string. Scan to the end quote
			NSCharacterSet *stringSet = dqSet;
			if (foo == '\'')
				stringSet = sqSet;
			if ([scanner scanUpToCharactersFromSet:stringSet intoString:&temp])
				[curToken appendString:temp];
			while (![scanner isAtEnd]) {
				unichar bar = [resourceSpecifier characterAtIndex:[scanner scanLocation]];
				[scanner setScanLocation:[scanner scanLocation]+1];
				if (bar == '\\') {
					// it's an escaped char
					bar = [resourceSpecifier characterAtIndex:[scanner scanLocation]];
					[curToken appendFormat:@"%C", bar];
					[scanner setScanLocation:[scanner scanLocation]+1];
				} else {
					// We hit the end. Break the loop
					break;
				}
				if ([scanner scanUpToCharactersFromSet:stringSet intoString:&temp])
					[curToken appendString:temp];
			}
		} else if (foo == '\\') {
			// It's an escaped char
			foo = [resourceSpecifier characterAtIndex:[scanner scanLocation]];
			[curToken appendFormat:@"%C", foo];
			[scanner setScanLocation:[scanner scanLocation]+1];
		} else if (foo == ':') {
			// It's our delimiter!
			[fields addObject:[NSString stringWithString:curToken]];
			[curToken setString:@""];
		}
		if ([scanner scanUpToCharactersFromSet:stopSet intoString:&temp])
			[curToken appendString:temp];
	}
	// Add the last token
	[fields addObject:[NSString stringWithString:curToken]];
	// And return
	return fields;
}

- (BOOL) _receivedResponse {
	return _receivedResponse;
}

- (void) _setReceivedResponse:(BOOL)flag {
	_receivedResponse = flag;
}

- (NSArray *) _args {
	return args;
}
@end

#pragma mark -

static void _socketCallback(CFSocketRef s, CFSocketCallBackType callbackType, CFDataRef address, 
							const void *data, void *info) {
	NSDICTURLProtocol *dictProtocol = (NSDICTURLProtocol *)info;
	if (!dictProtocol)
		return;
	
	switch (callbackType) {
		case kCFSocketConnectCallBack: {
			NSData *data;
			data = [[NSString stringWithFormat:@"CLIENT NSDICTURLProtocol\r\nDEFINE %@\r\nQUIT\r\n",
				[[dictProtocol _args] componentsJoinedByString:@" "]]
					dataUsingEncoding:NSUTF8StringEncoding];
			CFSocketSendData(s, NULL, (CFDataRef)data, -1.0);
			break;
		}
		case kCFSocketDataCallBack: {
			if ([(NSData *)data length] == 0) {
				if ([dictProtocol _receivedResponse]) {
					[[dictProtocol client] URLProtocolDidFinishLoading:dictProtocol];
					return;
				} else {
					NSError *error = [NSError errorWithDomain:NSURLErrorDomain
														 code:NSURLErrorZeroByteResource
													 userInfo:nil];
					[[dictProtocol client] URLProtocol:dictProtocol didFailWithError:error];
					return;
				}
			}
			NSString *response = [[NSString alloc] initWithData:(NSData *)data
													   encoding:NSUTF8StringEncoding];
			if (![dictProtocol _receivedResponse]) {
				// Make sure our first response is a good code
				if ([response hasPrefix:@"220"]) {
					// valid connection, yay!
					[dictProtocol _setReceivedResponse:YES];
					NSURL *url = [[dictProtocol request] URL];
					NSURLResponse *urlResponse = [[NSURLResponse alloc] initWithURL:url
																		   MIMEType:@"text/plain"
															  expectedContentLength:-1
																   textEncodingName:@"UTF-8"];
					[[dictProtocol client] URLProtocol:dictProtocol
									didReceiveResponse:urlResponse
									cacheStoragePolicy:NSURLCacheStorageAllowed];
				} else {
					NSError *error;
					if ([response hasPrefix:@"530"]) {
						// access denied
						error = [NSError errorWithDomain:NSURLErrorDomain
													code:NSURLErrorNoPermissionsToReadFile
												userInfo:nil];
					} else if ([response hasPrefix:@"420"] || [response hasPrefix:@"421"]) {
						// unavailable
						error = [NSError errorWithDomain:NSURLErrorDomain
													code:NSURLErrorResourceUnavailable
												userInfo:nil];
					} else {
						// bad connection, boo
						error = [NSError errorWithDomain:NSURLErrorDomain
													code:NSURLErrorBadServerResponse
												userInfo:nil];
					}
					[[dictProtocol client] URLProtocol:dictProtocol didFailWithError:error];
					return;
				}
			}
			[[dictProtocol client] URLProtocol:dictProtocol didLoadData:(NSData *)data];
			break;
		}
	}
}
