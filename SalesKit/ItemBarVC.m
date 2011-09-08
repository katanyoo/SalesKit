//
//  ItemBarVC.m
//  Mockup02
//
//  Created by Katanyoo Ubalee on 8/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ItemBarVC.h"


@implementation ItemBarVC

@synthesize items;
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
#pragma mark - Item Delegate

- (void)itemDidSelected:(ItemVC *)item
{
    if ([delegate respondsToSelector:@selector(subItemDidSelected:)]) {
        [delegate subItemDidSelected:item];
    }
}


#pragma mark - Setup Item

- (void)setupBarWithItems:(NSArray *)buttonItems
{
    if (self.items) {
        [self.items release];
        self.items = nil;
        self.items = [NSArray array];
    }
    self.items = buttonItems;
    
    int orginX = 0;
    for (SubMenuItem *item in self.items) {
        ItemVC *itemVC = [[ItemVC alloc] initWithItem:item];
        itemVC.delegate = self;
        
        UIScrollView *scroll = (UIScrollView *)self.view;
        scroll.contentSize = CGSizeMake(orginX + itemVC.view.frame.size.width, itemVC.view.frame.size.height);
        
        itemVC.view.frame = CGRectMake(orginX, 0, itemVC.view.frame.size.width, itemVC.view.frame.size.height);
        orginX += itemVC.view.frame.size.width;
        
        [scroll addSubview:itemVC.view];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //NSLog(@"items = %@", self.items);
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
