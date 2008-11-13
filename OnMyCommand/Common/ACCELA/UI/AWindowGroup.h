#include "XRefCountObject.h"

#include "CThrownResult.h"

class AWindowGroup :
		public XRefCountObject<WindowGroupRef>
{
public:
	explicit
		AWindowGroup(
				WindowGroupAttributes inAttributes);
	explicit
		AWindowGroup(
				WindowRef inWindow)
		: XRefCountObject(::GetWindowGroup(inWindow)) {}
		AWindowGroup(
				WindowGroupRef inGroup)
		: XRefCountObject(inGroup) {}
	
	// since WindowGroupAttributes and WindowClass are the same type...
	static AWindowGroup
		GetClassGroup(
				WindowClass inClass);
	
	// Name
	void
		SetName(
				CFStringRef inName);
	CFStringRef
		CopyName() const;
	
	// Attributes
	WindowGroupAttributes
		GetAttributes() const;
	void
		ChangeAttributes(
				WindowGroupAttributes inSet,
				WindowGroupAttributes inClear);
	
	// Ordering
	void
		SetLevel(
				SInt32 inLevel);
	SInt32
		GetLevel() const;
	void
		SendBehind(
				WindowGroupRef inBehind);
	
	// Hierarchy
	void
		AddWindow(
				WindowRef inWindow);
	bool
		ContainsWindow(
				WindowRef inWindow) const;
	WindowGroupRef
		GetParent() const;
	void
		SetParent(
				WindowGroupRef inParent);
	WindowGroupRef
		GetSibling(
				bool inGetNext) const;
	WindowRef
		GetOwner() const;
	void
		SetOwner(
				WindowRef inWindow);
	
	// Contents
	ItemCount
		CountContents(
				WindowGroupContentOptions inOptions) const;
	void
		GetContents(
				WindowGroupContentOptions inOptions,
				ItemCount inAllowedItems,
				ItemCount &outNumItems,
				void **outItems) const;
	void
		GetContents(
				WindowGroupContentOptions inOptions,
				ItemCount inAllowedItems,
				void **outItems) const;
	WindowRef
		GetIndWindow(
				UInt32 inIndex,
				WindowGroupContentOptions inOptions = kNilOptions) const;
	UInt32
		GetWindowIndex(
				WindowRef inWindow,
				WindowGroupContentOptions inOptions = kNilOptions) const;
	
	// Debugging
	void
		DebugPrint() const;
};

// ---------------------------------------------------------------------------

inline
AWindowGroup::AWindowGroup(
		WindowGroupAttributes inAttributes)
{
	CThrownOSStatus err = ::CreateWindowGroup(inAttributes,&mObjectRef);
}

inline AWindowGroup
AWindowGroup::GetClassGroup(
		WindowClass inClass)
{
	return AWindowGroup(::GetWindowGroupOfClass(inClass));
}

inline void
AWindowGroup::SetName(
		CFStringRef inName)
{
	CThrownOSStatus err = ::SetWindowGroupName(*this,inName);
}

inline CFStringRef
AWindowGroup::CopyName() const
{
	CFStringRef name;
	CThrownOSStatus err = ::CopyWindowGroupName(*this,&name);
	return name;
}

inline WindowGroupAttributes
AWindowGroup::GetAttributes() const
{
	WindowGroupAttributes attr;
	CThrownOSStatus err = ::GetWindowGroupAttributes(*this,&attr);
	return attr;
}

inline void
AWindowGroup::ChangeAttributes(
		WindowGroupAttributes inSet,
		WindowGroupAttributes inClear)
{
	CThrownOSStatus err = ::ChangeWindowGroupAttributes(*this,inSet,inClear);
}

inline void
AWindowGroup::SetLevel(
		SInt32 inLevel)
{
	CThrownOSStatus err = ::SetWindowGroupLevel(*this,inLevel);
}

inline SInt32
AWindowGroup::GetLevel() const
{
	SInt32 level;
	CThrownOSStatus err = ::GetWindowGroupLevel(*this,&level);
	return level;
}

inline void
AWindowGroup::SendBehind(
		WindowGroupRef inBehind)
{
	CThrownOSStatus err = ::SendWindowGroupBehind(*this,inBehind);
}

inline void
AWindowGroup::AddWindow(
		WindowRef inWindow)
{
	CThrownOSStatus err = ::SetWindowGroup(inWindow,*this);
}

inline bool
AWindowGroup::ContainsWindow(
		WindowRef inWindow) const
{
	return ::IsWindowContainedInGroup(inWindow,*this);
}

inline WindowGroupRef
AWindowGroup::GetParent() const
{
	return ::GetWindowGroupParent(*this);
}

inline void
AWindowGroup::SetParent(
		WindowGroupRef inParent)
{
	CThrownOSStatus err = ::SetWindowGroupParent(*this,inParent);
}

inline WindowGroupRef
AWindowGroup::GetSibling(
		bool inGetNext) const
{
	return ::GetWindowGroupSibling(*this,inGetNext);
}

inline WindowRef
AWindowGroup::GetOwner() const
{
	return ::GetWindowGroupOwner(*this);
}

inline void
AWindowGroup::SetOwner(
		WindowRef inWindow)
{
	CThrownOSStatus err = ::SetWindowGroupOwner(*this,inWindow);
}

inline ItemCount
AWindowGroup::CountContents(
		WindowGroupContentOptions inOptions) const
{
	return ::CountWindowGroupContents(*this,inOptions);
}

inline void
AWindowGroup::GetContents(
		WindowGroupContentOptions inOptions,
		ItemCount inAllowedItems,
		ItemCount &outNumItems,
		inline void **outItems) const
{
	CThrownOSStatus err = ::GetWindowGroupContents(*this,inOptions,inAllowedItems,&outNumItems,outItems);
}

inline void
AWindowGroup::GetContents(
		WindowGroupContentOptions inOptions,
		ItemCount inAllowedItems,
		void **outItems) const
{
	CThrownOSStatus err = ::GetWindowGroupContents(*this,inOptions,inAllowedItems,NULL,outItems);
}

inline WindowRef
AWindowGroup::GetIndWindow(
		UInt32 inIndex,
		WindowGroupContentOptions inOptions) const
{
	WindowRef window;
	CThrownOSStatus err = ::GetIndexedWindow(*this,inIndex,inOptions,&window);
	return window;
}

inline UInt32
AWindowGroup::GetWindowIndex(
		WindowRef inWindow,
		WindowGroupContentOptions inOptions) const
{
	UInt32 index;
	CThrownOSStatus err = ::GetWindowIndex(inWindow,*this,inOptions,&index);
	return index;
}

inline void
AWindowGroup::DebugPrint() const
{
	::DebugPrintWindowGroup(*this);
}

// ---------------------------------------------------------------------------

inline void
XRefCountObject<WindowGroupRef>::Retain()
{
	CThrownOSStatus err = ::RetainWindowGroup(*this);
}

inline void
XRefCountObject<WindowGroupRef>::Release()
{
	::ReleaseWindowGroup(*this);
}

inline UInt32
XRefCountObject<WindowGroupRef>::GetRetainCount() const
{
	return ::GetWindowGroupRetainCount(*this);
}
