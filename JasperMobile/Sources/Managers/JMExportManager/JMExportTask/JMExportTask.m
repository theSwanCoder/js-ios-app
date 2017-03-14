/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMExportTask.h"
#import "JMSavedResources+Helpers.h"

@interface JMExportTask ()
@property (nonatomic, strong, readwrite) JMExportResource *exportResource;
@property (atomic, strong) NSMutableArray *completions;

@property (nonatomic, assign) BOOL localExecuting;
@property (nonatomic, assign) BOOL localFinished;

@end


@implementation JMExportTask

- (void)addSavingCompletionBlock:(nonnull JMSavingCompletion)completionBlock
{
    [self.completions addObject:completionBlock];
}

#pragma mark - Life Cycle
- (void)dealloc
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
}

- (instancetype)initWithResource:(JMExportResource *)resource
{
    self = [super init];
    if (self) {
        self.exportResource = resource;
        self.completions = [NSMutableArray array];
        __weak typeof(self) weakSelf = self;
        [self setCompletionBlock:^{
            __strong typeof(self) strongSelf = weakSelf;
            if ([NSThread isMainThread]) {
                [strongSelf sendCallBacks];
            } else {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [strongSelf sendCallBacks];
                });
            }
        }];
    }
    return self;
}

+ (instancetype)taskWithResource:(JMExportResource *)resource
{
    return [[self alloc] initWithResource:resource];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: Export %@ in format %@>", [self class], self.name, self.exportResource.format];
}

- (void)start
{
    if(self.localFinished || [self isCancelled]) {
        [self completeOperation];
    } else {
        [self willChangeValueForKey:@"isExecuting"];
        [self main];
        self.localExecuting = YES;
        [self didChangeValueForKey:@"isExecuting"];
    }
}

- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isExecuting
{
    return self.localExecuting;
}

- (BOOL)isFinished
{
    return self.localFinished;
}

- (void)cancel
{
    [super cancel];
//    [self.completions removeAllObjects];
    [self completeOperation];
}

- (void)completeOperation
{
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    self.localExecuting = NO;
    self.localFinished  = YES;
    [self didChangeValueForKey:@"isFinished"];
    [self didChangeValueForKey:@"isExecuting"];
    
}

- (void)sendCallBacks
{
    [self.completions enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        JMSavingCompletion completion = obj;
        completion(self, _savedResourceFolderURL, _savingError);
    }];
}

@end
