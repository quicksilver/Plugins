//
//  MTCoreAudioDevice.m
//  MTCoreAudio.framework
//
//  Created by Michael Thornburgh on Sun Dec 16 2001.
//  Copyright (c) 2001 Michael Thornburgh. All rights reserved.
//

#import "MTCoreAudioStreamDescription.h"
#import "MTCoreAudioTypes.h"
#import "MTCoreAudioStream.h"
#import "MTCoreAudioDevice.h"
#import "MTCoreAudioDevicePrivateAdditions.h"
#import "MTCoreAudioIOProcMux.h"

// define some methods that are deprecated, but we still need to be able to call
// for backwards compatibility
@interface NSObject(MTCoreAudioDeprecatedMethods)
- (void) audioDeviceSourceDidChange:(MTCoreAudioDevice *)theDevice forChannel:(UInt32)theChannel forDirection:(MTCoreAudioDirection)theDirection;
@end


static NSString * _MTCoreAudioDeviceNotification = @"_MTCoreAudioDeviceNotification";
static NSString * _MTCoreAudioDeviceIDKey = @"DeviceID";
static NSString * _MTCoreAudioChannelKey = @"Channel";
static NSString * _MTCoreAudioDirectionKey = @"Direction";
static NSString * _MTCoreAudioPropertyIDKey = @"PropertyID";

NSString * MTCoreAudioHardwareDeviceListDidChangeNotification = @"MTCoreAudioHardwareDeviceListDidChangeNotification";
NSString * MTCoreAudioHardwareDefaultInputDeviceDidChangeNotification = @"MTCoreAudioHardwareDefaultInputDeviceDidChangeNotification";
NSString * MTCoreAudioHardwareDefaultOutputDeviceDidChangeNotification = @"MTCoreAudioHardwareDefaultOutputDeviceDidChangeNotification";
NSString * MTCoreAudioHardwareDefaultSystemOutputDeviceDidChangeNotification = @"MTCoreAudioHardwareDefaultSystemOutputDeviceDidChangeNotification";

static id _MTCoreAudioHardwareDelegate;


static OSStatus _MTCoreAudioHardwarePropertyListener (
	AudioHardwarePropertyID inPropertyID,
	void * inClientData
)
{
	NSAutoreleasePool * pool;
	SEL delegateSelector;
	NSString * notificationName = nil;
	
	switch (inPropertyID)
	{
		case kAudioHardwarePropertyDevices:
			delegateSelector = @selector(audioHardwareDeviceListDidChange);
			notificationName = MTCoreAudioHardwareDeviceListDidChangeNotification;
			break;
		case kAudioHardwarePropertyDefaultInputDevice:
			delegateSelector = @selector(audioHardwareDefaultInputDeviceDidChange);
			notificationName = MTCoreAudioHardwareDefaultInputDeviceDidChangeNotification;
			break;
		case kAudioHardwarePropertyDefaultOutputDevice:
			delegateSelector = @selector(audioHardwareDefaultOutputDeviceDidChange);
			notificationName = MTCoreAudioHardwareDefaultOutputDeviceDidChangeNotification;
			break;
		case kAudioHardwarePropertyDefaultSystemOutputDevice:
			delegateSelector = @selector(audioHardwareDefaultSystemOutputDeviceDidChange);
			notificationName = MTCoreAudioHardwareDefaultSystemOutputDeviceDidChangeNotification;
			break;
		
		default:
			return 0; // unknown notification, do nothing
	}
	
	pool = [[NSAutoreleasePool alloc] init];
	
	if ( _MTCoreAudioHardwareDelegate )
	{
		if ([_MTCoreAudioHardwareDelegate respondsToSelector:delegateSelector])
			[_MTCoreAudioHardwareDelegate performSelector:delegateSelector];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];

	[pool release];

	return 0;
}

static OSStatus _MTCoreAudioDevicePropertyListener (
	AudioDeviceID inDevice,
	UInt32 inChannel,
	Boolean isInput,
	AudioDevicePropertyID inPropertyID,
	void * inClientData
)
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	NSMutableDictionary * notificationUserInfo = [NSMutableDictionary dictionaryWithCapacity:4];
	
	[notificationUserInfo setObject:[NSNumber numberWithUnsignedLong:inDevice] forKey:_MTCoreAudioDeviceIDKey];
	[notificationUserInfo setObject:[NSNumber numberWithUnsignedLong:inChannel] forKey:_MTCoreAudioChannelKey];
	[notificationUserInfo setObject:[NSNumber numberWithBool:isInput] forKey:_MTCoreAudioDirectionKey];
	[notificationUserInfo setObject:[NSNumber numberWithUnsignedLong:inPropertyID] forKey:_MTCoreAudioPropertyIDKey];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:_MTCoreAudioDeviceNotification object:nil userInfo:notificationUserInfo];
	
	[pool release];
	
	return 0;
}

static NSString * _DataSourceNameForID ( AudioDeviceID theDeviceID, MTCoreAudioDirection theDirection, UInt32 theChannel, UInt32 theDataSourceID )
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
	theStatus = AudioDeviceGetProperty ( theDeviceID, theChannel, theDirection, kAudioDevicePropertyDataSourceNameForIDCFString, &theSize, &theTranslation );
	if (( theStatus == 0 ) && theCFString )
	{
		rv = [NSString stringWithString:(NSString *)theCFString];
		CFRelease ( theCFString );
		return rv;
	}

	return nil;
}

static NSString * _ClockSourceNameForID ( AudioDeviceID theDeviceID, MTCoreAudioDirection theDirection, UInt32 theChannel, UInt32 theClockSourceID )
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
	theStatus = AudioDeviceGetProperty ( theDeviceID, theChannel, theDirection, kAudioDevicePropertyClockSourceNameForIDCFString, &theSize, &theTranslation );
	if (( theStatus == 0 ) && theCFString )
	{
		rv = [NSString stringWithString:(NSString *)theCFString];
		CFRelease ( theCFString );
		return rv;
	}

	return nil;
}



@implementation MTCoreAudioDevice

// startup stuff
+ (void) load
{
	_MTCoreAudioHardwareDelegate = nil;
	AudioHardwareAddPropertyListener ( kAudioPropertyWildcardPropertyID, _MTCoreAudioHardwarePropertyListener, NULL );
}

