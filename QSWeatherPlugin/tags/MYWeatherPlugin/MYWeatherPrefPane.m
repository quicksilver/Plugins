#import "MYWeatherPrefPane.h"

@implementation MYWeatherPrefPane

-(id)init
{
	self = [super initWithBundle:[
		NSBundle bundleForClass:[MYWeatherPrefPane class]]];
	/*if(self) {
	}*/
	return self;
}	

- (NSString *) mainNibName
{
	return @"MYWeatherPrefPane";
}

- (void)mainViewDidLoad
{
}
- (IBAction)viewHelp:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:
		[NSURL URLWithString:@"http://www.nws.noaa.gov/data/current_obs/"]];
}
-(NSString *) paneName
{
	return @"Weather";
}
@end
