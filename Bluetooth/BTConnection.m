//
//  BTConnection.m
//  BuddyPop
//
//  Created by Yann Bizeul on Fri May 07 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "BTConnection.h"
//#import "PhoneNumber.h"

@interface BTConnection (Private)
- (void)_connect;
- (void)_retryConnect;
- (void)_sendData:(void*)buffer length:(UInt32)length ;
- (void)_flushBuffer;
- (int)_state;
- (void)_setState:(int)state;
@end
#define DEBUG 1
@implementation BTConnection
static id _sharedConnection = nil;
+ (BTConnection*)sharedConnection
{
    if (!_sharedConnection)
		_sharedConnection = [[ self alloc ] init ];
    
    return _sharedConnection;
}
+ (NSArray*)devicesWithService:(BluetoothClassOfDevice)service
{
    IOBluetoothDevice *currentDevice;
    NSArray *devices = [ IOBluetoothDevice pairedDevices];
    NSEnumerator *e = [devices objectEnumerator ];
    NSMutableArray *result = [NSMutableArray array];
    
    while (currentDevice = [ e nextObject ])
    {
		//00100000010000100001100 Alain Collet
		//10100100000001000000100 Ender
		//00000000010010110000000 MX900
		//10000000000000000000000
		//NSLog(@"%i : %@",[ device getClassOfDevice ], [ device getName ]);
		if ([ currentDevice getClassOfDevice ] & service)
			[result addObject: [NSDictionary dictionaryWithObjectsAndKeys:[currentDevice getName],@"name",[currentDevice getAddressString],@"address",nil]];
    }
    return [[result copy]autorelease];
}
+ (IOBluetoothDevice*)pairedDeviceWithName:(NSString*)aName
{
    IOBluetoothDevice *currentDevice;
    NSArray *devices = [ IOBluetoothDevice pairedDevices];
    NSEnumerator *e = [devices objectEnumerator ];
    
    while (currentDevice = [ e nextObject ])
    {
		//00100000010000100001100 Alain Collet
		//10100100000001000000100 Ender
		//00000000010010110000000 MX900
		//10000000000000000000000
		//NSLog(@"%i : %@",[ device getClassOfDevice ], [ device getName ]);
		if ([[currentDevice getName ]isEqual:aName])
			return currentDevice;
    }
    return nil;    
}
- (id)init
{
    self = [ super init ];
	
    device=nil;
    mRFCOMMChannel = nil;
    delegate = nil;
    state = kBTIdleState;
    commandsBuffer = [[ NSMutableArray array ]  retain ];   
	
    retryTimer = nil;
    stateTimer = [[NSTimer scheduledTimerWithTimeInterval:10
												   target:self
												 selector:@selector(notifyBTState:)
												 userInfo:nil
												  repeats:YES]retain];
    [stateTimer fire];
    
    [[[NSWorkspace sharedWorkspace]notificationCenter]addObserver:self
														 selector:@selector(handleSleep:)
															 name:@"NSWorkspaceDidWakeNotification"
														   object:nil];
    [[[NSWorkspace sharedWorkspace]notificationCenter]addObserver:self
														 selector:@selector(handleSleep:)
															 name:@"NSWorkspaceWillSleepNotification"
														   object:nil];
	// DEBUG = [[[ NSUserDefaults standardUserDefaults] objectForKey: @"DEBUG"] boolValue ];
    return self;
}
- (void)handleSleep:(NSNotification*)aNotification;
{
    if ([[aNotification name]isEqual:@"NSWorkspaceDidWakeNotification"] && reconnectAfterWakeUp)
    {
		if (DEBUG)
			NSLog(@"Machine wakes up, enabling bluetooth");
		reconnectAfterWakeUp = NO;
		[self connect];
    }
    else
    {
		if (DEBUG)
			NSLog(@"Machine goes to sleep, disabling bluetooth");
		[self disconnect];
		reconnectAfterWakeUp = YES;
    }
}
- (void)setDelegate:(id)anObject
{
    [ anObject retain ];
    [ delegate release ];
    delegate = anObject;
}
- (id)delegate
{
    return delegate;
}
- (NSString*)name
{
    if (device)
		return [device getName];
    return nil;
}
#pragma mark -
#pragma mark Connection/Disconnection
+ (BOOL)bluetoothAvailable
{
    BluetoothHCIVersionInfo     version;
    IOBluetoothGetVersion(NULL,&version);
    if(version.hciVersion)		// No bluetooth hardware detected
		return YES;
    return NO;
}
- (void)notifyBTState:(NSTimer*)aTimer
{
    if (previousState != [[self class]bluetoothAvailable])
		[[NSNotificationCenter defaultCenter]postNotificationName:@"BTDeviceStateChangedNotification"
														   object:nil];
    previousState = [[self class]bluetoothAvailable];
}

