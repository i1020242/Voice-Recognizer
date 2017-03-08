//
//  ViewController.h
//  mySpeechtoText
//
//  Created by BDAFshare on 3/6/17.
//  Copyright © 2017 RAD-INF. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Speech;
@import AVFoundation;

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *btnMicrophone;
@property (weak, nonatomic) IBOutlet UITextView *txtFromSpeech;
@end

