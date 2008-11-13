//
//  MTCoreAudioStream.m
//  MTCoreAudio
//
//  Created by Michael Thornburgh on Thu Jan 03 2002.
//  Copyright (c) 2001 Michael Thornburgh. All rights reserved.
//

#import "MTCoreAudioTypes.h"
#import "MTCoreAudioStreamDescription.h"
#import "MTCoreAudioDevice.h"
#import "MTCoreAudioStream.h"

static NSString * _MTCoreAudioStreamNotification = @"_MTCoreAudioStreamNotification";
static NSString * _MTCoreAudioStreamIDKey = @"StreamID";
static NSString * _MTCoreAudioChannelKey = @"Channel";
static NSString * _MTCoreAudioPropertyIDKey = @"PropertyID";


static NSString * _DataSourceNameForID ( AudioStreamID theStreamID, UInt32 theDataSourceID )
{
	OSStatus theStatus;
	UInt32 theSize;
	AudioValueTranslation theTranslation;
	CFStringRef theCFString;
	NSString * rv;
	
	theTranslation.mInputData = &theDataSourceID;
	theTranslation.mInputDataSize = sizeof(UInt32);
	theTranslation.mOutputData = &theCFString;
	theTranslation.mOutputDataSize = sizeof ( CFStringRef );
	theSize = sizeof(AudioValueTranslation);
	theStatus = AudioStreamGetProperty ( theStreamID, 0, kAudioDevicePropertyDataSourceNameForIDCFString, &theSize, &theTranslation );
	if (( theStatus == 0 ) && theCFString )
	{
		rv = [NSString stringWithString:(NSString *)theCFString];
		CFRelease ( theCFString );
		return rv;
	}

	return nil;
}

static NSString * _ClockSourceNameForID ( AudioStreamID theStreamID, UInt32 theClockSourceID )
{
	OSStatus theStatus;
	UInt32 theSize;
	AudioValueTranslation theTranslation;
	CFStringRef theCFString;
	NSString * rv;
	
	theTranslation.mInputData = &theClockSourceID;
	theTranslation.mInputDataSize = sizeof(UInt32);
	theTranslation.mOutputData = &theCFString;
	theTranslation.mOutputDataSize = sizeof ( CFStringRef );
	theSize = sizeof(AudioValueTranslation);
	theStatus = AudioStreamGetProperty ( theStreamID, 0, kAudioDevicePropertyClockSourceNameForIDCFString, &theSize, &theTranslation );
	if (( theStatus == 0 ) && theCFString )
	{
		rv = [NSString stringWithString:(NSString *)theCFString];
		CFRelease ( theCFString );
		return rv;
	}

	return nil;
}

static OSStatus _MTCoreAudioStreamPropertyListener (
	AudioStreamID inStream,
	UInt32 inChannel,
	AudioDevicePropertyID inPropertyID,
	void * inClientData
)
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	NSMutableDictionary * notificationUserInfo = [NSMutableDictionary dictionaryWithCapacity:4];
	
	[notificationUserInfo setObject:[NSNumber numberWithUnsignedLong:inStream] forKey:_MTCoreAudioStreamIDKey];
	[notificationUserInfo setObject:[NSNumber numberWithUnsignedLong:inChannel] forKey:_MTCoreAudioChannelKey];
	[notificationUserInfo setObject:[NSNumber numberWithUnsignedLong:inPropertyID] forKey:_MTCoreAudioPropertyIDKey];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:_MTCoreAudioStreamNotification object:nil userInfo:notificationUserInfo];
	
	[pool release];
	
	return 0;
}



@implementation MTCoreAudioStream

- init
{
	[self dealloc];
	return nil;
}

- (MTCoreAudioStream *) initWithStreamID:(AudioStreamID)theStreamID withOwningDevice:(id)theOwningDevice
{
	[super init];
	
	myDelegate = nil;
	myStream = theStreamID;
	parentAudioDevice = theOwningDevice;

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_dispatchStreamNotification:) name:_MTCoreAudioStreamNotification object:nil];
	AudioStreamAddPropertyListener ( theStreamID, kAudioPropertyWildcardChannel, kAudioPropertyWildcardPropertyID, _MTCoreAudioStreamPropertyListener, NULL );

	return self;
}

