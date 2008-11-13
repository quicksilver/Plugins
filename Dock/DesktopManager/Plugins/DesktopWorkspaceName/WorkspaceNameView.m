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

#import "WorkspaceNameView.h"
#import "DesktopWorkspaceNamesController.h"

@implementation WorkspaceNameView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		_name = nil;
		
		NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
	
		NSSize offset;
		offset.width = 0; offset.height = -1;
		[shadow setShadowColor: [NSColor blackColor]];
		[shadow setShadowOffset: offset];
		[shadow setShadowBlurRadius: 3];
	
		_attrs = [[NSDictionary dictionaryWithObjectsAndKeys:
			[NSColor whiteColor], NSForegroundColorAttributeName,
			[NSFont boldSystemFontOfSize: 13], NSFontAttributeName,
			shadow, NSShadowAttributeName,
		nil ] retain];
    }
    return self;
}

- (void) dealloc {
	if(_name) { [_name release]; }
	if(_attrs) { [_attrs release]; }
	[super dealloc];
}

- (BOOL) isOpaque { return NO; }
- (NSString*) name { return _name; }
- (void) setName: (NSString*) name {
	if(_name) { [_name release]; }
	_name = [name retain];
	
	//NSSize size = [name sizeWithAttributes: _attrs];
	//size.width += 10; size.height += 10;
	//[self setFrameSize: size];
}

- (BOOL) isFlipped { return YES; }

- (void)drawRect:(NSRect)rect {
	if(!_name) { return; }
	
	BOOL leftCorner = [[NSUserDefaults standardUserDefaults] 
		boolForKey: PREF_DESKTOPNAME_LEFTCORNER];
	BOOL topCorner = [[NSUserDefaults standardUserDefaults] 
		boolForKey: PREF_DESKTOPNAME_TOPCORNER];
	
    [[NSColor clearColor] set];
	NSRectFill(rect);
	NSPoint location;
	NSSize textSize = [_name sizeWithAttributes: _attrs];
	if(leftCorner) { 
		location.x = 10; 
	} else {
		location.x = [self frame].size.width - 10 - textSize.width;
	}
	if(topCorner) { 
		location.y = 10;
	} else {
		location.y = [self frame].size.height - 10 - textSize.height;
	}
	[_name drawAtPoint: location withAttributes: _attrs];
}

@end
