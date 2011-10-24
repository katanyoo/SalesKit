//
//  MenuCoverVC.h
//  Mockup02
//
//  Created by Katanyoo Ubalee on 8/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SalesKitAppDelegate.h"
#import "Category.h"

@protocol MenuCoverVCDelegate <NSObject>

@optional
- (void) scrollView:(UIScrollView *)scrollView didEndDeceleratingAtPage:(NSInteger)page andPageName:(NSString *)name;

@end

@interface MenuCoverVC : UIViewController
<UIScrollViewDelegate>
{
    
    BOOL pageControlUsed;
    NSInteger currentPage;
}

@property (nonatomic, retain) NSMutableArray *viewList;
@property (nonatomic, retain) NSArray *menus;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, assign) id<MenuCoverVCDelegate> delegate;

- (NSInteger) numberOfPage;
- (void) reloadView;
- (NSString *) currentPageName;
- (NSInteger) currentPage;

@end
