#import "QSSpeakerPhoneDialer.h"

#define FADEIN 3.0
#define FADEOUT 0.0
#define DURATION 0.2
#define PAUSE 0.05

@implementation QSSpeakerPhoneDialer
+ (id)sharedInstance{
    static id _sharedInstance;
    if (!_sharedInstance) _sharedInstance = [[[self class] allocWithZone:[self zone]] init];
    return _sharedInstance;
}

- (BOOL)removePlaybackCallback:(void *)outputCallback{
    OSStatus					err;
    UInt32						property_size;
	//  AudioStreamBasicDescription	outputStreamDescription;
	//   double						sampleRate;
    
    outputDevice = 0;
    property_size = sizeof(AudioDeviceID);
	err =AudioDeviceStop(outputDevice, outputCallback);
	if (err)NSLog(@"unable to stop");
    err = AudioDeviceRemoveIOProc(outputDevice, outputCallback);
    if (err)NSLog(@"unable to remove");
    return(YES);
}

- (BOOL)setupPlaybackCallback:(void *)outputCallback userInfo:(MyUserInfo *)userInfo{
    OSStatus					err;
    UInt32						property_size;
    AudioStreamBasicDescription	outputStreamDescription;
	//   double						sampleRate;
    
    outputDevice = 0;
    property_size = sizeof(AudioDeviceID);
    err = AudioHardwareGetProperty(kAudioHardwarePropertyDefaultOutputDevice, &property_size, &outputDevice);
    if(kAudioDeviceUnknown != outputDevice && kAudioHardwareNoError == err)
    {
        err = AudioDeviceAddIOProc(outputDevice, outputCallback, userInfo);
        if(kAudioHardwareNoError == err)
        {
            property_size = sizeof(outputStreamDescription);
            err = AudioDeviceGetProperty(outputDevice, 0, FALSE, kAudioDevicePropertyStreamFormat, &property_size, &outputStreamDescription);
            if(kAudioHardwareNoError == err)
            {
                return(YES);
            }
        }
    }
    return(NO);
}



OSStatus playbackCallback(AudioDeviceID device, const AudioTimeStamp *now, const AudioBufferList *input_data, const AudioTimeStamp *input_time, AudioBufferList *output_data, const AudioTimeStamp *output_time, void *client_data)
{
    register int		channels;
    register int		frames;
    register float		left;
    register float		right;
    register float		*new_data;
    register float		position;
    register float		position2;
    register float		volume;
    register float		incr;
    register float		incr2;
    register MyUserInfo	*userInfo;
    
    userInfo = (MyUserInfo *)client_data;
    
    new_data = (float *)(output_data->mBuffers[0].mData);				// Get pointer to the output buffer (here we store the data we want to be played)
    channels = output_data->mBuffers[0].mNumberChannels;				// Get number of channels
    frames = (output_data->mBuffers[0].mDataByteSize / sizeof(float)) / channels;	// Get number of frames we can store. Note: I assume we'll always get the data as floats, change the sizeof(float) if you expect data of another size!
    
    
    
    volume = userInfo->volume;
    incr = userInfo->frequency / 44100.0;
    incr2 = userInfo->frequency2 / 44100.0;
    
    position = userInfo->lastPosition;
    position2 = userInfo->lastPosition2;
    printf("data, %f",position);
    while(frames--){ // I assume 2 channels, non-interleaved, float32 format!
        left = sin(position * 2.0 * M_PI)/2;
        left+=sin(position2 * 2.0 * M_PI)/2;
        left*= volume;
        if (position<FADEIN)
            left *=(position/FADEIN);
        position += incr;
        position2 += incr2;
        
        
        right = left;
        *new_data++ = left;
        *new_data++ = right;
    }
    userInfo->lastPosition = position;
    userInfo->lastPosition2 = position2;
    
    return(kAudioHardwareNoError);
}

- (id)init
{
    self = [super init];
    if(self)
    {
        myUserInfo = (MyUserInfo *) malloc(sizeof(MyUserInfo));
        memset(myUserInfo, 0, sizeof(*myUserInfo));
        
        myUserInfo->lastPosition = 0.0;		// internal variable
        myUserInfo->frequency = 1000.0;		// tone frequency
        myUserInfo->volume = 0.215;			// tone volume
        
        
        [self setupPlaybackCallback:playbackCallback userInfo:myUserInfo];
    }
    return(self);
}
- (void)dealloc{
    [self removePlaybackCallback:playbackCallback];
    free(myUserInfo);
}

- (BOOL)dialString:(NSString *)string{
    OSStatus	err;
    
    const char *sequence=[string UTF8String];
    char c;
    
    int i;
    for(i=0;sequence[i];i++){
        c=sequence[i];
		//  NSLog(@"playchar %c",c);
        
        
        
        switch (c){
            case 'a': case 'b': case 'c':
            case 'A': case 'B': case 'C':
                c='2';
                break;
            case 'd': case 'e': case 'f':
            case 'D': case 'E': case 'F':
                c='3';
                break;
            case 'g': case 'h': case 'i':
            case 'G': case 'H': case 'I':
                c='4';
                break;
            case 'j': case 'k': case 'l':
            case 'J': case 'K': case 'L':
                c='5';
                break;
            case 'm': case 'n': case 'o':
            case 'M': case 'N': case 'O':
                c='6';
                break;
            case 'p': case 'q': case 'r': case 's':
            case 'P': case 'Q': case 'R': case 'S':
                c='7';
                break;
            case 't': case 'u': case 'v':
            case 'T': case 'U': case 'V':
                c='8';
                break;
            case 'w': case 'x': case 'y': case 'z':
            case 'W': case 'X': case 'Y': case 'Z':
                c='8';
                break;
            case ',':
                [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];      
                continue;
                
        }
        switch (c){
            case '1': case '2': case '3':
                myUserInfo->frequency = 697.0;
                break;
            case '4': case '5': case '6':
                myUserInfo->frequency = 770.0;
                break;
            case '7':  case '8': case '9':
                myUserInfo->frequency = 852.0;
                break;
            case '0': case '*': case '#':
                myUserInfo->frequency = 941.0;
                break;
            default:
                continue;
        }
        switch (c){
            case '1': case '4':  case '7': case '*':
                myUserInfo->frequency2 = 1209.0;
                break;
            case '2': case '5': case '8': case '0':
                myUserInfo->frequency2 = 1336.0;
                break;
            case '3': case '6': case '9': case '#':
                myUserInfo->frequency2 = 1477.0;
                break;
        }
        
        myUserInfo->volume=1.0;
        myUserInfo->lastPosition = 0.0;
        myUserInfo->lastPosition2 = 0.0;
        err = AudioDeviceStart(outputDevice, playbackCallback);
        if(kAudioHardwareNoError == err)
        {
            [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:DURATION]];    
            float f;
			if (FADEOUT>0.0){
				for (f=1.0;f>=0.0;f-=0.1){
					myUserInfo->volume=f;
					[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:FADEOUT/10]]; 
				}
			}
        }
		
        
        err = AudioDeviceStop(outputDevice, playbackCallback);
        if(kAudioHardwareNoError == err);
		
		[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:PAUSE]]; 
    }
    return YES;
}


@end
