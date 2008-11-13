

#import "QSIndigoPrefPane.h"
#import <QSCore/QSResourceManager.h>

@implementation QSIndigoPrefPane
- (id)init {
    self = [super initWithBundle:[NSBundle bundleForClass:[QSIndigoPrefPane class]]];
    if (self) {
    }
    return self;
}


- (NSString *) mainNibName{
	return @"QSIndigoPrefPane";
}

- (void)awakeFromNib{
	NSString *account=[[NSUserDefaults standardUserDefaults] objectForKey:@"QSIndigoUserName"];
	NSString *target=[[NSUserDefaults standardUserDefaults] objectForKey:@"QSIndigoTarget"];
	NSString *password=nil;
	if (account && target){
		NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"eppc://%@@%@",account,target]];
		 password=[url keychainPassword];
	}
	if (target)[targetField setStringValue:target];
	if (account)[userField setStringValue:account];
	if (password)[passField setStringValue:password];	
}


- (IBAction)savePassword:(id)sender{
	NSString *account=[userField stringValue];
	NSString *target=[targetField stringValue];
	NSString *pass=[passField stringValue];
	[[NSUserDefaults standardUserDefaults] setObject:account forKey:@"QSIndigoUserName"];
	[[NSUserDefaults standardUserDefaults] setObject:target forKey:@"QSIndigoTarget"];
	NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"eppc://%@:%@@%@",account,pass,target]];
	if ([pass length])
		[url addPasswordToKeychain];
}
@end
