//
//  QSSpotlightPlugIn_Action.h
//  QSSpotlightPlugIn
//
//  Created by Nicholas Jitkoff on 10/28/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//

#import <QSCore/QSObject.h>
#import <QSCore/QSActionProvider.h>
#import "QSSpotlightPlugIn_Action.h"
#define QSSpotlightPlugIn_Type @"QSSpotlightPlugIn_Type"
@interface QSSpotlightPlugIn_Action : QSActionProvider
{
    NSMetadataQuery *_query;
    NSString *_searchKey;
    BOOL _searchContent;
	
}
@end

