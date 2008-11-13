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

#import "DesktopManager.h"
#import "DesktopPagerView.h"
#import "DesktopPagerController.h"
#import "DesktopPagerCell.h"

@implementation DesktopPagerView

- (id)initWithFrame:(NSRect)frame controller: (WorkspaceController*) controller {
    self = [super initWithFrame:frame];
    if (self) {
		loadedSkin = [[NSString string] retain];
		defaultController = controller;
	
		targetHeight = 100;
	
		blImage = brImage = bcImage = nil;
		tlImage = trImage = tcImage = nil;
		lsImage = rsImage = bgImage = nil;
		closeImage = prefImage = nil;
				
		[self setAutoresizesSubviews: YES];
			
		frame.size.width = frame.size.height = 10;
		frame.origin.x = 0; frame.origin.y = [self bounds].size.height - 10;
		closeButton = [[NSButton alloc] initWithFrame: frame];
		[closeButton setButtonType: NSMomentaryChangeButton];
		[closeButton setBordered: NO];
		[closeButton setAutoresizingMask: NSViewMaxXMargin | NSViewMinYMargin ];
		[closeButton setTitle: @""]; [closeButton setImagePosition: NSImageOnly];
		[self addSubview: closeButton];
			
		frame.size.width = frame.size.height = 10;
		frame.origin.x = ([self bounds].size.width - 10) / 2; 
		frame.origin.y = 0;
		prefButton = [[NSButton alloc] initWithFrame: frame];
		[prefButton setButtonType: NSMomentaryChangeButton];
		[prefButton setBordered: NO];
		[prefButton setAutoresizingMask: NSViewMaxXMargin | NSViewMinXMargin | NSViewMaxYMargin ];
		[prefButton setTitle: @""]; [prefButton setImagePosition: NSImageOnly];
		[self addSubview: prefButton];
		
		pagerMatrix = [[NSMatrix alloc] initWithFrame: frame];
        [pagerMatrix setCellClass: NSClassFromString(@"DesktopPagerCell")];
		NSSize size;
        size.width = size.height = 0;
        [pagerMatrix setIntercellSpacing: size];
        [pagerMatrix setMode: NSRadioModeMatrix];
		
		[self addSubview: pagerMatrix];
		
        // Register for preferences changed notifications
		[[NSNotificationCenter defaultCenter] addObserver: self
			selector: @selector(readPreferences) name: NOTIFICATION_PREFSCHANGED
			object: nil];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
            selector: @selector(setNeedsDisplay)
            name: NOTIFICATION_WORKSPACESELECTED
            object: nil
        ];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
            selector: @selector(setNeedsDisplay)
            name: NOTIFICATION_WINDOWLAYOUTUPDATED
            object: nil
        ];
						
		[self readPreferences];
    }

    return self;
}

- (void) setNeedsDisplay {
	[self setNeedsDisplay: YES];
}

- (void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver: self];

	if(pagerMatrix) { [pagerMatrix release]; }
	if(closeButton) { [closeButton release]; }
	if(prefButton) { [prefButton release]; }

	if(bgImage) { [bgImage release]; }
	if(brImage) { [brImage release]; }
	if(bcImage) { [bcImage release]; }
	if(blImage) { [blImage release]; }
	if(trImage) { [trImage release]; }
	if(tcImage) { [tcImage release]; }
	if(tlImage) { [tlImage release]; }
	if(lsImage) { [lsImage release]; }
	if(rsImage) { [rsImage release]; }
	if(closeImage) { [closeImage release]; }
	if(prefImage) { [prefImage release]; }
	if(loadedSkin) { [loadedSkin release]; }
	
	[super dealloc];
}

- (NSRect) pagerFrame {
	NSRect pagerFrame = [self frame];
	
	pagerFrame.origin.x = [lsImage size].width;
	pagerFrame.origin.y = [bcImage size].height;
	pagerFrame.size.width -= [lsImage size].width + [rsImage size].width;
	pagerFrame.size.height -= [bcImage size].height + [tcImage size].height;
	
	return pagerFrame;
}

- (NSSize) sizeFromPagerSize: (NSSize) pagerSize {
	NSSize size;
	size.width = pagerSize.width + [blImage size].width + [trImage size].width;
	size.height = pagerSize.height + [blImage size].height + [trImage size].height;
	
	return size;
}

