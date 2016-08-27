/*
  Presentation Timer for iOS

  Copyright (c) 2008-2016, Takuya Murakami, All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:

  1. Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer. 

  2. Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution. 

  3. Neither the name of the project nor the names of its contributors
  may be used to endorse or promote products derived from this software
  without specific prior written permission. 

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import <AVFoundation/AVFoundation.h>

#import "PresentationTimerViewController.h"
#import "TimePickerViewController.h"
#import "InfoVC.h"

@interface PresentationTimerViewController()
{
    IBOutlet UILabel *timeLabel;
    IBOutlet UIButton *bell1Button;
    IBOutlet UIButton *bell2Button;
    IBOutlet UIButton *bell3Button;
    
    IBOutlet UIButton *bellButton;
    IBOutlet UIButton *startStopButton;
    IBOutlet UIButton *resetButton;
    
    TimerModel *mTimer;
    BOOL mIsCountDown;
	
    UIColor *mColor0;
    UIColor *mColor1;
    UIColor *mColor2;
    UIColor *mColor3;
    
    NSInteger mEditingItem;
}

- (IBAction)startStopTimer:(id)sender;
- (IBAction)resetTimer:(id)sender;
- (IBAction)bellButtonTapped:(id)sender;
- (IBAction)manualBell:(id)sender;
- (IBAction)showHelp:(id)sender;
- (IBAction)invertCountDown:(id)sender;

- (void)updateButtonTitle;
- (void)updateTimeLabel;

@end

@implementation PresentationTimerViewController

/**
   initialize
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    
    mTimer = [TimerModel new];
    mTimer.delegate = self;
    
    mIsCountDown = NO;

    mColor0 = [[UIColor alloc] initWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    mColor1 = [[UIColor alloc] initWithRed:1.0 green:1.0 blue:0.0 alpha:1.0];
    mColor2 = [[UIColor alloc] initWithRed:1.0 green:0.2 blue:0.8 alpha:1.0];
    mColor3 = [[UIColor alloc] initWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
	
    NSString *title;
    title = NSLocalizedString(@"Start", @"");
    [startStopButton setTitle:title forState:UIControlStateNormal];
    [startStopButton setTitle:title forState:UIControlStateHighlighted];
	
    title = NSLocalizedString(@"Reset", @"");
    [resetButton setTitle:title forState:UIControlStateNormal];
    [resetButton setTitle:title forState:UIControlStateHighlighted];
    [resetButton setTitle:title forState:UIControlStateDisabled];

    // timeLabel に対するタッチイベントを有効にする。
    // タッチイベントは touchesBegan で取る
    timeLabel.userInteractionEnabled = YES;
    timeLabel.tag = 100; // dummy tag
    
    // timeLabel: フォントサイズを over 300 に設定する
    timeLabel.font = [UIFont fontWithName:@"Helvetica" size:500];
    
    [self setButtonBorder:bellButton];
    [self setButtonBorder:startStopButton];
    [self setButtonBorder:resetButton];
}

- (void)setButtonBorder:(UIButton *)button {
    //button.layer.borderColor = [UIColor whiteColor].CGColor;
    //button.layer.borderWidth = 1.0f;

    button.layer.backgroundColor = [UIColor colorWithRed:0.9f green:0.9f blue:0.9f alpha:1.0f].CGColor;
    button.layer.cornerRadius = 7.5f;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateButtonTitle];
    [self updateTimeLabel];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

/**
   Update values of time buttons
*/
- (void)updateButtonTitle
{
    for (NSInteger i = 0; i < 3; i++) {
        UIButton *button;
        switch (i) {
            case 0: button = bell1Button; break;
            case 1: button = bell2Button; break;
            case 2: button = bell3Button; break;
        }
        NSInteger time = [mTimer bellTime:i];
        NSString *timeText = [TimerModel timeText:time];
        [button setTitle:timeText forState:UIControlStateNormal];
        [button setTitle:timeText forState:UIControlStateHighlighted];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


/**
   Start or stop timer (toggle)
*/
- (IBAction)startStopTimer:(id)sender
{
    NSString *newTitle;
	
    if (![mTimer isTimerRunning]) {
        // start timer
        [mTimer startTimer];
        newTitle = NSLocalizedString(@"Pause", @"");
        resetButton.enabled = NO;
    } else {
        // stop timer
        [mTimer stopTimer];
        newTitle = NSLocalizedString(@"Start", @"");
        resetButton.enabled = YES;
    }
    [startStopButton setTitle:newTitle forState:UIControlStateNormal];
    [startStopButton setTitle:newTitle forState:UIControlStateHighlighted];
}

/**
   Reset timer value
*/
- (IBAction)resetTimer:(id)sender
{
    [mTimer resetTimer];
    [self updateTimeLabel];
}

/**
   Ring bell manually
*/
- (IBAction)manualBell:(id)sender
{
    [mTimer manualBell];
}

/**
   Called when time buttons are tapped
*/
- (IBAction)bellButtonTapped:(id)sender
{
    NSInteger sec;
    if (sender == bell1Button) {
        mEditingItem = 1;
    } else if (sender == bell2Button) {
        mEditingItem = 2;
    } else {
        mEditingItem = 3;
    }
    sec = [mTimer bellTime:mEditingItem-1];
    
    TimePickerViewController *vc = [TimePickerViewController new];
    vc.delegate = self;
    vc.seconds = sec;

    UINavigationController *nv = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nv animated:YES completion:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    if (touch.view.tag == timeLabel.tag) {
        [self invertCountDown:timeLabel];
    }
}

/**
   Toggle count down mode
*/
- (IBAction)invertCountDown:(id)sender
{
    mIsCountDown = !mIsCountDown;
    [self updateTimeLabel];
}

/**
   Timer handler : called for each 1 second.
*/
- (void)timerUpdated
{
    [self updateTimeLabel];
}

/**
   Update time label
*/
- (void)updateTimeLabel
{
    NSInteger t;
    if (!mIsCountDown) {
        t = mTimer.currentTime;
    } else {
        NSInteger cdt = mTimer.countDownTarget;
        if (cdt < 1 || 3 < cdt) {
            cdt = 2;
        }
        t = [mTimer bellTime:cdt-1] - mTimer.currentTime;
        if (t < 0) t = -t;
    }
    timeLabel.text = [TimerModel timeText:t];

    UIColor *col;
    if (mTimer.currentTime >= [mTimer bellTime:2]) {
        col = mColor3;
    } else if (mTimer.currentTime >= [mTimer bellTime:1]) {
        col = mColor2;
    } else if (mTimer.currentTime >= [mTimer bellTime:0]) {
        col = mColor1;
    } else {
        col = mColor0;
    }
		
    timeLabel.textColor = col;
}

- (IBAction)showHelp:(id)sender
{
    //NSURL *url = [NSURL URLWithString:NSLocalizedString(@"HelpURL", @"")];
    //[[UIApplication sharedApplication] openURL:url];
    
    InfoVC *vc = [[InfoVC alloc] init];
    UINavigationController *nv = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nv animated:YES completion:nil];
}

#pragma mark TimePickerViewDelegate

- (void)timePickerViewSetTime:(NSInteger)seconds
{
    [mTimer setBellTime:seconds index:mEditingItem-1];
    [mTimer saveDefaults];
    [self updateButtonTitle];
}

- (void)timePickerViewSetCountdownTarget
{
    mTimer.countDownTarget = mEditingItem;
    [mTimer saveDefaults];
}

#pragma mark iOS4 support

- (void)appSuspended
{
    [mTimer appSuspended];
}

- (void)appResumed
{
    [mTimer appResumed];
    [self updateTimeLabel];
}

@end
