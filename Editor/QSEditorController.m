

#import "QSEditorController.h"

#import "QSObject_FileHandling.h"

#import "QSObject.h"

#define textTypes [NSArray arrayWithObjects:@"'TEXT'",@"txt",nil]
#define rtfTypes [NSArray arrayWithObjects:@"rtf",nil]

NSMutableDictionary *editorDictionary;

@implementation QSEditorController

+ (void)initialize{
    editorDictionary=[[NSMutableDictionary alloc]initWithCapacity:1];
}

+ (id)editorForObject:(QSObject *)anObject{
    QSEditorController *editor=[editorDictionary objectForKey:[anObject identifier]];
    if (!editor)
        editor=[[QSEditorController alloc]initWithObject:anObject];
             
    return editor;
}


- (id)init {
    return [self initWithWindowNibName:@"Editor"];
}


- (id)initWithObject:(QSObject *)anObject{
    [self init];
    object = anObject;
    filePath=nil;
    modificationDate=nil;
       [editorDictionary setObject:self forKey:[anObject identifier]];
    return self;
}

- (void)awakeFromNib{
    [[self window] addInternalWidgetsForStyleMask:NSUtilityWindowMask];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    [[self window] setMovableByWindowBackground:YES];
    [self openDocument:[object singleFilePath]];
}


- (void) openDocument:(NSString *)path {
    NSLog(@"open: %@",path);

    NSString *type=[[NSFileManager defaultManager]typeOfFile:path];
    if ([textTypes containsObject:type]){    
        NSString *text=[NSString stringWithContentsOfFile:path];
        [textView setString:(text?text:@"")];
    }else if ([rtfTypes containsObject:type]){
        [textView readRTFDFromFile:path];
    } else NSLog(@"Unknown Type: %@",type);

if ([[textView string]length]) filePath=path;
    [titleField setStringValue:([path lastPathComponent])];
    
}

- (IBAction) saveDocument:(id)sender{
    NSString *type=[[NSFileManager defaultManager]typeOfFile:filePath];
    
    if (!filePath){
        NSLog(@"No File Path to save to");
        return;
    }
    
    if ([textTypes containsObject:type])
        [[textView string]writeToFile:filePath atomically:NO];
    else if ([rtfTypes containsObject:type])
        [[textView RTFFromRange:NSMakeRange(0,[[textView string]length])]writeToFile:filePath atomically:NO];
        
        
     //   [textView writeRTFDToFile:filePath atomically:NO];
    else NSLog(@"Unknown Type: %@",type);

}

- (void)windowWillClose:(NSNotification *)aNotification{
    [self saveDocument:self];
    [editorDictionary removeObjectForKey:[object identifier]];
    [self autorelease];
}

- (void)windowDidResignKey:(NSNotification *)aNotification{
  //  [[self window] setAlphaValue:0.8];

}
- (void)windowDidBecomeKey:(NSNotification *)aNotification{
//    [[self window] setAlphaValue:1.0];

}


@end