- (void) updatePagerLayout {
	int numberPagerRows = [[NSUserDefaults standardUserDefaults] 
		integerForKey: PREF_DESKTOPPAGER_ROWS ];
	
	if(!pagerMatrix) { return; }
	
	WorkspaceController *wsController = defaultController;
		
	int workspaceCount = [wsController workspaceCount];
	int columns = workspaceCount / numberPagerRows;
	if(columns * numberPagerRows <  workspaceCount) { columns++; }
	
    [pagerMatrix renewRows: numberPagerRows columns: columns];
    
    int i, row, column;
	row = column = 0;
    for(i=0; i<numberPagerRows * columns; i++) {
        DesktopPagerCell *cell = [pagerMatrix cellAtRow: row column: column];
        
		if(i < [wsController workspaceCount]) {
			[cell setRepresentedObject: [wsController workspaceAtIndex: i]];
		}
		
		[cell setTargetHeight: targetHeight];
		
		column++; if(column >= columns) { row++; column=0; }
    }
    
    [pagerMatrix sizeToFit];
	
	NSSize pagerSize = [self sizeFromPagerSize: [pagerMatrix frame].size];
	[self setFrameSize: pagerSize];
	[[self window] setContentSize: pagerSize];
	
	NSPoint loc;	
	loc.x = 0; loc.y = [self frame].size.height - [tlImage size].height;
	[closeButton setFrameOrigin: loc];
	
	loc.x = ([pagerMatrix frame].size.width - [prefImage size].width) / 2; loc.y = 0;
	loc.x += [pagerMatrix frame].origin.x;
	[prefButton setFrameOrigin: loc];
}

- (void) readPreferences {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *skinFile = [defaults stringForKey: PREF_DESKTOPPAGER_SKIN];
	
	if(![loadedSkin isEqualToString: skinFile]) {
		if(![self loadSkin: skinFile]) {
			[self loadSkin: PREF_DESKTOPPAGER_SKIN_DEFAULT];
		}
	}
	
	[self updatePagerLayout];
}

- (BOOL) loadSkin: (NSString*) skinFile {
	NSData *plistData;
	NSString *error;
	NSPropertyListFormat format;
	NSDictionary *plist;
	
	// NSLog(@"Loading %@ ...", skinFile);
	
	// See if the file is in our bundle.
	NSString *path = [[NSBundle bundleForClass: [self class]] pathForResource: skinFile ofType: @"plist"];
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
	
	//NSLog(@"Author Name: %@", [plist objectForKey: @"AuthorName"]);
	//NSLog(@"Author URL: %@", [plist objectForKey: @"AuthorURL"]);
	
	if(blImage) { [blImage release]; }
	blImage = [[NSImage alloc] initWithData: [plist objectForKey: @"BottomLeft"]];
	if(brImage) { [brImage release]; }
	brImage = [[NSImage alloc] initWithData: [plist objectForKey: @"BottomRight"]];
	if(bcImage) { [bcImage release]; }
	bcImage = [[NSImage alloc] initWithData: [plist objectForKey: @"BottomCenter"]];
	if(tlImage) { [tlImage release]; }
	tlImage = [[NSImage alloc] initWithData: [plist objectForKey: @"TopLeft"]];
	if(trImage) { [trImage release]; }
	trImage = [[NSImage alloc] initWithData: [plist objectForKey: @"TopRight"]];
	if(tcImage) { [tcImage release]; }
	tcImage = [[NSImage alloc] initWithData: [plist objectForKey: @"TopCenter"]];
	if(lsImage) { [lsImage release]; }
	lsImage = [[NSImage alloc] initWithData: [plist objectForKey: @"LeftSide"]];
	if(rsImage) { [rsImage release]; }
	rsImage = [[NSImage alloc] initWithData: [plist objectForKey: @"RightSide"]];
	if(closeImage) { [closeImage release]; }
	closeImage = [[NSImage alloc] initWithData: [plist objectForKey: @"CloseWidget"]];
	if(prefImage) { [prefImage release]; }
	prefImage = [[NSImage alloc] initWithData: [plist objectForKey: @"PrefWidget"]];
	if(bgImage) { [bgImage release]; }
	bgImage = [[NSImage alloc] initWithData: [plist objectForKey: @"PagerBackground"]];
	
	NSPoint pagerOrigin;
	pagerOrigin.x = [lsImage size].width; pagerOrigin.y = [bcImage size].height;
	[pagerMatrix setFrameOrigin: pagerOrigin];

	[closeButton setImage: closeImage];
	[closeButton setFrameSize: [closeImage size]];
	[prefButton setImage: prefImage];
	[prefButton setFrameSize: [prefImage size]];

	[self updatePagerLayout];
	
	if(loadedSkin) { [loadedSkin release]; }
	loadedSkin = [skinFile retain];
	
	return YES;
}

