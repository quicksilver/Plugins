//
//  QSAmazonPlugIn_Action.m
//  QSAmazonPlugIn
//
//  Created by Nicholas Jitkoff on 10/5/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//

#import "QSAmazonPlugIn_Action.h"
#import <QSCore/QSLibrarian.h>
//#import <QSCore/QSMailMediator.h>
#define LINK_URL @"http://www.amazon.com/exec/obidos/ASIN/%@"
///ref=nosim/blackinc-20"

@implementation QSAmazonPlugIn_Action


#define kQSAmazonPlugInAction @"QSAmazonPlugInAction"

- (QSObject *)showItem:(QSObject *)dObject{
	NSString *asin=[dObject objectForType:QSAmazonItemType];
	NSString *urlString=[NSString stringWithFormat:LINK_URL,asin];
	
	[[NSWorkspace sharedWorkspace]openURL:[NSURL URLWithString:urlString]]; 
	return nil;
}
- (QSObject *)recommendItem:(QSObject *)dObject to:(QSObject *)iObject{
	NSString *asin=[dObject objectForType:QSAmazonItemType];
	NSString *urlString=[NSString stringWithFormat:LINK_URL,asin];
	
	//[[NSWorkspace sharedWorkspace]openURL:[NSURL URLWithString:urlString]]; 
	
	NSArray *addresses=[iObject arrayForType:QSEmailAddressType];
    NSString *subject=[NSString stringWithFormat:@"Recommendation: %@", [dObject name]];
    NSString *body=[NSString stringWithFormat:@"I think you might enjoy %@: <%@>",[dObject name],urlString];
    NSArray *attachments=nil;
    
	//  QSMailMediator *mediator=[QSMailMediator sharedInstance];
    [[NSClassFromString(@"QSMailMediator") defaultMediator]sendEmailTo:addresses from:nil subject:subject body:body attachments:attachments sendNow:NO];

    return nil;
}

- (NSArray *)validIndirectObjectsForAction:(NSString *)action directObject:(QSObject *)dObject{
	NSMutableArray *objects=[QSLib scoredArrayForString:nil inSet:[QSLib arrayForType:QSEmailAddressType]];
	return [NSArray arrayWithObjects:[NSNull null],objects,nil];
}
@end
