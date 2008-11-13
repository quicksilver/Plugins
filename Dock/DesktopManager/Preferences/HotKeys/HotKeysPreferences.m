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

#import "HotKeysPreferences.h"
#import "DesktopManager.h"

@interface HotKeyTextView : NSTextView {
	HotKey *_hotKey;
	NSButton *_delButton;
}

- (void) setHotKey: (HotKey*) hotKey;
- (HotKey*) hotKey;

@end

@implementation HotKeyTextView

- (id) initWithFrame: (NSRect) rect {
	id myself = [super initWithFrame: rect];
	if(myself) {
		_hotKey = nil;
		_delButton = [[NSButton alloc] initWithFrame: NSMakeRect(0,0,10,10)];
		[_delButton setImage: [NSImage imageNamed: @"hotKeyMinus"]];
		[_delButton setImagePosition: NSImageOnly];
		[_delButton setBordered: NO];
		[_delButton setButtonType: NSMomentaryLight];
		[self addSubview: _delButton];
		
		[_delButton setTarget: self];
		[_delButton setAction: @selector(clearHotKey:)];
	}
	return myself;
}

- (void) dealloc {
	if(_hotKey) {
		[_hotKey autorelease];
	}
	[_delButton autorelease];
	[super dealloc];
}

- (void) clearHotKey: (id) sender {
	if(!_hotKey) {
		return;
	}
	
	[_hotKey setEnabled: NO];
	[_delButton setEnabled: NO];
	[self setString: [_hotKey stringRepresentation]];
}

- (void) setHotKey: (HotKey*) hotKey {
	if(_hotKey) {
		[_hotKey autorelease];
	}
	_hotKey = [[hotKey copyWithZone: nil] retain];
	[_delButton setEnabled: [_hotKey enabled]];
}

- (HotKey*) hotKey {
	return _hotKey;
}

- (void) keyDown: (NSEvent*) event {
	[_hotKey setKeycode: [event keyCode]];
	[_hotKey setModifiers: [event modifierFlags]];
	[_hotKey setEnabled: YES];
	
	[self setString: [_hotKey stringRepresentation]];
	[self selectAll: self];
	[_delButton setEnabled: YES];
	[[self window] makeFirstResponder: [self superview]];
}

- (BOOL)performKeyEquivalent:(NSEvent *)theEvent {
	[self keyDown: theEvent];
	return YES;
}

- (void) frameChanged {
	// Frame changed, resize delete button
	NSRect newFrame = [self frame];
	newFrame.origin.x = newFrame.size.width - newFrame.size.height;
	newFrame.origin.y = 0;
	newFrame.size.width = newFrame.size.height;
	[_delButton setFrame: newFrame];
}

- (void) setFrame: (NSRect) frame {
	[super setFrame: frame];
	[self frameChanged];
}

- (void) setFrameSize: (NSSize) size {
	[super setFrameSize: size];
	[self frameChanged];
}

- (void) setFrameOrigin: (NSPoint) origin {
	[super setFrameOrigin: origin];
	[self frameChanged];
}

@end

@interface HotKeyCell : NSTextFieldCell {
}
@end

@implementation HotKeyCell 

- (void) setObjectValue: (id) object {
	if([object isKindOfClass: [HotKey class]]) {
		[super setObjectValue: [(HotKey*)object stringRepresentation]];
		[self setRepresentedObject: object];
		[self setEditable: YES];
	} else {
		[super setObjectValue: object];
		[self setRepresentedObject: nil];
		[self setEditable: NO];
	}
}

- (NSText *)setUpFieldEditorAttributes:(NSText *)textObj {
	[super setUpFieldEditorAttributes: textObj];
	
	if([textObj isKindOfClass: [HotKeyTextView class]]) {
		[(HotKeyTextView*) textObj setHotKey: [self representedObject]];
	}
	
	return textObj;
}

@end

@implementation HotKeysPreferences

- (void) mainViewDidLoad {
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(hotKeysLoaded:) name: @"HotKeysLoaded" object:nil];
	
	_dataCell = [[[HotKeyCell alloc] init] autorelease];
	[_dataCell setAlignment: NSCenterTextAlignment];
	
	[[_hotKeysView tableColumnWithIdentifier: @"hotkey"] setDataCell: _dataCell];
	
	_fieldEditor = [[HotKeyTextView alloc] initWithFrame: NSMakeRect(0,0,10,10)];
	[_fieldEditor setFieldEditor: YES];
	
	[[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(editEnd) name:NSTextDidEndEditingNotification object:_fieldEditor];
	
	[_hotKeysView setAutoresizesOutlineColumn: NO];
	[_hotKeysView setDataSource: [HotKeyController defaultController]];
	[_hotKeysView setDelegate: [HotKeyController defaultController]];
	[_hotKeysView reloadData];
}

- (void) dealloc {
	[_fieldEditor autorelease];
	[super dealloc];
}

- (void) editEnd {
	HotKey *hk = [(HotKeyTextView*) _fieldEditor hotKey];
	[[HotKeyController defaultController] setHotKey: hk forNotification: [hk notificationName]];
}

- (void)didSelect {
	NSWindow *window = [_hotKeysView window];
	
	[window setDelegate: self];
}

- (id)windowWillReturnFieldEditor:(NSWindow *)sender toObject:(id)anObject {
	if([anObject isKindOfClass: [NSOutlineView class]]) {
		return _fieldEditor;
	}	
	return nil;
}

- (void) hotKeysLoaded: (NSNotification*) notification {
	[_hotKeysView reloadData];
}

@end
