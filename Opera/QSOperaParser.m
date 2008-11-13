

#import "QSOperaParser.h"
#import <QSCore/QSCore.h>



@implementation QSOperaBookmarksParser
- (BOOL)validParserForPath:(NSString *)path{
    return [[path lastPathComponent]isEqualToString:@"Bookmarks"];
}
- (NSArray *)objectsFromPath:(NSString *)path withSettings:(NSDictionary *)settings{
    NSString *string=[NSString stringWithContentsOfFile: [path stringByStandardizingPath]];
    return [self linksFromOpera:string];
}
- (NSArray *)linksFromOpera:(NSString *)html{
    
    NSScanner *scanner=[NSScanner scannerWithString:html];
    
    NSMutableArray *array=[NSMutableArray arrayWithCapacity:1];
    
    NSString *url=nil;
    NSString *title=nil;
    QSObject *urlObject=nil;
    while (![scanner isAtEnd]){
        [scanner scanUpToString:@"NAME=" intoString:nil];
        // NSLog(test);
        [scanner scanString:@"NAME=" intoString:nil];
        
        if ([scanner scanUpToString:@"\n\tURL=" intoString:nil]);
        //NSLog(title);
        if ([scanner scanString:@"URL=" intoString:nil]){
            
            //  NSLog(@".");
            // NSLog(test);
            [scanner scanUpToString:@"\n" intoString:&url];
            // NSLog(url);
            if (url)
                url=[url stringByReplacing:@"&amp;" with:@"&"];
            
            if (url)
                urlObject=[QSObject URLObjectWithURL:url title:title];
            
            if (urlObject)
                [array addObject: urlObject];
        }
        url=nil;
        
        
    }
    return array;
    
    return nil;
}

@end

