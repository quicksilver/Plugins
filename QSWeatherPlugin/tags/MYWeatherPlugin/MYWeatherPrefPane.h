/* MYWeatherPrefPane */

#import <Cocoa/Cocoa.h>
#import <PreferencePanes/NSPreferencePane.h>

@interface MYWeatherPrefPane : NSPreferencePane
{
	IBOutlet id debug;
	IBOutlet id refreshInterval;
    IBOutlet id station;
}
- (IBAction)viewHelp:(id)sender;
@end
