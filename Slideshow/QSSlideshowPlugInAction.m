//
//  QSSlideshowPlugInAction.m
//  QSSlideshowPlugIn
//
//  Created by Nicholas Jitkoff on 5/13/05.
//  Copyright __MyCompanyName__ 2005. All rights reserved.
//


#import "QSSlideshowPlugInAction.h"

#import "Slideshow.h"

@implementation QSSlideshowPlugInAction

#define kQSSlideshowPlugInAction @"QSSlideshowPlugInAction"

- (QSObject *)runSlideshowForIPhotoAlbum:(QSObject *)dObject{
//	id album=[dObject objectForType:@"qs.apple.iPhoto.album"];
	[self runSlideshowForObjects:[dObject children]];
	return nil;
}



- (QSObject *)runSlideshowForFilesObject:(QSObject *)dObject{
	[self runSlideshowForObjects:[NSArray arrayWithObject:dObject]];
	return nil;
}

- (void)runSlideshowForObjects:(NSArray *)objects{
	
	Slideshow *show=[Slideshow sharedSlideshow];
	[show loadConfigData];
	
	NSDictionary *options=nil;
	
	
options=[NSDictionary dictionaryWithObjectsAndKeys:
		[NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithBool:NO],@"linear",
			[NSNumber numberWithFloat:20.0f],@"time",nil],
		@"FullScreenActualSize",
		[NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithFloat:1.0f],@"autoPlayDelay",
			[NSNumber numberWithFloat:3.0f],@"autoPlayTime",
			[NSNumber numberWithFloat:3.0f],@"manualTime",
			nil],
		@"ImageTransition",
		[NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithBool:NO],@"linear",
			[NSNumber numberWithFloat:20.0f],@"time",
			nil],
		@"timingInfo",
		nil];
	
	

	NSFileManager *fm=[NSFileManager defaultManager];
	BOOL isDirectory=NO;
	
	
	NSString *path=nil;
	NSArray *paths=nil;
	
	if ([objects count]==1 && [[objects lastObject] singleFilePath])
		path=[[objects lastObject] singleFilePath];
	
	if (path && [fm fileExistsAtPath:path isDirectory:&isDirectory] && isDirectory){
		paths=[fm directoryContentsAtPath:path];
		paths=[path performSelector:@selector(stringByAppendingPathComponent:) onObjectsInArray:paths returnValues:YES];
		paths=[paths pathsMatchingExtensions:[NSImage imageFileTypes]];
		//[show runSlideshowWithPDF:[NSURL fileURLWithPath:[dObject singleFilePath]] options:nil];
		[self setImages:paths];
	}else if (path && ![[path pathExtension]caseInsensitiveCompare:@"pdf"]){
		[show runSlideshowWithPDF:[NSURL fileURLWithPath:path] options:options];
		return;
	}else if ([objects count]==1){
		paths=[[objects lastObject] validPaths];
		[self setImages:paths];
	}else{
		[self setImages:objects];	
	}
	[show setDataSource:self];
	
	//[show setAutoPlayDelay:0.5];
	//[show startSlideshow:self];
	[show runSlideshowWithDataSource:self options:options];
	
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(slideshowDidStop:) name:@"SlideshowDidStopNotification" object:nil];
	return ;
}
- (void)slideshowDidStop:(id)notif{
	//	NSLog(@"notif %@\r%@",[notif name], notif);	
	[self setImages:nil];
}
- (BOOL)respondsToSelector:(SEL)aSelector{
	//if ( [super respondsToSelector:aSelector]) return YES;
	//NSLog(@"select %@",NSStringFromSelector(aSelector));
	//return NO;
	return  [super respondsToSelector:aSelector];
}

- (int)numberOfObjectsInSlideshow{
	return [images count];
}

- (id)slideshowObjectAtIndex:(int)index{
//	return [images objectAtIndex:index];
	id object=[images objectAtIndex:index];
	if ([object isKindOfClass:[NSString class]]){
		return object;
	}else{
		return [object singleFilePath];
		NSImage *image=[[[NSImage alloc]initByReferencingFile:[object singleFilePath]]autorelease];
		[image createRepresentationOfSize:NSMakeSize(128,128)];
		return image;//[object singleFilePath];
	}
}


- (NSString *)slideshowObjectNameAtIndex:(int)index{
//	NSLog(@"name");
	id object=[images objectAtIndex:index];
	if ([object isKindOfClass:[NSString class]])
		return [object lastPathComponent];
	else
		return [object name];
}
- (BOOL)canExportObjectAtIndexToiPhoto:(int)index{
	return YES;
}
- (void)exportObjectAtIndexToiPhoto:(int)index{
	id object=[images objectAtIndex:index];
	if ([object isKindOfClass:[NSString class]])
		[Slideshow addImageToiPhoto:[images objectAtIndex:index]];
	else
		[Slideshow addImageToiPhoto:[[images objectAtIndex:index]singleFilePath]];
	
}
//- (void)exportObjectsToiPhoto:(NSIndexSet *)indexes{
//	int index=-1;
//	while ((index=[indexes indexGreaterThanIndex:index])!=NSNotFound){
//		NSLog(@"exporting %d",index);	
//	}
//
//}
//

- (NSArray *)images { return [[images retain] autorelease]; }
- (void)setImages:(NSArray *)anImages
{
    if (images != anImages) {
        [images release];
        images = [anImages retain];
    }
}


@end
