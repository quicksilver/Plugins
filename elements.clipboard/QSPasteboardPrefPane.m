

#import "QSPasteboardPrefPane.h"


@implementation QSPasteboardPrefPane
- (id)init {
    self = [super initWithBundle:[NSBundle bundleForClass:[QSPasteboardPrefPane class]]];
    if (self) {
    }
    return self;
}

- (NSImage *) icon{
	return [[NSImage alloc]initByReferencingFile:[[NSBundle bundleForClass:[QSPasteboardPrefPane class]]pathForImageResource:@"Clipboard"]];
}
- (NSString *) mainNibName{
return @"QSPasteboardPrefPane";
}


 





@end
