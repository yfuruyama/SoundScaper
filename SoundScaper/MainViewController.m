//
//  MainViewController.m
//  SoundScaper
//
//  Created by Furuyama Yuuki on 2/23/14.
//  Copyright (c) 2014 Furuyama Yuuki. All rights reserved.
//

#import "MainViewController.h"
#import "NoteGenerator.h"

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
    
    // 各Audio関連の初期化
    self.audioHost = [[AudioHost alloc] init];
    
    // UIの初期化
    UIButton *playPauseButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    playPauseButton.frame = CGRectMake(0, 0, 100, 40);
    playPauseButton.center = CGPointMake(160, 200);
    [playPauseButton setTitle:@"Play/Pause" forState:UIControlStateNormal];
    [playPauseButton addTarget:self action:@selector(playPauseButtonDidTouch) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playPauseButton];
    
    UILabel *majorScaleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 260, 100, 20)];
    [majorScaleLabel setText:@"Major Scale"];
    [majorScaleLabel setFont:[UIFont fontWithName:@"ArialMT" size:14]];
    [majorScaleLabel setTextColor:[UIColor colorWithRed:0 green:0.4 blue:1 alpha:1.0]];
    [self.view addSubview:majorScaleLabel];
    
    UISegmentedControl *majorSeg = [[UISegmentedControl alloc] initWithItems:[NoteGenerator getMajorScaleName]];
    majorSeg.tag = MAJOR_SCALE;
    majorSeg.frame = CGRectMake(0, 0, 300, 40);
    majorSeg.center = CGPointMake(160, 300);
    majorSeg.selectedSegmentIndex = 0;
    [majorSeg setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"ArialMT" size:10]} forState:UIControlStateNormal];
    [majorSeg addTarget:self action:@selector(scaleChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:majorSeg];
    
    UILabel *minorScaleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 330, 100, 20)];
    [minorScaleLabel setText:@"Minor Scale"];
    [minorScaleLabel setFont:[UIFont fontWithName:@"ArialMT" size:14]];
    [minorScaleLabel setTextColor:[UIColor colorWithRed:0 green:0.4 blue:1 alpha:1.0]];
    [self.view addSubview:minorScaleLabel];
    
    UISegmentedControl *minorSeg = [[UISegmentedControl alloc] initWithItems:[NoteGenerator getMinorScaleName]];
    [minorSeg setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"ArialMT" size:10]} forState:UIControlStateNormal];
    minorSeg.tag = MINOR_SCALE;
    minorSeg.frame = CGRectMake(0, 0, 300, 40);
    minorSeg.center = CGPointMake(160, 370);
    [minorSeg addTarget:self action:@selector(scaleChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:minorSeg];
    
    UILabel *okinawaScaleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 400, 100, 20)];
    [okinawaScaleLabel setText:@"Okinawa Scale"];
    [okinawaScaleLabel setFont:[UIFont fontWithName:@"ArialMT" size:14]];
    [okinawaScaleLabel setTextColor:[UIColor colorWithRed:0 green:0.4 blue:1 alpha:1.0]];
    [self.view addSubview:okinawaScaleLabel];
    
    UISegmentedControl *okinawaSeg = [[UISegmentedControl alloc] initWithItems:[NoteGenerator getOkinawaScaleName]];
    [okinawaSeg setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"ArialMT" size:10]} forState:UIControlStateNormal];
    okinawaSeg.tag = OKINAWA_SCALE;
    okinawaSeg.frame = CGRectMake(0, 0, 300, 40);
    okinawaSeg.center = CGPointMake(160, 440);
    [okinawaSeg addTarget:self action:@selector(scaleChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:okinawaSeg];
    
    self.scaleSegArray = [NSArray arrayWithObjects:majorSeg, minorSeg, okinawaSeg, nil];
}

- (void)playPauseButtonDidTouch
{
    if ([self.audioHost isPlaying]) {
        [self.audioHost pause];
    } else {
        [self.audioHost play];
    }
}

- (void)scaleChanged:(UISegmentedControl *)seg
{
    int selectedIndex = seg.selectedSegmentIndex;

    // 一度全てのスケールのコントロールの選択を消す
    for (int i = 0; i < [self.scaleSegArray count]; i++) {
        UISegmentedControl *scaleSeg = [self.scaleSegArray objectAtIndex:i];
        scaleSeg.selectedSegmentIndex = UISegmentedControlNoSegment;
    }
    
    // 再度選択
    seg.selectedSegmentIndex = selectedIndex;
    
    [self.audioHost changeScale:[seg selectedSegmentIndex] type:seg.tag];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
