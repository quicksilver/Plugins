

#import "QSHFSAttributeActions.h"



# define kHFSInvisibleAction @"QSHFSMakeInvisibleAction"
# define kHFSVisibleAction @"QSHFSMakeVisibleAction"
# define kHFSLockAction @"QSHFSLockAction"
# define kHFSUnlockAction @"QSHFSUnlockAction"
# define kHFSSetLabelAction @"QSHFSSetLabelAction"



@implementation QSHFSAttributeActions

- (NSArray *)validActionsForDirectObject:(QSObject *)dObject indirectObject:(QSObject *)iObject{
    NSArray *paths=[dObject validPaths];
    NSMutableArray *newActions=[NSMutableArray arrayWithCapacity:1];
    if (paths){
        [newActions addObject:kHFSInvisibleAction];
        [newActions addObject:kHFSVisibleAction];
        [newActions addObject:kHFSLockAction];
        [newActions addObject:kHFSUnlockAction];
        [newActions addObject:kHFSSetLabelAction];
		[newActions addObject:@"QSSetFileCommentAction"];
    }        
    return newActions;
}

- (NSArray *)labelObjectsArray{    
    NSMutableArray *objects=[NSMutableArray arrayWithCapacity:1];
    QSObject *newObject;
	
	newObject=[QSObject objectWithName:@"None"];
	[newObject setObject:[NSNumber numberWithInt:0] forType:QSNumericType];
	[objects addObject:newObject];
	
	NSMutableDictionary *labelsDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
		@"None",@"Label_Name_0",
		@"Gray",@"Label_Name_1",
		@"Green",@"Label_Name_2",
		@"Purple",@"Label_Name_3",
		@"Blue",@"Label_Name_4",
		@"Yellow",@"Label_Name_5",
		@"Red",@"Label_Name_6",
		@"Orange",@"Label_Name_7",
		nil];
	
	
	NSMutableDictionary *colorsDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
		[NSColor clearColor],@"Label_Name_0",
		[NSColor grayColor],@"Label_Name_1",
		[NSColor greenColor],@"Label_Name_2",
		[NSColor purpleColor],@"Label_Name_3",
		[NSColor blueColor],@"Label_Name_4",
		[NSColor yellowColor],@"Label_Name_5",
		[NSColor redColor],@"Label_Name_6",
		[NSColor orangeColor],@"Label_Name_7",
		nil];
	
	[labelsDict addEntriesFromDictionary:
		[(NSDictionary *)CFPreferencesCopyMultiple((CFArrayRef)[labelsDict allKeys], (CFStringRef) @"com.apple.Labels", kCFPreferencesCurrentUser, kCFPreferencesAnyHost) autorelease]];
	
	int i=0;
	for (i=1;i<8;i++){
		NSString *entry=[NSString stringWithFormat:@"Label_Name_%d",i];
		newObject=[QSObject objectWithName:[labelsDict objectForKey:entry]];
		[newObject setObject:[NSNumber numberWithInt:i] forType:QSNumericType];
		[newObject setObject:[NSArchiver archivedDataWithRootObject:[colorsDict objectForKey:entry]] forType:NSColorPboardType];
		[newObject setPrimaryType:NSColorPboardType];
		[objects addObject:newObject];
	}
	
	return objects;
}

- (NSArray *)validIndirectObjectsForAction:(NSString *)action directObject:(QSObject *)dObject{	
	if ([action isEqualToString:kHFSSetLabelAction]){
		return [self labelObjectsArray];
	}else if ([action isEqualToString:@"QSSetFileCommentAction"]){
		NSString *comment=[[NSWorkspace sharedWorkspace]commentForFile:[dObject singleFilePath]];
		return [NSArray arrayWithObject:[QSObject textProxyObjectWithDefaultValue:comment?comment:@""]];
	}
	return nil;
}



- (BOOL)setPath:(NSString *)path isVisible:(BOOL)visible{
    OSStatus status = noErr;
    FSRef fsRef;
    
    status=FSPathMakeRef([path UTF8String],&fsRef,NULL);
    
    if (status != noErr) return 0;
    
    FSCatalogInfo catalogInfo;
    status = FSGetCatalogInfo(& fsRef, kFSCatInfoFinderInfo,&catalogInfo, NULL, NULL, NULL);
    
    if (status != noErr) return 0;
    
    FileInfo* info = (FileInfo*)&catalogInfo.finderInfo;
    if (visible)
        info->finderFlags &= ~kIsInvisible;
    else
        info->finderFlags |= kIsInvisible;
    
    status = FSSetCatalogInfo(& fsRef, kFSCatInfoFinderInfo, &catalogInfo);
    
    return 1;
}

- (BOOL)setPath:(NSString *)path isLocked:(BOOL)locked{
    FSRef theRef;
    FSCatalogInfo catInfo;
    OSErr err=noErr;
    err=FSPathMakeRef([path UTF8String],&theRef,NULL);
    // check for err here. noErr==0
    err=FSGetCatalogInfo(&theRef,kFSCatInfoNodeFlags,&catInfo,NULL,NULL,NULL);
    // check for err here.
    if (locked)
        catInfo.nodeFlags |= kFSNodeLockedMask;
    else
        catInfo.nodeFlags &= ~kFSNodeLockedMask;
    err=FSSetCatalogInfo(&theRef,kFSCatInfoNodeFlags,&catInfo);
    //check for err here.
    [[NSWorkspace sharedWorkspace] noteFileSystemChanged:path ];
    
    return YES;
}