- (MTCoreAudioDirection) direction
{
	OSStatus theStatus;
	UInt32 theSize;
	UInt32 theDirection;
	
	theSize = sizeof(UInt32);
	theStatus = AudioStreamGetProperty ( myStream, 0, kAudioStreamPropertyDirection, &theSize, &theDirection );
	if (( theStatus == 0 ) && (theDirection == 1 ))
		return kMTCoreAudioDeviceRecordDirection;
	else
		return kMTCoreAudioDevicePlaybackDirection;
}

- (NSString *) streamName
{
	OSStatus theStatus;
	CFStringRef theCFString;
	NSString * rv = nil;
	UInt32 theSize;
	
	theSize = sizeof ( CFStringRef );
	theStatus = AudioStreamGetProperty ( myStream, 0, kAudioDevicePropertyDeviceNameCFString, &theSize, &theCFString );
	if ( theStatus != 0 )
		return nil;
	if ( theCFString )
	{
		rv = [NSString stringWithString:(NSString *)theCFString];
		CFRelease ( theCFString );
	}
	return rv;
}

- (NSString *) description
{
	return [NSString stringWithFormat:@"<%@: %p %@ id %d> %@", [self className], self, [self direction] == kMTCoreAudioDeviceRecordDirection ? @"Record" : @"Playback", [self streamID], [self streamName]];
}

- (id) owningDevice
{
	return parentAudioDevice;
}

- (AudioStreamID) streamID
{
	return myStream;
}


- (void) _dispatchStreamNotification:(NSNotification *)theNotification
{
	id theDelegate;
	AudioStreamID theStreamID;
	UInt32 theChannel;
	AudioDevicePropertyID thePropertyID;
	NSDictionary * theUserInfo = [theNotification userInfo];
	BOOL hasVolumeInfoDidChangeMethod = false;
	MTCoreAudioStreamSide theSide = kMTCoreAudioStreamLogicalSide;
	
	theStreamID = [[theUserInfo objectForKey:_MTCoreAudioStreamIDKey] unsignedLongValue];
	
	if (myDelegate)
		theDelegate = myDelegate;
	else
		theDelegate = [parentAudioDevice delegate];
	
	if ( theDelegate && ( theStreamID == myStream ))
	{
		theChannel = [[theUserInfo objectForKey:_MTCoreAudioChannelKey] unsignedLongValue];
		thePropertyID = [[theUserInfo objectForKey:_MTCoreAudioPropertyIDKey] unsignedLongValue];
		
		switch (thePropertyID)
		{
			case kAudioDevicePropertyVolumeScalar:
			case kAudioDevicePropertyVolumeDecibels:
			case kAudioDevicePropertyMute:
			case kAudioDevicePropertyPlayThru:
				if ([theDelegate respondsToSelector:@selector(audioStreamVolumeInfoDidChange:forChannel:)])
					hasVolumeInfoDidChangeMethod = true;
				else
					hasVolumeInfoDidChangeMethod = false;
			break;
		}

		switch (thePropertyID)
		{
			case kAudioStreamPropertyPhysicalFormat:
				theSide = kMTCoreAudioStreamPhysicalSide;
			case kAudioDevicePropertyStreamFormat:
				if ([theDelegate respondsToSelector:@selector(audioStreamStreamDescriptionDidChange:forSide:)])
					[theDelegate audioStreamStreamDescriptionDidChange:self forSide:theSide];
				break;
			case kAudioDevicePropertyDataSource:
				if ([theDelegate respondsToSelector:@selector(audioStreamSourceDidChange:)])
					[theDelegate audioStreamSourceDidChange:self];
				break;
			case kAudioDevicePropertyClockSource:
				if ([theDelegate respondsToSelector:@selector(audioStreamClockSourceDidChange:)])
					[theDelegate audioStreamClockSourceDidChange:self];
				break;
			case kAudioDevicePropertyVolumeScalar:
			// case kAudioDevicePropertyVolumeDecibels:
				if ([theDelegate respondsToSelector:@selector(audioStreamVolumeDidChange:forChannel:)])
					[theDelegate audioStreamVolumeDidChange:self forChannel:theChannel];
				else if (hasVolumeInfoDidChangeMethod)
					[theDelegate audioStreamVolumeInfoDidChange:self forChannel:theChannel];
				break;
			case kAudioDevicePropertyMute:
				if ([theDelegate respondsToSelector:@selector(audioStreamMuteDidChange:forChannel:)])
					[theDelegate audioStreamMuteDidChange:self forChannel:theChannel];
				else if (hasVolumeInfoDidChangeMethod)
					[theDelegate audioStreamVolumeInfoDidChange:self forChannel:theChannel];
				break;
			case kAudioDevicePropertyPlayThru:
				if ([theDelegate respondsToSelector:@selector(audioStreamPlayThruDidChange:forChannel:)])
					[theDelegate audioStreamPlayThruDidChange:self forChannel:theChannel];
				else if (hasVolumeInfoDidChangeMethod)
					[theDelegate audioStreamVolumeInfoDidChange:self forChannel:theChannel];
				break;
		}
	}

}

