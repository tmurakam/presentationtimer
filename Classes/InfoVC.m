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

#import "InfoVC.h"

@interface InfoVC()
{
    IBOutlet UILabel *mNameLabel;
    IBOutlet UILabel *mVersionLabel;
}

- (void)doneAction:(id)sender;
- (IBAction)webButtonTapped;
@end

@implementation InfoVC

- (instancetype)init
{
    if (self = [super initWithNibName:@"InfoView" bundle:nil]) {
    }
    return self;
}

/*
// Implement loadView to create a view hierarchy programmatically.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Info", @"");
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc]
      initWithBarButtonSystemItem:UIBarButtonSystemItemDone
      target:self
      action:@selector(doneAction:)];

    NSString *version = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleVersion"];
    mVersionLabel.text = [NSString stringWithFormat:@"Version %@", version];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)doneAction:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)webButtonTapped
{
    NSURL *url = [NSURL URLWithString:NSLocalizedString(@"HelpURL", @"web help url")];
    [[UIApplication sharedApplication] openURL:url];
}

/*
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationPortrait;
}
*/

@end
