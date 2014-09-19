//
//  JMDashboardsViewerViewController.m
//  JasperMobile
//
//  Created by Oleksii Gubariev on 9/10/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMDashboardsViewerViewController.h"

@implementation JMDashboardsViewerViewController

- (void)runReportExecution
{
    NSString *dashboardUrl = [NSString stringWithFormat:@"%@%@%@",
                              self.resourceClient.serverProfile.serverUrl,
                              @"/flow.html?_flowId=dashboardRuntimeFlow&viewAsDashboardFrame=true&dashboardResource=",
                              self.resourceLookup.uri];
    
    NSURL *url = [NSURL URLWithString:dashboardUrl];
    self.request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:self.resourceClient.timeoutInterval];
}

- (JMResourceViewerAction)availableAction
{
    return [super availableAction] | JMResourceViewerAction_Refresh;
}

#pragma mark - JMResourceViewerActionsViewDelegate
- (void)actionsView:(JMResourceViewerActionsView *)view didSelectAction:(JMResourceViewerAction)action
{
    [super actionsView:view didSelectAction:action];
    if (action == JMResourceViewerAction_Refresh) {
        [self runReportExecution];
    }
}

@end
