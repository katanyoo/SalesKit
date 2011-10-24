//
//  Category.h
//  SalesKit
//
//  Created by Katanyoo Ubalee on 10/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SubCategory;

@interface Category : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * updateDate;
@property (nonatomic, retain) NSString * pageName;
@property (nonatomic, retain) NSNumber * nodeID;
@property (nonatomic, retain) NSString * cover;
@property (nonatomic, retain) NSNumber * weight;
@property (nonatomic, retain) NSSet* subCategoryItems;

@end
