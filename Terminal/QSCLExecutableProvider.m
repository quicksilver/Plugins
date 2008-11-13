

#import "QSCLExecutableProvider.h"


#import <QSCore/QSCore.h>


#import <QSCore/QSObject_StringHandling.h>

#import <QSCore/QSDefines.h>

//#define kQSCLExecuteAction @"ShellScriptRunAction"
#define kQSCLExecuteWithArgsAction @"QSShellScriptRunAction"
//#define kQSCLTermExecuteAction @"QSCLTermExecuteAction"
#define kQSCLTermExecuteWithArgsAction @"QSCLTermExecuteWithArgsAction"
#define kQSCLTermShowDirectoryAction @"QSCLTermShowDirectoryAction"
#define kQSCLTermShowManPageAction @"QSCLTermShowManPageAction"


#define kQSCLExecuteTextAction @"QSCLExecuteTextAction"
#define kQSCLTermExecuteTextAction @"QSCLTermExecuteTextAction"

# define kShellScriptRunAction @"ShellScriptRunAction"
# define kShellScriptTextRunAction @"ShellScriptTextRunAction"
# define kShellScriptTextRunInTerminalAction @"ShellScriptTextRunInTerminalAction"
#define QSShellScriptTypes [NSArray arrayWithObjects:@"sh",@"pl",@"command",@"php",@"py",@"'TEXT'",@"rb",@"",nil]

@implementation QSCLExecutableProvider

- (NSArray *)validActionsForDirectObject:(QSObject *)dObject indirectObject:(QSObject *)iObject{
    if ([dObject objectForType:NSFilenamesPboardType]){
        NSString *path=[dObject singleFilePath];
        if (!path)return nil;
        
		BOOL isDirectory;
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory] && isDirectory)
			return [NSArray arrayWithObject:kQSCLTermShowDirectoryAction];
        
        
        BOOL executable=[[NSFileManager defaultManager] isExecutableFileAtPath:path];
        //NSLog(@"exec %d",executable);
        if (![QSShellScriptTypes containsObject:[[NSFileManager defaultManager]typeOfFile:path]]) return nil;
        if (!executable){
            NSString *contents=[NSString stringWithContentsOfFile:path];
            if ([contents hasPrefix:@"#!"])executable=YES;
			else if (VERBOSE) NSLog(@"No Shebang found");
        }else{
            LSItemInfoRecord infoRec;
            LSCopyItemInfoForURL((CFURLRef)[NSURL fileURLWithPath:path],kLSRequestBasicFlagsOnly, &infoRec);
            if (infoRec.flags & kLSItemInfoIsApplication) // Ignore applications
                executable=NO;
        }
        if (executable){
            return [NSArray arrayWithObjects:kQSCLExecuteWithArgsAction,kQSCLTermExecuteWithArgsAction,kQSCLTermShowManPageAction,nil];
        }
    }
    //NSLog(@"nope %@",[[dObject singleFilePath]pathExtension]);
    return nil;
}

- (NSArray *)validIndirectObjectsForAction:(NSString *)action directObject:(QSObject *)dObject{
    QSObject *proxy=[QSObject textProxyObjectWithDefaultValue:@""];
    return [NSArray arrayWithObject:proxy];
    
}

- (QSObject *) executeObject:(QSObject *)dObject arguments:(QSObject *)iObject{
	NSString *result=[self runExecutable:[(QSObject *)dObject singleFilePath] withArguments:[iObject stringValue] inTerminal:NO];
    if ([result length]) return [QSObject objectWithString:result];
    return nil;
}

- (QSObject *) executeObjectInTerm:(QSObject *)dObject arguments:(QSObject *)iObject{    
    NSString *result=[self runExecutable:[(QSObject *)dObject singleFilePath] withArguments:[iObject stringValue] inTerminal:YES];
    if ([result length]) return [QSObject objectWithString:result];
    return nil;
}

