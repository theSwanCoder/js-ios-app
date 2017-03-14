/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMDashboardInfoViewController.h"
#import "JMResource.h"
#import "JMDashboardViewerVC.h"
#import "JMUtils.h"

@interface JMDashboardInfoViewController ()

@end

@implementation JMDashboardInfoViewController

#pragma mark - Overloaded methods
- (JMMenuActionsViewAction)availableAction
{
    return ([super availableAction] | JMMenuActionsViewAction_Run);
}

- (void)actionsView:(JMMenuActionsView *)view didSelectAction:(JMMenuActionsViewAction)action
{
    [super actionsView:view didSelectAction:action];
    if (action == JMMenuActionsViewAction_Run) {
        [self runDashboard];
    }
}

- (void)runDashboard
{
    id nextVC = [[JMUtils mainStoryBoard] instantiateViewControllerWithIdentifier:[self.resource resourceViewerVCIdentifier]];
    if ([nextVC respondsToSelector:@selector(setResource:)]) {
        [nextVC setResource:self.resource];
    }
    
    if (nextVC) {
        JMDashboardViewerVC *dashboardViewerVC = nextVC;
        // TODO: add for legacy dashboards
        if (self.resource.type == JMResourceTypeDashboard) {
            dashboardViewerVC.configurator = [JMUtils dashboardViewerConfiguratorReusableWebView];
        } else if (self.resource.type == JMResourceTypeLegacyDashboard) {
            dashboardViewerVC.configurator = [JMUtils dashboardViewerConfiguratorNonReusableWebView];
        }
        [self.navigationController pushViewController:nextVC animated:YES];
    }
}

@end
