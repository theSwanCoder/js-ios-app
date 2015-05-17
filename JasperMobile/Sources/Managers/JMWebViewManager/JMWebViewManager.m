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
//  JMWebViewManager.h
//  TIBCO JasperMobile
//

#import "JMWebViewManager.h"
#import "JMUtils.h"

@interface JMWebViewManager()
@property (nonatomic, strong, readwrite) UIWebView *primaryWebView;
@property (nonatomic, strong, readwrite) UIWebView *secondaryWebView;
@end

@implementation JMWebViewManager

#pragma mark - Public API

+ (instancetype)sharedInstance {
    static JMWebViewManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (UIWebView *)webViewWithParentFrame:(CGRect)frame
{
    return [self webViewWithParentFrame:frame asSecondary:NO];
}

- (UIWebView *)webViewWithParentFrame:(CGRect)frame asSecondary:(BOOL)asSecondary
{
    UIWebView *webView;
    if (asSecondary) {
        webView = self.secondaryWebView;
    } else {
        webView = self.primaryWebView;
    }

    [self updateFrame:frame forWebView:webView];

    webView.scrollView.minimumZoomScale = 1;
    webView.scrollView.maximumZoomScale = 2;

    return webView;
}

- (void)reset
{
    self.primaryWebView.delegate = nil;
    self.primaryWebView = nil;

    [self resetChildWebView];
}

- (void)resetChildWebView
{
    self.secondaryWebView.delegate = nil;
    self.secondaryWebView = nil;
}

#pragma mark - Private API

- (UIWebView *)primaryWebView
{
    if (!_primaryWebView) {
        _primaryWebView = [self createWebView];
    }
    return _primaryWebView;
}

- (UIWebView *)secondaryWebView
{
    if (!_secondaryWebView) {
        _secondaryWebView = [self createWebView];
    }
    return _secondaryWebView;
}

- (UIWebView *)createWebView
{
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    webView.scrollView.bounces = NO;
    webView.scalesPageToFit = YES;
    webView.dataDetectorTypes = UIDataDetectorTypeNone;
    webView.suppressesIncrementalRendering = YES;
    return webView;
}

- (void)updateFrame:(CGRect)frame forWebView:(UIWebView *)webView
{
    if (![JMUtils isSystemVersion8]) {
        UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
        CGRect webViewFrame = CGRectZero;
        if ( UIInterfaceOrientationIsPortrait(statusBarOrientation) ) {
            webViewFrame = frame;
        } else {
            webViewFrame = CGRectMake(0, 0, CGRectGetHeight(frame), CGRectGetWidth(frame));
        }

        webView.frame = webViewFrame;
    } else {
        webView.frame = frame;
    }
}


@end
