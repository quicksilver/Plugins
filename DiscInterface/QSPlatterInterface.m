//
//  QSPlatterInterface.m
//  QSPlatterInterface
//
//  Created by Nicholas Jitkoff on 8/8/06.
//  Copyright __MyCompanyName__ 2006. All rights reserved.
//

#import "QSPlatterInterface.h"
#import <Carbon/Carbon.h>
#import <QSFoundation/NSGeometry_BLTRExtensions.h>
#import <QSEffects/QSWindow.h>
#import <QSInterface/QSSearchObjectView.h>
#import <QSInterface/QSObjectCell.h>
#import <ApplicationServices/ApplicationServices.h>


#define EXPAND_HEIGHT 28


@implementation QSCIReflectionFilter : CIFilter

+ (id)reflectionFilter{
	return [[[self alloc]init]autorelease];
}
- (id) init {
	self = [super init];
	if (self != nil) {
		

		NSAffineTransform *transform=[NSAffineTransform transform];
		[transform scaleXBy:1.0 yBy:-1.0];
		[transform translateXBy:0.0 yBy:-16.0];
		flipFilter = [CIFilter filterWithName:@"CIAffineTransform"];		// create effect filter
		[flipFilter setDefaults];										// make sure all paramters are set to something reasonable
		[flipFilter setValue:transform forKey:kCIInputTransformKey];	// set the center of the effect to be the center of the layer        
		

		blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];		// create effect filter
		[blurFilter setDefaults];									// make sure all paramters are set to something reasonable
		[blurFilter setValue:[NSNumber numberWithFloat:3.0] forKey:kCIInputRadiusKey];	// set the center of the effect to be the center of the layer        
		

		opacityFilter = [CIFilter filterWithName:@"CIColorMatrix"];		// create effect filter
		[opacityFilter setDefaults];									// make sure all paramters are set to something reasonable
		[opacityFilter setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:0.5] forKey:@"inputAVector"];	// set the center of the effect to be the center of the layer        
		
		

//		gradientFilter = [CIFilter filterWithName:@"CILinearGradient"];		// create effect filter
//		[gradientFilter setDefaults];									// make sure all paramters are set to something reasonable
//		[gradientFilter setValue:[CIVector vectorWithX:0 Y:0] forKey:@"inputPoint0"];	// set the center of the effect to be the center of the layer        
//		[gradientFilter setValue:[CIVector vectorWithX:200 Y:200] forKey:@"inputPoint1"];	// set the center of the effect to be the center of the layer        
//		

		blendFilter = [CIFilter filterWithName:@"CISourceOverCompositing"];		// create effect filter
		[blendFilter setDefaults];									// make sure all paramters are set to something reasonable
		
		
		[flipFilter retain];
		[blurFilter retain];
		[opacityFilter retain];
		[gradientFilter retain];
		[blendFilter retain];
	}
	return self;
}

- (id)valueForKey:(NSString *)key{
	
	if ([key isEqualToString:kCIOutputImageKey]){
	
			
		id result=[self valueForKey:kCIInputImageKey];
		
		[blendFilter setValue:result forKey:kCIInputBackgroundImageKey];
		
		[flipFilter setValue:result forKey:kCIInputImageKey];
		result=[flipFilter valueForKey:kCIOutputImageKey];
		
		[blurFilter setValue:result forKey:kCIInputImageKey];
		result=[blurFilter valueForKey:kCIOutputImageKey];
		
		[opacityFilter setValue:result forKey:kCIInputImageKey];
		result=[opacityFilter valueForKey:kCIOutputImageKey];
		
	//	return [gradientFilter valueForKey:kCIOutputImageKey] ;
		
		[blendFilter setValue:result forKey:kCIInputImageKey];
		
	//	[blendFilter setValue:[gradientFilter valueForKey:kCIOutputImageKey] forKey:kCIInputMaskImageKey];
		result=[blendFilter valueForKey:kCIOutputImageKey];
		
		
		//	CIFilterGenerator *generator=[CIFilterGenerator filterGenerator];
		//	[generator exportKey:kCIInputImageKey fromObject:flipFilter withName:nil]; // Export the Flip filter
		//
		//	[generator connectObject:flipFilter withKey:kCIOutputImageKey toObject:blurFilter withKey:kCIInputImageKey]; // Blur the flipped version
		//
		//	[generator connectObject:blurFilter withKey:kCIOutputImageKey toObject:blendFilter withKey:kCIInputBackgroundImageKey]; // Connect Blurred version
		//	[generator connectObject:gradientFilter withKey:kCIOutputImageKey toObject:blendFilter withKey:kCIInputMaskImageKey]; // Connect Gradient
		//	[generator exportKey:kCIInputImageKey fromObject:blendFilter withName:nil]; // Connect Original Version
		//	//[generator connectObject:gradientFilter withKey:kCIOutputImageKey toObject:blendFilter withKey:kCIInputImageKey]; // Connect Original Version
		//	
		//	[generator exportKey:kCIOutputImageKey fromObject:blendFilter withName:nil];
		//	
		//	[generator writeToURL:[NSURL fileURLWithPath:@"/Users/alcor/Desktop/Filter.plist"] atomically:YES];
		//	//[generator registerFilterName:@"QSReflection" classAttributes:nil];
		//	
		//	
		return result;
	}
	return [super valueForKey:key]; 
}
- (void)setValue:(id)value forKey:(NSString *)key{
	//NSLog(@"value %@ %@",key, value);	
//		if ([key isEqualToString:kCIInputImageKey]){
//			inputImage=[value retain];
//		}
	[super setValue:value forKey:key];
}
@end





