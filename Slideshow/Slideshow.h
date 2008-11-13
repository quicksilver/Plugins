/*
 *  Slideshow.h
 *
 */

@interface Slideshow : NSResponder
{
	id mPrivateData;
}
+ (id)sharedSlideshow;
+ (void)addImageToiPhoto:(id)fp8;
- (void)setDataSource:(id)source;
- (void)loadConfigData;
- (void)runSlideshowWithDataSource:(id)source options:(NSDictionary *)options;
- (void)startSlideshow:(id)sender;
- (void)runSlideshowWithPDF:(NSURL *)pdfURL options:(NSDictionary *)options;
- (void)stopSlideshow:(id)sender;
- (void)noteNumberOfItemsChanged;
- (void)reloadData;
- (int)indexOfCurrentObject;
- (void)setAutoPlayDelay:(float)delay;
@end

@interface NSObject (SlideshowDelegate)
- (int)numberOfObjectsInSlideshow;
- (id)slideshowObjectAtIndex:(int)index;
- (NSString *)slideshowObjectNameAtIndex:(int)index;

- (BOOL)canExportObjectAtIndexToiPhoto:(int)index;
- (void)exportObjectsToiPhoto:(NSIndexSet *)indexes;
@end