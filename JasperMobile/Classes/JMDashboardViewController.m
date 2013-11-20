/*
 * JasperMobile for iOS
 * Copyright (C) 2011 - 2013 Jaspersoft Corporation. All rights reserved.
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
//  JMDashboardViewController.m
//  Jaspersoft Corporation
//

#import "JMDashboardViewController.h"
#import "JMUtils.h"

@implementation JMDashboardViewController
inject_default_rotation()

@synthesize resourceClient = _resourceClient;
@synthesize resourceLookup = _resourceLookup;

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.webView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    NSString *dashboardUrl = [NSString stringWithFormat:@"%@%@%@",
                              self.resourceClient.serverProfile.serverUrl,
                              @"/flow.html?_flowId=dashboardRuntimeFlow&viewAsDashboardFrame=true&dashboardResource=",
                              self.resourceLookup.uri];

    NSURL *url = [NSURL URLWithString:dashboardUrl];    
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:500];
    [JMUtils showNetworkActivityIndicator];
    [self.activityIndicator startAnimating];
    [self.webView loadRequest:request];
}

- (void)viewDidUnload
{
    self.webView = nil;
    self.activityIndicator = nil;
    [super viewDidUnload];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [JMUtils hideNetworkActivityIndicator];
    [self.activityIndicator stopAnimating];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (self.webView.isLoading) {
        [self.webView loadHTMLString:@"" baseURL:nil];
        [self.webView stopLoading];
        [self.webView setDelegate:nil];
        [self.webView removeFromSuperview];
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        // Hide network indicator if webView did not finish loading yet (back button
        // was pressed earlier)
        [JMUtils hideNetworkActivityIndicator];
    }
}

@end
