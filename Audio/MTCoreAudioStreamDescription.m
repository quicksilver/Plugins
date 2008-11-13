//
//  MTCoreAudioStreamDescription.m
//  MTCoreAudio.framework
//
//  Created by Michael Thornburgh on Fri Dec 21 2001.
//  Copyright (c) 2001 Michael Thornburgh. All rights reserved.
//

#import "MTCoreAudioStreamDescription.h"


@implementation MTCoreAudioStreamDescription

+ (MTCoreAudioStreamDescription *) streamDescriptionWithAudioStreamBasicDescription:(AudioStreamBasicDescription)theDescription
{
	return [[[[self class] alloc] initWithAudioStreamBasicDescription:theDescription] autorelease];
}

+ (MTCoreAudioStreamDescription *) streamDescription
{
	return [[[[self class] alloc] init] autorelease];
}

+ (MTCoreAudioStreamDescription *) nativeStreamDescription
{
	return [[[self class] streamDescription] setNativeFormat];
}

- copyWithZone:(NSZone *)zone
{
	return [[[self class] allocWithZone:zone] initWithAudioStreamBasicDescription:myASBasicDescription];
}

- (NSBundle *) bundleForDescriptionStrings
{
	return [NSBundle bundleForClass:[MTCoreAudioStreamDescription class]];
}
- (NSString *) description
{
	NSBundle * myBundle = [self bundleForDescriptionStrings];
	NSString * extraDesc = @"";
	NSString * channelString = [myBundle localizedStringForKey:@"ch" value:nil table:@"StreamDescription"];
	NSString * bitString = [myBundle localizedStringForKey:@"bit" value:nil table:@"StreamDescription"];
	NSString * hertzString = [myBundle localizedStringForKey:@"hz" value:nil table:@"StreamDescription"];
	
	if ( myASBasicDescription.mFormatID == kAudioFormatLinearPCM )
	{
		if ( myASBasicDescription.mFormatFlags != kAudioFormatFlagsNativeFloatPacked )
		{
			NSString * linearType = myASBasicDescription.mFormatFlags & kLinearPCMFormatFlagIsFloat ? @"floating-point" : ( myASBasicDescription.mFormatFlags & kLinearPCMFormatFlagIsSignedInteger ? @"signed-integer" : @"unsigned-integer" );
			NSString * endian = myASBasicDescription.mFormatFlags & kLinearPCMFormatFlagIsBigEndian ? @"big-endian" : @"little-endian";
			NSString * aligned = myASBasicDescription.mFormatFlags & kLinearPCMFormatFlagIsPacked ? @"packed" : ( myASBasicDescription.mFormatFlags & kLinearPCMFormatFlagIsAlignedHigh ? @"aligned-high" : @"aligned-low" );
			
			linearType = [myBundle localizedStringForKey:linearType value:nil table:@"StreamDescription"];
			endian = [myBundle localizedStringForKey:endian value:nil table:@"StreamDescription"];
			aligned = [myBundle localizedStringForKey:aligned value:nil table:@"StreamDescription"];
			
			extraDesc = [NSString stringWithFormat:@" %@ %@ %@", linearType, endian, aligned];
		}
	}
	else
	{
		// some non-lpcm special format
	}
	
	return [NSString stringWithFormat:@"%d%@-%.2f%@-%d%@-'%4.4s'%@",
		myASBasicDescription.mChannelsPerFrame, channelString,
		myASBasicDescription.mSampleRate, hertzString,
		myASBasicDescription.mBitsPerChannel, bitString,
		(char *)(&(myASBasicDescription.mFormatID)),
		extraDesc
		];
}

- (MTCoreAudioStreamDescription *) init
{
	[super init];
	// myASBasicDescription.mSampleRate = 0.0;
	myASBasicDescription.mFormatID = kAudioFormatLinearPCM;
	// myASBasicDescription.mFormatFlags = 0;
	// myASBasicDescription.mBytesPerPacket = 0;
	// myASBasicDescription.mFramesPerPacket = 0;
	// myASBasicDescription.mBytesPerFrame = 0;
	// myASBasicDescription.mChannelsPerFrame = 0;
	// myASBasicDescription.mBitsPerChannel = 0;
	
	return self;
}

- (MTCoreAudioStreamDescription *) initWithAudioStreamBasicDescription:(AudioStreamBasicDescription)theDescription
{
	[super init];
	myASBasicDescription = theDescription;
	return self;
}

- (void) _normalizeBytesForChannels
{
	unsigned bytesPerFrame;

	if ( [self isInterleaved] )
	{
		bytesPerFrame = sizeof(Float32) * myASBasicDescription.mChannelsPerFrame;
	}
	else
	{
		bytesPerFrame = sizeof(Float32);
	}
	myASBasicDescription.mBytesPerFrame = myASBasicDescription.mBytesPerPacket = bytesPerFrame;
}

