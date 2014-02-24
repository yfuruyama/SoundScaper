//
//  AudioHost.m
//  SoundScaper
//
//  Created by Furuyama Yuuki on 2/23/14.
//  Copyright (c) 2014 Furuyama Yuuki. All rights reserved.
//

#import "AudioHost.h"

#define NOTE_INTERVAL 0.25
#define BASE_VELOCITY 64

@implementation AudioHost

@synthesize graphSampleRate;
@synthesize mixerUnit;
@synthesize iOUnit;
@synthesize samplerUnit;

- (id)init
{
    self = [super init];
    
    if (!self) return nil;
    
    [self setupAudioSession];
    [self configureAndInitializeAudioProcessingGraph];
    
    self.externalInputManager = [[ExternalInputManager alloc] init];
    self.noteGenerator = [[NoteGenerator alloc] init];
    
    
    return self;
}

- (void)setupAudioSession
{
    NSError *audioSessionError = nil;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setDelegate:self];
    
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&audioSessionError];
    
    OSStatus propertySetError = 0;
    UInt32 allowMixing = true;
    propertySetError = AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryMixWithOthers,
                                               sizeof(allowMixing),
                                               &allowMixing
                                               );
    
    //[audioSession setCategory:AVAudioSessionCategoryAmbient error:&audioSessionError];
    
    if (audioSessionError != nil) {
        NSLog(@"Error setting audio session category.");
        return;
    }
    
    // Sample rate = 44.1kHz
    self.graphSampleRate = 44100.0;
    [audioSession setPreferredHardwareSampleRate:graphSampleRate
                                           error:&audioSessionError];
    
    if (audioSessionError != nil) {
        NSLog(@"Error setting preferred hardware sample rate.");
        return;
    }
    
    [audioSession setActive:YES
                      error:&audioSessionError];
    
    if (audioSessionError != nil) {
        NSLog(@"Error activating audio session during initial setup.");
        return;
    }
    
    // このsample rateは後でaudio processing graphで使う
    self.graphSampleRate = [audioSession currentHardwareSampleRate];
    
}


#pragma mark -
#pragma mark Audio Processing Graph setup
- (void)configureAndInitializeAudioProcessingGraph
{
    NSLog(@"Configuring and then initializing audio processing graph");
    OSStatus result = noErr;
    
    result = NewAUGraph(&processingGraph);
    if (result != noErr) {
        [self printErrorMessage:@"NewAUGraph" withStatus:result];
        return;
    }
    
    AudioComponentDescription samplerUnitDescription;
    samplerUnitDescription.componentType = kAudioUnitType_MusicDevice;
    samplerUnitDescription.componentSubType = kAudioUnitSubType_Sampler;
    samplerUnitDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    samplerUnitDescription.componentFlags = 0;
    samplerUnitDescription.componentFlagsMask = 0;
    
    AudioComponentDescription mixerUnitDescription;
    mixerUnitDescription.componentType = kAudioUnitType_Mixer;
    mixerUnitDescription.componentSubType = kAudioUnitSubType_MultiChannelMixer;
    mixerUnitDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    mixerUnitDescription.componentFlags = 0;
    mixerUnitDescription.componentFlagsMask = 0;
    
    AudioComponentDescription iOUnitDescription;
    iOUnitDescription.componentType = kAudioUnitType_Output;
    iOUnitDescription.componentSubType = kAudioUnitSubType_RemoteIO;
    iOUnitDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    iOUnitDescription.componentFlags = 0;
    iOUnitDescription.componentFlagsMask = 0;
    
    
    AUNode samplerNode;
    AUNode mixerNode;
    AUNode iONode;
    
    result = AUGraphAddNode(processingGraph, &samplerUnitDescription, &samplerNode);
    if (result != noErr) {
        [self printErrorMessage:@"AUGraphNewNode failed for Sampler unit" withStatus:result];
        return;
    }
    
    result = AUGraphAddNode(processingGraph, &mixerUnitDescription, &mixerNode);
    if (result != noErr) {
        [self printErrorMessage:@"AUGraphNewNode failed for Mixer unit" withStatus:result];
        return;
    }
    
    result = AUGraphAddNode(processingGraph, &iOUnitDescription, &iONode);
    if (result != noErr) {
        [self printErrorMessage:@"AUGraphNewNode failed for I/O unit" withStatus:result];
        return;
    }
    
    
    // AUGraphのインスタンス化
    result = AUGraphOpen(processingGraph);
    if (result != noErr) {
        [self printErrorMessage:@"AUGraphOpen" withStatus:result];
        return;
    }
    
    AUGraphNodeInfo(processingGraph, samplerNode, NULL, &samplerUnit);
    AUGraphNodeInfo(processingGraph, mixerNode, NULL, &mixerUnit);
    AUGraphNodeInfo(processingGraph, iONode, NULL, &iOUnit);
    
    UInt32 busCount = 1;
    
    // MixerUnitにバス数の設定
    AudioUnitSetProperty(mixerUnit,
                         kAudioUnitProperty_ElementCount,
                         kAudioUnitScope_Input,
                         0,
                         &busCount,
                         sizeof(busCount)
                         );
    
    
    UInt32 maximumFramesPerSlice = 4096;
    AudioUnitSetProperty(mixerUnit,
                         kAudioUnitProperty_MaximumFramesPerSlice,
                         kAudioUnitScope_Global,
                         0,
                         &maximumFramesPerSlice,
                         sizeof(maximumFramesPerSlice)
                         );
    
    
    result = AudioUnitSetProperty(mixerUnit,
                                  kAudioUnitProperty_SampleRate,
                                  kAudioUnitScope_Output,
                                  0,
                                  &graphSampleRate,
                                  sizeof(graphSampleRate)
                                  );
    if (result != noErr) {
        [self printErrorMessage:@"MixerUnit sampleRate" withStatus:result];
        return;
    }
    
    /*
    各Nodeを繋げる
     
     |--------------|     |--------------------|       |---------------------------|
     | Sampler Unit |---->| Multichannel Mixer |-----> | Remote I/O output element |----> Hardware Output
     |--------------|     |--------------------|       |---------------------------|
     
     */
    
    result = AUGraphConnectNodeInput(processingGraph,
                                     samplerNode,
                                     0,
                                     mixerNode,
                                     0
                                     );
    if (result != noErr) {
        [self printErrorMessage:@"Connect from SamplerNode to MixerNode" withStatus:result];
        return;
    }
    
    result = AUGraphConnectNodeInput(processingGraph,
                                     mixerNode,
                                     0,
                                     iONode,
                                     0
                                     );
    if (result != noErr) {
        [self printErrorMessage:@"Connect from MixerNode to IONode" withStatus:result];
        return;
    }
    
    CAShow(processingGraph);
    
    NSLog(@"Initialize the audio processing graph.");
    result = AUGraphInitialize(processingGraph);
    if (result != noErr) {
        [self printErrorMessage:@"AUGraphInitialize" withStatus:result];
        return;
    }
    
    [self startAUGraph];
}

