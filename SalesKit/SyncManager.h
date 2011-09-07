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

typedef enum {
    MIPSyncStatusFinish,
    MIPSyncStatusNormal,
    MIPSyncStatusError
} MIPSyncStatus;

@protocol SyncManagerDelegate;

@interface SyncManager : NSObject 
<ZipArchiveDelegate>
{

    NSInteger currentVersion;
    NSInteger itemCount;
    
    NSArray *updateList;
    
    NSString *linkPath;
    NSString *menuPath;
}

+ (SyncManager *) shared;
- (void)grabURLInBackground:(NSURL *)url;
- (void)startSyncWithURL:(NSURL *)url;
- (void)setStatus:(NSString *)status onState:(MIPSyncStatus)state;
- (void) downloadFinish:(NSString *)destinationPath;

//@property (nonatomic, retain) NSArray *updateList;
@property (nonatomic, assign) id<SyncManagerDelegate> delegate;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSArray *updateList;
@property (nonatomic, retain) NSString *linkPath;
@property (nonatomic, retain) NSString *menuPath;

@end


@protocol SyncManagerDelegate <NSObject>

@optional
- (void)syncManagerDidFinishSyncVersionWithJSONString:(NSString *)responseString;
- (void)syncManagerDidFinishSyncVersionWithItemCount:(NSInteger)count;
- (void)updateStatus:(NSString *)status onState:(MIPSyncStatus)state;

@end