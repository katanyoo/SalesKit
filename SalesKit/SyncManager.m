//
//  SyncManager.m
//  SalesKit
//
//  Created by Katanyoo Ubalee on 8/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SyncManager.h"
#import "ASIHTTPRequest.h"

#import "MenuItem.h"
#import "SubMenuItem.h"

#define DOCUMENTSPATH [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]


@implementation SyncManager

@synthesize delegate;
@synthesize managedObjectContext;
@synthesize updateList;
@synthesize linkPath;
@synthesize menuPath;

#pragma mark - Shared Method

static SyncManager *shared = nil;

+ (SyncManager *) shared
{
    @synchronized(self)
    {
        if (shared == nil)
        {
            shared = [[SyncManager alloc] init];
        }
    }
    return shared;
}

#pragma mark - Object Methods

- (void)grabURLInBackground:(NSURL *)url
{
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDelegate:self];
    [request startAsynchronous];
    
    [self setStatus:@"Checking for update" onState:MIPSyncStatusNormal];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{

    if ([delegate respondsToSelector:@selector(syncManagerDidFinishSyncVersionWithJSONString:)]) {
        [delegate syncManagerDidFinishSyncVersionWithJSONString:[request responseString]];
    }
    
    /*
    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"json"];
    NSLog(@"%@", [[NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:nil] objectFromJSONString]);
    */
    NSArray *version = [NSArray arrayWithArray:[[[request responseString] objectFromJSONString] objectForKey:@"versions"]];
    
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    currentVersion = [prefs integerForKey:@"currentVersion"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(version_no > %@)", [NSString stringWithFormat:@"%i", currentVersion]];
    NSArray *filtered = [version filteredArrayUsingPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"version_no"
                                                  ascending:YES] autorelease];
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    /*
    if (self.updateList) {
        [self.updateList release];
        self.updateList = nil;
    }
    self.updateList = [filtered sortedArrayUsingDescriptors:sortDescriptors];
    */
    
    self.updateList = [filtered sortedArrayUsingDescriptors:sortDescriptors];
    if ([self.updateList count] > 0) {
        itemCount = [self.updateList count];
        [DownloadManager shared].delegate = self;
        [[DownloadManager shared] startDownloadWithList:self.updateList];
    }
    else {
        itemCount = 0;
        [self setStatus:@"Have no item for update." onState:MIPSyncStatusFinish];
    }
    if ([delegate respondsToSelector:@selector(syncManagerDidFinishSyncVersionWithItemCount:)]) {
        [delegate syncManagerDidFinishSyncVersionWithItemCount:[self.updateList count]];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    [self setStatus:[error localizedDescription] onState:MIPSyncStatusError];
}

#pragma mark - Download Manager Delegate

- (void)downloadManager:(DownloadManager *)downloadManager didFinishDownloadWithPath:(NSString *)destinationPath {
    
    ZipArchive *zipper = [[ZipArchive alloc] init];
    zipper.delegate = self;
    
    if ([zipper UnzipOpenFile:destinationPath]) {
        [zipper UnzipFileTo:[destinationPath stringByDeletingLastPathComponent] 
                  overWrite:YES];
    }
}

- (void) downloadManager:(DownloadManager *)downloadManager didFailDownloadWithPath:(NSString *)destinationPath error:(NSString *)errorMessage {
    [self setStatus:errorMessage onState:MIPSyncStatusError];
}

#pragma  mark -

- (void)startSyncWithURL:(NSURL *)url
{
    [self grabURLInBackground:url];
}

- (void) setStatus:(NSString *)status onState:(MIPSyncStatus)state
{
    if ([delegate respondsToSelector:@selector(updateStatus:onState:)]) {
        [delegate updateStatus:status onState:state];
    }
}

- (MenuItem *) menuID:(NSString *)menuid
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MenuItem" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    
    NSError *error;
    NSMutableArray *mutableFetchResults = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    
    if (mutableFetchResults == nil) {
        MIPLog(@"Couldn't fetch data");
        return nil;
    }
    else if ([mutableFetchResults count] == 0) {
        return nil;
    }
    else {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(menuid == %@)", menuid];
        NSArray *filtered = [mutableFetchResults filteredArrayUsingPredicate:predicate];
        
        if ([filtered count] == 1) {
            return [filtered objectAtIndex:0];
        }
        else {
            return nil;
        }
    }
    return nil;
}

