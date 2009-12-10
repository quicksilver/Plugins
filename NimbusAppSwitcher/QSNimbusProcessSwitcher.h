

#import <AppKit/AppKit.h>

//#import <QSCore/QSProcessSwitcher.h>
#define kQSNimbusSwitcherPlugInType @"QSNimbusSwitcherPlugInType"

@class QSObjectView;

@interface QSNimbusProcessSwitcher : QSProcessSwitcher {
    
    unsigned int flags;
    bool shouldStick;
    bool lastDirection;
	
	NSTextField *infoView;
	bool centeredLocation;
	
	NSMutableString *searchString;
	QSObjectView *selectionView;
	NSTimer *infoTimer;
	QSObject *currentApplication;
	
	
    NSMutableArray *processViews;
	NSMutableDictionary *processViewsDict;
	NSSortDescriptor *currentSort;
	float scrollX;
	float scrollY;
}


- (IBAction)activate:(id)sender;

- (NSRect)frameForItem:(float)i of:(int)j inFrame:(NSRect)frame;
- (void)updateViews;
-(void)processViewSelected:(QSObjectView *)view;
-(NSString *)infoForApplication:(NSDictionary *)appDictionary;
- (float)diameterForProcessCount:(int)count inDiameter:(float)diameter;
- (float)innerRadiusForFrame:(NSRect)frame;



- (QSObject *)currentApplication;
- (void)setCurrentApplication:(QSObject *)value;


@end