- (id) delegate
{
	return myDelegate;
}

- (void) setDelegate:(id)theDelegate
{
	myDelegate = theDelegate;
}

- (UInt32) deviceStartingChannel
{
	OSStatus theStatus;
	UInt32 theSize;
	UInt32 theChannel;
	
	theSize = sizeof(UInt32);
	theStatus = AudioStreamGetProperty ( myStream, 0, kAudioStreamPropertyStartingChannel, &theSize, &theChannel );
	if ( theStatus == 0 )
		return theChannel;
	else
		return 0;
}

- (UInt32) numberChannels
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	int rv;
	MTCoreAudioStreamDescription * myDescription;
	
	myDescription = [self streamDescriptionForSide:kMTCoreAudioStreamLogicalSide];
	rv = [myDescription channelsPerFrame];

	[pool release];

	return rv;
}

- (NSString *) dataSource
{
	OSStatus theStatus;
	UInt32 theSize;
	UInt32 theSourceID;
	
	theSize = sizeof(UInt32);
	theStatus = AudioStreamGetProperty ( myStream, 0, kAudioDevicePropertyDataSource, &theSize, &theSourceID );
	if (theStatus == 0)
		return _DataSourceNameForID ( myStream, theSourceID );
	return nil;
}

// NSArray of NSStrings
- (NSArray *)  dataSources
{
	OSStatus theStatus;
	UInt32 theSize;
	UInt32 * theSourceIDs;
	UInt32 numSources;
	UInt32 x;
	NSMutableArray * rv = [NSMutableArray array];
	
	theStatus = AudioStreamGetPropertyInfo ( myStream, 0, kAudioDevicePropertyDataSources, &theSize, NULL );
	if (theStatus != 0)
		return rv;
	theSourceIDs = (UInt32 *) malloc ( theSize );
	numSources = theSize / sizeof(UInt32);
	theStatus = AudioStreamGetProperty ( myStream, 0, kAudioDevicePropertyDataSources, &theSize, theSourceIDs );
	if (theStatus != 0)
	{
		free(theSourceIDs);
		return rv;
	}
	for ( x = 0; x < numSources; x++ )
		[rv addObject:_DataSourceNameForID ( myStream, theSourceIDs[x] )];
	free(theSourceIDs);
	return rv;
}

- (Boolean)    canSetDataSource
{
	OSStatus theStatus;
	UInt32 theSize;
	Boolean rv;
	
	theSize = sizeof(UInt32);
	theStatus = AudioStreamGetPropertyInfo ( myStream, 0, kAudioDevicePropertyDataSource, &theSize, &rv );
	if ( 0 == theStatus )
		return rv;
	else
	{
		return NO;
	}
}

- (void)       setDataSource:(NSString *)theSource
{
	OSStatus theStatus;
	UInt32 theSize;
	UInt32 * theSourceIDs;
	UInt32 numSources;
	UInt32 x;
	
	if ( theSource == nil )
		return;
	
	theStatus = AudioStreamGetPropertyInfo ( myStream, 0, kAudioDevicePropertyDataSources, &theSize, NULL );
	if (theStatus != 0)
		return;
	theSourceIDs = (UInt32 *) malloc ( theSize );
	numSources = theSize / sizeof(UInt32);
	theStatus = AudioStreamGetProperty ( myStream, 0, kAudioDevicePropertyDataSources, &theSize, theSourceIDs );
	if (theStatus != 0)
	{
		free(theSourceIDs);
		return;
	}
	
	theSize = sizeof(UInt32);
	for ( x = 0; x < numSources; x++ )
	{
		if ( [theSource compare:_DataSourceNameForID ( myStream, theSourceIDs[x] )] == NSOrderedSame )
			(void) AudioStreamSetProperty ( myStream, NULL, 0, kAudioDevicePropertyDataSource, theSize, &theSourceIDs[x] );
	}
	free(theSourceIDs);
}

