//
//  ExternalInputManager.m
//  SoundScaper
//
//  Created by Furuyama Yuuki on 2/23/14.
//  Copyright (c) 2014 Furuyama Yuuki. All rights reserved.
//

#import "ExternalInputManager.h"

static void AudioInputCallback(void* inUserData,
                               AudioQueueRef inAQ,
                               AudioQueueBufferRef inBuffer,
                               const AudioTimeStamp *inStartTime,
                               UInt32 inNumberPacketDescriptions,
                               const AudioStreamPacketDescription *inPacketDescs)
{
}

@implementation ExternalInputManager

- (id) init
{
    self = [super init];
    
    if (!self) return nil;
    [self initMicInput];
    
    return self;
}

- (void)initMicInput
{
    AudioStreamBasicDescription description;
    description.mSampleRate = 44100.0f;
    description.mFormatID = kAudioFormatLinearPCM;
    description.mFormatFlags = kLinearPCMFormatFlagIsBigEndian |
                               kLinearPCMFormatFlagIsSignedInteger |
                               kLinearPCMFormatFlagIsPacked;
    description.mBytesPerPacket = 2;
    description.mFramesPerPacket = 1;
    description.mBytesPerFrame = 2;
    description.mChannelsPerFrame = 1;
    description.mBitsPerChannel = 16;
    description.mReserved = 0;
    
    AudioQueueNewInput(&description, AudioInputCallback, (__bridge void*)(self), CFRunLoopGetCurrent(), kCFRunLoopCommonModes, 0, &queue);
    AudioQueueStart(queue, NULL);
    
    UInt32 levelMeterEnabled = true;
    AudioQueueSetProperty(queue, kAudioQueueProperty_EnableLevelMetering, &levelMeterEnabled, sizeof(levelMeterEnabled));
}

- (Float32)getExternalInputLevel
{
    AudioQueueLevelMeterState levelMeter;
    UInt32 levelMeterSize = sizeof(levelMeter);
    AudioQueueGetProperty(queue, kAudioQueueProperty_CurrentLevelMeterDB, &levelMeter, &levelMeterSize);
    NSLog(@"mAveragePower: %0.9f, mPeakPower: %0.9f", levelMeter.mAveragePower, levelMeter.mPeakPower);
    
    // maybe mAveragePower < 0
    return levelMeter.mAveragePower;
}

@end
