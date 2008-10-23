//
//  ConfTimerViewController.h
//  ConfTimer
//
//  Created by 村上 卓弥 on 08/09/13.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "TimePickerViewController.h"

@interface PresentationTimerViewController : UIViewController {
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
	
	// Audio
	SystemSoundID sound_bell1;
	SystemSoundID sound_bell2;
	SystemSoundID sound_bell3;
	
	// View
	UINavigationController *timeNaviC;
	TimePickerViewController *timePickerVC;
}

@property(nonatomic,assign) int bell1Time;
@property(nonatomic,assign) int bell2Time;
@property(nonatomic,assign) int bell3Time;
@property(nonatomic,assign) int countDownTarget;

- (IBAction)startStopTimer:(id)sender;
- (IBAction)resetTimer:(id)sender;
- (IBAction)bellButtonTapped:(id)sender;
- (IBAction)manualBell:(id)sender;
- (IBAction)showHelp:(id)sender;
- (IBAction)invertCountDown:(id)sender;

- (void)updateButtonTitle;
- (void)updateTimeLabel;
- (NSString*)timeText:(int)n;
- (void)timerHandler:(NSTimer*)theTimer;

- (SystemSoundID)loadWav:(NSString*)name;

@end