- (NSString *) clockSource
{
	OSStatus theStatus;
	UInt32 theSize;
	UInt32 theSourceID;
	
	theSize = sizeof(UInt32);
	theStatus = AudioStreamGetProperty ( myStream, 0, kAudioDevicePropertyClockSource, &theSize, &theSourceID );
	if (theStatus == 0)
		return _ClockSourceNameForID ( myStream, theSourceID );
	return nil;
}

- (NSArray *)  clockSources
{
	OSStatus theStatus;
	UInt32 theSize;
	UInt32 * theSourceIDs;
	UInt32 numSources;
	UInt32 x;
	NSMutableArray * rv;
	
	theStatus = AudioStreamGetPropertyInfo ( myStream, 0, kAudioDevicePropertyClockSources, &theSize, NULL );
	if (theStatus != 0)
		return nil;
	theSourceIDs = (UInt32 *) malloc ( theSize );
	numSources = theSize / sizeof(UInt32);
	theStatus = AudioStreamGetProperty ( myStream, 0, kAudioDevicePropertyClockSources, &theSize, theSourceIDs );
	if (theStatus != 0)
	{
		free(theSourceIDs);
		return nil;
	}
	rv = [NSMutableArray arrayWithCapacity:numSources];
	for ( x = 0; x < numSources; x++ )
		[rv addObject:_ClockSourceNameForID ( myStream, theSourceIDs[x] )];
	free(theSourceIDs);
	return rv;
}

- (void)       setClockSource:(NSString *)theSource
{
	OSStatus theStatus;
	UInt32 theSize;
	UInt32 * theSourceIDs;
	UInt32 numSources;
	UInt32 x;

	if ( theSource == nil )
		return;
	
	theStatus = AudioStreamGetPropertyInfo ( myStream, 0, kAudioDevicePropertyClockSources, &theSize, NULL );
	if (theStatus != 0)
		return;
	theSourceIDs = (UInt32 *) malloc ( theSize );
	numSources = theSize / sizeof(UInt32);
	theStatus = AudioStreamGetProperty ( myStream, 0, kAudioDevicePropertyClockSources, &theSize, theSourceIDs );
	if (theStatus != 0)
	{
		free(theSourceIDs);
		return;
	}
	
	theSize = sizeof(UInt32);
	for ( x = 0; x < numSources; x++ )
	{
		if ( [theSource compare:_ClockSourceNameForID ( myStream, theSourceIDs[x] )] == NSOrderedSame )
			(void) AudioStreamSetProperty ( myStream, NULL, 0, kAudioDevicePropertyClockSource, theSize, &theSourceIDs[x] );
	}
	free(theSourceIDs);
}

- (MTCoreAudioStreamDescription *) streamDescriptionForSide:(MTCoreAudioStreamSide)theSide
{
	OSStatus theStatus;
	UInt32 theSize;
	AudioStreamBasicDescription theDescription;
	UInt32 theProperty;
	
	if (theSide == kMTCoreAudioStreamPhysicalSide)
		theProperty = kAudioStreamPropertyPhysicalFormat;
	else
		theProperty = kAudioDevicePropertyStreamFormat;
	
	theSize = sizeof(AudioStreamBasicDescription);
	theStatus = AudioStreamGetProperty ( myStream, 0, theProperty, &theSize, &theDescription );
	if (theStatus == 0)
	{
		return [[parentAudioDevice streamDescriptionFactory] streamDescriptionWithAudioStreamBasicDescription:theDescription];
	}
	return nil;
}

