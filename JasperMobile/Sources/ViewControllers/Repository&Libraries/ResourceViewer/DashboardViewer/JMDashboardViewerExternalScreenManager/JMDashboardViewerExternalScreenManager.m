/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


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
