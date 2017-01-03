/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2015 TIBCO Software, Inc. All rights reserved.
 * http://community.jaspersoft.com/project/jaspermobile-ios
 *
 * Unless you have purchased a commercial license agreement from Jaspersoft,
 * the following license terms apply:
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/lgpl>.
 */

//
//  JMJavascriptRequestTask.m
//  TIBCO JasperMobile
//

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
