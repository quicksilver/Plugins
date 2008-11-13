

#import "QSCommandLineToolPrefPane.h"
#import "QSCommandLineTool.h"
#import <QSCore/QSResourceManager.h>

#include <Security/Authorization.h>
#include <Security/AuthorizationTags.h>


@implementation QSCommandLineToolPrefPane
- (id)init {
    self = [super initWithBundle:[NSBundle bundleForClass:[QSCommandLineToolPrefPane class]]];
    if (self) {
    }
    return self;
}

- (NSImage *) paneIcon{
	return [QSResourceManager imageNamed:@"ExecutableBinaryIcon"];
}

- (NSImage *) paneName{
	return @"CL Tool";
}

- (NSImage *) paneDescription{
	return @"Configure the Command Line Tool";
}


- (NSString *) mainNibName{
	return @"QSCommandLineToolPrefPane";
}

- (void)mainViewDidLoad{
	[self populateFields];
	[toolImageView setImage:[self paneIcon]];
}

- (void) populateFields{
	[toolInstallStatus setStringValue:([self toolIsInstalled]?@"Installed":@"Not installed")];
}


- (void)setValueForSender:(id)sender{
	if (sender==toolInstallButton){
		[self installCommandLineTool:self];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:kToolIsInstalled];
		[[QSCommandLineTool sharedInstance]startToolConnection];
		[self populateFields];
	}	
}

- (BOOL)toolIsInstalled{
    NSFileManager *manager=[NSFileManager defaultManager];
    return [manager fileExistsAtPath:@"/usr/bin/qs"];
}

- (IBAction)installCommandLineTool:(id)sender{
    NSFileManager *manager=[NSFileManager defaultManager];
    NSString *toolPath=[[NSBundle bundleForClass:[self class]]pathForResource:@"qs" ofType:@""];
    if ([manager fileExistsAtPath:@"/usr/bin/qs"])
		
		NSLog(@"%@", toolPath);    
    
    OSStatus myStatus;
    AuthorizationFlags myFlags = kAuthorizationFlagDefaults;                //1
    AuthorizationRef myAuthorizationRef;             //2
    
    myStatus = AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment,             //3
                                   myFlags, &myAuthorizationRef);               //4
    if (myStatus != errAuthorizationSuccess)
        return;// myStatus;
        
        do 
        {
        {
            AuthorizationItem myItems = {kAuthorizationRightExecute, 0,             //5
                NULL, 0};                //6
            AuthorizationRights myRights = {1, &myItems};            //7
            
            myFlags = kAuthorizationFlagDefaults |           //8
                kAuthorizationFlagInteractionAllowed |           //9
                kAuthorizationFlagPreAuthorize |         //10
                kAuthorizationFlagExtendRights;         //11
            myStatus = AuthorizationCopyRights (myAuthorizationRef,                     &myRights, NULL, myFlags, NULL );           //12
        }
            
            if (myStatus != errAuthorizationSuccess) break;
            
            {
                char myToolPath[] = "/bin/cp";
                char *myArguments[] = {(char *)[toolPath cString],"/usr/bin", NULL };
                FILE *myCommunicationsPipe = NULL;
                char myReadBuffer[128];
                
                myFlags = kAuthorizationFlagDefaults;             //13
                myStatus = AuthorizationExecuteWithPrivileges           //14
                    (myAuthorizationRef, myToolPath, myFlags, myArguments,          //15
                     &myCommunicationsPipe);         //16
                
                if (myStatus == errAuthorizationSuccess)
                    for(;;)
                    {
                        int bytesRead = read (fileno (myCommunicationsPipe),
                                              myReadBuffer, sizeof (myReadBuffer));
                        if (bytesRead < 1) break;
                        write (fileno (stdout), myReadBuffer, bytesRead);
                    }
            }
        } while (0);
            
            AuthorizationFree (myAuthorizationRef, kAuthorizationFlagDefaults);                //17
            
            // if (myStatus) printf("Status: %i\n", myStatus);
            return ;//myStatus;
}


@end




//
//
//NSPasteboard * pboard = [NSPasteboard pasteboardWithUniqueName];
//
//int fileArgs=1;
//BOOL putOnShelf=NO;
//if (argc>1 && !strcmp(argv[1],"-s")){
//	//NSLog(@"Object ");
//	fileArgs++;
//	putOnShelf=YES;
//}
//
////NSLog(@"pipe? %d %d",fileArgs,argc);
//if(argc <= fileArgs){
//	// NSLog(@"pipe");
//	NSFileHandle * fhandle = [NSFileHandle fileHandleWithStandardInput];
//	NSData * data = [fhandle readDataToEndOfFile];
//	[pboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:data];
//	[pboard setData:data forType:NSStringPboardType];
//}else{
//	int i;
//	NSMutableArray *filenames=[NSMutableArray arrayWithCapacity:argc-1];
//	NSFileManager *manager=[NSFileManager defaultManager];
//	NSString *currentPath=[manager currentDirectoryPath];
//	//NSLog(currentPath);
//	for (i=1;i<argc;i++){
//		NSString *currentFile=[[NSString stringWithCString:argv[i]]stringByStandardizingPath];
//		if (![currentFile hasPrefix:@"/"])
//			currentFile=[currentPath stringByAppendingPathComponent:currentFile];
//		if ([manager fileExistsAtPath:currentFile isDirectory:nil])
//			[filenames addObject:currentFile];
//	}       
//	if ([filenames count]){
//		[pboard declareTypes:[NSArray arrayWithObject:NSFilenamesPboardType] owner:nil];
//		[pboard setPropertyList:filenames forType:NSFilenamesPboardType];
//	}
//}   
//
//[proxy setProtocolForProxy:@protocol(QSCommandLineTool)];
//
//if (putOnShelf) [proxy putOnShelfFromPasteboard:pboard];
//else [proxy readSelectionFromPasteboard:pboard];
