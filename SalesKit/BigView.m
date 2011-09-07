//
//  BigView.m
//  SalesKit
//
//  Created by Katanyoo Ubalee on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BigView.h"


@implementation BigView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextSaveGState(currentContext);
    CGContextSetShadow(currentContext, CGSizeMake(0, -20), 5);
    [super drawRect: rect];
    CGContextRestoreGState(currentContext);
}
//*/

- (void)dealloc
{
    [super dealloc];
}

@end
