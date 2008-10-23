//
//  PresentationTimerAppDelegate.h
//  PresentationTimer
//
//  Created by 村上 卓弥 on 08/09/13.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PresentationTimerViewController;

@interface PresentationTimerAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    PresentationTimerViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet PresentationTimerViewController *viewController;

@end

