

#import "QSCompressionActionProvider.h"

#import <QSCore/QSCore.h>


# define pBOMArchiveHelper @"/System/Library/CoreServices/BOMArchiveHelper.app"
# define kFileDecompressAction @"QSFileDecompressAction"
# define kFileCompressAction @"QSFileCompressAction"
//# import <StuffIt/StuffIt.h>

@implementation QSCompressionActionProvider

- (BOOL)tgzCompress:(NSArray *)paths destination:(NSString *)destinationPath{
	NSTask *task=[[[NSTask alloc]init]autorelease];
    [task setLaunchPath:@"/usr/bin/tar"];
    NSMutableArray *arguments=[NSMutableArray arrayWithObjects:@"-zcf",destinationPath,nil];
   foreach(path,paths){
		[arguments addObject:@"-C"];
		[arguments addObject:[path stringByDeletingLastPathComponent]];
		[arguments addObject:[path lastPathComponent]];
	}
	[task setArguments:arguments];
	[task launch];
	[task waitUntilExit];
	return [task terminationStatus]==0;	
}
- (BOOL)tbzCompress:(NSArray *)paths destination:(NSString *)destinationPath{
	NSTask *task=[[[NSTask alloc]init]autorelease];
    [task setLaunchPath:@"/usr/bin/tar"];
    NSMutableArray *arguments=[NSMutableArray arrayWithObjects:@"-jcf",destinationPath,nil];
   foreach(path,paths){
		[arguments addObject:@"-C"];
		[arguments addObject:[path stringByDeletingLastPathComponent]];
		[arguments addObject:[path lastPathComponent]];
	}
	[task setArguments:arguments];
	[task launch];
	[task waitUntilExit];
	return [task terminationStatus]==0;	
}
- (BOOL)cpgzCompress:(NSArray *)paths destination:(NSString *)destinationPath{
	NSTask *task=[[[NSTask alloc]init]autorelease];
    [task setLaunchPath:@"/usr/bin/ditto"];
    NSMutableArray *arguments=[NSMutableArray arrayWithObjects:@"-c",@"-z",@"-rsrc",@"--keepParent",nil];
    [arguments addObjectsFromArray:paths];
    [arguments addObject: destinationPath];
    [task setArguments:arguments];
    [task launch];
    [task waitUntilExit];
	return [task terminationStatus]==0;	
}
- (BOOL)cpioCompress:(NSArray *)paths destination:(NSString *)destinationPath{
	NSTask *task=[[[NSTask alloc]init]autorelease];
    [task setLaunchPath:@"/usr/bin/ditto"];
    NSMutableArray *arguments=[NSMutableArray arrayWithObjects:@"-c",@"-rsrc",@"--keepParent",nil];
    [arguments addObjectsFromArray:paths];
    [arguments addObject: destinationPath];
    [task setArguments:arguments];
    [task launch];
    [task waitUntilExit];
	return [task terminationStatus]==0;	
}
- (BOOL)zipCompress:(NSArray *)paths destination:(NSString *)destinationPath{
	NSTask *task=[[[NSTask alloc]init]autorelease];
    [task setLaunchPath:@"/usr/bin/ditto"];
    NSMutableArray *arguments=[NSMutableArray arrayWithObjects:@"-c",@"-k",@"-rsrc",@"--keepParent",nil];
    [arguments addObjectsFromArray:paths];
    [arguments addObject: destinationPath];
    [task setArguments:arguments];
    [task launch];
    [task waitUntilExit];
	return [task terminationStatus]==0;	
}

- (NSString *)temporaryPath{
	NSString *destinationPath=[NSTemporaryDirectory() stringByAppendingPathComponent:@"Quicksilver"];
	NSFileManager *fm=[NSFileManager defaultManager];
	[fm createDirectoriesForPath:destinationPath];
	return destinationPath;
}

- (QSObject *)compressFile:(QSObject *)dObject{
	[self compressFile:dObject withFormat:nil];
	return nil;
}
	
- (NSArray *)validIndirectObjectsForAction:(NSString *)action directObject:(QSObject *)dObject{
	NSMutableArray *array=[NSMutableArray array];
	foreachkey(ident,compressor,[QSReg tableNamed:@"QSFileCompressors"]){
		QSObject *object=[QSObject objectWithString:ident name:ident type:@"qs.filecompressortype"];
		NSString *iconName=nil;//[compressor objectForKey:@"icon"];
		[object setObject:iconName?iconName:@"com.apple.bomarchivehelper" forMeta:kQSObjectIconName];
		[array addObject:object];
	}
	return array;
}

- (QSObject *)compressFile:(QSObject *)dObject withFormat:(QSObject *)iObject{
		
	NSArray *sourcePaths=[dObject validPaths];
	
	NSString *type=[iObject stringValue];
	if (!type)type=[[NSUserDefaults standardUserDefaults]stringForKey:@"QSCompressionDefaultType"];
	if (!type)type=@"zip";
	BOOL useTempFile=[[NSUserDefaults standardUserDefaults]boolForKey:@"QSCompressionCreateTempFile"];
	
	
	NSString *destinationPath=nil;
	if (useTempFile){
		destinationPath=[self temporaryPath];
	}else{
		destinationPath=[[sourcePaths lastObject]stringByDeletingLastPathComponent];
	}
	
	if ([sourcePaths count]>1){
		destinationPath=[destinationPath stringByAppendingPathComponent:@"Archive"];
	}else{
		destinationPath=[destinationPath stringByAppendingPathComponent:
			[[[sourcePaths lastObject]lastPathComponent]stringByDeletingPathExtension]];
	}
	
	
	
	NSDictionary *info=[[QSReg tableNamed:@"QSFileCompressors"]objectForKey:type];
	NSString *extension=[info objectForKey:@"extension"];
	if (extension)
		destinationPath=[destinationPath stringByAppendingPathExtension:extension];
	destinationPath=[destinationPath firstUnusedFilePath];
	//NSLog(@"info %@ %@",info,destinationPath);
	BOOL success=[self performSelector:NSSelectorFromString([info objectForKey:@"selector"]) withObject:sourcePaths withObject:destinationPath];
	if (success){
		[[NSWorkspace sharedWorkspace] noteFileSystemChanged:[destinationPath stringByDeletingLastPathComponent]];
		return [QSObject fileObjectWithPath:destinationPath];
	}else{
		NSBeep();
		return nil;
	}
	return nil;
}


- (QSObject *)decompressFile:(QSObject *)dObject{
	NSEnumerator *e=[dObject enumeratorForType:QSFilePathType];
	NSString *path;
	while (path=[e nextObject])
		[[NSWorkspace sharedWorkspace] openFile:path withApplication:pBOMArchiveHelper];
    return nil;
}
@end
