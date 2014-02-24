//
//  MainViewController.m
//  SoundScaper
//
//  Created by Furuyama Yuuki on 2/23/14.
//  Copyright (c) 2014 Furuyama Yuuki. All rights reserved.
//

#import "MainViewController.h"

#define NOTE_INTERVAL 0.5

@interface MainViewController ()

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(0, 0, 100, 40);
    button.center = CGPointMake(160, 200);
    [button setTitle:@"Start" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonDidTouch) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    // 各Audio関連の初期化
    self.audioHost = [[AudioHost alloc] init];
    self.externalInputManager = [[ExternalInputManager alloc] init];
    UInt32 majorScale[] = {2, 2, 1, 2, 2, 2, 1};

    // generate noteList
    self.noteList = [NSMutableArray arrayWithCapacity:128];
    UInt32 startNote = 0;
    BOOL continued = true;
    UInt32 prevNote = startNote;
    while (continued) {
        for (int i = 0; i < 7; i++) {
            UInt32 note = majorScale[i] + prevNote;
            if (note > 127) {
                continued = false;
                break;
            }
            [self.noteList addObject:@(note)];
            prevNote = note;
        }
    }
    for (int i = 0; i < [self.noteList count]; i++) {
        NSNumber *num = [self.noteList objectAtIndex:i];
        NSLog(@"%d", [num integerValue]);
    }
    
}

- (void)buttonDidTouch
{
    // Loop
    [NSTimer scheduledTimerWithTimeInterval:NOTE_INTERVAL target:self selector:@selector(soundNote) userInfo:nil repeats:YES];
}

- (void)soundNote
{
    Float32 micLevel = [self.externalInputManager getExternalInputLevel];
    int noteIndex = [self micLevelToNoteIndex:micLevel noteList:self.noteList];
    NSLog(@"noteIndex: %d", noteIndex);
    
    // send note on message
    UInt32 noteNum = [(NSNumber*)[self.noteList objectAtIndex:noteIndex] integerValue];
    UInt32 velocity = 30;
    [self.audioHost playNoteOn:noteNum velocity:velocity];
    
    // send note off message after some delay
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self.audioHost methodSignatureForSelector:@selector(playNoteOff:velocity:)]];
    [invocation setSelector:@selector(playNoteOff:velocity:)];
    [invocation setTarget:self.audioHost];
    [invocation setArgument:&noteNum atIndex:2];
    [invocation setArgument:&velocity atIndex:3];
    [NSTimer scheduledTimerWithTimeInterval:NOTE_INTERVAL - 0.1 invocation:invocation repeats:NO];
}

- (int)micLevelToNoteIndex:(Float32)level noteList:(NSMutableArray*)noteList
{
    Float32 micMin = -70;
    Float32 micMax = 0;
    int noteIndexMin = 0;
    int noteIndexMax = [noteList count];
    
    float unit = (micMax - micMin) / (noteIndexMax - noteIndexMin);
    for (int index = noteIndexMin; index < noteIndexMax; index++) {
        if (micMin + (unit * index) > level) {
            return index;
        }
    }
    
    // コーナーケースがわからないので一応0返す
    return 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
