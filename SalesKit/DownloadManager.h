//
//  DownloadManager.h
//  SalesKit
//
//  Created by Katanyoo Ubalee on 8/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ASINetworkQueue;

@interface DownloadManager : NSObject {
    
    ASINetworkQueue *networkQueue;
    NSInteger itemCount;
}

+ (DownloadManager *) shared;
- (void) startDownloadWithList:(NSArray *)downloadList;

@end
