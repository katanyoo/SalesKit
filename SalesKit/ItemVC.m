//
//  ItemVC.m
//  Mockup02
//
//  Created by Katanyoo Ubalee on 8/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ItemVC.h"

#define DOCUMENTSPATH [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

//static NSString *ImageKey = @"image";
//static NSString *URLKey = @"linkto";

@implementation ItemVC

@synthesize delegate;

- (id)initWithItem:(SubCategory *)item {
    self = [super init];
    if (self) {
        itemData = item;
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

#pragma mark - Event

- (void)openURL
{
    if ([delegate respondsToSelector:@selector(itemDidSelected:)]) {
        [delegate itemDidSelected:self];
    }
}

#pragma mark - Methods

- (NSString *) URLForWeb
{
    return itemData.linkto;
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    MIPLog(@"%@", itemData.image);
    UIImage *img = [UIImage imageWithContentsOfFile:
                    [DOCUMENTSPATH stringByAppendingPathComponent:itemData.image]];
    
    buttonItem = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonItem.frame = CGRectMake(0, 
                                  0, 
                                  img.size.width, 
                                  img.size.height);
    [buttonItem setBackgroundImage:img forState:UIControlStateNormal];
    [buttonItem addTarget:self action:@selector(openURL) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.view.frame = buttonItem.frame;
    [self.view addSubview:buttonItem];

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
