//
//  MTCoreAudioDevice.h
//  MTCoreAudio.framework
//
//  Created by Michael Thornburgh on Sun Dec 16 2001.
//  Copyright (c) 2001 Michael Thornburgh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudio.h>

extern NSString * MTCoreAudioHardwareDeviceListDidChangeNotification;
extern NSString * MTCoreAudioHardwareDefaultInputDeviceDidChangeNotification;
extern NSString * MTCoreAudioHardwareDefaultOutputDeviceDidChangeNotification;
extern NSString * MTCoreAudioHardwareDefaultSystemOutputDeviceDidChangeNotification;

@interface MTCoreAudioDevice : NSObject {
	AudioDeviceID myDevice;
	id myDelegate;
	AudioDeviceIOProc myIOProc;
	Boolean deviceIOStarted;
	NSArray * myStreams[2];
	BOOL streamsDirty[2];
	void * myIOProcClientData;
	NSInvocation * myIOInvocation;
	Boolean isPaused;
}

// NSArray of MTCoreAudioDevices
+ (NSArray *)           allDevices;
+ (NSArray *)           devicesWithName:(NSString *)theName havingStreamsForDirection:(MTCoreAudioDirection)theDirection;

// NSArray of NSArray of MTCoreAudioDevices
+ (NSArray *)		allDevicesByRelation;

+ (MTCoreAudioDevice *) deviceWithID:(AudioDeviceID)theID;
+ (MTCoreAudioDevice *) deviceWithUID:(NSString *)theUID;
+ (MTCoreAudioDevice *) defaultInputDevice;
+ (MTCoreAudioDevice *) defaultOutputDevice;
+ (MTCoreAudioDevice *) defaultSystemOutputDevice;

- (MTCoreAudioDevice *) initWithDeviceID:(AudioDeviceID)theID;
- (MTCoreAudioDevice *) clone;

- (AudioDeviceID) deviceID;
- (NSString *)    deviceName;
- (NSString *)    deviceUID;
- (NSString *)    deviceManufacturer;
- (NSArray *)     relatedDevices;

+ (void) setDelegate:(id)theDelegate;
+ (id)   delegate;
+ (void) attachNotificationsToThisThread;

- (void) setDelegate:(id)theDelegate;
- (id)   delegate;

// subclasses might want to override this method in order to
// also override class MTCoreAudioStream
- (Class) streamFactory;

// NSArray of MTCoreAudioStreams
- (NSArray *) streamsForDirection:(MTCoreAudioDirection)theDirection;

// data source methods refer to the Device Master Source (HAL device channel 0)
- (NSString *) dataSourceForDirection:(MTCoreAudioDirection)theDirection;
// NSArray of NSStrings
- (NSArray *)  dataSourcesForDirection:(MTCoreAudioDirection)theDirection;
- (Boolean)    canSetDataSourceForDirection:(MTCoreAudioDirection)theDirection;
- (void)       setDataSource:(NSString *)theSource forDirection:(MTCoreAudioDirection)theDirection;

- (NSString *) clockSourceForChannel:(UInt32)theChannel forDirection:(MTCoreAudioDirection)theDirection;
- (NSArray *)  clockSourcesForChannel:(UInt32)theChannel forDirection:(MTCoreAudioDirection)theDirection;
- (void)       setClockSource:(NSString *)theSource forChannel:(UInt32)theChannel forDirection:(MTCoreAudioDirection)theDirection;

- (UInt32) deviceBufferSizeInFrames;
- (UInt32) deviceMaxVariableBufferSizeInFrames;
- (UInt32) deviceMinBufferSizeInFrames;
- (UInt32) deviceMaxBufferSizeInFrames;
- (void)   setDeviceBufferSizeInFrames:(UInt32)numFrames;
- (UInt32) deviceLatencyFramesForDirection:(MTCoreAudioDirection)theDirection;
- (UInt32) deviceSafetyOffsetFramesForDirection:(MTCoreAudioDirection)theDirection;

// NSArray of NSNumbers.  each NSNumber is the number of channels in the corresponding stream
- (NSArray *) channelsByStreamForDirection:(MTCoreAudioDirection)theDirection;
- (UInt32)    channelsForDirection:(MTCoreAudioDirection)theDirection;

- (MTCoreAudioVolumeInfo) volumeInfoForChannel:(UInt32)theChannel forDirection:(MTCoreAudioDirection)theDirection;
- (Float32) volumeForChannel:(UInt32)theChannel forDirection:(MTCoreAudioDirection)theDirection;
- (Float32) volumeInDecibelsForChannel:(UInt32)theChannel forDirection:(MTCoreAudioDirection)theDirection;
- (void)    setVolume:(Float32)theVolume forChannel:(UInt32)theChannel forDirection:(MTCoreAudioDirection)theDirection;
- (void)    setVolumeDecibels:(Float32)theVolumeDecibels forChannel:(UInt32)theChannel forDirection:(MTCoreAudioDirection)theDirection;
- (Float32) volumeInDecibelsForVolume:(Float32)theVolume forChannel:(UInt32)theChannel forDirection:(MTCoreAudioDirection)theDirection;
- (Float32) volumeForVolumeInDecibels:(Float32)theVolumeDecibels forChannel:(UInt32)theChannel forDirection:(MTCoreAudioDirection)theDirection;
- (void)    setMute:(BOOL)isMuted forChannel:(UInt32)theChannel forDirection:(MTCoreAudioDirection)theDirection;
- (void)    setPlayThru:(BOOL)isPlayingThru forChannel:(UInt32)theChannel;

