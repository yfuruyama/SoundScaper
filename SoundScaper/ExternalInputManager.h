//
//  ExternalInputManager.h
//  SoundScaper
//
//  Created by Furuyama Yuuki on 2/23/14.
//  Copyright (c) 2014 Furuyama Yuuki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "FFTAnalyzer.h"

@interface ExternalInputManager : NSObject {
    AudioQueueRef queue;
    AudioQueueBufferRef micBuffer;
}

- (Float32)getExternalInputLevel;
- (int)getExternalInputMaxFreq;

@property AudioQueueRef queue;
@property AudioQueueBufferRef micBuffer;

@end
