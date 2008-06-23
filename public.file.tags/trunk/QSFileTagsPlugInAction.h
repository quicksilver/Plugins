//
//  QSFileTagsPlugInAction.h
//  QSFileTagsPlugIn
//
//  Created by Nicholas Jitkoff on 5/3/05.
//  Copyright __MyCompanyName__ 2005. All rights reserved.
//

#import <QSCore/QSObject.h>
#import <QSCore/QSActionProvider.h>
#import "QSFileTagsPlugInAction.h"


#define QSFileTagType @"qs.tag.file"

#define QSFileTagsPlugInType @"QSFileTagsPlugIn_Type"

@interface QSFileTagsPlugInAction : QSActionProvider
{
}
+ (NSString *)queryStringForTag:(NSString *)tag;
@end

