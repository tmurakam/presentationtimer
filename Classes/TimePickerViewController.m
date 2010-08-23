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

#import "TimePickerViewController.h"

@implementation TimePickerViewController

@synthesize seconds;
@synthesize delegate;

- (id)init
{
    self = [super initWithNibName:@"TimePickerViewController" bundle:nil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
    //picker.datePickerMode = UIDatePickerModeCountDownTimer;
	
    self.title = @"Set Time";
    self.navigationItem.leftBarButtonItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                      target:self
                                                      action:@selector(onCancel:)];
    self.navigationItem.rightBarButtonItem = 
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                      target:self 
                                                      action:@selector(onDone:)];
	
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
    [delegate timePickerViewSetTime:seconds];
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)onCancel:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)onSetCountdownTarget:(id)sender
{
    [delegate timePickerViewSetCountdownTarget];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didReceiveMemoryWarning {
    //[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
}

- (void)dealloc {
    [super dealloc];
}

@end