+ (NSArray *) allDevices
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	NSMutableArray * theArray;
	UInt32 theSize;
	OSStatus theStatus;
	int numDevices;
	int x;
	AudioDeviceID * deviceList;
	MTCoreAudioDevice * tmpDevice;
	
	theStatus = AudioHardwareGetPropertyInfo ( kAudioHardwarePropertyDevices, &theSize, NULL );
	if (theStatus != 0)
		return nil;
	numDevices = theSize / sizeof(AudioDeviceID);
	deviceList = (AudioDeviceID *) malloc ( theSize );
	if (deviceList == NULL)
		return nil;
	theStatus = AudioHardwareGetProperty ( kAudioHardwarePropertyDevices, &theSize, deviceList );
	if (theStatus != 0)
	{
		free(deviceList);
		return nil;
	}
	
	theArray = [[NSMutableArray alloc] initWithCapacity:numDevices];
	for ( x = 0; x < numDevices; x++ )
	{
		tmpDevice = [[[self class] alloc] initWithDeviceID:deviceList[x]];
		[theArray addObject:tmpDevice];
		[tmpDevice release];
	}
	free(deviceList);
	
	[theArray sortUsingSelector:@selector(_compare:)];
	
	[pool release];

	[theArray autorelease];
	return theArray;
}

+ (NSArray *)		allDevicesByRelation
{
	NSMutableSet * coveredDeviceSet = [NSMutableSet set];
	NSEnumerator * deviceEnumerator = [[[self class] allDevices] objectEnumerator];
	MTCoreAudioDevice * whichDevice;
	NSArray * relatedDevices;
	NSMutableArray * rv = [NSMutableArray array];
	
	while ( whichDevice = [deviceEnumerator nextObject] )
	{
		if ( ! [coveredDeviceSet containsObject:whichDevice] )
		{
			relatedDevices = [whichDevice relatedDevices];
			[rv addObject:relatedDevices];
			[coveredDeviceSet addObjectsFromArray:relatedDevices];
		}
	}
	return rv;
}

+ (NSArray *) devicesWithName:(NSString *)theName havingStreamsForDirection:(MTCoreAudioDirection)theDirection
{
	NSEnumerator * deviceEnumerator = [[self allDevices] objectEnumerator];
	NSMutableArray * rv = [NSMutableArray array];
	MTCoreAudioDevice * aDevice;
	
	while ( aDevice = [deviceEnumerator nextObject] )
	{
		if ( [theName isEqual:[aDevice deviceName]] && ( [aDevice channelsForDirection:theDirection] > 0 ))
		{
			[rv addObject:aDevice];
		}
	}
	return rv;
}

+ (MTCoreAudioDevice *) deviceWithID:(AudioDeviceID)theID
{
	return [[[[self class] alloc] initWithDeviceID:theID] autorelease];
}

+ (MTCoreAudioDevice *) deviceWithUID:(NSString *)theUID
{
	OSStatus theStatus;
	UInt32 theSize;
	AudioValueTranslation theTranslation;
	CFStringRef theCFString;
	unichar * theCharacters;
	AudioDeviceID theID;
	MTCoreAudioDevice * rv = nil;
	
	theCharacters = (unichar *) malloc ( sizeof(unichar) * [theUID length] );
	[theUID getCharacters:theCharacters];
	
	theCFString = CFStringCreateWithCharactersNoCopy ( NULL, theCharacters, [theUID length], kCFAllocatorNull );
	
	theTranslation.mInputData = &theCFString;
	theTranslation.mInputDataSize = sizeof(CFStringRef);
	theTranslation.mOutputData = &theID;
	theTranslation.mOutputDataSize = sizeof(AudioDeviceID);
	theSize = sizeof(AudioValueTranslation);
	theStatus = AudioHardwareGetProperty ( kAudioHardwarePropertyDeviceForUID, &theSize, &theTranslation );
	CFRelease ( theCFString );
	free ( theCharacters );
	if (theStatus == 0)
		rv = [[self class] deviceWithID:theID];
	if ( [theUID isEqual:[rv deviceUID]] )
		return rv;
	return nil;
}

+ (MTCoreAudioDevice *) _defaultDevice:(int)whichDevice
{
	OSStatus theStatus;
	UInt32 theSize;
	AudioDeviceID theID;
	
	theSize = sizeof(AudioDeviceID);

	theStatus = AudioHardwareGetProperty ( whichDevice, &theSize, &theID );
	if (theStatus == 0)
		return [[self class] deviceWithID:theID];
	return nil;
}

+ (MTCoreAudioDevice *) defaultInputDevice
{
	return [[self class] _defaultDevice:kAudioHardwarePropertyDefaultInputDevice];
}

+ (MTCoreAudioDevice *) defaultOutputDevice
{
	return [[self class] _defaultDevice:kAudioHardwarePropertyDefaultOutputDevice];
}

+ (MTCoreAudioDevice *) defaultSystemOutputDevice
{
	return [[self class] _defaultDevice:kAudioHardwarePropertyDefaultSystemOutputDevice];
}

- init // head off -new and bad usage
{
	[self dealloc];
	return nil;
}

- (MTCoreAudioDevice *) initWithDeviceID:(AudioDeviceID)theID
{
	[super init];
	myStreams[0] = myStreams[1] = nil;
	streamsDirty[0] = streamsDirty[1] = true;
	myDevice = theID;
	myDelegate = nil;
	myIOProc = NULL;
	return self;
}

- (MTCoreAudioDevice *) clone
{
	return [[self class] deviceWithID:[self deviceID]];
}

- (NSArray *) relatedDevices
{
	OSStatus theStatus;
	UInt32 theSize;
	UInt32 numDevices;
	AudioDeviceID * deviceList = NULL;
	MTCoreAudioDevice * tmpDevice;
	NSMutableArray * rv = [NSMutableArray arrayWithObject:self];
	UInt32 x;
	
	theStatus = AudioDeviceGetPropertyInfo ( myDevice, 0, 0, kAudioDevicePropertyRelatedDevices, &theSize, NULL );
	if (theStatus != 0)
		goto finish;
	deviceList = (AudioDeviceID *) malloc ( theSize );
	numDevices = theSize / sizeof(AudioDeviceID);
	theStatus = AudioDeviceGetProperty ( myDevice, 0, 0, kAudioDevicePropertyRelatedDevices, &theSize, deviceList );
	if (theStatus != 0)
	{
		goto finish;
	}

	for ( x = 0; x < numDevices; x++ )
	{
		tmpDevice = [[self class] deviceWithID:deviceList[x]];
		if ( ! [self isEqual:tmpDevice] )
		{
			[rv addObject:tmpDevice];
		}
	}

	finish:
	
	if ( deviceList )
		free(deviceList);
	
	[rv sortUsingSelector:@selector(_compare:)];
	
	return rv;
}

- (AudioDeviceID) deviceID
{
	return myDevice;
}

- (NSString *) deviceName
{
	OSStatus theStatus;
	CFStringRef theCFString;
	NSString * rv;
	UInt32 theSize;
	
	theSize = sizeof ( CFStringRef );
	theStatus = AudioDeviceGetProperty ( myDevice, 0, false, kAudioDevicePropertyDeviceNameCFString, &theSize, &theCFString );
	if ( theStatus != 0 || theCFString == NULL )
		return nil;
	rv = [NSString stringWithString:(NSString *)theCFString];
	CFRelease ( theCFString );
	return rv;
}

