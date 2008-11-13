//
//  QSPatchPlugIn.m
//  QSPatchPlugIn
//
//  Created by Nicholas Jitkoff on 5/16/07.
//  Copyright Blacktree 2007. All rights reserved.
//

#import "QSPatchPlugIn.h"
#import "NSEvent+BLTRExtensions.h"
@implementation QSProcessMonitor (Patch)
+ (void)initialize {
  NSLog(@"Using QSProcessMonitor Patch"); 
}
- (NSDictionary *)infoForPSN:(ProcessSerialNumber)processSerialNumber {
  NSDictionary *dict = (NSDictionary *)ProcessInformationCopyDictionary(&processSerialNumber,kProcessDictionaryIncludeAllInformationMask);	
  dict = [[[dict autorelease] mutableCopy] autorelease];
  
  [dict setValue:[dict objectForKey:@"CFBundleName"]
          forKey:@"NSApplicationName"];
  
  [dict setValue:[dict objectForKey:@"BundlePath"]
          forKey:@"NSApplicationPath"];
  
  [dict setValue:[dict objectForKey:@"CFBundleIdentifier"]
          forKey:@"NSApplicationBundleIdentifier"];
  
  [dict setValue:[dict objectForKey:@"pid"]
          forKey:@"NSApplicationProcessIdentifier"];
  
  [dict setValue:[NSNumber numberWithLong:processSerialNumber.highLongOfPSN]
          forKey:@"NSApplicationProcessSerialNumberHigh"];
  
  [dict setValue:[NSNumber numberWithLong:processSerialNumber.lowLongOfPSN]
          forKey:@"NSApplicationProcessSerialNumberLow"];
  
	return dict;
}


- (BOOL)handleProcessEvent:(NSEvent *)theEvent{
	ProcessSerialNumber psn;
	psn.highLongOfPSN=[theEvent data1];
	psn.lowLongOfPSN=[theEvent data2];
	
	NSDictionary *processInfo = [self infoForPSN:psn];
  
  switch ([theEvent subtype]){
		case NSProcessDidLaunchSubType:
			if (![[NSUserDefaults standardUserDefaults]boolForKey:@"QSShowBackgroundProcesses"]) return YES;
      BOOL background=[[processInfo objectForKey:@"LSUIElement"]boolValue]||[[processInfo objectForKey:@"LSBackgroundOnly"]boolValue];
			if (!background) return YES;
				[self addProcessWithDict: processInfo];
			break;
		case NSProcessDidTerminateSubType:
			[self removeProcessWithPSN:psn];
			break;
		case NSFrontProcessSwitched:
			[[NSNotificationCenter defaultCenter] postNotificationName:@"QSActiveApplicationChanged" object: processInfo];
			[self appChanged:nil];
			break;
		default:
      break;
	}
	return YES;
};


@end
