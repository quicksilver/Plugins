/* DesktopManager -- A virtual desktop provider for OS X
 *
 * Copyright (C) 2003, 2004 Richard J Wareham <richwareham@users.sourceforge.net>
 * This program is free software; you can redistribute it and/or modify it 
 * under the terms of the GNU General Public License as published by the Free 
 * Software Foundation; either version 2 of the License, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but 
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY 
 * or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License 
 * for more details.
 *
 * You should have received a copy of the GNU General Public License along 
 * with this program; if not, write to the Free Software Foundation, Inc., 675 
 * Mass Ave, Cambridge, MA 02139, USA.
 */

#import "couvert.h"

#import "DesktopManager.h"

#import <syslog.h>
#import <unistd.h>
#import <sys/time.h>
#import <math.h>

static struct timeval startTime;

void startAnimation() {
	gettimeofday(&startTime, NULL);
}

#define PI 3.1415925

float animationCoordinate(float duration) {
	struct timeval now;
	gettimeofday(&now, NULL);
	
	// Elapsed time in microseconds.
	float elapsedTime = ((float)(now.tv_sec - startTime.tv_sec) * 1000.0) +
		((float)(now.tv_usec - startTime.tv_usec)/1000.0);
	
	if(elapsedTime >= duration) { return 1.0; }
	
	return 0.5 - (0.5 * cos(PI * elapsedTime/duration));
}

void getWorkspaceWindows(CGSConnection connection, int workspace,
	CGSWindow **_windowArray, CGAffineTransform **_transformArray,
	int *_numWindows) {
	int windows = -1;
	CGSGetWorkspaceWindowCount(connection, workspace, &windows);
	//syslog(LOG_WARNING, "Workspace has %i windows", windows);
	
	CGSWindow *windowList = malloc(windows * sizeof(CGSWindow) + 1);
	_transformArray[0] = malloc(windows * sizeof(CGAffineTransform) + 1);
	CGSGetWorkspaceWindowList(connection,workspace,windows,windowList,&windows);
	_windowArray[0] = malloc(windows * sizeof(CGSWindow));
	
	int i = 0; _numWindows[0] = 0;
	for(i=0; i<windows; i++) {
		CGSWindow wid = windowList[i];
		int level = -1;
		CGSGetWindowLevel(connection, wid, &level);
		if(level == kCGNormalWindowLevel) {
			_windowArray[0][(_numWindows[0])] = wid;
			CGSGetWindowTransform(connection, wid, &(_transformArray[0][(_numWindows[0])]));
			
			_numWindows[0] ++;
		}
	}
	//
	//syslog(LOG_WARNING, "Found %i non-floating windows", _numWindows[0]);
}

CGAffineTransform CGAffineTransformInterpolate(CGAffineTransform from, CGAffineTransform to, float lambda) {
	CGAffineTransform transform;
	float mu= 1.0 - lambda;
	transform.a = lambda * to.a + mu * from.a;
	transform.b = lambda * to.b + mu * from.b;
	transform.c = lambda * to.c + mu * from.c;
	transform.d = lambda * to.d + mu * from.d;
	transform.tx = lambda * to.tx + mu * from.tx;
	transform.ty = lambda * to.ty + mu * from.ty;
	return transform;
}

#define DURATION 500.0

static int haveArranged = 0;

static int **windowLists = NULL;
static CGAffineTransform **transformLists = NULL;
static int *counts = NULL;

static int *numberList = NULL;
static CGAffineTransform *targetList = NULL;
static int count = 0;

