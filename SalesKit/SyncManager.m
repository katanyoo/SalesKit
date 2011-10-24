//
//  SyncManager.m
//  SalesKit
//
//  Created by Katanyoo Ubalee on 8/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SyncManager.h"
#import "ASIHTTPRequest.h"

#import "Category.h"
#import "SubCategory.h"
#import "UIConfig.h"

#import "DownloadItem.h"

#define DOCUMENTSPATH [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]


@implementation SyncManager

@synthesize delegate;
@synthesize managedObjectContext;
@synthesize updateList;
@synthesize linkPath;
@synthesize menuPath;
@synthesize node;
@synthesize nodeListForOperation;

- (id)init {
    self = [super init];
    if (self) {
        appDelegate = (SalesKitAppDelegate *)[[UIApplication sharedApplication] delegate];
        operationQue = [[NSOperationQueue alloc] init];
        self.node = [[DIOSNode alloc] initWithSession:appDelegate.session];
        operation = [[NSMutableDictionary alloc] init];
    }
    return self;
}

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
/*
- (void)grabURLInBackground:(NSURL *)url
{
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDelegate:self];
    [request startAsynchronous];
    
    [self setStatus:@"Checking for update" onState:MIPSyncStatusNormal];
}
*/
/*
- (void)requestFinished:(ASIHTTPRequest *)request
{

    if ([delegate respondsToSelector:@selector(syncManagerDidFinishSyncVersionWithJSONString:)]) {
        [delegate syncManagerDidFinishSyncVersionWithJSONString:[request responseString]];
    }
    
    
//    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"json"];
//    NSLog(@"%@", [[NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:nil] objectFromJSONString]);
    
    NSArray *version = [NSArray arrayWithArray:[[[request responseString] objectFromJSONString] objectForKey:@"versions"]];
    
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    currentVersion = [prefs integerForKey:@"currentVersion"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(version_no > %@)", [NSString stringWithFormat:@"%i", currentVersion]];
    NSArray *filtered = [version filteredArrayUsingPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"version_no"
                                                  ascending:YES] autorelease];
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    
//    if (self.updateList) {
//        [self.updateList release];
//        self.updateList = nil;
//    }
//    self.updateList = [filtered sortedArrayUsingDescriptors:sortDescriptors];

    
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
*/
/*
- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    [self setStatus:[error localizedDescription] onState:MIPSyncStatusError];
}
*/
#pragma mark - DIOS Methods
- (void) displayDebugDIOS:(id)aDIOSConnect {
    //responseStatus.text = [aDIOSConnect responseStatusMessage];
    NSString *response = [aDIOSConnect responseStatusMessage];
    if([aDIOSConnect connResult] == nil) {
        if([aDIOSConnect respondsToSelector:@selector(error)]) {
            //responseStatus.text = [NSString stringWithFormat:@"%@", [aDIOSConnect error]]; 
            //MIPLog(@"%@", [aDIOSConnect error]);
            //MIPLog(@"%@", aDIOSConnect);
            NSArray *respTrimed = [response componentsSeparatedByString:@": "];
            if ([respTrimed count] > 0) {
                NSMutableArray *resp = [NSMutableArray arrayWithArray:[[respTrimed lastObject] componentsSeparatedByString:@" "]];
                [resp removeLastObject];
                NSString *respCon = [resp componentsJoinedByString:@" "];
                if ([respCon isEqualToString:@"Already logged in as"]) {
                    if ([delegate respondsToSelector:@selector(syncManagerDidFinishLogin:)]) {
                        [delegate syncManagerDidFinishLogin:[respTrimed lastObject]];
                    }
                }
            }
        }
    } else {
        //[self dismissModalViewControllerAnimated:YES];
        if ([[[response componentsSeparatedByString:@" "] lastObject] isEqualToString:@"OK"]){
            if ([aDIOSConnect userInfo]) {
                MIPLog(@"++++ Login OK ++++");
                if ([delegate respondsToSelector:@selector(syncManagerDidFinishLogin:)]) {
                    [delegate syncManagerDidFinishLogin:@"Login Success"];
                }
            }
            else {
                MIPLog(@"---- Logout OK ----");
                if ([delegate respondsToSelector:@selector(syncManagerDidFinishLogout)]) {
                    [delegate syncManagerDidFinishLogout];
                }
            }
        }
        else {
        }
    }
}

