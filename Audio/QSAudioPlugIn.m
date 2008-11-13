//
//  QSAudioPlugIn.m
//  QSAudioPlugIn
//
//  Created by Nicholas Jitkoff on 11/18/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//


// Recording stuff By Kurt Revis


#import "QSAudioPlugIn.h"
#import <CoreAudio/CoreAudio.h>
#import <objc/objc-runtime.h>

#import "MTCoreAudio.h"

#import <AudioToolbox/AudioFile.h>
#import <AudioToolbox/AudioConverter.h>

// about 25 seconds of recording time
#define SOUND_BUFFER_SIZE (8 * 1024 * 1024) 
static unsigned char g_soundBuffer[SOUND_BUFFER_SIZE];

// for recording and playback, this is where we are in the buffer
static int g_lastIndex;

// how much data is in the buffer
static int g_bufferSize;



void WriteAIFF(FSRef fsRef, CFStringRef newFile)
{
	
	//An interleaved 16-bit 44.1 kHz stereo AIFF file has the following AudioStreamBasicDescription:
	
	
	AudioStreamBasicDescription aiffFormat;
	aiffFormat.mSampleRate = 44100;
	aiffFormat.mFormatID = kAudioFormatLinearPCM;
	aiffFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger |
		kLinearPCMFormatFlagIsPacked |
		kLinearPCMFormatFlagIsBigEndian;
	aiffFormat.mBytesPerPacket = 4;
	aiffFormat.mFramesPerPacket = 1;
	aiffFormat.mBytesPerFrame = 4;
	aiffFormat.mChannelsPerFrame = 2;
	aiffFormat.mBitsPerChannel = 16;
	
	//	Uncompressed audio means that there is always 1 frame per packet (compressed audio - like MP3 - will have multiple frame per packet). A frame is a cross section of samples that covers all the channels of audio. So here an AIFF frame contains the left and right samples.
	//		
	//		The internal format we want to save to an AIFF file is quite different. It's in a non-interleaved 32-bit float stereo format and has the following description:
	//		
	//		
	AudioStreamBasicDescription floatFormat;
	floatFormat.mSampleRate = 44100;
	floatFormat.mFormatID = kAudioFormatLinearPCM;
	floatFormat.mFormatFlags =  kLinearPCMFormatFlagIsFloat | kLinearPCMFormatFlagIsBigEndian| kLinearPCMFormatFlagIsPacked;
	floatFormat.mBytesPerPacket = 8;
	floatFormat.mFramesPerPacket = 1;
	floatFormat.mBytesPerFrame = 8;
	floatFormat.mChannelsPerFrame = 2;
	floatFormat.mBitsPerChannel = 32;
	//	
	//	Note that non-interleaved formats are described differently from interleaved formats in the mBytesPerPacket and BytesPerFrame fields. This is because a frame of samples is not contiguous and is divided into separate buffers. Therefore the description describes one of the buffers and that description is used as a template (so to speak) for all the other buffers. What are these buffers to which I'm referring? Well as non-interleaved data has a more complex structure it cannot just be plonked into a blob of memory. The AudioConverter requires that non-interleaved data be presented in an AudioBufferList that describes the buffer layout.
	//		
	//Note: the need to use a AudioBufferList means that the simple AudioConverter API AudioConverterConvertBuffer() cannot be used as this is only useful for converting between buffers that are interleaved, uncompressed and have the same sample rate. Also be careful with this function: it doesn't check that it can convert between the formats before it starts cranking - resulting in either garbage or a crash!
	//	
	//	So now that we've got our formats set out we can proceed to getting the file created. To create a new audio file use the AudioFileCreate function:
	
	
	FSRef outRef;
	AudioFileID audioFileID;
	//AudioFileCreate
	OSStatus status = AudioFileCreate
		(
		 //an FSRef to the directory where  the new file should be created.
		 &fsRef,
		 // a CFStringRef containing the name of the file to be created. 
		 (CFStringRef)newFile,  
		 // a UInt32 indicating the type of audio file to created.
		 kAudioFileAIFCType, 
		 // an AudioStreamBasicDescription describing the data format that will be  added to the audio file.
		 &aiffFormat,        
		 // relevent flags for creating/opening the file. Currently zero.
		 0,                  
		 // on success, the FSRef of the newly created file.
		 &outRef,            
		 // upon success, an AudioFileID that can be used for subsequent AudioFile calls.
		 &audioFileID);
	
	NSLog(@"status %d",status);
	//Note: If the file already exists then this call will fail. You should use AudioFileInitialize() (which has a very similar interface) instead. 
	
	// Once we've opened the file we need to create an AudioConverter so that we can easily create data ready for writing to the AIFF file. To create an AudioConverter we just need to supply to two audio formats. Creation will fail if the converter can't convert between the two formats specified. If it does fail it's probably due to an error in one (or both) of your AudioStreamBasicDescriptions. Unfortunately you're not told where the error is...
	
	
    AudioConverterRef converter;
    status = AudioConverterNew( &floatFormat, // from format
                                &aiffFormat,  // to format
                                &converter); // if successful refereces the newly created converter.
	
	// Now we've got the file and the converter ready to roll we need to create a buffer to hold the converted data:
	
	
	UInt32 size= 0;
	AudioBufferList outputData; // only need a single buffer which you get for free
	outputData.mNumberBuffers = 1; // single interleaved buffer
	outputData.mBuffers[0].mData = malloc(2048); // lots of room for data
	outputData.mBuffers[0].mNumberChannels = 2; // stereo
	outputData.mBuffers[0].mDataByteSize = 2048;  // how much room have we provided
	
	// Finally it's just a matter of iterating through the data and writing the converted packets to the file:
	
	
	
	//	while (!done)
	//		// see this Apple page for info on indicating the
	//		// end of the data: http://developer.apple.com/qa/qa2001/qa1317.html
	//	{
	//		status = AudioConverterFillComplexBuffer(converter,
	//												 InputDataProc,      // see below
	//												 NULL,            // any user data you want to supply to the input proc
	//												 &size,                      // the number of packets produced
	//												 &outputData,        // the converted buffers
	//												 NULL);              // not compressed so don't need a packet description
	//		
	
	SInt64 curPos=0;
	size=g_bufferSize/sizeof(Float32);
	
	NSLog(@"size %d",size);
	// we can use write packets because for uncompressed 1 packet = 1 frame
	status = AudioFileWritePackets(audioFileID, // the ID from AudioFileCreate
								   TRUE,          // don't need caching 
								   size,           // the amount of data returned
								   NULL,           // no packet descriptions
								   curPos,         // current sample location
								   &size,  // actual data written
								   &g_soundBuffer); // the buffer of converted audio
	
	
	NSLog(@"size %d",size);
	//}
	
// When we're all done we need to clean up:


AudioConverterDispose(converter);
AudioFileClose(audioFileID);
free(outputData.mBuffers[0].mData);
}

