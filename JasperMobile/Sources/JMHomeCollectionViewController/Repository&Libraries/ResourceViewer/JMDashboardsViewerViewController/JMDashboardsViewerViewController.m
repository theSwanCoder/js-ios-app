/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2014 TIBCO Software, Inc. All rights reserved.
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


#import "JMDashboardsViewerViewController.h"

@implementation JMDashboardsViewerViewController

- (void)runReportExecution
{
    NSString *dashboardUrl;
    
    if (self.resourceClient.serverProfile.serverInfo.versionAsFloat >= [JSConstants sharedInstance].SERVER_VERSION_CODE_AMBER_6_0_0 &&
        [self.resourceLookup.resourceType isEqualToString:[JSConstants sharedInstance].WS_TYPE_DASHBOARD]) {
        dashboardUrl = [NSString stringWithFormat:@"%@%@%@", self.resourceClient.serverProfile.serverUrl, @"/dashboard/viewer.html?", self.resourceLookup.uri];
    } else {
        dashboardUrl = [NSString stringWithFormat:@"%@%@%@", self.resourceClient.serverProfile.serverUrl, @"/flow.html?_flowId=dashboardRuntimeFlow&viewAsDashboardFrame=true&dashboardResource=", self.resourceLookup.uri];
    }
    dashboardUrl = [dashboardUrl stringByAppendingString:@"&sessionDecorator=no&decorate=no#"];
    NSURL *url = [NSURL URLWithString:dashboardUrl];
    self.resourceRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:self.resourceClient.timeoutInterval];
}

- (JMMenuActionsViewAction)availableAction
{
    return [super availableAction] | JMMenuActionsViewAction_Refresh;
}

#pragma mark - JMMenuActionsViewDelegate
- (void)actionsView:(JMMenuActionsView *)view didSelectAction:(JMMenuActionsViewAction)action
{
    [super actionsView:view didSelectAction:action];
    if (action == JMMenuActionsViewAction_Refresh) {
        [self runReportExecution];
    }
}

@end