- (NSString *) description
{
	return [NSString stringWithFormat:@"<%@: %p id %d> %@", [self className], self, [self deviceID], [self deviceName]];
}

- (NSString *) deviceUID
{
	OSStatus theStatus;
	CFStringRef theCFString;
	NSString * rv;
	UInt32 theSize;
	
	theSize = sizeof ( CFStringRef );
	theStatus = AudioDeviceGetProperty ( myDevice, 0, false, kAudioDevicePropertyDeviceUID, &theSize, &theCFString );
	if ( theStatus != 0 || theCFString == NULL )
		return nil;
	rv = [NSString stringWithString:(NSString *)theCFString];
	CFRelease ( theCFString );
	return rv;
}

- (NSString *) deviceManufacturer
{
	OSStatus theStatus;
	CFStringRef theCFString;
	NSString * rv;
	UInt32 theSize;
	
	theSize = sizeof ( CFStringRef );
	theStatus = AudioDeviceGetProperty ( myDevice, 0, false, kAudioDevicePropertyDeviceManufacturerCFString, &theSize, &theCFString );
	if ( theStatus != 0 || theCFString == NULL )
		return nil;
	rv = [NSString stringWithString:(NSString *)theCFString];
	CFRelease ( theCFString );
	return rv;
}

- (NSComparisonResult) _compare:(MTCoreAudioDevice *)other
{
	NSString * myName, *myUID;
	NSComparisonResult rv;
	
	myName = [self deviceName];
	if ( myName == nil )
		return NSOrderedDescending; // dead devices to the back of the bus!
	rv = [myName compare:[other deviceName]];
	if ( rv != NSOrderedSame )
		return rv;
	
	myUID = [self deviceUID];
	if ( myUID == nil )
		return NSOrderedDescending;
	return [myUID compare:[other deviceUID]];
}

- (BOOL) isEqual:(id)other
{
	if ( [other respondsToSelector:@selector(deviceID)] )
	{
		if ( [self deviceID] == [other deviceID] )
		{
			return YES;
		}
	}
	return NO;
}

- (unsigned) hash
{
	return ((unsigned)[self deviceID]);
}

+ (void) setDelegate:(id)theDelegate
{
	_MTCoreAudioHardwareDelegate = theDelegate;
}

+ (id) delegate
{
	return _MTCoreAudioHardwareDelegate;
}

+ (void) attachNotificationsToThisThread
{
	CFRunLoopRef theRunLoop = CFRunLoopGetCurrent();
	AudioHardwareSetProperty ( kAudioHardwarePropertyRunLoop, sizeof(CFRunLoopRef), &theRunLoop );
}

- (void) _dispatchDeviceNotification:(NSNotification *)theNotification
{
	NSDictionary * theUserInfo = [theNotification userInfo];
	AudioDeviceID theDeviceID;
	MTCoreAudioDirection theDirection;
	UInt32 theChannel;
	AudioDevicePropertyID thePropertyID;
	BOOL hasVolumeInfoDidChangeMethod = false;
	
	theDeviceID = [[theUserInfo objectForKey:_MTCoreAudioDeviceIDKey] unsignedLongValue];

	if (myDelegate && (theDeviceID == myDevice))
	{
		theDirection = ( [[theUserInfo objectForKey:_MTCoreAudioDirectionKey] boolValue] ) ? kMTCoreAudioDeviceRecordDirection : kMTCoreAudioDevicePlaybackDirection ;
		theChannel = [[theUserInfo objectForKey:_MTCoreAudioChannelKey] unsignedLongValue];
		thePropertyID = [[theUserInfo objectForKey:_MTCoreAudioPropertyIDKey] unsignedLongValue];
				
		switch (thePropertyID)
		{
			case kAudioDevicePropertyVolumeScalar:
			case kAudioDevicePropertyVolumeDecibels:
			case kAudioDevicePropertyMute:
			case kAudioDevicePropertyPlayThru:
				if ([myDelegate respondsToSelector:@selector(audioDeviceVolumeInfoDidChange:forChannel:forDirection:)])
					hasVolumeInfoDidChangeMethod = true;
				else
					hasVolumeInfoDidChangeMethod = false;
			break;
		}
		
		switch (thePropertyID)
		{
			case kAudioDevicePropertyDeviceIsAlive:
				if ([myDelegate respondsToSelector:@selector(audioDeviceDidDie:)])
					[myDelegate audioDeviceDidDie:self];
				break;
			case kAudioDeviceProcessorOverload:
				if ([myDelegate respondsToSelector:@selector(audioDeviceDidOverload:)])
					[myDelegate audioDeviceDidOverload:self];
				break;
			case kAudioDevicePropertyDeviceHasChanged:
				if ([myDelegate respondsToSelector:@selector(audioDeviceSomethingDidChange:)])
					[myDelegate audioDeviceSomethingDidChange:self];
				break;
			case kAudioDevicePropertyBufferFrameSize:
			case kAudioDevicePropertyUsesVariableBufferFrameSizes:
				if ([myDelegate respondsToSelector:@selector(audioDeviceBufferSizeInFramesDidChange:)])
					[myDelegate audioDeviceBufferSizeInFramesDidChange:self];
				break;
			case kAudioDevicePropertyStreams:
				if (theDirection == kMTCoreAudioDevicePlaybackDirection)
					streamsDirty[0] = true;
				else
					streamsDirty[1] = true;
				if ([myDelegate respondsToSelector:@selector(audioDeviceStreamsListDidChange:)])
					[myDelegate audioDeviceStreamsListDidChange:self];
				break;
			case kAudioDevicePropertyStreamConfiguration:
				if ([myDelegate respondsToSelector:@selector(audioDeviceChannelsByStreamDidChange:forDirection:)])
					[myDelegate audioDeviceChannelsByStreamDidChange:self forDirection:theDirection];
				break;
			case kAudioDevicePropertyStreamFormat:
				if ([myDelegate respondsToSelector:@selector(audioDeviceStreamDescriptionDidChange:forChannel:forDirection:)])
					[myDelegate audioDeviceStreamDescriptionDidChange:self forChannel:theChannel forDirection:theDirection];
				break;
			case kAudioDevicePropertyNominalSampleRate:
				if (0 == theChannel && [myDelegate respondsToSelector:@selector(audioDeviceNominalSampleRateDidChange:)])
					[myDelegate audioDeviceNominalSampleRateDidChange:self];
				break;
			case kAudioDevicePropertyAvailableNominalSampleRates:
				if (0 == theChannel && [myDelegate respondsToSelector:@selector(audioDeviceNominalSampleRatesDidChange:)])
					[myDelegate audioDeviceNominalSampleRatesDidChange:self];
				break;
			case kAudioDevicePropertyVolumeScalar:
			// case kAudioDevicePropertyVolumeDecibels:
				if ([myDelegate respondsToSelector:@selector(audioDeviceVolumeDidChange:forChannel:forDirection:)])
					[myDelegate audioDeviceVolumeDidChange:self forChannel:theChannel forDirection:theDirection];
				else if (hasVolumeInfoDidChangeMethod)
					[myDelegate audioDeviceVolumeInfoDidChange:self forChannel:theChannel forDirection:theDirection];
				break;
			case kAudioDevicePropertyMute:
				if ([myDelegate respondsToSelector:@selector(audioDeviceMuteDidChange:forChannel:forDirection:)])
					[myDelegate audioDeviceMuteDidChange:self forChannel:theChannel forDirection:theDirection];
				else if (hasVolumeInfoDidChangeMethod)
					[myDelegate audioDeviceVolumeInfoDidChange:self forChannel:theChannel forDirection:theDirection];
				break;
			case kAudioDevicePropertyPlayThru:
				if ([myDelegate respondsToSelector:@selector(audioDevicePlayThruDidChange:forChannel:forDirection:)])
					[myDelegate audioDevicePlayThruDidChange:self forChannel:theChannel forDirection:theDirection];
				else if (hasVolumeInfoDidChangeMethod)
					[myDelegate audioDeviceVolumeInfoDidChange:self forChannel:theChannel forDirection:theDirection];
				break;
			case kAudioDevicePropertyDataSource:
				if (theChannel != 0)
				{
					NSLog ( @"MTCoreAudioDevice kAudioDevicePropertyDataSource theChannel != 0" );
				}
				if ([myDelegate respondsToSelector:@selector(audioDeviceSourceDidChange:forDirection:)])
					[myDelegate audioDeviceSourceDidChange:self forDirection:theDirection];
				else if ([myDelegate respondsToSelector:@selector(audioDeviceSourceDidChange:forChannel:forDirection:)])
				{
					NSLog ( @"MTCoreAudio: delegate method -audioDeviceSourceDidChange:forChannel:forDirection: is deprecated, use audioDeviceSourceDidChange:forDirection:" );
					[myDelegate audioDeviceSourceDidChange:self forChannel:theChannel forDirection:theDirection];
				}
				break;
			case kAudioDevicePropertyClockSource:
				if ([myDelegate respondsToSelector:@selector(audioDeviceClockSourceDidChange:forChannel:forDirection:)])
					[myDelegate audioDeviceClockSourceDidChange:self forChannel:theChannel forDirection:theDirection];
				break;
		}
	}
}

