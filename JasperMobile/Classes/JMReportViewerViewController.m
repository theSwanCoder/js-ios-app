/*
 * JasperMobile for iOS
 * Copyright (C) 2011 - 2014 Jaspersoft Corporation. All rights reserved.
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
//  JMReportViewerViewController.m
//  Jaspersoft Corporation
//

#import "JMReportViewerViewController.h"
#import "JMRotationBase.h"
#import "JMUtils.h"

@interface JMReportViewerViewController()
@property (nonatomic, assign) BOOL isRequestLoaded;
@end

@implementation  JMReportViewerViewController
inject_default_rotation()

@synthesize request = _request;

- (void)setRequest:(NSURLRequest *)request
{
    if (request != _request) {
        _request = request;
        if (self.webView.isLoading) {
            [self.webView stopLoading];
        }
        [self.webView loadRequest:request];
        self.isRequestLoaded = NO;
    }
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.webView.scrollView.bounces = NO;
    self.webView.delegate = self;
    self.webView.suppressesIncrementalRendering = YES;
    [self.webView loadHTMLString:@"" baseURL:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.isRequestLoaded && self.request) {
        [self.webView loadRequest:self.request];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (self.webView.loading) {
        [self.webView stopLoading];
        [self loadingDidFinished];
    }
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.activityIndicator startAnimating];
    [JMUtils showNetworkActivityIndicator];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self loadingDidFinished];
    if (self.request) {
        self.isRequestLoaded = YES;
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self loadingDidFinished];
    self.isRequestLoaded = NO;
}

- (void)loadingDidFinished
{
    [JMUtils hideNetworkActivityIndicator];
    [self.activityIndicator stopAnimating];
}

@end