-(IBAction) loginWithUsername:(NSString *)username password:(NSString *)password {
    DIOSUser *user = [[DIOSUser alloc] initWithSession:appDelegate.session];
    [user loginWithUsername:username andPassword:password];
    //Since we logged in our main session needs to know the new user information
    if ([[[[user connResult] objectForKey:@"#data"] objectForKey:@"user"] objectForKey:@"uid"]) {
        [appDelegate setSession:user];
    }
    [self displayDebugDIOS:user];
    [user release];
}

-(IBAction) logout {
    DIOSUser *user = [[DIOSUser alloc] initWithSession:[appDelegate session]];
    [user logout];
    MIPLog(@"%@", user);
    if ([user connResult]) {
        [appDelegate setSession:user];
    }
    [self displayDebugDIOS:user];
    [user release];
}


#pragma mark - Download Manager Delegate

- (void)downloadManager:(DownloadManager *)downloadManager didFinishDownloadWithPath:(NSString *)destinationPath {
    
    ZipArchive *zipper = [[ZipArchive alloc] init];
    zipper.delegate = self;
    
    if ([zipper UnzipOpenFile:destinationPath]) {
        [zipper UnzipFileTo:[destinationPath stringByDeletingLastPathComponent] 
                  overWrite:YES];
    }
    [zipper release];
}

- (void) downloadManager:(DownloadManager *)downloadManager didFailDownloadWithPath:(NSString *)destinationPath error:(NSString *)errorMessage {
    [self setStatus:errorMessage onState:MIPSyncStatusError];
}

#pragma  mark -

- (NSDictionary *)getNodeDetail:(NSNumber *)nid
{
    DIOSNode *nn = [[DIOSNode alloc] initWithSession:appDelegate.session];
    
    NSString *nodeID = [NSString stringWithFormat:@"%@", nid];
    NSDictionary *nodeData = [[nn nodeGet:nodeID] copy];
    [nn release];
    
    return nodeData;
}

- (void) addCategoryNode:(NSDictionary *)successNode
{
    Category *newNode = (Category *)[NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:appDelegate.managedObjectContext];
    
    newNode.nodeID = [successNode objectForKey:@"nid"];
    newNode.updateDate = [successNode objectForKey:@"changed"];
    newNode.pageName = [successNode objectForKey:@"title"];
    newNode.cover = [successNode objectForKey:@"cover"];
    newNode.weight = [successNode objectForKey:@"weight"];
    
    NSError *error;
    if (![appDelegate.managedObjectContext save:&error]) {
        MIPLog(@"Add new Category FAIL : %@", [error localizedDescription]);
    }
    else {
        MIPLog(@"Add new Category SUCCESS");
        [self startNextOperation];
    }
}

- (void) addSubCategoryNode:(NSDictionary *)successNode
{
    SubCategory *newNode = (SubCategory *)[NSEntityDescription insertNewObjectForEntityForName:@"SubCategory" inManagedObjectContext:appDelegate.managedObjectContext];
    
    newNode.nodeID = [successNode objectForKey:@"nid"];
    newNode.updateDate = [successNode objectForKey:@"changed"];
    //newNode.pageName = [successNode objectForKey:@"title"];
    newNode.image = [successNode objectForKey:@"image"];
    newNode.weight = [successNode objectForKey:@"weight"];
    newNode.linkto = [successNode objectForKey:@"linkto"];
    
    NSFetchRequest *tmpRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *tmpEntity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:appDelegate.managedObjectContext];
    [tmpRequest setEntity:tmpEntity];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"nodeID = %@", [successNode objectForKey:@"parentNodeID"]];
    [tmpRequest setPredicate:pred];
    
    NSError *tmpError;
    NSArray *tmpResult = [appDelegate.managedObjectContext executeFetchRequest:tmpRequest error:&tmpError];
    if (tmpResult == nil) {
        MIPLog(@"Fetch Category Node Error!!");
    }
    else if ([tmpResult count] == 0) {
        MIPLog(@"Have no Category Node");
    }
    else {
        Category *cat = (Category *)[tmpResult objectAtIndex:0];
        newNode.CategoryItem = cat;
        [cat addSubCategoryItemsObject:newNode];
        //MIPLog(@"%@", [[tmpResult objectAtIndex:0] cover]);
    }
    
    NSError *error;
    if (![appDelegate.managedObjectContext save:&error]) {
        MIPLog(@"Add new SubCategory FAIL : %@", [error localizedDescription]);
    }
    else {
        MIPLog(@"Add new SubCategory SUCCESS");
        [self startNextOperation];
    }
}

