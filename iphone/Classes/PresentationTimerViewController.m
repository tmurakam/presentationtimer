// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
  Presentation Timer for iPhone

  Copyright (c) 2008-2010, Takuya Murakami, All rights reserved.

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

#import "PresentationTimerViewController.h"
#import "TimePickerViewController.h"
#import "InfoVC.h"

@interface PresentationTimerViewController()
{
    IBOutlet UILabel *timeLabel;
    IBOutlet UIButton *bell1Button;
    IBOutlet UIButton *bell2Button;
    IBOutlet UIButton *bell3Button;
    IBOutlet UIButton *startStopButton;
    IBOutlet UIButton *resetButton;
    
    // Timer value
    int mCurrentTime; // seconds
    int mBell1Time;
    int mBell2Time;
    int mBell3Time;
    int mCountDownTarget;
    BOOL mIsCountDown;
	
    UIColor *mColor0;
    UIColor *mColor1;
    UIColor *mColor2;
    UIColor *mColor3;
    
    NSTimer *mTimer;
    NSDate *mSuspendedTime;
	
    int mEditingItem;
    
    // Audio
    SystemSoundID mSoundBell1;
    SystemSoundID mSoundBell2;
    SystemSoundID mSoundBell3;
}

- (void)saveDefaults;
- (void)updateButtonTitle;
- (void)updateTimeLabel;
- (NSString*)timeText:(int)n;
- (void)timerHandler:(NSTimer*)theTimer;

- (SystemSoundID)loadWav:(NSString*)name;

@end

@implementation PresentationTimerViewController

/**
   initialize
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    
    mCurrentTime = 0;
    mSuspendedTime = nil;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    mBell1Time = [defaults integerForKey:@"bell1Time"];
    mBell2Time = [defaults integerForKey:@"bell2Time"];
    mBell3Time = [defaults integerForKey:@"bell3Time"];
    mCountDownTarget = [defaults integerForKey:@"countDownTarget"];
    if (mBell1Time == 0) mBell1Time = 13*60;
    if (mBell2Time == 0) mBell2Time = 15*60;
    if (mBell3Time == 0) mBell3Time = 20*60;
    if (mCountDownTarget == 0) mCountDownTarget = 2;
    mIsCountDown = NO;

    mColor0 = [[UIColor alloc] initWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    mColor1 = [[UIColor alloc] initWithRed:1.0 green:1.0 blue:0.0 alpha:1.0];
    mColor2 = [[UIColor alloc] initWithRed:1.0 green:0.2 blue:0.8 alpha:1.0];
    mColor3 = [[UIColor alloc] initWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
	
    mSoundBell1 = [self loadWav:@"1bell"];
    mSoundBell2 = [self loadWav:@"2bell"];
    mSoundBell3 = [self loadWav:@"3bell"];
	
    NSString *title;
    title = NSLocalizedString(@"Start", @"");
    [startStopButton setTitle:title forState:UIControlStateNormal];
    [startStopButton setTitle:title forState:UIControlStateHighlighted];
	
    title = NSLocalizedString(@"Reset", @"");
    [resetButton setTitle:title forState:UIControlStateNormal];
    [resetButton setTitle:title forState:UIControlStateHighlighted];
    [resetButton setTitle:title forState:UIControlStateDisabled];
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
   Save default values
*/
- (void)saveDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInt:mBell1Time] forKey:@"bell1Time"];
    [defaults setObject:[NSNumber numberWithInt:mBell2Time] forKey:@"bell2Time"];
    [defaults setObject:[NSNumber numberWithInt:mBell3Time] forKey:@"bell3Time"];
    [defaults setObject:[NSNumber numberWithInt:mCountDownTarget] forKey:@"countDownTarget"];
    [defaults synchronize];
}

/**
   load WAV file from resource
*/
- (SystemSoundID)loadWav:(NSString*)name
{
    SystemSoundID sid;
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:name ofType:@"wav"]];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &sid);
    return sid;
}

/**
   Update values of time buttons
*/
- (void)updateButtonTitle
{
    [bell1Button setTitle:[self timeText:mBell1Time] forState:UIControlStateNormal];
    [bell1Button setTitle:[self timeText:mBell1Time] forState:UIControlStateHighlighted];
    [bell2Button setTitle:[self timeText:mBell2Time] forState:UIControlStateNormal];
    [bell2Button setTitle:[self timeText:mBell2Time] forState:UIControlStateHighlighted];
    [bell3Button setTitle:[self timeText:mBell3Time] forState:UIControlStateNormal];
    [bell3Button setTitle:[self timeText:mBell3Time] forState:UIControlStateHighlighted];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

// iOS 6 later
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}
- (BOOL)shouldAutorotate
{
    return YES;
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
	
    if (mTimer == nil) {
        // start timer
        mTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                         target:self 
                         selector:@selector(timerHandler:) 
                         userInfo:nil
                         repeats:YES];
        newTitle = NSLocalizedString(@"Pause", @"");
        resetButton.enabled = NO;

        // Disable auto lock when timer is running
        [UIApplication sharedApplication].idleTimerDisabled = YES;
    } else {
        // stop timer
        [mTimer invalidate];
        mTimer = nil;

        newTitle = NSLocalizedString(@"Start", @"");
        resetButton.enabled = YES;

        // Enable auto lock
        [UIApplication sharedApplication].idleTimerDisabled = NO;
    }
    [startStopButton setTitle:newTitle forState:UIControlStateNormal];
    [startStopButton setTitle:newTitle forState:UIControlStateHighlighted];
}

