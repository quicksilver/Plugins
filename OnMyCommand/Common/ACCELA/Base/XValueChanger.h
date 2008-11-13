// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

template <class T>
class XValueChanger
{
public:
		XValueChanger(
				T &ioVariable,
				const T &inNewValue)
		: mVariable(ioVariable),
		  mOldValue(ioVariable)
		{
			ioVariable = inNewValue;
		}
		~XValueChanger()
		{
			mVariable = mOldValue;
		}

protected:
	T &mVariable;
	T mOldValue;
};
