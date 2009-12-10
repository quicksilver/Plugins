//
//  QSImageManipulationPlugInAction.m
//  QSImageManipulationPlugIn
//
//  Created by Nicholas Jitkoff on 11/24/05.
//  Copyright __MyCompanyName__ 2005. All rights reserved.
//

#import "QSImageManipulationPlugInAction.h"
#import <QuartzCore/QuartzCore.h>

#import <Quartz/Quartz.h>

#import "QSImageAdjustController.h"
@implementation NSImage (CICreation)
+ (NSImage *)imageWithCIImage:(CIImage *)i fromRect:(CGRect)r
{
    NSImage *image;
    NSCIImageRep *ir;
    
    ir = [NSCIImageRep imageRepWithCIImage:i];
    image = [[[NSImage alloc] initWithSize:
		NSMakeSize(r.size.width, r.size.height)]
        autorelease];
    [image addRepresentation:ir];
    return image;
}

+ (NSImage *)imageWithCIImage:(CIImage *)i
{
	return [self imageWithCIImage:i fromRect:[i extent]];
}
@end

@implementation NSBitmapImageRep (CICreation)
+ (NSBitmapImageRep *)imageRepWithCIImage:(CIImage *)i fromRect:(CGRect)r
{
	
	// Create a new NSBitmapImageRep.
	NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL pixelsWide:r.size.width pixelsHigh:r.size.height bitsPerSample:8 samplesPerPixel:4 hasAlpha:YES isPlanar:NO colorSpaceName:NSDeviceRGBColorSpace bytesPerRow:0 bitsPerPixel:0];
	
	// Create an NSGraphicsContext that draws into the NSBitmapImageRep. (This capability is new in Tiger.)
	NSGraphicsContext *nsContext = [NSGraphicsContext graphicsContextWithBitmapImageRep:rep];
	
	// Save the previous graphics context and state, and make our bitmap context current.
	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext: nsContext];
	
	// Get a CIContext from the NSGraphicsContext, and use it to draw the CIImage into the NSBitmapImageRep.
	[[nsContext CIContext] drawImage:i atPoint:CGPointZero fromRect:r];
	
	// Restore the previous graphics context and state.
	[NSGraphicsContext restoreGraphicsState];
	
    return [rep autorelease];
}

+ (NSImage *)imageRepWithCIImage:(CIImage *)i
{
	return [self imageRepWithCIImage:i fromRect:[i extent]];
}
@end

@implementation QSImageManipulationPlugInAction


#define kQSImageManipulationPlugInAction @"QSImageManipulationPlugInAction"

