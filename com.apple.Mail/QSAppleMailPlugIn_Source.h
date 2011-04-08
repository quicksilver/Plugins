//
//  QSAppleMailPlugIn_Source.h
//  QSAppleMailPlugIn
//
//  Created by Nicholas Jitkoff on 9/28/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//


#import "QSAppleMailPlugIn_Source.h"
#define kQSAppleMailMailboxType @"qs.mail.mailbox"
#define kQSAppleMailMessageType @"qs.mail.message"
#define MAIL_BID @"com.apple.mail"

@interface QSAppleMailPlugIn_Source : NSObject
{
}
- (NSArray *)allMailboxes;
@end

