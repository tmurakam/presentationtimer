/*
  Presentation Timer for iOS

  Copyright (c) 2008-2018, Takuya Murakami, All rights reserved.

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

@interface TimePickerViewController()
{
    //IBOutlet UIDatePicker *mPicker;
    IBOutlet UIPickerView *mPickerView;
    IBOutlet UIButton *mCdtButton;
	
    NSInteger mSeconds;
    
    id<TimePickerViewDelegate> __unsafe_unretained mDelegate;
}
@end

@implementation TimePickerViewController

@synthesize seconds = mSeconds;
@synthesize delegate = mDelegate;

- (instancetype)init
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
    [mCdtButton setTitle:title forState:UIControlStateNormal];
    [mCdtButton setTitle:title forState:UIControlStateHighlighted];
}

- (void)viewDidAppear:(BOOL)animated {
    [self setupLabel:mPickerView];
}

- (void)setupLabel:(UIPickerView *)picker
{
    NSString *titles[] = {@"hour", @"min", @"sec"};
    CGSize size = picker.frame.size;
    
    for (NSInteger i = 0; i < 3; i++) {
        CGRect rect = CGRectMake(42 + (size.width / 3) * i, size.height / 2 - 15, 75, 30);
        UILabel *label = [[UILabel alloc] initWithFrame:rect];
        label.text = titles[i];
        [picker addSubview:label];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    //TODO:
    //mPicker.countDownDuration = (double)mSeconds;
    
    NSInteger hour = mSeconds / 3600;
    NSInteger min = (mSeconds / 60) % 60;
    NSInteger sec = mSeconds % 60;
    
    [mPickerView selectRow:hour inComponent:0 animated:NO];
    [mPickerView selectRow:min inComponent:1 animated:NO];
    [mPickerView selectRow:sec inComponent:2 animated:NO];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    switch (component) {
        case 0:
            return 10;
        default:
            return 60;
    }
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [NSString stringWithFormat:@"%ld", (long)row];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *columnView = [[UILabel alloc] initWithFrame:CGRectMake(35, 0, self.view.frame.size.width/3 - 35, 30)];
    columnView.text = [NSString stringWithFormat:@"%lu", (long) row];
    columnView.textAlignment = NSTextAlignmentLeft;
    
    return columnView;
}

/*
- (NSString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    switch (component) {
        case 0:
            return @"hour";
        case 1:
            return @"min";
        case 2:
        default:
            return @"sec";
    }
}
*/

- (IBAction)onDone:(id)sender
{
    NSInteger hour = [mPickerView selectedRowInComponent:0];
    NSInteger min = [mPickerView selectedRowInComponent:1];
    NSInteger sec = [mPickerView selectedRowInComponent:2];

    mSeconds = hour * 3600 + min * 60 + sec;
    [mDelegate timePickerViewSetTime:mSeconds];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onCancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onSetCountdownTarget:(id)sender
{
    [mDelegate timePickerViewSetCountdownTarget];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didReceiveMemoryWarning {
    //[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
}


@end
