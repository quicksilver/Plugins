//
//  QSHomestarRunnerSBEmailSource.m
//  QSHomestarRunnerPlugIn
//
//  Created by Brian Donovan on Mon Oct 25 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "QSHomestarRunnerSBEmailHandler.h"

@implementation QSHomestarRunnerSBEmailHandler

- (BOOL)loadChildrenForObject:(QSObject *)object {
//	NSLog( @"-loadChildrenForObject: %@", [object identifier] );
	
	if( [[object identifier] isEqualToString:HRSBEmailListID] ) {
		/* load emails */
		[object setChildren:[QSHomestarRunnerPlugIn fixQSObjectArray:[self fetchEmailsWithParent:object]]];
	} else if( [[object identifier] hasPrefix:HRSBEmailItem] ) {
		/* load email data */
		[object setChildren:[QSHomestarRunnerPlugIn fixQSObjectArray:[self fetchEmailData:object]]];
	} else if( [[object identifier] isEqualToString:HRCharacterList] ) {
		/* load cast */
		[object setChildren:[QSHomestarRunnerPlugIn fixQSObjectArray:[QSHomestarRunnerPlugIn castForObject:object]]];
	} else {
		return NO;
	}
	
	return YES;
}

- (BOOL)objectHasChildren:(QSObject *)object {
//	NSLog( @"-objectHasChildren: %@", [object identifier] );
	
	if( [[object identifier] isEqualToString:HRSBEmailListID] ) {
		/* email list */
		return YES;
	} else if( [[object primaryType] isEqualToString:HRSBEmailItem] ) {
		/* email item */
		return YES;
	} else if( [[object primaryType] isEqualToString:HRCharacterList] ) {
		/* character list */
		return YES;
	}
	
	return NO;
}

- (NSArray *)fetchEmailsWithParent:(QSObject *)parent {
	NSLog( @"-fetchEmailsWithParent" );
	
	NSString *indexPage, *emailPage;
	NSMutableString *emailText;
	NSMutableArray *emails;
	
	/* load either from the cache or the web */
	indexPage = [NSString stringWithContentsOfURL:[NSURL URLWithString:HRWikiSBEmailList] orCache:[NSString stringWithFormat:HRTempItem, HRSBEmailList] ifCreatedSinceNow:(-kHRTimeoutEmailList)];
	
	AGRegex *emailRegex = [AGRegex regexWithPattern:HRWikiSBEmailLinkPat options:AGRegexCaseInsensitive];
	NSEnumerator *matches = [emailRegex findEnumeratorInString:indexPage];
	AGRegexMatch *match;
	QSObject *object;
	NSImage *icon = [QSHomestarRunnerPlugIn iconForEntryType:HRSBEmailItem];
	
	/* enumerate through the emails and create objects for them */
	emails = [NSMutableArray array];
	while( match = [matches nextObject] ) {
		object = [QSObject makeObjectWithIdentifier:[NSString stringWithFormat:HRSBEmailItemID, [match groupAtIndex:kHRSBEmailGroupIndex]]];
		[object setName:[match groupAtIndex:kHRSBEmailGroupIndex]];
		[object setLabel:[match groupAtIndex:kHRSBEmailGroupName]];
		[object setObject:[[NSURL URLWithString:[match groupAtIndex:kHRSBEmailGroupURL] relativeToURL:URL(HRWikiBase)] absoluteString] forType:HRSBEmailItem];
		[object setPrimaryType:HRSBEmailItem];
		[object setIcon:icon];
		[object setParentID:[parent identifier]];
		
		/* add the email excerpt if available */
		emailPage = [NSString stringWithFormat:HRTempItem, [object identifier]];
		if( [[NSFileManager defaultManager] fileExistsAtPath:emailPage] ) {
			emailText = [[[NSMutableString alloc] initWithContentsOfFile:emailPage] autorelease];
			emailText = [emailText stringBetweenString:HRWikiSBEmailStart andString:HRWikiSBEmailEnd];
			
			if( emailText ) {
				[object setDetails:[emailText stringForSingleLineDisplay]];
			}
		}
		
		[emails addObject:object];
	}
	
	return emails;
}

- (NSArray *)fetchEmailData:(QSObject *)email {
//	NSLog( @"-fetchEmailData: %@", [email identifier] );
	NSString *emailPage;
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:3];
	
	emailPage = [NSString stringWithContentsOfURL:[NSURL URLWithString:[email objectForType:QSURLType]] orCache:[NSString stringWithFormat:HRTempItem, [email identifier]] ifCreatedSinceNow:(-kHRTimeoutEmailItem)];
	
	QSObject *object;
	AGRegexMatch *link;
	AGRegex *linkRegex = [AGRegex regexWithPattern:HRWikiExternalLinkPat options:AGRegexCaseInsensitive];
	NSEnumerator *links = [linkRegex findEnumeratorInString:[emailPage substringFromIndex:[emailPage rangeOfString:@"<a name=\"External_Links\">"].location]];
	
	object = [QSObject makeObjectWithIdentifier:HRCharacterListID];
	[object setName:@"Cast"];
	[object setObject:[email objectForType:QSURLType] forType:QSURLType];
	[object setObject:[email identifier] forType:HRCharacterList];
	[object setPrimaryType:HRCharacterList];
	[object setParentID:[email identifier]];
	[array addObject:object];

	if( link = [links nextObject] ) {
		object = [QSObject makeObjectWithIdentifier:[NSString stringWithFormat:HRSBEmailViewerID, [email name]]];
		[object setLabel:[NSString stringWithFormat:@"watch \"%@\"", [email label]]];
		[object setName:[email name]];
		[object setObject:[link groupAtIndex:kHRSBEmailGroupEntry] forType:QSURLType];
		[object setParentID:[email identifier]];
		[array addObject:object];
		NSLog( @"%@", [link groupAtIndex:kHRSBEmailGroupEntry] );
	}
	if( link = [links nextObject] ) {
		object = [QSObject makeObjectWithIdentifier:[NSString stringWithFormat:HRSBEmailFlashID, [email name]]];
		[object setLabel:[NSString stringWithFormat:@"\"%@\" flash file", [email label]]];
		[object setName:[[link groupAtIndex:kHRSBEmailGroupEntry] lastPathComponent]];
		[object setObject:[link groupAtIndex:kHRSBEmailGroupEntry] forType:QSURLType];
		[object setParentID:[email identifier]];
		[array addObject:object];
		NSLog( @"%@", [link groupAtIndex:kHRSBEmailGroupEntry] );
	}
	
	return array;
}

@end
