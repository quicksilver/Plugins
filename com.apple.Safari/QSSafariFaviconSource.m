

#import "QSSafariFaviconSource.h"
//#import "WebKit.h"

@implementation QSSafariFaviconSource
+ (id)sharedInstance{
    static id _sharedInstance;
    if (!_sharedInstance) _sharedInstance = [[[self class] allocWithZone:[self zone]] init];
    return _sharedInstance;
}

- (id)init {
    if (self = [super init]){
        iconCache=nil;
        webSiteURLToIconURLDict=nil;
        
		[NSThread detachNewThreadSelector:@selector(loadSafariIcons) toTarget:self withObject:nil];
    }
    return self;
}

- (NSImage *)faviconForURL:(NSURL *)url{
   // NSLog(@"URL!? %@",url);
    // NSLog([webSiteURLToIconURLDict description]);
    NSString *faviconKey=nil;
    NSString *urlString=[url absoluteString];
    faviconKey=[webSiteURLToIconURLDict objectForKey:urlString];
    if (!faviconKey)
        faviconKey=[[[[NSURL alloc]initWithScheme:[url scheme] host:[url host] path:@"/favicon.ico"]autorelease]absoluteString];
    
    
    NSImage *favicon=[iconCache objectForKey:faviconKey];
    if (0 && !favicon){ //**Try to load?
                        //favicon=[[NSImage alloc]initWithContentsOfURL:faviconKey];
                        //[favicon setName:[url host]];
    }
    return favicon;
}

- (void) loadSafariIcons{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[NSThread setThreadPriority:0.0];
    //NSLog(@"eep");
	NSMutableDictionary *newIconCache=[[NSMutableDictionary alloc]initWithCapacity:100];
	NSDictionary *newWebSiteURLToIconURLDict=nil;
    NS_DURING
     //   sleep(5);
        NSFileManager *manager = [NSFileManager defaultManager];
        
        NSString *cachePath=[@"~/Library/Safari/Icons/" stringByExpandingTildeInPath];
        NSArray *iconCaches=[manager subpathsAtPath:cachePath];
        
        int i;
        NSString *thePath;
        for (i=0;i<[iconCaches count];i++){
            thePath=[cachePath stringByAppendingPathComponent:[iconCaches objectAtIndex:i]];
            
            if ([[thePath pathExtension]isEqualToString:@"cache"]){
                
                NSUnarchiver *unarchiver=[[[NSUnarchiver alloc]initForReadingWithData:[NSData dataWithContentsOfFile:thePath]]autorelease];
                if (!unarchiver) NSLog(@"Skipping icon file: %@",thePath);
                NSString *key=[unarchiver decodeObject];
                id object=[unarchiver decodeObject];
                
                if ([object isKindOfClass:[NSNull class]])continue;
                if ([object isKindOfClass:[NSData class]]){
                    object=[[[NSImage alloc] initWithData:object]autorelease];
                    [newIconCache setObject:object forKey:key];
                }
                else{
                    if ([key isEqualToString:@"WebSiteURLToIconURLKey"]){
                        newWebSiteURLToIconURLDict=[object retain];
					}
                    //NSLog(@"unknown data: %@ %@",key,thePath);
                }
                
            }
            
        }
        
        //    NSLog(@"Dict:%@",webSiteURLToIconURLDict);
		//NSLog(@"Loaded %d Favicons",[[iconCache allKeys]count]);
        
		iconCache=newIconCache;
		webSiteURLToIconURLDict=[newWebSiteURLToIconURLDict retain];
		
		
        NS_HANDLER
            NSLog(@"Unable to load Favicons");
            
        NS_ENDHANDLER
        
        [pool release];
}
@end
