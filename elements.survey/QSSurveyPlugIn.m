//
//  QSSurveyPlugIn.m
//  QSSurveyPlugIn
//
//  Created by Nicholas Jitkoff on 10/11/07.
//  Copyright Blacktree Inc 2007. All rights reserved.
//

#import "QSSurveyPlugIn.h"
#import <Carbon/Carbon.h>

#define kQSSurveyResponse @"QSSurveyResponse"

NSString *QSGetPrimaryMACAddress();
@implementation QSSurveyPlugIn
+ (void)initialize {
  NSNumber *response = [[NSUserDefaults standardUserDefaults] objectForKey:kQSSurveyResponse];
  if (!response || GetCurrentKeyModifiers()&cmdKey) {
    NSLog(@"Loading Survey");
    [[self alloc] init];
  }
}


- (id) init
{
  self = [super init];
  if (self != nil) {
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(showRequest)
//                                                 name:NSApplicationDidFinishLaunchingNotification
//                                               object:nil];
    [self performSelector:@selector(showRequest) withObject:nil afterDelay:0.0];
    
    uuid = [[NSUserDefaults standardUserDefaults] stringForKey:@"QSSurveyID"];
    if (!uuid) {
      uuid = [NSString uniqueString];
      [[NSUserDefaults standardUserDefaults] setObject:uuid forKey:@"QSSurveyID"];
    }
    [uuid retain];
  }
  return self;
}
- (void) dealloc {
  [surveyRequestWindow release];
  [uuid release];
  [super dealloc];
}

- (void)showRequest {
  BOOL success = [NSBundle loadNibNamed:@"Survey" owner:self];
  [surveyRequestWindow center];
  [surveyRequestWindow makeKeyAndOrderFront:nil];
  [NSApp activateIgnoringOtherApps:YES];
  

}

- (IBAction)decline:(id)sender {
  [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kQSSurveyResponse];
  [[NSUserDefaults standardUserDefaults] synchronize];
  NSString *declineURLString = [NSString stringWithFormat:@"http://blacktree.textdriven.com/survey.php?decline=%@", uuid];
  
  NSLog(@"decline %@", declineURLString);
  NSURL *declineURL = [NSURL URLWithString:declineURLString];
  NSURLRequest *request = [NSURLRequest requestWithURL:declineURL];
  NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
  [surveyRequestWindow orderOut:nil];
}

- (IBAction)accept:(id)sender {
  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kQSSurveyResponse];
  [[NSUserDefaults standardUserDefaults] synchronize];
  
  NSString *scriptPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"Surveyor" ofType:@"pl"];
  NSTask *task = [NSTask launchedTaskWithLaunchPath:scriptPath arguments:[NSArray arrayWithObject:uuid]];

  [progessWindow setHidesOnDeactivate:NO];
  [progressLabel setStringValue:@"Collecting and Sending Data..."];
  [progessWindow center];
  [progessWindow orderFront:nil];
  [doneButton setTarget:progessWindow];
  [doneButton setAction:@selector(performClose:)];
  [progressIndicator startAnimation:nil]; 
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskComplete:) name:NSTaskDidTerminateNotification object:task];

  [surveyRequestWindow orderOut:nil];
}

- (void) taskComplete:(NSNotification *)notif {

  NSString *message = @"Your response was sent. Thanks!";
  NSTask *task = [notif object];  
  if ([task terminationStatus]) {
   message = @"An error occured. Your response will be retried later.";
  }
  NSLog(@"complete %d", [task terminationStatus]);
  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"QSSurveySent"];
  [progressLabel setStringValue:message];
  [progressIndicator stopAnimation:nil]; 
  [doneButton setHidden:NO];
}



- (BOOL)windowShouldClose:(id)sender {
//  [self decline:nil];
  return YES;
}
@end
