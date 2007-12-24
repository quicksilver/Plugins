//
//  ColloquySource.h
//  Quicksilver
//

#import <Foundation/Foundation.h>

#import <QSCore/QSObjectSource.h>
#import <QSCore/QSActionProvider.h>

@interface ColloquySource : QSObjectSource {
	NSMutableDictionary *servers;
	NSMutableDictionary *objectChildren;
	NSImage *roomImage;
	NSImage *personImage;
	NSImage *bookmarkImage;
	NSImage *entryImage;
}

@end

@interface NSURL (TSURLAdditions)
- (BOOL) matchesURL:(NSURL *)other;
@end

@interface ColloquyActionProvider : QSActionProvider {
	NSImage *roomImage;
	NSImage *chatImage;
}
@end
