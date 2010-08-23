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

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "TimePickerViewController.h"

@interface PresentationTimerViewController : UIViewController
  <TimePickerViewDelegate>
{
    IBOutlet UILabel *timeLabel;
    IBOutlet UIButton *bell1Button;
    IBOutlet UIButton *bell2Button;
    IBOutlet UIButton *bell3Button;
    IBOutlet UIButton *startStopButton;
    IBOutlet UIButton *resetButton;

    // Timer value                                                                                                                                        
    int currentTime; // seconds                                                                                                                           
    int bell1Time;
    int bell2Time;
    int bell3Time;
    int countDownTarget;
    BOOL isCountDown;
	
    UIColor *color0;
    UIColor *color1;
    UIColor *color2;
    UIColor *color3;

    NSTimer *timer;
    NSDate *suspendedTime;
	
    int editingItem;

    // Audio
    SystemSoundID sound_bell1;
    SystemSoundID sound_bell2;
    SystemSoundID sound_bell3;
}

- (IBAction)startStopTimer:(id)sender;
- (IBAction)resetTimer:(id)sender;
- (IBAction)bellButtonTapped:(id)sender;
- (IBAction)manualBell:(id)sender;
- (IBAction)showHelp:(id)sender;
- (IBAction)invertCountDown:(id)sender;

- (void)saveDefaults;
- (void)updateButtonTitle;
- (void)updateTimeLabel;
- (NSString*)timeText:(int)n;
- (void)timerHandler:(NSTimer*)theTimer;

- (SystemSoundID)loadWav:(NSString*)name;

- (void)appSuspended;
- (void)appResumed;

@end
