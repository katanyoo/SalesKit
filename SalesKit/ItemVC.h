//
//  ItemVC.h
//  Mockup02
//
//  Created by Katanyoo Ubalee on 8/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubMenuItem.h"

@protocol ItemVCDelegate;

@interface ItemVC : UIViewController {

    SubMenuItem *itemData;
    UIButton *buttonItem;
}

@property (nonatomic, retain) id<ItemVCDelegate> delegate;

- (id)initWithItem:(SubMenuItem *)item;
- (NSString *) URLForWeb;

@end


@protocol ItemVCDelegate <NSObject>

@optional
- (void)itemDidSelected:(ItemVC *)item;

@end