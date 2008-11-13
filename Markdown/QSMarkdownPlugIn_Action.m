//
//  QSMarkdownPlugIn_Action.m
//  QSMarkdownPlugIn
//
//  Created by Nicholas Jitkoff on 1/6/05.
//  Copyright __MyCompanyName__ 2005. All rights reserved.
//

#import "QSMarkdownPlugIn_Action.h"

NSString *QSConvertMarkdownToHTML(NSString *markdown){
	NSTask *task=[[[NSTask alloc]init]autorelease];
	NSString *execPath=[[NSBundle bundleForClass:[QSMarkdownPlugIn_Action class]]pathForResource:@"Markdown" ofType:@"pl"];
	[task setLaunchPath:execPath];
	[task setArguments:[NSArray array]];
	[task setStandardInput:[NSPipe pipe]];
	[task setStandardOutput:[NSPipe pipe]];
	[task launch];
	
	[[[task standardInput]fileHandleForWriting] writeData:[markdown dataUsingEncoding:NSUTF8StringEncoding]];
	[[[task standardInput]fileHandleForWriting] closeFile];
[task waitUntilExit];
	
	NSString *string=[[[NSString alloc] initWithData:[[[task standardOutput]fileHandleForReading] readDataToEndOfFile] encoding:NSUTF8StringEncoding]autorelease];
	return string;
}


@implementation QSMarkdownPlugIn_Action


#define kQSMarkdownPlugInAction @"QSMarkdownPlugInAction"

- (QSObject *)convertMarkdownToHTML:(QSObject *)dObject{
	
	NSString *string=QSConvertMarkdownToHTML([dObject stringValue]);
	return [QSObject objectWithString:string];;
}
@end
