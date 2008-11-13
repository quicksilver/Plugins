

#import "QSKeychainSource.h"

#import <QSCore/QSCore.h>
#import <QSFoundation/QSFoundation.h>
#include <Security/Security.h>
#include <CoreServices/CoreServices.h>

#define QSKeychainType @"QSKeychainType"
#define QSKeychainEntryType @"QSKeychainEntryType"

#define QSKeychainInternetPasswordType @"QSKeychainInternetPasswordType"
#define QSKeychainGenericPasswordType @"QSKeychainGenericPasswordType"
#define QSKeychainAppleSharePasswordType @"QSKeychainAppleSharePasswordType"
#define QSKeychainCertificateType @"QSKeychainCertificateType"

NSString *typeForKeychainClass(SecItemClass itemClass){
	switch (itemClass){
		case kSecInternetPasswordItemClass: return QSKeychainInternetPasswordType;
		case kSecGenericPasswordItemClass: return QSKeychainGenericPasswordType;
		case kSecAppleSharePasswordItemClass: return QSKeychainAppleSharePasswordType;
		case kSecCertificateItemClass: return QSKeychainCertificateType;
	}
	return nil;
}
SecItemClass keychainClassForType(NSString *class){
	if ([class isEqualToString:QSKeychainInternetPasswordType])return kSecInternetPasswordItemClass;
	if ([class isEqualToString:QSKeychainGenericPasswordType])return kSecGenericPasswordItemClass;
	if ([class isEqualToString:QSKeychainAppleSharePasswordType])return kSecAppleSharePasswordItemClass;
	if ([class isEqualToString:QSKeychainCertificateType])return kSecCertificateItemClass;
	return nil;
}	

