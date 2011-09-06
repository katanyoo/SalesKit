//
//  ItemBarVC.h
//  Mockup02
//
//  Created by Katanyoo Ubalee on 8/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemVC.h"

@protocol ItemBarVCDelegate <NSObject>

@optional
- (void) subItemDidSelected:(ItemVC *)item;

@end

@interface ItemBarVC : UIViewController
<ItemVCDelegate>
{
    
}

@property (nonatomic, retain) NSArray *items;
@property (nonatomic, assign) id<ItemBarVCDelegate> delegate;

- (void)setupBarWithItems:(NSArray *)buttonItems;

@end
