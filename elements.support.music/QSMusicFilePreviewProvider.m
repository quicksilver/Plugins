//
//  QSMusicFilePreviewProvider.m
//  Quicksilver
//
//  Created by Nicholas Jitkoff on 1/22/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "QSMusicFilePreviewProvider.h"
#import <CoreFoundation/CFByteOrder.h>
#import <QuickLook/QuickLook.h>

@implementation QSMusicFilePreviewProvider



- (NSImage *)iconForFile:(NSString *)path ofType:(NSString *)type{

  NSImage * theImage = nil;
  NSURL *fileURL = [NSURL fileURLWithPath:path];
  NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger: 128] 
                                                      forKey:kQLThumbnailOptionIconModeKey];
  CGSize iconSize = {256.0, 256.0};
  
  QLThumbnailRef thumbnail = QLThumbnailCreate(NULL, (CFURLRef)fileURL, iconSize, (CFDictionaryRef)options);
  if (thumbnail) {
    CGImageRef cgImage = QLThumbnailCopyImage(thumbnail);
    if (cgImage) {
      NSBitmapImageRep *rep = [[[NSBitmapImageRep alloc] initWithCGImage:cgImage] autorelease];
      theImage = [[[NSImage alloc] init] autorelease];
      [theImage addRepresentation:rep];
      CFRelease(cgImage);
    }
    CFRelease(thumbnail);
  }
  return theImage;
  NSImage *icon=nil;
	
  
	
	BOOL isMP3=NO,isAAC=NO;
	
	
	
	NSString *ext=[path pathExtension];
	if ([ext caseInsensitiveCompare:@"mp3"]==NSOrderedSame)
		isMP3=YES;
	else if ([ext caseInsensitiveCompare:@"m4p"]==NSOrderedSame)
		isAAC=YES;		
	else if ([ext caseInsensitiveCompare:@"m4a"]==NSOrderedSame)
		isAAC=YES;
	
	
	
	
	if (isMP3){
		NSData *data=[NSData dataWithContentsOfMappedFile:path];
		if ([[data subdataWithRange:NSMakeRange(0,3)]isEqualToData:[@"ID3" dataUsingEncoding:NSUTF8StringEncoding]]){
			UInt8 *bytes = (UInt8 *)[data bytes];
			if (bytes[3]>2){
				NSRange coverData=[self rangeOfFrame:'APIC' inData:data];
				if (coverData.location==NSNotFound){
					//NSLog(@"error reading image for MP3: %@",path);
				}else{
					
					int i;
					for (i=2;bytes[coverData.location+i]!=0;i++); //Skip Mime Type
					for (i++;bytes[coverData.location+i]!=0;i++); //Skip Description
					i++; //Skip Terminator
					if (bytes[coverData.location+i]==0) i++; //Skip Extra
					NSRange imageDataRange=NSMakeRange(coverData.location+i,coverData.length-i);
					if (NSMaxRange(imageDataRange)<=[data length]){
					data=[data subdataWithRange:imageDataRange];
					
					icon=[[[NSImage alloc]initWithData:data]autorelease];
					}
				}
			}
		}
	}else if (isAAC){
		NSData *data=[NSData dataWithContentsOfMappedFile:path];
		NSRange coverData=[self rangeOfAtom:'data' inData:data range:[self rangeOfAtom:'covr' inData:data]];
		if (coverData.location!=NSNotFound){
			data=[data subdataWithRange:NSMakeRange(coverData.location+8,coverData.length-8)];
			icon= [[[NSImage alloc]initWithData:data]autorelease];
		}
	}
	//NSLog(@"icon %@",icon);
	return icon;
	return nil;
}



- (NSRange)rangeOfAtom:(UInt32)atom inData:(NSData *)data{
	return [self rangeOfAtom:atom inData:data range:NSMakeRange(0,[data length])];
}
- (NSRange)rangeOfAtom:(UInt32)atom inData:(NSData *)data range:(NSRange)range{
	if (range.location==NSNotFound) return NSMakeRange(NSNotFound,0);
  atom=CFSwapInt32HostToBig(atom);

	UInt8 *bytes, *bytePtr;
	unsigned long int byteIndex, byteCount;
	
	byteCount = [data length];
	bytes = (UInt8 *)[data bytes];
	if (!byteCount || !bytes)return NSMakeRange(NSNotFound,0);
	UInt32 *type;
	UInt32 *length;
	
  // Scan data for byte sequence
	for (byteIndex = range.location, bytePtr = bytes+range.location; byteIndex < byteCount-8 && byteIndex < NSMaxRange(range)-8; byteIndex++,bytePtr++) {
		length=(UInt32 *)(bytePtr);
		type=(UInt32 *)(bytePtr+4);
 		if (*type==atom){
			if (*length>8) 		 return NSMakeRange(byteIndex+8,CFSwapInt32HostToBig((*length))-8);
		}
	}
	//NSLog(@"atom not found");
	return NSMakeRange(NSNotFound,0);
}

- (NSRange)rangeOfFrame:(UInt32)frame inData:(NSData *)data{
	return [self rangeOfFrame:frame inData:data range:NSMakeRange(0,[data length])];
}
- (NSRange)rangeOfFrame:(UInt32)frame inData:(NSData *)data range:(NSRange)range{
	UInt8 *bytes, *bytePtr;
	unsigned long int byteIndex, byteCount;
	  frame=CFSwapInt32HostToBig(frame);
	byteCount = [data length];
	bytes = (UInt8 *)[data bytes];
	if (!byteCount || !bytes)return NSMakeRange(NSNotFound,0);
	
	UInt32 *type;
	UInt32 *length;
	
	for (byteIndex = range.location, bytePtr = bytes+range.location; byteIndex < byteCount-8 && byteIndex < NSMaxRange(range)-8; byteIndex++,bytePtr++) {
		length=(UInt32 *)(bytePtr+4);
		type=(UInt32 *)(bytePtr);
		if (*type==frame){
			if (*length>8) 		 return NSMakeRange(byteIndex+10,CFSwapInt32HostToBig(*length));
		}
	}
	//NSLog(@"frame not found");
	return NSMakeRange(NSNotFound,0);
}

@end