- (NSString *)temporaryPath{
	NSString *destinationPath=[NSTemporaryDirectory() stringByAppendingPathComponent:@"Quicksilver"];
	NSFileManager *fm=[NSFileManager defaultManager];
	[fm createDirectoriesForPath:destinationPath];
	return destinationPath;
}
//APPKIT_EXTERN NSString* NSImageCompressionMethod;	// TIFF input/output (NSTIFFCompression in NSNumber)
//APPKIT_EXTERN NSString* NSImageCompressionFactor;	// TIFF/JPEG input/output (float in NSNumber)
- (NSDictionary *)formatDictionaryForString:(NSString *)string{
	if (!string) return nil;
	NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithCapacity:1];
	
	int format=NSTIFFFileType;
	NSRange formatRange;
	if 		((formatRange=[string rangeOfString:@"tif" 	options:NSCaseInsensitiveSearch]).location!=NSNotFound) 	format = NSTIFFFileType;
	else if ((formatRange=[string rangeOfString:@"png" 	options:NSCaseInsensitiveSearch]).location!=NSNotFound)	format = NSPNGFileType;
	else if ((formatRange=[string rangeOfString:@"gif" 	options:NSCaseInsensitiveSearch]).location!=NSNotFound)	format = NSGIFFileType;
	else if ((formatRange=[string rangeOfString:@"bmp" 	options:NSCaseInsensitiveSearch]).location!=NSNotFound)	format = NSBMPFileType;
	else if ((formatRange=[string rangeOfString:@"jpg2" options:NSCaseInsensitiveSearch]).location!=NSNotFound)	format = NSJPEG2000FileType;
	else if ((formatRange=[string rangeOfString:@"jpeg2" options:NSCaseInsensitiveSearch]).location!=NSNotFound)	format = NSJPEG2000FileType;
	else if ((formatRange=[string rangeOfString:@"jpg" 	options:NSCaseInsensitiveSearch]).location!=NSNotFound)	format = NSJPEGFileType;
	else if ((formatRange=[string rangeOfString:@"jpeg" options:NSCaseInsensitiveSearch]).location!=NSNotFound)	format = NSJPEGFileType;
	if (formatRange.location==NSNotFound)return nil;
	NSString *extension=[string substringWithRange:formatRange];
	float quality=0;
	[dict setObject:[NSNumber numberWithInt:format] forKey:@"NSBitmapImageFileType"];
	switch (format){
		case NSJPEGFileType:
		case NSJPEG2000FileType:
		{
			quality=[string floatValue];
			if (quality>100.0f)quality/=100.0f;
			
			if ([string rangeOfString:@" hi" 	options:NSCaseInsensitiveSearch].location!=NSNotFound) quality=0.6f;
			if ([string rangeOfString:@" med" 	options:NSCaseInsensitiveSearch].location!=NSNotFound) quality=0.3f;
			if ([string rangeOfString:@" lo" 	options:NSCaseInsensitiveSearch].location!=NSNotFound) quality=0.1f;
			
			//NSLog(@"quality %f",quality);
			if (quality)
				[dict setObject:[NSNumber numberWithFloat:quality] forKey: NSImageCompressionFactor];
			
			
			if ([string rangeOfString:@"prog" 	options:NSCaseInsensitiveSearch].location!=NSNotFound)
				[dict setObject:[NSNumber numberWithBool:YES] forKey: NSImageProgressive];
			
			break;
		}
		case NSPNGFileType:
			if ([string rangeOfString:@"inter" 	options:NSCaseInsensitiveSearch].location!=NSNotFound)
				[dict setObject:[NSNumber numberWithBool:YES] forKey: NSImageInterlaced];
			
			break;
		case NSGIFFileType:
			if ([string rangeOfString:@"dith" 	options:NSCaseInsensitiveSearch].location!=NSNotFound)
				[dict setObject:[NSNumber numberWithBool:YES] forKey: NSImageDitherTransparency];
			
			break;
		case NSTIFFFileType:
			//			NSTIFFCompressionNone		= 1,
			//			NSTIFFCompressionLZW		= 5,
			//			NSTIFFCompressionPackBits		= 32773,
			
			if ([string rangeOfString:@"jp" 	options:NSCaseInsensitiveSearch].location!=NSNotFound)
				[dict setObject:[NSNumber numberWithBool:YES] forKey: NSImageDitherTransparency];
			
			break;
		default:
			break;
	}
	if (extension)
		[dict setObject:extension forKey: @"fileExtension"];
	
	//NSLog(@"dict %@",dict);
				return dict;
}

float QSFirstStringFloat(NSString *string){
	float f=0;
	for(NSString * component in [string componentsSeparatedByString:@" "]){
		//NSLog(@"comp %@",component);
		f=[component floatValue];
		if (f!=0)break;
	}
	return f;
}

- (CGImageRef)image{

	IKImageView *view=[[IKImageView alloc]init];
	[view setImageWithURL:[NSURL fileURLWithPath:[@"~/Desktop/Picture 1.png" stringByStandardizingPath]]];

		NSLog(@"image %@",[view image]);
		return [view image];

}

- (void)setImage: (CGImageRef)image imageProperties: (NSDictionary*)metaData{
NSLog(@"setimage %@ %@",image, metaData);
}
 
 
- (QSObject *)cropImage:(QSObject *)dObject{
	BOOL useTempFile=[[NSUserDefaults standardUserDefaults]boolForKey:@"QSImageManipulationCreateTempFile"];
	
	NSArray *sourcePaths=[dObject validPaths];
	NSArray *outputFiles=[NSMutableArray arrayWithCapacity:[sourcePaths count]];
	for(NSString * path in sourcePaths){
		NSString *destinationPath=nil;
		if (useTempFile){
			destinationPath=[self temporaryPath];
			destinationPath=[destinationPath stringByAppendingPathComponent:[path lastPathComponent]];
		}else{
			destinationPath=path;//[path stringByDeletingLastPathComponent];
		}
		
		QSImageAdjustController *adjuster=[[QSImageAdjustController alloc]init];
	[adjuster showWindow:nil];
		
//		IKImageEditPanel *panel=[IKImageEditPanel sharedImageEditPanel];
//		[panel setDataSource:self];
//[panel makeKeyAndOrderFront:nil];
//[NSApp runModalForWindow:panel];
//		destinationPath=[destinationPath stringByDeletingPathExtension];
//		
//		NSDictionary *formatDictionary=defaultFormat;
//		
//		NSString *extension=[formatDictionary objectForKey:@"fileExtension"];
//		if (extension)
//			destinationPath=[destinationPath stringByAppendingPathExtension:extension];

		destinationPath=[destinationPath firstUnusedFilePath];
				NSLog(@"path %@ %@",path, destinationPath);
		
//		NSBitmapImageRep *rep=[NSBitmapImageRep imageRepWithContentsOfFile:path];
//		[[rep representationUsingType:[[formatDictionary objectForKey:@"NSBitmapImageFileType"]intValue]
//						   properties:formatDictionary] writeToFile:destinationPath atomically:NO];
//		[[NSWorkspace sharedWorkspace] noteFileSystemChanged:[destinationPath stringByDeletingLastPathComponent]];
//		[outputFiles addObject:destinationPath];
	}
	return [QSObject fileObjectWithArray:outputFiles];
	

}


