/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMContentResourceViewerConfigurator.h"
#import "JMContentResourceViewerStateManager.h"
#import "JMContentResourceLoader.h"
#import "JMContentResourceViewerExternalScreenManager.h"

@interface JMContentResourceViewerConfigurator ()
@property (nonatomic, strong, readwrite, nonnull) JMContentResourceLoader * contentResourceLoader;

@end

@implementation JMContentResourceViewerConfigurator

- (void)configWithWebEnvironment:(JMWebEnvironment *)webEnvironment
{
    [super configWithWebEnvironment:webEnvironment];
    
    _contentResourceLoader = [JMContentResourceLoader loaderWithRESTClient:self.restClient
                                                            webEnvironment:webEnvironment];
}

- (JMResourceViewerStateManager *)createStateManager
{
    return [JMContentResourceViewerStateManager new];
}

- (JMResourceViewerExternalScreenManager *)createExternalScreenManager
{
    return [JMContentResourceViewerExternalScreenManager new];
}

@end
