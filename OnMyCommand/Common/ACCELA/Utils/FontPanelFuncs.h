// This file is for accessing the font panel in CFM apps

#include <AEDataModel.h>

// Can't include FontPanel.h and HIObject.h because they
// use framework-style includes

typedef struct OpaqueHIObjectRef*       HIObjectRef;

enum {
  kEventClassFont               = 'font'
};

enum {
  kEventFontPanelClosed         = 1,
  kEventFontSelection           = 2
};

enum {
  typeATSUFontID                = typeUInt32, /* ATSUI font ID.*/
  typeATSUSize                  = typeFixed, /* ATSUI font size.*/
  typeFMFontFamily              = typeSInt16, /* Font family reference.*/
  typeFMFontStyle               = typeSInt16, /* Quickdraw font style*/
  typeFMFontSize                = typeSInt16, /* Integer font size.*/
  typeFontColor                 = typeRGBColor, /* Font color spec (optional).*/
  kEventParamATSUFontID         = 'auid', /* typeATSUFontID*/
  kEventParamATSUFontSize       = 'ausz', /* typeATSUSize*/
  kEventParamFMFontFamily       = 'fmfm', /* typeFMFontFamily*/
  kEventParamFMFontStyle        = 'fmst', /* typeFMFontStyle*/
  kEventParamFMFontSize         = 'fmsz', /* typeFMFontSize*/
  kEventParamFontColor          = 'fclr' /* typeFontColor*/
};

enum {
  kHICommandShowHideFontPanel   = 'shfp'
};

enum {
  kFontSelectionATSUIType       = 'astl', /* Use ATSUIStyle collection.*/
  kFontSelectionQDType          = 'qstl' /* Use FontSelectionQDStyle record.*/
};

struct FontSelectionQDStyle {
  UInt32              version;                /* Version number of struct.*/
  FMFontFamilyInstance  instance;             /* Font instance data.*/
  FMFontSize          size;                   /* Size of font in points.*/
  Boolean             hasColor;               /* true if color info supplied.*/
  UInt8               reserved;               /* Filler byte.*/
  RGBColor            color;                  /* Color specification for font.*/
};
typedef struct FontSelectionQDStyle     FontSelectionQDStyle;
typedef FontSelectionQDStyle *          FontSelectionQDStylePtr;

enum {
  kFontSelectionQDStyleVersionZero = 0
};

OSStatus
FPShowHideFontPanel();

Boolean
FPIsFontPanelVisible();

OSStatus
SetFontInfoForSelection(
		OSType inStyleType,
		UInt32 inNumStyles,
		void *inStyles,
		HIObjectRef inFPEventTarget);
