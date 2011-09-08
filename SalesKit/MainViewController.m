//
//  Mockup02ViewController.m
//  Mockup02
//
//  Created by Katanyoo Ubalee on 8/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"
#import "UIConfig.h"
//#import "MyWebView.h"
#import "Switch3DTransition.h"
#import "SettingViewController.h"

#define DOCUMENTSPATH [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

@interface MainViewController()

@property (nonatomic, retain) HMGLTransition *transition;
@property (nonatomic, retain) UIButton *close_bt;

@end


@implementation MainViewController

@synthesize transition;
@synthesize close_bt;


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


#pragma mark - Web View Life Cycle

- (UIView *)viewForEvent: (NSString *)event 
{
	
	CGRect frame = CGRectMake((LANDSCAPE_WIDTH - 130)/2, (LANDSCAPE_HEIGHT - 130)/2, 130, 130);
	UIView *view = [[[UIView alloc] initWithFrame:frame] autorelease];
	view.layer.cornerRadius = 10.0;
	view.tag = 777;
	
	UILabel *message = [[[UILabel alloc] initWithFrame:CGRectMake(0, 80, 130, 50)] autorelease];
	view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
	
	if ([event isEqualToString:@"Loading..."]) {
		UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] 
												  initWithFrame:CGRectMake(55, 55, 20, 20)];
		[indicatorView startAnimating];
		[view addSubview:indicatorView];
		[indicatorView release];
		
	}
	else {
		UIImageView *failImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fail.png"]];
		failImage.frame = CGRectMake(45, 45, 40, 40);
		[view addSubview:failImage];
		[failImage release];
	}
	message.text = event;
	message.textColor = [UIColor whiteColor];
	message.textAlignment = UITextAlignmentCenter;
	message.numberOfLines = 2;
	message.font = [UIFont boldSystemFontOfSize:15.0];
	message.backgroundColor = [UIColor clearColor];
	
	[view addSubview:message];
	return view;
}

- (void) closeWeb
{
    if (closed) {
        return;
    }
    
    //NSLog(@"close");
    closed = YES;
    
    //webViewVC.view.frame = CGRectMake(0, 0, WEBVIEW_WIDTH, WEBVIEW_HEIGHT);
    
    [UIView beginAnimations:nil context:nil]; 
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:1.0]; 
	
    close_bt.alpha = 0.0;

	[UIView commitAnimations];
    

    //[self.close_bt removeFromSuperview];
    
    UIView *containerView = webViewVC.view.superview;
    int index = 0;
    
    for (UIView *tmp in [containerView subviews]) {
        if (tmp.tag == WEBVIEW_TAG) {
            break;
        }
        ++index;
    }
    
    ((Switch3DTransition *)self.transition).transitionType = Switch3DTransitionLeft;
    
    [[HMGLTransitionManager sharedTransitionManager] setTransition:self.transition];	
	[[HMGLTransitionManager sharedTransitionManager] beginTransition:containerView];
    
    [webViewVC.view removeFromSuperview];
    [containerView insertSubview:mainScrollVC.view atIndex:index];
    
    [[HMGLTransitionManager sharedTransitionManager] commitTransition];
    
    showingWeb = NO;
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    closed = NO;
    
    //webViewVC.view.frame = CGRectMake(0, WEBVIEW_HEIGHT/2, 0, 0);
    
	[UIView beginAnimations:nil context:nil]; 
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:1.0]; 
	
    close_bt.alpha = 1.0;
    //webViewVC.view.frame = CGRectMake(0, 0, WEBVIEW_WIDTH, WEBVIEW_HEIGHT);
    
	[UIView commitAnimations];
	
    
	[[self.view viewWithTag:777] removeFromSuperview];

    if (showingWeb) return;
    
    UIView *containerView = mainScrollVC.view.superview;
    
    int index = 0;
    
    for (UIView *tmp in [containerView subviews]) {
        if (tmp.tag == MAINSCROLL_TAG) {
            break;
        }
        ++index;
    }
    
    ((Switch3DTransition *)self.transition).transitionType = Switch3DTransitionRight;
    
    [[HMGLTransitionManager sharedTransitionManager] setTransition:self.transition];	
	[[HMGLTransitionManager sharedTransitionManager] beginTransition:containerView];
    
    [mainScrollVC.view removeFromSuperview];
    [containerView insertSubview:webViewVC.view atIndex:index];
    
    [[HMGLTransitionManager sharedTransitionManager] commitTransition];
	//[webViewVC release];
    
    showingWeb = YES;
}

#pragma mark - Setting Panel Delegate

