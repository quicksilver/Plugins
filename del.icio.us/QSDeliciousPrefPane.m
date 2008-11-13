

#import "QSDeliciousPrefPane.h"
#import <QSCore/QSResourceManager.h>

@implementation QSDeliciousPrefPane
- (id)init {
    self = [super initWithBundle:[NSBundle bundleForClass:[QSDeliciousPrefPane class]]];
    if (self) {
    }
    return self;
}

- (NSImage *) icon{
	return [[NSBundle bundleForClass:[self class]] imageNamed:@"del.icio.us"];
}

- (NSString *) mainNibName{
	return @"QSDeliciousPrefPane";
}

- (void)awakeFromNib{
	NSString *account=[[NSUserDefaults standardUserDefaults] objectForKey:@"QSDeliciousUserName"];
	NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"http://%@@del.icio.us/",account]];
	NSString *password=[url keychainPassword];
	if (account)[userField setStringValue:account];
	if (password)[passField setStringValue:password];	
}

- (IBAction)savePassword:(id)sender{
	NSString *account=[userField stringValue];
	NSString *pass=[passField stringValue];

	NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%@@del.icio.us/",account,pass]];
	if ([pass length])
		[url addPasswordToKeychain];
}

@end