#pragma mark Device connection

-(void)connect
{
    [self _connect];
}
-(void)connect:(NSTimer*)timer
{
    if (DEBUG) NSLog(@"Retrying connection to device");
	
    [retryTimer release];
    retryTimer = nil;
    
    [ self _connect ];
}
-(void)_connect
{
    IOReturn status;
    
    if (DEBUG) NSLog(@"Connection request");
    
    if(! [[self class] bluetoothAvailable])				// No bluetooth hardware detected
    { if (DEBUG) NSLog(@"No bluetooth Hardware detected"); return; }
    
    if (! device)							// No device supplied
    { if (DEBUG) NSLog(@"No Device supplied"); return; }
	
    if (!btNotification)
		btNotification = [[ device registerForDisconnectNotification: self selector: @selector(deviceConnectionClosed:device:) ]retain];
	
    if ([ device isConnected ])						// Already connected
    {
		if (DEBUG) NSLog(@"Already connected"); 
		[self _openRFCOMM];
		return;
    }
    
    if (DEBUG) NSLog(@"Connecting...");
    [self _setState: kBTConnectingState];   
	
    status = [ device openConnection: self withPageTimeout:10000 authenticationRequired: NO];
    if (DEBUG) NSLog(@"Checking...");
    if (status != kIOReturnSuccess)
    {
		if (DEBUG) NSLog(@"Connection request failed");
		[self _retryConnect];
    }
	if (DEBUG) NSLog(@"Weired : %i, status : %i...",[ device isConnected ],status);

    if ([ device isConnected ])						// Already connected
    {
		if (DEBUG) NSLog(@"Already connected 2"); 
		[self _openRFCOMM];
		return;
    }
}
-(void)disconnect
{
    if (DEBUG) NSLog(@"Disconnecting");
    shouldClose = YES;
    if ([ mRFCOMMChannel isOpen ])
    {
		[ mRFCOMMChannel closeChannel ];
    }
    if (device)
    {
		[ device closeConnection ];
    }
    
    [btNotification unregister];
    [btNotification release];
    btNotification = nil;
	
    [ self _setState: kBTIdleState ];
}
- (BOOL)isConnected
{
    return ([ self _state ] == kBTSerialReadyState);
}
-(void)_retryConnect
{
    if (DEBUG) NSLog(@"Retrying device connection in 30s");
    retryTimer = [[ NSTimer scheduledTimerWithTimeInterval:30 
													target:self
												  selector:@selector(connect:)
												  userInfo:nil
												   repeats:NO ]retain];
	/*    
		//[ self _setState: kBTConnectingState];
		
		if ([ mRFCOMMChannel isOpen ])
    {
			[ mRFCOMMChannel closeChannel ];
			mRFCOMMChannel = nil;
    }
    
    if ([device isConnected])
    {
		[ device closeConnection ];
    }
    */
}

#pragma mark Channel connection

- (void)_openRFCOMM:(NSTimer*)aTimer
{
    if (DEBUG) NSLog(@"Retrying channel connection");
    
    [retryTimer release];
    retryTimer = nil;
    
    [self _openRFCOMM];
}
- (void)_openRFCOMM
{
    IOReturn status;
    IOBluetoothSDPServiceRecord	*dialupServiceRecord;    
    BluetoothRFCOMMChannelID	rfcommChannelID;
	
    if ([mRFCOMMChannel isOpen])						// Already open
    {
		if (DEBUG) NSLog(@"Already open"); 
		return;
    }
    
    //kBluetoothSDPUUID16ServiceClassDialupNetworking
    //dialupServiceUUID = [IOBluetoothSDPUUID uuidWithBytes: kBluetoothSDPUUID16ServiceClassDialupNetworking length:16];
    dialupServiceRecord = [device getServiceRecordForUUID: [ IOBluetoothSDPUUID uuid16: kBluetoothSDPUUID16ServiceClassDialupNetworking] ];
    [dialupServiceRecord getRFCOMMChannelID:&rfcommChannelID];
    
    status = [ device openRFCOMMChannelAsync:&mRFCOMMChannel withChannelID:rfcommChannelID delegate: self ];
    if (status != kIOReturnSuccess)
    {
		mRFCOMMChannel=nil;
		[self _retryOpenRFCOMM];
    }
}

- (void)_retryOpenRFCOMM
{
    if (DEBUG) NSLog(@"Retrying channel connection in 30s");
    retryTimer = [[NSTimer scheduledTimerWithTimeInterval:30 
												   target:self
												 selector:@selector(_openRFCOMM:)
												 userInfo:nil
												  repeats:NO]retain];
}
#pragma mark -
#pragma mark Delegate stuffs

