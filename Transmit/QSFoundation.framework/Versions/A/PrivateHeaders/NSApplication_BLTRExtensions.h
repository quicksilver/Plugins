//
//  NSApplication_Extensions.h
//  Daedalus
//
//  Created by Nicholas Jitkoff on Thu May 01 2003.
//  Copyright (c) 2003 Blacktree, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSApplication (Info)
- (NSString *)versionString;
- (int)featureLevel;
@end

@interface NSApplication (Focus)
- (BOOL) stealKeyFocus;
- (BOOL) releaseKeyFocus;
@end


@interface NSApplication (Relaunching)
-(IBAction)relaunch:(id)sender;
- (void)requestRelaunch:(id)sender;
-(void)relaunchFromPath:(NSString *)path;
-(void)relaunchAfterMovingFromPath:(NSString *)newPath;
-(void)relaunchAtPath:(NSString *)launchPath movedFromPath:(NSString *)newPath;
@end

@interface NSApplication (LSUIElementManipulation)
-(BOOL)shouldBeUIElement;
-(BOOL)setShouldBeUIElement:(BOOL)hidden;
@end



