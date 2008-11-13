#include "AControlHandler.h"
#include "ATextInputHandler.h"
#include "AControls.h"
#include "AWASTE.h"

class AWASTEControl :
		public AControlHandler,
		public ATextInputHandler
{
public:
		AWASTEControl(
				ControlRef inControl,
				OptionBits inOptions);
	
	void
		TrackScrollBar(
				ControlPartCode inPart);
	void
		AdjustScrollBar();
	
protected:
	class WScrollBar :
			public AScrollBar
	{
	public:
			WScrollBar(
					AWASTEControl &inWASTEControl,
					AControl &inControl);
		
	protected:
		AWASTEControl &mWASTEControl;
		
		void
			Action(
					ControlPartCode inPart)
			{
				mWASTEControl.TrackScrollBar(inPart);
			}
		
		static Rect
			ScrollBarRect(
					const AControl &inControl);
	};
	
	StHandleEventTypes mControlTypes,mTextTypes;
	AControl mControl;
 	AWASTE mEditor;
 	WScrollBar mScrollBar;
 	UInt16 mLineHeight;
 	
 	// AControlHandler
 	
	virtual bool
		BoundsChanged(
				UInt32 inAttributes,
				const Rect &inOriginalBounds,
				const Rect &inPreviousBounds,
				const Rect &inCurrentBounds);
	virtual bool
		Draw(
				const AParam<>::ControlPart &inPart,
				const AParam<>::Port &inGrafPort);
	virtual bool
		Activate();
	virtual bool
		Deactivate();
	virtual bool
		SetCursor(
				Point inMouse,
				UInt32 inModifiers);
	virtual bool
		Click(
				Point inMouse,
				UInt32 inModifiers);
	virtual bool
		DragEnter(
				DragRef inDragRef);
	virtual bool
		DragWithin(
				DragRef inDragRef);
	virtual bool
		DragLeave(
				DragRef inDragRef);
	virtual bool
		DragReceive(
				DragRef inDragRef);
	
	// ATextInputHandler
	
	virtual bool
		UnicodeForKeyEvent(
				ComponentInstance inComponent,
				long inRefCon,
				const ScriptLanguageRecord &inScript,
				const UniChar *inText,
				Size inTextSize,
				EventRef inKeyboardEvent);
	
	// AWASTEControl
	
	virtual void
		PostDraw();
};
