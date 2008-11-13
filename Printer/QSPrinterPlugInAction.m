//
//  QSPrinterPlugInAction.m
//  QSPrinterPlugIn
//
//  Created by Nicholas Jitkoff on 6/27/05.
//  Copyright __MyCompanyName__ 2005. All rights reserved.
//

#import "QSPrinterPlugInAction.h"
#import <Carbon/Carbon.h>
#include <ApplicationServices/ApplicationServices.h>

@implementation QSPrinterPlugInAction


#define kQSPrinterPlugInAction @"QSPrinterPlugInAction"
- (void)printString:(NSString *)string{
	
	   NSPrintOperation    *printOperation;
	   
	   // This will scale the view to fit the page without centering it.
	   // It would be better to specify these default settings when
	   // the document is created instead of in the print method.
	NSPrintInfo *printInfo=[NSPrintInfo sharedPrintInfo];
		  NSData *data=[[NSUserDefaults standardUserDefaults]dataForKey:@"QSPrinterDefaultSettings"];
		  if (data)
			  printInfo=[NSKeyedUnarchiver unarchiveObjectWithData:data];
		  
		  
		  [printInfo setHorizontalPagination:NSFitPagination];
		  [printInfo setHorizontallyCentered:NO];
		  [printInfo setVerticallyCentered:YES];
		  
		  NSRect imageableBounds = [printInfo imageablePageBounds];
		  NSSize paperSize = [printInfo paperSize];
		  if (NSWidth(imageableBounds) > paperSize.width) {
			  imageableBounds.origin.x = 0;
			  imageableBounds.size.width = paperSize.width;
		  }
		  if (NSHeight(imageableBounds) > paperSize.height) {
			  imageableBounds.origin.y = 0;
			  imageableBounds.size.height = paperSize.height;
		  }
		  
		  [printInfo setBottomMargin:NSMinY(imageableBounds)];
		  [printInfo setTopMargin:paperSize.height - NSMinY(imageableBounds) - NSHeight(imageableBounds)];
		  [printInfo setLeftMargin:NSMinX(imageableBounds)];
		  [printInfo setRightMargin:paperSize.width - NSMinX(imageableBounds) - NSWidth(imageableBounds)];
		  
		  
		  
		  
		  // Setup the print operation with the print info and view
		  printOperation = [NSPrintOperation printOperationWithView:[self printableViewForString:string printInfo:printInfo] printInfo:printInfo];
		  [NSApp activateIgnoringOtherApps:YES];
		  
		  [printOperation	setShowPanels:NO];
		  if (mOptionKeyIsDown){
			  // [NSApp runPageLayout:nil];
			  // [printOperation	setShowPanels:YES];
			  [[printOperation printInfo] setJobDisposition:NSPrintPreviewJob];
		  }else{
		  }
		  [printOperation runOperation];
		  return nil;
		  
}
- (QSObject *)print:(QSObject *)dObject{
	NSArray *files=[dObject validPaths];
	if (files){
		[self printFiles:files toPrinter:nil];
	}else{
		NSString *string=[dObject stringValue];
		[self printString:string];
	}
	return nil;
}

- (void)printFiles:(NSArray *)files toPrinter:(id)printer{
	NSWorkspace *w=[NSWorkspace sharedWorkspace];
	NSArray *urls=[NSURL performSelector:@selector(fileURLWithPath:) onObjectsInArray:files returnValues:YES];
	
	//	LSLaunchURLSpec launchSpec;
	//	launchSpec.appURL = NULL;
	//	launchSpec.itemURLs = NULL;
	//	launchSpec.passThruParams = NULL;
	//	launchSpec.launchFlags = kLSLaunchAndPrint;
	//	launchSpec.asyncRefCon = NULL;
	//	
	//	OSErr err = LSOpenFromURLSpec(&launchSpec, NULL);
	
	NSAppleEventDescriptor  *appleEvent = [NSAppleEventDescriptor appleEventWithEventClass: kCoreEventClass
																				   eventID: kAEPrintDocuments
																		  targetDescriptor: NULL
																				  returnID: kAutoGenerateReturnID
																		     transactionID: kAnyTransactionID];
	Boolean b=NO;
	NSAppleEventDescriptor *extras=[NSAppleEventDescriptor listDescriptor];
	[extras setParamDescriptor:[NSAppleEventDescriptor descriptorWithBoolean:YES] forKeyword:'pdlg'];
	
	[w openURLs:urls withAppBundleIdentifier:nil 
		options:NSWorkspaceLaunchAndPrint
additionalEventParamDescriptor:extras
  launchIdentifiers:nil];
}



- (NSView *)printableViewForString:(NSString *)string printInfo:(NSPrintInfo *)printInfo
{
    NSTextView    *printView;
    NSDictionary    *titleAttr;
	
    // CREATE THE PRINT VIEW
    // 480 pixels wide seems like a good width for printing text
	printView = [[[NSTextView alloc] initWithFrame:[printInfo imageablePageBounds]] autorelease];
	[printView setVerticallyResizable:YES];
    [printView setHorizontallyResizable:NO];
	
    // ADD THE TEXT
    // This assumes there is an NSTextField called titleField
    // and an NSTextView called mainTextView
	
    [[printView textStorage] beginEditing];
	
	NSFont *font=[NSFont boldSystemFontOfSize:9];
	NSData *data=[[NSUserDefaults standardUserDefaults]dataForKey:@"QSPrinterDefaultFont"];
	if (data)
		font=[[NSKeyedUnarchiver unarchiveObjectWithData:data]retain];
	
    // Set the attributes for the title
    titleAttr = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
	
    // Add the title
    [[printView textStorage] appendAttributedString:[[[NSAttributedString alloc]
        initWithString:string attributes:titleAttr] autorelease]];
	
    // Create a couple returns between the title and the body
    //[[printView textStorage] appendAttributedString:[[[NSAttributedString alloc] initWithString:@"\n\n"] autorelease]];
	
    // Add the body text
    //[[printView textStorage] appendAttributedString:[mainTextView textStorage]];
	
    // Center the title
    //[printView setAlignment:NSCenterTextAlignment range:NSMakeRange(0, [[titleField stringValue] length])];
	
    [[printView textStorage] endEditing];
	
    // Resize the print view to fit the added text
    // (Is this done automatically?)
    [printView sizeToFit];
	
    return printView;
}
@end
