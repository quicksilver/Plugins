/* Controller */

#import <Cocoa/Cocoa.h>
#import <CoreAudio/CoreAudio.h>

typedef struct MyUserInfo MyUserInfo;
struct MyUserInfo
{
	double			sampleRate;			// (Float64)
	unsigned long	bytesPerFrame;
	unsigned long	channelsPerFrame;
	unsigned long	bitsPerChannel;

	// user-variables:
	float			lastPosition;
	float			lastPosition2;
	float			frequency;
	float			frequency2;
        
	float			duration;
	float			volume;
};

@interface QSSpeakerPhoneDialer : NSObject{
	AudioDeviceID	outputDevice;
	MyUserInfo      *myUserInfo;
}

+ (id)sharedInstance;
- (BOOL)dialString:(NSString *)string;
@end


