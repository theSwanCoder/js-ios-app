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


#import <SplunkMint-iOS/SplunkMint-iOS.h>
#import "JMDashboardsViewerViewController.h"
#import "JMVisualizeClient.h"
#import "JMWebConsole.h"
#import "JMCancelRequestPopup.h"

@interface JMDashboardsViewerViewController() <JMVisualizeClientDelegate>
@property (strong, nonatomic) JMVisualizeClient *visualizeClient;
@property (strong, nonatomic) NSArray *rightButtonItems;
@property (assign, nonatomic) BOOL isCommandSend;
@property (assign, nonatomic) BOOL isPopupVisible;
@end

@implementation JMDashboardsViewerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.isCommandSend = NO;
    self.isPopupVisible = NO;

    [JMWebConsole enable];

    self.visualizeClient = [JMVisualizeClient new];
    self.visualizeClient.delegate = self;
    self.visualizeClient.webView = self.webView;

    self.rightButtonItems = self.navigationItem.rightBarButtonItems;

    self.webView.scalesPageToFit = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.webView.backgroundColor = [UIColor whiteColor];
    self.webView.opaque = NO;

    if ([self isServerVersionUp6] && [self isNewDashboard]) {
        self.webView.scrollView.maximumZoomScale = 5;
        self.webView.scrollView.minimumZoomScale = 0.1;
        [self.webView.scrollView setZoomScale:0.1 animated:NO];
    }
}

- (void)runReportExecution
{
    NSString *dashboardUrl;

    if (self.resourceClient.serverProfile.serverInfo.versionAsFloat >= [JSConstants sharedInstance].SERVER_VERSION_CODE_AMBER_6_0_0 &&
            [self.resourceLookup.resourceType isEqualToString:[JSConstants sharedInstance].WS_TYPE_DASHBOARD]) {
        dashboardUrl = [NSString stringWithFormat:@"%@%@%@", self.resourceClient.serverProfile.serverUrl, @"/dashboard/viewer.html?_opt=true&sessionDecorator=no&decorate=no#", self.resourceLookup.uri];
    } else {
        dashboardUrl = [NSString stringWithFormat:@"%@%@%@", self.resourceClient.serverProfile.serverUrl, @"/flow.html?_flowId=dashboardRuntimeFlow&viewAsDashboardFrame=true&dashboardResource=", self.resourceLookup.uri];
        dashboardUrl = [dashboardUrl stringByAppendingString:@"&"];
    }
    NSURL *url = [NSURL URLWithString:dashboardUrl];
//    self.resourceRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:self.resourceClient.timeoutInterval];
    self.resourceRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:self.resourceClient.timeoutInterval];
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
        self.isCommandSend = NO;
        [self.webView reload];
    }
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([self isServerVersionUp6] && [self isNewDashboard]) {
        return ![self.visualizeClient isCallbackRequest:request];
    } else {
        return [super webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self showLoadingPopup];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if ([self isServerVersionUp6] && [self isNewDashboard]) {
        if (!self.isCommandSend) {
            self.isCommandSend = YES;

            [self.webView.scrollView setZoomScale:0.1 animated:YES];

            NSString *jsMobilePath = [[NSBundle mainBundle] pathForResource:@"jaspermobile" ofType:@"js"];
            NSError *error;
            NSString *jsMobile = [NSString stringWithContentsOfFile:jsMobilePath encoding:NSUTF8StringEncoding error:&error];
            if (jsMobile) {
                [self.webView stringByEvaluatingJavaScriptFromString:jsMobile];
            } else {
                NSLog(@"load jaspermobile.js error: %@", error.localizedDescription);
            }
        }
    } else {
        [self dissmissLoadingPopup];
        [super webViewDidFinishLoad:webView];
    }
}

#pragma mark - Actions
- (void)minimizeDashboard
{
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.rightBarButtonItems = self.rightButtonItems;
    self.navigationItem.title = self.resourceLookup.label;
    [self.visualizeClient minimizeDashlet];
}

#pragma mark - JMVisualizeClientDelegate
- (void)visualizeClientDidEndLoading
{
    [self dissmissLoadingPopup];
}

- (void)visualizeClientDidMaximizeDashletWithTitle:(NSString *)title
{
    [self.webView.scrollView setZoomScale:0.1 animated:YES];
    //self.webView.scalesPageToFit = YES;
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(minimizeDashboard)];
    self.navigationItem.rightBarButtonItem = barButtonItem;

    self.navigationItem.title = title;
}

#pragma mark - Methods
- (void)showLoadingPopup {
    if (!self.isPopupVisible) {
        self.isPopupVisible = YES;
        [JMCancelRequestPopup presentInViewController:self
                                              message:@"status.loading"
                                           restClient:nil
                                          cancelBlock:@weakself(^(void))
                                                                              {
                                                                                  self.isPopupVisible = NO;
                                                                                  [self.webView stopLoading];
                                                                                  [self.navigationController popViewControllerAnimated:YES];
                                                                              }
                                                                              @weakselfend];
    }
}

- (void)dissmissLoadingPopup {
    [JMCancelRequestPopup dismiss];
}

#pragma mark - Utils
- (BOOL)isServerVersionUp6
{
    return self.resourceClient.serverProfile.serverInfo.versionAsFloat >= [JSConstants sharedInstance].SERVER_VERSION_CODE_AMBER_6_0_0;
}

- (BOOL)isNewDashboard
{
    return [self.resourceLookup.resourceType isEqualToString:[JSConstants sharedInstance].WS_TYPE_DASHBOARD];
}

@end