- (void) setDelegate:(id)theDelegate
{
	id oldDelegate = myDelegate;
	
	myDelegate = theDelegate;
	if (myDelegate && (oldDelegate == nil ))  // setting a delegate for the first time
	{
		AudioDeviceAddPropertyListener ( myDevice, kAudioPropertyWildcardChannel, kAudioPropertyWildcardSection, kAudioPropertyWildcardPropertyID, _MTCoreAudioDevicePropertyListener, NULL );
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_dispatchDeviceNotification:) name:_MTCoreAudioDeviceNotification object:nil];
	}
	else if ((myDelegate == nil ) && oldDelegate )
	{
		[[NSNotificationCenter defaultCenter] removeObserver:self name:_MTCoreAudioDeviceNotification object:nil];
	}
}

- (id) delegate
{
	return myDelegate;
}

- (Class) streamFactory
{
	return [MTCoreAudioStream class];
}

// NSArray of MTCoreAudioStreams
- (NSArray *) streamsForDirection:(MTCoreAudioDirection)theDirection
{
	AudioStreamID * theStreamIDs;
	OSStatus theStatus;
	UInt32 theSize;
	UInt32 numStreams;
	MTCoreAudioStream * theStream;
	NSMutableArray * tmpArray;
	UInt32 x;
	int streamIndex;
	
	streamIndex = (theDirection == kMTCoreAudioDevicePlaybackDirection) ? 0 : 1 ;
	
	if ( ! streamsDirty[streamIndex] )
		return myStreams[streamIndex];
		
	if ( myStreams[streamIndex] )
		[myStreams[streamIndex] release];
	myStreams[streamIndex] = nil;
	
	theStatus = AudioDeviceGetPropertyInfo ( myDevice, 0, theDirection, kAudioDevicePropertyStreams, &theSize, NULL );
	if (theStatus != 0)
		return nil;
	theStreamIDs = (UInt32 *) malloc ( theSize );
	numStreams = theSize / sizeof(AudioStreamID);
	theStatus = AudioDeviceGetProperty ( myDevice, 0, theDirection, kAudioDevicePropertyStreams, &theSize, theStreamIDs );
	if (theStatus != 0)
	{
		free(theStreamIDs);
		return myStreams[streamIndex];
	}
	
	tmpArray = [[NSMutableArray alloc] initWithCapacity:numStreams];

	for ( x = 0; x < numStreams; x++ )
	{
		theStream = [[[self streamFactory] alloc] initWithStreamID:theStreamIDs[x] withOwningDevice:self];
		[tmpArray addObject:theStream];
		[theStream release]; // retained by _streams
	}
	free(theStreamIDs);
	myStreams[streamIndex] = tmpArray;
	streamsDirty[streamIndex] = false;
	return myStreams[streamIndex];

}

// backwards compatibility nastiness
- (NSString *) dataSourceForChannel:(UInt32)theChannel forDirection:(MTCoreAudioDirection)theDirection
{
	NSLog ( @"-[MTCoreAudioDevice dataSourceForChannel:forDirection:] is deprecated, use -dataSourceForDirection:]" );
	return [self dataSourceForDirection:theDirection];
}

- (NSArray *) dataSourcesForChannel:(UInt32)theChannel forDirection:(MTCoreAudioDirection)theDirection
{
	NSLog ( @"-[MTCoreAudioDevice dataSourcesForChannel:forDirection:] is deprecated, use -dataSourcesForDirection:]" );
	return [self dataSourcesForDirection:theDirection];
}

- (void) setDataSource:(NSString *)theSource forChannel:(UInt32)theChannel forDirection:(MTCoreAudioDirection)theDirection
{
	NSLog ( @"-[MTCoreAudioDevice setDataSource:forChannel:forDirection:] is deprecated, use -setDataSource:forDirection:]" );
	[self setDataSource:theSource forDirection:theDirection];
}

// real methods
- (NSString *) dataSourceForDirection:(MTCoreAudioDirection)theDirection
{
	OSStatus theStatus;
	UInt32 theSize;
	UInt32 theSourceID;
	
	theSize = sizeof(UInt32);
	theStatus = AudioDeviceGetProperty ( myDevice, 0, theDirection, kAudioDevicePropertyDataSource, &theSize, &theSourceID );
	if (theStatus == 0)
		return _DataSourceNameForID ( myDevice, theDirection, 0, theSourceID );
	return nil;
}

