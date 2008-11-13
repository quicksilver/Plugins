//
//  QSIndigoPlugIn_Source.h
//  QSIndigoPlugIn
//
//  Created by Nicholas Jitkoff on 10/19/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//


#import "QSIndigoPlugIn_Source.h"



@interface QSIndigoPlugIn_Source : NSObject
@end

@interface QSIndigoDBParser : NSObject{
	
	NSMutableString *currentStringValue;
	NSMutableArray *deviceList;
	NSMutableDictionary *currentDevice;
}
@end

