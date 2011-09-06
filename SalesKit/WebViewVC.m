//
//  WebViewVC.m
//  Mockup02
//
//  Created by Katanyoo Ubalee on 8/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WebViewVC.h"
//#import "MyWebView.h"


@implementation WebViewVC

@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Pinch Delegate


- (IBAction)handlePinchGesture:(UIPinchGestureRecognizer *)sender {
//    CGFloat factor = [(UIPinchGestureRecognizer *)sender scale];
//    self.view.transform = CGAffineTransformMakeScale(factor, factor);
    
    if (sender.scale < 0.5) {
        if ([delegate respondsToSelector:@selector(pinchedIn)]) {
            [delegate pinchedIn];
        }
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIWebView *myWebView = (UIWebView *)self.view;
    
    UIPinchGestureRecognizer *pinching = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    
    [myWebView addGestureRecognizer:pinching];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
