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
#import "JMReportViewerVC.h"
#import "JMDashboard.h"

@interface JMDashboardViewerVC() <JMDashboardLoaderDelegate>
@property (nonatomic, copy) NSArray *rightButtonItems;
@property (nonatomic, strong) UIBarButtonItem *leftButtonItem;

@property (nonatomic, strong, readwrite) JMDashboard *dashboard;
@property (nonatomic, strong) JMDashboardViewerConfigurator *configurator;
@end


@implementation JMDashboardViewerVC

#pragma mark - Print
- (void)printResource
{
    [self imageFromWebViewWithCompletion:^(UIImage *image) {
        if (image) {
            [self printItem:image
                   withName:self.dashboard.resourceLookup.label];
        }
    }];
}

- (void)imageFromWebViewWithCompletion:(void(^)(UIImage *image))completion
{
    [JMCancelRequestPopup presentWithMessage:@"resource.viewer.print.prepare.title"];
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

    CGRect rootViewBounds = self.navigationController.view.bounds;
    id dashboardView = [self.configurator webViewWithFrame:rootViewBounds asSecondary:NO];
    [self.view addSubview:dashboardView];

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
    [[JMVisualizeWebViewManager sharedInstance] reset];
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
    if (self.restClient.keepSession && [self.restClient isSessionAuthorized]) {

        [self startShowLoaderWithMessage:@"status.loading"
                             cancelBlock:@weakself(^(void)) {
                                     [self.dashboardLoader reset];
                                     [super cancelResourceViewingAndExit:YES];
                                 }@weakselfend];

        [self.dashboardLoader reloadDashboardWithCompletion:^(BOOL success, NSError *error) {
            [self stopShowLoader];
        }];
    } else {
        [JMUtils showLoginViewAnimated:YES completion:@weakself(^(void)) {
                [self cancelResourceViewingAndExit:YES];
            } @weakselfend];
    }
}

#pragma mark - Overriden methods
- (void)startResourceViewing
{
    [self startShowLoaderWithMessage:@"status.loading"
                         cancelBlock:@weakself(^(void)) {
                                 [self.dashboardLoader reset];
                                 [super cancelResourceViewingAndExit:YES];
                             }@weakselfend];

    [self.dashboardLoader loadDashboardWithCompletion:^(BOOL success, NSError *error) {
        [self stopShowLoader];
    }];
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
    [[self webView].scrollView setZoomScale:0.1 animated:YES];
    self.navigationItem.rightBarButtonItems = nil;

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

        NSString *reportURI = [resourceLookup.uri stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [self loadInputControlsWithReportURI:reportURI completion:@weakself(^(NSArray *inputControls, NSError *error)) {
                if (error) {
                    [JMUtils showAlertViewWithError:error completion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                        [self cancelResourceViewingAndExit:YES];
                    }];
                } else {
                    JMReportViewerVC *reportViewController = [self.storyboard instantiateViewControllerWithIdentifier:[resourceLookup resourceViewerVCIdentifier]];
                    reportViewController.resourceLookup = resourceLookup;
                    [reportViewController.report updateInputControls:inputControls];
                    [reportViewController.report updateReportParameters:parameters];
                    reportViewController.isChildReport = YES;

                    //[self resetSubViews];
                    [self.navigationController pushViewController:reportViewController animated:YES];
                }
            }@weakselfend];
    } else if (hyperlinkType == JMHyperlinkTypeReference) {
        NSURL *URL = parameters.firstObject;
        if (URL) {
            [[UIApplication sharedApplication] openURL:URL];
        }
    }
}

- (void)dashboardLoaderDidReceiveAuthRequest:(id <JMDashboardLoader>)loader
{
    [self reloadDashboard];
}

#pragma mark - Report Options (Input Controls)
- (void)loadInputControlsWithReportURI:(NSString *)reportURI completion:(void (^)(NSArray *inputControls, NSError *error))completion
{
    [self.restClient inputControlsForReport:reportURI
                                        ids:nil
                             selectedValues:nil
                            completionBlock:@weakself(^(JSOperationResult *result)) {

                                    if (result.error) {
                                        if (result.error.code == JSSessionExpiredErrorCode) {
                                            if (self.restClient.keepSession && [self.restClient isSessionAuthorized]) {
                                                [self loadInputControlsWithReportURI:reportURI completion:completion];
                                            } else {
                                                [JMUtils showLoginViewAnimated:YES completion:@weakself(^(void)) {
                                                        [self cancelResourceViewingAndExit:YES];
                                                    } @weakselfend];
                                            }
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

                                }@weakselfend];
}

#pragma mark - Helpers
- (BOOL)isDashletShown
{
    return self.leftButtonItem != nil;
}

@end