- (void) downloadManager:(DownloadManager *)downloadManager didFinishDownloadWithRequest:(ASIHTTPRequest *)request forObject:(id)obj
{
    DownloadItem *dlitem = obj;
    
    if ([[[[request downloadDestinationPath] lastPathComponent] pathExtension] isEqualToString:@"zip"]) {
        // unzip;
    }
    else {
    
    }
    
    if (dlitem.done) {
        if (!dlitem.linkto) {
            NSMutableDictionary *successNode = [[NSMutableDictionary alloc] init];
            [successNode setObject:dlitem.nodeID forKey:@"nid"];
            [successNode setObject:dlitem.updateDate forKey:@"changed"];
            [successNode setObject:dlitem.pageName forKey:@"title"];
            [successNode setObject:[request downloadDestinationPath] forKey:@"cover"];
            [successNode setObject:dlitem.weight forKey:@"weight"];
            
            if ([[operation valueForKey:[NSString stringWithFormat:@"%@", dlitem.nodeID]] isEqualToString:@"add"]) {
                [self addCategoryNode:successNode];
            }
            [successNode release];
        }
        else {
            NSMutableDictionary *successNode = [[NSMutableDictionary alloc] init];
            [successNode setObject:dlitem.nodeID forKey:@"nid"];
            [successNode setObject:dlitem.updateDate forKey:@"changed"];
            [successNode setObject:dlitem.pageName forKey:@"title"];
            [successNode setObject:[request downloadDestinationPath] forKey:@"image"];
            [successNode setObject:dlitem.weight forKey:@"weight"];
            [successNode setObject:dlitem.linkto forKey:@"linkto"];
            [successNode setObject:dlitem.parentNodeID forKey:@"parentNodeID"];
            
            if ([[operation valueForKey:[NSString stringWithFormat:@"%@", dlitem.nodeID]] isEqualToString:@"add"]) {
                [self addSubCategoryNode:successNode];
            }
            [successNode release];
        }
    }
}

- (void) downloadManager:(DownloadManager *)downloadManager didFailDownloadWithRequest:(ASIHTTPRequest *)request forObject:(id)obj
{
    
}

