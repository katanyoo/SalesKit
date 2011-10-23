//
//  MenuBarVC.h
//  Mockup02
//
//  Created by Katanyoo Ubalee on 8/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SalesKitAppDelegate.h"
#import "ItemBarVC.h"
#import "Category.h"
#import "SubCategory.h"

@protocol MenuBarVCDelegate <NSObject>

@optional
- (void)subItemDidSelected:(ItemVC *)item;

@end

@interface MenuBarVC : UIViewController
<UIScrollViewDelegate, ItemBarVCDelegate>
{

    ItemBarVC *itemBarVC;
    
    BOOL pageControlUsed;
    NSInteger currentPage;
}

@property (nonatomic, retain) NSMutableArray *viewList;
@property (nonatomic, retain) NSArray *menus;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, assign) id<MenuBarVCDelegate> delegate;

- (void) reloadView;
- (void)scrollToPage:(NSInteger)page;

@end
