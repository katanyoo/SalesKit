//
//  MenuBarVC.m
//  Mockup02
//
//  Created by Katanyoo Ubalee on 8/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MenuBarVC.h"
#import "UIConfig.h"


@implementation MenuBarVC

@synthesize viewList;
@synthesize menus;
@synthesize managedObjectContext;
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

#pragma mark - Data Manager

- (void)readData
{
    /*
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Menu" ofType:@"plist"];
    NSDictionary *menuData = [NSDictionary dictionaryWithContentsOfFile:filePath];
    self.menus = [menuData objectForKey:@"menu"];
    */
    
    if (self.menus) {
        [self.menus release];
        self.menus = nil;
        self.menus = [NSArray array];
    }
    SalesKitAppDelegate *appDelegate = (SalesKitAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    
    NSError *error;
    NSMutableArray *mutableFetchResults = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    
    if (mutableFetchResults == nil) {
        MIPLog(@"Couldn't fetch data");
    }
    else if ([mutableFetchResults count] == 0) {
        MIPLog(@"Have no data");
    }
    else {
        self.menus = [mutableFetchResults mutableCopy];
    }
}

#pragma mark - ItemBar Delegate

- (void)subItemDidSelected:(ItemVC *)item
{
    if ([delegate respondsToSelector:@selector(subItemDidSelected:)]) {
        [delegate subItemDidSelected:item];
    }
}

#pragma mark - Main Scroll

- (void)loadScrollViewWithPage:(int)page
{
    if (page < 0)
        return;
    if (page >= [self.menus count])
        return;
    
    // replace the placeholder if necessary
    ItemBarVC *itemBar = [self.viewList objectAtIndex:page];
    
    if ((NSNull *)itemBar == [NSNull null])
    {
        itemBar = [[ItemBarVC alloc] init];
        itemBar.delegate = self;
        
        [self.viewList replaceObjectAtIndex:page withObject:itemBar];
        [itemBar release];
    }
    
    // add the ImageView to the scroll view
    if (itemBar.view.superview == nil)
    {
        UIScrollView *menuBarScroll = (UIScrollView *)self.view;
        CGRect frame = CGRectMake(self.view.bounds.size.width * page,
                                  0,
                                  self.view.bounds.size.width,
                                  self.view.bounds.size.height);
        itemBar.view.frame = frame;
        itemBar.view.backgroundColor = [UIColor clearColor];
        /*
        itemBar.view.backgroundColor = [UIColor colorWithRed:0.9 * page
                                                       green:0.5
                                                        blue:0.2
                                                       alpha:1.0];
        */
        /*
        Category *cat = (Category *)[self.menus objectAtIndex:page];
                                     
        NSFetchRequest *tmpRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *tmpEntity = [NSEntityDescription entityForName:@"SubCategory" inManagedObjectContext:self.managedObjectContext];
        [tmpRequest setEntity:tmpEntity];
        
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"CategoryItem = %@", cat];
        [tmpRequest setPredicate:pred];
        
        NSError *tmpError;
        NSArray *tmpResult = [self.managedObjectContext executeFetchRequest:tmpRequest error:&tmpError];
        if (tmpResult == nil) {
            MIPLog(@"Fetch SubCategory Node Error!!");
        }
        else if ([tmpResult count] == 0) {
            MIPLog(@"Have no SubCategory Node");
        }
        else {
            MIPLog(@"item count = %i", [tmpResult count]);
            MIPLog(@"items = %@", [[tmpResult objectAtIndex:0] image]);
            [itemBar setupBarWithItems:tmpResult];
            [menuBarScroll addSubview:itemBar.view];
        }
        */
        NSArray *items = [[((Category *)[self.menus objectAtIndex:page]) subCategoryItems] allObjects];
        MIPLog(@"item count = %i", [items count]);
        //MIPLog(@"items = %@", [[items objectAtIndex:0] image]);
        [itemBar setupBarWithItems:items];
        
        [menuBarScroll addSubview:itemBar.view];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    if (pageControlUsed)
    {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }
	
    // Switch the indicator when more than 50% of the previous/next page is visible
    UIScrollView *mainScroll = (UIScrollView *)self.view;
    CGFloat pageWidth = mainScroll.frame.size.width;
    int page = floor((mainScroll.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    //pageControl.currentPage = page;
    currentPage = page;
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
    // A possible optimization would be to unload the views+controllers which are no longer visible
}

// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
}

- (void)scrollToPage:(NSInteger)page
{
    UIScrollView *menuScroll = (UIScrollView *)self.view;
    
    CGRect frame = menuScroll.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    
    [menuScroll scrollRectToVisible:frame animated:YES];
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/
- (void) reloadView
{
    [self readData];
    
    NSMutableArray *views = [[NSMutableArray alloc] init];
    for (unsigned i = 0; i < [self.menus count]; i++)
    {
		[views addObject:[NSNull null]];
    }
    self.viewList = views;
    [views release];
    
    UIScrollView *tempScrollView=(UIScrollView *)self.view;
    tempScrollView.delegate = self;
    
    tempScrollView.frame = CGRectMake(0, LANDSCAPE_HEIGHT - MENUBAR_HEIGHT, LANDSCAPE_WIDTH, MENUBAR_HEIGHT);
    tempScrollView.contentSize = CGSizeMake(LANDSCAPE_WIDTH * [self.menus count],
                                            MENUBAR_HEIGHT);
    
    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor clearColor];
    
    [self reloadView];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

@end
