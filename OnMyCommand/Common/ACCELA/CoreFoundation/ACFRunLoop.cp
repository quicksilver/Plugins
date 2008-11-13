#include "ACFRunLoop.h"

void
ACFRunLoop::Observer::Callback(
		CFRunLoopObserverRef inObserver,
		CFRunLoopActivity inActivity,
		void *inInfo)
{
	ACFRunLoop::Observer *observer = (ACFRunLoop::Observer*)inInfo;
	
	observer->Observe(inActivity);
}

