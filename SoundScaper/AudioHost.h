//
//  AudioHost.h
//  SoundScaper
//
//  Created by Furuyama Yuuki on 2/23/14.
//  Copyright (c) 2014 Furuyama Yuuki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface AudioHost : NSObject <AVAudioSessionDelegate> {
    Float64 graphSampleRate;
    CFURLRef sourceSoundURL;
    AUGraph processingGraph;
    AudioUnit mixerUnit;
    AudioUnit iOUnit;
    AudioUnit samplerUnit;
    CFURLRef midiURLRef;
    MusicPlayer musicPlayer;
}

@property (readwrite) Float64 graphSampleRate;
@property (readwrite) AudioStreamBasicDescription stereoStreamFormat;
@property AudioUnit mixerUnit;
@property AudioUnit iOUnit;
@property AudioUnit samplerUnit;

- (void)playNoteOn:(UInt32)noteNum velocity:(UInt32)velocity;
- (void)playNoteOff:(UInt32)noteNum velocity:(UInt32)velocity;

@end
