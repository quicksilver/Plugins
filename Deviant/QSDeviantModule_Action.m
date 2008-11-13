//
//  QSDeviantModule_Action.m
//  QSDeviantModule
//
//  Created by Nicholas Jitkoff on 7/13/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//

#import <QSFoundation/NDAlias.h>
//#import "NSImage_Extensions.h"
#import <signal.h>

#define DESKTOP_PATH [NSHomeDirectory() stringByAppendingPathComponent:@"Desktop"]
#define DESKTOP_PATH_OLD [NSHomeDirectory() stringByAppendingPathComponent:@"Desktop (Disabled)"]
#define archivedDesktopKey @"Deviant archivedDesktop"
#define archivedDesktopAliasKey @"Deviant archivedDesktopAlias"
#define autoRestoreKey @"Deviant autoRestore"
#define linkedDesktopKey @"Deviant linkedDesktop"
#define desktopListKey @"Deviant desktops"

#define donateURL @"https://www.paypal.com/xclick/business=nicholas%40blacktree.com&item_name=Deviant+Freeware+Donation&no_note=0&tax=0&currency_code=USD"
#define siteURL @"http://www.blacktree.com/apps/?app=deviant"


#import <QSCore/QSNotifyMediator.h>
#import <QSCore/QSCore.h>
#import "QSDeviantModule_Action.h"

@implementation QSDeviantActionProvider


#define QSDeviantSwitchDesktopAction @"QSDeviantSwitchDesktopAction"

- (NSArray *)validActionsForDirectObject:(QSObject *)dObject indirectObject:(QSObject *)iObject{
	BOOL isDirectory;
	
	if ([dObject singleFilePath]){
		if ([[NSFileManager defaultManager]fileExistsAtPath:[dObject singleFilePath] isDirectory:&isDirectory] && isDirectory && ![dObject isApplication]){
			return [NSArray arrayWithObject:QSDeviantSwitchDesktopAction];
		}
		
	}
	return nil;
}
- (QSObject *)linkToDesktop:(QSObject *)dObject{
	NSString *path=[dObject singleFilePath];
	
	if ([path isEqualToString:[self archivedDesktop]])
		[self restoreDesktop:self];
	else
		[self linkDesktopToPath:[dObject singleFilePath]];
	
	QSShowNotifierWithAttributes([NSDictionary dictionaryWithObjectsAndKeys:
		[[NSBundle bundleForClass:[self class]]imageNamed:@"deviant"], QSNotifierIcon,
		@"Desktop set to:",QSNotifierTitle,
		[path lastPathComponent],QSNotifierText,
		nil]);
	
	return nil;
}


-(bool)currentDesktopIsLink{
    NSFileManager *manager=[NSFileManager defaultManager];
    NSDictionary *fattrs = [manager fileAttributesAtPath:DESKTOP_PATH traverseLink:NO];
	
    if (fattrs && [[fattrs objectForKey:NSFileType] isEqualToString: NSFileTypeSymbolicLink])
        return YES;
    else
        return NO;
}

//
//  DeviantMenuExtra.m
//  Deviant
//
//  Created by Nicholas Jitkoff on Tue Jan 21 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//
-(void)linkDesktopToPath:(NSString*)path{
    if (!path) return;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"Deviant: Linking Desktop to: %@", path);
	
    bool canLink=NO;
    NSFileManager *manager=[NSFileManager defaultManager];
	
    if ([self currentDesktopIsLink])
        canLink=[manager removeFileAtPath:DESKTOP_PATH handler:nil];
    else{
        NSString *archivedDesktop=[defaults objectForKey:archivedDesktopKey];
        if (!archivedDesktop)archivedDesktop=DESKTOP_PATH_OLD;
        NSLog(@"Deviant: Archiving Desktop to:%@",archivedDesktop); 
        canLink=[manager movePath:DESKTOP_PATH toPath:archivedDesktop handler:nil];
        [defaults setObject:[[NDAlias aliasWithPath:archivedDesktop]data] forKey:archivedDesktopAliasKey];
		
		
    }
	
    if (!canLink) NSLog(@"Deviant: Desktop Link Blocked");
	
    if ([manager createSymbolicLinkAtPath:DESKTOP_PATH pathContent:path]){
        [self restartFinder];
		[self restartUIServer];
        [defaults setObject:path forKey:linkedDesktopKey];
        [defaults synchronize];
    }
    else NSLog(@"Deviant: Desktop Link Failed");
	
  //  [recentDesktops removeObject:path];
   // [recentDesktops addObject:path];
	
 //   [defaults setObject:recentDesktops forKey:desktopListKey];
    [defaults synchronize];
	
}


-(void)restoreDesktop:(id)sender{
    NSLog(@"Deviant: Restoring Desktop Folder"); 
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSFileManager *manager=[NSFileManager defaultManager];
	
    NSString *archivedDesktop=[self archivedDesktop];
	
    if ([self currentDesktopIsLink]){
        [manager removeFileAtPath:DESKTOP_PATH handler:nil];
        if (archivedDesktop)
            [manager movePath:archivedDesktop toPath:DESKTOP_PATH handler:nil];
        else
            [manager createDirectoryAtPath:DESKTOP_PATH attributes:nil];
		
        [defaults removeObjectForKey:archivedDesktopAliasKey];
        [self restartFinder]; //Restart Finder
        [defaults removeObjectForKey:linkedDesktopKey]; //Remove linked desktop key
        [defaults synchronize];
    }
	
  //  if (!loading) [self restartSystemUIServer];
}