- (void)addNewNode:(NSNumber *)nid
{
    NSDictionary *nodeDetail = [self getNodeDetail:nid];
    NSString *nodeType = [nodeDetail objectForKey:@"type"];
    
    [operation setValue:@"add" forKey:[NSString stringWithFormat:@"%@",nid]];
    
    if ([nodeType isEqualToString:@"category"]) {
        
        MIPLog(@"%@", nodeDetail);
        
        NSString *imageName = [[[[nodeDetail objectForKey:@"field_image"] 
                                 objectForKey:@"und"] 
                                objectAtIndex:0]
                               objectForKey:@"filename"];
        //NSString *imagePath = [BASE_FILES_URL stringByAppendingPathComponent:imageName];
        NSURL *imageURL = [[NSURL URLWithString:BASE_FILES_URL] URLByAppendingPathComponent:imageName];
        
        
        DownloadItem *catNode = [[DownloadItem alloc] init];
        catNode.nodeID = [nodeDetail objectForKey:@"nid"];
        catNode.updateDate = [nodeDetail objectForKey:@"changed"];
        catNode.pageName = [nodeDetail objectForKey:@"title"];
        catNode.imagePath = [imageURL absoluteString];
        catNode.weight = [[[[nodeDetail objectForKey:@"field_weight"] objectForKey:@"und"] objectAtIndex:0] objectForKey:@"value"];
        catNode.linkto = nil;
        catNode.parentNodeID = nil;
        catNode.done = NO;
        
        /*
        NSArray *downloadList = [NSArray arrayWithObject:catNode];
        downloadItemCount = [downloadList count];
        */
        
        DownloadManager *dl = [[DownloadManager alloc] init];
        dl.delegate = self;
        [dl startDownloadWithItem:catNode];
        
        /*

        }*/
    }
    else if ([nodeType isEqualToString:@"sub_category"]) {
        MIPLog(@"%@", [nodeDetail objectForKey:@"nid"]);
        
        NSString *imageName = [[[[nodeDetail objectForKey:@"field_image"] 
                                 objectForKey:@"und"] 
                                objectAtIndex:0]
                               objectForKey:@"filename"];
        //NSString *imagePath = [BASE_FILES_URL stringByAppendingPathComponent:imageName];
        NSURL *imageURL = [[NSURL URLWithString:BASE_FILES_URL] URLByAppendingPathComponent:imageName];
        
        DownloadItem *subCatNode = [[DownloadItem alloc] init];
        
        subCatNode.nodeID = [nodeDetail objectForKey:@"nid"];
        subCatNode.updateDate = [nodeDetail objectForKey:@"changed"];
        subCatNode.pageName = [nodeDetail objectForKey:@"title"];
        subCatNode.imagePath = [imageURL absoluteString];
        subCatNode.parentNodeID = [[[[nodeDetail objectForKey:@"field_parent_menu"] objectForKey:@"und"] objectAtIndex:0] objectForKey:@"nid"];
        subCatNode.weight = [[[[nodeDetail objectForKey:@"field_weight"] objectForKey:@"und"] objectAtIndex:0] objectForKey:@"value"];
        
        if (![[nodeDetail objectForKey:@"field_embed_web"] isKindOfClass:[NSArray class]]) {
            MIPLog(@"web");
            NSString *fileName = [[[[nodeDetail objectForKey:@"field_embed_web"] 
                                     objectForKey:@"und"] 
                                    objectAtIndex:0]
                                   objectForKey:@"filename"];
            NSString *filePath = [[[NSURL URLWithString:BASE_FILES_URL] URLByAppendingPathComponent:fileName] absoluteString];
            
            subCatNode.linkto = filePath;
        }
        else if (![[nodeDetail objectForKey:@"field_link"] isKindOfClass:[NSArray class]]) {
            MIPLog(@"link");
            MIPLog(@"%@", [nodeDetail class]);
            NSString *linkURL = [[[[nodeDetail objectForKey:@"field_link"] 
                                    objectForKey:@"und"] 
                                   objectAtIndex:0]
                                  objectForKey:@"value"];
            
            subCatNode.linkto = linkURL;
        }
        else {
            MIPLog(@"default");
            subCatNode.linkto = @"http://www.google.com";
        }
        subCatNode.done = NO;
        
        /*
        NSArray *downloadList = [NSArray arrayWithObject:catNode];
        downloadItemCount = [downloadList count];
        */
        DownloadManager *dl = [[DownloadManager alloc] init];
        dl.delegate = self;
        [dl startDownloadWithItem:subCatNode];
    }
    
}

- (void)updateNode:(NSNumber *)nid
{
    [operation setValue:@"update" forKey:[NSString stringWithFormat:@"%@",nid]];
}

- (void)removeNode:(NSNumber *)nid
{
    [operation setValue:@"remove" forKey:[NSString stringWithFormat:@"%@",nid]];
}

- (void)startOperation:(NSDictionary *)metaNode
{
    NSString *status = [NSString stringWithFormat:@"Updating Node ID: %@", [metaNode objectForKey:@"nid"]];
    [self setStatus:status onState:MIPSyncStatusNormal];
                            
    NSNumber *lastUpdate = [appDelegate lastUpdateForNodeID:[metaNode objectForKey:@"nid"]];
    if (lastUpdate == nil) {
        MIPLog(@"Add new node %@", [metaNode objectForKey:@"nid"]);
        
        NSInvocationOperation *addNode = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(addNewNode:) object:[metaNode objectForKey:@"nid"]];
        
        [operationQue addOperation:addNode];
        [addNode release];
    }
    else if ([[metaNode objectForKey:@"changed"] intValue] - [lastUpdate intValue] > 0) {
        MIPLog(@"have update %i", [[metaNode objectForKey:@"changed"] intValue] - [lastUpdate intValue] > 0);
        
        NSInvocationOperation *updatingNode = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(updateNode:) object:[metaNode objectForKey:@"nid"]];
        
        [operationQue addOperation:updatingNode];
        [updatingNode release];
    }
    else if (YES) {
        // check for remove node
        MIPLog(@"No update");
        [self startNextOperation];
    }
}

