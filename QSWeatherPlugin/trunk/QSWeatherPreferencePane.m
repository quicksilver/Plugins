#import "QSWeatherPreferencePane.h"

@implementation QSWeatherPreferencePane

-(NSString *) mainNibName
{
    return @"QSWeatherPlugin_PrefPane";
}
- (IBAction)showHelp:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:
		[NSURL URLWithString:@"http://www.nws.noaa.gov/data/current_obs/"]];
}
- (void)controlTextDidEndEditing:(NSNotification *)aNotification
{
    [self inferLatLong];
}
-(void)inferLatLong
{
    NSLog(@"Attempting to infer Lat/Long");
    [inferenceProgressIndicator startAnimation:self];
	
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *targetStation = [[defaults objectForKey:@"QSWeatherStation"] uppercaseString];
	
	NSString *url = [NSString stringWithFormat:@"http://www.nws.noaa.gov/data/current_obs/%@.xml",
		targetStation];
    NSXMLDocument *xml = [[NSXMLDocument alloc] initWithContentsOfURL:
        [NSURL URLWithString:url] options:nil error:nil];
    NSString *xpath = @".//latitude/text() | //longitude/text()";
    NSArray *nodes = [xml nodesForXPath:xpath error:nil];
    if([nodes count]<1) {
        NSLog(@"Error");
    } else {
        [defaults setObject:[NSString stringWithFormat:@"%@",[nodes objectAtIndex:0]]
            forKey:@"QSWeatherLatitude"];
        [defaults setObject:[NSString stringWithFormat:@"%@",[nodes objectAtIndex:1]]
            forKey:@"QSWeatherLongitude"];
    }
    [xml release];
    [inferenceProgressIndicator stopAnimation:self];
}
@end