static OSStatus logKeychainEntry(SecKeychainItemRef itemRef)
{
	OSStatus                                        result;
	SecKeychainAttribute            attr;
	SecKeychainAttributeList        attrList;
	UInt32                                          length; 
	//	void                                            *outData;
	
	/* the attribute we want is the account name */
	attr.tag = kSecServerItemAttr;
	attr.length = 0;
	attr.data = NULL;
	
	attrList.count = 1;
	attrList.attr = &attr;
	
	attr.tag = kSecCreationDateItemAttr; if ( SecKeychainItemCopyContent(itemRef, NULL, &attrList, &length, NULL) == noErr ) NSLog(@"\"cdat - %@\"",[NSString stringWithCString:attr.data length:attr.length]);
	attr.tag = kSecModDateItemAttr; if ( SecKeychainItemCopyContent(itemRef, NULL, &attrList, &length, NULL) == noErr ) NSLog(@"\"mdat - %@\"",[NSString stringWithCString:attr.data length:attr.length]);
	attr.tag = kSecDescriptionItemAttr; if ( SecKeychainItemCopyContent(itemRef, NULL, &attrList, &length, NULL) == noErr ) NSLog(@"\"desc - %@\"",[NSString stringWithCString:attr.data length:attr.length]);
	attr.tag = kSecCommentItemAttr; if ( SecKeychainItemCopyContent(itemRef, NULL, &attrList, &length, NULL) == noErr ) NSLog(@"\"icmt - %@\"",[NSString stringWithCString:attr.data length:attr.length]);
	attr.tag = kSecCreatorItemAttr; if ( SecKeychainItemCopyContent(itemRef, NULL, &attrList, &length, NULL) == noErr ) NSLog(@"\"crtr - %@\"",[NSString stringWithCString:attr.data length:attr.length]);
	attr.tag = kSecTypeItemAttr; if ( SecKeychainItemCopyContent(itemRef, NULL, &attrList, &length, NULL) == noErr ) NSLog(@"\"type - %@\"",[NSString stringWithCString:attr.data length:attr.length]);
	attr.tag = kSecScriptCodeItemAttr; if ( SecKeychainItemCopyContent(itemRef, NULL, &attrList, &length, NULL) == noErr ) NSLog(@"\"scrp - %@\"",[NSString stringWithCString:attr.data length:attr.length]);
	attr.tag = kSecLabelItemAttr; if ( SecKeychainItemCopyContent(itemRef, NULL, &attrList, &length, NULL) == noErr ) NSLog(@"\"labl - %@\"",[NSString stringWithCString:attr.data length:attr.length]);
	attr.tag = kSecInvisibleItemAttr; if ( SecKeychainItemCopyContent(itemRef, NULL, &attrList, &length, NULL) == noErr ) NSLog(@"\"invi - %@\"",[NSString stringWithCString:attr.data length:attr.length]);
	attr.tag = kSecNegativeItemAttr; if ( SecKeychainItemCopyContent(itemRef, NULL, &attrList, &length, NULL) == noErr ) NSLog(@"\"nega - %@\"",[NSString stringWithCString:attr.data length:attr.length]);
	attr.tag = kSecCustomIconItemAttr; if ( SecKeychainItemCopyContent(itemRef, NULL, &attrList, &length, NULL) == noErr ) NSLog(@"\"cusi - %@\"",[NSString stringWithCString:attr.data length:attr.length]);
	attr.tag = kSecAccountItemAttr; if ( SecKeychainItemCopyContent(itemRef, NULL, &attrList, &length, NULL) == noErr ) NSLog(@"\"acct - %@\"",[NSString stringWithCString:attr.data length:attr.length]);
	attr.tag = kSecServiceItemAttr; if ( SecKeychainItemCopyContent(itemRef, NULL, &attrList, &length, NULL) == noErr ) NSLog(@"\"svce - %@\"",[NSString stringWithCString:attr.data length:attr.length]);
	attr.tag = kSecGenericItemAttr; if ( SecKeychainItemCopyContent(itemRef, NULL, &attrList, &length, NULL) == noErr ) NSLog(@"\"gena - %@\"",[NSString stringWithCString:attr.data length:attr.length]);
	attr.tag = kSecSecurityDomainItemAttr; if ( SecKeychainItemCopyContent(itemRef, NULL, &attrList, &length, NULL) == noErr ) NSLog(@"\"sdmn - %@\"",[NSString stringWithCString:attr.data length:attr.length]);
	attr.tag = kSecServerItemAttr; if ( SecKeychainItemCopyContent(itemRef, NULL, &attrList, &length, NULL) == noErr ) NSLog(@"\"srvr - %@\"",[NSString stringWithCString:attr.data length:attr.length]);
	attr.tag = kSecAuthenticationTypeItemAttr; if ( SecKeychainItemCopyContent(itemRef, NULL, &attrList, &length, NULL) == noErr ) NSLog(@"\"atyp - %@\"",[NSString stringWithCString:attr.data length:attr.length]);
	attr.tag = kSecPortItemAttr; if ( SecKeychainItemCopyContent(itemRef, NULL, &attrList, &length, NULL) == noErr ) NSLog(@"\"port - %@\"",[NSString stringWithCString:attr.data length:attr.length]);
	attr.tag = kSecPathItemAttr; if ( SecKeychainItemCopyContent(itemRef, NULL, &attrList, &length, NULL) == noErr ) NSLog(@"\"path - %@\"",[NSString stringWithCString:attr.data length:attr.length]);
	attr.tag = kSecVolumeItemAttr; if ( SecKeychainItemCopyContent(itemRef, NULL, &attrList, &length, NULL) == noErr ) NSLog(@"\"vlme - %@\"",[NSString stringWithCString:attr.data length:attr.length]);
	attr.tag = kSecAddressItemAttr; if ( SecKeychainItemCopyContent(itemRef, NULL, &attrList, &length, NULL) == noErr ) NSLog(@"\"addr - %@\"",[NSString stringWithCString:attr.data length:attr.length]);
	attr.tag = kSecSignatureItemAttr; if ( SecKeychainItemCopyContent(itemRef, NULL, &attrList, &length, NULL) == noErr ) NSLog(@"\"ssig - %@\"",[NSString stringWithCString:attr.data length:attr.length]);
	attr.tag = kSecProtocolItemAttr; if ( SecKeychainItemCopyContent(itemRef, NULL, &attrList, &length, NULL) == noErr ) NSLog(@"\"ptcl - %@\"",[NSString stringWithCString:attr.data length:attr.length]);
	attr.tag = kSecCertificateType; if ( SecKeychainItemCopyContent(itemRef, NULL, &attrList, &length, NULL) == noErr ) NSLog(@"\"ctyp - %@\"",[NSString stringWithCString:attr.data length:attr.length]);
	attr.tag = kSecCertificateEncoding; if ( SecKeychainItemCopyContent(itemRef, NULL, &attrList, &length, NULL) == noErr ) NSLog(@"\"cenc - %@\"",[NSString stringWithCString:attr.data length:attr.length]);
	attr.tag = kSecCrlType; if ( SecKeychainItemCopyContent(itemRef, NULL, &attrList, &length, NULL) == noErr ) NSLog(@"\"crtp - %@\"",[NSString stringWithCString:attr.data length:attr.length]);
	attr.tag = kSecCrlEncoding; if ( SecKeychainItemCopyContent(itemRef, NULL, &attrList, &length, NULL) == noErr ) NSLog(@"\"crnc - %@\"",[NSString stringWithCString:attr.data length:attr.length]);
	attr.tag = kSecAlias; if ( SecKeychainItemCopyContent(itemRef, NULL, &attrList, &length, NULL) == noErr ) NSLog(@"\"alis - %@\"",[NSString stringWithCString:attr.data length:attr.length]);
	
	return ( result );
}

