/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMJavascriptRequestTask.h"
#import "JMJavascriptRequest.h"
#import "JMJavascriptRequestExecutor.h"
#import "JMJavascriptResponse.h"
#import "JMUtils.h"

@interface JMJavascriptRequestTask()
@property (nonatomic, strong) JMJavascriptRequest *request;
@property (nonatomic, strong) JMJavascriptRequestExecutor *requestExecutor;
@property (nonatomic, copy) JMWebEnvironmentRequestParametersCompletion completion;
@end

@implementation JMJavascriptRequestTask

#pragma mark - Life Cycle

- (instancetype)initWithRequestExecutor:(JMJavascriptRequestExecutor *)requestExecutor request:(JMJavascriptRequest *)request completion:(JMWebEnvironmentRequestParametersCompletion)completion
{
    self = [super init];
    if (self) {
        JMLog(@"%@SEL: '%@'", self, NSStringFromSelector(_cmd));
        _requestExecutor = requestExecutor;
        _request = request;
        _completion = [completion copy];
    }
    return self;
}

+ (instancetype)taskWithRequestExecutor:(JMJavascriptRequestExecutor *)requestExecutor request:(JMJavascriptRequest *)request completion:(JMWebEnvironmentRequestParametersCompletion)completion
{
    return [[self alloc] initWithRequestExecutor:requestExecutor
                                         request:request
                                      completion:completion];
}

#pragma mark - Overridden NSOperation

- (void)main
{
    JMLog(@"%@SEL: '%@'", self, NSStringFromSelector(_cmd));
    if (self.isCancelled) {
        return;
    }
    NSString *commandString = self.request.fullCommand;
    JMLog(@"start execute operation: %@", commandString);
    __weak __typeof(self) weakSelf = self;
    [self.requestExecutor sendJavascriptRequest:self.request
                                         completion:^(JMJavascriptResponse *response, NSError *error) {
                                             __typeof(self) strongSelf = weakSelf;
                                             JMLog(@"%@end execute operation: %@", strongSelf, commandString);
                                             if (strongSelf.isCancelled) {
                                                 if (strongSelf.completion) {
                                                     strongSelf.completion(nil, [self createCancelTaskErrorWithErrorCode:JMJavascriptRequestErrorTypeCancel]);
                                                 }
                                             } else {
                                                 strongSelf.state = JMAsyncTaskStateFinished;
                                                 if (strongSelf.completion) {
                                                     strongSelf.completion(response.parameters, error);
                                                 }
                                             }
                                         }];
}

#pragma mark - Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@\nself.request: %@\nself.requestExecutor: %@\n", super.description, self.request, self.requestExecutor];
}

@end
