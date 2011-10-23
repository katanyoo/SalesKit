//
//  DownloadItem.h
//  SalesKit
//
//  Created by Katanyoo Ubalee on 10/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DownloadItem : NSObject {
    
}

@property (nonatomic, retain) NSNumber * updateDate;
@property (nonatomic, retain) NSString * pageName;
@property (nonatomic, retain) NSString * nodeID;
@property (nonatomic, retain) NSNumber * weight;

@property (nonatomic, retain) NSString * imagePath;
@property (nonatomic, retain) NSString * linkto;
@property (nonatomic, assign) BOOL done;


@end
