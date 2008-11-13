

#import "QSEmailActions.h"
#import "QSMailMediator.h"

#import <ApplicationServices/ApplicationServices.h> 


//#import <QSCore/QSLibrarian.h> 


# define kEmailAction @"QSEmailAction"
# define kEmailItemAction @"QSEmailItemAction"
# define kEmailItemReverseAction @"QSEmailItemReverseAction"
# define kComposeEmailItemAction @"QSComposeEmailItemAction"
# define kComposeEmailItemReverseAction @"QSComposeEmailItemReverseAction"
#define kDirectEmailItemReverseAction @"QSDirectEmailItemReverseAction"


@implementation QSEmailActions

- (NSArray *)validActionsForDirectObject:(QSObject *)dObject indirectObject:(QSObject *)iObject{
    NSMutableArray *newActions=[NSMutableArray arrayWithCapacity:1];
	BOOL mediatorAvailable=[[QSReg tableNamed:kQSMailMediators]count];
    if ([[dObject types] containsObject:QSEmailAddressType]){
		
		if (mediatorAvailable){
			[newActions addObject:kEmailItemAction];
			[newActions addObject:kComposeEmailItemAction];
		}
        [newActions addObject:kEmailAction];
    }
    else if (mediatorAvailable && ([[dObject types] containsObject:NSFilenamesPboardType] && [dObject validPaths])
             || ([[dObject types] containsObject:NSStringPboardType] && ![[dObject types] containsObject:NSFilenamesPboardType])){
        [newActions addObject:kEmailItemReverseAction];
        [newActions addObject:kComposeEmailItemReverseAction];
    }
    return newActions;
}


- (NSArray *)validIndirectObjectsForAction:(NSString *)action directObject:(QSObject *)dObject{
	if ([action isEqualToString:kEmailItemAction] || [action isEqualToString:kComposeEmailItemAction]){
		return nil;
	}else if ([action isEqualToString:kEmailItemReverseAction] ||[action isEqualToString:kDirectEmailItemReverseAction] || [action isEqualToString:kComposeEmailItemReverseAction]){
		NSMutableArray *objects=[QSLib scoredArrayForString:nil inSet:[QSLib arrayForType:QSEmailAddressType]];
		return [NSArray arrayWithObjects:[NSNull null],objects,nil];
	}
	return nil;
}

- (QSObject *) sendEmailTo:(QSObject *)dObject{
    NSArray *addresses=[dObject arrayForType:QSEmailAddressType];
	NSString *addressesString=[addresses componentsJoinedByString:@","];
	addressesString=[addressesString URLEncoding];
	NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"mailto:%@",addressesString]];
	if (!url) NSLog(@"Badurl: %@",[NSString stringWithFormat:@"mailto:%@",addressesString]);
	[[NSWorkspace sharedWorkspace] openURL:url];
    return nil;
}
- (QSObject *) sendEmailTo:(QSObject *)dObject withItem:(QSObject *)iObject{
    return [self composeEmailTo:(QSObject *)dObject withItem:(QSObject *)iObject sendNow:(BOOL)YES direct:NO];}
- (QSObject *) sendDirectEmailTo:(QSObject *)dObject withItem:(QSObject *)iObject{
    return [self composeEmailTo:(QSObject *)dObject withItem:(QSObject *)iObject sendNow:(BOOL)YES direct:YES];}
- (QSObject *) composeEmailTo:(QSObject *)dObject withItem:(QSObject *)iObject{
    return [self composeEmailTo:(QSObject *)dObject withItem:(QSObject *)iObject sendNow:(BOOL)NO direct:NO];}
- (QSObject *) composeEmailTo:(QSObject *)dObject withItem:(QSObject *)iObject sendNow:(BOOL)sendNow direct:(BOOL)direct{
    NSArray *addresses=[dObject arrayForType:QSEmailAddressType];
    NSString *subject=nil;
    NSString *body=nil;
    NSArray *attachments=nil;
	iObject=[iObject resolvedObject];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
	NSString *from=[defaults objectForKey:@"QSMailActionCustomFrom"];
	if (![from length])from=nil;
    if ([iObject containsType:QSFilePathType]){
        subject=[NSString stringWithFormat:[defaults objectForKey:@"QSMailActionFileSubject"],[iObject name]];
        body=[[NSString stringWithFormat:[defaults objectForKey:@"QSMailActionFileBody"],[iObject name]]stringByAppendingString:@"\r\r"];
        attachments=[iObject arrayForType:QSFilePathType];
    } else if ([[iObject types] containsObject:NSStringPboardType]){
		NSString *string=[iObject stringValue];
		NSString *delimiter=@"\n";
		NSArray *components=[string componentsSeparatedByString:delimiter];
		if (![components count]<2){
			delimiter=@">>";
			components=[string componentsSeparatedByString:delimiter];
		}
		subject=[components objectAtIndex:0];
		if ([subject length]>255)subject=[subject substringToIndex:255];
		
		if ([components count]>1){
			body=[[components subarrayWithRange:NSMakeRange(1,[components count]-1)]componentsJoinedByString:@"\r"];
		}else{
			body=[iObject stringValue];
			
		}
	}
	
	//  QSMailMediator *mediator=[QSMailMediator sharedInstance];
	if (direct){
		[[QSReg getClassInstance:@"QSDirectMailMediator"]sendEmailTo:addresses from:from subject:subject body:body attachments:attachments sendNow:sendNow];
		
	}else{
		[[QSMailMediator defaultMediator]sendEmailTo:addresses from:from subject:subject body:body attachments:attachments sendNow:sendNow];
	}
	
	return nil;
}

@end