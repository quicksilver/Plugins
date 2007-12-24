/* QSWeatherPreferencePane */

#import <Cocoa/Cocoa.h>
#import "QSInterface/QSPreferencePane.h"

@interface QSWeatherPreferencePane : QSPreferencePane
{
    IBOutlet id debug;
    IBOutlet id station;
    IBOutlet id inferenceProgressIndicator;
}
-(IBAction)showHelp:(id)sender;
-(void)inferLatLong;
@end
