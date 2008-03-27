//
//  QSTextManipulationPlugIn.m
//  QSTextManipulationPlugIn
//
//  Created by Nicholas Jitkoff on 3/31/05.
//  Copyright __MyCompanyName__ 2005. All rights reserved.
//

#import "QSTextManipulationPlugIn.h"
#define kQSTextAppendAction @"QSTextAppendAction"
#define kQSTextPrependAction @"QSTextPrependAction"
#define textTypes [NSArray arrayWithObjects:@"'TEXT'", @"txt", @"sh", @"pl", @"rb", @"html", @"htm", nil]
#define richTextTypes [NSArray arrayWithObjects:@"rtf", @"doc", @"rtfd", nil]

//@interface NSAttributedString (QSTextManipulationPlugIn)
//
//@end
//
//@implementation NSAttributedString (QSTextManipulationPlugIn)

//
//
//@end


@implementation QSTextManipulationPlugIn

- (NSArray *)validActionsForDirectObject:(QSObject *)dObject indirectObject:(QSObject *)iObject {
  if ([dObject containsType:QSFilePathType])
		return nil;
  return [NSArray arrayWithObjects:kQSTextAppendAction, kQSTextPrependAction, nil];
}

- (NSArray *)validIndirectObjectsForAction:(NSString *)action directObject:(QSObject *)dObject {
	if ([action isEqualToString:@"QSTextPrependAction"] || [action isEqualToString:@"QSTextAppendAction"])
		return nil;
	QSObject *textObject = [QSObject textProxyObjectWithDefaultValue:@""];
	return [NSArray arrayWithObject:textObject]; //[QSLibarrayForType:NSFilenamesPboardType];
}



- (QSObject *)prependObject:(QSObject *)dObject toObject:(QSObject *)iObject {
  return [self appendObject:(QSObject *)dObject toObject:(QSObject *)iObject atBeginning:YES];
}
- (QSObject *)appendObject:(QSObject *)dObject toObject:(QSObject *)iObject {
  return [self appendObject:(QSObject *)dObject toObject:(QSObject *)iObject atBeginning:NO];
  
}
- (QSObject *)appendObject:(QSObject *)dObject toObject:(QSObject *)iObject atBeginning:(BOOL)atBeginning {
	
	if ([iObject containsType:@"QSLineReferenceType"]) {
		
		NSDictionary *reference = [iObject objectForType:@"QSLineReferenceType"];
		NSString *file = [[reference objectForKey:@"path"] stringByStandardizingPath];
		NSString *string = [NSString stringWithContentsOfFile:file];
		
		NSMutableArray *lines = [[[string lines] mutableCopy] autorelease]; 		
		int lineIndex = [[reference objectForKey:@"line"] intValue];
		if (atBeginning) lineIndex--;
		[lines insertObject:[dObject stringValue] atIndex:lineIndex];
		//NSLog(@"iObject %@ %@", [dObject objectForType:@"QSLineReferenceType"] , lines);
//		
		[[lines componentsJoinedByString:@"\r"] writeToFile:file atomically:NO];
		
		return [QSObject fileObjectWithPath:file];
	} else {
		NSString *path = [iObject singleFilePath];
		NSString *type = [[NSFileManager defaultManager] typeOfFile:path];
    NSLog(@"type %@", type);
    if ([richTextTypes containsObject:type]) {
      NSDictionary *docAttributes = nil;
      NSError *error = nil;
      NSMutableAttributedString *astring = [[NSMutableAttributedString alloc] initWithURL:[NSURL fileURLWithPath:path]
                                                                                  options:nil
                                                                       documentAttributes:&docAttributes
                                                                                    error:&error];
      NSDictionary *attributes = [astring attributesAtIndex:atBeginning ? 0 : [astring length]-1
                                             effectiveRange:nil];
      NSAttributedString *newlineString = [[[NSAttributedString alloc] initWithString:@"\n" attributes:attributes] autorelease];
      NSAttributedString *appendString = [[[NSAttributedString alloc] initWithString:[dObject stringValue]  attributes:attributes] autorelease];
      
			NSString *text = [NSString stringWithContentsOfFile:path];
			if (atBeginning) {
        [astring insertAttributedString:newlineString atIndex:0];
        [astring insertAttributedString:appendString atIndex:0];
			} else {
				unichar lastChar = [[astring string] characterAtIndex:[astring length] - 1];
				BOOL newlineAtEnd = lastChar == '\r' || lastChar == '\n';
        if (!newlineAtEnd) [astring appendAttributedString:newlineString];
        [astring appendAttributedString:appendString];
        if (newlineAtEnd) [astring appendAttributedString:newlineString];
      }
      
      NSFileWrapper *wrapper = [astring fileWrapperFromRange:NSMakeRange(0, [astring length])
                                          documentAttributes:docAttributes error:&error];
      
      if (!error)
        [wrapper writeToFile:path atomically:NO updateFilenames:YES];
      
    } else if ([textTypes containsObject:type]) {    
			NSString *text = [NSString stringWithContentsOfFile:path];
			if (atBeginning) {
				text = [NSString stringWithFormat:@"%@\n%@", [dObject stringValue] , text];  
			} else {
				unichar lastChar = [text characterAtIndex:[text length] -1];
				BOOL newlineAtEnd = lastChar == '\r' || lastChar == '\n';
				text = [NSString stringWithFormat:newlineAtEnd?@"%@%@\n":@"%@\n%@", text, [dObject stringValue]];
			}
			[text writeToFile:path atomically:NO];
		} else {
			NSBeep();  
		}
		return iObject;
	}
}




