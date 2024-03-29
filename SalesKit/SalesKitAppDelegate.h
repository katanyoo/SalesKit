//
//  SalesKitAppDelegate.h
//  SalesKit
//
//  Created by Katanyoo Ubalee on 8/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DIOSConnect.h"

@interface SalesKitAppDelegate : NSObject <UIApplicationDelegate> {

    DIOSConnect *session;
}

@property (nonatomic, retain) DIOSConnect *session;
@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (NSNumber *)lastUpdateForNodeID:(NSNumber *)nid;

@end
