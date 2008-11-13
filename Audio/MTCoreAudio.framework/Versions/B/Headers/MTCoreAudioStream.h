//
//  MTCoreAudioStream.h
//  MTCoreAudio
//
//  Created by Michael Thornburgh on Thu Jan 03 2002.
//  Copyright (c) 2001 Michael Thornburgh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTCoreAudioStream : NSObject {
	AudioStreamID myStream;
	id myDelegate;
	id parentAudioDevice;
}

- (MTCoreAudioStream *) initWithStreamID:(AudioStreamID)theID withOwningDevice:(id)theOwningDevice;
- (MTCoreAudioDirection) direction;
- (NSString *) streamName;
- (id) owningDevice;
- (AudioStreamID) streamID;

// if no delegate is set, will try the owningDevice's delegate
- (id) delegate;
- (void) setDelegate:(id)theDelegate;

- (UInt32) deviceStartingChannel;
- (UInt32) numberChannels;

- (NSString *) dataSource;
// NSArray of NSStrings
- (NSArray *)  dataSources;
- (Boolean)    canSetDataSource;
- (void)       setDataSource:(NSString *)theSource;

- (NSString *) clockSource;
// NSArray of NSStrings
- (NSArray *)  clockSources;
- (void)       setClockSource:(NSString *)theSource;


- (MTCoreAudioStreamDescription *) streamDescriptionForSide:(MTCoreAudioStreamSide)theSide;
// NSArray of MTCoreAudioStreamDescriptions
- (NSArray *) streamDescriptionsForSide:(MTCoreAudioStreamSide)theSide;
- (Boolean) setStreamDescription:(MTCoreAudioStreamDescription *)theDescription forSide:(MTCoreAudioStreamSide)theSide;
- (MTCoreAudioStreamDescription *) matchStreamDescription:(MTCoreAudioStreamDescription *)theDescription forSide:(MTCoreAudioStreamSide)theSide;

- (MTCoreAudioVolumeInfo) volumeInfoForChannel:(UInt32)theChannel;
- (Float32) volumeForChannel:(UInt32)theChannel;
- (Float32) volumeInDecibelsForChannel:(UInt32)theChannel;
- (void)    setVolume:(Float32)theVolume forChannel:(UInt32)theChannel;
- (void)    setVolumeDecibels:(Float32)theVolumeDecibels forChannel:(UInt32)theChannel;
- (Float32) volumeInDecibelsForVolume:(Float32)theVolume forChannel:(UInt32)theChannel;
- (Float32) volumeForVolumeInDecibels:(Float32)theVolumeDecibels forChannel:(UInt32)theChannel;
- (void)    setMute:(BOOL)isMuted forChannel:(UInt32)theChannel;
- (void)    setPlayThru:(BOOL)isPlayingThru forChannel:(UInt32)theChannel;

@end


// these may be implemented by an MTCoreAudioStream instance's delegate.  if the
// instance doesn't have a delegate, then it's owning MTCoreAudioDevice instance's delegate
// will be tried instead
@interface NSObject(MTCoreAudioStreamPropertyNotifications)
// note that in real life, this probably doesn't get called because CoreAudio
// resets the stream IDs when the format changes.  at least on my audio hardware.
- (void) audioStreamStreamDescriptionDidChange:(MTCoreAudioStream *)theStream forSide:(MTCoreAudioStreamSide)theSide;
// delegate should implement either audioDeviceVolumeInfoDidChange or the individuals
// for volume, mute, and playthru
- (void) audioStreamVolumeInfoDidChange:(MTCoreAudioStream *)theStream forChannel:(UInt32)theChannel;
- (void) audioStreamVolumeDidChange:(MTCoreAudioStream *)theStream forChannel:(UInt32)theChannel;
- (void) audioStreamMuteDidChange:(MTCoreAudioStream *)theStream forChannel:(UInt32)theChannel;
- (void) audioStreamPlayThruDidChange:(MTCoreAudioStream *)theStream forChannel:(UInt32)theChannel;
- (void) audioStreamSourceDidChange:(MTCoreAudioStream *)theStream;
- (void) audioStreamClockSourceDidChange:(MTCoreAudioStream *)theStream;
@end