- (NSString *)runExecutable:(NSString *)path withArguments:(NSString *)arguments inTerminal:(BOOL)inTerminal{
    BOOL executable=[[NSFileManager defaultManager] isExecutableFileAtPath:path];
    
    NSString *taskPath=path;
    NSMutableArray *argArray=[NSMutableArray array]; 
    
    if (!executable){
        NSString *contents=[NSString stringWithContentsOfFile:path];
        NSScanner *scanner=[NSScanner scannerWithString:contents];
        [argArray addObject:taskPath];
        [scanner scanString:@"#!" intoString:nil];
        [scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\r\n"] intoString:&taskPath];
    }//else if (!inTerminal){
	 //taskPath=@"/bin/sh";
	 //[argArray addObject:@"-c"];
	 //[argArray addObject:taskPath];
	 //}
    
    if ([arguments length]);
    [argArray addObjectsFromArray:[arguments componentsSeparatedByString:@" "]];

    if (inTerminal){
        NSString *fullCommand=[NSString stringWithFormat:@"%@ %@",[self escapeString:taskPath],[argArray componentsJoinedByString:@" "]];
        [self performCommandInTerminal:fullCommand];      
		///  NSLog(@"Run Shell Script: %@",fullCommand);
    }else{
        
        NSTask *task=[[[NSTask alloc]init]autorelease];
        [task setLaunchPath:taskPath];
        [task setArguments:argArray];
        [task setStandardOutput:[NSPipe pipe]];
        [task launch];
        [task waitUntilExit];
		// NSLog(@"Run Task: %@ %@",taskPath,argArray);
        
        NSString *string=[[[NSString alloc] initWithData:[[[task standardOutput]fileHandleForReading] readDataToEndOfFile] encoding:NSUTF8StringEncoding]autorelease];
        int status = [task terminationStatus];
        if (status == 0) NSLog(@"Task succeeded.");
        else NSLog(@"Task failed.");
        return string;
}
return nil;
}
- (NSString *)escapeString:(NSString *)string{
    NSString *escapeString=@"\\!$&\"'*(){[|;<>?~` ";
    
    int i;
    for (i=0;i<[escapeString length];i++){
        NSString *thisString=[escapeString substringWithRange:NSMakeRange(i,1)];
        string=[[string componentsSeparatedByString:thisString]componentsJoinedByString:[@"\\" stringByAppendingString:thisString]];
        
    }
    return string;
}

- (QSObject *) showManPage:(QSObject *)dObject{
    NSString *path=[dObject singleFilePath];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"x-man-page://%@",[path lastPathComponent]]]];
    return nil;
}

- (QSObject *) executeText:(QSObject *)dObject{
	NSString *string=[dObject objectForType:QSShellCommandType];
	if (!string)string=[dObject stringValue];
	
	if ([string rangeOfString:@"sudo" options:NSCaseInsensitiveSearch].location!=NSNotFound){
		NSLog(@"sudo in %@",string);
		if (![self sudoIfNeeded]){
			NSBeep();
			return nil;
		}
	}
    NSTask *task=[[[NSTask alloc]init]autorelease];
    [task setLaunchPath:@"/bin/sh"];
    [task setArguments:[NSArray arrayWithObjects:@"-c",string,nil]];
    [task setStandardOutput:[NSPipe pipe]];
    [task launch];
    [task waitUntilExit];
	
    NSString *result=[[[NSString alloc] initWithData:[[[task standardOutput]fileHandleForReading] readDataToEndOfFile] encoding:NSUTF8StringEncoding]autorelease];
    int status = [task terminationStatus];
    if (status == 0) NSLog(@"Task succeeded.");
    else NSLog(@"Task failed.");
    
    if ([result length]) 
        return [QSObject objectWithString:result];
    
    return nil;
}

- (QSObject *) executeTextInTerminal:(QSObject *)dObject{
	NSString *string=[dObject objectForType:QSShellCommandType];
	if (!string)string=[dObject stringValue];
    [self performCommandInTerminal:string];
	return nil;
}

- (QSObject *) showDirectoryInTerminal:(QSObject *)dObject{
    NSString *path=[dObject singleFilePath];
    //  NSLog(@"path %@",path);
    [self performCommandInTerminal:[NSString stringWithFormat:@"cd %@",[self escapeString:path]]];
    return nil;
}

- (void)performCommandInTerminal:(NSString *)command{
	[[QSReg preferredTerminalMediator]performCommandInTerminal:(NSString *)command];
}
- (void)ok:(id)sender{[NSApp stopModalWithCode:1];}
- (void)cancel:(id)sender{[NSApp stopModalWithCode:0];}



- (BOOL)sudoIfNeeded{
	BOOL status=YES;
	while (status){
		NSTask *task=[NSTask taskWithLaunchPath:@"/usr/bin/sudo" arguments:[NSArray arrayWithObjects:@"-v",@"-S",nil]];
		[task setStandardInput:[NSPipe pipe]]; 
		[task setStandardError:[NSPipe pipe]];
		[task launch];
		NSData *data= [[[task standardError]fileHandleForReading]availableData];
		if ([data length]){
			if (!window)[NSBundle loadNibNamed:@"QSSudoPasswordAlert" owner:self];
			[window makeKeyAndOrderFront:self];
			int result=[NSApp runModalForWindow:window];
			[window close];
			
			if (!result){
				[task interrupt];
				return NO;
			}
			NSString *string=[[window initialFirstResponder]stringValue];
			//string=[string stringByAppendingString:@"\n"];
			[[[task standardInput]fileHandleForWriting]writeData:[string dataUsingEncoding:NSUTF8StringEncoding]];
			[[[task standardInput]fileHandleForWriting]closeFile];
		}
		
		usleep(250000);	
		if ([task isRunning])
			[task interrupt];
		else
			status=[task terminationStatus];
		if (status)
			NSBeep();
			//NSLog(@"term %d",status);
	}
	
	return !status;
}


- (void)setQuickIconForObject:(QSObject *)object{
	[object setIcon:[QSResourceManager imageNamed:@"ExecutableBinaryIcon"]];	
}

@end




