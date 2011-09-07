//
//  DownloadManager.m
//  SalesKit
//
//  Created by Katanyoo Ubalee on 8/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DownloadManager.h"
#import "SettingViewController.h"
#import "ASINetworkQueue.h"
#import "ASIHTTPRequest.h"
#import "ASIDataDecompressor.h"

#define DOCUMENTSPATH [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

@implementation DownloadManager

@synthesize delegate;

- (void) startDownloadWithList:(NSArray *)downloadList
{
    
    itemCount = [downloadList count];
    
    if (!networkQueue) {
        networkQueue = [[ASINetworkQueue alloc] init];
    }
    
    [networkQueue reset];
    [networkQueue setDownloadProgressDelegate:[[SettingViewController shared] progressView]];
    [networkQueue setRequestDidFinishSelector:@selector(downloadComplete:)];
	[networkQueue setRequestDidFailSelector:@selector(downloadFailed:)];
	[networkQueue setShowAccurateProgress:YES];
	[networkQueue setDelegate:self];
    
    ASIHTTPRequest *request;
    for (NSDictionary *item in downloadList) {
        NSURL *urlForDownlaod = [NSURL URLWithString:[item objectForKey:@"fileURL"]];
        NSString *fileName = [[item objectForKey:@"fileURL"] lastPathComponent];
        NSString *destinationPath = [DOCUMENTSPATH stringByAppendingPathComponent:fileName];
        
        request = [ASIHTTPRequest requestWithURL:urlForDownlaod];
        [request setDownloadDestinationPath:destinationPath];
        [networkQueue addOperation:request];
    }
    
    [networkQueue go];
    [[SyncManager shared] setStatus:@"Downloading..." onState:MIPSyncStatusNormal];
}

- (void)downloadComplete:(ASIHTTPRequest *)request
{
    --itemCount;
    
    NSString *destinationFile = [request downloadDestinationPath];
    
    if (itemCount == 0) {
        [[SyncManager shared] setStatus:@"Download Complete" onState:MIPSyncStatusFinish];
    }
    
    NSFileManager *fileManger = [NSFileManager defaultManager];
    if ([fileManger fileExistsAtPath:destinationFile]) {
        //[[SyncManager shared] downloadFinish:destinationFile];
        if ([delegate respondsToSelector:@selector(downloadManager:didFinishDownloadWithPath:)]) {
            [delegate downloadManager:self didFinishDownloadWithPath:destinationFile];
        }
    }
    else {
        if ([delegate respondsToSelector:@selector(downloadManager:didFailDownloadWithPath:error:)]) {
            [delegate downloadManager:self didFailDownloadWithPath:destinationFile error:@"Have no downloaded file"];
        }
    }
}

- (void)downloadFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    //[[SyncManager shared] setStatus:[error localizedDescription] onState:MIPSyncStatusError]; 
    
    NSString *destinationFile = [request downloadDestinationPath];
    if ([delegate respondsToSelector:@selector(downloadManager:didFailDownloadWithPath:error:)]) {
        [delegate downloadManager:self didFailDownloadWithPath:destinationFile error:[error localizedDescription]];
    }
}

#pragma mark - Shared Method

static DownloadManager *shared = nil;

+ (DownloadManager *) shared
{
    @synchronized(self)
    {
        if (shared == nil)
        {
            shared = [[DownloadManager alloc] init];
        }
    }
    return shared;
}

@end
