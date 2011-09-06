//
//  MenuItem.h
//  SalesKit
//
//  Created by Katanyoo Ubalee on 8/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MenuItem : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * menuid;
@property (nonatomic, retain) NSString * cover;
@property (nonatomic, retain) NSString * pageName;
@property (nonatomic, retain) NSSet* subMenuItems;

@end
