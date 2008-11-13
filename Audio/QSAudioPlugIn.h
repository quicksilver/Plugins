//
//  QSAudioPlugIn.h
//  QSAudioPlugIn
//
//  Created by Nicholas Jitkoff on 11/18/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//

#import <QSCore/QSObject.h>
#import "QSAudioPlugIn.h"

#import "MTCoreAudio.h"

@interface QSAudioPlugIn : NSWindowController
{
	IBOutlet NSSlider *inputVolumeSlider;
    IBOutlet NSSlider *outputVolumeSlider;
	
    IBOutlet NSButton *recordStopButton;
    IBOutlet NSButton *playStopButton;
	
    MTCoreAudioDevice *inputDevice;
    MTCoreAudioDevice *outputDevice;
}

- (IBAction) startRecording: (id) sender;
- (IBAction) stopRecording: (id) sender;

- (IBAction) startPlaying: (id) sender;
- (IBAction) stopPlaying: (id) sender;

- (IBAction) changeInputVolume: (id) sender;
- (IBAction) changeOutputVolume: (id) sender;

- (IBAction) done: (id) sender;

@end

#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudio.h>

@interface SoundInputGrabber : NSObject
{
    id nonretainedDelegate;
    SEL delegateCallbackSelector;
	
    BOOL isRunning;
    AudioDeviceID deviceID; 
}

- (id)initWithDelegate:(id)aDelegate callbackSelector:(SEL)aSel;
    // This class will send a message to the delegate when each buffer of audio data arrives.
    // (That message will be sent in the CoreAudio I/O thread.)
    // The delegate's callback should be something like this:
    // - (void)takeDataFromAudioInput:(AudioBuffer *)buffer;

- (BOOL)start;
- (void)stop;
- (BOOL)isRunning;

- (AudioStreamBasicDescription)audioStreamDescription;

@end