/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.6
 */

#import "JMAsyncTask.h"
#import "JMBaseWebEnvironment.h"

@class JMJavascriptRequestExecutor;

@interface JMWebEnvironmentLoadingTask : JMAsyncTask
+ (instancetype __nullable)taskWithRequestExecutor:(JMJavascriptRequestExecutor *__nonnull)requestExecutor
                                        HTMLString:(NSString *__nonnull)HTMLString
                                           baseURL:(NSURL *__nonnull)baseURL
                                        completion:(void(^__nullable)(void))completion;
+ (instancetype __nullable)taskWithRequestExecutor:(JMJavascriptRequestExecutor *__nonnull)requestExecutor
                                        URLRequest:(NSURLRequest *__nonnull)URLRequest
                                        completion:(void(^__nullable)(void))completion;
@end
