//
//  DownloadManager.h
//  SalesKit
//
//  Created by Katanyoo Ubalee on 8/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ASINetworkQueue;

@protocol DownloadManagerDelegate;

@interface DownloadManager : NSObject {
    
    ASINetworkQueue *networkQueue;
    NSInteger itemCount;
}

+ (DownloadManager *) shared;
- (void) startDownloadWithList:(NSArray *)downloadList;

@property (nonatomic, assign) id<DownloadManagerDelegate> delegate;

@end


@protocol DownloadManagerDelegate <NSObject>

@optional
- (void) downloadManager:(DownloadManager *)downloadManager didFinishDownloadWithPath:(NSString *)destinationPath;
- (void) downloadManager:(DownloadManager *)downloadManager didFailDownloadWithPath:(NSString *)destinationPath error:(NSString *)errorMessage;


@end