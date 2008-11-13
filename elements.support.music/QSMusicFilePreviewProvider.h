//
//  QSMusicFilePreviewProvider.h
//  Quicksilver
//
//  Created by Nicholas Jitkoff on 1/22/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface QSMusicFilePreviewProvider : NSObject {

}
//- (NSImage *)imageFromTrackTagFile:(NSDictionary *)trackDict;

- (NSRange)rangeOfAtom:(UInt32)atom inData:(NSData *)data;
- (NSRange)rangeOfAtom:(UInt32)atom inData:(NSData *)data range:(NSRange)range;
- (NSRange)rangeOfFrame:(UInt32)frame inData:(NSData *)data;
- (NSRange)rangeOfFrame:(UInt32)frame inData:(NSData *)data range:(NSRange)range;
@end
