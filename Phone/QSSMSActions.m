

#import "QSSMSActions.h"

#import <QSCore/QSTypes.h>


#define kQSAIMSMSAction @"QSAIMSMSAction"

@implementation QSSMSActions

- (NSArray *) types{
    return [NSArray arrayWithObjects:QSContactPhoneType,nil];
}
- (NSArray *) actions{
    QSAction *action=[QSAction actionWithIdentifier:kQSAIMSMSAction];
    [action setIcon:[NSImage imageNamed:@"All16"]];
    [action setProvider:self];
    [action setAction:@selector(sendSMS:)];
    [action setArgumentCount:1];
    return [NSArray arrayWithObject:action];
}

- (NSArray *)validActionsForDirectObject:(QSObject *)dObject indirectObject:(QSObject *)iObject{
    return [NSArray arrayWithObject:kQSAIMSMSAction];
    return nil;
}

- (QSObject *)sendSMS:(QSObject *)dObject{
    NSString *number=[dObject objectForType:QSContactPhoneType];
    NSString *digits;
 //   NSLog(@"smsnumber:%@",number);
    NSScanner *scanner=[NSScanner scannerWithString:number];
    number=@"";
    [scanner setCharactersToBeSkipped:[[NSCharacterSet decimalDigitCharacterSet]invertedSet]];
    while(![scanner isAtEnd]){
    if ([scanner scanCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&digits])
        number=[number stringByAppendingString:digits];
}
 //   NSLog(@"smsnumber:%@",number);

if ([number length]==10){
    NSString *url=[NSString stringWithFormat:@"aim:goim?screenname=%%2B1%@",number];//&message=Hi.+Are+you+there?"
        
        if (![[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]])
            NSLog(@"could not open");
    }else{
        NSBeep();
    }
    
    return nil;
}


@end
