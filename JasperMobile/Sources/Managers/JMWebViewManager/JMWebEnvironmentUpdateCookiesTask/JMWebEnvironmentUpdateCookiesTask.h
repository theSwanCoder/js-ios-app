/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.6
 */

#import "JMAsyncTask.h"
#import "JaspersoftSDK.h"

@class JMJavascriptRequestExecutor;

@interface JMWebEnvironmentUpdateCookiesTask : JMAsyncTask
- (instancetype __nullable)initWithRESTClient:(JSRESTBase * __nonnull)RESTClient
                              requestExecutor:(JMJavascriptRequestExecutor * __nonnull)requestExecutor
                                      cookies:(NSArray <NSHTTPCookie *>* __nullable)cookies
                                    competion:(void(^__nullable)(void))completion;
+ (instancetype __nullable)taskWithRESTClient:(JSRESTBase *__nonnull)RESTClient
                              requestExecutor:(JMJavascriptRequestExecutor *__nonnull)requestExecutor
                                      cookies:(NSArray <NSHTTPCookie *>*__nullable)cookies
                                    competion:(void(^__nullable)(void))completion;
@end