// Well there's one last thing - we need to define the InputDataProc. This is used to feed the source audio into the audio converter. Note that the CoreAudio folks have made the AudioConverter as efficient as possible and one of these efficiencies is to eliminate buffer copies as much as possible. This is great for your input proc because it means that you can just hand back your buffer pointers to the converter. The one thing to be careful of is avoiding futzing with the buffers while the audio converter is doing its thing.


OSStatus InputDataProc(AudioConverterRef inAudioConverter,
					   UInt32* ioNumberDataPackets,
					   AudioBufferList* ioData,
					   AudioStreamPacketDescription** outDataPacketDescription,
					   void* inUserData)
{
	// note: we can ignore the packet description parameter  because we're uncompressed.
	
	// Fill up your buffers - remember the buffers have to match the input format we
	// described earlier otherwise the converter will be very confused. The
	// AudioConverter will present an AudioBufferList that is compatible with the
	// format you described. In our case it's created two buffers for our
	// non-interleaved float data.
	// You can use the ioNumberDataPackets to determine how many packets to
	// render. Or you can ignore it - the AudioConverter will accept more or less than
	// asks for which is very friendly.
	
    ioData->mBuffers[0].mData = &g_soundBuffer; // pointer to your left buffer
    ioData->mBuffers[0].mDataByteSize = g_bufferSize; // ioNumberDataPackets * sizeof(Foat32) 
    ioData->mBuffers[0].mNumberChannels = 2; // non-interleaved
											 //    ioData->mBuffers[1].mData = // pointer to your right buffer
											 //		ioData->mBuffers[1].mDataByteSize = // ioNumberDataPackets * sizeof(Foat32)
											 //		ioData->mBuffers[1].mNumberChannels = 1; // non-interleaved
											 //												 // if you don't produce the requested number of packets then make sure you
											 //												 // tell the converter the real number
	*ioNumberDataPackets = g_bufferSize/sizeof(Float32);  // actual number of packets rendered;
	return noErr;
}




