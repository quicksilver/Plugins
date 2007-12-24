//
//  SpellcheckActionProvider.m
//  Quicksilver
//

#import "SpellcheckActionProvider.h"
#import <QSCore/QSObject.h>
#import <QSCore/QSObject_Pasteboard.h>
#import <QSCore/QSObject_PropertyList.h>

@implementation SpellcheckActionProvider

// moved to plist
- (NSArray *) types {
	return [NSArray arrayWithObject:NSStringPboardType];
}

// moved to plist
- (NSArray *) actions {
	QSAction *action = [QSAction actionWithIdentifier:@"SpellcheckAction"
											   bundle:[NSBundle bundleForClass:
												   [SpellcheckActionProvider class]]];
	//[action setIcon:[QSResourceManager imageNamed:@"com.apple.calculator"]];
	[action setProvider:self];
	// The "right" way:
	[action setAction:@selector(checkSpelling:)];
	[action setArgumentCount:1];
	// The bad way that Alcor doesn't like
	//[action setAction:@selector(spellcheck:two:)];
	//[action setArgumentCount:2];
	[action setDetails:@"Check Spelling"];
	return [NSArray arrayWithObject:action];
}

- (NSArray *) validActionsForDirectObject:(QSObject *)dObject indirectObject:(QSObject *)iObject{
	return [NSArray arrayWithObject:@"SpellcheckAction"];
}

- (QSObject *) checkSpelling:(QSObject *)dObject {


	NSString *value = [dObject objectForType:NSStringPboardType];
	NSLog([NSString stringWithFormat:@"SpellcheckAction: got word: '%@'",value]);
	NSLog([NSString stringWithFormat:@"SpellcheckAction: shared checker state: %i",(int)[NSSpellChecker sharedSpellCheckerExists]]);


	NSArray *guesses = [[NSSpellChecker sharedSpellChecker] guessesForWord:value];
	NSLog([NSString stringWithFormat:@"SpellcheckAction: got %i suggestions",[guesses count]]);
	int count = [guesses count];
	if(count) {
		//return [QSObject objectWithString:[guesses objectAtIndex:0]];
		//NSMutableArray *returnarr = [NSMutableArray arrayWithCapacity:[guesses count]];
		int i;
		for(i = 0; i< [guesses count]; i++) {
			NSString *this = [guesses objectAtIndex:i];
			NSLog([NSString stringWithFormat:@"SpellcheckAction: guess %i: '%@'",i,this]);
			//QSObject *result = [QSObject objectWithString:this];
			
			//[result setDetails:@"Spell check result"];
			//[result setChildren:[NSArray array]];
			//[returnarr addObject:result];
		}
		
		//id controller=[[NSApp delegate]interfaceController];
		//[controller showArray:returnarr];
	} else {
		
	}
	return nil;
	
	/*
	QSObject *result = [QSObject objectWithString:value];
	[result setChildren:returnarr];
	//[result setDetails:@"Spell Check request"];
	[result setChildrenLoaded:YES];
	return result;
	*/
	
	
	// Without children, first match only:
	//QSObject *result = [QSObject objectWithString:[guesses objectAtIndex:0]];
	//return [NSArray arrayWithObject:result];
	//return guesses;
}

// Stuff below is the old way that Alcor doesn't like
// (because it's a total abuse of the interface ;-)

/*
- (NSArray *) validIndirectObjectsForAction:(NSString *)action directObject:(QSObject *)dObject {
	NSString *value = [dObject objectForType:NSStringPboardType];
	NSArray *guesses = [[NSSpellChecker sharedSpellChecker] guessesForWord:value];
	
	NSMutableArray *returnarr = [NSMutableArray arrayWithCapacity:[guesses count]];
	int i;
	for(i = 0; i< [guesses count]; i++) {
		NSString *this = [guesses objectAtIndex:i];
		QSObject *result = [QSObject objectWithString:this];
		[returnarr addObject:result];
	}
	
	return returnarr;
}
*/

/*
- (QSObject *) spellcheck:(QSObject *)dObject two:(QSObject *)iObject {
	return iObject;
	
	//NSString *value = [dObject objectForType:NSStringPboardType];
	//NSArray *guesses = [[NSSpellChecker sharedSpellChecker] guessesForWord:value];
	
	//QSObject *result = [QSObject objectWithString:[guesses objectAtIndex:0]];
	//return result;
}
*/

@end
