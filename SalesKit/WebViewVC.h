//
//  WebViewVC.h
//  Mockup02
//
//  Created by Katanyoo Ubalee on 8/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WebViewVCDelegate <NSObject>

@optional
- (void) pinchedIn;

@end

@interface WebViewVC : UIViewController {
    
}

@property (nonatomic, assign) id<WebViewVCDelegate> delegate;

@end
