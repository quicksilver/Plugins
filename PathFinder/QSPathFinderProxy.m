

#import "QSPathFinderProxy.h"
@implementation QSPathFinderProxy
- (id) init{
    if (self=[super init]){
        // NSDictionary *errorDict=nil;
//		NSString *path=[[NSBundle bundleForClass:[QSPathFinderProxy class]]pathForResource:@"PathFinder" ofType:@"scpt"];
  //      pathFinderScript=[[NSAppleScript alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:nil];
    }
    return self;
}
- (void)dealloc{
    [pathFinderScript release];
    [super dealloc];
}
- (NSImage *)icon{
    return [[NSWorkspace sharedWorkspace] iconForFile:
        [[NSWorkspace sharedWorkspace] fullPathForApplication:@"Path Finder"]];   
}

- (NSArray *)selection{
	return [[self pathFinderListener]selectedPaths];
}

- (BOOL)openFile:(NSString *)file{
	NSWorkspace *workspace=[NSWorkspace sharedWorkspace];
    NSFileManager *manager=[NSFileManager defaultManager];
    BOOL isDirectory;
    if ([manager fileExistsAtPath:file isDirectory:&isDirectory]){
        if (isDirectory && ![workspace isFilePackageAtPath:file]){
			[self activatePathFinder];
             [[self pathFinderListener]showPath:file inNewWindow:YES];
		return YES;
        }else{
			return  [workspace openFile:file];
        }
    }
    return NO;
}


- (void)revealFile:(NSString *)file{
	
	[self activatePathFinder];
	[[self pathFinderListener]showPath:file inNewWindow:YES];

}

- (NSArray *)getInfoForFiles:(NSArray *)files{
	
	[self activatePathFinder];
	NSEnumerator *e=[files objectEnumerator]; // *** should resolve aliases
	NSString *thisFile;
	while(thisFile=[e nextObject])
		[[self pathFinderListener]showInfoForPath:thisFile];
	
	return nil;
}


- (void)activatePathFinder{
	NSWorkspace *workspace=[NSWorkspace sharedWorkspace];
	NSDictionary *dict=[workspace dictForApplicationIdentifier:@"com.cocoatech.PathFinder"];
		if (dict)
			[workspace switchToApplication:dict frontWindowOnly:YES];
	else
		[workspace launchAppWithBundleIdentifier:@"com.cocoatech.PathFinder" options:nil additionalEventParamDescriptor:nil launchIdentifier:nil];
}

- (id <pathFinderListener>)pathFinderListener{
	NSConnection *_connection = [NSConnection connectionWithRegisteredName:@"Path FinderListener" host:nil];
	if (_connection)
	{
		return (id <pathFinderListener>)[_connection rootProxy];
	}
	return nil;
}


	
	
/*

- (NSArray *)oldSelection{
    NSDictionary *errorDict=nil;
    NSAppleEventDescriptor *desc=[pathFinderScript executeSubroutine:@"get_selection" arguments:nil error:&errorDict];
    if (errorDict) NSLog(@"Execute Error: %@",errorDict);
    NSMutableArray *files=[NSMutableArray arrayWithCapacity:[desc numberOfItems]];
    int i;
    for (i=0;i<[desc numberOfItems];i++)
        [files addObject:[[desc descriptorAtIndex:i+1]stringValue]];
    return files;
}


- (BOOL)oldOpenFile:(NSString *)file{
    
    NSFileManager *manager=[NSFileManager defaultManager];
    BOOL isDirectory;
    if ([manager fileExistsAtPath:file isDirectory:&isDirectory]){
        if (isDirectory)
            return[[NSWorkspace sharedWorkspace] openFile:file withApplication:@"Path Finder"];
        else
			return  [[NSWorkspace sharedWorkspace] openFile:file];
        
    }
    return NO;
}


- (void)oldRevealFile:(NSString *)file{
    NSLog(@"reveal %@",file);
    NSDictionary *errorDict=nil;
    [pathFinderScript executeSubroutine:@"reveal" arguments:[NSArray arrayWithObject:file] error:&errorDict];
    if (errorDict){
        NSLog(@"Execute Error: %@",errorDict);
        [[NSWorkspace sharedWorkspace] selectFile:file inFileViewerRootedAtPath:@""];
        NSPasteboard *pboard=[NSPasteboard pasteboardWithUniqueName];
        [pboard declareTypes:[NSArray arrayWithObject:NSFilenamesPboardType] owner:self];
        [pboard setPropertyList:[NSArray arrayWithObject:file] forType:NSFilenamesPboardType];
        BOOL success=NSPerformService(@"Path Finder/Reveal in Path Finder", pboard);
        if (success) return;// YES;
			NSLog(@"Path Finder Reveal Service Failed, using openFile:");
			[[NSWorkspace sharedWorkspace] openFile:file withApplication:@"Path Finder"];
    }
    return;// YES;
}

- (NSArray *)oldGetInfoForFiles:(NSArray *)files{
    NSDictionary *errorDict=nil;
    
    //NSAppleEventDescriptor *desc=
	[pathFinderScript executeSubroutine:@"get_info" arguments:[NSArray arrayWithObject:files] error:&errorDict];
    if (errorDict)
        NSLog(@"Execute Error: %@",errorDict);
    return nil;
}
*/
- (NSArray *)copyFiles:(NSArray *)files toFolder:(NSString *)destination{return nil;}
- (NSArray *)moveFiles:(NSArray *)files toFolder:(NSString *)destination{return nil;}

- (BOOL)loadChildrenForObject:(QSObject *)object{
	NSArray *newChildren=[QSObject fileObjectsWithPathArray:[self selection]];
	[object setChildren:newChildren];
	return YES;   	
}

-(id)resolveProxyObject:(id)proxy{
	return [QSObject fileObjectWithArray:[self selection]];
}

@end
