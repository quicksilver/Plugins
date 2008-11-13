

#import "QSFakeMenuWindow.h"

NSRect menuRect(){
    NSRect menuRect=[[[NSScreen screens]objectAtIndex:0]frame];
    float yOffset=NSHeight(menuRect)-22;
    menuRect.size.height=22;

    menuRect=NSOffsetRect(menuRect,0,yOffset);
    //logRect(menuRect);
    return menuRect;
}

@implementation QSFakeMenuWindow

- (id)init{
    NSWindow* result = [super initWithContentRect:menuRect() styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:YES];
    //[self setBackgroundColor: [NSColor clearColor]];//colorWithCalibratedWhite:0.75 alpha:0.5]];
    [self setBackgroundColor: [NSColor clearColor]];
    [self setOpaque:NO];
    [self setHasShadow:NO];
    [self setLevel:27];
    //[self setAutodisplay:NO];
    //[self center];
    [self setMovableByWindowBackground:YES];
    

    NSImageView *content=[[NSImageView alloc]initWithFrame:NSZeroRect];
    [content setImageFrameStyle:NSImageFrameNone];
    [content setImageScaling:NSScaleNone];


   // [content setImage:[self menuBarImage]];


//    [self setAlphaValue: 0.0];
    [self setContentView:content];

    //[content display];
    return result;
}

/*
- (IBAction) hide:(id)sender{

    if (hidden) return;
    hidden=YES;
    [self setFrame:NSOffsetRect([self frame],0,22) display:NO animate:YES];
    [self orderOut:sender];
}

- (IBAction) show:(id)sender{
    if (!hidden) return;
    hidden=NO;


    NSRect menuScreenRect=[[[NSScreen screens]objectAtIndex:0]frame];

    [self setFrame:NSMakeRect(0,0,NSWidth(menuScreenRect),22) display:NO];
    [self setFrameTopLeftPoint:NSMakePoint(NSMinX(menuScreenRect),NSMaxY(menuScreenRect))-22];
 

    [self orderFront:sender];
    [self setAlphaValue:0.0];
    [self display];
    NSImageView *flipView =[[NSImageView alloc]initWithFrame:NSMakeRect(0,0,NSWidth([self frame]),22)];
    [flipView setImageScaling:NSScaleToFit];

    [flipView setImage:[self menuBarImage]];
    [[self contentView]addSubview:flipView];


    [self setAlphaValue:1.0];
    int i;
    for(i=22;i>0;i-=2){
        [flipView setFrame:NSMakeRect(0,22-i,NSWidth([self frame]),22)];
        [self display];
    }

    [flipView removeFromSuperview];
    [flipView release];
    [self display];
}
*/

- (void) mimic{
//    NSLog(@"Mimic");

    [self orderOut:self];

    [[self contentView]setImage:[self menuBarImage]];

    [self setLevel: NSPopUpMenuWindowLevel];
    [self orderWindow: NSWindowAbove  relativeTo: 0];

    [self orderFront:self];
    [self setFrame:menuRect() display:YES animate:NO];
}



- (NSTimeInterval)animationResizeTime:(NSRect)newFrame{
    return 0.25;
}






+ (NSImage *)imageWithScreenShotInRect:(NSRect)cocoaRect
{
	PicHandle picHandle;
	GDHandle mainDevice;
	Rect rect;
	NSImage *image;
	NSImageRep *imageRep;
	
	// Convert NSRect to Rect
	SetRect(&rect, NSMinX(cocoaRect), NSMinY(cocoaRect), NSMaxX(cocoaRect), NSMaxY(cocoaRect));
	
	// Get the main screen. I may want to add support for multiple screens later
	mainDevice = GetMainDevice();
	
	// Capture the screen into the PicHandle.
	picHandle = OpenPicture(&rect);
	CopyBits((BitMap *)*(**mainDevice).gdPMap, (BitMap *)*(**mainDevice).gdPMap,
				&rect, &rect, srcCopy, 0l);
	ClosePicture();
	
	// Convert the PicHandle into an NSImage
	// First lock the PicHandle so it doesn't move in memory while we copy
	HLock((Handle)picHandle);
	imageRep = [NSPICTImageRep imageRepWithData:[NSData dataWithBytes:(*picHandle)
					length:GetHandleSize((Handle)picHandle)]];
	HUnlock((Handle)picHandle);
	
	// We can release the PicHandle now that we're done with it
	KillPicture(picHandle);
	
	// Create an image with the representation
	image = [[[NSImage alloc] initWithSize:[imageRep size]] autorelease];
	[image addRepresentation:imageRep];
	
	return image;
}

