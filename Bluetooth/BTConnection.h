//
//  BTConnection.h
//  BuddyPop
//
//  Created by Yann Bizeul on Fri May 07 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <IOBluetooth/Bluetooth.h>
#import <IOBluetooth/objc/IOBluetoothDevice.h>
#import <IOBluetooth/IOBluetoothUtilities.h>
#import <IOBluetooth/objc/IOBluetoothSDPServiceRecord.h>
#import <IOBluetooth/objc/IOBluetoothRFCOMMChannel.h>
#import <IOBluetooth/objc/IOBluetoothSDPUUID.h>

#import <AddressBook/AddressBook.h>
//#import "AddressBookAdditions.h"

// State constants
#define kBTSerialReadyState 1
#define kBTSerialWaitingState 2
#define kBTSerialOfflineState 10
#define kBTIdleState 100
#define kBTConnectingState 101

#define kBPSEStatusIdle 0
#define kBPSEStatusCalling 1
#define kBPSEStatusConnecting 2
#define kBPSEStatusActive 3
#define kBPSEStatusHold 4
#define kBPSEStatusWaiting 5
#define kBPSEStatusAlerting 6
#define kBPSEStatusBudy 7

#define kBPSECallTypeVoice 1
#define kBPSECallTypeData 2
#define kBPSECallTypeFax 4
#define kBPSECallTypeVoice32 128

#define kBPSEProcessIDCC 8
#define kBPSEProcessIDMM 68
#define kBPSEProcessIDMS 69

typedef enum {
    BTNotAvailable = 0x0,
    BTAvailable = 0x1
} BTDeviceState;

@protocol BTConnectionDelegate
- (void)btDeviceConnected:(id)aConnection;
- (void)btConnectionFailed:(id)aConnection;
- (void)btPhoneStatusChanged:(NSDictionary*)aDictionary;

- (BOOL)respondsToSelector:(SEL)aSelector;
@end

@interface BTConnection : NSObject {
    id				delegate;
    
    NSTimer			*stateTimer;
    NSTimer			*retryTimer;
    BTDeviceState		previousState;
    IOBluetoothDevice           *device;
    IOBluetoothRFCOMMChannel	*mRFCOMMChannel;
    IOBluetoothUserNotification *btNotification;
    
    BOOL			shouldClose;
    BOOL			state;
    
//    BOOL			DEBUG;
    
    NSMutableArray		*commandsBuffer;
    
    BOOL reconnectAfterWakeUp;
}
+ (id)sharedConnection;
+ (NSArray*)devicesWithService:(BluetoothClassOfDevice)service;
+ (IOBluetoothDevice*)pairedDeviceWithName:(NSString*)aName;
- (void)setDelegate:(id)anObject;

- (NSString*)name;
+ (BOOL)bluetoothAvailable;
- (void)connect;
- (void)disconnect;
- (BOOL)isConnected;

- (void)_openRFCOMM;
- (void)_retryOpenRFCOMM;

- (void)setDevice:(NSString*)deviceID;
- (id<BTConnectionDelegate>)delegate;
- (void)sendString:(NSString*)aString;
- (void)sendString:(NSString*)aString wait:(BOOL)flag;
@end