//
//  TimePickerViewController.h
//  PresentationTimer
//
//  Created by 村上 卓弥 on 08/09/13.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PresentationTimerViewController;

@interface TimePickerViewController : UIViewController {
	IBOutlet UIDatePicker *picker;
	IBOutlet UIButton *cdtButton;
	
	int editingItem;
	int seconds;
	
	PresentationTimerViewController *presentationTimerVC;
}

@property(nonatomic,assign) int editingItem;
@property(nonatomic,assign) int seconds;
@property(nonatomic,assign) PresentationTimerViewController* presentationTimerVC;

- (IBAction)onDone:(id)sender;
- (IBAction)onCancel:(id)sender;
- (IBAction)onSetCountdownTarget:(id)sender;

@end