- (void) drawRect:(NSRect)rect {
	NSRect srcRect;
	NSRect destRect;
	NSPoint dest;
	
	srcRect.origin.x = srcRect.origin.y;
	
	srcRect.size = [bgImage size];
    [bgImage drawInRect: [self pagerFrame] fromRect: srcRect
		operation: NSCompositeSourceOver fraction: 1.0];
		
	srcRect.size = [blImage size]; 
	dest.x = 0; dest.y = 0;
	[blImage drawAtPoint: dest fromRect: srcRect operation: NSCompositeSourceOver fraction: 1.0];
	srcRect.size = [lsImage size]; 
	destRect.origin.x = 0; destRect.origin.y = [blImage size].height;
	destRect.size.width = [lsImage size].width; 
	destRect.size.height = [self bounds].size.height - [blImage size].height - [tlImage size].height;
	[lsImage drawInRect: destRect fromRect: srcRect operation: NSCompositeSourceOver fraction: 1.0];
	srcRect.size = [tlImage size]; 
	dest.x = 0; dest.y = [self bounds].size.height - [tlImage size].height;
	[tlImage drawAtPoint: dest fromRect: srcRect operation: NSCompositeSourceOver fraction: 1.0];
		
	srcRect.size = [brImage size]; 
	dest.x = [self bounds].size.width - [brImage size].width; dest.y = 0;
	[brImage drawAtPoint: dest fromRect: srcRect operation: NSCompositeSourceOver fraction: 1.0];
	srcRect.size = [rsImage size]; 
	destRect.origin.x = [self bounds].size.width - [rsImage size].width; destRect.origin.y = [brImage size].height;
	destRect.size.width = [rsImage size].width; 
	destRect.size.height = [self bounds].size.height - [brImage size].height - [trImage size].height;
	[rsImage drawInRect: destRect fromRect: srcRect operation: NSCompositeSourceOver fraction: 1.0];
	srcRect.size = [trImage size]; 
	dest.x = [self bounds].size.width - [trImage size].width; dest.y = [self bounds].size.height - [trImage size].height;
	[trImage drawAtPoint: dest fromRect: srcRect operation: NSCompositeSourceOver fraction: 1.0];

	srcRect.size = [tcImage size]; 
	destRect.origin.x = [tlImage size].width; 
	destRect.origin.y = [self bounds].size.height - [tcImage size].height;
	destRect.size.width = [self bounds].size.width - [tlImage size].width - [trImage size].width; 
	destRect.size.height = [tcImage size].height;
	[tcImage drawInRect: destRect fromRect: srcRect operation: NSCompositeSourceOver fraction: 1.0];
	srcRect.size = [bcImage size]; 
	destRect.origin.x = [blImage size].width; 
	destRect.origin.y = 0;
	destRect.size.width = [self bounds].size.width - [blImage size].width - [brImage size].width; 
	destRect.size.height = [bcImage size].height;
	[bcImage drawInRect: destRect fromRect: srcRect operation: NSCompositeSourceOver fraction: 1.0];
}

- (void) setCloseTarget: (id) target {
	[closeButton setTarget: target];
}

- (void) setCloseAction: (SEL) action {
	[closeButton setAction: action];
}

- (void) setPrefTarget: (id) target {
	[prefButton setTarget: target];
}

- (void) setPrefAction: (SEL) action {
	[prefButton setAction: action];
}

- (BOOL) mouseDownCanMoveWindow {
	return YES;
}

- (void) setTargetHeight: (int) height {
	if(targetHeight == height) { return; }
	
	targetHeight = height;

	[self updatePagerLayout];
}

- (int) targetHeight {
	return targetHeight;
}

@end
