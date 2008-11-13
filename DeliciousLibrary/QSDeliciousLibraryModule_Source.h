//
//  QSDeliciousLibraryModule_Source.h
//  QSDeliciousLibraryModule
//
//  Created by Nicholas Jitkoff on 11/8/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//


#import "QSDeliciousLibraryModule_Source.h"

@interface QSDeliciousLibraryModule_Source : NSObject{

	BOOL inRecommendations;
	
	id currentItem;
	id currentShelf;
	NSMutableArray *items;
	NSMutableArray *shelves;
	NSMutableDictionary *library;
}
@end

