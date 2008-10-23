//
//  TimePickerViewController.m
//  PresentationTimer
//
//  Created by 村上 卓弥 on 08/09/13.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TimePickerViewController.h"
#import "PresentationTimerViewController.h"


@implementation TimePickerViewController

@synthesize seconds;
@synthesize editingItem;
@synthesize presentationTimerVC;

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

// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	picker.datePickerMode = UIDatePickerModeCountDownTimer;
	
	self.title = @"Set Time";
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
		target:self action:@selector(onCancel:)];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
		target:self action:@selector(onDone:)];
	
	NSString *title = NSLocalizedString(@"Use as presentation end time", @"");
	[cdtButton setTitle:title forState:UIControlStateNormal];
	[cdtButton setTitle:title forState:UIControlStateHighlighted];
}

- (void)viewWillAppear:(BOOL)animated
{
	picker.countDownDuration = (double)seconds;
}

- (IBAction)onDone:(id)sender
{
	seconds = (int)picker.countDownDuration;
	if (seconds > 99*60) {
		seconds = 99*60;
	}
	seconds -= (seconds % 60); // for safety
	switch (editingItem) {
		case 1:
			presentationTimerVC.bell1Time = seconds;
			break;
		case 2:
			presentationTimerVC.bell2Time = seconds;
			break;
		case 3:
			presentationTimerVC.bell3Time = seconds;
			break;
	}
	[presentationTimerVC updateButtonTitle];
	
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)onCancel:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)onSetCountdownTarget:(id)sender
{
	presentationTimerVC.countDownTarget = editingItem;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
    [super dealloc];
}


@end
