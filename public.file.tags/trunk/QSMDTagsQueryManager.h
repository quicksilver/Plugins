//
//  QSMDTagsQueryManager.h
//  QSFileTagsPlugIn
//
//  Created by Etienne on 11/09/08.
//  Copyright 2008 Etienne Samson. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define gTagPrefix [[NSUserDefaults standardUserDefaults] objectForKey:@"QSTagPrefix"]
#define QSFileTagType @"qs.tag.file"

@interface QSObject (QSFileTagsHandling)
+ (QSObject *)objectForTag:(NSString *)tag;
@end

@interface QSMDTagsQueryManager : NSObject {
    NSMutableDictionary *tagQueries; /* tagPrefix, query */
    NSMutableDictionary *tagDelegates; /* tagPrefix, set of ids */
}
+ (id)sharedInstance;

- (BOOL)startScanningForTagPrefix:(NSString*)tagPrefix delegate:(id)delegate;
- (BOOL)isScanningForTagPrefix:(NSString*)tagPrefix;
- (void)stopScanningForTagPrefix:(NSString*)tagPrefix delegate:(id)delegate;

- (NSArray*)tagsWithTagPrefix:(NSString*)tagPrefix;
- (NSArray*)filesForTag:(NSString*)tag;
- (NSArray*)filesForTags:(NSArray*)tags;

/* NSString Helpers for tag prefixes */
- (NSString *)stringByAddingTagPrefix:(NSString *)string;
- (NSString *)stringByRemovingTagPrefix:(NSString *)string;
@end

@interface NSObject (QSMDTagsQueryManagerDelegate)
- (void)tagQueryDidUpdate:(NSString*)tagPrefix;
@end