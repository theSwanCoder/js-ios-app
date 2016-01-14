/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2015 TIBCO Software, Inc. All rights reserved.
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
#import "JMReportViewerVC.h"
#import "JMDashboard.h"
#import "JMWebViewManager.h"
#import "JMExternalWindowDashboardControlsVC.h"
#import "JMDashboardInputControlsVC.h"
#import "JMDashlet.h"

@interface JMDashboardViewerVC() <JMDashboardLoaderDelegate, JMExternalWindowDashboardControlsVCDelegate>
@property (nonatomic, copy) NSArray *rightButtonItems;
@property (nonatomic, strong) UIBarButtonItem *leftButtonItem;

@property (nonatomic, strong, readwrite) JMDashboard *dashboard;
@property (nonatomic, strong) JMDashboardViewerConfigurator *configurator;
@property (nonatomic) JMExternalWindowDashboardControlsVC *controlsViewController;
@end


@implementation JMDashboardViewerVC

#pragma mark -
- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator
{
    if ([self.dashboardLoader respondsToSelector:@selector(updateViewportScaleFactorWithValue:)]) {
        CGFloat initialScaleViewport = 0.75;
        BOOL isCompactWidth = newCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact;
        if (isCompactWidth) {
            initialScaleViewport = 0.25;
        }
        [self.dashboardLoader updateViewportScaleFactorWithValue:initialScaleViewport];
    }
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
}

#pragma mark - Print
- (void)printResource
{
    [super printResource];

    [self imageFromWebViewWithCompletion:^(UIImage *image) {
        if (image) {
            [self printItem:image
                   withName:self.dashboard.resourceLookup.label
                 completion:nil];
        }
    }];
}

- (void)imageFromWebViewWithCompletion:(void(^)(UIImage *image))completion
{
    [JMCancelRequestPopup presentWithMessage:@"status.loading"];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        // Screenshot rendering from webView
        UIGraphicsBeginImageContextWithOptions(self.webView.bounds.size, self.webView.opaque, 0.0);
        [self.webView.layer renderInContext:UIGraphicsGetCurrentContext()];

        UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        dispatch_async(dispatch_get_main_queue(), ^(void){
            [JMCancelRequestPopup dismiss];
            if (completion) {
                completion(viewImage);
            }
        });
    });
}

#pragma mark - Custom Accessors

- (JMDashboard *)dashboard
{
    if (!_dashboard) {
        _dashboard = [self.resourceLookup dashboardModel];
    }
    return _dashboard;
}

- (UIWebView *)webView
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    return self.configurator.webView;
}

- (id<JMDashboardLoader>)dashboardLoader
{
    return [self.configurator dashboardLoader];
}

#pragma mark - Setups
- (void)setupSubviews
{
    self.configurator = [JMDashboardViewerConfigurator configuratorWithDashboard:self.dashboard];

    // Setup viewport scale factor
    CGFloat initialScaleViewport = 0.75;
    BOOL isCompactWidth = self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact;
    if (isCompactWidth) {
        initialScaleViewport = 0.25;
    }
    self.configurator.viewportScaleFactor = initialScaleViewport;

    id dashboardView = [self.configurator webViewAsSecondary:NO];
    [self.view addSubview:dashboardView];

    [self setupWebViewLayout];

    [self.configurator updateReportLoaderDelegateWithObject:self];
}

- (void)setupLeftBarButtonItems
{
    if ([self isDashletShown]) {
        self.navigationItem.leftBarButtonItem = [self backButtonWithTitle:self.title
                                                                   target:self
                                                                   action:@selector(minimizeDashlet)];
    } else {
        [super setupLeftBarButtonItems];
    }
}

- (void)setupRightBarButtonItems
{
    if (![self isDashletShown]) {
        [super setupRightBarButtonItems];
        self.rightButtonItems = self.navigationItem.rightBarButtonItems;
    }
}

- (void)resetSubViews
{
    [self.dashboardLoader destroy];
    [[JMWebViewManager sharedInstance] resetZoom];
}


- (void)cancelResourceViewingAndExit:(BOOL)exit
{
    if ([self isContentOnTV]) {
        [self switchFromTV];
        [self hideExternalWindow];
        [super cancelResourceViewingAndExit:exit];
    } else {
        [super cancelResourceViewingAndExit:exit];
    }
}

#pragma mark - Actions
- (void)minimizeDashlet
{
    [[self webView].scrollView setZoomScale:0.1 animated:YES];
    [self.dashboardLoader minimizeDashlet];
    self.navigationItem.leftBarButtonItem = self.leftButtonItem;
    self.navigationItem.rightBarButtonItems = self.rightButtonItems;
    self.navigationItem.title = [self resourceLookup].label;
    self.leftButtonItem = nil;
}

