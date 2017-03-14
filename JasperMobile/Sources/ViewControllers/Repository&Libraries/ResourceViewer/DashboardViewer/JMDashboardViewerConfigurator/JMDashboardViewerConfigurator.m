/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMDashboardViewerConfigurator.h"
#import "JMDashboardLoader.h"
#import "JMLegacyDashboardLoader.h"
#import "JMVisDashboardLoader.h"
#import "JMWebViewManager.h"
#import "JMVisualizeManager.h"
#import "JMDashboard.h"
#import "JMWebEnvironment.h"
#import "JMResource.h"
#import "JMVIZWebEnvironment.h"
#import "JMDashboardViewerStateManager.h"
#import "JMUtils.h"
#import "NSObject+Additions.h"
#import "JMDashboardViewerExternalScreenManager.h"

@interface JMDashboardViewerConfigurator()
@property (nonatomic, strong, readwrite) id <JMDashboardLoader> dashboardLoader;
@end

@implementation JMDashboardViewerConfigurator

#pragma mark - Helpers

- (void)configWithWebEnvironment:(JMWebEnvironment *)webEnvironment
{
    [super configWithWebEnvironment:webEnvironment];
    
    JMResourceFlowType flowType = webEnvironment.flowType;
    switch(flowType) {
        case JMResourceFlowTypeUndefined: {
            NSAssert(false, @"Should not be undefined flow type");
            break;
        }
        case JMResourceFlowTypeREST: {
            _dashboardLoader = [JMLegacyDashboardLoader loaderWithRESTClient:self.restClient
                                                            webEnvironment:webEnvironment];
            break;
        }
        case JMResourceFlowTypeVIZ: {
            _dashboardLoader = [JMVisDashboardLoader loaderWithRESTClient:self.restClient
                                                           webEnvironment:webEnvironment];
            ((JMVIZWebEnvironment *)webEnvironment).visualizeManager.viewportScaleFactor = self.viewportScaleFactor;
            break;
        }
    }
}

- (JMResourceViewerStateManager *)createStateManager
{
    return [JMDashboardViewerStateManager new];
}

- (JMDashboardViewerExternalScreenManager *)createExternalScreenManager
{
    return [JMDashboardViewerExternalScreenManager new];
}

@end
