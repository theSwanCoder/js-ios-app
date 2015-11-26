/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2015 TIBCO Software, Inc. All rights reserved.
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

#pragma mark - Lifecycle
- (void)dealloc
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
}

+ (instancetype)sharedInstance {
    static JMWebViewManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

#pragma mark - Public API
- (UIWebView *)webView
{
    return [self webViewAsSecondary:NO];
}

- (UIWebView *)webViewAsSecondary:(BOOL)asSecondary
{
    UIWebView *webView;
    if (asSecondary) {
        webView = self.secondaryWebView;
    } else {
        webView = self.primaryWebView;
    }

    webView.scrollView.minimumZoomScale = 1;
    webView.scrollView.maximumZoomScale = 2;

    return webView;
}

- (BOOL)isWebViewEmpty:(UIWebView *)webView
{
    NSString *jsCommand = @"document.getElementsByTagName('body')[0].innerHTML";
    NSString *result = [webView stringByEvaluatingJavaScriptFromString:jsCommand];
    BOOL isWebViewEmpty = result.length == 0;
    return isWebViewEmpty;
}

- (void)reset
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    _primaryWebView.delegate = nil;
    _primaryWebView = nil;

    [self resetChildWebView];
}

- (void)resetChildWebView
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    _secondaryWebView.delegate = nil;
    _secondaryWebView = nil;
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
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    webView.scrollView.bounces = NO;
    webView.scalesPageToFit = YES;
    webView.dataDetectorTypes = UIDataDetectorTypeNone;
    webView.suppressesIncrementalRendering = YES;
    return webView;
}

@end