- (void)reloadDashboard
{
    __weak typeof(self)weakSelf = self;
    [self.restClient verifyIsSessionAuthorizedWithCompletion:^(BOOL isSessionAuthorized) {
        __strong typeof(self)strongSelf = weakSelf;
        if (strongSelf.restClient.keepSession && isSessionAuthorized) {
            __weak typeof(self)weakSelf = strongSelf;
            [strongSelf startShowLoaderWithMessage:JMCustomLocalizedString(@"resources.loading.msg", nil)
                                       cancelBlock:^(void) {
                                           __strong typeof(self)strongSelf = weakSelf;
                                           [strongSelf.dashboardLoader cancel];
                                           [super cancelResourceViewingAndExit:YES];
                                       }];
            [self.dashboardLoader reloadDashboardWithCompletion:^(BOOL success, NSError *error) {
                __weak typeof(self)strongSelf = weakSelf;
                [strongSelf stopShowLoader];
            }];
        } else {
            __weak typeof(self)weakSelf = strongSelf;
            [JMUtils showLoginViewAnimated:YES completion:^{
                __weak typeof(self)strongSelf = weakSelf;
                [strongSelf cancelResourceViewingAndExit:YES];
            }];
        }
    }];
}

- (void)reloadDashlet
{
    if ([self.dashboardLoader respondsToSelector:@selector(reloadMaximizedDashletWithCompletion:)]) {

        __weak typeof(self)weakSelf = self;
        [self startShowLoaderWithMessage:JMCustomLocalizedString(@"resources.loading.msg", nil)];

        [self.dashboardLoader reloadMaximizedDashletWithCompletion:^(BOOL success, NSError *error){
            __weak typeof(self)strongSelf = weakSelf;
            [strongSelf stopShowLoader];
        }];

    } else {
        [self minimizeDashlet];
        [self reloadDashboard];
    }
}

#pragma mark - Overriden methods
- (void)startResourceViewing
{
    [self startShowDashboard];
}

- (void)startShowDashboard
{
    __weak typeof(self)weakSelf = self;
    [self.restClient verifyIsSessionAuthorizedWithCompletion:^(BOOL isSessionAuthorized) {
        __strong typeof(self)strongSelf = weakSelf;
        if (strongSelf.restClient.keepSession && isSessionAuthorized) {

            [strongSelf startShowLoaderWithMessage:JMCustomLocalizedString(@"resources.loading.msg", nil)
                                 cancelBlock:^(void) {
                                         [strongSelf.dashboardLoader cancel];
                                         [super cancelResourceViewingAndExit:YES];
                                     }];
            __weak typeof(self)weakSelf = strongSelf;
            [strongSelf.dashboardLoader loadDashboardWithCompletion:^(BOOL success, NSError *error) {
                __weak typeof(self)strongSelf = weakSelf;
                [strongSelf stopShowLoader];

                if (success) {
                    // Analytics
                    NSString *label = ([JMUtils isSupportVisualize] && [JMUtils isServerAmber2OrHigher]) ? kJMAnalyticsResourceEventLabelDashboardVisualize : kJMAnalyticsResourceEventLabelDashboardFlow;
                    [JMUtils logEventWithInfo:@{
                                        kJMAnalyticsCategoryKey      : kJMAnalyticsResourceEventCategoryTitle,
                                        kJMAnalyticsActionKey        : kJMAnalyticsResourceEventActionOpenTitle,
                                        kJMAnalyticsLabelKey         : label
                                        }];
                }
            }];

        } else {
            [JMUtils showLoginViewAnimated:YES completion:^(void) {
                [strongSelf cancelResourceViewingAndExit:YES];
            }];
        }
    }];
}

- (JMMenuActionsViewAction)availableActionForResource:(JSResourceLookup *)resource
{
    JMMenuActionsViewAction menuActions = [super availableActionForResource:resource] | JMMenuActionsViewAction_Refresh;
    if ([self isExternalScreenAvailable]) {
        menuActions |= [self isContentOnTV] ?  JMMenuActionsViewAction_HideExternalDisplay : JMMenuActionsViewAction_ShowExternalDisplay;
    }
    // TODO: verify if input controls available
    menuActions |= JMMenuActionsViewAction_Edit;
    return menuActions;
}

#pragma mark - JMMenuActionsViewDelegate
- (void)actionsView:(JMMenuActionsView *)view didSelectAction:(JMMenuActionsViewAction)action
{
    [super actionsView:view didSelectAction:action];

    switch (action) {
        case JMMenuActionsViewAction_Refresh: {
            [self reloadDashboard];
            break;
        }
        case JMMenuActionsViewAction_ShowExternalDisplay: {
            [self showExternalWindow];
            break;
        }
        case JMMenuActionsViewAction_HideExternalDisplay: {
            [self switchFromTV];
            [self hideExternalWindow];
            break;
        }
        case JMMenuActionsViewAction_Edit: {
            [self showInputControlsVC];
            break;
        }
        default:{break;}
    }
}