-(NSString *)archivedDesktop{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSFileManager *manager=[NSFileManager defaultManager];
    NSData *archivedDesktopAliasData=[defaults dataForKey:archivedDesktopAliasKey];
    NSString *archivedDesktop=nil;
    if (archivedDesktopAliasData && (archivedDesktop=[[NDAlias aliasWithData:archivedDesktopAliasData]path])){
        [defaults setObject:archivedDesktop forKey:archivedDesktopKey];
        NSLog(@"Deviant: Archived Desktop (alias) is %@",archivedDesktop);  
    }
    if (!archivedDesktop && [manager fileExistsAtPath:[defaults objectForKey:archivedDesktopKey]]){
        archivedDesktop=[defaults objectForKey:archivedDesktopKey];
		NSLog(@"Deviant: Archived Desktop (path) is %@",archivedDesktop);  
    }
    if (!archivedDesktop){
        //NSLog(@"Deviant: Archived Desktop not found"); 
    }
    [defaults synchronize];
	
    return archivedDesktop;
}


-(void)restartUIServer{
	system("/usr/bin/killall SystemUIServer");
}

-(void)restartFinder{
//	[[NSWorkspace sharedWorkspace]dictForApplicationName:@"Finder"];
	 NSLog(@"Deviant: Restarting Finder");
    [self quitFinder];
	
	NSWorkspace *workspace=[NSWorkspace sharedWorkspace];
	NSDate *date=[NSDate date];
	while([date timeIntervalSinceNow]-5 && [[[workspace launchedApplications]valueForKey:@"NSApplicationBundleIdentifier"]containsObject:@"com.apple.Finder"]){
	//	NSLog(@"waiting");
		[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];	
	}	
	
	[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];	
	//NSLog(@"waiting");
	[self runFinder];
}


-(void)quitFinder{
    NSLog(@"Deviant: Quitting Finder");
    system("osascript -e 'tell application \"Finder\" to quit'");
}
-(void)runFinder{
    NSLog(@"Deviant: Launching Finder");
	
	NSWorkspace *workspace=[NSWorkspace sharedWorkspace];
	[workspace launchApplication:@"/System/Library/CoreServices/Finder.app"];
}


/*

@implementation DeviantMenuExtra


///////////////////////////////////////////////////////////////
//
//	NSMenuExtra init/dealloc
//
///////////////////////////////////////////////////////////////


+ (void)initialize{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults registerDefaults: [NSDictionary dictionaryWithObjectsAndKeys:
        DESKTOP_PATH_OLD ,archivedDesktopKey,
        [NSNumber numberWithBool:YES],autoRestoreKey,
        [NSArray array], desktopListKey,
        nil]];
}


- initWithBundle:(NSBundle *)bundle {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    // Menu item we are setting up at first
    NSMenuItem			*menuItem;

    // Allow super to init
    self = [super initWithBundle:bundle];
    if (!self) return nil;

    
    if ([defaults boolForKey:autoRestoreKey] && [[defaults arrayForKey:@"menuExtras"] containsObject:[bundle bundlePath]]){
        NSString *linkedDesktop=[defaults objectForKey:linkedDesktopKey];
        if ([self currentDesktopIsLink]){
            NSLog(@"Deviant: AutoRestore: Desktop is a link. Restoring.");
            [self restoreDesktop:nil];
            //unloading=YES;
            //[self quitFinder];
            //unloading=NO;
            //[self restartSystemUIServer];
        }
        if (linkedDesktop){
            //NSLog(@"Deviant: AutoRestore: Relinking to: %@",linkedDesktop);
            //[self linkDesktopToPath:linkedDesktop];
            //[self restartFinder];
            //reloadTimer=[[NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(timerLink:) userInfo:linkedDesktop repeats:NO] retain];
            
           }
    }


    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(workspaceWillPowerOff:) name:NSWorkspaceWillPowerOffNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appLaunching:) name:NSApplicationDidFinishLaunchingNotification object:NSApp];

    [self setImage:[[NSImage alloc]initWithContentsOfFile:[bundle pathForResource:@"deviant" ofType:@"tif"]]];

    [self setAlternateImage:[[NSImage alloc]initWithContentsOfFile:[bundle pathForResource:@"deviant_selected" ofType:@"tif"]]];
    [self setTitle:@"Deviant"];

     return self;

} // initWithBundle



- (void)timerLink:(NSTimer *)aTimer{
    NSLog(@"timerFired, restore: %@",[aTimer userInfo]);

    [self linkDesktopToPath:[aTimer userInfo]];
    [reloadTimer invalidate];
    [reloadTimer release];
    reloadTimer=nil;
}




-(void)toggleAutoRestore:(id)sender{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:![defaults boolForKey:autoRestoreKey] forKey:autoRestoreKey];
    [defaults synchronize];
}

-(NSString *)currentDesktop{
    NSFileManager *manager=[NSFileManager defaultManager];

    if ([self currentDesktopIsLink])
        return [manager pathContentOfSymbolicLinkAtPath:DESKTOP_PATH];
    else
        return DESKTOP_PATH;
}



-(void)restartSystemUIServer{
    NSLog(@"Deviant: Restarting UIServer");
    [[NSUserDefaults standardUserDefaults]synchronize];
    kill([[NSProcessInfo processInfo] processIdentifier],SIGKILL);
}


- (void)dealloc {
    loading=YES;
    [self restoreDesktop];
    [self restartFinder];
    [super dealloc];
} // dealloc

- (void)showDesktop:(id)sender{
}

- (IBAction)donate:(id)sender{
    [[NSWorkspace sharedWorkspace]openURL:[NSURL URLWithString:donateURL]];
}

- (void)setDesktop:(id)sender{
    [self linkDesktopToPath:[sender representedObject]];
}

- (void)clearRecent:(id)sender{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [recentDesktops setArray:[NSMutableArray arrayWithCapacity:1]];
    [defaults setObject:recentDesktops forKey:desktopListKey];
    [defaults synchronize];
}

@end
*/


@end