@implementation QSPlatterInterface

//
//CALayer *layer=[CALayer layer];
//layer.frame=CGRectMake(0,0,200,00);
//layer.view=[;
//
//@end
- (id)init {
	if (self = [super initWithWindowNibName:@"QSPlatterInterface"]){
    }
    return self;
}

- (NSSize)maxIconSize{
    return NSMakeSize(512,512);
}

- (void) windowDidLoad{
	[super windowDidLoad];
    [[self window] setLevel:NSModalPanelWindowLevel];
    [[self window] setFrameAutosaveName:@"PlatterInterfaceWindow"];
	[[self window]setFrame:constrainRectToRect([[self window]frame],[[[self window]screen]visibleFrame]) display:NO];
	
	//    [self contractWindow:self];
	[[self window] setBackgroundColor:[NSColor clearColor]];
	NSWindow *contentWindow=[self window];
	
	NSWindow *window=[self window];
	
	
	
	[window setShowEffect:[NSDictionary dictionaryWithObjectsAndKeys:@"QSGrowEffect",@"transformFn",@"show",@"type",[NSNumber numberWithFloat:0.25],@"duration",nil]];
			[window setHideEffect:[NSDictionary dictionaryWithObjectsAndKeys:@"QSShrinkEffect",@"transformFn",@"hide",@"type",[NSNumber numberWithFloat:.25],@"duration",nil]];
	//	
	//[window setWindowProperty:[NSDictionary dictionaryWithObjectsAndKeys:@"QSExplodeEffect",@"transformFn",@"hide",@"type",[NSNumber numberWithFloat:0.2],@"duration",nil]
	//forKey:kQSWindowExecEffect];
	
//	[window setHideEffect:[NSDictionary dictionaryWithObjectsAndKeys:@"hide",@"type",[NSNumber numberWithFloat:0.15],@"duration",nil]];
//	[window setWindowProperty:
//	forKey:kQSWindowFadeEffect];
	
	//	[window setWindowProperty:[NSDictionary dictionaryWithObjectsAndKeys:@"QSShrinkEffect",@"transformFn",@"hide",@"type",[NSNumber numberWithFloat:0.333],@"duration",nil,[NSNumber numberWithFloat:0.25],@"brightnessB",@"QSStandardBrightBlending",@"brightnessFn",nil]
	//						   forKey:kQSWindowCancelEffect];
	//
	
	
	
	
	positionL=[dSelector frame];
	positionC=[aSelector frame];
	positionR=[iSelector frame];
	[dSelector setFrame:positionC];
	[aSelector setFrame:positionR];
	[iSelector setFrame:positionR];
	[[contentWindow contentView] setWantsLayer:YES];							// setup the content view to use layers
	
	CALayer *root = [[contentWindow contentView] layer];						// create a layer to contain all of our layers

	CIFilter    *noFilter;
	noFilter = [CIFilter filterWithName:@"CIAffineTransform"];		// create effect filter
	[noFilter setValue:[NSAffineTransform transform] forKey:kCIInputTransformKey];	// set the center of the effect to be the center of the layer        
	
	CIFilter  *flipFilter;
	NSAffineTransform *transform=[NSAffineTransform transform];
	[transform scaleXBy:1.0 yBy:-1.0];
	flipFilter = [CIFilter filterWithName:@"CIAffineTransform"];		// create effect filter
	[flipFilter setDefaults];										// make sure all paramters are set to something reasonable
	[flipFilter setValue:transform forKey:kCIInputTransformKey];	// set the center of the effect to be the center of the layer        
	
	CIFilter    *blurFilter;
	blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];		// create effect filter
	[blurFilter setDefaults];									// make sure all paramters are set to something reasonable
	[blurFilter setValue:[NSNumber numberWithFloat:1.0] forKey:kCIInputRadiusKey];	// set the center of the effect to be the center of the layer        
	
	CIFilter    *gradientFilter;
	gradientFilter = [CIFilter filterWithName:@"CILinearGradient"];		// create effect filter
	[gradientFilter setDefaults];									// make sure all paramters are set to something reasonable
	[gradientFilter setValue:[CIVector vectorWithX:0 Y:0] forKey:@"inputPoint0"];	// set the center of the effect to be the center of the layer        
	[gradientFilter setValue:[CIVector vectorWithX:0 Y:200] forKey:@"inputPoint1"];	// set the center of the effect to be the center of the layer        
	
	

	CIFilter    *blendFilter;
	blendFilter = [CIFilter filterWithName:@"CIBlendWithMask"];		// create effect filter
	[blendFilter setDefaults];									// make sure all paramters are set to something reasonable
	

	
