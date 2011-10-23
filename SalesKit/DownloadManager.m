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
#import "UIConfig.h"

#define DOCUMENTSPATH [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

@implementation DownloadManager

@synthesize delegate;
@synthesize nodeContainer;

- (id)init {
    self = [super init];
    if (self) {
        appDelegate = (SalesKitAppDelegate *)[[UIApplication sharedApplication] delegate];
        nodeContainer = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) startDownloadWithNodeList:(NSArray *)nodeList
{
    if (!networkQueue) {
        networkQueue = [[ASINetworkQueue alloc] init];
    }
    
    nodeListCount = [nodeList count];
    
    [networkQueue reset];
    [networkQueue setDownloadProgressDelegate:[[SettingViewController shared] progressView]];
    [networkQueue setRequestDidFinishSelector:@selector(downloadItemsComplete:)];
	[networkQueue setRequestDidFailSelector:@selector(downloadItemsFail:)];
	[networkQueue setRequestDidStartSelector:@selector(downloadingItem:)];
    [networkQueue setShowAccurateProgress:YES];
	[networkQueue setDelegate:self];
    
    ASIHTTPRequest *request;
    
    for (NSString *nid in nodeList) {
        DIOSNode *node = [[DIOSNode alloc] initWithSession:appDelegate.session];
        NSDictionary *connResult = [[node nodeGet:nid] copy];
        [nodeContainer addObject:connResult];
        
        NSString *fileName = [[[[connResult objectForKey:@"field_image"] objectForKey:@"und"] objectAtIndex:0] objectForKey:@"filename"];
        NSURL *url = [NSURL URLWithString:[BASE_FILES_URL stringByAppendingString:fileName]];
        NSString *destinationPath = [DOCUMENTSPATH stringByAppendingPathComponent:fileName];
        
        request = [ASIHTTPRequest requestWithURL:url];
        [request setDownloadDestinationPath:destinationPath];
        [networkQueue addOperation:request];
    }
    
    [networkQueue go];
    [[SyncManager shared] setStatus:@"Downloading..." onState:MIPSyncStatusNormal];
}

- (void) downloadingItem:(ASIHTTPRequest *)request
{
    NSString *filename = [[request url] lastPathComponent];
    [[SyncManager shared] setStatus:filename onState:MIPSyncStatusNormal];
}

- (void) downloadItemsComplete:(ASIHTTPRequest *)request
{
    --nodeListCount;
    
    MIPLog(@"%@", request);
    
    if (nodeListCount == 0) {
        MIPLog(@"Download Items Complete");
        [[SyncManager shared] setStatus:@"Download Image Complete" onState:MIPSyncStatusNormal];
    }
    
}

- (void) downloadItemsFail:(ASIHTTPRequest *)request
{
    MIPLog(@"Download Items Fail");    
}

- (void) startDownloadWithItem:(DownloadItem *)item
{
    
    
    if (dlItem) {
        dlItem = nil;
    }
    dlItem = [item copy];
    dlItemPathCount = 0;
    
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
        
    if (item.imagePath) {
        ++dlItemPathCount;
        NSString *fileName = [item.imagePath lastPathComponent];
        NSString *destinationPath = [[[appDelegate applicationDocumentsDirectory]
                                      URLByAppendingPathComponent:fileName] absoluteString];
        
        request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:item.imagePath]];
        [request setDownloadDestinationPath:destinationPath];
        [networkQueue addOperation:request];
    }
    
    if (item.linkto) {
        ++dlItemPathCount;
        NSString *fileName = [item.linkto lastPathComponent];
        NSString *destinationPath = [[[appDelegate applicationDocumentsDirectory]
                                      URLByAppendingPathComponent:fileName] absoluteString];
        
        request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:item.imagePath]];
        [request setDownloadDestinationPath:destinationPath];
        [networkQueue addOperation:request];
    }
    
    [networkQueue go];
    [[SyncManager shared] setStatus:@"Downloading..." onState:MIPSyncStatusNormal];
}

- (void)downloadComplete:(ASIHTTPRequest *)request
{
    /*
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
     */
    --dlItemPathCount;
    if (dlItemPathCount == 0) {
        dlItem.done = YES;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:[request downloadDestinationPath]]) {
        if ([delegate respondsToSelector:@selector(downloadManager:didFinishDownloadWithRequest:forObject:)]) {
            [delegate downloadManager:self didFinishDownloadWithRequest:request forObject:dlItem];
        }
    }
    else {
        if ([delegate respondsToSelector:@selector(downloadManager:didFailDownloadWithRequest:forObject:)]) {
            [delegate downloadManager:self didFailDownloadWithRequest:request forObject:dlItem];
        }
    }
}

- (void)downloadFailed:(ASIHTTPRequest *)request
{
    /*
    NSError *error = [request error];
    //[[SyncManager shared] setStatus:[error localizedDescription] onState:MIPSyncStatusError]; 
    
    NSString *destinationFile = [request downloadDestinationPath];
    if ([delegate respondsToSelector:@selector(downloadManager:didFailDownloadWithPath:error:)]) {
        [delegate downloadManager:self didFailDownloadWithPath:destinationFile error:[error localizedDescription]];
    }
     */
    if ([delegate respondsToSelector:@selector(downloadManager:didFailDownloadWithRequest:forObject:)]) {
        [delegate downloadManager:self didFailDownloadWithRequest:request forObject:dlItem];
    }
}
#pragma mark - Download With URL
- (void)startDownloadWithURL:(NSURL *)url
{
    NSString *filename = [url lastPathComponent];
    NSURL *destinationPath = [[appDelegate applicationDocumentsDirectory] URLByAppendingPathComponent:filename];
    
    ASIHTTPRequest *request;
    request = [ASIHTTPRequest requestWithURL:url];
    [request setDownloadDestinationPath:[destinationPath absoluteString]];
    [request setDelegate:self];
    [request startAsynchronous];

}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    // Use when fetching text data
    NSString *responseString = [request responseString];
    
    // Use when fetching binary data
    NSData *responseData = [request responseData];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
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
