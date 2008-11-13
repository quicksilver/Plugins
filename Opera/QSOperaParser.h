

#import <Foundation/Foundation.h>
#import <QSCore/QSParser.h>
@interface QSOperaBookmarksParser : QSParser

- (NSArray *)linksFromOpera:(NSString *)html;
@end