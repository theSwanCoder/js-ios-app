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

@interface JMReportViewerViewController() <UIGestureRecognizerDelegate>
@property (nonatomic, assign) BOOL isRequestLoaded;
@property (nonatomic, assign) BOOL isVisible;
@end

@implementation  JMReportViewerViewController
inject_default_rotation()

@synthesize request = _request;

- (void)setRequest:(NSURLRequest *)request
{
    if (request != _request) {
        _request = request;
        if (self.isVisible && !self.isRequestLoaded) {
            [self.webView loadRequest:request];
        }
    }
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.webView.scrollView.bounces = NO;
    self.webView.delegate = self;
    self.webView.suppressesIncrementalRendering = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.isRequestLoaded && self.request) {
        [self.webView loadRequest:self.request];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.isVisible = YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.isVisible = NO;
    [self.webView stopLoading];
    [JMUtils hideNetworkActivityIndicator];
}

- (void)dealloc
{
    [self.webView loadHTMLString:@"" baseURL:nil];
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
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self loadingDidFinished];
}

- (void)loadingDidFinished
{
    [JMUtils hideNetworkActivityIndicator];
    [self.activityIndicator stopAnimating];
    self.isRequestLoaded = YES;
}

@end
