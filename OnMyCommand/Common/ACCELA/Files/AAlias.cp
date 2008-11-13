// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#include "AAlias.h"
#include "AAEDesc.h"

// ---------------------------------------------------------------------------

AAlias::AAlias(
		const AEDesc &inDesc)
{
	const AAEDesc aliasDesc(typeAlias,inDesc);
	const Size aliasSize = aliasDesc.DataSize();
	
	mObject = (AliasHandle) ::NewHandle(aliasSize);
	aliasDesc.GetDescData(*mObject,aliasSize);
}