- (NSArray *) dataSourcesForDirection:(MTCoreAudioDirection)theDirection
{
	OSStatus theStatus;
	UInt32 theSize;
	UInt32 * theSourceIDs;
	UInt32 numSources;
	UInt32 x;
	NSMutableArray * rv = [NSMutableArray array];
	
	theStatus = AudioDeviceGetPropertyInfo ( myDevice, 0, theDirection, kAudioDevicePropertyDataSources, &theSize, NULL );
	if (theStatus != 0)
		return rv;
	theSourceIDs = (UInt32 *) malloc ( theSize );
	numSources = theSize / sizeof(UInt32);
	theStatus = AudioDeviceGetProperty ( myDevice, 0, theDirection, kAudioDevicePropertyDataSources, &theSize, theSourceIDs );
	if (theStatus != 0)
	{
		free(theSourceIDs);
		return rv;
	}
	for ( x = 0; x < numSources; x++ )
		[rv addObject:_DataSourceNameForID ( myDevice, theDirection, 0, theSourceIDs[x] )];
	free(theSourceIDs);
	return rv;
}

- (Boolean) canSetDataSourceForDirection:(MTCoreAudioDirection)theDirection
{
	OSStatus theStatus;
	UInt32 theSize;
	Boolean rv;
	
	theSize = sizeof(UInt32);
	theStatus = AudioDeviceGetPropertyInfo ( myDevice, 0, theDirection, kAudioDevicePropertyDataSource, &theSize, &rv );
	if ( 0 == theStatus )
		return rv;
	else
	{
		return NO;
	}
}

- (void) setDataSource:(NSString *)theSource forDirection:(MTCoreAudioDirection)theDirection
{
	OSStatus theStatus;
	UInt32 theSize;
	UInt32 * theSourceIDs;
	UInt32 numSources;
	UInt32 x;
	
	if ( theSource == nil )
		return;
	
	theStatus = AudioDeviceGetPropertyInfo ( myDevice, 0, theDirection, kAudioDevicePropertyDataSources, &theSize, NULL );
	if (theStatus != 0)
		return;
	theSourceIDs = (UInt32 *) malloc ( theSize );
	numSources = theSize / sizeof(UInt32);
	theStatus = AudioDeviceGetProperty ( myDevice, 0, theDirection, kAudioDevicePropertyDataSources, &theSize, theSourceIDs );
	if (theStatus != 0)
	{
		free(theSourceIDs);
		return;
	}
	
	theSize = sizeof(UInt32);
	for ( x = 0; x < numSources; x++ )
	{
		if ( [theSource compare:_DataSourceNameForID ( myDevice, theDirection, 0, theSourceIDs[x] )] == NSOrderedSame )
			(void) AudioDeviceSetProperty ( myDevice, NULL, 0, theDirection, kAudioDevicePropertyDataSource, theSize, &theSourceIDs[x] );
	}
	free(theSourceIDs);
}

- (NSString *) clockSourceForChannel:(UInt32)theChannel forDirection:(MTCoreAudioDirection)theDirection
{
	OSStatus theStatus;
	UInt32 theSize;
	UInt32 theSourceID;
	
	theSize = sizeof(UInt32);
	theStatus = AudioDeviceGetProperty ( myDevice, theChannel, theDirection, kAudioDevicePropertyClockSource, &theSize, &theSourceID );
	if (theStatus == 0)
		return _ClockSourceNameForID ( myDevice, theDirection, theChannel, theSourceID );
	return nil;
}

- (NSArray *)  clockSourcesForChannel:(UInt32)theChannel forDirection:(MTCoreAudioDirection)theDirection
{
	OSStatus theStatus;
	UInt32 theSize;
	UInt32 * theSourceIDs;
	UInt32 numSources;
	UInt32 x;
	NSMutableArray * rv;
	
	theStatus = AudioDeviceGetPropertyInfo ( myDevice, theChannel, theDirection, kAudioDevicePropertyClockSources, &theSize, NULL );
	if (theStatus != 0)
		return nil;
	theSourceIDs = (UInt32 *) malloc ( theSize );
	numSources = theSize / sizeof(UInt32);
	theStatus = AudioDeviceGetProperty ( myDevice, theChannel, theDirection, kAudioDevicePropertyClockSources, &theSize, theSourceIDs );
	if (theStatus != 0)
	{
		free(theSourceIDs);
		return nil;
	}
	rv = [NSMutableArray arrayWithCapacity:numSources];
	for ( x = 0; x < numSources; x++ )
		[rv addObject:_ClockSourceNameForID ( myDevice, theDirection, theChannel, theSourceIDs[x] )];
	free(theSourceIDs);
	return rv;
}

- (void)       setClockSource:(NSString *)theSource forChannel:(UInt32)theChannel forDirection:(MTCoreAudioDirection)theDirection
{
	OSStatus theStatus;
	UInt32 theSize;
	UInt32 * theSourceIDs;
	UInt32 numSources;
	UInt32 x;
	
	if ( theSource == nil )
		return;
	
	theStatus = AudioDeviceGetPropertyInfo ( myDevice, theChannel, theDirection, kAudioDevicePropertyClockSources, &theSize, NULL );
	if (theStatus != 0)
		return;
	theSourceIDs = (UInt32 *) malloc ( theSize );
	numSources = theSize / sizeof(UInt32);
	theStatus = AudioDeviceGetProperty ( myDevice, theChannel, theDirection, kAudioDevicePropertyClockSources, &theSize, theSourceIDs );
	if (theStatus != 0)
	{
		free(theSourceIDs);
		return;
	}
	
	theSize = sizeof(UInt32);
	for ( x = 0; x < numSources; x++ )
	{
		if ( [theSource compare:_ClockSourceNameForID ( myDevice, theDirection, theChannel, theSourceIDs[x] )] == NSOrderedSame )
			(void) AudioDeviceSetProperty ( myDevice, NULL, theChannel, theDirection, kAudioDevicePropertyClockSource, theSize, &theSourceIDs[x] );
	}
	free(theSourceIDs);
}

- (UInt32) deviceBufferSizeInFrames
{
	OSStatus theStatus;
	UInt32 theSize;
	UInt32 frameSize;
	
	theSize = sizeof(UInt32);
	theStatus = AudioDeviceGetProperty ( myDevice, 0, false, kAudioDevicePropertyBufferFrameSize, &theSize, &frameSize );
	return frameSize;
}

- (UInt32) deviceMaxVariableBufferSizeInFrames
{
	OSStatus theStatus;
	UInt32 theSize;
	UInt32 frameSize;
	
	theSize = sizeof(UInt32);
	theStatus = AudioDeviceGetProperty ( myDevice, 0, false, kAudioDevicePropertyUsesVariableBufferFrameSizes, &theSize, &frameSize );
	if ( noErr == theStatus )
		return frameSize;
	else
		return [self deviceBufferSizeInFrames];
}

