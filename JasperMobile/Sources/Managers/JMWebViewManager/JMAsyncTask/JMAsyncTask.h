/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.6
 */

@import Foundation;

typedef NS_ENUM(NSInteger, JMAsyncTaskState) {
    JMAsyncTaskStateReady,
    JMAsyncTaskStateExecuting,
    JMAsyncTaskStateFinished
};

typedef void(^JMAsyncTaskFinishBlock)(void);
typedef void(^JMAsyncTaskExecutionBlock)(JMAsyncTaskFinishBlock);

@interface JMAsyncTask : NSOperation
@property (nonatomic) JMAsyncTaskState state;
@property (nonatomic, copy) NSString *taskDescription;
- (instancetype)initWithExecutionBlock:(JMAsyncTaskExecutionBlock)executionBlock;
+ (instancetype)taskWithExecutionBlock:(JMAsyncTaskExecutionBlock)executionBlock;
- (NSError *)createCancelTaskErrorWithErrorCode:(NSInteger)errorCode;
@end
