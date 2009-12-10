

#import "QSPhonePrefPane.h"
#import <QSCore/QSResourceManager.h>

#import "QSPhoneDialerActionProvider.h"
#import "QSPhonePlugIn.h"

@implementation QSPhonePrefPane

- (NSImage *) paneIcon{
	return [QSResourceManager imageNamed:@"ContactPhone"];
}

- (NSString *) paneDescription{
	return @"Local and International Dialing Options";
}
- (NSString *) paneName{
	return @"Phone";
}

- (id)init {
    self = [super initWithBundle:[NSBundle bundleForClass:[QSPhonePrefPane class]]];
    if (self) {
    }
    return self;
}

- (NSString *) mainNibName{
	return @"QSPhonePrefPane";
}


- (void)awakeFromNib{
	
	[[callTypePopUp itemAtIndex:[callTypePopUp indexOfItemWithTag:0]]setRepresentedObject:kDefaultPhoneType];
	[[callTypePopUp itemAtIndex:[callTypePopUp indexOfItemWithTag:1]]setRepresentedObject:kLocalPhoneType];
	[[callTypePopUp itemAtIndex:[callTypePopUp indexOfItemWithTag:2]]setRepresentedObject:kLongDistPhoneType];
	[[callTypePopUp itemAtIndex:[callTypePopUp indexOfItemWithTag:3]]setRepresentedObject:kInternationalPhoneType];
	[[callTypePopUp itemAtIndex:[callTypePopUp indexOfItemWithTag:4]]setRepresentedObject:kTollFreePhoneType];
	[[callTypePopUp itemAtIndex:[callTypePopUp indexOfItemWithTag:5]]setRepresentedObject:kInternalPhoneType];
	[self populateFields];	
	[testInput setDelegate:self];
	
}
//- (void)textDidChange:(NSNotification *)notification{
	- (void)controlTextDidChange:(NSNotification *)aNotification{
	//NSLog(@"change");
	[self testStringChanged:nil];
}
- (IBAction)selectCountry:(id)sender{
	
}

- (IBAction)testStringChanged:(id)sender{
	[testOutput setStringValue:QSFormattedPhoneNumberString([testInput stringValue])];
}



- (BOOL)validateMenuItem:(NSMenuItem*)anItem {
	if ([anItem tag]>0){
		NSString *type=[anItem representedObject];
		
		NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
		
		BOOL custom=[defaults boolForKey:[NSString stringWithFormat:@"QSPhone%@Customized",type]];	
		[anItem setState:custom?NSMixedState:NSOffState];
	}
	return YES;
	
}

- (void)populateFields{
	NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
	NSString *type=[[callTypePopUp selectedItem]representedObject];
	NSString *prefix=[defaults stringForKey:[NSString stringWithFormat:@"QSPhone%@Prefix",type]];
	NSString *suffix=[defaults stringForKey:[NSString stringWithFormat:@"QSPhone%@Suffix",type]];
	
	BOOL custom=[defaults boolForKey:[NSString stringWithFormat:@"QSPhone%@Customized",type]];
	
	if (!custom){
		prefix=[defaults stringForKey:[NSString stringWithFormat:@"QSPhone%@Prefix",kDefaultPhoneType]];
		suffix=[defaults stringForKey:[NSString stringWithFormat:@"QSPhone%@Suffix",kDefaultPhoneType]];
	}
	
	BOOL defaultSelected=[[callTypePopUp selectedItem]tag]==0;
	[useDefaultSwitch setState:!custom || defaultSelected];
	[useDefaultSwitch setEnabled:!defaultSelected];
	[prefixField setStringValue:prefix?prefix:@""];
	[suffixField setStringValue:suffix?suffix:@""];
	[prefixField setEnabled:custom || defaultSelected];
	[suffixField setEnabled:custom || defaultSelected];
	
	//	IBOutlet NSPopUpButton *callTypePopUp;
	
}



- (IBAction)setValueForSender:(id)sender{
	NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
	NSString *type=[[callTypePopUp selectedItem]representedObject];
	
	
	if (sender==callTypePopUp){
		
	}else if (sender==prefixField){
		[defaults setObject:[sender stringValue] forKey:[NSString stringWithFormat:@"QSPhone%@Prefix",type]];
	}else if (sender==suffixField){
		[defaults setObject:[sender stringValue] forKey:[NSString stringWithFormat:@"QSPhone%@Suffix",type]];
	}else if (sender==useDefaultSwitch){
		
		[defaults setBool:![sender state] forKey:[NSString stringWithFormat:@"QSPhone%@Customized",type]];
		
	}
[self testStringChanged:nil];
	[self populateFields];
}


@end
