//
//  MTAudioBuffer.h
//  MTCoreAudio
//
//  Created by Michael Thornburgh on Wed Mar 31 2004.
//  Copyright (c) 2004 Michael Thornburgh. All rights reserved.
//

#import "MTBuffer.h"
#import <CoreAudio/CoreAudio.h>


@interface MTAudioBuffer : MTBuffer {
	AudioBufferList * myBuffer;
	Float64 scaledFramesInBuffer;
	Float64 effectiveRateScalar;
}

- init;
- initWithCapacityFrames:(unsigned)frames channels:(unsigned)channels;

- (unsigned) writeFromAudioBufferList:(const AudioBufferList *)theABL maxFrames:(unsigned)count rateScalar:(Float64)rateScalar waitForRoom:(Boolean)wait;
- (unsigned) readToAudioBufferList:(AudioBufferList *)theABL maxFrames:(unsigned)count waitForData:(Boolean)wait;

- (Float64) rateScalar;
- (Float64) scaledCount;
- (unsigned) channels;

/*
** inherited methods, included for documentation

- (unsigned) count;
- (unsigned) capacity;
- (void) flush;

*/

@end
