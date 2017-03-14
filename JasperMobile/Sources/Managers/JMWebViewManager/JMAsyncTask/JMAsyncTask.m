/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMAsyncTask.h"
#import "JMUtils.h"

@interface JMAsyncTask()
@property (nonatomic, copy) JMAsyncTaskExecutionBlock executionBlock;
@end

@implementation JMAsyncTask

- (void)dealloc
{
    JMLog(@"%@SEL: '%@'", self, NSStringFromSelector(_cmd));
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.state = JMAsyncTaskStateReady;
    }
    return self;
}

- (instancetype)initWithExecutionBlock:(JMAsyncTaskExecutionBlock)executionBlock
{
    self = [super init];
    if (self) {
        self.state = JMAsyncTaskStateReady;
        self.executionBlock = executionBlock;
    }
    return self;
}

+ (instancetype)taskWithExecutionBlock:(JMAsyncTaskExecutionBlock)executionBlock
{
    return [[self alloc] initWithExecutionBlock:executionBlock];
}

#pragma mark - Custom Accessors

- (void)setState:(JMAsyncTaskState)state
{
    [self willChangeValueForKey:[self stringValueForState:state]];
    _state = state;
    [self didChangeValueForKey:[self stringValueForState:state]];
}

- (NSString *)stringValueForState:(JMAsyncTaskState)state
{
    NSString *stringValue = @"is";
    switch (state) {
        case JMAsyncTaskStateReady: {
            stringValue = [stringValue stringByAppendingString:@"Ready"];
            break;
        }
        case JMAsyncTaskStateExecuting: {
            stringValue = [stringValue stringByAppendingString:@"Executing"];
            break;
        }
        case JMAsyncTaskStateFinished: {
            stringValue = [stringValue stringByAppendingString:@"Finished"];
            break;
        }
    }
    return stringValue;
}

#pragma mark - Overrode Properties of 'NSOperation'

- (BOOL)isReady
{
    BOOL isReady = super.isReady && (self.state == JMAsyncTaskStateReady);
    return isReady;
}

- (BOOL)isExecuting
{
    BOOL isExecuting = (self.state == JMAsyncTaskStateExecuting);
    return isExecuting;
}

- (BOOL)isFinished
{
    JMLog(@"%@SEL: '%@'", self, NSStringFromSelector(_cmd));
    BOOL isFinished = self.isCancelled || (self.state == JMAsyncTaskStateFinished);
    return isFinished;
}

#pragma mark - Overrode Methods of 'NSOperation'

- (void)start
{
    JMLog(@"%@SEL: '%@'", self, NSStringFromSelector(_cmd));
    if (self.isCancelled) {
        return;
    }

    self.state = JMAsyncTaskStateExecuting;
    [self main];
}

- (void)main
{
    JMLog(@"%@SEL: '%@'", self, NSStringFromSelector(_cmd));
    if (self.isCancelled) {
        return;
    }
    JMLog(@"Start async task");
    if (self.executionBlock) {
        __weak __typeof(self) weakSelf = self;
        self.executionBlock(^{
            JMLog(@"Finish async task");
            __typeof(self) strongSelf = weakSelf;
            strongSelf.state = JMAsyncTaskStateFinished;
        });
    }
}

- (void)cancel
{
    JMLog(@"%@SEL: '%@'", self, NSStringFromSelector(_cmd));
    [super cancel];
    self.state = JMAsyncTaskStateFinished;
}

#pragma mark - Common methods

- (NSError *)createCancelTaskErrorWithErrorCode:(NSInteger)errorCode
{
    NSErrorDomain domain = @"JMAsyncTask Cancel Error";
    NSError *error = [[NSError alloc] initWithDomain:domain
                                                code:errorCode
                                            userInfo:@{
                                                    NSLocalizedDescriptionKey : @"Async task was canceled"
                                            }];
    return error;
}

#pragma mark - Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"\nself: %@\nstate: %@\nisCancelled: %@\n%@",
                    super.description,
                    [self stringValueForState:self.state], self.isCancelled ? @"YES" : @"NO",
                    self.taskDescription.length > 0 ? [NSString stringWithFormat:@"task description: %@\n", self.taskDescription] : @""];
}

@end
