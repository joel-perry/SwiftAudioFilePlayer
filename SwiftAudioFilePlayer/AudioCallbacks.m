//
//  AudioCallbacks.m
//  SwiftAudioFilePlayer
//
//  Created by Joel Perry on 2/8/15.
//  Copyright (c) 2015 Joel Perry. All rights reserved.
//

#import "AudioCallbacks.h"

@implementation AudioCallbacks

AudioTimeStamp _stamp;
UInt32 _stampSize = sizeof(AudioTimeStamp);

OSStatus renderCallback(void *inRefCon,
                            AudioUnitRenderActionFlags *actionFlags,
                            const AudioTimeStamp *inTimeStamp,
                            UInt32 inBusNumber,
                            UInt32 inNumberFrames,
                            AudioBufferList *ioData) {
    
    printf("render\t");
    return 0;
}

void registerCallbackForAU(AudioUnit unit, void *inRefCon) {
    AudioUnitAddRenderNotify(unit, renderCallback, inRefCon);
}

@end
