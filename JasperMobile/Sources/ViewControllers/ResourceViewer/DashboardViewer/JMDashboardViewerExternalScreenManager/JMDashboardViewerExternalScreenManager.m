/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2016 TIBCO Software, Inc. All rights reserved.
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
//  JMDashboardViewerExternalScreenManager.m
//  TIBCO JasperMobile
//


#import "JMDashboardViewerExternalScreenManager.h"
#import "JMDashboardViewerVC.h"
#import "JMUtils.h"
#import "JMExternalWindowDashboardControlsVC.h"
#import "JMBaseResourceView.h"
#import "JMDashboard.h"

@interface JMDashboardViewerExternalScreenManager()
@property (nonatomic, strong) JMExternalWindowDashboardControlsVC *controlsVC;
@end

@implementation JMDashboardViewerExternalScreenManager

#pragma mark - Public API

- (void)showContentOnTV
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));

    [super showContentOnTV];
    [self showControlsViewOnDevice];
}

- (void)backContentOnDevice
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));

    [super backContentOnDevice];
    [self removeControlsViewFromDevice];
}

#pragma mark - Overridden

- (JMBaseResourceView *)resourceView
{
    return (JMBaseResourceView *) self.controller.view;
}

- (void)handleExternalScreenWillBeDestroy
{
    [self.controller switchFromTV];
}

#pragma mark - Helpers

- (void)showControlsViewOnDevice
{
    self.controlsVC = [JMExternalWindowDashboardControlsVC new];
    self.controlsVC.delegate = self.controller;
    self.controlsVC.components = self.controller.dashboard.components;

    CGRect controlViewFrame = self.controller.view.frame;
    controlViewFrame.origin.y = 0;
    self.controlsVC.view.frame = controlViewFrame;

    [self.controller.view addSubview:self.controlsVC.view];
}

- (void)removeControlsViewFromDevice
{
    [self.controlsVC.view removeFromSuperview];
    self.controlsVC = nil;
}

@end