//	CIFilterGenerator *generator=[CIFilterGenerator filterGenerator];
//	[generator exportKey:kCIInputImageKey fromObject:flipFilter withName:nil]; // Export the Flip filter
//
//	[generator connectObject:flipFilter withKey:kCIOutputImageKey toObject:blurFilter withKey:kCIInputImageKey]; // Blur the flipped version
//
//	[generator connectObject:blurFilter withKey:kCIOutputImageKey toObject:blendFilter withKey:kCIInputBackgroundImageKey]; // Connect Blurred version
//	[generator connectObject:gradientFilter withKey:kCIOutputImageKey toObject:blendFilter withKey:kCIInputMaskImageKey]; // Connect Gradient
//	[generator exportKey:kCIInputImageKey fromObject:blendFilter withName:nil]; // Connect Original Version
//	//[generator connectObject:gradientFilter withKey:kCIOutputImageKey toObject:blendFilter withKey:kCIInputImageKey]; // Connect Original Version
//	
//	[generator exportKey:kCIOutputImageKey fromObject:blendFilter withName:nil];
//	
//	[generator writeToURL:[NSURL fileURLWithPath:@"/Users/alcor/Desktop/Filter.plist"] atomically:YES];
//	//[generator registerFilterName:@"QSReflection" classAttributes:nil];
//	
//	
	
//	2006-08-11 05:28:51.099 Quicksilver[269:117] *** Selector 'exportedKeys' sent to dealloced instance 0x16608ca0 of class CIFilterGenerator.
//	Break at '-[_NSZombie methodSignatureForSelector:]' to debug.
//	2006-08-11 05:28:51.099 Quicksilver[269:117] *** -[NSAutoreleasePool dealloc]: Exception ignored while releasing an object in an autorelease pool: *** Selector 'exportedKeys' sent to dealloced instance 0x16608ca0 of class CIFilterGenerator.
//	Break at '-[_NSZombie methodSignatureForSelector:]' to debug.
//	
//	CIFilterGenerator *simpleGenerator=[CIFilterGenerator filterGenerator];
//	[simpleGenerator exportKey:kCIInputImageKey fromObject:blurFilter withName:nil]; // Export the Blur filter
//	[simpleGenerator exportKey:kCIOutputImageKey fromObject:blurFilter withName:nil]; // Export the Blur filter
//	CIFilter    *finalFilter=[simpleGenerator filter];
//	
	
	
	
	CIFilter    *reflectionFilter;