@implementation QSAudioPlugIn

- (QSObject *)record{
	[self startRecording:nil];
	[NSBundle loadNibNamed:@"QSRecordWindow" owner:self];
	[[self window]orderFront:nil];
	
}

// this is the MTCoreAudioDevice IO target for recording. It's
// callback saying that there is new data to be read.  Since we're
// just doing real simple buffering of data, and then regurgitating it
// when we play, we don't mess with too many of the arguments.

- (OSStatus) readCycleForDevice: (MTCoreAudioDevice *) theDevice 
					  timeStamp: (const AudioTimeStamp *) now 
					  inputData: (const AudioBufferList *) inputData 
					  inputTime: (const AudioTimeStamp *) inputTime 
					 outputData: (AudioBufferList *) outputData 
					 outputTime: (const AudioTimeStamp *) outputTime 
					 clientData: (void *) clientData
{
    // peer into the data
	
    const AudioBuffer *buffer;
    buffer = &inputData->mBuffers[0];
	
	//	NSLog(@"%d",buffer->mNumberChannels);
	
	
    // will this sample put us over the line?  If so, dump the data
    // and tell the UI to stop the recording and disable the Stop
    // button.  We don't stop the actual reading from here
    // because it seems to leave some stale locks in the MTCoreAudio
    // guts.
	
    if (g_lastIndex + buffer->mDataByteSize > SOUND_BUFFER_SIZE) {
		[self performSelectorOnMainThread: @selector(stopRecording:)
							   withObject: self
							waitUntilDone: NO];
		
    } else {
		
		// append the data to the end of our buffer
		memcpy (g_soundBuffer + g_lastIndex,
				buffer->mData, buffer->mDataByteSize);
		g_lastIndex += buffer->mDataByteSize;
    }
	
    return (noErr);
	
} // readCycleForDevice



// the MTCoreAudioDevice IO target for playback.  We feed data from
// our buffer into the sound system

- (OSStatus) writeCycleForDevice: (MTCoreAudioDevice *) theDevice 
					   timeStamp: (const AudioTimeStamp *) now 
					   inputData: (const AudioBufferList *) inputData 
					   inputTime: (const AudioTimeStamp *) inputTime 
					  outputData: (AudioBufferList *) outputData 
					  outputTime: (const AudioTimeStamp *) outputTime 
					  clientData: (void *) clientData
{
    // are we done? 
	
    if (g_lastIndex >= g_bufferSize) {
		
		// yep.  tell the UI part to shut down the playback.
		[self performSelectorOnMainThread: @selector(stopPlaying:)
							   withObject: self
							waitUntilDone: NO];
		
    } else {
		
		// otherwise stick some data into the buffer
		AudioBuffer *buffer;
		buffer = &outputData->mBuffers[0];
		
		memcpy (buffer->mData,
				g_soundBuffer + g_lastIndex,
				buffer->mDataByteSize);
		
		g_lastIndex += buffer->mDataByteSize;
    }
	
    return (noErr);
    
} // writeCycleForDevice


// update the UI based on the current sytem volume and input volume

- (void) setStuffBasedOnVolume
{
    MTCoreAudioVolumeInfo volumeInfo;
	
    volumeInfo = [inputDevice volumeInfoForChannel: 1
									  forDirection: kMTCoreAudioDeviceRecordDirection];
    [inputVolumeSlider setFloatValue: volumeInfo.theVolume];
	
    volumeInfo = [outputDevice volumeInfoForChannel: 1
									   forDirection: kMTCoreAudioDevicePlaybackDirection];
    [outputVolumeSlider setFloatValue: volumeInfo.theVolume];
	
	
} // setStuffBasedOnVolume



// we've been intantiated.  acquire our audio devices and set up the UI

