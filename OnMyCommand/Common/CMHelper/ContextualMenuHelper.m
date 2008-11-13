/* ContextualMenuHelper.m
   By Jayson Adams
   Copyright (c) 2003 Circus Ponies Software, Inc.  All Rights Reserved.


   IMPORTANT:  This Circus Ponies software is supplied to you by Circus Ponies Software, Inc. ("Circus Ponies") in consideration
   of your agreement to the following terms, and your use, installation, modification or redistribution of this Circus Ponies
   software constitutes acceptance of these terms.  If you do not agree with these terms, do not use, install, modify or
   redistribute this Circus Ponies software.
 
   In consideration of your agreement to abide by the following terms, and subject to these terms, Circus Ponies grants you a
   personal, non-exclusive license under Circus Ponies’ copyrights in this original Circus Ponies software (the "Circus Ponies
   Software"), to use, reproduce, modify and redistribute the Circus Ponies Software, with or without modifications, in source
   and/or binary forms; provided that if you redistribute the Circus Ponies Software in whole or in part, you must retain this
   notice and the following text and disclaimers in all such redistributions of the Circus Ponies Software.  Neither the name,
   trademarks, service marks or logos of Circus Ponies may be used to endorse or promote products derived from the Circus Ponies
   Software without specific prior written permission from Circus Ponies.  Except as expressly stated in this notice, no other
   rights or licenses, express or implied, are granted by Circus Ponies herein, including but not limited to any patent rights
   that may be infringed by your derivative works or by other works in which the Circus Ponies Software may be incorporated.
 
   The Circus Ponies Software is provided by Circus Ponies on an "AS IS" basis.  CIRCUS PONIES MAKES NO WARRANTIES, EXPRESS OR
   IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
   PURPOSE, REGARDING THE CIRCUS PONIES SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
   IN NO EVENT SHALL CIRCUS PONIES BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY
   WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE CIRCUS PONIES SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER
   THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE EVEN IF CIRCUS PONIES HAS BEEN ADVISED OF THE
   POSSIBILITY OF SUCH DAMAGE.


   This class presents a set of functions that help you send the current selection in an application hosting a CM plug-in to a
   Service, as well as get the current text selection from a host Cocoa app.  The important functions are:
   
        hostIsMyApp();
        performServiceWithCurrentCarbonSelection();
        cocoaAppHasSelection();
        performServiceWithCurrentCocoaSelection();
	cocoaAppHasStringSelection();
	currentCocoaStringSelection();
        
   Just include the ContextualMenuHelper.[hm] files in your project (easy with Project Builder - I'm not sure what's required for
   CW), include the ContextualMenuHelperExterns.h file in your contextual menu source code, and you're ready to call them.
   
   There doesn't appear to be a way to ask if the host app is Carbon or Cocoa.  Here's a code snippet that pretty much just guesses
   which performService... function to call based on the plug-in's ability to get the text selection from the Apple Event:
   
        CFStringRef	textRef = nil;
        
        ...
        
        if (inContext != NULL) {
            textRef = createCFStringFromAEDesc(*inContext);
        }
        
        if (textRef != nil) {
            performServiceWithCurrentCarbonSelection(textRef);
        } else {
            performServiceWithCurrentCocoaSelection();
        }

 */
 
 
#import "ContextualMenuHelper.h"
#import "ContextualMenuHelperExterns.h"


@protocol MyAppServicesProtocol

- (void)copySelectionFromPasteboard:(NSPasteboard *)aPasteboard error:(NSString **)error;

@end


@implementation ContextualMenuHelper


/* Returns an array of send types that the Service we're going to work with accepts.  Note that when you go to change
 * this array, or to work with raw Services type information as declared by applications, you must work with the
 * types, not the types as strings.  In other words, when invoking the validRequestor... method, you must pass
 *
 *		NSRTFPboardType
 *
 * and not
 *
 *		@"NSRTFPboardType"
 *
 * The latter will cause the search to fail.  The strings that the type objects represent are not (necessarily) the same
 * as their names.
 */
+ (NSArray *)serviceSendTypes
{
    return [NSArray arrayWithObjects:NSRTFDPboardType, NSRTFPboardType, NSPostScriptPboardType, NSTIFFPboardType,
                                     NSPICTPboardType, NSTabularTextPboardType, NSFileContentsPboardType,
                                     NSFilenamesPboardType, NSStringPboardType, nil];
}

/* Returns 1 if the "host app" (within which the CM plug-in is running) is a Carbon application.  Carbon apps don't have
 * an NSApplication object.
 */
int hostIsACarbonApp()
{
    return (NSApp == nil ? 1 : 0);
}

/* Returns 1 if the "host app" (within which the CM plug-in is running) is a Cocoa application.
*/
int isHostACocoaApp()
{
	return (NSApp != nil) ? YES : NO;
}

