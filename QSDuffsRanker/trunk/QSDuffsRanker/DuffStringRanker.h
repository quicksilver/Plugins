#import <Foundation/Foundation.h>

/*@protocol QSStringRanker
- (id)initWithString:(NSString *)string;
- (double)scoreForAbbreviation:(NSString*)anAbbreviation;
- (NSIndexSet*)maskForAbbreviation:(NSString*)anAbbreviation;
@end
*/
@interface DuffStringRanker : NSObject <QSStringRanker>
{
	UniChar* string;
	unsigned* originalIndex;
	unsigned length;
	NSString* originalString; // only for debug messages
	NSString* rankedString;
}
- (id)initWithString:(NSString *)aString;
- (double)scoreForAbbreviation:(NSString*)anAbbreviation;
- (NSIndexSet*)maskForAbbreviation:(NSString*)anAbbreviation;
- (NSString*)rankedString;
- (void)setRankedString:(NSString*)aString;
@end