- (MTCoreAudioStreamDescription *) setNativeFormat
{
	myASBasicDescription.mFormatID = kAudioFormatLinearPCM;
	myASBasicDescription.mFormatFlags = kAudioFormatFlagsNativeFloatPacked;
	myASBasicDescription.mBitsPerChannel = sizeof(Float32) * 8;
	myASBasicDescription.mFramesPerPacket = 1;
	[self _normalizeBytesForChannels];
	return self;
}

- (AudioStreamBasicDescription) audioStreamBasicDescription
{
	return myASBasicDescription;
}

- (Boolean) isLinearPCMFormat
{
	return ( kAudioFormatLinearPCM == myASBasicDescription.mFormatID );
}

- (Boolean) isCanonicalFormat
{
	return (
		( [self isLinearPCMFormat] )
		&& (( kAudioFormatFlagsNativeFloatPacked | kLinearPCMFormatFlagIsNonInterleaved ) == ( myASBasicDescription.mFormatFlags | kLinearPCMFormatFlagIsNonInterleaved ))
		&& (( sizeof(Float32) * 8 ) == myASBasicDescription.mBitsPerChannel )
		&& ( 1 == myASBasicDescription.mFramesPerPacket )
	);
}

- (Boolean) isNativeFormat
{
	return ( [self isCanonicalFormat] && [self isInterleaved] );
}

- (Float32) sampleRate
{
	return myASBasicDescription.mSampleRate;
}

- (MTCoreAudioStreamDescription *) setSampleRate:(Float32)theSampleRate
{
	myASBasicDescription.mSampleRate = theSampleRate;
	return self;
}

- (UInt32)  formatID
{
	return myASBasicDescription.mFormatID;
}

- (MTCoreAudioStreamDescription *) setFormatID:(UInt32)theFormatID
{
	myASBasicDescription.mFormatID = theFormatID;
	return self;
}

- (UInt32) formatFlags
{
	return myASBasicDescription.mFormatFlags;
}

- (MTCoreAudioStreamDescription *) setFormatFlags:(UInt32)theFormatFlags
{
	myASBasicDescription.mFormatFlags = theFormatFlags;
	return self;
}

- (UInt32) bytesPerPacket
{
	return myASBasicDescription.mBytesPerPacket;
}

- (MTCoreAudioStreamDescription *) setBytesPerPacket:(UInt32)theBytesPerPacket
{
	myASBasicDescription.mBytesPerPacket = theBytesPerPacket;
	return self;
}

- (UInt32)  framesPerPacket
{
	return myASBasicDescription.mFramesPerPacket;
}

- (MTCoreAudioStreamDescription *) setFramesPerPacket:(UInt32)theFramesPerPacket
{
	myASBasicDescription.mFramesPerPacket = theFramesPerPacket;
	return self;
}

- (UInt32) bytesPerFrame
{
	return myASBasicDescription.mBytesPerFrame;
}

- (MTCoreAudioStreamDescription *) setBytesPerFrame:(UInt32)theBytesPerFrame
{
	myASBasicDescription.mBytesPerFrame = theBytesPerFrame;
	return self;
}

- (UInt32) channelsPerFrame
{
	return myASBasicDescription.mChannelsPerFrame;
}

- (MTCoreAudioStreamDescription *) setChannelsPerFrame:(UInt32)theChannelsPerFrame;
{
	myASBasicDescription.mChannelsPerFrame = theChannelsPerFrame;
	if ( [self isCanonicalFormat] )
	{
		[self _normalizeBytesForChannels];
	}
	return self;
}

- (UInt32) bitsPerChannel
{
	return myASBasicDescription.mBitsPerChannel;
}

- (MTCoreAudioStreamDescription *) setBitsPerChannel:(UInt32)theBitsPerChannel;
{
	myASBasicDescription.mBitsPerChannel = theBitsPerChannel;
	return self;
}

- (Boolean)                        isInterleaved
{
	return ( 0 == ( myASBasicDescription.mFormatFlags & kLinearPCMFormatFlagIsNonInterleaved ));
}

- (MTCoreAudioStreamDescription *) setIsInterleaved:(Boolean)interleave
{
	if ( [self isLinearPCMFormat] )
	{
		if ( interleave )
		{
			myASBasicDescription.mFormatFlags &= ~kLinearPCMFormatFlagIsNonInterleaved;
		}
		else
		{
			myASBasicDescription.mFormatFlags |= kLinearPCMFormatFlagIsNonInterleaved;
		}
		if ( [self isCanonicalFormat] )
		{
			[self _normalizeBytesForChannels];
		}
	}
	return self;
}


@end