- (UInt32) deviceMinBufferSizeInFrames
{
	OSStatus theStatus;
	UInt32 theSize;
	AudioValueRange theRange;
	
	theSize = sizeof(AudioValueRange);
	theStatus = AudioDeviceGetProperty ( myDevice, 0, false, kAudioDevicePropertyBufferFrameSizeRange, &theSize, &theRange );
	return (UInt32) theRange.mMinimum;
}

- (UInt32) deviceMaxBufferSizeInFrames
{
	OSStatus theStatus;
	UInt32 theSize;
	AudioValueRange theRange;
	
	theSize = sizeof(AudioValueRange);
	theStatus = AudioDeviceGetProperty ( myDevice, 0, false, kAudioDevicePropertyBufferFrameSizeRange, &theSize, &theRange );
	return (UInt32) theRange.mMaximum;
}

- (void) setDeviceBufferSizeInFrames:(UInt32)numFrames
{
	OSStatus theStatus;
	UInt32 theSize;

	theSize = sizeof(UInt32);
	theStatus = AudioDeviceSetProperty ( myDevice, NULL, 0, false, kAudioDevicePropertyBufferFrameSize, theSize, &numFrames );
}

- (UInt32) deviceLatencyFramesForDirection:(MTCoreAudioDirection)theDirection
{
	OSStatus theStatus;
	UInt32 theSize;
	UInt32 latencyFrames;
	
	theSize = sizeof(UInt32);
	theStatus = AudioDeviceGetProperty ( myDevice, 0, theDirection, kAudioDevicePropertyLatency, &theSize, &latencyFrames );
	return latencyFrames;
}

- (UInt32) deviceSafetyOffsetFramesForDirection:(MTCoreAudioDirection)theDirection
{
	OSStatus theStatus;
	UInt32 theSize;
	UInt32 safetyFrames;
	
	theSize = sizeof(UInt32);
	theStatus = AudioDeviceGetProperty ( myDevice, 0, theDirection, kAudioDevicePropertySafetyOffset, &theSize, &safetyFrames );
	return safetyFrames;
}

- (NSArray *) channelsByStreamForDirection:(MTCoreAudioDirection)theDirection
{
	OSStatus theStatus;
	UInt32 theSize;
	AudioBufferList * theList;
	NSMutableArray * rv;
	UInt32 x;
	
	rv = [NSMutableArray arrayWithCapacity:1];
	
	theStatus = AudioDeviceGetPropertyInfo ( myDevice, 0, theDirection, kAudioDevicePropertyStreamConfiguration, &theSize, NULL );
	if (theStatus != 0)
		return rv;
	
	theList = (AudioBufferList *) malloc ( theSize );
	theStatus = AudioDeviceGetProperty ( myDevice, 0, theDirection, kAudioDevicePropertyStreamConfiguration, &theSize, theList );
	if (theStatus != 0)
	{
		free(theList);
		return rv;
	}
	
	for ( x = 0; x < theList->mNumberBuffers; x++ )
	{
		[rv addObject:[NSNumber numberWithUnsignedLong:theList->mBuffers[x].mNumberChannels]];
	}
	free(theList);
	return rv;
}

- (UInt32) channelsForDirection:(MTCoreAudioDirection)theDirection
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	NSNumber * theNumberOfChannelsInThisStream;
	NSEnumerator * channelEnumerator;
	UInt32 rv;
	
	rv = 0;
	
	channelEnumerator = [[self channelsByStreamForDirection:theDirection] objectEnumerator];
	while ( theNumberOfChannelsInThisStream = [channelEnumerator nextObject] )
		rv += [theNumberOfChannelsInThisStream unsignedLongValue];
	[pool release];
	return rv;
}

- (MTCoreAudioVolumeInfo) volumeInfoForChannel:(UInt32)theChannel forDirection:(MTCoreAudioDirection)theDirection
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
	
	theStatus = AudioDeviceGetPropertyInfo ( myDevice, theChannel, theDirection, kAudioDevicePropertyVolumeScalar, &theSize, &rv.canSetVolume );
	if (noErr == theStatus)
	{
		rv.hasVolume = true;
		theStatus = AudioDeviceGetProperty ( myDevice, theChannel, theDirection, kAudioDevicePropertyVolumeScalar, &theSize, &rv.theVolume );
		if (noErr != theStatus)
			rv.theVolume = 0.0;
	}
	
	theStatus = AudioDeviceGetPropertyInfo ( myDevice, theChannel, theDirection, kAudioDevicePropertyMute, &theSize, &rv.canMute );
	if (theStatus == 0)
	{
		theStatus = AudioDeviceGetProperty ( myDevice, theChannel, theDirection, kAudioDevicePropertyMute, &theSize, &tmpBool32 );
		if (noErr == theStatus)
			rv.isMuted = tmpBool32;
	}
	
	theStatus = AudioDeviceGetPropertyInfo ( myDevice, theChannel, theDirection, kAudioDevicePropertyPlayThru, &theSize, &rv.canPlayThru );
	if (noErr == theStatus)
	{
		theStatus = AudioDeviceGetProperty ( myDevice, theChannel, theDirection, kAudioDevicePropertyPlayThru, &theSize, &tmpBool32 );
		if (noErr == theStatus)
			rv.playThruIsSet = tmpBool32;
	}
	
	return rv;
}

- (Float32) volumeForChannel:(UInt32)theChannel forDirection:(MTCoreAudioDirection)theDirection
{
	OSStatus theStatus;
	UInt32 theSize;
	Float32 theVolumeScalar;
	
	theSize = sizeof(Float32);
	theStatus = AudioDeviceGetProperty ( myDevice, theChannel, theDirection, kAudioDevicePropertyVolumeScalar, &theSize, &theVolumeScalar );
	if (theStatus == 0)
		return theVolumeScalar;
	else
		return 0.0;
}

- (Float32) volumeInDecibelsForChannel:(UInt32)theChannel forDirection:(MTCoreAudioDirection)theDirection
{
	OSStatus theStatus;
	UInt32 theSize;
	Float32 theVolumeDecibels;
	
	theSize = sizeof(Float32);
	theStatus = AudioDeviceGetProperty ( myDevice, theChannel, theDirection, kAudioDevicePropertyVolumeDecibels, &theSize, &theVolumeDecibels );
	if (theStatus == 0)
		return theVolumeDecibels;
	else
		return 0.0;
}

- (void) setVolume:(Float32)theVolume forChannel:(UInt32)theChannel forDirection:(MTCoreAudioDirection)theDirection
{
	OSStatus theStatus;
	UInt32 theSize;
	
	theSize = sizeof(Float32);
	theStatus = AudioDeviceSetProperty ( myDevice, NULL, theChannel, theDirection, kAudioDevicePropertyVolumeScalar, theSize, &theVolume );
}

