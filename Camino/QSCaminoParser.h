

#import <Foundation/Foundation.h>
#import <QSCore/QSParser.h>
@interface QSCaminoBookmarksParser : QSParser
- (NSArray *)caminoBookmarksForDict:(NSDictionary *)dict;
@end
@interface QSOldCaminoBookmarksParser : QSParser
- (NSArray *)linksFromCamino:(NSString *)html;
@end

//@interface QSMozillaHistoryParser : QSParser
//@end