// NSArray of MTCoreAudioStreamDescriptions
- (NSArray *) streamDescriptionsForSide:(MTCoreAudioStreamSide)theSide
{
	OSStatus theStatus;
	UInt32 theSize;
	UInt32 numItems;
	UInt32 x;
	AudioStreamBasicDescription * descriptionArray;
	NSMutableArray * rv;
	UInt32 theProperty;
	
	if (theSide == kMTCoreAudioStreamPhysicalSide)
		theProperty = kAudioStreamPropertyPhysicalFormats;
	else
		theProperty = kAudioDevicePropertyStreamFormats;

	rv = [NSMutableArray arrayWithCapacity:1];
	
	theStatus = AudioStreamGetPropertyInfo ( myStream, 0, theProperty, &theSize, NULL );
	if (theStatus != 0)
		return rv;
	
	descriptionArray = (AudioStreamBasicDescription *) malloc ( theSize );
	numItems = theSize / sizeof(AudioStreamBasicDescription);
	theStatus = AudioStreamGetProperty ( myStream, 0, theProperty, &theSize, descriptionArray );
	if (theStatus != 0)
	{
		free(descriptionArray);
		return rv;
	}
	
	for ( x = 0; x < numItems; x++ )
		[rv addObject:[[parentAudioDevice streamDescriptionFactory] streamDescriptionWithAudioStreamBasicDescription:descriptionArray[x]]];

	free(descriptionArray);
	return rv;
}

- (Boolean) setStreamDescription:(MTCoreAudioStreamDescription *)theDescription forSide:(MTCoreAudioStreamSide)theSide
{
	OSStatus theStatus;
	UInt32 theSize;
	AudioStreamBasicDescription theASBasicDescription;
	UInt32 theProperty;
	
	if (theSide == kMTCoreAudioStreamPhysicalSide)
		theProperty = kAudioStreamPropertyPhysicalFormat;
	else
		theProperty = kAudioDevicePropertyStreamFormat;

	
	theASBasicDescription = [theDescription audioStreamBasicDescription];
	theSize = sizeof(AudioStreamBasicDescription);
	
	theStatus = AudioStreamSetProperty ( myStream, NULL, 0, theProperty, theSize, &theASBasicDescription );
	if (theStatus != 0)
		printf ("MTCoreAudioStream setStreamDescription:forSide: failed, got %4.4s\n", (char *)&theStatus );
	return (theStatus == 0);
}

- (MTCoreAudioStreamDescription *) matchStreamDescription:(MTCoreAudioStreamDescription *)theDescription forSide:(MTCoreAudioStreamSide)theSide
{
	OSStatus theStatus;
	UInt32 theSize;
	AudioStreamBasicDescription theASBasicDescription;
	UInt32 theMatchProperty;
	
	if (theSide == kMTCoreAudioStreamPhysicalSide)
	{
		theMatchProperty = kAudioStreamPropertyPhysicalFormatMatch;
	}
	else
	{
		theMatchProperty = kAudioDevicePropertyStreamFormatMatch;
	}
		
	theASBasicDescription = [theDescription audioStreamBasicDescription];
	theSize = sizeof(AudioStreamBasicDescription);
	
	theStatus = AudioStreamGetProperty ( myStream, 0, theMatchProperty, &theSize, &theASBasicDescription );
	if ( theStatus == 0 )
	{
		return [[parentAudioDevice streamDescriptionFactory] streamDescriptionWithAudioStreamBasicDescription:theASBasicDescription];
	}

	return nil;
}

- (MTCoreAudioVolumeInfo) volumeInfoForChannel:(UInt32)theChannel
{
	OSStatus theStatus;
	MTCoreAudioVolumeInfo rv;
	UInt32 theSize;
	UInt32 tmpBool32;
	
	rv.hasVolume = false;
	rv.canMute = false;
	rv.canPlayThru = false;
	rv.theVolume = 0.0;
	rv.isMuted = false;
	rv.playThruIsSet = false;
	
	theStatus = AudioStreamGetPropertyInfo ( myStream, theChannel, kAudioDevicePropertyVolumeScalar, &theSize, &rv.canSetVolume );
	if (noErr == theStatus)
	{
		rv.hasVolume = true;
		theStatus = AudioStreamGetProperty ( myStream, theChannel, kAudioDevicePropertyVolumeScalar, &theSize, &rv.theVolume );
		if (noErr != theStatus)
			rv.theVolume = 0.0;
	}
	
	theStatus = AudioStreamGetPropertyInfo ( myStream, theChannel, kAudioDevicePropertyMute, &theSize, &rv.canMute );
	if (noErr == theStatus)
	{
		theStatus = AudioStreamGetProperty ( myStream, theChannel, kAudioDevicePropertyMute, &theSize, &tmpBool32 );
		if (noErr == theStatus)
			rv.isMuted = tmpBool32;
	}
	
	theStatus = AudioStreamGetPropertyInfo ( myStream, theChannel, kAudioDevicePropertyPlayThru, &theSize, &rv.canPlayThru );
	if (noErr == theStatus)
	{
		theStatus = AudioStreamGetProperty ( myStream, theChannel, kAudioDevicePropertyPlayThru, &theSize, &tmpBool32 );
		if (noErr == theStatus)
			rv.playThruIsSet = tmpBool32;
	}
	
	return rv;
}