-(NSImage *)menuBarImage{
return [[self class]imageWithScreenShotInRect:NSMakeRect(0, 0, CGDisplayPixelsWide(kCGDirectMainDisplay), 22)];
}


-(NSImage *)menuBarImage2{
    NSBitmapImageRep *_screenCaptureBitmap;
    int bPerPixel, bPerSample, sPerPixel, byPerRow, byPerPixel, w, h;
    NSImage *capture;
    unsigned char *_screenBytesActual;

    // Gets the screen dimensions:
    w = CGDisplayPixelsWide(kCGDirectMainDisplay);
    h = 22;//CGDisplayPixelsHigh(kCGDirectMainDisplay);

    // Fix the destination size so it is not bigger that the source
    // (this means we can resize only to smaller images)

    // Gets the base of the screen memory:
    _screenBytesActual = (unsigned char *)CGDisplayBaseAddress(kCGDirectMainDisplay);

    //need to copy the bytes so we can swap them.
    if (_screenBytes != NULL)
        free (_screenBytes);

    _screenBytes = (unsigned char*)malloc(w * h * 4);

    // Gets all the screen info:
    bPerPixel = CGDisplayBitsPerPixel(kCGDirectMainDisplay);
    bPerSample = CGDisplayBitsPerSample(kCGDirectMainDisplay);
    sPerPixel =  CGDisplaySamplesPerPixel(kCGDirectMainDisplay);
    byPerRow = CGDisplayBytesPerRow(kCGDirectMainDisplay);
    byPerPixel = bPerPixel / 8;

    if (_screenBytes != 0)
        {
        // Finds how much we need to resize:
        int xSource, ySource, xDestination, yDestination, deltaX, deltaY;

        // the delta steps are:
        deltaX = (((float)w / (float)w) + 0.5);
        deltaY = (((float)h / (float)h) + 0.5);

        // Copy the screen memory in the new buffer resizing it and "fixing" the pixels:
        for (ySource = 0, yDestination = 0; ySource < h; ySource += deltaY, yDestination++)
            {
            // Pre calucalte this here to save time:

            unsigned long stepSource = ySource * byPerRow;
            unsigned long stepDestination = yDestination * (w * 4);

            for (xSource = 0, xDestination = 0; xSource < w; xSource += deltaX, xDestination++)
                {
                unsigned long newPixel=0;

                if (bPerPixel == 16)
                    {
                    unsigned short thisPixel;

                    // Finds the begin of this pixel:
                    thisPixel = *((unsigned short*)(_screenBytesActual + (xSource * byPerPixel) + stepSource));

                    // Transformation is 0xARGB (with 1555) to 0xR0G0B0A0 with 4444
                    newPixel = thisPixel;
                    newPixel =	(((newPixel & 0x8000) >> 15) * 0xF8) 	/* A */ |
                        ((newPixel & 0x7C00) << 17)		/* R */ |
                        ((newPixel & 0x03E0) << 14)		/* G */ |
                        ((newPixel & 0x001F) << 11)		/* B */ ;
                    }
                else if (bPerPixel == 32)
                    {
                    unsigned long thisPixel;

                    // Finds the beginning of this pixel:
                    thisPixel = *((unsigned long*)(_screenBytesActual + (xSource * byPerPixel) + stepSource));

                    // Transformation is 0xAARRGGBB to 0xRRGGBBAA
                    newPixel = ((thisPixel & 0xFF000000) >> 24) |  ((thisPixel & 0x00FFFFFF) << 8);
                    }

                // Sets the new pixel, and just in case check for the postion:
                if ((xDestination < w) && (yDestination < h))
                    *((unsigned long*)(_screenBytes + (xDestination * 4) + stepDestination)) = newPixel;
                }
            }
        }

    //Phew! create a bitmap w/ the screen capture
    _screenCaptureBitmap = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:&_screenBytes
                                                                   pixelsWide:w
                                                                   pixelsHigh:h
                                                                bitsPerSample:8
                                                              samplesPerPixel:3
                                                                     hasAlpha:NO
                                                                     isPlanar:NO
                                                               colorSpaceName:NSCalibratedRGBColorSpace
                                                                  bytesPerRow:(w * 4)
                                                                 bitsPerPixel:32];

    capture = [[NSImage alloc] initWithSize:[_screenCaptureBitmap size]];
    [capture addRepresentation:_screenCaptureBitmap];

    NSAssert(capture != nil, @"Screen capture failed!");

    [_screenCaptureBitmap release];
    return [capture autorelease];
}





@end
