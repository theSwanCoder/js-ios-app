/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.6
 */

#import "JMAsyncTask.h"
#import "JMBaseWebEnvironment.h"

@class JMJavascriptRequest;
@class JMJavascriptRequestExecutor;
@class JMJavascriptResponse;

@interface JMJavascriptRequestTask : JMAsyncTask
- (instancetype)initWithRequestExecutor:(JMJavascriptRequestExecutor *)requestExecutor
                                request:(JMJavascriptRequest *)request
                             completion:(JMWebEnvironmentRequestParametersCompletion)completion;
+ (instancetype)taskWithRequestExecutor:(JMJavascriptRequestExecutor *)requestExecutor
                                request:(JMJavascriptRequest *)request
                             completion:(JMWebEnvironmentRequestParametersCompletion)completion;
@end