//	reflectionFilter = [[generator filter]retain];//[CIFilter filterWithName:@"QSReflection"];		// create effect filter

	CIFilter    *effect=[QSCIReflectionFilter reflectionFilter];//[finalFilter retain];
	
	NSLog(@"filter %@",effect);
	
	
	CALayer *container=[CALayer layer];
	{
		foreach(sublayer,[[[root sublayers]copy]autorelease]){
			[container addSublayer:sublayer];
//			((CALayer *)sublayer).sublayerTransform=LKTransformTranslateLKTransformMakeScale(1.0,-1.0,1.0);
//			CALayer *reflection=[CALayer layer];
//			CGRect frame=[(CALayer *)sublayer frame];
//			frame.origin=CGPointZero;
//			frame.origin.y+=32;
//			frame.size.height*=-1;
//			reflection.frame=frame;
//			[(CALayer *)sublayer addSublayer:reflection];
//			//reflection.backgroundColor=(CGColorRef)[NSColor whiteColor];
//			reflection.borderWidth=2.0;
//			reflection.cornerRadius=8.0;
//			reflection.opacity=0.5;
//			reflection.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;	// make it resize when its superlayer does
//			NSLog(@"prop %@",[(CALayer *)sublayer actions]);
//			
	
			((CALayer *)sublayer).filters=[NSArray arrayWithObjects:effect,nil];	// set the effect on the layer
			
		}
	}
	[root addSublayer:container];

	
	
	//container.layoutManager = self;				// use constraint layout to allow sublayers to center themselves
	
	label = [CATextLayer layer];
	label.frame=CGRectMake(100,0,344,168);
	label.string=@"Type to Search";
	//label.font=[NSFont fontWithName:@"Lucida Grande" size:40.0];
	label.fontSize=24.0;
	label.alignmentMode=kCAAlignmentCenter;
	label.foregroundColor=(CGColorRef)[NSColor blackColor];
	//label.borderWidth=1.0;
	//label.backgroundColor=[NSColor whiteColor];
//	CIFilter    *effect;
	
//	effect = [CIFilter filterWithName:@"CIGaussianBlur"];		// create effect filter
//	[effect setDefaults];										// make sure all paramters are set to something reasonable
//	[effect setValue:[NSNumber numberWithFloat:1.0] forKey:kCIInputRadiusKey];	// set the center of the effect to be the center of the layer        
	
//	label.filters=[NSArray arrayWithObject:effect];	// set the effect on the layer
	
	
	
	
	
	[root insertSublayer:label above:nil];
	
	CALayer *background = [CALayer layer];
	{
		background.bounds = root.bounds;
		background.frame = CGRectMake(0,0,544,335);
		NSURL	*imageURL = [NSURL fileURLWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"Silver-Platter-Interface" ofType:@"png"]];
		CGImageSourceRef	source     = CGImageSourceCreateWithURL((CFURLRef)imageURL, nil);
		background.contents = (id)CGImageSourceCreateImageAtIndex(source, 0, nil);
		CFRelease (source);
	}
	[root insertSublayer:background atIndex:0];	// insert layer on the bottom of the stack so it is behind the controls
	//root.sublayerTransform = LKTransformMakeTranslation(0.0,0.0,-512.0);
	
	CALayer *mask = [CALayer layer];
	{
		mask.bounds = root.bounds;
		mask.frame = CGRectMake(0,0,544,635);
		NSURL	*imageURL = [NSURL fileURLWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"Silver-Platter-Mask" ofType:@"png"]];
		CGImageSourceRef	source     = CGImageSourceCreateWithURL((CFURLRef)imageURL, nil);
		mask.contents = (id)CGImageSourceCreateImageAtIndex(source, 0, nil);
		CFRelease (source);
	}
	
	container.mask=mask;//[root insertSublayer:mask atIndex:1];	// insert layer on the bottom of the stack so it is behind the controls
	
	
	
	root.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;	// make it resize when its superlayer does
	//container.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;	// make it resize when its superlayer does
	//root.layoutManager = self;
	
	
	CALayer *sublayer=[dSelector layer];
	//	sublayer.transform = LKTransformMakeRotation(0.8,1.0,0.0,0);
	////	sublayer.borderWidth=2.0;
	//	sublayer=[aSelector layer];
	//	sublayer.transform = LKTransformMakeRotation(0.4,0.0,1.0,0);
	
	
	
	
	
	
    NSArray *theControls=[NSArray arrayWithObjects:dSelector,aSelector,iSelector,nil];
    foreach(theControl,theControls){
		//NSCell *theCell=[[[QSFancyObjectCell alloc]init]autorelease];
		//[theControl setCell:theCell];
		
		NSCell *theCell=[theControl cell];
		[theCell setAlignment:NSCenterTextAlignment];
		[theControl setPreferredEdge:NSMinYEdge];
		[theControl setResultsPadding:108];
		[theControl setPreferredEdge:NSMinYEdge];
		[(QSWindow *)[((QSSearchObjectView *)theControl)->resultController window]setHideOffset:NSMakePoint(0,NSMinY([iSelector frame]))];
		[(QSWindow *)[((QSSearchObjectView *)theControl)->resultController window]setShowOffset:NSMakePoint(0,NSMinY([dSelector frame]))];
		
        [(QSObjectCell *)theCell setShowDetails:NO];
		[(QSObjectCell *)theCell setImagePosition:NSImageOnly];
		//   [(QSObjectCell *)theCell setTextColor:[NSColor whiteColor]];
		// [(QSObjectCell *)theCell setState:NSOnState];
		[(QSObjectCell *)theCell setHighlightColor:[NSColor clearColor]];
		
	}
	
	
	
	NSLog(@"root %@", [[root sublayers]valueForKey:@"view"]);
}


