/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMExportManager.h"
#import "JMExportTask.h"
#import "JMSavedResources+Helpers.h"

@interface JMExportManager()
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@end

@implementation JMExportManager

#pragma mark - Life Cycle
+ (instancetype)sharedInstance {
    static JMExportManager *sharedInstance;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
       sharedInstance = [JMExportManager new];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _operationQueue = [NSOperationQueue new];
        _operationQueue.maxConcurrentOperationCount = 1;
    }
    return self;
}

#pragma mark - Public API
- (void)saveResourceWithTask:(JMExportTask *)newTask
{
    [newTask addSavingCompletionBlock:^(JMExportTask * _Nonnull task, NSURL * _Nullable savedResourceFolderURL, NSError * _Nullable error) {
        if ([task isCancelled]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kJMExportedResourceDidCancelNotification object:task.exportResource userInfo:nil];
        } else {
            if (error) {
                if (error.code == JSSessionExpiredErrorCode) {
                    [JMUtils showLoginViewAnimated:YES completion:nil];
                } else {
                    [JMUtils presentAlertControllerWithError:error completion:nil];
                }
            } else if(savedResourceFolderURL){
                [JMSavedResources addResource:task.exportResource sourcesURL:savedResourceFolderURL];
            }

            [[NSNotificationCenter defaultCenter] postNotificationName:kJMExportedResourceDidLoadNotification object:task.exportResource userInfo:nil];
            
            UILocalNotification* notification = [UILocalNotification new];
            notification.fireDate = [NSDate date];
            notification.alertBody = task.exportResource.resourceLookup.label;
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        }
    }];
    
    [self.operationQueue addOperation:newTask];
}

- (void)addExportTask:(JMExportTask *)newTask
{
    [self.operationQueue addOperation:newTask];
}

- (void)cancelAll
{
    [self.operationQueue cancelAllOperations];
}

- (void)cancelTask:(JMExportTask *)task
{
    [task cancel];
}

- (void)cancelTaskForResource:(JMExportResource *)resource;
{
    [self cancelTask:[self taskForResource:resource]];
}

- (NSArray <JMExportResource *> *)exportedResources
{
    NSMutableArray *resources = [NSMutableArray new];
    for (JMExportTask *task in self.operationQueue.operations) {
        if (!task.isFinished) {
            [resources addObject:task.exportResource];
        }
    }
    return resources;
}

- (JMExportTask *)taskForResource:(JMExportResource *)resource
{
    for (JMExportTask *exportTask in self.operationQueue.operations) {
        if (exportTask.exportResource == resource) {
            return exportTask;
        }
    }
    return nil;
}

+ (JMExportResource *)exportResourceWithName:(NSString *)reportName format:(NSString *)reportFormat;
{
    NSPredicate *predicateName = [NSPredicate predicateWithFormat:@"resourceLookup.label == %@", reportName];
    NSPredicate *predicateFormat = [NSPredicate predicateWithFormat:@"format == %@", reportFormat];
    NSPredicate *predicateAll = [[NSCompoundPredicate alloc] initWithType:NSAndPredicateType subpredicates:@[predicateName, predicateFormat]];
    
    NSArray *allExportResources = [[[self sharedInstance] exportedResources] filteredArrayUsingPredicate:predicateAll];
    return [allExportResources firstObject];
}
@end
