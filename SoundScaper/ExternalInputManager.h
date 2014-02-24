//
//  ExternalInputManager.h
//  SoundScaper
//
//  Created by Furuyama Yuuki on 2/23/14.
//  Copyright (c) 2014 Furuyama Yuuki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface ExternalInputManager : NSObject {
    AudioQueueRef queue;
}

//@property AudioQueueRef queue;

- (Float32)getExternalInputLevel;

@end