#pragma mark - JMDashboardLoaderDelegate
- (void)dashboardLoader:(id <JMDashboardLoader>)loader didStartMaximazeDashletWithTitle:(NSString *)title
{
    [[self webView].scrollView setZoomScale:0.1 animated:YES];

    self.navigationItem.rightBarButtonItems = nil;
    if ([self.dashboardLoader respondsToSelector:@selector(reloadMaximizedDashletWithCompletion:)]) {
        UIBarButtonItem *refreshDashlet = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"refresh_action"]
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(reloadDashlet)];
        self.navigationItem.rightBarButtonItem = refreshDashlet;
    }

    self.leftButtonItem = self.navigationItem.leftBarButtonItem;
    self.navigationItem.leftBarButtonItem = [self backButtonWithTitle:self.title
                                                               target:self
                                                               action:@selector(minimizeDashlet)];
    self.navigationItem.title = title;
}

- (void)dashboardLoader:(id <JMDashboardLoader>)loader didReceiveHyperlinkWithType:(JMHyperlinkType)hyperlinkType
         resourceLookup:(JSResourceLookup *)resourceLookup
             parameters:(NSArray *)parameters
{
    if (hyperlinkType == JMHyperlinkTypeReportExecution) {
        NSString *reportURI = resourceLookup.uri;
        __weak typeof(self)weakSelf = self;
        [self loadInputControlsWithReportURI:reportURI completion:^(NSArray *inputControls, NSError *error) {
            __strong typeof(self)strongSelf = weakSelf;
            if (error) {
                __weak typeof(self) weakSelf = strongSelf;
                [JMUtils presentAlertControllerWithError:error completion:^{
                    __strong typeof(self) strongSelf = weakSelf;
                    [strongSelf cancelResourceViewingAndExit:YES];
                }];
            } else {
                JMReportViewerVC *reportViewController = (JMReportViewerVC *) [strongSelf.storyboard instantiateViewControllerWithIdentifier:[resourceLookup resourceViewerVCIdentifier]];
                reportViewController.resourceLookup = resourceLookup;
                [reportViewController.report generateReportOptionsWithInputControls:inputControls];
                [reportViewController.report updateReportParameters:parameters];
                reportViewController.isChildReport = YES;

                [strongSelf.navigationController pushViewController:reportViewController animated:YES];
            }
        }];
    } else if (hyperlinkType == JMHyperlinkTypeReference) {
        NSURL *URL = parameters.firstObject;
        if (URL) {
            [[UIApplication sharedApplication] openURL:URL];
        }
    }
}

- (void)dashboardLoaderDidReceiveAuthRequest:(id <JMDashboardLoader>)loader
{
    if ([self isDashletShown]) {
        [self minimizeDashlet];
    }

    [self.restClient deleteCookies];
    if ([JMUtils isServerAmber2OrHigher]) {
        [self startResourceViewing];
    } else {
        [self reloadDashboard];
    }
}

#pragma mark - Report Options (Input Controls)
- (void)loadInputControlsWithReportURI:(NSString *)reportURI completion:(void (^)(NSArray *inputControls, NSError *error))completion
{
    __weak typeof(self)weakSelf = self;
    [self.restClient inputControlsForReport:reportURI
                                        ids:nil
                             selectedValues:nil
                            completionBlock:^(JSOperationResult *result) {
                                __strong typeof(self)strongSelf = weakSelf;
                                if (result.error) {
                                    if (result.error.code == JSSessionExpiredErrorCode) {
                                        [JMUtils showLoginViewAnimated:YES completion:^{
                                            [strongSelf cancelResourceViewingAndExit:YES];
                                        }];
                                    } else {
                                        if (completion) {
                                            completion(nil, result.error);
                                        }
                                    }
                                } else {

                                    NSMutableArray *invisibleInputControls = [NSMutableArray array];
                                    for (JSInputControlDescriptor *inputControl in result.objects) {
                                        if (!inputControl.visible.boolValue) {
                                            [invisibleInputControls addObject:inputControl];
                                        }
                                    }

                                    if (result.objects.count - invisibleInputControls.count == 0) {
                                        completion(nil, nil);
                                    } else {
                                        NSMutableArray *inputControls = [result.objects mutableCopy];
                                        if (invisibleInputControls.count) {
                                            [inputControls removeObjectsInArray:invisibleInputControls];
                                        }
                                        completion([inputControls copy], nil);
                                    }
                                }

                            }];
}

