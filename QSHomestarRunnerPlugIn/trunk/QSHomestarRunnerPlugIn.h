//
//  QSHomestarRunnerPlugIn.h
//  QSHomestarRunnerPlugIn
//
//  Created by Brian Donovan on Sun Oct 24 2004.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QSCore/QSObject.h>
#import "AGRegex.h"
#import "QSHomestarRunnerConstants.h"

@interface QSHomestarRunnerPlugIn : QSObjectSource
{
}

+ (QSObject *)objectForCharacter:(NSString *)character;
+ (NSArray *)fixQSObjectArray:(NSArray *)array;
+ (NSImage *)iconForResourceFile:(NSString *)file;
+ (NSImage *)iconForEntryType:(NSString *)type;
+ (NSArray *)castForObject:(QSObject *)object;

@end

@interface NSString (QSAdditionsInformalProtocol)

- (NSString *)stringBetweenString:(NSString *)str1 andString:(NSString *)str2;
- (NSString *)stringForSingleLineDisplay;
+ (NSString *)stringWithContentsOfURL:(NSURL *)url orCache:(NSString *)cachePath ifCreatedSinceNow:(NSTimeInterval)secs;
+ (NSString *)stringWithContentsOfURL:(NSURL *)url orCache:(NSString *)cachePath ifCreatedAfter:(NSDate *)date;

@end

@interface NSURL (QSAdditionsInformalProtocol)

- (NSString *)cachePath;

@end