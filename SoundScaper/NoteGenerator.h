//
//  NoteGenerator.h
//  SoundScaper
//
//  Created by Furuyama Yuuki on 2/24/14.
//  Copyright (c) 2014 Furuyama Yuuki. All rights reserved.
//

#import <Foundation/Foundation.h>

enum Scale {
    MAJOR_SCALE = 0,
    MINOR_SCALE,
    OKINAWA_SCALE,
};

@interface NoteGenerator : NSObject

@property NSMutableArray *noteList;

- (int)micLevelToNoteIndex:(Float32)level;
- (void)setScale:(int)startNoteIndex type:(int)scaleType;
- (int)getNote:(int)index;
- (int)getVelocityWeight;
+ (NSArray *)getMajorScaleName;
+ (NSArray *)getMinorScaleName;
+ (NSArray *)getOkinawaScaleName;

@end
