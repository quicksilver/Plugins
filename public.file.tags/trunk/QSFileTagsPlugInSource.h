//
//  QSFileTagsPlugInSource.h
//  QSFileTagsPlugIn
//
//  Created by Nicholas Jitkoff on 5/3/05.
//  Copyright __MyCompanyName__ 2005. All rights reserved.
//


#import "QSFileTagsPlugInSource.h"

@interface QSFileTagsPlugInSource : QSObjectSource{
	NSMetadataQuery *tagQuery;
}
- (NSArray *) tagsFromQuery:(NSMetadataQuery *)aQuery;
@end

