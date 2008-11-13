#include "FW.h"

#include FW(Carbon,Navigation.h)

class ANavTypeList
{
public:
		ANavTypeList(
				OSType inSignature);
		ANavTypeList(
				OSType inSignature,
				OSType inType);
		ANavTypeList(
				OSType inSignature,
				short inCount,
				OSType *inTypes);
	virtual
		~ANavTypeList();
	
		operator NavTypeListHandle()
		{ return mTypeList; }
	
	void
		AddType(
				OSType inType);
	void
		AddTypes(
				short inCount,
				OSType *inTypes);
	
protected:
	NavTypeListHandle mTypeList;
};