#pragma mark - Helpers
- (BOOL)isDashletShown
{
    return self.leftButtonItem != nil;
}

- (void)showInputControlsVC
{
    JMDashboardInputControlsVC *inputControlsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"JMDashboardInputControlsVC"];
    inputControlsVC.dashboard = self.dashboard;
    inputControlsVC.exitBlock = ^(void) {
        // generate parameters

        // expected format {"id":["value1", "value2", ...]}
        // array of parameters is not valid
        // need send only one parameter
        NSDictionary *firstParameter = self.dashboard.inputControls[0];
        NSString *identifier = firstParameter[@"id"];
        NSArray *values = firstParameter[@"value"];
        NSString *valuesAsString = @"";
        for (NSString *value in values) {
            valuesAsString = [valuesAsString stringByAppendingFormat:@"\"%@\",", value];
        }
        NSString *parameterAsString = [NSString stringWithFormat:@"{\"%@\":[%@]}", identifier, valuesAsString];

        JMLog(@"%@", parameterAsString);

        [self.dashboardLoader applyParameters:parameterAsString];
    };
    [self.navigationController pushViewController:inputControlsVC animated:YES];
}

#pragma mark - Work with external screen
- (UIView *)viewForAddingToExternalWindow
{
    [self addControlsForExternalWindow];

    if ([self.dashboardLoader respondsToSelector:@selector(updateViewportScaleFactorWithValue:)]) {
        [self.dashboardLoader updateViewportScaleFactorWithValue:0.75];
    }
    UIView *dashboardView = self.configurator.webView;
    dashboardView.translatesAutoresizingMaskIntoConstraints = YES;
    return dashboardView;
}

- (void)addControlsForExternalWindow
{
    self.controlsViewController = [JMExternalWindowDashboardControlsVC new];
    self.controlsViewController.components = self.dashboard.components;
    [self.view addSubview:self.controlsViewController.view];

    self.controlsViewController.delegate = self;

    self.controlsViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[controlsView]-0-|"
                                                                      options:NSLayoutFormatAlignAllLeading
                                                                      metrics:nil
                                                                        views:@{@"controlsView": self.controlsViewController.view}]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[controlsView]-0-|"
                                                                      options:NSLayoutFormatAlignAllLeading
                                                                      metrics:nil
                                                                        views:@{@"controlsView": self.controlsViewController.view}]];


}

- (void)switchFromTV
{
    [self.view addSubview:self.webView];
    [self setupWebViewLayout];

    if ([self.dashboardLoader respondsToSelector:@selector(updateViewportScaleFactorWithValue:)]) {
        CGFloat initialScaleViewport = 0.75;
        BOOL isCompactWidth = self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact;
        if (isCompactWidth) {
            initialScaleViewport = 0.25;
        }
        [self.dashboardLoader updateViewportScaleFactorWithValue:initialScaleViewport];
    }

    [self.controlsViewController.view removeFromSuperview];
    self.controlsViewController = nil;
}

#pragma mark - JMExternalWindowDashboardControlsVCDelegate
- (void)externalWindowDashboardControlsVC:(JMExternalWindowDashboardControlsVC *)dashboardControlsVC didAskMaximizeDashlet:(JMDashlet *)dashlet
{
    if ([self.dashboardLoader respondsToSelector:@selector(maximizeDashlet:)]) {
        [self.dashboardLoader maximizeDashlet:dashlet];

        // TODO: move to separate method
        self.navigationItem.rightBarButtonItems = nil;
        if ([self.dashboardLoader respondsToSelector:@selector(reloadMaximizedDashletWithCompletion:)]) {
            UIBarButtonItem *refreshDashlet = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"refresh_action"]
                                                                               style:UIBarButtonItemStylePlain
                                                                              target:self
                                                                              action:@selector(reloadDashlet)];
            self.navigationItem.rightBarButtonItem = refreshDashlet;
        }

        self.leftButtonItem = self.navigationItem.leftBarButtonItem;
        self.navigationItem.title = dashlet.name;
    }
}

- (void)externalWindowDashboardControlsVC:(JMExternalWindowDashboardControlsVC *)dashboardControlsVC didAskMinimizeDashlet:(JMDashlet *)dashlet
{
    if ([self.dashboardLoader respondsToSelector:@selector(maximizeDashlet:)]) {
        [self.dashboardLoader minimizeDashlet:dashlet];

        // TODO: move to separate method
        self.navigationItem.leftBarButtonItem = self.leftButtonItem;
        self.navigationItem.rightBarButtonItems = self.rightButtonItems;
        self.navigationItem.title = [self resourceLookup].label;
        self.leftButtonItem = nil;
    }
}

@end