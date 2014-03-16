//
//  FFTAnalyzer.h
//  SoundScaper
//
//  Created by Furuyama Yuuki on 3/16/14.
//  Copyright (c) 2014 Furuyama Yuuki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>

@interface FFTAnalyzer : NSObject

- (int)getMaxFreq:(float *)inData length:(int)length;

@end
