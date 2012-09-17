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

#import "TimerModel.h"
#import <AVFoundation/AVFoundation.h>

@interface TimerInfo : NSObject
{
    // ベル時刻
    int bellTime;
    
    // ベル音
    AVAudioPlayer *soundBell;
}

@property (nonatomic) int bellTime;
@property (nonatomic) AVAudioPlayer *soundBell;
@end

@implementation TimerInfo
@synthesize bellTime;
@synthesize soundBell;
@end

@interface TimerModel()
{
    id<TimerModelDelegate> mDelegate;
    
    // Timer value
    int mCurrentTime; // seconds
    
    // ベル情報
    TimerInfo *mTimerInfo[3];

    // プレゼン終了時刻タイマのインデックス
    int mCountDownTarget;
    
    // カウントダウンモード
    BOOL mIsCountDown;
    
    NSTimer *mTimer;
    NSDate *mSuspendedTime;
	
    int mEditingItem;
    
    // 最後に鳴らしたベルのインデックス
    int mLastPlayBell;
}

- (void)timerHandler:(NSTimer*)theTimer;

- (AVAudioPlayer *)loadWav:(NSString*)name;

@end

@implementation TimerModel

@synthesize delegate = mDelegate;
@synthesize countDownTarget = mCountDownTarget;
@synthesize isCountDown = mIsCountDown;

/**
   initialize
 */
- (id)init
{
    self = [super init];
    if (self) {
        mCurrentTime = 0;
        mSuspendedTime = nil;
        int i;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        for (i = 0; i < 3; i++) {
            mTimerInfo[i] = [TimerInfo new];
            
            int bellTime = [defaults integerForKey:[NSString stringWithFormat:@"bell%dTime", i+1]];
            if (bellTime == 0) {
                switch (i) {
                    case 0:
                        bellTime = 13 * 60;
                        break;
                    
                    case 1:
                        bellTime = 15 * 60;
                        break;

                    case 2:
                        bellTime = 20 * 60;
                        break;
                }
            }
            mTimerInfo[i].bellTime = bellTime;

            AVAudioPlayer *avp = [self loadWav:[NSString stringWithFormat:@"%dbell", i+1]];
            mTimerInfo[i].soundBell = avp;
        }
        mCountDownTarget = [defaults integerForKey:@"countDownTarget"];
        if (mCountDownTarget == 0) mCountDownTarget = 2;
        mIsCountDown = NO;
    
        mLastPlayBell = -1;
	}
    return self;
}

/**
   Save default values
*/
- (void)saveDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    for (int i = 0; i < 3; i++) {
        NSString *key = [NSString stringWithFormat:@"bell%dTime", i+1];
        [defaults setObject:[NSNumber numberWithInt:mTimerInfo[i].bellTime] forKey:key];
    }
    [defaults setObject:[NSNumber numberWithInt:mCountDownTarget] forKey:@"countDownTarget"];
    [defaults synchronize];
}

/**
 get timer value
 */
- (int)bellTime:(int)index
{
    return mTimerInfo[index].bellTime;
}

- (void)setBellTime:(int)time index:(int)index
{
    mTimerInfo[index].bellTime = time;
}

/**
   load WAV file from resource
*/
    - (AVAudioPlayer *)loadWav:(NSString*)name
{
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:name ofType:@"wav"]];
    AVAudioPlayer *audio = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    return audio;
}

/**
 Is timer running?
 */
- (BOOL)isTimerRunning
{
    if (mTimer != nil) return YES;
    return NO;
}

/**
   Start or stop timer (toggle)
*/
- (void)startTimer
{
    if (mTimer != nil) return; // do nothing

    mTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                              target:self
                                            selector:@selector(timerHandler:)
                                            userInfo:nil
                                             repeats:YES];
    // Disable auto lock when timer is running
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)stopTimer
{
    if (mTimer == nil) return; // do nothing

    // stop timer
    [mTimer invalidate];
    mTimer = nil;

    // Enable auto lock
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

/**
   Reset timer value
*/
- (void)resetTimer
{
    mCurrentTime = 0;
}

/**
   Ring bell manually
*/
- (void)manualBell
{
    [self playBell:0];
}

/**
   Toggle count down mode
*/
- (void)invertCountDown
{
    mIsCountDown = !mIsCountDown;
}

/**
   Timer handler : called for each 1 second.
*/
- (void)timerHandler:(NSTimer*)theTimer
{
    mCurrentTime ++;
	
    for (int i = 0; i < 3; i++) {
        if (mCurrentTime == mTimerInfo[i].bellTime) {
            [self playBell:i];
        }
    }
    
    [delegate timerUpdated];
}

- (void)playBell:(int)n
{
    AVAudioPlayer *p;
    
    if (mLastPlayBell >= 0) {
        p = mTimerInfo[mLastPlayBell].soundBell;
        if ([p isPlaying]) {
            [p stop];
            p.currentTime = 0;
        }
    }
    
    p = mTimerInfo[mLastPlayBell].soundBell;
    [p play];
    mLastPlayBell = n;
}

// 秒を時分秒に変換する
+ (NSString*)timeText:(int)n
{
    int sec = n % 60;
    n = n / 60;
    int min = n % 60;
    int hour = n / 60;

    NSString *ts;
    if (hour > 0) {
        ts = [NSString stringWithFormat:@"%d:%02d:%02d", hour, min, sec];
    } else {
        ts = [NSString stringWithFormat:@"%02d:%02d", min, sec];
    }
    return ts;
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
