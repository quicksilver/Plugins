//
//  QSPrinterPrefPane.m
//  QSPrinterPlugIn
//
//  Created by Nicholas Jitkoff on 6/27/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "QSPrinterPrefPane.h"
#import <QSInterface/QSBackgroundView.h>


@implementation QSPrinterPrefPane
- (IBAction)setPrintPreviewOptions:(id)sender;
{
	NSPageLayout *pageLayout=[NSPageLayout pageLayout];
	//[pageLayout setPrintInfo:[NSPrintInfo sharedPrintInfo]];

	NSPrintInfo *info=[[[self info]copy] autorelease];
//	NSLog(@"info %@",info);
	[pageLayout runModalWithPrintInfo:info];
//	[pageLayout beginSheetWithPrintInfo:nil modalForWindow: delegate:(id)delegate didEndSelector:(SEL)didEndSelector contextInfo:(void *)contextInfo;
//	NSLog(@"info %@ %@",info,[pageLayout printInfo]);
	[self setInfo:info];

}
- (IBAction)setPrintOptions:(id)sender;
{
	//	NSPrintInfo *info=[[copy] autorelease];
	NSPrintOperation *printOperation=[NSPrintOperation printOperationWithView:nil printInfo:[self info]];
	[[printOperation printInfo] setJobDisposition:NSPrintSaveJob];
//	[NSPrintOperation setCurrentOperation:printOperation];
//	NSPanel *printPanel=[NSPrintPanel printPanel];
//	NSView *content=[printPanel contentView];
//	// NSLog(@"sub %@",[content subviews]);
//	if  (![content isKindOfClass:[QSBackgroundView class]]){
//		NSView *newBackground=[[[QSBackgroundView alloc]init]autorelease];
//		[printPanel setContentView:newBackground];
//		[newBackground addSubview:content];
//	}
	
	[printOperation runOperation];

		   

	[self setInfo:[printOperation printInfo]];
	//[printOpereration cancel];
}

- (IBAction)setFontOptions:(id)sender;
{
	NSFontManager *fontManager=[NSFontManager sharedFontManager];	

	[[fontManager fontPanel:YES]orderFront:nil];
	//	[fontManager setDelegate:self];
	[[sender window]makeFirstResponder:sender];
	NSLog(@"res %@",[[ _mainView window]firstResponder]);
}

-(void)changeFont:(id)sender 
{
    NSFont *oldFont = [self font]; 
    NSFont *newFont = [sender convertFont:oldFont]; 
    [self setFont:newFont]; 
	NSLog(@"font: %@",newFont);
    return; 
}

- (NSPrintInfo *)info {
	if (!info){
		NSData *data=[[NSUserDefaults standardUserDefaults]dataForKey:@"QSPrinterDefaultSettings"];
		if (data)
			info=[[NSKeyedUnarchiver unarchiveObjectWithData:data]retain];
	}
	if (!info) return [NSPrintInfo sharedPrintInfo];
    return [[info retain] autorelease];
}

- (void)setInfo:(NSPrintInfo *)value {
		NSLog(@"info %@",value);
    if (info != value) {
        [info release];
        info = [value copy];

		[[NSUserDefaults standardUserDefaults]setObject:[NSKeyedArchiver archivedDataWithRootObject:info] forKey:@"QSPrinterDefaultSettings"];
		[[NSUserDefaults standardUserDefaults]synchronize];
    }	
}

- (NSFont *)font {
	if (!font){
		NSData *data=[[NSUserDefaults standardUserDefaults]dataForKey:@"QSPrinterDefaultFont"];
		if (data)
			font=[[NSKeyedUnarchiver unarchiveObjectWithData:data]retain];
	}
//	NSLog(@"font %@",font);
	if (!font) return [NSFont systemFontOfSize:[NSFont systemFontSize]];
    return [[font retain] autorelease];
}

- (void)setFont:(NSFont *)value {
    if (font != value) {
        [font release];
        font = [value copy];
		[[NSUserDefaults standardUserDefaults]setObject:[NSKeyedArchiver archivedDataWithRootObject:font] forKey:@"QSPrinterDefaultFont"];
		[[NSUserDefaults standardUserDefaults]synchronize];

    }
}



@end
