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


#import "JMResourceViewerViewController.h"
#import "JMWebViewManager.h"
#import "ALToastView.h"

@implementation JMResourceViewerViewController

#pragma mark - UIViewController LifeCycle
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    if (self.webView.loading) {
        [self stopShowLoadingIndicators];
        // old dashboards don't load empty page
        //[self.webView stopLoading];
    }
}

#pragma mark - Setups
- (void)setupSubviews
{
    CGRect rootViewBounds = self.navigationController.view.bounds;
    UIWebView *webView = [[JMWebViewManager sharedInstance] webViewWithParentFrame:rootViewBounds];
    webView.delegate = self;
    [self.view insertSubview:webView belowSubview:self.activityIndicator];
    self.webView = webView;
}

- (void)resetSubViews
{
    [self.webView stopLoading];
    [self.webView loadHTMLString:nil baseURL:nil];
}

- (void)cancelResourceViewingAndExit:(BOOL)exit
{
    [self resetSubViews];
    [self.view endEditing:YES];
    self.webView.delegate = nil;

    [super cancelResourceViewingAndExit:exit];
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *serverHost = [NSURL URLWithString:self.restClient.serverProfile.serverUrl].host;
    NSString *requestHost = request.URL.host;
    BOOL isParentHost = [requestHost isEqualToString:serverHost];
    BOOL isLinkClicked = navigationType == UIWebViewNavigationTypeLinkClicked;

    if (!isParentHost && isLinkClicked) {
        if ([[UIApplication sharedApplication] canOpenURL:request.URL]) {
            [[UIAlertView localizedAlertWithTitle:@"dialod.title.attention"
                                          message:@"resource.viewer.open.link"
                                       completion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                        if (alertView.cancelButtonIndex != buttonIndex) {
                                                            [[UIApplication sharedApplication] openURL:request.URL];
                                                        }
                                                    }
                                cancelButtonTitle:@"dialog.button.cancel"
                                otherButtonTitles:@"dialog.button.ok", nil] show];
        } else {
            [ALToastView toastInView:webView
                            withText:JMCustomLocalizedString(@"resource.viewer.can't.open.link", nil)];
        }
        return NO;
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self startShowLoadingIndicators];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self stopShowLoadingIndicators];
    if (self.resourceRequest) {
        self.isResourceLoaded = YES;
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self stopShowLoadingIndicators];
    self.isResourceLoaded = NO;
}

@end