/* Called when the preferred size of 'layer' may have changed. The
 * receiver is responsible for recomputing the preferred size and
 * returning it. */

- (CGSize)preferredSizeOfLayer:(CALayer *)layer{
	
}

/* Called when the preferred size of 'layer' may have changed. The
 * receiver should invalidate any cached state. */

- (void)invalidateLayoutOfLayer:(CALayer *)layer{}

/* Called when the sublayers of 'layer' may need rearranging (e.g. if
 * something changed size). The receiver is responsible for changing
 * the frame of each sublayer that needs a new layout. */

- (void)layoutSublayersOfLayer:(CALayer *)layer{
	NSLog(@"layout %@",layer);
}

- (void)firstResponderChanged:(NSResponder *)aResponder{

	
	//[super firstResponderChanged:aResponder];
	//	logRect([[self window]frame]);
	//	[super firstResponderChanged:aResponder];
	//NSLog(@"responder",aResponder);
	
	
	id responder=[[self window]firstResponder];
	
	[self updateSearchViewsForTarget:responder];
	
}


- (void)updateSearchViewsForTarget:(NSView *)aResponder{
	
	CALayer *dLayer=[(NSView *)dSelector layer];
	CALayer *aLayer=[(NSView *)aSelector layer];
	
	CALayer *mainLayer=nil;
	CALayer *fadeLayer=nil;
	
	
	if (aResponder==dSelector){
		
		mainLayer=dLayer;
		fadeLayer=aLayer;
	}else if (aResponder==aSelector){// || aResponder==iSelector){
		mainLayer=aLayer;
		fadeLayer=dLayer;

		
	}
	
	//mainLayer.transform = LKTransformTranslate(mainLayer.transform,0.0,0.0,10.0);
	//fadeLayer.transform = LKTransformTranslate(fadeLayer.transform,0.0,0.0,-10.0);
	
	
	
//	CIFilter    *effect;
//	
//	effect = [CIFilter filterWithName:@"CIGaussianBlur"];		// create effect filter
//	[effect setDefaults];										// make sure all paramters are set to something reasonable
//	[effect setValue:[NSNumber numberWithFloat:1.0] forKey:kCIInputRadiusKey];	// set the center of the effect to be the center of the layer        
//	
//	[fadeLayer setFilters:[NSArray arrayWithObject:effect]];	// set the effect on the layer
//	//fadeLayer.opacity=0.5;
//	[mainLayer setFilters:[NSArray array]];
//	mainLayer.opacity=1.0;
//	
	
	
	NSControl *fieldL=nil;
	NSControl *fieldR=nil;
	NSControl *fieldC=nil;
	NSControl *fieldO=nil;
	
	NSRect frameC=positionC;
	NSRect frameR=positionR;
	NSRect frameL=positionL;
	
	if (aResponder==dSelector){
		fieldC=dSelector;
		fieldR=aSelector;
		fieldO=iSelector;
		//		frameC=NSOffsetRect(NSInsetRect(frameC,-128,-128),0,128);
	}else if (aResponder==aSelector){
		fieldL=dSelector;
		fieldC=aSelector;
		fieldR=iSelector;
	}else if (aResponder==iSelector){
		fieldL=dSelector;
		fieldR=aSelector;
		fieldC=iSelector;
	};
  
	
	[[fieldC animator] setFrame:frameC];
	[[fieldC animator] setAlphaValue:1.0];
	[[fieldR animator] setFrame:frameR];
	[[fieldR animator] setAlphaValue:1.0];
	[[fieldL animator] setFrame:frameL];
	[[fieldL animator] setAlphaValue:1.0];
	
	[[fieldO animator] setAlphaValue:0.0];
	
	CALayer *layer=[fieldC layer];
	//[[[layer sublayers]lastObject]setContents:[layer contents]];


	
//	sublayer=[
//	CALayer *reflection=[CALayer layer];
//	CGRect frame=[(CALayer *)sublayer frame];
//	frame.origin=CGPointZero;
//	frame.size.height*=-1;
//	reflection.frame=frame;
//	
	
	
	

	[self updateDetailsString];
	
}
- (void)searchObjectChanged:(NSNotification*)notif{
	[super searchObjectChanged:notif];	
	[self updateDetailsString];
}




