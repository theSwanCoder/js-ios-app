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
#import "JMFilter.h"
#import "JMRotationBase.h"
#import "JMUtils.h"

@implementation JMDashboardViewController
inject_default_rotation()

@synthesize resourceClient = _resourceClient;
@synthesize resourceDescriptor = _resourceDescriptor;

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.webView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [JMFilter checkNetworkReachabilityForBlock:^{
        NSString *dashboardUrl = [NSString stringWithFormat:@"%@%@%@",
                                  self.resourceClient.serverProfile.serverUrl,
                                  @"/flow.html?_flowId=dashboardRuntimeFlow&viewAsDashboardFrame=true&dashboardResource=",
                                  self.resourceDescriptor.uriString];
        
        [self.activityIndicator startAnimating];
        
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:dashboardUrl]]];
    } viewControllerToDismiss:self];
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
        [self.webView stopLoading];
        // Hide network indicator if webView did not finish loading yet (back button
        // was pressed earlier)
        [JMUtils hideNetworkActivityIndicator];
    }
}

@end
