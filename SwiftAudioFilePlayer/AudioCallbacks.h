//
//  AudioCallbacks.h
//  SwiftAudioFilePlayer
//
//  Created by Joel Perry on 2/8/15.
//  Copyright (c) 2015 Joel Perry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface AudioCallbacks : NSObject

void registerCallbackForAU(AudioUnit unit, void *inRefCon);

@end
