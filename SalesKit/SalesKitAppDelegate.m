//
//  SalesKitAppDelegate.m
//  SalesKit
//
//  Created by Katanyoo Ubalee on 8/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SalesKitAppDelegate.h"
#import "MainViewController.h"
#import "SettingViewController.h"
#import "SyncManager.h"
#import "UIConfig.h"

@implementation SalesKitAppDelegate

@synthesize session;
@synthesize window=_window;

@synthesize managedObjectContext=__managedObjectContext;

@synthesize managedObjectModel=__managedObjectModel;

@synthesize persistentStoreCoordinator=__persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    //SettingViewController *settingVC = [SettingViewController shared];
    //self.window.rootViewController = settingVC;
    //[DownloadManager shared];
    [SyncManager shared].managedObjectContext = self.managedObjectContext;
    
    //[[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:NO];
    
    MainViewController *mainVC = [[MainViewController alloc] init];
    //mainVC.view.bounds = CGRectMake(0, 0, 1024, 748);
    self.window.rootViewController = mainVC;
    //mainVC.view.bounds = settingVC.view.bounds;
    //mainVC.view.tag = MAINVIEW_TAG;
    self.session = [[DIOSConnect alloc] init];
    /*
    CGAffineTransform rotate = CGAffineTransformMakeRotation(M_PI/2.0);
    [mainVC.view setTransform:rotate];
    CGRect contentRect = CGRectMake(0, 0, 1024, 748); 
    mainVC.view.bounds = contentRect; 
    [mainVC.view setCenter:CGPointMake(768/2, 1024/2)];
    */
    //[settingVC.view addSubview:mainVC.view];

    //[self.window addSubview:mainVC.view];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (NSNumber *)lastUpdateForNodeID:(NSNumber *)nid
{
    //NSMutableArray *mutableFetchResults = [[NSMutableArray alloc] init];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init]; 
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Category" 
											  inManagedObjectContext:self.managedObjectContext]; 
	[request setEntity:entity];
	
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"nodeID = %@", nid];
    [request setPredicate:predicate];
    
	NSError *error;
	NSArray *results = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy]; 
    [request release];
    if (results == nil) {
        MIPLog(@"Can't fetch Category");
        NSFetchRequest *requestSub = [[NSFetchRequest alloc] init]; 
        NSEntityDescription *entitySub = [NSEntityDescription entityForName:@"SubCategory" 
                                                     inManagedObjectContext:self.managedObjectContext]; 
        [requestSub setEntity:entitySub];
        
        NSPredicate *predicateSub = [NSPredicate predicateWithFormat:@"nodeID = %@", nid];
        [requestSub setPredicate:predicateSub];
        
        NSError *errorSub;
        NSArray *resultSub = [[self.managedObjectContext executeFetchRequest:requestSub error:&errorSub] mutableCopy];
        [requestSub release];
        if (resultSub == nil) {
            MIPLog(@"Can't fetch Sub Category");
        }
        else if ([resultSub count] != 1) {
            [resultSub release];
            return nil;
        }
        else {
            return [[resultSub objectAtIndex:0] updateDate];
        }
    }
    else if ([results count] != 1) {
        [results release];
        NSFetchRequest *requestSub = [[NSFetchRequest alloc] init]; 
        NSEntityDescription *entitySub = [NSEntityDescription entityForName:@"SubCategory" 
                                                  inManagedObjectContext:self.managedObjectContext]; 
        [requestSub setEntity:entitySub];
        
        NSPredicate *predicateSub = [NSPredicate predicateWithFormat:@"nodeID = %@", nid];
        [requestSub setPredicate:predicateSub];
        
        NSError *errorSub;
        NSArray *resultSub = [[self.managedObjectContext executeFetchRequest:requestSub error:&errorSub] mutableCopy];
        [requestSub release];
        if (resultSub == nil) {
            MIPLog(@"Can't fetch Sub Category");
        }
        else if ([resultSub count] != 1) {
            [resultSub release];
            return nil;
        }
        else {
            return [[resultSub objectAtIndex:0] updateDate];
        }
        return nil;
    }
    else {
        return [[results objectAtIndex:0] updateDate];
    }
    
    [results release];
    return nil;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)dealloc
{
    [_window release];
    [__managedObjectContext release];
    [__managedObjectModel release];
    [__persistentStoreCoordinator release];
    [super dealloc];
}

- (void)awakeFromNib
{
    /*
     Typically you should set up the Core Data stack here, usually by passing the managed object context to the first view controller.
     self.<#View controller#>.managedObjectContext = self.managedObjectContext;
    */
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"SalesKit" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"SalesKit.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