- (QSObject *)makeInvisible:(QSObject *)dObject{
    NSString* path;
    NSEnumerator *pathEnumerator=[[dObject arrayForType:QSFilePathType]objectEnumerator];
    while (path=[pathEnumerator nextObject]){
        [self setPath:path isVisible:NO];
        [[NSWorkspace sharedWorkspace] noteFileSystemChanged:path ];
    }
    return nil;
}

- (QSObject *)makeVisible:(QSObject *)dObject{
    NSString* path;
    NSEnumerator *pathEnumerator=[dObject enumeratorForType:QSFilePathType];
    while (path=[pathEnumerator nextObject]){
        [self setPath:path isVisible:YES];
      //  [[NSWorkspace sharedWorkspace] noteFileSystemChanged:path ];
    }
    return nil;
}  

- (QSObject *)lock:(QSObject *)dObject{
    NSString* path;
    NSEnumerator *pathEnumerator=[dObject enumeratorForType:QSFilePathType];
    while (path=[pathEnumerator nextObject]){
        [self setPath:path isLocked:YES];
       // [[NSWorkspace sharedWorkspace] noteFileSystemChanged:[path stringByDeletingLastPathComponent]];
    }
    return nil;
}

- (QSObject *)unlock:(QSObject *)dObject{
    NSString* path;
    NSEnumerator *pathEnumerator=[dObject enumeratorForType:QSFilePathType];
    while (path=[pathEnumerator nextObject]){
        [self setPath:path isLocked:NO];
        //[[NSWorkspace sharedWorkspace] noteFileSystemChanged:[path stringByDeletingLastPathComponent]];
    }
    return nil;
}




// *** purify

- (void) setLabel:(int)label forPath:(NSString *)path{
    FSCatalogInfo info;
	FSRef par;
	FSRef ref;
    Boolean dir = false;
    
	if (FSPathMakeRef([path fileSystemRepresentation],&par,&dir) == noErr) {
		HFSUniStr255 fork = {0,{0}};
		SInt16 refnum = kResFileNotOpened;
        
        /* Get the Finder Catalog Info */
        OSErr err = FSGetCatalogInfo(&par,
                                     kFSCatInfoContentMod | kFSCatInfoFinderXInfo | kFSCatInfoFinderInfo,
                                     &info,
                                     NULL,
                                     NULL,
                                     NULL);
        
        if (err != noErr)
		{
            NSLog(@"Unabled to get catalog info... %i", err);
			return;
		}
        
        /* Manipulate the Finder CatalogInfo */
        UInt16 *flags = &((FileInfo*)(&info.finderInfo))->finderFlags;
        
        //To Turn off
        // *flags &= kColor;
        
        /*
         0 is off
         1 is Grey
         2 is Green
         3 is Purple
         4 is Blue
         5 is Yellow
         6 is Red
         7 is Orange
         */
        
        //int label = label;
        *flags = ( *flags &~ kColor) | ( (label << 1) & kColor );
        
        /* Set the Finder Catalog Info Back */
        err = FSSetCatalogInfo(&par,
                               kFSCatInfoContentMod | kFSCatInfoFinderXInfo | kFSCatInfoFinderInfo,
                               &info);
        
        if (err != noErr)
        {
            NSLog(@"Unable to set catalog info... %i", err);
            return;
        }
    }
}

- (QSObject *)setLabelForFile:(QSObject *)dObject to:(QSObject *)iObject{
    NSString* path;
	NSNumber *value=[iObject objectForType:QSNumericType];
	if (!value) return nil;
	int label=[value intValue];
	//NSLog(@"setlabel %d",label);
    NSEnumerator *pathEnumerator=[dObject enumeratorForType:QSFilePathType];
    while (path=[pathEnumerator nextObject]){
		[self setLabel:label forPath:path];
        [[NSWorkspace sharedWorkspace] noteFileSystemChanged:path];
    }
    return nil;
}


- (QSObject *)setCommentForFile:(QSObject *)dObject to:(QSObject *)iObject{
    NSEnumerator *pathEnumerator=[dObject enumeratorForType:QSFilePathType];
	NSString *newComment=[iObject stringValue];
	NSString *path;
    while (path=[pathEnumerator nextObject]){
        [[NSWorkspace sharedWorkspace] setComment:newComment forFile:path];
    }
    return nil;
}

- (QSObject *)setIconForFile:(QSObject *)dObject to:(QSObject *)iObject{
	NSWorkspace *w=[NSWorkspace sharedWorkspace];
	NSString *sourcePath=[iObject singleFilePath];
	NSImage *icon=[[[NSImage alloc]initWithContentsOfFile:sourcePath]autorelease];
	if (!icon)icon=[w iconForFile:sourcePath];
	
	NSEnumerator *pathEnumerator=[dObject enumeratorForType:QSFilePathType];
	NSString *path;
    while (path=[pathEnumerator nextObject]){
        [[NSWorkspace sharedWorkspace] setIcon:icon forFile:path options:NSExclude10_4ElementsIconCreationOption];
		[[NSWorkspace sharedWorkspace] noteFileSystemChanged:path ];
    }
    return nil;
}


@end