-(void)connectionComplete:(IOBluetoothDevice*)aDevice status:(IOReturn)status
{
    if (DEBUG) NSLog(@"Connection result (device)");
    
    if (status != kIOReturnSuccess)
    { [ self _retryConnect ]; return; }
    
    if (DEBUG) NSLog(@"Connection done (device)");
    
    [self _openRFCOMM];
}

- (void)rfcommChannelOpenComplete:(IOBluetoothRFCOMMChannel*)rfcommChannel status:(IOReturn)error;
{
    if (error == kIOReturnSuccess)
    {
		shouldClose=NO;
		[ mRFCOMMChannel retain ];
		if (DEBUG) NSLog(@"Connection done (channel)");
		[self _setState: kBTSerialReadyState];
		if ([self delegate ] && [[ self delegate ] respondsToSelector:@selector(btDeviceConnected:)])
			[[ self delegate ] btDeviceConnected: self ];
    }
    else
    {
		if ([self delegate ] && [[ self delegate ] respondsToSelector:@selector(btConnectionFailed:)])
			[[ self delegate ] btConnectionFailed: self ];
		[self _retryOpenRFCOMM];
		return;
    }
	
}
- (void)rfcommChannelData:(IOBluetoothRFCOMMChannel*)rfcommChannel data:(void *)dataPointer length:(size_t)dataLength;
{
    NSData *data = [[ NSData alloc ] initWithBytes: dataPointer length: dataLength ];
    NSString *string = [[[ NSString alloc ] initWithData: data encoding: NSASCIIStringEncoding ] autorelease ];
    if (DEBUG) NSLog(@"Data received : %@",string);
    if ([ string isEqual: @"\r\nOK\r\n" ])
        [ self _setState: kBTSerialReadyState ];
    else if ([ string isEqual: @"\r\nERROR\r\n" ])
        [ self _setState: kBTSerialReadyState ];  
    else if ([ string length ] >= 9 && [[ string substringWithRange: NSMakeRange(2,6) ] isEqual: @"*ECAV:" ])
    {
        /*
         > AT*ECAM=1
         OK
         > ATD+33 6 60 22 31 01;
         OK
         *ECAV: 1,1,1,,,"33660223101",145
         *ECAV: 1,2,1 // Connecting
         *ECAV: 1,3,1 //Established
         *ECAV: 1,0,1,08,016
         
         // Appel entrant
         *ECAV: 1,6,1,,,"33616381469",145
		 
		 // Appel anonyme
		 *ECAV: 1,6,1
		 
         */
		string = [string substringWithRange:NSMakeRange(0,[string length]-1)];
        NSArray *arguments = [[ string substringWithRange: NSMakeRange(8,[ string length ] - 9)] componentsSeparatedByString: @"," ];
        NSArray *keys = nil;
        
        if ([[ arguments objectAtIndex: 1 ] intValue ] == 0)
            keys = [ NSArray arrayWithObjects: @"ccid",@"ccstatus",@"caltype",@"processid",@"exitcause",nil];
        else if ([[ arguments objectAtIndex: 1 ] intValue ] == 1 || [[ arguments objectAtIndex: 1 ] intValue ] == 6)
		{
			if ([arguments count]==7)
			{
				NSMutableArray *mutableArguments = [arguments mutableCopy];
				NSString *number = [arguments objectAtIndex:5];
				if ([[arguments objectAtIndex:6] isEqual: @"145"])
				{
					number =  [NSString stringWithFormat: @"+%@",number]; 
				}
				[mutableArguments insertObject:number atIndex:6];
				arguments = [[mutableArguments copy]autorelease];
				[mutableArguments release];
				keys = [ NSArray arrayWithObjects: @"ccid",@"ccstatus",@"caltype",@"processid",@"exitcause",@"number",@"formatedNumber",@"type",nil];
			}
			else if ([arguments count]==3)
				keys = [ NSArray arrayWithObjects: @"ccid",@"ccstatus",@"caltype",nil];
		}
        else
            keys = [ NSArray arrayWithObjects: @"ccid",@"ccstatus",@"caltype",nil ];
		
		if ([self delegate ] && [[ self delegate ] respondsToSelector:@selector(btPhoneStatusChanged:)])
			[[ self delegate ] btPhoneStatusChanged: [ NSDictionary dictionaryWithObjects: arguments forKeys:keys]];
		
		[[NSNotificationCenter defaultCenter]postNotificationName:@"BTPhoneStatusChanged" object:self userInfo:[ NSDictionary dictionaryWithObjects: arguments forKeys:keys]];
		
    }
    /*    if (close)
    {
		//        [ rfcommChannel closeChannel ];
        [ mRFCOMMChannel release ];
        mRFCOMMChannel = nil;
        [ device closeConnection ];
    }
    */
}
- (void)rfcommChannelClosed:(IOBluetoothRFCOMMChannel*)rfcommChannel;
{
    if (DEBUG) NSLog(@"Channel closed");
    [commandsBuffer removeAllObjects];
    [ self _setState: kBTSerialOfflineState ];
    [ mRFCOMMChannel release ];
    mRFCOMMChannel=nil;
    if (! shouldClose)
    {
        [ self _retryOpenRFCOMM ];
    }
}

