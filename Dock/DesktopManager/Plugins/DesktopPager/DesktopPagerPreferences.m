/* DesktopManager -- A virtual desktop provider for OS X
 *
 * Copyright (C) 2003, 2004 Richard J Wareham <richwareham@users.sourceforge.net>
 * This program is free software; you can redistribute it and/or modify it 
 * under the terms of the GNU General Public License as published by the Free 
 * Software Foundation; either version 2 of the License, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but 
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY 
 * or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License 
 * for more details.
 *
 * You should have received a copy of the GNU General Public License along 
 * with this program; if not, write to the Free Software Foundation, Inc., 675 
 * Mass Ave, Cambridge, MA 02139, USA.
 */
 
#import "DesktopPagerPreferences.h"
#import "DesktopPagerController.h"

@implementation DesktopPagerPreferences

- (BOOL) loadSkinInfo: (NSString*) skinFile {
	NSData *plistData;
	NSString *error;
	NSPropertyListFormat format;
	NSDictionary *plist;
	
	// NSLog(@"Loading %@ ...", skinFile);
	// See if the file is in our bundle.
	NSString *path = [[NSBundle bundleForClass: NSClassFromString(@"DesktopPagerView")] 
		pathForResource: skinFile ofType: @"plist"];
	if(path) {
		skinFile = path;
	}
		
	plistData = [NSData dataWithContentsOfFile: skinFile];
	if(!plistData) {
		NSLog(@"Error loading '%@'");
		return NO;
	}

	plist = [NSPropertyListSerialization propertyListFromData:plistData
                                mutabilityOption:NSPropertyListImmutable
                                format:&format
                                errorDescription:&error];

	if(!plist) {
		NSLog(@"Error loading skin (%@).", error);
		[error release];
		return NO;
	}
	
	[skinNameField setStringValue: [plist objectForKey: @"AuthorName"]];
	[skinAuthorField setStringValue: [plist objectForKey: @"AuthorURL"]];
	
	NSImage *bgImage = [[NSImage alloc] initWithData: [plist objectForKey: @"PagerBackground"]];
	[skinImage setImage: bgImage];
	[bgImage autorelease];
	
	return YES;
}

- (void) awakeFromNib {	
	// See if the file is in our bundle.
	NSString *skinFile = [[NSUserDefaults standardUserDefaults] stringForKey: PREF_DESKTOPPAGER_SKIN];
	
	if(skinFile) { [self loadSkinInfo: skinFile]; }
	
	[pagerRowsField takeIntValueFrom: pagerRowsStepper];
}

- (void) resetSkin: (id) sender {
	if(![self loadSkinInfo: PREF_DESKTOPPAGER_SKIN_DEFAULT]) { return; }
	[[NSUserDefaults standardUserDefaults] setObject: PREF_DESKTOPPAGER_SKIN_DEFAULT
		forKey: PREF_DESKTOPPAGER_SKIN ];
}

- (void) chooseSkin: (id) sender {
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	NSArray *filetypes = [NSArray arrayWithObject: @"plist"];
	
	[openPanel setCanChooseDirectories: NO];
	[openPanel beginSheetForDirectory: nil file: nil types: filetypes
		modalForWindow: [[self mainView] window] modalDelegate: self 
		didEndSelector: @selector(chooseSkinPanelDidEnd:returnCode:contextInfo:) contextInfo: self];
}

- (void) chooseSkinPanelDidEnd: (NSOpenPanel*) sheet 
	returnCode: (int) returnCode contextInfo: (void*) contextInfo {
	
	if(returnCode == NSCancelButton) { return; }
	
	if(![self loadSkinInfo: [sheet filename]]) { return; }
	
	[[NSUserDefaults standardUserDefaults] setObject: [sheet filename]
		forKey: PREF_DESKTOPPAGER_SKIN ];
}

@end
