//
//  SettingViewController.h
//  SalesKit
//
//  Created by Katanyoo Ubalee on 8/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SyncManager.h"

@protocol SettingViewControllerDelegate <NSObject>

@optional
- (void)needSync:(BOOL)needSync;

@end

@interface SettingViewController : UIViewController 
<SyncManagerDelegate>
{
    IBOutlet UILabel *responseStatus;
    IBOutlet UITextView *syncStatusView;
    IBOutlet UIActivityIndicatorView *indicatorView;
    //IBOutlet UITextField *syncURLField;
    IBOutlet UITextField *usernameField;
    IBOutlet UITextField *passwordField;
    
}

- (IBAction) startSync;
- (IBAction) login;
- (IBAction) logout;
- (void) endSync;
+ (SettingViewController *)shared;

@property (nonatomic, retain) IBOutlet UIProgressView *progressView;
@property (nonatomic, assign) id<SettingViewControllerDelegate>delegate;

@end
