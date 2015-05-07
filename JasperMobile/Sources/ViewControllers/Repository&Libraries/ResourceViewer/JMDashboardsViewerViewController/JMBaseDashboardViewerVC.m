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


#import "JMBaseDashboardViewerVC.h"
#import "RKObjectmanager.h"

@implementation JMBaseDashboardViewerVC

#pragma mark - Actions
- (void)reloadDashboard
{
    if (self.restClient.keepSession && [self.restClient isSessionAuthorized]) {
        [self clearContentWebView];
        // waiting until page will be cleared
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self startLoadDashboard];
        });
    } else {
        [JMUtils showLoginViewAnimated:YES completion:@weakself(^(void)) {
            [self cancelResourceViewingAndExit];
        } @weakselfend];
    }
}

#pragma mark - Overriden methods
- (JSResourceLookup *)currentResourceLookup
{
    return self.dashboard.resourceLookup;
}

- (void)startResourceViewing
{
    [self startLoadDashboard];
}

- (JMMenuActionsViewAction)availableActionForResource:(JSResourceLookup *)resource
{
    return [super availableActionForResource:resource] | JMMenuActionsViewAction_Refresh;
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    NSString *requestUrl = request.URL.absoluteString;
    NSLog(@"Dashboard");
    NSLog(@"request url: %@", requestUrl);
    
    if ([requestUrl isEqualToString:@"http://localhost/"]) {
        // clearing web view
        NSLog(@"clearing web view");
        return YES;
    }

    // Check request to login and handle it
    NSString *loginUrlRegex = [NSString stringWithFormat:@"%@/login.html(.+)?", self.restClient.serverProfile.serverUrl];
    NSPredicate *loginUrlValidator = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", loginUrlRegex];
    if ([loginUrlValidator evaluateWithObject:requestUrl]) {
        [self.restClient deleteCookies];
        [self reloadDashboard];
        return NO;
    }
    
    
    BOOL sholdStartFromSuperclass = [super webView:webView shouldStartLoadWithRequest:request
                                    navigationType:navigationType];
    
    NSString *requestURLString = request.URL.absoluteString;
    
    //  don't let run link run report
    if ([requestURLString rangeOfString:@"_flowId=viewReportFlow&reportUnit"].length) {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }

    return sholdStartFromSuperclass;
}

#pragma mark - JMMenuActionsViewDelegate
- (void)actionsView:(JMMenuActionsView *)view didSelectAction:(JMMenuActionsViewAction)action
{
    [super actionsView:view didSelectAction:action];
    if (action == JMMenuActionsViewAction_Refresh) {
        [self reloadDashboard];
    }
}

#pragma mark - Start Point
- (void)startLoadDashboard
{    
    if (self.webView.isLoading) {
        [self.webView stopLoading];
    }
    [self.webView loadRequest:self.dashboard.resourceRequest];
}

#pragma mark - Heplers
- (void)clearContentWebView
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [self.webView stopLoading];
    [self.webView loadHTMLString:@"<html><head></head><body></body></html>"
                         baseURL:[NSURL URLWithString:@"http://localhost"]];
    // TODO: for test purpose only
    //[[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (void)resetSubViews
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [self clearContentWebView];
    self.webView.delegate = nil;
    [self.webView removeFromSuperview];
    [[JMWebViewManager sharedInstance] reset];
}

@end