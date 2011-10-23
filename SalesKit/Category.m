//
//  Category.m
//  SalesKit
//
//  Created by Katanyoo Ubalee on 10/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Category.h"
#import "SubCategory.h"


@implementation Category
@dynamic updateDate;
@dynamic pageName;
@dynamic nodeID;
@dynamic cover;
@dynamic weight;
@dynamic subCategoryItems;

- (void)addSubCategoryItemsObject:(SubCategory *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"subCategoryItems" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"subCategoryItems"] addObject:value];
    [self didChangeValueForKey:@"subCategoryItems" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeSubCategoryItemsObject:(SubCategory *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"subCategoryItems" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"subCategoryItems"] removeObject:value];
    [self didChangeValueForKey:@"subCategoryItems" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addSubCategoryItems:(NSSet *)value {    
    [self willChangeValueForKey:@"subCategoryItems" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"subCategoryItems"] unionSet:value];
    [self didChangeValueForKey:@"subCategoryItems" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeSubCategoryItems:(NSSet *)value {
    [self willChangeValueForKey:@"subCategoryItems" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"subCategoryItems"] minusSet:value];
    [self didChangeValueForKey:@"subCategoryItems" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


@end