- (void) awakeFromNib
{
    inputDevice = [MTCoreAudioDevice defaultInputDevice];
    [inputDevice retain];
	
    outputDevice = [MTCoreAudioDevice defaultOutputDevice];
    [outputDevice retain];
	
    // set up the recording callback
    [inputDevice setIOTarget: self
				withSelector: @selector(readCycleForDevice:timeStamp:inputData:inputTime:outputData:outputTime:clientData:)
			  withClientData: NULL];
    
    // set up the palyback callback
    [outputDevice setIOTarget: self
				 withSelector: @selector(writeCycleForDevice:timeStamp:inputData:inputTime:outputData:outputTime:clientData:)
			   withClientData: NULL];
	
    // update the UI
	
    [self setStuffBasedOnVolume];
    
} // awakeFromNib



// clean up our mess

- (void) dealloc
{
    [inputDevice release];
    [outputDevice release];
	
    [super dealloc];
	
} // dealloc



// button handler.  kick off the recording

- (IBAction) startRecording: (id) sender
{
    // reset our buffer position to the start
    g_lastIndex = 0;
    g_bufferSize = 0;
	
    // update the UI so the user can stop the recording
    [recordStopButton setEnabled: YES];
	
    // start recording
    [inputDevice deviceStart];
	
} // startRecording



// button handler.  cease recording.

- (IBAction) stopRecording: (id) sender
{
    // stop recording
    [inputDevice deviceStop];
	
    // snarf how much data we've gotten
    g_bufferSize = g_lastIndex;
	

	
    // update the UI to turn off the 'stop' button
    [recordStopButton setEnabled: NO];
	
} // stopRecording



// button handler, start playback of our data

- (IBAction) startPlaying: (id) sender
{
    // start playing from the beginning
    g_lastIndex = 0;
	
    // update the UI so the user can stop the playback
    [playStopButton setEnabled: YES];
	
    // start playback
    [outputDevice deviceStart];
	
} // play
- (IBAction)done:(id)sender{
	
	
	FSRef fsRef;
	
	// use the CF function to extract an FSRef from the URL:
	CFURLGetFSRef([NSURL fileURLWithPath:[@"~/Desktop/" stringByStandardizingPath]], &fsRef);
	WriteAIFF(fsRef, @"testme.aiff");	
	[[self window]orderOut:nil];
}


// button handler.  cease playback

- (IBAction) stopPlaying: (id) sender
{
    // stop playback
    [outputDevice deviceStop];
	
    // update the UI to turn off the 'stop' button
    [playStopButton setEnabled: NO];
	
} // stopPlaying



// slider action handler.  set the recording volume (the gain on the
// microphone)

- (IBAction) changeInputVolume: (id) sender
{
    // setting volume on channel zero (the master channel) doesn't
    // seem to affect the actual recording volume.  So set each
    // side of the input volume independently
	
    [inputDevice setVolume: [inputVolumeSlider floatValue]
				forChannel: 1
			  forDirection: kMTCoreAudioDeviceRecordDirection];
	
    [inputDevice setVolume: [inputVolumeSlider floatValue]
				forChannel: 2
			  forDirection: kMTCoreAudioDeviceRecordDirection];
	
} // changeInputVolume


// slider action handler.  set the playback volume.
- (IBAction) changeOutputVolume: (id) sender
{
    // setting volume on channel zero (the master channel) doesn't
    // seem to affect the actual playback volume.  So set each
    // side of the input volume independently
	
    [outputDevice setVolume: [outputVolumeSlider floatValue]
				 forChannel: 1
			   forDirection: kMTCoreAudioDevicePlaybackDirection];
	
    [outputDevice setVolume: [outputVolumeSlider floatValue]
				 forChannel: 2
			   forDirection: kMTCoreAudioDevicePlaybackDirection];
} // changeOutputVolume






@end




//@interface SoundInputGrabber (Private)
//
//- (BOOL)setUpAudioDevice;
//
//	static OSStatus ioProc(AudioDeviceID inDevice, const AudioTimeStamp* inNow, const AudioBufferList* inInputData, const AudioTimeStamp* inInputTime, AudioBufferList* outOutputData, const AudioTimeStamp* inOutputTime, void* inClientData);
//
//@end
//
//
//@implementation SoundInputGrabber

