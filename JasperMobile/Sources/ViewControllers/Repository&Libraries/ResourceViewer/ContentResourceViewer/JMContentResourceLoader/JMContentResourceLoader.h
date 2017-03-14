/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksii Gubariev ogubarie@tibco.com
 @since 2.6
 */

#import <Foundation/Foundation.h>
@class JMResource, JMSavedResources;

@interface JMContentResourceLoader : NSObject
@property (nonatomic, strong, readonly) JMSavedResources *savedResource;
@property (nonatomic, strong, readonly) JSContentResource *contentResource;
@property (nonatomic, strong, readonly) NSURL *contentResourceURL;
@property (nonatomic, copy, readonly) JSRESTBase *restClient;

- (instancetype)initWithRESTClient:(JSRESTBase *)restClient
                    webEnvironment:(JMWebEnvironment *)webEnvironment;
+ (instancetype)loaderWithRESTClient:(JSRESTBase *)restClient
                      webEnvironment:(JMWebEnvironment *)webEnvironment;

- (void)loadContentResourceForResource:(JMResource *)resource
                            completion:(void (^)(NSURL *baseURL, NSError *error))completion;

- (void)cancel;

@end
