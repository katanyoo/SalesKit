//
//  MenuCoverVC.m
//  Mockup02
//
//  Created by Katanyoo Ubalee on 8/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MenuCoverVC.h"
#import "UIConfig.h"

#define DOCUMENTSPATH [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

//static NSString *ImageKey = @"cover";
//static NSString *pageNameKey = @"pagename";

@implementation MenuCoverVC

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
    
    NSSortDescriptor *sortByWeight = [[NSSortDescriptor alloc] initWithKey:@"weight" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sortByWeight]];
    [sortByWeight release];
    
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


#pragma mark - Main Scroll

- (void)loadScrollViewWithPage:(int)page
{
    if (page < 0)
        return;
    if (page >= [self.menus count])
        return;
    
    // replace the placeholder if necessary
    UIImageView *cover = [self.viewList objectAtIndex:page];
    
    if ((NSNull *)cover == [NSNull null])
    {
        NSString *imageName = ((Category *)[self.menus objectAtIndex:page]).cover;
//        cover = [[UIImageView alloc] initWithImage:
//                 [UIImage imageWithContentsOfFile:
//                  [DOCUMENTSPATH stringByAppendingPathComponent:imageName]]];

        cover = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:imageName]];
        
        [self.viewList replaceObjectAtIndex:page withObject:cover];
        [cover release];
    }
    
    // add the ImageView to the scroll view
    if (cover.superview == nil)
    {
        UIScrollView *mainScroll = (UIScrollView *)self.view;
        cover.frame = CGRectMake(LANDSCAPE_WIDTH * page, 0, LANDSCAPE_WIDTH, LANDSCAPE_HEIGHT);
        [mainScroll addSubview:cover];
        
        NSString *imageName = ((Category *)[self.menus objectAtIndex:page]).cover;
//        cover.image = [UIImage imageWithContentsOfFile:
//                       [DOCUMENTSPATH stringByAppendingPathComponent:imageName]];
        
        cover.image = [UIImage imageWithContentsOfFile:imageName];
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
    
    if ([delegate respondsToSelector:@selector(scrollView:didEndDeceleratingAtPage:andPageName:)]) {
        [delegate scrollView:(UIScrollView *)self.view didEndDeceleratingAtPage:currentPage andPageName:[[self.menus objectAtIndex:currentPage] pageName]];
    }
}

#pragma mark - Method

- (NSInteger) currentPage
{
    return currentPage;
}

- (NSString *) currentPageName
{
    return [[self.menus objectAtIndex:currentPage] pageName];
}
- (NSInteger) numberOfPage
{
    return [self.menus count];
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
    

    
    UIScrollView *mainScroll = (UIScrollView *)self.view;
    mainScroll.delegate = self;
    mainScroll.backgroundColor = [UIColor grayColor];
    mainScroll.contentSize = CGSizeMake(LANDSCAPE_WIDTH * [self.menus count],
                                        LANDSCAPE_HEIGHT);
    
    //mainScroll.frame = CGRectMake(0, 100, 1024, 668);
    
    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor grayColor];
    
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