/**
   Reset timer value
*/
- (IBAction)resetTimer:(id)sender
{
    mCurrentTime = 0;
    [self updateTimeLabel];
}

/**
   Ring bell manually
*/
- (IBAction)manualBell:(id)sender
{
    AudioServicesPlaySystemSound(mSoundBell1);
}

/**
   Called when time buttons are tapped
*/
- (IBAction)bellButtonTapped:(id)sender
{
    int sec;
    if (sender == bell1Button) {
        sec = mBell1Time;
        mEditingItem = 1;
    } else if (sender == bell2Button) {
        sec = mBell2Time;
        mEditingItem = 2;
    } else {
        sec = mBell3Time;
        mEditingItem = 3;
    }
    
    TimePickerViewController *vc = [[TimePickerViewController alloc] init];
    vc.delegate = self;
    vc.seconds = sec;

    UINavigationController *nv = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentModalViewController:nv animated:YES];
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
- (void)timerHandler:(NSTimer*)theTimer
{
    mCurrentTime ++;
	
    if (mCurrentTime == mBell1Time) {
        AudioServicesPlaySystemSound(mSoundBell1);
    }
    else if (mCurrentTime == mBell2Time) {
        AudioServicesPlaySystemSound(mSoundBell2);
    }
    else if (mCurrentTime == mBell3Time) {
        AudioServicesPlaySystemSound(mSoundBell3);
    }
			
    [self updateTimeLabel];
}

/**
   Update time label
*/
- (void)updateTimeLabel
{
    int t;
    if (!mIsCountDown) {
        t = mCurrentTime;
    } else {
        switch (mCountDownTarget)
            {
            case 1:
                t = mBell1Time - mCurrentTime;
                break;
            case 2:
            default:
                t = mBell2Time - mCurrentTime;
                break;
            case 3:
                t = mBell3Time - mCurrentTime;
                break;
            }
        if (t < 0) t = -t;
    }
    timeLabel.text = [self timeText:t];

    UIColor *col;
    if (mCurrentTime >= mBell3Time) {
        col = mColor3;
    } else if (mCurrentTime >= mBell2Time) {
        col = mColor2;
    } else if (mCurrentTime >= mBell1Time) {
        col = mColor1;
    } else {
        col = mColor0;
    }
		
    timeLabel.textColor = col;
}

- (NSString*)timeText:(int)n
{
    int min = n / 60;
    int sec = n % 60;
    NSString *ts = [NSString stringWithFormat:@"%02d:%02d", min, sec];
    return ts;
}

- (IBAction)showHelp:(id)sender
{
    //NSURL *url = [NSURL URLWithString:NSLocalizedString(@"HelpURL", @"")];
    //[[UIApplication sharedApplication] openURL:url];
    
    InfoVC *vc = [[InfoVC alloc] init];
    UINavigationController *nv = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentModalViewController:nv animated:YES];
}

#pragma mark TimePickerViewDelegate

- (void)timePickerViewSetTime:(int)seconds
{
    if (seconds > 99*60) {
        seconds = 99*60;
    }
    seconds -= (seconds % 60); // for safety
    switch (mEditingItem) {
        case 1:
            mBell1Time = seconds;
            break;
        case 2:
            mBell2Time = seconds;
            break;
        case 3:
            mBell3Time = seconds;
            break;
    }
    [self saveDefaults];
    [self updateButtonTitle];
}

- (void)timePickerViewSetCountdownTarget
{
    mCountDownTarget = mEditingItem;
    [self saveDefaults];
}

#pragma mark iOS4 support

- (void)appSuspended
{
    if (mTimer == nil) return; // do nothing
    
    // timer working. remember current time
    mSuspendedTime = [NSDate date];
}

- (void)appResumed
{
    if (mTimer == nil) return; // do nothing
    
    if (mSuspendedTime == nil) return;
    
    // modify current time
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:mSuspendedTime];
    mCurrentTime += interval;
    mSuspendedTime = nil;
}

@end
