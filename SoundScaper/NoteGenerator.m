//
//  NoteGenerator.m
//  SoundScaper
//
//  Created by Furuyama Yuuki on 2/24/14.
//  Copyright (c) 2014 Furuyama Yuuki. All rights reserved.
//

#import "NoteGenerator.h"

#define BASE_VELOCITY 64

NSArray *sharpMajor;
NSArray *sharpMinor;
NSArray *sharpOkinawa;
NSArray *majorScale;
NSArray *harmonicMinorScale;
NSArray *okinawaScale;

@implementation NoteGenerator

- (id)init
{
    self = [super init];
    if (!self) return nil;
    
    [self initScale];
    [self setScale:0 type:MAJOR_SCALE];
    
    return self;
}

- (void)initScale
{
    sharpMajor = @[@0, @7, @2, @9, @4, @11, @6, @1, @8, @3, @10, @5];
    sharpMinor = @[@9, @4, @11, @6, @1, @8, @3, @10, @5, @0, @7, @2];
    sharpOkinawa = @[@0, @1, @2, @3, @4, @5, @6, @7, @8, @9, @10 , @11];

    majorScale = @[@2, @2, @1, @2, @2, @2, @1];
    harmonicMinorScale = @[@2, @1, @2, @2, @1, @3, @1];
    okinawaScale = @[@4, @1, @2, @4, @1];
}

- (int)micLevelToNoteIndex:(Float32)level
{
    Float32 micMin = -70;
    Float32 micMax = 0;
    int noteIndexMin = 0;
    int noteIndexMax = [self.noteList count];
    
    float unit = (micMax - micMin) / (noteIndexMax - noteIndexMin);
    for (int index = noteIndexMin; index < noteIndexMax; index++) {
        if (micMin + (unit * index) > level) {
            return index;
        }
    }
    
    // コーナーケースがわからないので一応0返す
    return 0;
}

- (int)getNote:(int)index
{
    return [(NSNumber*)[self.noteList objectAtIndex:index] integerValue];
}

- (void)setScale:(int)startNoteIndex type:(int)scaleType
{
    int startNote;
    NSArray *scale;
    
    switch (scaleType) {
        case MAJOR_SCALE:
            startNote = [[sharpMajor objectAtIndex:startNoteIndex] integerValue];
            scale = majorScale;
            break;
        case MINOR_SCALE:
            startNote = [[sharpMinor objectAtIndex:startNoteIndex] integerValue];
            scale = harmonicMinorScale;
            break;
        case OKINAWA_SCALE:
            startNote = [[sharpOkinawa objectAtIndex:startNoteIndex] integerValue];
            scale = okinawaScale;
            break;
        default:
            break;
    }
    
    self.noteList = [NSMutableArray arrayWithCapacity:128];
    BOOL continued = true;
    UInt32 prevNote = startNote;
    while (continued) {
        for (int i = 0; i < [scale count]; i++) {
            UInt32 note = [[scale objectAtIndex:i] integerValue] + prevNote;
            if (note > 127) {
                continued = false;
                break;
            }
            [self.noteList addObject:@(note)];
            prevNote = note;
        }
    }
    
    // debug print
    for (int i = 0; i < [self.noteList count]; i++) {
        NSNumber *num = [self.noteList objectAtIndex:i];
        NSLog(@"%d", [num integerValue]);
    }
}

+ (NSArray *)getMajorScaleName
{
    return @[@"C", @"G", @"D", @"A", @"E", @"B", @"F#", @"C#", @"Ab", @"Eb", @"Bb", @"F"];
}

+ (NSArray *)getMinorScaleName
{
    return @[@"Am", @"Em", @"Bm", @"F#m", @"C#m", @"Abm", @"Ebm", @"Bbm", @"Fm", @"Cm", @"Gm", @"Dm"];
}

+ (NSArray *)getOkinawaScaleName
{
    return @[@"C", @"C#", @"D", @"D#", @"E", @"F", @"F#", @"G", @"G#", @"A", @"A#", @"B"];
}

// for humanizing
- (int)getVelocityWeight
{
    int r = arc4random() % 64;
    return r - 40;
}

@end