/* Returns 1 if the "host app" (within which the CM plug-in is running) is the "MyApp" application.  If you're writing a 
 * plug-in to go along with an application you've written, you may not want the plug-in's menu items to show up when the
 * user brings up the contextual menu within your application.  So before you build your contextual menu items you can
 * call this function to verify that the host app isn't your app.
 */
int hostIsMyApp()
{
    return ([[[NSProcessInfo processInfo] processName] isEqualToString:@"MyApp"]);
}

/* Returns a "proxy" for an object in the target app that will respond to our pseudo-Service request. */
static id _targetAppServicesProxy()
{
    id		targetAppProxy;
    float	totalWaitTime;
    
    /* get the proxy */
    targetAppProxy = [NSConnection rootProxyForConnectionWithRegisteredName:@"MyAppServicesPort" host:nil];
    
    /* no problem getting it, so return it */
    if (targetAppProxy != nil) {
        return targetAppProxy;
    }
    
    /* we assume the proxy request failed because the target app isn't running - ask the Finder to launch it */
    if (![[NSWorkspace sharedWorkspace] launchApplication:@"MyApp" showIcon:YES autolaunch:YES]) {
        NSLog(@"Could't launch the MyApp application.");
        
        return nil;
    }
    
    totalWaitTime = 0.0;
    
    /* now we sit in a loop where we wait a little bit and then ask for a connection; it can take time for the Finder to launch
     * the app, so if we were to immediately ask for a connection it might fail
     */
    do {
        /* wait a little bit */
        [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
        
        totalWaitTime += 1.0;
        
        /* try to acquire a connection; we will give up after 20 seconds/tries */
        targetAppProxy = [NSConnection rootProxyForConnectionWithRegisteredName:@"MyAppServicesPort" host:nil];
    } while (targetAppProxy == nil && totalWaitTime < 20.0);
    
    /* failure */
    if (totalWaitTime >= 20.0) {
        NSLog(@"MyApp launch time exceeded maximum wait time.");
    }
    
    return targetAppProxy;
}

/* Takes the current selected text as retrieved from the Apple Events/Contextual Menu subsystem and sends it to a Service.  You must
 * know the Service's "name" and send/return types in order to call it.  You must also have the name of the port that the target app
 * is using to listen for Services requests.  This may be as simple as the application's name (I don't know).  If you wrote the 
 * target application, you can create a port, register it under some name, and reference that name here.
 *
 * Note that really what you'd want to do is call NSPerformService(), as in the Cocoa case below, but for some reason this creates
 * problems in the host Carbon app.  Specifically, I discovered that the Hide menu command no longer hid the app after invoking this
 * funtion.  The host app would deactivate but not hide.
 *
 * Also note that a CFStringRef is the same as an NSString.
 */
void performServiceWithCurrentCarbonSelection(CFStringRef selectionString)
{
    id				targetAppProxy;
    NSPasteboard		*servicePasteboard;
    NSString			*errorString = nil;
    NSAutoreleasePool		*tmpPool;
    
	NSString *carbonSelectionString = (NSString *)selectionString;
	
    /* create a temporary autorelease pool */
    tmpPool = [[NSAutoreleasePool alloc] init];

    /* create a temporary pasteboard to hold the services data */
    servicePasteboard = [NSPasteboard pasteboardWithUniqueName];
    
    /* declare the string type and place it on the pasteboard */
    [servicePasteboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
    [servicePasteboard setString:carbonSelectionString forType:NSStringPboardType];
    
    /* get a "proxy" for the object in the target app that's listening for Services requests;  a proxy is an object that looks like
     * the object in the target app - you can send it messages as if its remote object were in your address space;  by telling the
     * proxy object (which sits on our side of the connection) the methods the remote object understands, our proxy doesn't have to
     * first ask the other side if it understands the message it's about to forward on to it, which will make the communcation 
     * process go faster
     */
    targetAppProxy = _targetAppServicesProxy();
    [targetAppProxy setProtocolForProxy:@protocol(MyAppServicesProtocol)];

    /* send the message - we, of course, have to know the right message to send to the proxy;  if the target app is our own, no 
     * problem;  if it was written by someone else, it'll take a little work to figure out (but not much);  note: the target app has 
     * to be careful with what it does within this method; for example, if it becomes the active app for some reason (deactivating 
     * the host app in the process), the host carbon app will get screwed up;  if you have control over the message it might make 
     * more sense for this message to be "oneway" (i.e. returns void and doesn't round-trip with an error string)
     */
    [targetAppProxy copySelectionFromPasteboard:servicePasteboard error:&errorString];
    
    /* print out any error reported from the other side */
    if (errorString != nil) {
        NSLog(@"Error invoking service: %@", errorString);
    }
    
    /* clean up */
    [tmpPool release];
}

/* Returns YES if the host Cocoa app has a selection.  Uses the host app's support of the Services subsystem to locate a selection
 * acceptible to the Service.
 */
int cocoaAppHasSelection()
{
    id			firstResponder, validRequestor = nil;
    NSArray		*sendTypes;
    int			i, count;

	if (NSApp == nil) {
		return NO;
	}
       
    /* get the service's send types */
    sendTypes = [ContextualMenuHelper serviceSendTypes];
    
    /* get the key window's first responder */
    firstResponder = [[[NSApplication sharedApplication] keyWindow] firstResponder];
    
    /* now ask it for an object that can supply one of the types the service wants */
    count = [sendTypes count];
    for (i = 0; i < count; i++) {
        validRequestor = [firstResponder validRequestorForSendType:(NSString *)[sendTypes objectAtIndex:i] returnType:nil];
        
        /* we found one */
        if (validRequestor != nil) {
            break;
        }
    }
    
    /* return the results of our search */
    return (validRequestor != nil) ? YES : NO;
}

/* Takes the current selection from the Cocoa key window and sends it to a Service.  This function relies upon the host app's support 
 * of the Services subsystem, and retrieves the current selection by emulating that subsystem.  You must know the Services's "name"
 * and send/return types in order to invoke it.
 */
void performServiceWithCurrentCocoaSelection()
{
    id				firstResponder, validRequestor = nil;
    NSPasteboard		*servicePasteboard;
    NSArray			*sendTypes;
    NSString			*availableType = nil;
    int				i, count;

	if (NSApp == nil) {
		return;
	}

    /* get the key window's first responder */
    firstResponder = [[[NSApplication sharedApplication] keyWindow] firstResponder];

    /* now ask it for an object that can supply one of the types the service wants */
    sendTypes = [ContextualMenuHelper serviceSendTypes];
    count = [sendTypes count];
    for (i = 0, availableType = nil; i < count; i++) {
        validRequestor = [firstResponder validRequestorForSendType:(NSString *)[sendTypes objectAtIndex:i] returnType:nil];
        
        /* if the first responder returns an object that can supply the type, we're done searching */
        if (validRequestor != nil) {
            availableType = (NSString *)[sendTypes objectAtIndex:i];
            break;
        }
    }
    
    if (validRequestor != nil) {
        /* get a temporary pasteboard to hold the data */
        servicePasteboard = [NSPasteboard pasteboardWithUniqueName];
    
        /* get the selection supplier to load the pasteboard with the selection */
        [validRequestor writeSelectionToPasteboard:servicePasteboard types:[NSArray arrayWithObject:availableType]];
        
        /* perform the service - see the documentation for NSPerformService() for more information */
        NSPerformService(@"MyApp/Store Current Selection", servicePasteboard);
    } else {
        /* there's no object in the responder chain that can supply any of the requested types;  this should never happen (presumably
         * we called cocoaAppHasSelection() first)
         */
        NSBeep();
    } 
}

/* Returns YES if the host Cocoa app has a selection and it can be represented as an NSString/CFStringRef.  Uses the host app's support 
 * of the Services subsystem to locate the NSString/CFStringRef selection.
 */
int cocoaAppHasStringSelection()
{
    id			firstResponder, validRequestor;

	if (NSApp == nil) {
		return NO;
	}

    /* get the key window's first responder */
    firstResponder = [[[NSApplication sharedApplication] keyWindow] firstResponder];
    
    /* now ask it for an object that can supply the current selection (if any) as an NSString */
    validRequestor = [firstResponder validRequestorForSendType:NSStringPboardType returnType:nil];
        
    /* return the results of our search */
    return (validRequestor != nil) ? YES : NO;
}

/* Returns the current selection from the Cocoa key window as an NSString/CFStringRef.  This function returns nil if the Cocoa app does
 * not have a selection or the selection cannot be represented as an NSString/CFStringRef.  You must call CFRelease() when you're finished
 * with the selection string.
 */
CFStringRef currentCocoaStringSelection()
{
    id			firstResponder, validRequestor = nil;
    NSPasteboard	*tmpPasteboard;
    NSString		*selectionString;

	if (NSApp == nil) {
		return nil;
	}
    
    /* get the key window's first responder */
    firstResponder = [[[NSApplication sharedApplication] keyWindow] firstResponder];
    
    /* now ask it for an object that can supply the current selection (if any) as an NSString */
    validRequestor = [firstResponder validRequestorForSendType:NSStringPboardType returnType:nil];
    
    /* no selection, or the current selection cannot be represented as a string */
    if (validRequestor == nil) {
        return nil;
    }
    
    /* get a temporary pasteboard to hold the data */
    tmpPasteboard = [NSPasteboard pasteboardWithUniqueName];

    /* get the selection supplier to load the pasteboard with the selection */
    [validRequestor writeSelectionToPasteboard:tmpPasteboard types:[NSArray arrayWithObject:NSStringPboardType]];

    /* retrieve the selection from the pasteboard and retain it (otherwise it'll get freed when the tmp autorelease pool goes away; the
     * caller must free it with CFRelease() when finished
     */
    selectionString = [[tmpPasteboard stringForType:NSStringPboardType] retain];
        
    /* return the selection */
    return (CFStringRef)selectionString;
}


@end