//- (id)initWithDelegate:(id)aDelegate callbackSelector:(SEL)aSel;
//{
//    if (!(self = [super init]))
//        return nil;
//	
//    nonretainedDelegate = aDelegate;
//    delegateCallbackSelector = aSel;
//	
//    if (!nonretainedDelegate || !delegateCallbackSelector || ![nonretainedDelegate respondsToSelector:delegateCallbackSelector]) {
//        [self release];
//        return nil;
//	}
//	
//    isRunning = NO;
//	
//    if (![self setUpAudioDevice]) {
//        [self release];
//        return nil;
//    }
//	
//    return self;
//}
//
//- (void)dealloc
//{
//    AudioDeviceRemoveIOProc(deviceID, ioProc);
//	
//    [super dealloc];
//}
//
//- (BOOL)start;
//{
//    OSStatus err;
//	
//    if (isRunning) {
//        NSLog(@"can't start because we're already running");
//        return NO;
//    }
//	
//    if ((err = AudioDeviceStart(deviceID, ioProc))) {
//        NSLog(@"AudioDeviceStart returned error: %lu", err);
//        return NO;
//	} else {
//        isRunning = YES;
//        return YES;
//    }
//}
//
//- (void)stop
//{
//    OSStatus err;
//	
//    if (!isRunning) {
//        NSLog(@"can't stop because we're not running");
//        return;
//    }
//	
//    isRunning = NO;
//	
//    if ((err = AudioDeviceStop(deviceID, ioProc))) {
//        NSLog(@"AudioDeviceStop returned error %lu", err);
//    }
//}
//
//- (BOOL)isRunning
//{
//    return isRunning;
//}
//
//- (AudioStreamBasicDescription)audioStreamDescription;
//{    
//    UInt32 size;
//    AudioStreamBasicDescription description;
//    OSStatus err;
//	
//    size = sizeof(description);
//    err = AudioDeviceGetProperty(deviceID, 0 /* channel 0 means "first stream" */, true /* is input */, kAudioDevicePropertyStreamFormat, &size, &description);
//    if (err) {
//        NSLog(@"error %lu from AudioDeviceGetProperty(kAudioDevicePropertyStreamFormat)", err);
//		
//        // zero out the description--not a very good way to return an error but better than nothing
//        // TODO need an alternative
//        bzero(&description, sizeof(description));
//    }
//	
//    return description;
//}
//
//@end
//
//@implementation SoundInputGrabber (Private)
//
//- (BOOL)setUpAudioDevice;
//{
//    OSStatus err;
//    UInt32 size;
//	
//    // get the default input device
//    size = sizeof(AudioDeviceID);
//    err = AudioHardwareGetProperty(kAudioHardwarePropertyDefaultInputDevice, &size, &deviceID);
//    if (err) {
//        NSLog(@"AudioHardwareGetProperty(kAudioHardwarePropertyDefaultInputDevice) returned error %ld", err);
//		return NO;
//    }
//	
//    // set up our ioproc
//    err = AudioDeviceAddIOProc(deviceID, ioProc, self);
//    if (err) {
//        NSLog(@"AudioDeviceAddIOProc returned error %ld", err);
//        return NO;
//    }
//	
//    // TODO We could specify that this ioproc is only interested in one particular input stream and no other data -- would be better for performance
//    
//    // TODO We should also subscribe to notifications from the device, and handle them
//    // and probably use an AU to convert to a stable format
//    
//    return YES;
//}
//
//
//OSStatus ioProc(AudioDeviceID inDevice, const AudioTimeStamp* inNow, const AudioBufferList* inInputData, const AudioTimeStamp* inInputTime, AudioBufferList* outOutputData, const AudioTimeStamp* inOutputTime, void* inClientData)
//{
//    // The buffer is only valid if the timestamp is nonzero.
//    if (inInputTime->mSampleTime != 0) {
//        SoundInputGrabber *self = (SoundInputGrabber *)inClientData;
//		
//        if (self->isRunning)
//            // Normally we'd do this:
//            //    [nonretainedDelegate performSelector:delegateCallbackSelector withObject:(id)&inInputData->mBuffers[0]]
//            // but that seems dubious because the 'object' is not really an object.
//            // It does work but I feel safer going down to the ObjC runtime level.
//            objc_msgSend(self->nonretainedDelegate, self->delegateCallbackSelector, &inInputData->mBuffers[0]);
//		// TODO we could maybe grab the implementation and call it directly ... would be faster
//    }
//	
////#if DEBUG && 0
//    // TODO just testing
//    {
//        static int printed = 0;
//        if (!printed) {
//            printed = 1;
//            NSLog(@"number of buffers: %lu", inInputData->mNumberBuffers);
//            NSLog(@"buffer 0 has %lu channels, %lu byte size", inInputData->mBuffers[0].mNumberChannels, inInputData->mBuffers[0].mDataByteSize);
//        }
//    }
////#endif    
//	
//    return noErr;    
//}
//
//@end
//
//




