//
//  MTCoreAudioStreamDescription.h
//  MTCoreAudio.framework
//
//  Created by Michael Thornburgh on Fri Dec 21 2001.
//  Copyright (c) 2001 Michael Thornburgh. All rights reserved.
//
//  provides an object wrapper around an AudioStreamBasicDescription
//

#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudioTypes.h>


@interface MTCoreAudioStreamDescription : NSObject <NSCopying> {
	AudioStreamBasicDescription myASBasicDescription;
}

+ (MTCoreAudioStreamDescription *) streamDescriptionWithAudioStreamBasicDescription:(AudioStreamBasicDescription)theDescription;
+ (MTCoreAudioStreamDescription *) streamDescription;
+ (MTCoreAudioStreamDescription *) nativeStreamDescription;

- (NSBundle *) bundleForDescriptionStrings;
- (NSString *) description;

- (AudioStreamBasicDescription) audioStreamBasicDescription;

- (Boolean) isLinearPCMFormat;
- (Boolean) isCanonicalFormat;
- (Boolean) isNativeFormat;

- (MTCoreAudioStreamDescription *) init;
- (MTCoreAudioStreamDescription *) initWithAudioStreamBasicDescription:(AudioStreamBasicDescription)theDescription;
- (MTCoreAudioStreamDescription *) setNativeFormat;

- (Float32)                        sampleRate;
- (MTCoreAudioStreamDescription *) setSampleRate:(Float32)theSampleRate;

- (UInt32)                         formatID;
- (MTCoreAudioStreamDescription *) setFormatID:(UInt32)theFormatID;

- (UInt32)                         formatFlags;
- (MTCoreAudioStreamDescription *) setFormatFlags:(UInt32)theFormatFlags;

- (UInt32)                         bytesPerPacket;
- (MTCoreAudioStreamDescription *) setBytesPerPacket:(UInt32)theBytesPerPacket;

- (UInt32)                         framesPerPacket;
- (MTCoreAudioStreamDescription *) setFramesPerPacket:(UInt32)theFramesPerPacket;

- (UInt32)                         bytesPerFrame;
- (MTCoreAudioStreamDescription *) setBytesPerFrame:(UInt32)theBytesPerFrame;

- (UInt32)                         channelsPerFrame;
- (MTCoreAudioStreamDescription *) setChannelsPerFrame:(UInt32)theChannelsPerFrame;

- (UInt32)                         bitsPerChannel;
- (MTCoreAudioStreamDescription *) setBitsPerChannel:(UInt32)theBitsPerChannel;

- (Boolean)                        isInterleaved;
- (MTCoreAudioStreamDescription *) setIsInterleaved:(Boolean)interleave;

@end