- (void)startNextOperation
{
    [self finishLastOperationElement];
    //NSNumber *nodeID = [[nodeList objectAtIndex:ind] objectForKey:@"nid"];
    //NSDictionary *nodeDetail = [self getNodeDetail:nodeID];
    if ([self.nodeListForOperation count] > operationIndex) {
        [self startOperation:[self.nodeListForOperation objectAtIndex:operationIndex]];
    }
    else {
        if ([delegate respondsToSelector:@selector(syncManagerDidFinishSync)]) {
            [delegate syncManagerDidFinishSync];
        }
    }
}

- (void)initOperation
{
    operationIndex = -1;
}

- (void)finishLastOperationElement
{

    ++operationIndex;
}


- (void)getLastestVersionNodes
{
    DIOSNode *nn = [[DIOSNode alloc] initWithSession:appDelegate.session];
    
    NSMutableArray *connResult = [[NSMutableArray alloc] init];
    
    int i=0;
    NSArray *tmp;
    
    do {
        if (tmp) {
            tmp = nil;
        }
        
        tmp = (NSArray *)[nn nodeGetWithType:@"category" pageSize:30 page:i];
        if ([tmp count] > 0) {
            [connResult addObjectsFromArray:tmp];
            ++i;
        }
    } while ([tmp count] > 0);
    
    i=0;
    do {
        if (tmp) {
            tmp = nil;
        }
        
        tmp = (NSArray *)[nn nodeGetWithType:@"sub_category" pageSize:30 page:i];
        if ([tmp count] > 0) {
            [connResult addObjectsFromArray:tmp];
            ++i;
        }
    } while ([tmp count] > 0);
    
    //NSArray *connResult = [(NSArray *)[node nodeGet:@"19"] copy];
    //NSLog(@"%@", connResult);
    
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type == 'category' || type == 'sub_category'"];
    //NSArray *filterResult = [connResult filteredArrayUsingPredicate:predicate];
    
    //checkList = [[NSMutableArray alloc] init];
    //MIPLog(@"---- %@ ----", [nn nodeGetWithCurrentUser]);
    //for (NSDictionary *nodeDetail in connResult) {
        //[checkList addObject:[nodeDetail objectForKey:@"nid"]];
    if (self.nodeListForOperation) {
        [self.nodeListForOperation release];
        self.nodeListForOperation = nil;
    }
    self.nodeListForOperation = [connResult copy];
    [self initOperation];
    [self startNextOperation];
        //MIPLog(@"%@", nodeDetail);
    //}

    [connResult release];
    //[self.node release];
    [nn release];
}

- (void)startSync
{
    MIPLog(@"reloadData");

    NSInvocationOperation *checkForUpdate = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(getLastestVersionNodes) object:nil];
    
    [operationQue addOperation:checkForUpdate];
    [checkForUpdate release];
}

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

- (Category *) menuID:(NSString *)menuid
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
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

- (BOOL) addCategory:(NSDictionary *)categoryItem
{
    Category *mItem = [self menuID:[categoryItem objectForKey:@"id"]];
    if (!mItem) {
        mItem = (Category *)[NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
        mItem.nodeID = [categoryItem objectForKey:@"id"];
        mItem.cover = [self.menuPath stringByAppendingPathComponent:
                       [categoryItem objectForKey:@"cover"]];
        mItem.pageName = [categoryItem objectForKey:@"name"];
    }

    NSMutableSet *itemSet = [NSMutableSet set];
    for (NSDictionary *subItem in [categoryItem objectForKey:@"items"]) {
        SubCategory *sItem = (SubCategory *)[NSEntityDescription insertNewObjectForEntityForName:@"SubCategory" inManagedObjectContext:self.managedObjectContext];
        sItem.image = [self.menuPath stringByAppendingPathComponent:
                       [subItem objectForKey:@"image"]];
        sItem.linkto = [self.linkPath stringByAppendingPathComponent:
                        [subItem objectForKey:@"linkto"]];
        [itemSet addObject:sItem];
    }
    
    mItem.subCategoryItems = itemSet;
    
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
        
        for (NSDictionary *Category in menuData) {
            if ([[Category objectForKey:@"action"] isEqualToString:@"add"]) {
                if ([self addCategory:Category] && success) {
                    success = YES;
                }
                else {
                    success = NO;
                }
            }
            else if ([[Category objectForKey:@"action"] isEqualToString:@"remove"]){
                
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
