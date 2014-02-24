//
//  MainViewController.h
//  SoundScaper
//
//  Created by Furuyama Yuuki on 2/23/14.
//  Copyright (c) 2014 Furuyama Yuuki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioHost.h"

@interface MainViewController : UIViewController

@property AudioHost *audioHost;
@property NSArray *scaleSegArray;

@end