NSString *stringForKeychainItemAttribute(SecKeychainItemRef itemRef,SecKeychainAttrType type){	
	NSString *value=nil;
	SecKeychainAttribute attrs[] = {{type,0,NULL}};
	SecKeychainAttributeList attributes = { sizeof(attrs)/sizeof(attrs[0]),attrs};	
	if (noErr != SecKeychainItemCopyContent(itemRef, NULL, &attributes, NULL, NULL))
		return nil;
	if (attrs[0].length){
	//	NSData *data=[NSData dataWithBytes:attrs[0].data length:attrs[0].length];	// **** is this causing a leak?
		//NSLog(@"value %@ %@ %d",NSFileTypeForHFSTypeCode(type),data,attrs[0].length);
		value=[NSString stringWithCString:attrs[0].data encoding:NSUTF8StringEncoding];
		//NSLog(@"value %@",value);
	}
	SecKeychainItemFreeContent(&attributes, NULL);
	return value;
}


QSObject *objectForKeychainRef(SecKeychainItemRef itemRef,SecItemClass itemClass){
	NSString *type=typeForKeychainClass(itemClass);
	NSString *label=stringForKeychainItemAttribute(itemRef,kSecLabelItemAttr);
	
	NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:
		stringForKeychainItemAttribute(itemRef,kSecModDateItemAttr),NSFileTypeForHFSTypeCode(kSecModDateItemAttr),
		stringForKeychainItemAttribute(itemRef,kSecCreationDateItemAttr),NSFileTypeForHFSTypeCode(kSecCreationDateItemAttr),
		label,NSFileTypeForHFSTypeCode(kSecLabelItemAttr),
		stringForKeychainItemAttribute(itemRef,kSecAccountItemAttr),NSFileTypeForHFSTypeCode(kSecAccountItemAttr),
		stringForKeychainItemAttribute(itemRef,kSecServiceItemAttr),NSFileTypeForHFSTypeCode(kSecServiceItemAttr),
		stringForKeychainItemAttribute(itemRef,kSecDescriptionItemAttr),NSFileTypeForHFSTypeCode(kSecDescriptionItemAttr),
		nil];
	
	if (!label)label=@"Keychain Item";
	QSObject *newObject=[QSObject objectWithName:label];
	[newObject setObject:dict forType:type];
	[newObject setPrimaryType:type];
	
	return ( newObject );
	
	return nil;
}

@implementation QSKeychainSource

- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry{
    NSDate *modDate=[[[NSFileManager defaultManager] fileAttributesAtPath:[@"~/Library/Preferences/com.apple.Keychain.plist" stringByStandardizingPath] traverseLink:YES]fileModificationDate];
    return [modDate compare:indexDate]==NSOrderedAscending;
}

- (NSImage *) iconForEntry:(NSDictionary *)dict{
    return [QSResourceManager imageNamed:@"com.apple.keychainaccess"];
}

- (NSString *)identifierForObject:(id <QSObject>)object{
	NSString *path=[object objectForType:QSKeychainType];
	if (!path) return nil;
    return [@"[Keychain]:"stringByAppendingString:path];
}

