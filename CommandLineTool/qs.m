#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>


@protocol QSCommandLineTool
- (void)handleArguments:(NSArray *)array input:(NSData *)input directory:(NSString *)directory;
- (NSString *)usageText;
@end

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

    id proxy=[NSConnection rootProxyForConnectionWithRegisteredName:@"Quicksilver Command Line Tool" host:nil];
    if (proxy){
		[proxy setProtocolForProxy:@protocol(QSCommandLineTool)];

	
		// If help requested, print usage
		if ( argc==2 && (!strcmp(argv[1],"-h") || !strcmp(argv[1],"-?") || !strcmp(argv[1],"--help"))){
			NSString *usageText=[proxy usageText];
			fprintf(stderr,"%s\n",[usageText UTF8String]);
			return 0;
		}
		
		NSMutableArray *arguments=[NSMutableArray arrayWithCapacity:argc];
		NSData *input=nil;
		
		// Get CWD
		NSFileManager *manager=[NSFileManager defaultManager];
		NSString *directory=[manager currentDirectoryPath];		
		
		// Convert arguments to NSArray
		int i;
		for(i=0;i<argc;i++){
			[arguments addObject:[NSString stringWithUTF8String:argv[i]]];
		}
		
		// If last argument is a dash or no arguments, read stdin and provide
		if (argc==1 || !strcmp(argv[argc-1],"-")){
			//fprintf(stderr,"%s\r",[usageText UTF8String]);
			NSFileHandle * fhandle = [NSFileHandle fileHandleWithStandardInput];
			input = [fhandle readDataToEndOfFile];
		}
		
	
		
		// Send data to Quicksilver
		[proxy handleArguments:arguments input:input directory:directory];
		
    }else{	
		fprintf(stderr,"Unable to connect to Quicksilver\n");
		return 1;
    }    
    
    [pool release];
    return 0;
}
