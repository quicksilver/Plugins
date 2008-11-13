/*
 *  MTCoreAudioTypes.h
 *  MTCoreAudio
 *
 *  Created by Michael Thornburgh on Thu Jan 03 2002.
 *  Copyright (c) 2001 Michael Thornburgh. All rights reserved.
 *
 */
 
#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudio.h>


typedef enum MTCoreAudioDirection {
	kMTCoreAudioDevicePlaybackDirection,
	kMTCoreAudioDeviceRecordDirection
} MTCoreAudioDirection;

typedef enum MTCoreAudioStreamSide {
	kMTCoreAudioStreamLogicalSide,
	kMTCoreAudioStreamPhysicalSide
} MTCoreAudioStreamSide;

typedef struct _MTCoreAudioVolumeInfo {
	Boolean hasVolume;
	Boolean canSetVolume;
	Float32 theVolume;
	Boolean canMute;
	Boolean isMuted;
	Boolean canPlayThru;
	Boolean playThruIsSet;
} MTCoreAudioVolumeInfo;
