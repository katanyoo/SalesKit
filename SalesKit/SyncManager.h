//
//  SyncManager.h
//  SalesKit
//
//  Created by Katanyoo Ubalee on 8/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadManager.h"
#import "ZipArchive.h"
#import "JSONKit.h"
#import "DIOSUser.h"
#import "DIOSNode.h"
#import "SalesKitAppDelegate.h"

typedef enum {
    MIPSyncStatusFinish,
    MIPSyncStatusNormal,
    MIPSyncStatusError
} MIPSyncStatus;

@protocol SyncManagerDelegate;

@interface SyncManager : NSObject 
<ZipArchiveDelegate, DownloadManagerDelegate>
{

    NSInteger currentVersion;
    NSInteger itemCount;
    NSInteger downloadItemCount;
    
    NSArray *updateList;
    
    //NSMutableArray *checkList;
    
    NSString *linkPath;
    NSString *menuPath;
    
    SalesKitAppDelegate *appDelegate;
    
    DIOSNode *node;
    NSOperationQueue *operationQue;
    NSMutableDictionary *operation;
    
    NSInteger operationIndex;
}

+ (SyncManager *) shared;
//- (void)grabURLInBackground:(NSURL *)url;
- (void)startSyncWithURL:(NSURL *)url;
- (void)startSync;
- (void)setStatus:(NSString *)status onState:(MIPSyncStatus)state;
- (IBAction) loginWithUsername:(NSString *)username password:(NSString *)password;
- (IBAction) logout;

- (void)initOperation;
- (void)startNextOperation;
- (void)finishLastOperationElement;
//- (void)downloadFinish:(NSString *)destinationPath;

//@property (nonatomic, retain) NSArray *updateList;
@property (nonatomic, assign) id<SyncManagerDelegate> delegate;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSArray *updateList;
@property (nonatomic, retain) NSString *linkPath;
@property (nonatomic, retain) NSString *menuPath;

@property (nonatomic, retain) DIOSNode *node;
@property (nonatomic, retain) NSArray *nodeListForOperation;

@end


@protocol SyncManagerDelegate <NSObject>

@optional
- (void)syncManagerDidFinishSyncVersionWithJSONString:(NSString *)responseString;
- (void)syncManagerDidFinishSyncVersionWithItemCount:(NSInteger)count;
- (void)syncManagerDidFinishUpdateDatabase;
- (void)syncManagerDidFailUpdateDatabase;
- (void)syncManagerDidFinishLogin:(NSString *)message;
- (void)syncManagerDidFinishLogout;
- (void)syncManagerDidFinishSync;
- (void)syncManagerDidFailSync;
- (void)updateStatus:(NSString *)status onState:(MIPSyncStatus)state;

@end