// subclasses might want to override this method in order to
// also override class MTCoreAudioStreamDescription
- (Class) streamDescriptionFactory;

- (MTCoreAudioStreamDescription *) streamDescriptionForChannel:(UInt32)theChannel forDirection:(MTCoreAudioDirection)theDirection;
- (NSArray *) streamDescriptionsForChannel:(UInt32)theChannel forDirection:(MTCoreAudioDirection)theDirection;
- (Boolean) setStreamDescription:(MTCoreAudioStreamDescription *)theDescription forChannel:(UInt32)theChannel forDirection:(MTCoreAudioDirection)theDirection;
- (MTCoreAudioStreamDescription *) matchStreamDescription:(MTCoreAudioStreamDescription *)theDescription forChannel:(UInt32)theChannel forDirection:(MTCoreAudioDirection)theDirection;

- (Float64)   nominalSampleRate;
- (NSArray *) nominalSampleRates;
- (Boolean)   supportsNominalSampleRate:(Float64)theRate;
- (Boolean)   setNominalSampleRate:(Float64)theRate;
- (Float64)   actualSampleRate;

- (void) setIOProc:(AudioDeviceIOProc)theIOProc withClientData:(void *)theClientData;
- (void) setIOTarget:(id)theTarget withSelector:(SEL)theSelector withClientData:(void *)theClientData;
- (void) removeIOProc;
- (void) removeIOTarget;
- (Boolean) deviceStart;
- (void) deviceStop;
- (void) setDevicePaused:(Boolean)shouldPause;

// prototype for an IOTarget -- IOTargets must have the same signature, and
// take their arguments in this order
- (OSStatus) ioCycleForDevice:(MTCoreAudioDevice *)theDevice timeStamp:(const AudioTimeStamp *)inNow inputData:(const AudioBufferList *)inInputData inputTime:(const AudioTimeStamp *)inInputTime outputData:(AudioBufferList *)outOutputData outputTime:(const AudioTimeStamp *)inOutputTime clientData:(void *)inClientData;

@end

// these may be implemented by MTCoreAudioDevice's delegate
@interface NSObject(MTCoreAudioHardwarePropertyNotifications)
- (void) audioHardwareDeviceListDidChange;
- (void) audioHardwareDefaultInputDeviceDidChange;
- (void) audioHardwareDefaultOutputDeviceDidChange;
- (void) audioHardwareDefaultSystemOutputDeviceDidChange;
@end

// these may be implemented by an MTCoreAudioDevice instance's delegate
@interface NSObject(MTCoreAudioDevicePropertyNotifications)
- (void) audioDeviceDidDie:(MTCoreAudioDevice *)theDevice;
- (void) audioDeviceDidOverload:(MTCoreAudioDevice *)theDevice;
- (void) audioDeviceSomethingDidChange:(MTCoreAudioDevice *)theDevice;
- (void) audioDeviceBufferSizeInFramesDidChange:(MTCoreAudioDevice *)theDevice;
- (void) audioDeviceStreamsListDidChange:(MTCoreAudioDevice *)theDevice;
- (void) audioDeviceChannelsByStreamDidChange:(MTCoreAudioDevice *)theDevice forDirection:(MTCoreAudioDirection)theDirection;
- (void) audioDeviceStreamDescriptionDidChange:(MTCoreAudioDevice *)theDevice forChannel:(UInt32)theChannel forDirection:(MTCoreAudioDirection)theDirection;
- (void) audioDeviceNominalSampleRateDidChange:(MTCoreAudioDevice *)theDevice;
- (void) audioDeviceNominalSampleRatesDidChange:(MTCoreAudioDevice *)theDevice;
// if the delegate doesn't implement a more-specific method for volume, mute, or playthru,
// then audioDeviceVolumeInfoDidChange will be tried
- (void) audioDeviceVolumeInfoDidChange:(MTCoreAudioDevice *)theDevice forChannel:(UInt32)theChannel forDirection:(MTCoreAudioDirection)theDirection;
- (void) audioDeviceVolumeDidChange:(MTCoreAudioDevice *)theDevice forChannel:(UInt32)theChannel forDirection:(MTCoreAudioDirection)theDirection;
- (void) audioDeviceMuteDidChange:(MTCoreAudioDevice *)theDevice forChannel:(UInt32)theChannel forDirection:(MTCoreAudioDirection)theDirection;
- (void) audioDevicePlayThruDidChange:(MTCoreAudioDevice *)theDevice forChannel:(UInt32)theChannel forDirection:(MTCoreAudioDirection)theDirection;
- (void) audioDeviceSourceDidChange:(MTCoreAudioDevice *)theDevice forDirection:(MTCoreAudioDirection)theDirection;
- (void) audioDeviceClockSourceDidChange:(MTCoreAudioDevice *)theDevice forChannel:(UInt32)theChannel forDirection:(MTCoreAudioDirection)theDirection;
- (void) audioDeviceStartDidFail:(MTCoreAudioDevice *)theDevice forReason:(OSStatus)theReason;
@end
