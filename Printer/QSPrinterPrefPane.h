//
//  QSPrinterPrefPane.h
//  QSPrinterPlugIn
//
//  Created by Nicholas Jitkoff on 6/27/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <QSInterface/QSPreferencePane.h>

@interface QSPrinterPrefPane : QSPreferencePane {
	NSPrintInfo *info;
	NSFont *font;
}
- (IBAction)setPrintPreviewOptions:(id)sender;
- (IBAction)setPrintOptions:(id)sender;
- (IBAction)setFontOptions:(id)sender;
- (NSPrintInfo *)info;
- (void)setInfo:(NSPrintInfo *)value;
- (NSFont *)font;
- (void)setFont:(NSFont *)value;


@end