- (Float32) volumeForChannel:(UInt32)theChannel
{
	OSStatus theStatus;
	UInt32 theSize;
	Float32 theVolumeScalar;
	
	theSize = sizeof(Float32);
	theStatus = AudioStreamGetProperty ( myStream, theChannel, kAudioDevicePropertyVolumeScalar, &theSize, &theVolumeScalar );
	if (theStatus == 0)
		return theVolumeScalar;
	else
		return 0.0;
}

- (Float32) volumeInDecibelsForChannel:(UInt32)theChannel
{
	OSStatus theStatus;
	UInt32 theSize;
	Float32 theVolumeDecibels;
	
	theSize = sizeof(Float32);
	theStatus = AudioStreamGetProperty ( myStream, theChannel, kAudioDevicePropertyVolumeDecibels, &theSize, &theVolumeDecibels );
	if (theStatus == 0)
		return theVolumeDecibels;
	else
		return 0.0;
}

- (void)    setVolume:(Float32)theVolume forChannel:(UInt32)theChannel
{
	OSStatus theStatus;
	UInt32 theSize;
	
	theSize = sizeof(Float32);
	theStatus = AudioStreamSetProperty ( myStream, NULL, theChannel, kAudioDevicePropertyVolumeScalar, theSize, &theVolume );
}

- (void)    setVolumeDecibels:(Float32)theVolumeDecibels forChannel:(UInt32)theChannel
{
	OSStatus theStatus;
	UInt32 theSize;
	
	theSize = sizeof(Float32);
	theStatus = AudioStreamSetProperty ( myStream, NULL, theChannel, kAudioDevicePropertyVolumeDecibels, theSize, &theVolumeDecibels );
}

- (Float32) volumeInDecibelsForVolume:(Float32)theVolume forChannel:(UInt32)theChannel
{
	OSStatus theStatus;
	UInt32 theSize;
	Float32 theVolumeDecibels;
	
	theSize = sizeof(Float32);
	theVolumeDecibels = theVolume;
	theStatus = AudioStreamGetProperty ( myStream, theChannel, kAudioDevicePropertyVolumeScalarToDecibels, &theSize, &theVolumeDecibels );
	if (theStatus == 0)
		return theVolumeDecibels;
	else
		return 0.0;
}

- (Float32) volumeForVolumeInDecibels:(Float32)theVolumeDecibels forChannel:(UInt32)theChannel
{
	OSStatus theStatus;
	UInt32 theSize;
	Float32 theVolume;
	
	theSize = sizeof(Float32);
	theVolume = theVolumeDecibels;
	theStatus = AudioStreamGetProperty ( myStream, theChannel, kAudioDevicePropertyVolumeDecibelsToScalar, &theSize, &theVolume );
	if (theStatus == 0)
		return theVolume;
	else
		return 0.0;
}

- (void)    setMute:(BOOL)isMuted forChannel:(UInt32)theChannel
{
	OSStatus theStatus;
	UInt32 theSize;
	UInt32 theMuteVal;
	
	theSize = sizeof(UInt32);
	if (isMuted) theMuteVal = 1; else theMuteVal = 0;
	theStatus = AudioStreamSetProperty ( myStream, NULL, theChannel, kAudioDevicePropertyMute, theSize, &theMuteVal );
}

- (void)    setPlayThru:(BOOL)isPlayingThru forChannel:(UInt32)theChannel
{
	OSStatus theStatus;
	UInt32 theSize;
	UInt32 thePlayThruVal;
	
	theSize = sizeof(UInt32);
	if (isPlayingThru) thePlayThruVal = 1; else thePlayThruVal = 0;
	theStatus = AudioStreamSetProperty ( myStream, NULL, theChannel, kAudioDevicePropertyPlayThru, theSize, &thePlayThruVal );
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:_MTCoreAudioStreamNotification object:nil];
}


@end