- (NSArray *) objectsForEntry:(NSDictionary *)theEntry{
	NSMutableArray *objects=[NSMutableArray arrayWithCapacity:1];
    QSObject *newObject;
	
	NSArray *searchList;
	if (!SecKeychainCopySearchList((CFArrayRef *)&searchList)){
		
		
		int i;
		for (i=0;i<[searchList count];i++){
			char 				kcPath[1024];
			UInt32 				kcPathLen = 1024;
			SecKeychainGetPath((SecKeychainRef)[searchList objectAtIndex:i], &kcPathLen, kcPath);
			NSString *path=[NSString stringWithCString:kcPath length:kcPathLen];
			
			newObject=[QSObject fileObjectWithPath:path];
			[newObject setObject:path forType:QSKeychainType];
			[newObject setPrimaryType:QSKeychainType];
			[newObject setLabel:[[path lastPathComponent]stringByDeletingPathExtension]];
			if (newObject)
				[objects addObject:newObject];
		}
		CFRelease(searchList);	
	}
	return objects;
	return nil;
}


- (NSString *)detailsOfObject:(QSObject *)object{
	if ([[object primaryType]isEqualToString:QSKeychainType]){
		return @"Keychain";
	}else{
		
		NSDictionary *info=[object primaryObject];		
		NSString *details= [info objectForKey:NSFileTypeForHFSTypeCode(kSecDescriptionItemAttr)];
		if (!details)
			details=[info objectForKey:NSFileTypeForHFSTypeCode(kSecAccountItemAttr)];
		return details;			
	}
	return nil; 
}

- (BOOL)loadChildrenForObject:(QSObject *)object{
	if (![object objectForType:QSKeychainType]){
		[object setChildren:[self objectsForEntry:nil]];
		return YES;
	}else{
	NSString *keychainPath=[object objectForType:QSKeychainType];
	
	NSMutableArray *children=[NSMutableArray arrayWithCapacity:1];
	
	SecKeychainSearchRef searchRef;
	SecKeychainRef keychainRef=NULL;
	SecKeychainItemRef itemRef = NULL;
	OSStatus status;
	
	
	SecKeychainOpen ([keychainPath UTF8String],&keychainRef);
	//SecKeychainAttributeList *attrList=NULL;//&attrList;
	
	if (!(status=SecKeychainSearchCreateFromAttributes(keychainRef,kSecInternetPasswordItemClass,NULL,&searchRef))){
		while((status = SecKeychainSearchCopyNext(searchRef,&itemRef))!=errSecItemNotFound){
			
			id object=objectForKeychainRef(itemRef,kSecInternetPasswordItemClass);
			//logKeychainEntry(itemRef);
			if (object)[children addObject:object];
			
			[object setObject:keychainPath forMeta:@"QSKeychainSourcePath"];
		}
		CFRelease(searchRef);
	}
	if (!(status=SecKeychainSearchCreateFromAttributes(keychainRef,kSecGenericPasswordItemClass,NULL,&searchRef))){
		while((status = SecKeychainSearchCopyNext(searchRef,&itemRef))!=errSecItemNotFound){
			id object=objectForKeychainRef(itemRef,kSecGenericPasswordItemClass);
			//	logKeychainEntry(itemRef);
			if (object)[children addObject:object];
		}
		CFRelease(searchRef);
	}
	if (!(status=SecKeychainSearchCreateFromAttributes(keychainRef,kSecAppleSharePasswordItemClass,NULL,&searchRef))){
		while((status = SecKeychainSearchCopyNext(searchRef,&itemRef))!=errSecItemNotFound){
			id object=objectForKeychainRef(itemRef,kSecAppleSharePasswordItemClass);
			//	logKeychainEntry(itemRef);
			if (object)[children addObject:object];
		}
		CFRelease(searchRef);
	}
				
				CFRelease(keychainRef);
				if (children){
					[object setChildren:children];
					return YES;   
				}
				return NO;
				
				}
}


