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


//
//  JMDashboardViewerVC.m
//  TIBCO JasperMobile
//

#import "JMDashboardViewerVC.h"
#import "JMDashboardViewerConfigurator.h"
#import "JSResourceLookup+Helpers.h"
#import "JMDashboardLoader.h"
#import "JMJavascriptNativeBridgeProtocol.h"

@interface JMDashboardViewerVC() <JMDashboardLoaderDelegate>
@property (strong, nonatomic) NSArray *rightButtonItems;
@property (strong, nonatomic) UIBarButtonItem *leftButtonItem;
@property (nonatomic, strong) JMDashboardViewerConfigurator *configurator;
@property (nonatomic, strong) JMDashboard *dashboard;
@property (nonatomic, weak) id<JMDashboardLoader>dashboardLoader;
@end


@implementation JMDashboardViewerVC

#pragma mark - LifeCycle
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.rightButtonItems = self.navigationItem.rightBarButtonItems;
}

#pragma mark - Custom Accessors

- (JMDashboard *)dashboard
{
    if (!_dashboard) {
        _dashboard = [self.resourceLookup dashboardModel];
    }
    return _dashboard;
}

- (id<JMDashboardLoader>)dashboardLoader
{
    return [self.configurator dashboardLoader];
}

#pragma mark - Setups
- (void)setupSubviews
{
    self.configurator = [JMDashboardViewerConfigurator configuratorWithDashboard:self.dashboard];

    CGRect rootViewBounds = self.navigationController.view.bounds;
    id dashboardView = [self.configurator webViewWithFrame:rootViewBounds asSecondary:NO];
    [self.view addSubview:dashboardView];

    [self.configurator updateReportLoaderDelegateWithObject:self];
}

- (void)resetSubViews
{
    [[JMVisualizeWebViewManager sharedInstance] reset];
}


#pragma mark - Actions
- (void)minimizeDashlet
{
    [self.dashboardLoader minimizeDashlet];
    self.navigationItem.leftBarButtonItem = self.leftButtonItem;
    self.navigationItem.rightBarButtonItems = self.rightButtonItems;
    self.navigationItem.title = [self resourceLookup].label;
}

- (void)reloadDashboard
{
    if (self.restClient.keepSession && [self.restClient isSessionAuthorized]) {
        [self.dashboardLoader reset];
        // waiting until page will be cleared
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.dashboardLoader reloadDashboard];
        });
    } else {
        [JMUtils showLoginViewAnimated:YES completion:@weakself(^(void)) {
                [self cancelResourceViewingAndExit:YES];
            } @weakselfend];
    }
}

#pragma mark - Overriden methods
- (void)startResourceViewing
{
    [self.dashboardLoader loadDashboard];
}

- (JMMenuActionsViewAction)availableActionForResource:(JSResourceLookup *)resource
{
    return [super availableActionForResource:resource] | JMMenuActionsViewAction_Refresh;
}

#pragma mark - JMMenuActionsViewDelegate
- (void)actionsView:(JMMenuActionsView *)view didSelectAction:(JMMenuActionsViewAction)action
{
    [super actionsView:view didSelectAction:action];
    if (action == JMMenuActionsViewAction_Refresh) {
        [self reloadDashboard];
    }
}

#pragma mark - JMDashboardLoaderDelegate
- (void)dashboardLoader:(id <JMDashboardLoader>)loader didStartMaximazeDashletWithTitle:(NSString *)title
{
    self.navigationItem.rightBarButtonItems = nil;

    self.leftButtonItem = self.navigationItem.leftBarButtonItem;
    self.navigationItem.leftBarButtonItem = [self backButtonWithTitle:self.title
                                                               target:self
                                                               action:@selector(minimizeDashlet)];
    self.navigationItem.title = title;
}

@end