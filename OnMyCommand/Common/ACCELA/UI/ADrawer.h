#include "AWindow.h"

// ---------------------------------------------------------------------------

class ADrawer :
		public AWindow
{
public:
		// WindowRef
		ADrawer(
				WindowRef inWindow,
				bool inDoRetain = true)
		: AWindow(inWindow,inDoRetain) {}
		// nib
		ADrawer(
				IBNibRef inNib,
				CFStringRef inName)
		: AWindow(inNib,inName) {}
		// resource
		ADrawer(
				SInt16 inID,
				WindowRef inBehindWindow = (WindowRef)-1L);
		: AWindow(inID,inBehindWindow) {}
	
	OptionBits
		PreferredEdge() const;
	void
		SetPreferredEdge(
				OptionBits inEdge);
	OptionBits
		CurrentEdge() const;
	
	WindowDrawerState
		State() const;
	
	WindowRef
		Parent() const;
	void
		SetParent(
				WindowRef inParent);
	
	void
		SetOffsets(
				float inLeading,
				float inTrailing = kWindowOffsetUnchanged);
	void
		GetDrawerOffsets(
				float *inLeading,
				float *inTrailing = NULL);
	
	void
		Toggle();
	void
		Open(
				OptionBits inEdge = kWindowEdgeDefault,
				bool inAsync = true);
	void
		Close(
				bool inAsync = true);
};

// ---------------------------------------------------------------------------

inline OptionBits
ADrawer::PreferredEdge() const
{
	return ::GetDrawerPreferredEdge(*this);
}

inline void
ADrawer::SetPreferredEdge(
		OptionBits inEdge)
{
	CThrownOSStatus err = ::SetDrawerPreferredEdge(*this,inEdge);
}

inline OptionBits
ADrawer::CurrentEdge() const
{
	return ::GetDrawerCurrentEdge(*this);
}

inline WindowDrawerState
ADrawer::State() const
{
	return ::GetDrawerState(*this);
}

inline WindowRef
ADrawer::Parent() const
{
	return ::GetDrawerParent(*this);
}

inline void
ADrawer::SetParent(
		WindowRef inParent)
{
	CThrownOSStatus err = ::SetDrawerParent(*this,inParent);
}

inline void
ADrawer::SetOffsets(
		float inLeading,
		float inTrailing)
{
	CThrownOSStatus err = ::SetDrawerOffsets(*this,inLeading,inTrailing);
}

inline void
ADrawer::GetDrawerOffsets(
		float *inLeading,
		float *inTrailing)
{
	CThrownOSStatus err = ::GetDrawerOffsets(*this,inLeading,inTrailing);
}

inline void
ADrawer::Toggle()
{
	CThrownOSStatus err = ::ToggleDrawer(*this);
}

inline void
ADrawer::Open(
		OptionBits inEdge,
		bool inAsync)
{
	CThrownOSStatus err = ::OpenDrawer(*this,inEdge,inAsync);
}

inline void
ADrawer::Close(
		bool inAsync)
{
	CThrownOSStatus err = ::CloseDrawer(*this,inAsync);
}
