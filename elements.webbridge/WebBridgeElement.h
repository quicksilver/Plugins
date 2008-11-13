//
//  WebBridgeElement.h
//  WebBridge
//
//  Created by Nicholas Jitkoff on 6/11/07.
//  Copyright __MyCompanyName__ 2007. All rights reserved.
//

@class SimpleHTTPConnection, SimpleHTTPServer;

@interface WebBridgeElement : NSObject {
  SimpleHTTPServer *server;
}

- (void)setServer:(SimpleHTTPServer *)sv;
- (SimpleHTTPServer *)server;

- (void)processURL:(NSURL *)path connection:(SimpleHTTPConnection *)connection;
- (void)stopProcessing;


@end

