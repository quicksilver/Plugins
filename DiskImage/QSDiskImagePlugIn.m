//
//  QSDiskImagePlugIn.m
//  QSDiskImagePlugIn
//
//  Created by Nicholas Jitkoff on 2/7/05.
//  Copyright __MyCompanyName__ 2005. All rights reserved.
//

#import "QSDiskImagePlugIn.h"

@implementation QSDiskImagePlugIn
//- (NSArray *)objectsFromData:(NSData *)data encoding:(NSStringEncoding)encoding settings:(NSDictionary *)settings source:(NSURL *)source{
- (NSArray *)objectsFromPath:(NSString *)path withSettings:(NSDictionary *)settings{
	NSArray *array=[self mountDiskImage:path];
	
	//	NSLog(@"mounted %@",[array description]);
	return [QSObject fileObjectsWithPathArray:array];;
}


- (BOOL)loadChildrenForObject:(QSObject *)object{
	[self mountedDiskInfo];
	if ([[object primaryType]isEqualToString:NSFilenamesPboardType]){
		[object setChildren:nil];
		return YES;   	
	}
	return NO;
}



- (NSDictionary *)mountedDiskInfo{
	NSTask *task=[NSTask taskWithLaunchPath:@"/usr/bin/hdiutil" arguments:[@"info -plist" componentsSeparatedByString:@" "]];
	
	[task waitUntilExit];
}

- (NSDictionary *)mountDiskImage:(NSString *)path{
	//hdiutil mount  /Volumes/Lore/Desktop/Disk\ Image\ Test/Test.dmg -plist
	//[path
	
	[[QSTaskController sharedInstance]updateTask:@"MountImage" status:@"Mounting Disk Image" progress:-1];
	
	
	NSTask *task=[NSTask taskWithLaunchPath:@"/usr/bin/hdiutil" 
								  arguments:[NSArray arrayWithObjects:@"mount",path,@"-plist",nil]];
	
	NSData *output=[task launchAndReturnOutput];
	[[QSTaskController sharedInstance]removeTask:@"MountImage"];
	
	//NSLog(@"data %@",output);
	NSDictionary *dict=[NSPropertyListSerialization propertyListFromData:output
														mutabilityOption:NSPropertyListImmutable
																  format:nil
														errorDescription:nil];
	
	
	return [dict valueForKeyPath:@"system-entities.@distinctUnionOfObjects.mount-point"];
}





- (NSDictionary *)createDiskImageFromFolder:(QSObject *)object{
	NSString *path=[object singleFilePath];
	NSString *destPath=[path stringByAppendingPathExtension:@"dmg"];
	NSTask *task=[NSTask taskWithLaunchPath:@"/usr/bin/hdiutil" 
								  arguments:[NSArray arrayWithObjects:
									  @"create",@"-srcfolder",path,destPath,nil]];
	
	NSData *output=[task launchAndReturnOutput];
	
	return [QSObject fileObjectWithPath:destPath];
}




- (NSDictionary *)compactDiskImageObject:(QSObject *)object{
	NSString *path=[object singleFilePath];
	
	NSTask *task=[NSTask taskWithLaunchPath:@"/usr/bin/hdiutil" 
								  arguments:[NSArray arrayWithObjects:@"compact",path,@"-plist",nil]];
	
	NSData *output=[task launchAndReturnOutput];
	//		[[QSTaskController sharedInstance]removeTask:@"MountImage"];
	return nil;
	
}


- (NSDictionary *)compressDiskImageObject:(QSObject *)object{
	
	NSString *path=[object singleFilePath];
	NSString *destPath=[[path stringByDeletingPathExtension]
stringByAppendingPathExtension:@"c.dmg"];
	

	NSTask *task=[NSTask taskWithLaunchPath:@"/usr/bin/hdiutil" 
								  arguments:[NSArray arrayWithObjects:
									  @"convert",@"-format",@"UDZO",@"-o",destPath,path,nil]];

		NSData *output=[task launchAndReturnOutput];
	//		[[QSTaskController sharedInstance]removeTask:@"MountImage"];
	
	return [QSObject fileObjectWithPath:destPath];
	
}

- (NSDictionary *)internetEnableDiskImageObject:(QSObject *)object{
	NSString *path=[object singleFilePath];
	NSTask *task=[NSTask taskWithLaunchPath:@"/usr/bin/hdiutil" 
								  arguments:[NSArray arrayWithObjects:@"internet-enable",path,@"-plist",nil]];
	
	NSData *output=[task launchAndReturnOutput];
	//		[[QSTaskController sharedInstance]removeTask:@"MountImage"];
	
}


@end