- (QSObject *)scaleImage:(QSObject *)dObject toSize:(QSObject *)iObject{
	NSString *size=[iObject stringValue];
	
	NSString *formatString=nil;
	
	NSArray *components=[size componentsSeparatedByString:@"as"];
	if ([components count]==2)
		formatString=[components objectAtIndex:1];
	size=[components objectAtIndex:0];
	components=[size componentsSeparatedByString:@"x"]; 
	
	NSDictionary *defaultFormat=[self formatDictionaryForString:formatString];
	
	
	BOOL percent=[size rangeOfString:@"%"].location!=NSNotFound;
	//BOOL isMaxSize=NO;
	BOOL isMaxSize=[size rangeOfString:@"fit"].location!=NSNotFound;
	BOOL sharpen=[size rangeOfString:@"shar"].location!=NSNotFound;
	
	NSString *widthString=[components objectAtIndex:0];
	NSString *heightString=nil;
	
	float w=QSFirstStringFloat(widthString);
	float h=w;
	if ([components count]>1)
		h=QSFirstStringFloat([components objectAtIndex:1]);
	else
		isMaxSize=YES;
	
	if (w*h==0){
		//	if (isMaxSize){
		isMaxSize=YES;
		if (!w)w=MAXFLOAT;
		if (!h)h=MAXFLOAT;
		}
	
	if (percent){
		w/=100.0f;
		h/=100.0f;
	}else if (w<1.0f || h<1.0f){
		percent=YES;	
	}
	//NSLog(@"Scale to %f x %f, perc:%d max:%d",w,h,percent,isMaxSize);
	
	BOOL useTempFile=[[NSUserDefaults standardUserDefaults]boolForKey:@"QSImageManipulationCreateTempFile"];
	
	NSArray *sourcePaths=[dObject validPaths];
	NSArray *outputFiles=[NSMutableArray arrayWithCapacity:[sourcePaths count]];
	for(NSString * path in sourcePaths){
		NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
#warning should honor gif's NSImageRGBColorTable value
		NSString *destinationPath=nil;
		if (useTempFile){
			destinationPath=[self temporaryPath];
			destinationPath=[destinationPath stringByAppendingPathComponent:[path lastPathComponent]];
		}else{
			destinationPath=path;//[path stringByDeletingLastPathComponent];
		}
		destinationPath=[destinationPath stringByDeletingPathExtension];
		
		
		CIImage *image=[CIImage imageWithContentsOfURL:[NSURL fileURLWithPath:path]];
		CGRect extent=[image extent];
		
		float oldWidth=extent.size.width;
		float oldHeight=extent.size.height;
		
		float newWidth=oldWidth;
		float newHeight=oldHeight;
		
		float scale=1.0f;
		float ratio=1.0f;
		
		if (percent){
			scale=h;
			ratio=w/scale;
			newWidth*=h;
			newHeight*=h;
		}else if (isMaxSize){
			scale=MIN(w/oldWidth,h/oldHeight);
			
			//NSLog(@"min %f  %f",w/oldWidth,h/oldHeight);
			newWidth*=scale;
			newHeight*=scale;
		}else{
			scale=h/oldHeight;
			ratio=w/oldWidth/scale;
			newWidth=w;
			newHeight=h;
		}
		newWidth=roundf(newWidth);
		newHeight=roundf(newHeight);
//		CIFilter *scaleFilter = [CIFilter filterWithName:@"CILanczosScaleTransform"]; 
//		[scaleFilter setDefaults]; 
//		[scaleFilter setValue: image forKey: @"inputImage"];  
//		[scaleFilter setValue: [NSNumber numberWithFloat: ratio]  forKey: @"inputAspectRatio"];
//		[scaleFilter setValue: [NSNumber numberWithFloat: scale]  forKey: @"inputScale"];
//		
//		CIImage *result = [scaleFilter valueForKey: @"outputImage"]; 
//		
	//	float yscale = h / originalSize.height;
		//NSLog(@"bigger? %d",newHeight>200.0f);
		CIImage *im=image;
		
		CIFilter *f = [CIFilter filterWithName:@"CILanczosScaleTransform"];
		[f setDefaults]; 
		[f setValue:[NSNumber numberWithFloat:scale] forKey:@"inputScale"];
		[f setValue:[NSNumber numberWithFloat:ratio] forKey:@"inputAspectRatio"];
		[f setValue:im forKey:@"inputImage"];
		im = [f valueForKey:@"outputImage"];
		
		f = [CIFilter filterWithName:@"CIAffineClamp"];
		[f setValue:[NSAffineTransform transform]forKey:@"inputTransform"];
		[f setValue:im forKey:@"inputImage"];
		im = [f valueForKey:@"outputImage"];
		
		CIVector *cropRect =[CIVector vectorWithX:0.0 Y:0.0 Z: newWidth W: newHeight];
		f = [CIFilter filterWithName:@"CICrop"];
		[f setValue:im forKey:@"inputImage"];
		[f setValue:cropRect forKey:@"inputRectangle"];
		im = [f valueForKey:@"outputImage"];
		
		if (sharpen){
			f = [CIFilter filterWithName:@"CISharpenLuminance"];
			[f setDefaults]; 			
			[f setValue:im forKey:@"inputImage"];
//			[f setValue:[NSNumber numberWithFloat:0.04] forKey:@"inputSharpness"];
			im = [f valueForKey:@"outputImage"];
		}
		
		CIImage *result=im;
		
		//NSLog(@"scale %f %f %f",extent.size.height,scale, extent.size.height*scale);
		NSBitmapImageRep *rep=[NSBitmapImageRep imageRepWithCIImage:result];
		
		
		NSDictionary *formatDictionary=defaultFormat;
		if (!formatDictionary) formatDictionary=[self formatDictionaryForString:[path pathExtension]];
		
		NSString *extension=[formatDictionary objectForKey:@"fileExtension"];
		if (extension)
			destinationPath=[destinationPath stringByAppendingPathExtension:extension];
		destinationPath=[destinationPath firstUnusedFilePath];
		
		[[rep representationUsingType:[[formatDictionary objectForKey:@"NSBitmapImageFileType"]intValue]
						   properties:formatDictionary] writeToFile:destinationPath atomically:NO];
		[[NSWorkspace sharedWorkspace] noteFileSystemChanged:[destinationPath stringByDeletingLastPathComponent]];
		[outputFiles addObject:destinationPath];
		[pool release];
	}
	return [QSObject fileObjectWithArray:outputFiles];
	
	}