- (void)hideMainWindow:(id)sender{
    [[self window] saveFrameUsingName:@"PlatterInterfaceWindow"];
    [super hideMainWindow:sender];
}

-(void) activate:(id)sender{
	
	CABasicAnimation* animation=[CABasicAnimation animationWithKeyPath:@"transform"];
	animation.fromValue=[NSValue valueWithLKTransform:LKTransformMakeTranslation(0.0,0.0,0.0)];
	animation.toValue=[NSValue valueWithLKTransform:LKTransformMakeTranslation(0.0,10.0,0.0)];
	animation.repeatCount=10.0;
	animation.autoreverses=YES;
	animation.speed=0.05;
	animation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	[[[[self window] contentView]layer] addAnimation:animation forKey:@"Float"];
  [super activate:sender];

}

- (NSRect)window:(NSWindow *)window willPositionSheet:(NSWindow *)sheet usingRect:(NSRect)rect{
    return NSOffsetRect(NSInsetRect(rect,8,0),0,-21);
}
- (void)showIndirectSelector:(id)sender{
	//   [[[self window]contentView]addSubview:iSelector];
    [aSelector setNextKeyView:iSelector];
}

- (void)hideIndirectSelector:(id)sender{
	   [aSelector setNextKeyView:dSelector];
    //[iSelector removeFromSuperview];
}

-(void)updateDetailsString{
	NSControl *firstResponder=(NSControl *)[[self window]firstResponder];
	//	NSString *details=nil;
	//	if ([firstResponder respondsToSelector:@selector(objectValue)]){
	//		id object=[firstResponder objectValue];
	//		if ([object respondsToSelector:@selector(details)]){
	//			details=[object details];
	//		}
	//		
	//		NSString *string=[firstResponder matchedString];
	//		[searchTextField setStringValue:(string && ![string hasPrefix:@"QSActionMnemonic"])?[string uppercaseString]:@""];
	//		//	[searchTextField setAttributedStringValue:[self fancyStringForView:firstResponder]];
	//	}
	//	[detailsTextField setStringValue:details?details:@""];
	
	
	//NSLog(@"update");
	if ([firstResponder respondsToSelector:@selector(objectValue)]){

	NSString *command=[[firstResponder objectValue]displayName];
	if (command)	label.string=command;//[commandField setStringValue:command?command:@""];
	}
}


//- (void)showIndirectSelector:(id)sender{
//
////        [iSelector setFrame:NSOffsetRect([aSelector frame],0,-26)];
////    [super showIndirectSelector:sender];
//}
////
//- (void)expandWindow:(id)sender{ 
//
//    [super expandWindow:sender];
//}

//- (void)contractWindow:(id)sender{
////    NSRect contractedRect=[[self window]frame];
////    
////    contractedRect.size.height-=EXPAND_HEIGHT;
////    contractedRect.origin.y+=EXPAND_HEIGHT;
////
////    if (expanded)
////        [[self window]setFrame:contractedRect display:YES animate:YES];
////    
//    [super contractWindow:sender];
//}
//

@end