// Object Handler Methods
- (void)setQuickIconForObject:(QSObject *)object{
    [object setIcon:[QSResourceManager imageNamed:@"com.apple.keychainaccess"]];
}
- (BOOL)loadIconForObject:(QSObject *)object{
	NSImage *icon=nil;
	
	if ([[object primaryType]isEqualToString:QSKeychainInternetPasswordType]){
		icon=[QSResourceManager imageNamed:@"KeychainURLIcon"];
	}
	if ([[object primaryType]isEqualToString:QSKeychainGenericPasswordType]){
		if ([[[object primaryObject]objectForKey:@"'desc'"]isEqual:@"secure note"])
			icon=[QSResourceManager imageNamed:@"KeychainSecureNoteIcon"];
		else
			icon=[QSResourceManager imageNamed:@"KeychainKeyIcon"];
	}
	if ([[object primaryType]isEqualToString:QSKeychainAppleSharePasswordType]){
		icon=[QSResourceManager imageNamed:@"KeychainNetVolIcon"];
	}
	
	if (icon){
		[object setIcon:icon];
		return YES;
	}
	
	return NO;
}
- (BOOL)drawIconForObject:(QSObject *)object inRect:(NSRect)rect flipped:(BOOL)flipped{
	if(NSWidth(rect)<=32) return NO;
	NSImage *image=[QSResourceManager imageNamed:@"com.apple.keychainaccess"];
	
    [image setSize:[[image bestRepresentationForSize:rect.size] size]];
	//[image adjustSizeToDrawAtSize:rect.size];
	[image setFlipped:flipped];
	[image drawInRect:rect fromRect:rectFromSize([image size]) operation:NSCompositeSourceOver fraction:1.0];
	
	if ([object iconLoaded]){
		NSImage *cornerBadge=[object icon];
		if (cornerBadge!=image){
			[cornerBadge setFlipped:flipped]; 
			NSImageRep *bestBadgeRep=[cornerBadge bestRepresentationForSize:rect.size];    
			[cornerBadge setSize:[bestBadgeRep size]];
			NSRect badgeRect=rectFromSize([cornerBadge size]);
			
			//NSPoint offset=rectOffset(badgeRect,rect,2);
			badgeRect=centerRectInRect(badgeRect,rect);
			badgeRect=NSOffsetRect(badgeRect,0,NSHeight(rect)/2-NSHeight(badgeRect)/2);
			
			[[NSColor colorWithDeviceWhite:1.0 alpha:0.8]set];
			//NSRectFillUsingOperation(NSInsetRect(badgeRect,-3,-3),NSCompositeSourceOver);
			[[NSColor colorWithDeviceWhite:0.75 alpha:1.0]set];
			//NSFrameRectWithWidth(NSInsetRect(badgeRect,-5,-5),2);
			[cornerBadge drawInRect:badgeRect fromRect:rectFromSize([cornerBadge size]) operation:NSCompositeSourceOver fraction:1.0];
		}
	}
	return YES;
}

@end


#define kQSKeychainItemShowAction @"QSKeychainItemShowAction"
#define kQSKeychainItemCopyPasswordAction @"QSKeychainItemCopyPasswordAction"
#define kQSKeychainItemGetPasswordAction @"QSKeychainItemGetPasswordAction"

#define kQSKeychainLock @"QSKeychainLock"
#define kQSKeychainUnlock @"QSKeychainUnlock"


@implementation QSKeychainActionProvider

//- (NSArray *) types{
//    return [NSArray arrayWithObjects:QSKeychainInternetPasswordType,QSKeychainGenericPasswordType,QSKeychainAppleSharePasswordType,nil];
//}
- (NSArray *)xvalidActionsForDirectObject:(QSObject *)dObject indirectObject:(QSObject *)iObject{
    return [NSArray arrayWithObjects:kQSKeychainItemCopyPasswordAction,kQSKeychainItemGetPasswordAction,nil];
}

- (QSObject *) showKeychainItem:(QSObject *)dObject{
    
	//AXUIElementRef app=AXUIElementCreateApplication(1099);
	
	
    return nil;
}