- (QSObject *)saveImage:(QSObject *)dObject asFormat:(QSObject *)iObject{
	NSString *formatString=[iObject stringValue];
	NSDictionary *defaultFormat=[self formatDictionaryForString:formatString];
	
	BOOL useTempFile=[[NSUserDefaults standardUserDefaults]boolForKey:@"QSImageManipulationCreateTempFile"];
	
	NSArray *sourcePaths=[dObject validPaths];
	NSArray *outputFiles=[NSMutableArray arrayWithCapacity:[sourcePaths count]];
	for(NSString * path in sourcePaths){
		NSString *destinationPath=nil;
		if (useTempFile){
			destinationPath=[self temporaryPath];
			destinationPath=[destinationPath stringByAppendingPathComponent:[path lastPathComponent]];
		}else{
			destinationPath=path;//[path stringByDeletingLastPathComponent];
		}
		destinationPath=[destinationPath stringByDeletingPathExtension];
		
		NSDictionary *formatDictionary=defaultFormat;
		
		NSString *extension=[formatDictionary objectForKey:@"fileExtension"];
		if (extension)
			destinationPath=[destinationPath stringByAppendingPathExtension:extension];
		destinationPath=[destinationPath firstUnusedFilePath];
		
		
		NSBitmapImageRep *rep=[NSBitmapImageRep imageRepWithContentsOfFile:path];
		[[rep representationUsingType:[[formatDictionary objectForKey:@"NSBitmapImageFileType"]intValue]
						   properties:formatDictionary] writeToFile:destinationPath atomically:NO];
		[[NSWorkspace sharedWorkspace] noteFileSystemChanged:[destinationPath stringByDeletingLastPathComponent]];
		[outputFiles addObject:destinationPath];
	}
	return [QSObject fileObjectWithArray:outputFiles];
	
}

- (NSArray *)validActionsForDirectObject:(QSObject *)dObject indirectObject:(QSObject *)iObject{
	NSString *paths=[dObject validPaths];
	if ([[NSImage imageUnfilteredFileTypes]containsObject:[[[paths lastObject]pathExtension]lowercaseString]]){
		return [NSArray arrayWithObjects:@"QSImageAsFormatAction",@"QSImageScaleAction",@"QSImageCropAction",nil];
	}
	//	NSLog(@"other %@",[[[paths lastObject]pathExtension]lowercaseString]);
	return nil;
}
- (NSArray *)validIndirectObjectsForAction:(NSString *)action directObject:(QSObject *)dObject{
	QSObject *textObject=[QSObject textProxyObjectWithDefaultValue:@""];
	return [NSArray arrayWithObject:textObject]; //[QSLibarrayForType:NSFilenamesPboardType];
	
}
@end