- (QSObject *)deleteLineReference:(QSObject *)dObject {
	NSString *file = [[[dObject objectForType:@"QSLineReferenceType"] objectForKey:@"path"] stringByStandardizingPath];
	NSNumber *line = [[dObject objectForType:@"QSLineReferenceType"] objectForKey:@"line"];
	int lineNum = [line intValue] -1;
	
	NSString *string = [NSString stringWithContentsOfFile:file];
	
	string = [string stringByReplacing:@"\n" with:@"\r"];
	
	NSMutableArray *lines = [[[string componentsSeparatedByString:@"\r"] mutableCopy] autorelease];
	
	NSString *fileLine = [lines objectAtIndex:lineNum];
	//NSLog(@"\r%@\r%@", [dObject stringValue] , fileLine);
	if ([[dObject stringValue] isEqualToString:fileLine]) {
		[lines removeObjectAtIndex:lineNum];
		[[lines componentsJoinedByString:@"\n"] writeToFile:file atomically:NO];
	} else {
		NSBeep();
		QSShowLargeType(@"Contents of file have changed. Line was not deleted.");
	}
	return nil;
}

- (QSObject *)changeLineReference:(QSObject *)dObject to:(QSObject *)iObject {
	NSString *file = [[[dObject objectForType:@"QSLineReferenceType"] objectForKey:@"path"] stringByStandardizingPath];
	NSNumber *line = [[dObject objectForType:@"QSLineReferenceType"] objectForKey:@"line"];
	int lineNum = [line intValue] -1;
	
	NSString *replacement = [iObject stringValue];
	
	NSString *string = [NSString stringWithContentsOfFile:file];
	NSMutableArray *lines = [[[string lines] mutableCopy] autorelease];
	
	
	NSString *fileLine = [lines objectAtIndex:lineNum];
	NSLog(@"\r%@\r%@", [dObject stringValue] , fileLine);
	if ([[dObject stringValue] isEqualToString:fileLine]) {
		[lines replaceObjectAtIndex:lineNum withObject:replacement];
		[[lines componentsJoinedByString:@"\n"] writeToFile:file atomically:NO];
	} else {
		NSBeep();
		QSShowLargeType(@"Contents of file have changed. Change was abandoned.");
	}
	return [QSObject fileObjectWithPath:file];
}



@end
