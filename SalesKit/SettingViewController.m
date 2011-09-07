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

- (void)syncManagerDidFinishSyncVersionWithItemCount:(NSInteger)count
{
    
    if (count > 0) {
        if ([delegate respondsToSelector:@selector(needSync:)]) {
            [delegate needSync:YES];
        }
    }
    else {
        if ([delegate respondsToSelector:@selector(needSync:)]) {
            [delegate needSync:NO];
        }
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

- (void) updateStatus:(NSString *)status onState:(MIPSyncStatus)state
{
    syncingStatus.text = status;
    
    if (state == MIPSyncStatusError) {
        syncingStatus.textColor = [UIColor redColor];
    }
    else if (state == MIPSyncStatusNormal) {
        syncingStatus.textColor = [UIColor lightGrayColor];
    }
    else if (state == MIPSyncStatusFinish) {
        syncingStatus.textColor = [UIColor greenColor];
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
    return [NSURL URLWithString:syncURLField.text];
}

- (IBAction) startSync
{
    [[SyncManager shared] startSyncWithURL:[self urlForSync]];// grabURLInBackground:[self urlForSync]];
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
    [self startSync];
    
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
