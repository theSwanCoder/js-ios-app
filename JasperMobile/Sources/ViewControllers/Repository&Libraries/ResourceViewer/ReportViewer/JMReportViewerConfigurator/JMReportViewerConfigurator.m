/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMReportViewerConfigurator.h"
#import "JMReportLoaderProtocol.h"
#import "JMVisualizeReportLoader.h"
#import "JMRestReportLoader.h"
#import "JMVisualizeManager.h"
#import "JMWebViewManager.h"
#import "JMWebEnvironment.h"
#import "JMVIZWebEnvironment.h"
#import "JMReportViewerStateManager.h"
#import "JMUtils.h"
#import "NSObject+Additions.h"
#import "JMReportViewerExternalScreenManager.h"

@interface JMReportViewerConfigurator()
@property (nonatomic, strong, readwrite) id <JMReportLoaderProtocol> reportLoader;
@end

@implementation JMReportViewerConfigurator

#pragma mark - Helpers

- (void)configWithWebEnvironment:(JMWebEnvironment *)webEnvironment
{
    [super configWithWebEnvironment:webEnvironment];
    
    if ([JMUtils flowTypeForReportViewer] == JMResourceFlowTypeVIZ) {
        JMLog(@"run with VIZ");
        _reportLoader = [JMVisualizeReportLoader loaderWithRestClient:self.restClient
                                                       webEnvironment:webEnvironment];
        ((JMVIZWebEnvironment *)webEnvironment).visualizeManager.viewportScaleFactor = self.viewportScaleFactor;
    } else {
        JMLog(@"run with REST");
        _reportLoader = [JMRestReportLoader loaderWithRestClient:self.restClient
                                                  webEnvironment:webEnvironment];
    }
}

- (JMReportViewerStateManager *)createStateManager
{
    return [JMReportViewerStateManager new];
}

- (JMReportViewerExternalScreenManager *)createExternalScreenManager
{
    return [JMReportViewerExternalScreenManager new];
}

@end