- (void) setVolumeDecibels:(Float32)theVolumeDecibels forChannel:(UInt32)theChannel forDirection:(MTCoreAudioDirection)theDirection
{
	OSStatus theStatus;
	UInt32 theSize;
	
	theSize = sizeof(Float32);
	theStatus = AudioDeviceSetProperty ( myDevice, NULL, theChannel, theDirection, kAudioDevicePropertyVolumeDecibels, theSize, &theVolumeDecibels );
}

- (Float32) volumeInDecibelsForVolume:(Float32)theVolume forChannel:(UInt32)theChannel forDirection:(MTCoreAudioDirection)theDirection
{
	OSStatus theStatus;
	UInt32 theSize;
	Float32 theVolumeDecibels;
	
	theSize = sizeof(Float32);
	theVolumeDecibels = theVolume;
	theStatus = AudioDeviceGetProperty ( myDevice, theChannel, theDirection, kAudioDevicePropertyVolumeScalarToDecibels, &theSize, &theVolumeDecibels );
	if (theStatus == 0)
		return theVolumeDecibels;
	else
		return 0.0;
}

- (Float32) volumeForVolumeInDecibels:(Float32)theVolumeDecibels forChannel:(UInt32)theChannel forDirection:(MTCoreAudioDirection)theDirection
{
	OSStatus theStatus;
	UInt32 theSize;
	Float32 theVolume;
	
	theSize = sizeof(Float32);
	theVolume = theVolumeDecibels;
	theStatus = AudioDeviceGetProperty ( myDevice, theChannel, theDirection, kAudioDevicePropertyVolumeDecibelsToScalar, &theSize, &theVolume );
	if (theStatus == 0)
		return theVolume;
	else
		return 0.0;
}

- (void) setMute:(BOOL)isMuted forChannel:(UInt32)theChannel forDirection:(MTCoreAudioDirection)theDirection
{
	OSStatus theStatus;
	UInt32 theSize;
	UInt32 theMuteVal;
	
	theSize = sizeof(UInt32);
	if (isMuted) theMuteVal = 1; else theMuteVal = 0;
	theStatus = AudioDeviceSetProperty ( myDevice, NULL, theChannel, theDirection, kAudioDevicePropertyMute, theSize, &theMuteVal );
}

- (void) setPlayThru:(BOOL)isPlayingThru forChannel:(UInt32)theChannel
{
	OSStatus theStatus;
	UInt32 theSize;
	UInt32 thePlayThruVal;
	
	theSize = sizeof(UInt32);
	if (isPlayingThru) thePlayThruVal = 1; else thePlayThruVal = 0;
	theStatus = AudioDeviceSetProperty ( myDevice, NULL, theChannel, kMTCoreAudioDevicePlaybackDirection, kAudioDevicePropertyPlayThru, theSize, &thePlayThruVal );
}

- (void) setPlayThru:(BOOL)isPlayingThru forChannel:(UInt32)theChannel forDirection:(MTCoreAudioDirection)theDirection
{
	printf ( "-[MTCoreAudioDevice setPlayThru:forChannel:forDirection:] is deprecated, please use -[MTCoreAudioDevice setPlayThru:forChannel:] instead.\n" );
	[self setPlayThru:isPlayingThru forChannel:theChannel];
}

- (Class) streamDescriptionFactory
{
	return [MTCoreAudioStreamDescription class];
}

- (MTCoreAudioStreamDescription *) streamDescriptionForChannel:(UInt32)theChannel forDirection:(MTCoreAudioDirection)theDirection
{
	OSStatus theStatus;
	UInt32 theSize;
	AudioStreamBasicDescription theDescription;
	
	theSize = sizeof(AudioStreamBasicDescription);
	theStatus = AudioDeviceGetProperty ( myDevice, theChannel, theDirection, kAudioDevicePropertyStreamFormat, &theSize, &theDescription );
	if (theStatus == 0)
	{
		return [[self streamDescriptionFactory] streamDescriptionWithAudioStreamBasicDescription:theDescription];
	}
	return nil;
}

// NSArray of MTCoreAudioStreamDescriptions
- (NSArray *) streamDescriptionsForChannel:(UInt32)theChannel forDirection:(MTCoreAudioDirection)theDirection
{
	OSStatus theStatus;
	UInt32 theSize;
	UInt32 numItems;
	UInt32 x;
	AudioStreamBasicDescription * descriptionArray;
	NSMutableArray * rv;
	
	rv = [NSMutableArray arrayWithCapacity:1];
	
	theStatus = AudioDeviceGetPropertyInfo ( myDevice, theChannel, theDirection, kAudioDevicePropertyStreamFormats, &theSize, NULL );
	if (theStatus != 0)
		return rv;
	
	descriptionArray = (AudioStreamBasicDescription *) malloc ( theSize );
	numItems = theSize / sizeof(AudioStreamBasicDescription);
	theStatus = AudioDeviceGetProperty ( myDevice, theChannel, theDirection, kAudioDevicePropertyStreamFormats, &theSize, descriptionArray );
	if (theStatus != 0)
	{
		free(descriptionArray);
		return rv;
	}
	
	for ( x = 0; x < numItems; x++ )
		[rv addObject:[[self streamDescriptionFactory] streamDescriptionWithAudioStreamBasicDescription:descriptionArray[x]]];

	free(descriptionArray);
	return rv;
}

- (Boolean) setStreamDescription:(MTCoreAudioStreamDescription *)theDescription forChannel:(UInt32)theChannel forDirection:(MTCoreAudioDirection)theDirection
{
	OSStatus theStatus;
	UInt32 theSize;
	AudioStreamBasicDescription theASBasicDescription;
	
	theASBasicDescription = [theDescription audioStreamBasicDescription];
	theSize = sizeof(AudioStreamBasicDescription);
	
	theStatus = AudioDeviceSetProperty ( myDevice, NULL, theChannel, theDirection, kAudioDevicePropertyStreamFormat, theSize, &theASBasicDescription );
	return (theStatus == 0);
}

- (MTCoreAudioStreamDescription *) matchStreamDescription:(MTCoreAudioStreamDescription *)theDescription forChannel:(UInt32)theChannel forDirection:(MTCoreAudioDirection)theDirection
{
	OSStatus theStatus;
	UInt32 theSize;
	AudioStreamBasicDescription theASBasicDescription;
	
	theASBasicDescription = [theDescription audioStreamBasicDescription];
	theSize = sizeof(AudioStreamBasicDescription);
	
	theStatus = AudioDeviceGetProperty ( myDevice, theChannel, theDirection, kAudioDevicePropertyStreamFormatMatch, &theSize, &theASBasicDescription );
	if ( theStatus == 0 )
	{
		return [[self streamDescriptionFactory] streamDescriptionWithAudioStreamBasicDescription:theASBasicDescription];
	}

	return nil;
}

