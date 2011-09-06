//
//  SubMenuItem.h
//  SalesKit
//
//  Created by Katanyoo Ubalee on 8/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MenuItem;

@interface SubMenuItem : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * image;
@property (nonatomic, retain) NSString * linkto;
@property (nonatomic, retain) MenuItem * menuItem;

@end