- (NSString *)passwordForKeychainObject:(QSObject *)dObject{
	NSDictionary *info=[dObject primaryObject];
	
	
	SecItemClass class=keychainClassForType([dObject primaryType]);
	
	SecKeychainSearchRef searchRef;
	CFTypeRef keychainRef=NULL;
	SecKeychainItemRef itemRef = NULL;
	OSStatus status;
	
	NSString *label=[info objectForKey:NSFileTypeForHFSTypeCode(kSecLabelItemAttr)];
	NSString *date=[info objectForKey:NSFileTypeForHFSTypeCode(kSecCreationDateItemAttr)];
	
	SecKeychainAttribute attrs[] = {
	{ kSecCreationDateItemAttr, [date length]+1, [date UTF8String]},
	{ kSecLabelItemAttr, [label length],[label UTF8String]} };
	///NSLog(@"label '%@' date  %d %d '%@' %@",label,[date length],[date cStringLength],[date dataUsingEncoding:NSUTF8StringEncoding],date);
	const SecKeychainAttributeList attributes = { sizeof(attrs)/sizeof(attrs[0]),attrs};
	
	
	NSString *password=nil;
	if (!(status=SecKeychainSearchCreateFromAttributes(keychainRef,class,&attributes,&searchRef))){
		while((status = SecKeychainSearchCopyNext(searchRef,&itemRef))!=errSecItemNotFound){
			int length;
			void *data;
			if(SecKeychainItemCopyContent(itemRef, NULL, NULL, &length, &data)==noErr) {
                password=[NSString stringWithCString:data length: length];
                SecKeychainItemFreeContent(NULL, data);
            }
			//logKeychainEntry(itemRef);
			//NSLog(@"Pass %@ %p %d",password,itemRef,status);
			
		}
		CFRelease(searchRef);
	}
	return password;
}
- (BOOL)copyPasswordForObject:(QSObject *)dObject{
	NSString *password=[self passwordForKeychainObject:dObject];
	
	if (password){
		NSPasteboard *pboard=[NSPasteboard generalPasteboard];
		[pboard declareTypes:[NSArray arrayWithObjects:NSStringPboardType,QSPrivatePboardType,nil] owner:self];
		[pboard setString:password forType:NSStringPboardType];
		[pboard setString:password forType:QSPrivatePboardType];
		
	}
	return password!=nil;
}
- (QSObject *) copyPassword:(QSObject *)dObject{
	[self copyPasswordForObject:dObject];
	return nil;
}

- (QSObject *) pastePassword:(QSObject *)dObject{
	if ([self copyPasswordForObject:dObject]){
	[[NSNotificationCenter defaultCenter] postNotificationName:@"WindowsShouldHide" object:self];
	[[NSApp keyWindow]orderOut:self];
	QSForcePaste();
	}else{
		NSBeep();
		NSLog(@"Could not find password for %@",dObject);
	}
	return nil;
}

- (QSObject *) getPassword:(QSObject *)dObject{
	NSString *password=[self passwordForKeychainObject:dObject];
	if (password)return [QSObject objectWithString:password];
    return nil;
}


/*
 show_key("10.0.1.100")
 
 on show_key(theKey)
 tell application "System Events"
 tell application process "Keychain Access"
 tell table 1 of scroll area 1 of group 1 of window 1
 set theValues to value of text field 1 of rows
 repeat with i from 1 to count theValues
 if length of item i of theValues = (length of theKey) + 2 then
 if item i of theValues ends with theKey then
 
 select row i
 return i
 
 end if
 end if
 --log item i of theValues
 --log theKey
 end repeat
	end tell
	end tell
	end tell
	return 0
	end show_key
 
 */

@end


/* OLD attribute copying code: crashed when getting label attribute
UInt32 tags[]={kSecGenericItemAttr,kSecAccountItemAttr,kSecDescriptionItemAttr,kSecCommentItemAttr,kSecTypeItemAttr,kSecServiceItemAttr};
int count=sizeof(tags) / sizeof(tags[0]);
SecKeychainAttributeInfo info = { count, &tags,NULL };
while((status = SecKeychainSearchCopyNext(searchRef,&itemRef))!=errSecItemNotFound){
	logKeychainEntry(itemRef);
	
	status=SecKeychainItemCopyAttributesAndData(itemRef,&info,NULL,&attrList,NULL,NULL);
	//attrList=*attrList;
	if (!status){
		
		NSLog(@"--");
		int i;
		for (i=0;i<count;i++){
			//NSLog(@"%d - %@",i,[NSString stringWithCString:attrList->attr[i].data length:attrList->attr[i].length]);
		}
		
	}else{NSLog(@"err %d",status);}
	SecKeychainItemFreeAttributesAndData(attrList,NULL);
	*/
