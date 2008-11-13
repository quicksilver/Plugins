

#import "QSPhoneDialerActionProvider.h"

#import "QSModemPhoneDialer.h"
#import "QSSpeakerPhoneDialer.h"
#import <QSCore/QSFeatureLevel.h>


NSString *QSFormattedPhoneNumberString(NSString *number){
	NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
	
	NSMutableString *string=[[number mutableCopy]autorelease];
	NSRange range;
	NSCharacterSet *set=[[NSCharacterSet decimalDigitCharacterSet]invertedSet];
	while ((range=[string rangeOfCharacterFromSet:set]).location!=NSNotFound)
		[string deleteCharactersInRange:range];
	
	
	
	NSString *prefix=nil,*suffix=nil;
	
	//	BOOL include=[defaults boolForKey:@"QSPhoneIncludeAreaCode"];
	//	NSString *areaCode=[defaults stringForKey:@"QSPhoneAreaCode"];
	
	if ([string length]<=4 && [defaults boolForKey:[NSString stringWithFormat:@"QSPhone%@Customized",kInternalPhoneType]]){
		prefix=[defaults stringForKey:[NSString stringWithFormat:@"QSPhone%@Prefix",kInternalPhoneType]];
		suffix=[defaults stringForKey:[NSString stringWithFormat:@"QSPhone%@Suffix",kInternalPhoneType]];
	}else if ([string length]<=7 && [defaults boolForKey:[NSString stringWithFormat:@"QSPhone%@Customized",kLocalPhoneType]]){
		prefix=[defaults stringForKey:[NSString stringWithFormat:@"QSPhone%@Prefix",kLocalPhoneType]];
		suffix=[defaults stringForKey:[NSString stringWithFormat:@"QSPhone%@Suffix",kLocalPhoneType]];
	}else if ([string hasPrefix:@"0"] && [defaults boolForKey:[NSString stringWithFormat:@"QSPhone%@Customized",kInternationalPhoneType]]){
		prefix=[defaults stringForKey:[NSString stringWithFormat:@"QSPhone%@Prefix",kInternationalPhoneType]];
		suffix=[defaults stringForKey:[NSString stringWithFormat:@"QSPhone%@Suffix",kInternationalPhoneType]];
	}else if ([string hasPrefix:@"800"]  && [defaults boolForKey:[NSString stringWithFormat:@"QSPhone%@Customized",kTollFreePhoneType]]){
		prefix=[defaults stringForKey:[NSString stringWithFormat:@"QSPhone%@Prefix",kTollFreePhoneType]];
		suffix=[defaults stringForKey:[NSString stringWithFormat:@"QSPhone%@Suffix",kTollFreePhoneType]];
	}else if (1 && [defaults boolForKey:[NSString stringWithFormat:@"QSPhone%@Customized",kLongDistPhoneType]]){
			prefix=[defaults stringForKey:[NSString stringWithFormat:@"QSPhone%@Prefix",kLongDistPhoneType]];
			suffix=[defaults stringForKey:[NSString stringWithFormat:@"QSPhone%@Suffix",kLongDistPhoneType]];
		
	}else{
		
		if (!prefix && !suffix){
			prefix=[defaults stringForKey:[NSString stringWithFormat:@"QSPhone%@Prefix",kDefaultPhoneType]];
			suffix=[defaults stringForKey:[NSString stringWithFormat:@"QSPhone%@Suffix",kDefaultPhoneType]];
		}
	}
	
	
	
	if (prefix)[string insertString:prefix atIndex:0];	
	if (suffix)[string appendString:suffix];	
	
	return string;
}

@interface QSPhoneDialerScriptCommand : NSScriptCommand
@end

@implementation QSPhoneDialerScriptCommand
- (id)performDefaultImplementation {
	//NSDictionary *args = [self evaluatedArguments];	
	NSString *string=[self directParameter];

		NSDictionary *args = [self evaluatedArguments];

	NSString *meth=[args objectForKey:@"method"];
	
	if ([meth isEqualToString:@"modem"])
		[[QSModemPhoneDialer sharedInstance] dialString:string];
	else if ([meth isEqualToString:@"speaker"])
		[[QSSpeakerPhoneDialer sharedInstance] dialString:string];
	
	return nil;
	
}
@end
@implementation QSPhoneDialerActionProvider


- (NSArray *)validIndirectObjectsForAction:(NSString *)action directObject:(QSObject *)dObject{
	NSMutableArray *array=[NSMutableArray array];
	
	NSString *last=[[NSUserDefaults standardUserDefaults]stringForKey:@"QSPhoneDialerLastUsed"];
	id preferred=nil;
	foreachkey(key,value,[QSReg tableNamed:@"QSPhoneDialers"]){
		QSObject *object=[QSObject objectWithName:[value objectForKey:@"name"]];
		if ([key isEqual:last])preferred=object;
		[object setObject:key forType:@"QSPhoneDialer"];
		[object setObject:[value objectForKey:@"icon"] forMeta:kQSObjectIconName];
		[array addObject:object];
	}
	
if (preferred)
	array=[NSArray arrayWithObjects:preferred,array,nil];
	
	return array;
}
- (QSObject *)dialNumber:(QSObject *)dObject withDialer:(QSObject *)iObject{
	NSString *dialer=[iObject objectForType:@"QSPhoneDialer"];
	[[NSUserDefaults standardUserDefaults]setObject:dialer forKey:@"QSPhoneDialerLastUsed"];
	[self dialString:[self formattedNumberString:[dObject objectForType:QSContactPhoneType]] withDialer:dialer];
	return nil;
}

- (BOOL)dialString:(NSString *)string withDialer:(NSString *)dialer{
	NSDictionary *dialDict=[[QSReg tableNamed:@"QSPhoneDialers"]objectForKey:dialer];
	id instance=[[QSReg getClass:[dialDict objectForKey:@"class"]]alloc];
	
	if ([instance respondsToSelector:@selector(initWithSettings:)])
		instance=[instance initWithSettings:dialDict];
	else
		instance=[instance init];

	[instance dialString:string];
	
	//NSLog(@"Dial %@ with %@ %@",string,dialDict,instance);	

	[instance autorelease];
	return nil;
}


- (NSString *)formattedNumberString:(NSString *)number{
	return QSFormattedPhoneNumberString(number);
}




@end
