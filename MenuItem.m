//
//  MenuItem.m
//  SalesKit
//
//  Created by Katanyoo Ubalee on 8/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MenuItem.h"


@implementation MenuItem
@dynamic menuid;
@dynamic cover;
@dynamic pageName;
@dynamic subMenuItems;

- (void)addSubMenuItemsObject:(NSManagedObject *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"subMenuItems" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"subMenuItems"] addObject:value];
    [self didChangeValueForKey:@"subMenuItems" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeSubMenuItemsObject:(NSManagedObject *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"subMenuItems" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"subMenuItems"] removeObject:value];
    [self didChangeValueForKey:@"subMenuItems" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addSubMenuItems:(NSSet *)value {    
    [self willChangeValueForKey:@"subMenuItems" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"subMenuItems"] unionSet:value];
    [self didChangeValueForKey:@"subMenuItems" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeSubMenuItems:(NSSet *)value {
    [self willChangeValueForKey:@"subMenuItems" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"subMenuItems"] minusSet:value];
    [self didChangeValueForKey:@"subMenuItems" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


@end