- (void)needSync:(BOOL)needSync
{
    if (needSync) {
        
        CGRect rect = mainScrollVC.view.frame;
        rect.origin = CGPointMake(0, 200);
        //rect.origin = CGPointMake(0, 0);
        
        [UIView beginAnimations:nil context:nil]; 
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.5]; 
        
        mainScrollVC.view.frame = rect;
        
        [UIView commitAnimations];
    }
    else {
        CGRect rect = mainScrollVC.view.frame;
        rect.origin = CGPointMake(0, 0);
        
        [UIView beginAnimations:nil context:nil]; 
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.5]; 
        
        mainScrollVC.view.frame = rect;
        
        [UIView commitAnimations];
        
        [self reloadView];
    }
}

#pragma mark - WebViewVC Delegate

- (void) pinchedIn
{
    [self closeWeb];
}

#pragma mark - Scroll Delegate

- (void) scrollView:(UIScrollView *)scrollView didEndDeceleratingAtPage:(NSInteger)page andPageName:(NSString *)name
{
    [menuBarVC scrollToPage:page];
    pageControl.currentPage = page;
    
    pageName.text = name;
}

#pragma mark - MenuBar Delegate

- (void)subItemDidSelected:(ItemVC *)item
{    
    //NSString *htmlPath = [[NSBundle mainBundle] pathForResource:[item URLForWeb] ofType:@""];
    NSString *htmlPath = [DOCUMENTSPATH stringByAppendingPathComponent:[item URLForWeb]];
    MIPLog(@"html path = %@", htmlPath);
    NSString *HTMLData = [NSString stringWithContentsOfFile:htmlPath
                                                   encoding:NSUTF8StringEncoding 
                                                      error:nil];
    
    //NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *path = [htmlPath stringByDeletingLastPathComponent];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    
    [self.view addSubview:[self viewForEvent:@"Loading..."]];
    
    [(UIWebView *)webViewVC.view loadHTMLString:HTMLData baseURL:baseURL];
    
}

#pragma mark - View lifecycle

- (void)reloadView
{
    SettingViewController *settingVC = [SettingViewController shared];
    settingVC.delegate = self;
    [bigView addSubview:settingVC.view];
    
    mainScrollVC.delegate = self;
    mainScrollVC.view.tag = MAINSCROLL_TAG;
    [mainScrollVC reloadView];
    [bigView addSubview:mainScrollVC.view];
    
    
    //pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(-125, WEBVIEW_HEIGHT - PAGECONTROL_HEIGHT, PAGECONTROL_WIDTH, PAGECONTROL_HEIGHT)];
    
    //pageControl.center = self.view.center;
    pageControl.frame = CGRectMake(0, WEBVIEW_HEIGHT - pageControl.frame.size.height - 10,
                                   pageControl.frame.size.width, pageControl.frame.size.height);
    
    //[self.view addSubview:pageControl];
    //pageControl.backgroundColor = [UIColor blackColor];
    pageControl.currentPage = 0;
    //pageControl.numberOfPages = [mainScrollVC numberOfPage];
    
    pageName.backgroundColor = [UIColor clearColor];
    pageName.frame = CGRectMake(pageName.frame.origin.x, 
                                WEBVIEW_HEIGHT - pageControl.frame.size.height - pageName.frame.size.height,
                                pageName.frame.size.width, 
                                pageName.frame.size.height);
    //[self.view addSubview:pageName];
    
    UIWebView *web = (UIWebView *)webViewVC.view;
    web.delegate = self;
    
    webViewVC.view.tag = WEBVIEW_TAG;
    webViewVC.delegate = self;
    //webViewVC.view.alpha = 1.0;
    //webViewVC.view.frame = CGRectMake(0, WEBVIEW_HEIGHT/2, 0, 0);
    webViewVC.view.frame = CGRectMake(0, 0, WEBVIEW_WIDTH, WEBVIEW_HEIGHT);
    
    for (id subview in webViewVC.view.subviews)
        if ([[subview class] isSubclassOfClass: [UIScrollView class]])
        {
            ((UIScrollView *)subview).bounces = NO;
            ((UIScrollView *)subview).showsVerticalScrollIndicator = NO;
            ((UIScrollView *)subview).showsHorizontalScrollIndicator = NO;
        }
    
    //[self.view addSubview:webViewVC.view];
    
    self.close_bt = [UIButton buttonWithType:UIButtonTypeCustom];
    self.close_bt.frame = CGRectMake(20, 540, 50, 50);
    self.close_bt.alpha = 0.0;
    [self.close_bt setBackgroundImage:[UIImage imageNamed:@"close_button.png"] forState:UIControlStateNormal];
    [self.close_bt addTarget:self action:@selector(closeWeb) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:close_bt];
    
    
    menuBarVC.delegate = self;
    [menuBarVC reloadView];
    [self.view addSubview:menuBarVC.view];   
    
    [HMGLTransitionManager sharedTransitionManager];
    
    self.transition = [[[Switch3DTransition alloc] init] autorelease];
    
    showingWeb = NO;
}
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self reloadView];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    MIPLog(@"view did appear");

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

@end