#pragma mark -
#pragma mark Playback control

- (void)startAUGraph
{
    NSLog(@"start audio processing graph");
    OSStatus result = AUGraphStart(processingGraph);
    if (result != noErr) {
        [self printErrorMessage:@"AUGraphStart" withStatus:result];
        return;
    }
}

- (void)stopAUGraph
{
    NSLog(@"stop audio processing graph");
    
    Boolean isRunning = false;
    AUGraphIsRunning(processingGraph, &isRunning);
    
    if (isRunning) {
        AUGraphStop(processingGraph);
    }
}

- (void)playNoteOn:(UInt32)noteNum velocity:(UInt32)velocity
{
    UInt32 noteCommand = 0x90; // MIDI note on message for channel 0
    MusicDeviceMIDIEvent(self.samplerUnit, noteCommand, noteNum, velocity, 0);
}

- (void)playNoteOff:(UInt32)noteNum velocity:(UInt32)velocity
{
    UInt32 noteCommand = 0x80; // MIDI note off message for channel 0
    MusicDeviceMIDIEvent(self.samplerUnit, noteCommand, noteNum, velocity, 0);
}

- (void)play
{
    self.playTimer = [NSTimer scheduledTimerWithTimeInterval:NOTE_INTERVAL target:self selector:@selector(soundNote) userInfo:nil repeats:YES];
}

- (void)pause
{
    if (self.playTimer && [self.playTimer isValid]) {
        [self.playTimer invalidate];
    }
    self.playTimer = nil;
}

- (BOOL)isPlaying
{
    if (self.playTimer && [self.playTimer isValid]) {
        return TRUE;
    } else {
        return FALSE;
    }
}

- (void)soundNote
{
    Float32 micLevel = [self.externalInputManager getExternalInputLevel];
    int noteIndex = [self.noteGenerator micLevelToNoteIndex:micLevel];
    NSLog(@"noteIndex: %d", noteIndex);
    
    UInt32 velocity = BASE_VELOCITY + [self.noteGenerator getVelocityWeight];
    
    // send note-on message
    UInt32 noteNum = [self.noteGenerator getNote:noteIndex];
    [self playNoteOn:noteNum velocity:velocity];
    
    // send note-off message after some delay
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(playNoteOff:velocity:)]];
    [invocation setSelector:@selector(playNoteOff:velocity:)];
    [invocation setTarget:self];
    [invocation setArgument:&noteNum atIndex:2];
    [invocation setArgument:&velocity atIndex:3];
    [NSTimer scheduledTimerWithTimeInterval:NOTE_INTERVAL - 0.05 invocation:invocation repeats:NO];
}

- (void)changeScale:(int)startNoteIndex type:(int)scaleType
{
    if ([self isPlaying]) {
        [self pause];
        [self.noteGenerator setScale:startNoteIndex type:scaleType];
        [self play];
    } else {
        [self.noteGenerator setScale:startNoteIndex type:scaleType];
    }
}

#pragma mark -
#pragma mark Utility methods

- (void)printASBD:(AudioStreamBasicDescription)asbd
{
    char formatIDString[5];
    UInt32 formatID = CFSwapInt32HostToBig(asbd.mFormatID);
    bcopy(&formatID, formatIDString, 4);
    formatIDString[4] = '\0';
    
    NSLog(@"Sample Rate:          %10.0f", asbd.mSampleRate);
    NSLog(@"Format ID:            %10s", formatIDString);
    NSLog(@"Format Flags:         %10lu", asbd.mFormatFlags);
    NSLog(@"Bytes per Packet:     %10lu", asbd.mBytesPerPacket);
    NSLog(@"Frames per Packet:    %10lu", asbd.mFramesPerPacket);
    NSLog(@"Bytes per Frame:      %10lu", asbd.mBytesPerFrame);
    NSLog(@"Channels per Frame:   %10lu", asbd.mChannelsPerFrame);
    NSLog(@"Bits per Channel:     %10lu", asbd.mBitsPerChannel);
}

- (void) printErrorMessage: (NSString *) errorString withStatus: (OSStatus) result {
    
    char resultString[5];
    UInt32 swappedResult = CFSwapInt32HostToBig (result);
    bcopy (&swappedResult, resultString, 4);
    resultString[4] = '\0';
    
    NSLog (
           @"*** %@ error: %d %08X %4.4s\n",
           errorString,
           (char*) &resultString
           );
}

@end
