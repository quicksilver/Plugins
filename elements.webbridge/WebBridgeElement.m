//
//  WebBridgeElement.m
//  WebBridge
//
//  Created by Nicholas Jitkoff on 6/11/07.
//  Copyright __MyCompanyName__ 2007. All rights reserved.
//

#import <QSFoundation/QSFoundation.h>
#import <QSCore/QSCore.h>
#import <QSCore/QSLibrarian.h>
#import <QSCore/QSExecutor.h>

#import "WebBridgeElement.h"
#import "SimpleHTTPConnection.h"
#import "SimpleHTTPServer.h"
#import <stdio.h>
#import <string.h>
#import <sys/socket.h>
#include <arpa/inet.h>

@interface WebBridgeElement (PrivateMethods)
- (NSString *)applicationSupportFolder;
  //- (NSURL *)currentURL;
@end

@implementation WebBridgeElement
+ (void) initialize {
  [[self alloc] init];  
}

- (id) init {
  self = [super init];
  if (self != nil) {
    [self setServer:[[[SimpleHTTPServer alloc] initWithTCPPort:5001
                                                      delegate:self] autorelease]];
    
    NSLog(@"enable web bridge");
  }
  return self;
}


- (void)awakeFromNib
{
}

- (void)dealloc
{
  [server release];
  [super dealloc];
}

- (void)setServer:(SimpleHTTPServer *)sv
{
  [server autorelease];
  server = [sv retain];
}
- (SimpleHTTPServer *)server { return server; }




- (void)processURL:(NSURL *)url connection:(SimpleHTTPConnection *)connection {
  
  NSLog(@"URL %@", url);
  NSData *data = nil;
  NSString *mime = nil;
  
  @try {
  NSString *path = [url path];
  if ([path isEqualToString:@"/image"]) {
    NSLog(@"url %@", url);
    NSLog(@"url %@", [url query]);
    NSLog(@"url %@", [url path]);
    
    NSString *name = [url query];
    NSImage *image = [QSResourceManager imageNamed:name];
    image =  [image duplicateOfSize:QSSize128];
    data = [image TIFFRepresentation];
    mime = @"image/tiff";
  } else if ([path isEqualToString:@"/icon"]) {
    NSString *name = [url query];
    QSObject *object = [QSObject objectWithIdentifier:name];    

    NSImage *image = [object loadedIcon];
    image =  [image duplicateOfSize:QSSize32];
    data = [image TIFFRepresentation];
    mime = @"image/tiff";
  } else if ([path isEqualToString:@"/object"]) {
    NSString *name = [url query];
    QSObject *object = [QSObject objectWithIdentifier:name];
    NSLog(@"Object %@", object);
  } else if ([path isEqualToString:@"/query"]) {
    if (![[url query] length]) return;
    NSArray *objects = [QSLib scoredArrayForString:[url query]];
    
    if ([objects count] > 10) objects = [objects subarrayWithRange:NSMakeRange(0, 10)];
    NSXMLElement *root = [NSXMLElement elementWithName:@"results"];
    NSXMLDocument *document = [[[NSXMLDocument alloc] initWithRootElement:root] autorelease];
    
    foreach(object, objects) {
      NSXMLElement *objectElement = [NSXMLElement elementWithName:@"div"];
      NSString *identifier = [object identifier];
      if (!identifier) {
        continue;
        identifier = [NSString uniqueString];
        [object setIdentifier:identifier];
      }
      NSURL *imageSURL = [NSURL URLWithString:[@"http://localhost:5001/icon?" stringByAppendingString:identifier]];
      NSXMLElement *imageElement = [NSXMLElement elementWithName:@"img"];
      [imageElement addAttribute:[NSXMLNode attributeWithName:@"src" stringValue:imageSURL]];
      [imageElement addAttribute:[NSXMLNode attributeWithName:@"height" stringValue:@"32"]];
      [imageElement addAttribute:[NSXMLNode attributeWithName:@"width" stringValue:@"32"]];
      [imageElement addAttribute:[NSXMLNode attributeWithName:@"align" stringValue:@"middle"]];
      [objectElement addChild:imageElement];
      [objectElement addChild:[NSXMLElement textWithStringValue:[object name]]];

//      [objectElement addAttribute:[NSXMLNode attributeWithName:@"name" stringValue:[object name]]];
//      [objectElement addAttribute:[NSXMLNode attributeWithName:@"id" stringValue:[object identifier]]];
//      [objectElement addAttribute:[NSXMLNode attributeWithName:@"image" stringValue:@"imgsrc"]];
      [root addChild:objectElement];
    }
    NSLog(@"doc %@", document);
    data = [document XMLDataWithOptions:NSXMLNodePrettyPrint];
    mime = @"text/plain";
  } else if ([path isEqualToString:@"/query"]) {   
    data = [[url query] dataUsingEncoding:NSUTF8StringEncoding];
    mime = @"text/plain";
    
  } else if ([path isEqualToString:@"/command"]) {   
    
    NSString *name = [url query];
    QSObject *object = [QSObject objectWithIdentifier:name];
  NSArray *actions=[QSExec validActionsForDirectObject:object indirectObject:nil];
  [actions sortUsingDescriptors:[NSSortDescriptor descriptorArrayWithKey:@"rank" ascending:YES selector:@selector(compare:)]];
  QSAction *action = nil;
  if ([actions count])
    action = [actions objectAtIndex:0];
  
  [action performOnDirectObject:object indirectObject:nil];
}

  }
@catch (NSException *e) {
  NSLog(@"Exception %@", e);
}

if(data && mime) {
  [server replyWithData: data
               MIMEType: mime];
} else {
  NSString *errorMsg = [NSString stringWithFormat:@"Error in URL: %@", url];
  NSLog(@"%@", errorMsg);
    [server replyWithStatusCode:400 // Bad Request
                        message:errorMsg];
  }
}

- (void)stopProcessing {
  
}


- (NSString *)applicationSupportFolder
{
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
  
  NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
  
  NSFileManager *manager = [NSFileManager defaultManager];
  
	basePath = [basePath stringByAppendingPathComponent:@"Cultured Code"];
	if( ![manager fileExistsAtPath:basePath] ) {
		[manager createDirectoryAtPath:basePath attributes:nil];
  }
  
	NSString *appSupportFolder = [basePath stringByAppendingPathComponent:@"SimpleHTTPServer"];
	if( ![manager fileExistsAtPath:appSupportFolder] )
		[manager createDirectoryAtPath:appSupportFolder attributes:nil];	
	
  return appSupportFolder;
}

@end

