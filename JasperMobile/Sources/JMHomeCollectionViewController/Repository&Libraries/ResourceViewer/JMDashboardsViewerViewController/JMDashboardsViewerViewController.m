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
#import "JMVisualizeClient.h"

@interface JMDashboardsViewerViewController() <JMVisualizeClientDelegate>
@property (strong, nonatomic) JMVisualizeClient *visualizeClient;
@property (strong, nonatomic) NSArray *rightButtonItems;
@end

@implementation JMDashboardsViewerViewController

#pragma mark - View Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupWebView];
    self.rightButtonItems = self.navigationItem.rightBarButtonItems;
}

#pragma mark - Methods
- (void)runReportExecution
{
    if ([self isServerVersionUp6] && [self isNewDashboard]) {
        [self runWithVisualize];
    } else {
        [self runWithURL];
    }
}

- (JMMenuActionsViewAction)availableAction
{
    return [super availableAction] | JMMenuActionsViewAction_Refresh;
}

- (void)setResourceRequest:(NSURLRequest *)resourceRequest
{
    if ( !([self isServerVersionUp6] && [self isNewDashboard]) ) {
        [self setResourceRequest:resourceRequest];
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

#pragma mark - JMMenuActionsViewDelegate
- (void)actionsView:(JMMenuActionsView *)view didSelectAction:(JMMenuActionsViewAction)action
{
    [super actionsView:view didSelectAction:action];
    if (action == JMMenuActionsViewAction_Refresh) {
        [self runReportExecution];
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
    [super webViewDidStartLoad:webView];
    if ([self isServerVersionUp6] && [self isNewDashboard]) {
        self.webView.backgroundColor = [UIColor lightGrayColor];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if ([self isServerVersionUp6] && [self isNewDashboard]) {
        self.webView.scrollView.zoomScale = 0.1f;
        [self.visualizeClient runDashboard];
    } else {
        [super webViewDidFinishLoad:webView];
    }
}

#pragma mark - JMVisualizeClientDelegate
- (void)visualizeClientDidEndLoading
{
    self.webView.backgroundColor = [UIColor clearColor];
    [JMUtils hideNetworkActivityIndicator];
    [self.activityIndicator stopAnimating];
}

- (void)visualizeClientDidMaximizeDashletWithTitle:(NSString *)title
{
    [self.webView.scrollView setZoomScale:0.1 animated:YES];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(minimizeDashboard)];
    self.navigationItem.rightBarButtonItem = barButtonItem;

    self.navigationItem.title = title;
}

#pragma mark - Private API
- (void)runWithVisualize
{
    self.resourceRequest = nil;
    [self setupVisualize];
}

- (void)runWithURL
{
    NSString *dashboardUrl;
    dashboardUrl = [NSString stringWithFormat:@"%@%@%@", self.resourceClient.serverProfile.serverUrl, @"/flow.html?_flowId=dashboardRuntimeFlow&viewAsDashboardFrame=true&dashboardResource=", self.resourceLookup.uri];
    dashboardUrl = [dashboardUrl stringByAppendingString:@"&sessionDecorator=no&decorate=no#"];
    NSURL *url = [NSURL URLWithString:dashboardUrl];
    self.resourceRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:self.resourceClient.timeoutInterval];
}

- (void)setupWebView
{
    self.webView.scrollView.maximumZoomScale = 5;
    self.webView.scrollView.minimumZoomScale = 0.1;
}

- (void)setupVisualize
{
    self.visualizeClient = [JMVisualizeClient new];
    self.visualizeClient.delegate = self;
    self.visualizeClient.webView = self.webView;
    self.visualizeClient.resourceClient = self.resourceClient;
    self.visualizeClient.resourceLookup = self.resourceLookup;
    [self.visualizeClient setup];
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
