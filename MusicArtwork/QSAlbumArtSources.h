/*
 *  untitled.h
 *  Quicksilver
 *
 *  Created by Nicholas Jitkoff on 7/3/04.
 *  Copyright 2004 __MyCompanyName__. All rights reserved.
 *
 */

#define SYNPATH [@"~/Library/Application Support/Synergy/Album Covers/" stringByStandardizingPath]
#define SOFPATH [@"~/Library/Application Support/Sofa/Artworks/" stringByStandardizingPath]
#define CLUTPATH [@"~/Library/Images/com.sprote.clutter/CDs/" stringByStandardizingPath]


NSImage * imageForSofaTrack(NSString *artist,NSString *album);
NSImage *imageForSynergyTrack(NSString *artist,NSString *album,NSString *name);
NSImage *imageForClutterTrack(NSString *artist,NSString *album);
NSImage *imageForCommonTrack(NSString *artist,NSString *album,NSNumber *compilation);
