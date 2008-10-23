//
//  ConfTimerViewController.m
//  ConfTimer
//
//  Created by 村上 卓弥 on 08/09/13.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import "PresentationTimerViewController.h"

@implementation PresentationTimerViewController

@synthesize bell1Time, bell2Time, bell3Time, countDownTarget;

/*
// Override initWithNibName:bundle: to load the view using a nib file then perform additional customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically.
- (void)loadView {
}
*/

#if 0
+ (void)initialize
{
	// initialize dictionary
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	for (int i = 0; i < 3; i++) {
		NSNumber *n = [NSNumber numberWithInt:(600+300*i)];
		NSString *key = [NSString stringWithFormat:@"bell%dTime", i+1];
		NSDictionary *d = [NSDictionary dictionaryWithObject:n forKey:key];
		[defaults registerDefaults:d];
	}
}
#endif

// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
    [super viewDidLoad];
	
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
	
	timePickerVC = [[TimePickerViewController alloc] initWithNibName:@"TimePickerViewController" bundle:[NSBundle mainBundle]];
	timeNaviC = [[UINavigationController alloc] initWithRootViewController:timePickerVC];
	
	timePickerVC.presentationTimerVC = self;

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
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:[NSNumber numberWithInt:bell1Time] forKey:@"bell1Time"];
	[defaults setObject:[NSNumber numberWithInt:bell2Time] forKey:@"bell2Time"];
	[defaults setObject:[NSNumber numberWithInt:bell3Time] forKey:@"bell3Time"];
	[defaults setObject:[NSNumber numberWithInt:countDownTarget] forKey:@"countDownTarget"];
	[defaults synchronize];
}

- (SystemSoundID)loadWav:(NSString*)name
{
	SystemSoundID sid;
	NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:name ofType:@"wav"]];
	AudioServicesCreateSystemSoundID((CFURLRef)url, &sid);
	return sid;
}

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
    // Return YES for supported orientations
	return YES;
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [super dealloc];
}

///

- (IBAction)startStopTimer:(id)sender
{
	NSString *newTitle;
	
	if (timer == nil) {
		timer = [NSTimer scheduledTimerWithTimeInterval:1.0
												 target:self 
											   selector:@selector(timerHandler:) 
											   userInfo:nil
												repeats:YES];
		newTitle = NSLocalizedString(@"Pause", @"");
		resetButton.enabled = NO;
                [UIApplication sharedApplication].idleTimerDisabled = YES;
	} else {
		[timer invalidate];
		[timer release];
		timer = nil;

		newTitle = NSLocalizedString(@"Start", @"");
		resetButton.enabled = YES;
                [UIApplication sharedApplication].idleTimerDisabled = NO;
	}
	[startStopButton setTitle:newTitle forState:UIControlStateNormal];
	[startStopButton setTitle:newTitle forState:UIControlStateHighlighted];
}

- (IBAction)resetTimer:(id)sender
{
	currentTime = 0;
	[self updateTimeLabel];
}

- (IBAction)manualBell:(id)sender
{
	AudioServicesPlaySystemSound(sound_bell1);
}

- (IBAction)bellButtonTapped:(id)sender
{
	int sec;
	int editingItem;
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

	timePickerVC.seconds = sec;
	timePickerVC.editingItem = editingItem;

	[self presentModalViewController:timeNaviC animated:YES];
}

- (IBAction)invertCountDown:(id)sender
{
	isCountDown = !isCountDown;
	[self updateTimeLabel];
}

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
	NSURL *url = [NSURL URLWithString:NSLocalizedString(@"HelpURL", @"")];
	[[UIApplication sharedApplication] openURL:url];
}

@end
