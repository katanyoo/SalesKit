//
//  Mockup02ViewController.h
//  Mockup02
//
//  Created by Katanyoo Ubalee on 8/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "MenuCoverVC.h"
#import "MenuBarVC.h"
#import "WebViewVC.h"
//#import "WowCoverVC.h"

#import "HMGLTransitionManager.h"

@interface Mockup02ViewController : UIViewController
<MenuCoverVCDelegate, MenuBarVCDelegate, WebViewVCDelegate, UIWebViewDelegate>
{
    IBOutlet UIView *bigView;
    
    IBOutlet MenuCoverVC *mainScrollVC;
    IBOutlet MenuBarVC *menuBarVC;
    IBOutlet WebViewVC *webViewVC;
    //IBOutlet WowCoverVC *mainScrollVC;
    
    BOOL closed;
    
    IBOutlet UIPageControl *pageControl;
    IBOutlet UILabel *pageName;
    
    UIButton *close_bt;
    
    BOOL showingWeb;
    //HMGLTransition *transition;
}

@end
