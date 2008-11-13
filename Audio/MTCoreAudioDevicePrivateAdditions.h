//
//  MTCoreAudioDevicePrivateAdditions.h
//  MTCoreAudio
//
//  Created by Michael Thornburgh on Thu Oct 03 2002.
//  Copyright (c) 2002 Michael Thornburgh. All rights reserved.
//



@interface MTCoreAudioDevice(MTCoreAudioDevicePrivateAdditions)

- (void) dispatchIOProcWithTimeStamp:(const AudioTimeStamp *)inNow inputData:(const AudioBufferList *)inInputData inputTime:(const AudioTimeStamp *)inInputTime outputData:(AudioBufferList *)outOutputData outputTime:(const AudioTimeStamp *)inOutputTime;
- (void) dispatchIOStartDidFailForReason:(OSStatus)theReason;
- (void) doSetPause:(Boolean)shouldPause;

@end
