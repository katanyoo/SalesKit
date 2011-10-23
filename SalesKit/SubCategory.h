//
//  SubCategory.h
//  SalesKit
//
//  Created by Katanyoo Ubalee on 10/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Category;

@interface SubCategory : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * updateDate;
@property (nonatomic, retain) NSString * nodeID;
@property (nonatomic, retain) NSString * image;
@property (nonatomic, retain) NSString * linkto;
@property (nonatomic, retain) NSNumber * weight;
@property (nonatomic, retain) Category * CategoryItem;

@end