- (void)deviceConnectionClosed:(IOBluetoothUserNotification*)aNotification device:(IOBluetoothDevice*)aDevice
{
    if (DEBUG) NSLog(@"Device disconnected");
    if (! shouldClose)
    {
		if (retryTimer)
		{
			[retryTimer invalidate];
			[retryTimer release];
			retryTimer = nil;
		}
        [ self _retryConnect ];
    }
}
#pragma mark -
#pragma mark Device communication
- (void)setDevice:(NSString*)deviceID
{
    if (DEBUG) NSLog(@"Set device to : %@",deviceID);
	
    IOReturn		    status;
    BluetoothDeviceAddress  deviceAddress;
    IOBluetoothDevice       *tempDevice;
    if (! deviceID || ![ deviceID length ])
    {
		if (device)
		{
			[ self disconnect ];
			[device release];
			device=nil;
		}
		return;
    }
	
    if (![[device getAddressString ] isEqual: deviceID])
    {
		BOOL connected = [device isConnected];
		[self disconnect];
		[device release];
		
		status = IOBluetoothNSStringToDeviceAddress( deviceID, &deviceAddress );
		if (status != kIOReturnSuccess)
			[ NSException raise:@"BPDeviceAddressConversionException" format:@"Error while converting device string to device address" ];
		
		tempDevice = [ IOBluetoothDevice withAddress: &deviceAddress];
		if (! tempDevice)
			[ NSException raise:@"BPDeviceCreationException" format:@"Error while creating Bluetooth device" ];
		
		device = [ tempDevice retain ];
		
		if (connected)
			[ self connect ];
    }
}


- (void)sendString:(NSString*)aString
{
    [ self sendString: aString wait: YES ];
}
- (void)sendString:(NSString*)aString wait:(BOOL)flag;
{
    NSLog(@"sendString %@",aString);
    if (! [ mRFCOMMChannel isOpen ])
        return;
    NSLog(@"sendString %@",aString);
    
	[ commandsBuffer addObject: aString ];
    [ self _flushBuffer ];
}

#pragma mark -
#pragma mark Private stuffs

- (void)_sendData:(void*)buffer length:(UInt32)length ;
{
    if ( mRFCOMMChannel != nil )
    {
        UInt32				numBytesRemaining;
        IOReturn			result;
        BluetoothRFCOMMMTU	rfcommChannelMTU;
        
        numBytesRemaining = length;
        result = kIOReturnSuccess;
        
        // Get the RFCOMM Channel's MTU.  Each write can only contain up to the MTU size
        // number of bytes.
        rfcommChannelMTU = [mRFCOMMChannel getMTU];
        
        // Loop through the data until we have no more to send.
        while ( ( result == kIOReturnSuccess ) && ( numBytesRemaining > 0 ) )
        {
            // finds how many bytes I can send:
            UInt32 numBytesToSend = ( ( numBytesRemaining > rfcommChannelMTU ) ? rfcommChannelMTU :  numBytesRemaining );
            
            // This method won't return until the buffer has been passed to the Bluetooth hardware to be sent to the remote device.
            // Alternatively, the asynchronous version of this method could be used which would queue up the buffer and return immediately.
            result = [mRFCOMMChannel writeSync:buffer length:numBytesToSend];
            
            // Updates the position in the buffer:
            numBytesRemaining -= numBytesToSend;
            buffer += numBytesToSend;
        }
        
        // We are successful only if all the data was sent:
        /*
		 if ( ( numBytesRemaining == 0 ) && ( result == kIOReturnSuccess ) )
		 {
			 return TRUE;
		 }
         */
    }
    
    // return FALSE;
}

-(void)_flushBuffer;
{
    if ([ self _state ] == kBTSerialReadyState && [ commandsBuffer count ])
    {
		NSString *string = [ commandsBuffer objectAtIndex: 0 ];
		[ self _setState : kBTSerialWaitingState ];
		if (DEBUG) NSLog(@"sending : %@",string);
		[ self _sendData: (void*)[ string lossyCString ] length: [ string length ]];
		[ commandsBuffer removeObjectAtIndex: 0 ];
    }
}
- (void)_setState:(int)aState
{
    state = aState;
    if ( state == kBTSerialReadyState)
		[ self _flushBuffer ];
}
- (int)_state
{
    return state;
}
- (void)dealloc
{
    [stateTimer invalidate];
    [stateTimer release];
    [retryTimer invalidate];
    [retryTimer release];
    [ self disconnect ];
    [ commandsBuffer release ];
    [ super dealloc ];
}
@end
