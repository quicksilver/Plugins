/*
 *  MTAudioBufferListUtils.h
 *  MTCoreAudio
 *
 *  Created by Michael Thornburgh on Fri Apr 02 2004.
 *  Copyright (c) 2004 Michael Thornburgh. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudio.h>

AudioBufferList * MTAudioBufferListNew ( unsigned channels, unsigned frames, Boolean interleaved );
void MTAudioBufferListDispose ( AudioBufferList * aList );
unsigned MTAudioBufferListCopy ( const AudioBufferList * src, unsigned srcOffset, AudioBufferList * dst, unsigned dstOffset, unsigned count );
unsigned MTAudioBufferListClear ( AudioBufferList * aList, unsigned offset, unsigned count );
unsigned MTAudioBufferListFrameCount ( const AudioBufferList * buf );
unsigned MTAudioBufferListChannelCount ( const AudioBufferList * buf );