void arrangeWindows(int *_numberList, CGAffineTransform *_targetList, int _count) {
	int i,j;
	/* This is some non-trivial code to shoe-horn into the Dock. */

	// Firstly, make sure we don't call this twice without restoring.
	if(haveArranged) { return; }
	
	// Copy our passed lists (for future use).
	count = _count;
	numberList = malloc(count * sizeof(int));
	memcpy(numberList, _numberList, count * sizeof(int));
	targetList = malloc(count * sizeof(CGAffineTransform)); 
	memcpy(targetList, _targetList, count * sizeof(CGAffineTransform));

	// Get the Default connection for CGS...() calls.
	CGSConnection connection = _CGSDefaultConnection();
	
	// Find which workspace we are on....
	int workspace = -1;
	CGSGetWorkspace(connection, &workspace);
	// ...and its index.
	int workspaceIndex = -1;
	for(i=0; i<count; i++) { if(numberList[i] == workspace) { workspaceIndex = i; } }

	// Sanity check.
	if(workspaceIndex == -1) { 
		syslog(LOG_ERR, "Couvert: Passed workspaces didn't include current one");
		return;
	}

	// Set flag
	haveArranged = 1;
	
	// Create our list arrays.
	windowLists = malloc(count * sizeof(int*));
	transformLists = malloc(count * sizeof(int*));
	counts = malloc(count * sizeof(int));
	
	// for each workspace passed...
	for(i=0; i<count; i++) {
		// Get the appropriate window and transform list
		getWorkspaceWindows(connection, numberList[i],
			&(windowLists[i]), &(transformLists[i]), &(counts[i]));
	}
	
	// fopr each workspace...
	for(i=0; i<count; i++) {
		// If it's not the selected one...
		if(i != workspaceIndex) {
			// ...set the alpha for all windows to 0.0
			CGSSetWindowListAlpha(connection, windowLists[i], counts[i], 0.0);
		}

		// Move the windows to the selected workspace.
		if(counts[i]) { CGSMoveWorkspaceWindowList(connection, windowLists[i], counts[i], workspace); }
		
		CGSWindowTag tags[2];
		tags[0] = CGSTagNoShadow; tags[1] = 0;

		for(j=0;j<counts[i];j++) {
			// If not the selected workspace
			if(i != workspaceIndex) {
				// Start off with windows transformed to their targets
				CGSSetWindowTransform(connection, windowLists[i][j], 
					CGAffineTransformConcat(targetList[i], transformLists[i][j]));
			}
			
			// Set all windows to have no shadows.
			CGSSetWindowTags(connection, windowLists[i][j], tags, 32);
		}
	}
	
	// List for anumation transforms
	CGAffineTransform *newTransforms = malloc(counts[workspaceIndex] * sizeof(CGAffineTransform) + 1);
	
	// animation co-ordinate
	float coord;
	
	startAnimation(); // Begin animation
	while((coord = animationCoordinate(DURATION)) < 1.0) {
		// For each workspace
		for(j=0; j<count; j++) {
			// If this is the selected one...
			if(j == workspaceIndex) {
				// ...for each window
				for(i=0;i<counts[j];i++) {
					// Calculate appropriate transform.
					CGAffineTransform windowTarget = 
						CGAffineTransformConcat(targetList[j], transformLists[j][i]);
					newTransforms[i] = CGAffineTransformInterpolate(transformLists[j][i], windowTarget, coord);
				}
				
				// Apply transforms
				if(counts[j]) 
					CGSSetWindowTransforms(connection, windowLists[j], newTransforms, counts[j]);
			} else {
				// ...if not the selected one, set alpha to fade in...
				if(counts[j])
					CGSSetWindowListAlpha(connection, windowLists[j], counts[j], coord);
			}
		}
		
		// Snooze for a bit.
		usleep(5000);
	}
	
	for(i=0; i<count; i++) {
		// Set all windows to be sticky.
		CGSWindowTag tags[2];
		tags[0] = CGSTagSticky; tags[1] = 0;
		for(j=0;j<counts[i];j++) {
			CGSSetWindowTags(connection, windowLists[i][j], tags, 32);
		}
	}
		
	// Finally, set the target transform for each window.
	for(i=0;i<counts[workspaceIndex];i++) {
		CGAffineTransform windowTarget = 
			CGAffineTransformConcat(targetList[workspaceIndex], transformLists[workspaceIndex][i]);
		newTransforms[i] = windowTarget;
	}
	if(counts[workspaceIndex]) 
		CGSSetWindowTransforms(connection, windowLists[workspaceIndex], newTransforms, counts[workspaceIndex]);
				
	free(newTransforms);
}

void restoreWindows() {
	int i,j;
	/* This is some non-trivial code to shoe-horn into the Dock. */

	// Firstly, make sure we don't call this twice without restoring.
	if(!haveArranged) { return; }
	haveArranged = 0;

	// Get the Default connection for CGS...() calls.
	CGSConnection connection = _CGSDefaultConnection();
	
	// Find which workspace we are on....
	int workspace = -1;
	CGSGetWorkspace(connection, &workspace);
	// ...and its index.
	int workspaceIndex = -1;
	for(i=0; i<count; i++) { if(numberList[i] == workspace) { workspaceIndex = i; } }
	
	// Sanity check.
	if(workspaceIndex == -1) { 
		syslog(LOG_ERR, "Couvert: Passed workspaces didn't include current one");
		return;
	}
	
	// Create list of temp animation transforms
	CGAffineTransform *newTransforms = malloc(counts[workspaceIndex] * sizeof(CGAffineTransform) + 1);
	
	// animation co-ordinate.
	float coord;
	
	startAnimation(); // Begin animation
	while((coord = animationCoordinate(DURATION)) < 1.0) {
		for(j=0; j<count; j++) {
			if(j == workspaceIndex) {
				for(i=0;i<counts[j];i++) {
						CGAffineTransform windowTarget = 
							CGAffineTransformConcat(targetList[j], 
							transformLists[j][i]);
						newTransforms[i] = CGAffineTransformInterpolate(windowTarget, 
							transformLists[j][i], coord);
				}
				CGSSetWindowTransforms(connection, windowLists[j], newTransforms, counts[j]);
			} else {
				CGSSetWindowListAlpha(connection, windowLists[j], counts[j], 1.0 - coord);
			}
		}
		usleep(5000);
	}
	
	CGSSetWindowTransforms(connection, windowLists[workspaceIndex], transformLists[workspaceIndex],
		counts[workspaceIndex]);

	for(i=0; i<count; i++) {
		CGSSetWindowTransforms(connection, windowLists[i], transformLists[i], counts[i]);

		CGSWindowTag tags[2];
		tags[0] = CGSTagNoShadow; tags[1] = 0;
		for(j=0;j<counts[i];j++) {
			CGSClearWindowTags(connection, windowLists[i][j], tags, 32);
		}
		tags[0] = CGSTagSticky; tags[1] = 0;
		for(j=0;j<counts[i];j++) {
			CGSClearWindowTags(connection, windowLists[i][j], tags, 32);
		}
		CGSMoveWorkspaceWindowList(connection, windowLists[i], counts[i], numberList[i]);
		
		CGSSetWindowListAlpha(connection, windowLists[i], counts[i], 1.0);
		
		free(windowLists[i]); windowLists[i] = NULL;
		free(transformLists[i]); transformLists[i] = NULL;
		counts[i] = 0;
	}
	
	free(newTransforms);
	free(windowLists); free(transformLists);
	free(numberList); free(targetList); free(counts);
}