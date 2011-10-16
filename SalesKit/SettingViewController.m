//
//  SettingViewController.m
//  SalesKit
//
//  Created by Katanyoo Ubalee on 8/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingViewController.h"
#import "JSONKit.h"
#import "UIConfig.h"

@implementation SettingViewController

@synthesize progressView;
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


#pragma mark - SyncManager Delegate

- (void)syncManagerDidFinishUpdateDatabase
{
    [self endSync];
}

- (void)syncManagerDidFinishSyncVersionWithItemCount:(NSInteger)count
{

    MIPLog(@"count = %i", count);    
    if (count > 0) {
        if ([delegate respondsToSelector:@selector(needSync:)]) {
            [delegate needSync:YES];
        }
    }
    else {
        [self endSync];
    }
    /*
    MIPLog(@"sync count = %i", count);
    MIPLog(@"%@", [self.view viewWithTag:MAINVIEW_TAG]);
    if (count > 0) {
        
        CGRect rect = [self.view viewWithTag:MAINVIEW_TAG].bounds;
        rect.origin = CGPointMake(0, 200);
        
        [UIView beginAnimations:nil context:nil]; 
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.5]; 
        
        //[self.view viewWithTag:MAINVIEW_TAG].frame = rect;
        
        [UIView commitAnimations];
         
    }
     */
}

- (void)syncManagerDidFinishSyncVersionWithJSONString:(NSString *)responseString
{
    
}

- (void) syncManagerDidFinishLogin:(NSString *)message
{
    //MIPLog(@"login success");
    responseStatus.text = message;
    
    if ([delegate respondsToSelector:@selector(needSync:)]) {
        [delegate needSync:YES];
    }
}

- (void) syncManagerDidFinishLogout
{
    responseStatus.text = @"Logout Success";
    
    if ([delegate respondsToSelector:@selector(needSync:)]) {
        [delegate needSync:YES];
    }
}

- (void) updateStatus:(NSString *)status onState:(MIPSyncStatus)state
{
    responseStatus.text = status;
    
    if (state == MIPSyncStatusError) {
        responseStatus.textColor = [UIColor redColor];
    }
    else if (state == MIPSyncStatusNormal) {
        responseStatus.textColor = [UIColor lightGrayColor];
    }
    else if (state == MIPSyncStatusFinish) {
        responseStatus.textColor = [UIColor greenColor];
    }
    
    if (state == MIPSyncStatusFinish || state == MIPSyncStatusError) {
        [indicatorView stopAnimating];
    }
    else
    {
        [indicatorView startAnimating];
    }
}

#pragma mark - Object Methods

- (NSURL *) urlForSync
{
//    return [NSURL URLWithString:syncURLField.text];
    return nil;
}

- (IBAction) login
{
    [[SyncManager shared] loginWithUsername:usernameField.text password:passwordField.text];
}

- (IBAction) logout
{
    [[SyncManager shared] logout];
}

- (IBAction) startSync
{
    //[[SyncManager shared] startSyncWithURL:[self urlForSync]];// grabURLInBackground:[self urlForSync]];
    [[SyncManager shared] startSync];
    
}

- (void) endSync
{
    if ([delegate respondsToSelector:@selector(needSync:)]) {
        [delegate needSync:NO];
    }
}

#pragma mark - Shared Method

static SettingViewController *shared = nil;

+ (SettingViewController *) shared
{
    @synchronized(self)
    {
        if (shared == nil)
        {
            shared = [[SettingViewController alloc] init];
        }
    }
    return shared;
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImage *bg = [UIImage imageNamed:@"setting_bg.png"];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:bg];
    
    //[self.view viewWithTag:MAINVIEW_TAG].frame = CGRectMake(0, 0, 1024, 768);
    
    [SyncManager shared].delegate = self;
    //[self startSync];
    [self login];
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
	return interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight;
}

@end