//
//#import <AudioToolbox/AudioFile.h>
//#import <AudioToolbox/AudioConverter.h>
//
////#include <CoreServices/CoreServices.h>
//#include <AudioUnit/AudioUnit.h>
//#include <AudioToolbox/AudioToolbox.h>
//#include <unistd.h>
//#include <stdio.h>
//#include <fcntl.h>
//#include <stdlib.h>
//
//static AudioConverterRef converter;
//static int stereo, samplerate, bufsize = 1024;
//static unsigned char *buffer;
//static unsigned char playbackIsFinished = 0;
//
//static OSStatus
//floatAudioConverterInput (AudioConverterRef inAudioConverter,
//						  UInt32 * ioNumberDataPackets,
//						  AudioBufferList * ioData,
//						  AudioStreamPacketDescription **
//						  outDataPacketDescription, void *inUserData)
//{
//	if (playbackIsFinished)
//		goto alldone;
//	ioData->mBuffers[0].mNumberChannels = stereo ? 2 : 1;
//	int packetsize = stereo ? 4 : 2;
//	if (packetsize * *ioNumberDataPackets > bufsize)
//    {
//		buffer = realloc (buffer, packetsize * *ioNumberDataPackets);
//		bufsize = packetsize * *ioNumberDataPackets;
//    }
//	int rdsize = read (STDIN_FILENO, buffer, packetsize * *ioNumberDataPackets);
//	if (rdsize == -1)
//    {
//		int e = errno;
//		if (e == EAGAIN || e == EINTR)
//		{
//			*ioNumberDataPackets = 0;
//			return 1;
//		}
//		else
//			goto alldone;
//    }
//	if (rdsize == 0)
//		goto alldone;
//	ioData->mBuffers[0].mData = buffer;
//	ioData->mBuffers[0].mDataByteSize = rdsize;
//	*ioNumberDataPackets = rdsize / packetsize;
//	return noErr;
//alldone:
//		playbackIsFinished = 1;
//	*ioNumberDataPackets = ioData->mBuffers[0].mDataByteSize = 0;
//	return 0;
//}
//
//
//static OSStatus
//myAudioConverterInput (AudioConverterRef inAudioConverter,
//					   UInt32 * ioNumberDataPackets,
//					   AudioBufferList * ioData,
//					   AudioStreamPacketDescription **
//					   outDataPacketDescription, void *inUserData)
//{
//	if (playbackIsFinished)
//		goto alldone;
//	ioData->mBuffers[0].mNumberChannels = stereo ? 2 : 1;
//	int packetsize = stereo ? 4 : 2;
//	if (packetsize * *ioNumberDataPackets > bufsize)
//    {
//		buffer = realloc (buffer, packetsize * *ioNumberDataPackets);
//		bufsize = packetsize * *ioNumberDataPackets;
//    }
//	int rdsize = read (STDIN_FILENO, buffer, packetsize * *ioNumberDataPackets);
//	if (rdsize == -1)
//    {
//		int e = errno;
//		if (e == EAGAIN || e == EINTR)
//		{
//			*ioNumberDataPackets = 0;
//			return 1;
//		}
//		else
//			goto alldone;
//    }
//	if (rdsize == 0)
//		goto alldone;
//	ioData->mBuffers[0].mData = buffer;
//	ioData->mBuffers[0].mDataByteSize = rdsize;
//	*ioNumberDataPackets = rdsize / packetsize;
//	return noErr;
//alldone:
//		playbackIsFinished = 1;
//	*ioNumberDataPackets = ioData->mBuffers[0].mDataByteSize = 0;
//	return 0;
//}
//
//static OSStatus
//myAURenderCallback (void *inRefCon,
//					AudioUnitRenderActionFlags * ioActionFlags,
//					const AudioTimeStamp * inTimeStamp,
//					UInt32 inBusNumber,
//					UInt32 inNumberFrames, AudioBufferList * ioData)
//{
//	UInt32 numDataPacketsNeeded = inNumberFrames;
//	AudioConverterFillComplexBuffer (converter, myAudioConverterInput, NULL,
//									 &numDataPacketsNeeded, ioData, NULL);
//	return noErr;
//}
//
//static void
//printaudiostream (const AudioStreamBasicDescription * as)
//{
//	printf ("sample rate: %f\n"
//			"format: %.4s\n"
//			"flags: %s%s%s%s%s%s%s\n"
//			"bytes per packet: %lu\n"
//			"frames per packet: %lu\n"
//			"bytes per frame: %lu\n"
//			"channels per frame: %lu\n"
//			"bits per channel: %lu\n\n",
//			as->mSampleRate,
//			&as->mFormatID,
//			as->mFormatFlags & kAudioFormatFlagIsFloat ? "float " : "",
//			as->mFormatFlags & kAudioFormatFlagIsBigEndian ? "be " : "",
//			as->mFormatFlags & kAudioFormatFlagIsSignedInteger ? "si " : "",
//			as->mFormatFlags & kAudioFormatFlagIsPacked ? "packed " : "",
//			as->
//			mFormatFlags & kAudioFormatFlagIsAlignedHigh ? "alignedhigh " : "",
//			as->
//			mFormatFlags & kAudioFormatFlagIsNonInterleaved ? "noninterleaved "
//															: "",
//			as->mFormatFlags & kAudioFormatFlagsAreAllClear ? "allclear " : "",
//			as->mBytesPerPacket, as->mFramesPerPacket, as->mBytesPerFrame,
//			as->mChannelsPerFrame, as->mBitsPerChannel);
//	
//}
//
//
//int
//main (int argc, char *argv[])
//{
//	stereo = atoi (argv[1]);
//	samplerate = atoi (argv[2]);
//	fcntl (STDIN_FILENO, F_SETFL, O_NONBLOCK);
//	buffer = malloc (4096);
//	AudioUnit soundOutU;
//	AudioStreamBasicDescription inFormat, outFormat;
//	ComponentDescription desc =
//    { kAudioUnitType_Output, kAudioUnitSubType_DefaultOutput, 0, 0, 0 };
//	Component c = FindNextComponent (NULL, &desc);
//	OpenAComponent (c, &soundOutU);
//	size_t s = sizeof (inFormat);
//	AudioUnitInitialize (soundOutU);
//	AudioUnitGetProperty (soundOutU, kAudioUnitProperty_StreamFormat,
//						  kAudioUnitScope_Output, 0, &outFormat, &s);
//	AudioUnitSetProperty (soundOutU, kAudioUnitProperty_StreamFormat,
//						  kAudioUnitScope_Input, 0, &outFormat, s);
//	
//	inFormat = (AudioStreamBasicDescription)
//	{
//		samplerate, kAudioFormatLinearPCM,
//		kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsBigEndian
//		| kLinearPCMFormatFlagIsPacked, stereo ? 4 : 2, 1, stereo ? 4 : 2,
//		stereo ? 2 : 1, 16, 0};
//	
//	printaudiostream (&inFormat);
//	printaudiostream (&outFormat);
//	AudioConverterNew (&inFormat, &outFormat, &converter);
//	if (!stereo && outFormat.mChannelsPerFrame == 2)
//    {
//		signed int chmap[2] = { 0, 0 };
//		AudioConverterSetProperty (converter, kAudioConverterChannelMap,
//								   sizeof (chmap), chmap);
//    }
//	unsigned int primeMethod = kConverterPrimeMethod_None;
//	AudioConverterSetProperty (converter, kAudioConverterPrimeMethod,
//							   sizeof (primeMethod), &primeMethod);
//	AURenderCallbackStruct callbackSetup;
//	callbackSetup.inputProc = myAURenderCallback;
//	AudioUnitSetProperty (soundOutU, kAudioUnitProperty_SetRenderCallback,
//						  kAudioUnitScope_Input, 0, &callbackSetup,
//						  sizeof (callbackSetup));
//	AudioOutputUnitStart (soundOutU);
//	while (!playbackIsFinished)
//    {
//		usleep (25000);
//    }
//	return 0;
//}