- (Float64)    nominalSampleRate
{
	OSStatus theStatus;
	UInt32 theSize;
	Float64 theSampleRate;
	
	theSize = sizeof(Float64);
	theStatus = AudioDeviceGetProperty ( myDevice, 0, 0, kAudioDevicePropertyNominalSampleRate, &theSize, &theSampleRate );
	if ( noErr == theStatus )
		return theSampleRate;
	else
		return 0.0;
}

- (NSArray *) nominalSampleRates
{
	OSStatus theStatus;
	UInt32 theSize;
	UInt32 numItems;
	UInt32 x;
	AudioValueRange * rangeArray;
	NSMutableArray * rv = [NSMutableArray array];
	
	theStatus = AudioDeviceGetPropertyInfo ( myDevice, 0, 0, kAudioDevicePropertyAvailableNominalSampleRates, &theSize, NULL );
	if ( noErr != theStatus )
		return rv;
	
	rangeArray = (AudioValueRange *) malloc ( theSize );
	numItems = theSize / sizeof(AudioValueRange);
	theStatus = AudioDeviceGetProperty ( myDevice, 0, 0, kAudioDevicePropertyAvailableNominalSampleRates, &theSize, rangeArray );
	if ( noErr != theStatus )
	{
		free(rangeArray);
		return rv;
	}
	
	for ( x = 0; x < numItems; x++ )
		[rv addObject:[NSArray arrayWithObjects:[NSNumber numberWithDouble:rangeArray[x].mMinimum], [NSNumber numberWithDouble:rangeArray[x].mMaximum], nil]];

	free(rangeArray);
	return rv;
}

- (Boolean)   supportsNominalSampleRate:(Float64)theRate
{
	NSEnumerator * sampleRateRangeEnumerator = [[self nominalSampleRates] objectEnumerator];
	NSArray * aRange;
	
	while ( aRange = [sampleRateRangeEnumerator nextObject] )
	{
		if (( [[aRange objectAtIndex:0] doubleValue] <= theRate ) && ( [[aRange objectAtIndex:1] doubleValue] >= theRate ))
		{
			return YES;
		}
	}
	return NO;
}

- (Boolean)   setNominalSampleRate:(Float64)theRate
{
	OSStatus theStatus;
	UInt32 theSize;
	
	theSize = sizeof(Float64);
	theStatus = AudioDeviceSetProperty ( myDevice, NULL, 0, 0, kAudioDevicePropertyNominalSampleRate, theSize, &theRate );
	return ( noErr == theStatus );
}

- (double)    actualSampleRate
{
	OSStatus theStatus;
	UInt32 theSize;
	Float64 theSampleRate;
	
	theSize = sizeof(Float64);
	theStatus = AudioDeviceGetProperty ( myDevice, 0, 0, kAudioDevicePropertyActualSampleRate, &theSize, &theSampleRate );
	if ( noErr == theStatus )
		return theSampleRate;
	else
		return 0.0;
}

- (void) setIOProc:(AudioDeviceIOProc)theIOProc withClientData:(void *)theClientData
{
	[self removeIOProc];
	myIOProc = theIOProc;
	myIOProcClientData = theClientData;
}

- (void) setIOTarget:(id)theTarget withSelector:(SEL)theSelector withClientData:(void *)theClientData
{
	[self removeIOProc];
	myIOInvocation = [[NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(ioCycleForDevice:timeStamp:inputData:inputTime:outputData:outputTime:clientData:)]] retain];
	[myIOInvocation setTarget:theTarget];
	[myIOInvocation setSelector:theSelector];
	[myIOInvocation setArgument:&self atIndex:2];
	[myIOInvocation setArgument:&theClientData atIndex:8];

	myIOProcClientData = theClientData;
}

- (void) removeIOProc
{
	if (myIOProc || myIOInvocation)
	{
		[self deviceStop];
		myIOProc = NULL;
		[myIOInvocation release];
		myIOInvocation = nil;
		myIOProcClientData = NULL;
	}
}

- (void) removeIOTarget
{
	[self removeIOProc];
}

- (Boolean) deviceStart
{
	if (myIOProc || myIOInvocation)
	{
		deviceIOStarted = [MTCoreAudioIOProcMux registerDevice:self];
	}
	return deviceIOStarted;
}

- (void) deviceStop
{
	if (deviceIOStarted)
	{
		[MTCoreAudioIOProcMux unRegisterDevice:self];
		deviceIOStarted = false;
	}
}

- (void) setDevicePaused:(Boolean)shouldPause
{
	if ( shouldPause )
	{
		[MTCoreAudioIOProcMux setPause:shouldPause forDevice:self];
	}
	else
	{
		isPaused = FALSE;
	}
}


- (void) dealloc
{
	[self removeIOProc];
	if (myStreams[0]) [myStreams[0] release];
	if (myStreams[1]) [myStreams[1] release];
	[self setDelegate:nil];
	[super dealloc];
}

- (OSStatus) ioCycleForDevice:(MTCoreAudioDevice *)theDevice timeStamp:(const AudioTimeStamp *)inNow inputData:(const AudioBufferList *)inInputData inputTime:(const AudioTimeStamp *)inInputTime outputData:(AudioBufferList *)outOutputData outputTime:(const AudioTimeStamp *)inOutputTime clientData:(void *)inClientData
{
	return noErr;
}

@end

@implementation MTCoreAudioDevice(MTCoreAudioDevicePrivateAdditions)

- (void) dispatchIOProcWithTimeStamp:(const AudioTimeStamp *)inNow inputData:(const AudioBufferList *)inInputData inputTime:(const AudioTimeStamp *)inInputTime outputData:(AudioBufferList *)outOutputData outputTime:(const AudioTimeStamp *)inOutputTime
{
	if ( isPaused )
		return;
	
	if (myIOProc)
	{
		(void)(*myIOProc)( myDevice, inNow, inInputData, inInputTime, outOutputData, inOutputTime, myIOProcClientData );
	}
	else if (myIOInvocation)
	{
		[myIOInvocation setArgument:&inNow atIndex:3];
		[myIOInvocation setArgument:&inInputData atIndex:4];
		[myIOInvocation setArgument:&inInputTime atIndex:5];
		[myIOInvocation setArgument:&outOutputData atIndex:6];
		[myIOInvocation setArgument:&inOutputTime atIndex:7];
		[myIOInvocation invoke];
	}
}

- (void) dispatchIOStartDidFailForReason:(OSStatus)theReason
{
	if ( myDelegate && [myDelegate respondsToSelector:@selector(audioDeviceStartDidFail:forReason:)] )
	{
		[myDelegate audioDeviceStartDidFail:self forReason:theReason];
	}
}

- (void) doSetPause:(Boolean)shouldPause
{
	isPaused = shouldPause;
}

@end
