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

@implementation PresentationTimerViewController

/**
   initialize
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    
    currentTime = 0;
    suspendedTime = nil;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    bell1Time = [defaults integerForKey:@"bell1Time"];
    bell2Time = [defaults integerForKey:@"bell2Time"];
    bell3Time = [defaults integerForKey:@"bell3Time"];
    countDownTarget = [defaults integerForKey:@"countDownTarget"];
    if (bell1Time == 0) bell1Time = 13*60;
    if (bell2Time == 0) bell2Time = 15*60;
    if (bell3Time == 0) bell3Time = 20*60;
    if (countDownTarget == 0) countDownTarget = 2;
    isCountDown = NO;

    color0 = [[UIColor alloc] initWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    color1 = [[UIColor alloc] initWithRed:1.0 green:1.0 blue:0.0 alpha:1.0];
    color2 = [[UIColor alloc] initWithRed:1.0 green:0.2 blue:0.8 alpha:1.0];
    color3 = [[UIColor alloc] initWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
	
    sound_bell1 = [self loadWav:@"1bell"];
    sound_bell2 = [self loadWav:@"2bell"];
    sound_bell3 = [self loadWav:@"3bell"];
	
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
    [defaults setObject:[NSNumber numberWithInt:bell1Time] forKey:@"bell1Time"];
    [defaults setObject:[NSNumber numberWithInt:bell2Time] forKey:@"bell2Time"];
    [defaults setObject:[NSNumber numberWithInt:bell3Time] forKey:@"bell3Time"];
    [defaults setObject:[NSNumber numberWithInt:countDownTarget] forKey:@"countDownTarget"];
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
    [bell1Button setTitle:[self timeText:bell1Time] forState:UIControlStateNormal];
    [bell1Button setTitle:[self timeText:bell1Time] forState:UIControlStateHighlighted];
    [bell2Button setTitle:[self timeText:bell2Time] forState:UIControlStateNormal];
    [bell2Button setTitle:[self timeText:bell2Time] forState:UIControlStateHighlighted];
    [bell3Button setTitle:[self timeText:bell3Time] forState:UIControlStateNormal];
    [bell3Button setTitle:[self timeText:bell3Time] forState:UIControlStateHighlighted];
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

- (void)dealloc {
    [super dealloc];
}

/**
   Start or stop timer (toggle)
*/
- (IBAction)startStopTimer:(id)sender
{
    NSString *newTitle;
	
    if (timer == nil) {
        // start timer
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                         target:self 
                         selector:@selector(timerHandler:) 
                         userInfo:nil
                         repeats:YES];
        [timer retain];
        newTitle = NSLocalizedString(@"Pause", @"");
        resetButton.enabled = NO;

        // Disable auto lock when timer is running
        [UIApplication sharedApplication].idleTimerDisabled = YES;
    } else {
        // stop timer
        [timer invalidate];
        [timer release];
        timer = nil;

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
    currentTime = 0;
    [self updateTimeLabel];
}

/**
   Ring bell manually
*/
- (IBAction)manualBell:(id)sender
{
    AudioServicesPlaySystemSound(sound_bell1);
}

/**
   Called when time buttons are tapped
*/
- (IBAction)bellButtonTapped:(id)sender
{
    int sec;
    if (sender == bell1Button) {
        sec = bell1Time;
        editingItem = 1;
    } else if (sender == bell2Button) {
        sec = bell2Time;
        editingItem = 2;
    } else {
        sec = bell3Time;
        editingItem = 3;
    }
    
    TimePickerViewController *vc = [[[TimePickerViewController alloc] init] autorelease];
    vc.delegate = self;
    vc.seconds = sec;

    UINavigationController *nv = [[[UINavigationController alloc] initWithRootViewController:vc] autorelease];
    [self presentModalViewController:nv animated:YES];
}

/**
   Toggle count down mode
*/
- (IBAction)invertCountDown:(id)sender
{
    isCountDown = !isCountDown;
    [self updateTimeLabel];
}

/**
   Timer handler : called for each 1 second.
*/
- (void)timerHandler:(NSTimer*)theTimer
{
    currentTime ++;
	
    if (currentTime == bell1Time) {
        AudioServicesPlaySystemSound(sound_bell1);
    }
    else if (currentTime == bell2Time) {
        AudioServicesPlaySystemSound(sound_bell2);
    }
    else if (currentTime == bell3Time) {
        AudioServicesPlaySystemSound(sound_bell3);
    }
			
    [self updateTimeLabel];
}

/**
   Update time label
*/
- (void)updateTimeLabel
{
    int t;
    if (!isCountDown) {
        t = currentTime;
    } else {
        switch (countDownTarget)
            {
            case 1:
                t = bell1Time - currentTime;
                break;
            case 2:
            default:
                t = bell2Time - currentTime;
                break;
            case 3:
                t = bell3Time - currentTime;
                break;
            }
        if (t < 0) t = -t;
    }
    timeLabel.text = [self timeText:t];

    UIColor *col;
    if (currentTime >= bell3Time) {
        col = color3;
    } else if (currentTime >= bell2Time) {
        col = color2;
    } else if (currentTime >= bell1Time) {
        col = color1;
    } else {
        col = color0;
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
    
    InfoVC *vc = [[[InfoVC alloc] init] autorelease];
    UINavigationController *nv = [[[UINavigationController alloc] initWithRootViewController:vc] autorelease];
    [self presentModalViewController:nv animated:YES];
}

#pragma mark TimePickerViewDelegate

- (void)timePickerViewSetTime:(int)seconds
{
    if (seconds > 99*60) {
        seconds = 99*60;
    }
    seconds -= (seconds % 60); // for safety
    switch (editingItem) {
        case 1:
            bell1Time = seconds;
            break;
        case 2:
            bell2Time = seconds;
            break;
        case 3:
            bell3Time = seconds;
            break;
    }
    [self saveDefaults];
    [self updateButtonTitle];
}

- (void)timePickerViewSetCountdownTarget
{
    countDownTarget = editingItem;
    [self saveDefaults];
}

#pragma mark iOS4 support

- (void)appSuspended
{
    if (timer == nil) return; // do nothing
    
    // timer working. remember current time
    suspendedTime = [NSDate date];
    [suspendedTime retain];
}

- (void)appResumed
{
    if (timer == nil) return; // do nothing
    
    if (suspendedTime == nil) return;
    
    // modify current time
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:suspendedTime];
    currentTime += interval;
    [suspendedTime release];
    suspendedTime = nil;
}

@end
