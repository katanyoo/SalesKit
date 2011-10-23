//
//  DownloadManager.h
//  SalesKit
//
//  Created by Katanyoo Ubalee on 8/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DIOSNode.h"
#import "SalesKitAppDelegate.h"
#import "DownloadItem.h"

@class ASINetworkQueue;
@class ASIHTTPRequest;

@protocol DownloadManagerDelegate;

@interface DownloadManager : NSObject {
    
    ASINetworkQueue *networkQueue;
    NSInteger itemCount;
    NSInteger nodeListCount;
    
    SalesKitAppDelegate *appDelegate;
    
    DownloadItem *dlItem;
    NSInteger dlItemPathCount;
    
}

+ (DownloadManager *) shared;
- (void) startDownloadWithItem:(DownloadItem *)item;
- (void) startDownloadWithNodeList:(NSArray *)nodeList;
- (void)startDownloadWithURL:(NSURL *)url;

@property (nonatomic, assign) id<DownloadManagerDelegate> delegate;
@property (nonatomic, retain) NSMutableArray *nodeContainer;

@end


@protocol DownloadManagerDelegate <NSObject>

@optional
- (void) downloadManager:(DownloadManager *)downloadManager didFinishDownloadWithPath:(NSString *)destinationPath;
- (void) downloadManager:(DownloadManager *)downloadManager didFailDownloadWithPath:(NSString *)destinationPath error:(NSString *)errorMessage;

- (void) downloadManager:(DownloadManager *)downloadManager didFinishDownloadWithRequest:(ASIHTTPRequest *)request forObject:(id)obj;
- (void) downloadManager:(DownloadManager *)downloadManager didFailDownloadWithRequest:(ASIHTTPRequest *)request forObject:(id)obj;

@end