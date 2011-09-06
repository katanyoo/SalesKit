//
//  SettingViewController.h
//  SalesKit
//
//  Created by Katanyoo Ubalee on 8/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SyncManager.h"

@interface SettingViewController : UIViewController 
<SyncManagerDelegate>
{
    IBOutlet UILabel *syncingStatus;
    IBOutlet UIActivityIndicatorView *indicatorView;
    IBOutlet UITextField *syncURLField;
}

- (IBAction) startSync;
+ (SettingViewController *)shared;

@property (nonatomic, retain) IBOutlet UIProgressView *progressView;

@end