- (BOOL) addMenuItem:(NSDictionary *)menuItem
{
    MenuItem *mItem = [self menuID:[menuItem objectForKey:@"id"]];
    if (!mItem) {
        mItem = (MenuItem *)[NSEntityDescription insertNewObjectForEntityForName:@"MenuItem" inManagedObjectContext:self.managedObjectContext];
        mItem.menuid = [menuItem objectForKey:@"id"];
        mItem.cover = [self.menuPath stringByAppendingPathComponent:
                       [menuItem objectForKey:@"cover"]];
        mItem.pageName = [menuItem objectForKey:@"name"];
    }

    NSMutableSet *itemSet = [NSMutableSet set];
    for (NSDictionary *subItem in [menuItem objectForKey:@"items"]) {
        SubMenuItem *sItem = (SubMenuItem *)[NSEntityDescription insertNewObjectForEntityForName:@"SubMenuItem" inManagedObjectContext:self.managedObjectContext];
        sItem.image = [self.menuPath stringByAppendingPathComponent:
                       [subItem objectForKey:@"image"]];
        sItem.linkto = [self.linkPath stringByAppendingPathComponent:
                        [subItem objectForKey:@"linkto"]];
        [itemSet addObject:sItem];
    }
    
    mItem.subMenuItems = itemSet;
    
    NSError *error;
    if(![self.managedObjectContext save:&error]) {
        MIPLog(@"Can't add new menu item");
        return NO;
    }
    else {
        MIPLog(@"Save data ok");
        return YES;
    }
}

- (BOOL) setDataToDatabase
{
    BOOL success = YES;
    for (NSDictionary *versionItem in self.updateList) {
        MIPLog(@"%@", versionItem);
        
        NSString *fileName = [[[[versionItem objectForKey:@"fileURL"] 
                                lastPathComponent] 
                               stringByDeletingPathExtension] 
                              stringByAppendingPathExtension:@"json"];
        
        NSString *filePath = [DOCUMENTSPATH stringByAppendingPathComponent:fileName];
        
        NSDictionary *dataForUpdate = [[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil] objectFromJSONString];

        
        self.linkPath = [dataForUpdate objectForKey:@"linkpath"];
        self.menuPath = [dataForUpdate objectForKey:@"menupath"];
        
        NSArray *menuData = [dataForUpdate objectForKey:@"data"];
        
        for (NSDictionary *menuItem in menuData) {
            if ([[menuItem objectForKey:@"action"] isEqualToString:@"add"]) {
                if ([self addMenuItem:menuItem] && success) {
                    success = YES;
                }
                else {
                    success = NO;
                }
            }
            else if ([[menuItem objectForKey:@"action"] isEqualToString:@"remove"]){
                
            }
        }
    }
    return success;
}

#pragma mark - Zip Delegate

-(void) zipArchive:(ZipArchive *)zipArch disFinishUnzipFile:(NSString *)path
{
//    [self setStatus:@"Validate Success" onState:MIPSyncStatusFinish];
    MIPLog(@"%@", path);
    
    NSFileManager *fileManger = [NSFileManager defaultManager];
    if ([fileManger fileExistsAtPath:path]) {
        [fileManger removeItemAtPath:path error:nil];
        --itemCount;
    }
    
    MIPLog(@"%i", itemCount);
    if (itemCount == 0) {
        if ([self setDataToDatabase]) {
            if ([delegate respondsToSelector:@selector(syncManagerDidFinishUpdateDatabase)]) {
                [delegate syncManagerDidFinishUpdateDatabase];
            }
        }
        else {
            
        }
    }
}

-(void) zipArchive:(ZipArchive *)zipArch disFailUnzipFile:(NSString *)path
{
//    [self setStatus:@"Validate Fail" onState:MIPSyncStatusError];
    
    NSFileManager *fileManger = [NSFileManager defaultManager];
    if ([fileManger fileExistsAtPath:path]) {
        [fileManger removeItemAtPath:path error:nil];
    }
}

@end
