//
//  MenuBarVC.h
//  Mockup02
//
//  Created by Katanyoo Ubalee on 8/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemBarVC.h"

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
@property (nonatomic, assign) id<MenuBarVCDelegate> delegate;

- (void)scrollToPage:(NSInteger)page;

@end
