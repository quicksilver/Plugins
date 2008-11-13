#import "QSNetworkBrowser.h"
#import "QSController.h"
#import "QSInterfaceController.h"
#import "QSObject.h"
#import "QSSearchObjectView.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <unistd.h>



#import "QSLibrarian.h"
#import "QSResourceManager.h"
#import "QSRegistry.h"

#define kQSMachineSendAction @"QSMachineSendAction"



@implementation QSMachineSource

- (id) init{
    if (self=[super init]){
       // NSLog(@"init");
        browser = [[NSNetServiceBrowser alloc] init];
        services = [[NSMutableArray array] retain];
        resolvedServices = [[NSMutableArray array] retain];
        [browser setDelegate:self];
        
        // Passing in "" for the domain causes us to browse in the default browse domain, 
        // which currently will always be the ".local" domain.  The service type should be registered
        // with IANA, and it should be listed at <http://www.iana.org/assignments/port-numbers>.  Our
        // service type "wwdcpic" isn't listed because this is just sample code.
        [browser searchForServicesOfType:@"_quicksilver._tcp." inDomain:@""];
        //    [ipAddressField setStringValue:@""];
        //    [portField setStringValue:@""];
    }
    return self;
}


- (NSImage *) iconForEntry:(NSDictionary *)dict{
    return [QSResourceManager imageNamed:@"rendezvousIcon"];
}

- (NSArray *) objectsForEntry:(NSDictionary *)theEntry{
    
    // NSLog(@"obkects");
    if (!fDEV) return nil;
    NSMutableArray *objects=[NSMutableArray arrayWithCapacity:1];
    QSObject *newObject;
    NSNetService *service;
    NSEnumerator *serviceEnumerator=[services objectEnumerator];
    while(service=[serviceEnumerator nextObject]){
        
        newObject=[QSObject objectWithName:[service name]];
        
      //  [newObject setObject:key forKey:QSNetworkLocationPasteboardType];
      //  [newObject setPrimaryType:QSNetworkLocationPasteboardType];
        
        [objects addObject:newObject];
    }
    return objects;
}



// This object is the delegate of its NSNetServiceBrowser object. We're only interested in services-related methods,
// so that's what we'll call.
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    [services addObject:aNetService];
    NSLog(@"Discovered service %@",aNetService);
  // aNetService  name
    [aNetService setDelegate:self];
  // [aNetService resolve];

    if(!moreComing)
        [super invalidateSelf];
}


- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    // This case is slightly more complicated. We need to find the object in the list and remove it.
    int removed=[services indexOfObject:aNetService];
    
  [aNetService stop];
  
 // [resolvedServices removeObjectAtIndex:removed];
  [services removeObjectAtIndex:removed];
    
    if(!moreComing)
        [super invalidateSelf];
}



- (void)netServiceDidResolveAddress:(NSNetService *)sender {
    NSLog(@"Resolved Address: %@",sender);
    if ([[sender addresses] count] > 0) {
       // NSData * address;
        //struct sockaddr * socketAddress=nil;
       // NSString * ipAddressString = nil;
        //NSString * portString = nil;
        //int socketToRemoteServer;
        //char buffer[256];
        //int index;
        
        
        /*
        // Iterate through addresses until we find an IPv4 address
        for (index = 0; index < [[sender addresses] count]; index++) {
            address = [[sender addresses] objectAtIndex:index];
            socketAddress = (struct sockaddr *)[address bytes];
            if (socketAddress->sa_family == AF_INET)
                break;
        }
        
        // Be sure to include <netinet/in.h> and <arpa/inet.h> or else you'll get compile errors.
        
        if (socketAddress) {
            switch(socketAddress->sa_family) {
                case AF_INET:
                    if (inet_ntop(AF_INET, &((struct sockaddr_in *)socketAddress)->sin_addr, buffer, sizeof(buffer))) {
                        ipAddressString = [NSString stringWithCString:buffer];
                        portString = [NSString stringWithFormat:@"%d", ntohs(((struct sockaddr_in *)socketAddress)->sin_port)];
                    }
                    // Cancel the resolve now that we have an IPv4 address.
                    [sender stop];
                    [sender release];
                    serviceBeingResolved = nil;
                    
                    break;
                case AF_INET6:
                    // PictureSharing server doesn't support IPv6
                    return;
            }
        }   
        
        if (ipAddressString && portString)
            NSLog(@"Connected to: %@:%@",ipAddressString,portString);
        
        socketToRemoteServer = socket(AF_INET, SOCK_STREAM, 0);
        if(socketToRemoteServer > 0) {
            NSLog(@"Socket %d",socketToRemoteServer);
            NSFileHandle * remoteConnection = [[NSFileHandle alloc] initWithFileDescriptor:socketToRemoteServer closeOnDealloc:YES];
            if(remoteConnection) {
                
                //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readAllTheData:) name:NSFileHandleReadToEndOfFileCompletionNotification object:remoteConnection];
                if(connect(socketToRemoteServer, (struct sockaddr *)socketAddress, sizeof(*socketAddress)) == 0) {
                    QSObject *object=[[[(QSController *)[NSApp delegate]interfaceController]dSelector]objectValue];
                    NSData * representationToSend = [NSArchiver archivedDataWithRootObject:object];
                    NSLog(@"Send Data:\r%@",representationToSend);
                    [remoteConnection writeData:representationToSend];
                    [remoteConnection closeFile];
                    [remoteConnection release];
                }
            } else {
                close(socketToRemoteServer);
            }
        }
          */
    }
        
}





- (NSArray *) types{
    return [NSArray arrayWithObject:QSMachinePasteboardType];
}
- (NSArray *) actions{
    QSAction *action=[QSAction actionWithIdentifier:kQSMachineSendAction];
    [action setIcon:[QSResourceManager imageNamed:@"GenericNetworkIcon"]];
    [action setProvider:self];
    [action setAction:@selector(sendObject:toMachine:)];
    [action setArgumentCount:2];
    return [NSArray arrayWithObject:action];
}

- (NSArray *)validActionsForDirectObject:(QSObject *)dObject indirectObject:(QSObject *)iObject{
    return [NSArray arrayWithObject:kQSMachineSendAction];
}

- (QSObject *) sendObject:(QSObject *)dObject toMachine:(QSObject *)iObject{    
    return nil;
}





// Object Handler Methods

- (BOOL)loadIconForObject:(QSObject *)object{
    [object setIcon:[QSResourceManager imageNamed:@"rendezvousIcon"]];
    return YES;
}

@end






