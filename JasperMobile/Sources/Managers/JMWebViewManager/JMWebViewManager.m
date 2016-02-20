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
@property (nonatomic, strong, readwrite) WKWebView *primaryWebView;
@property (nonatomic, strong, readwrite) WKWebView *secondaryWebView;
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
- (WKWebView *)webView
{
    return [self webViewAsSecondary:NO];
}

- (WKWebView *)webViewAsSecondary:(BOOL)asSecondary
{
    WKWebView *webView;
    if (asSecondary) {
        webView = self.secondaryWebView;
    } else {
        webView = self.primaryWebView;
    }

    webView.scrollView.zoomScale = 1;
    webView.scrollView.minimumZoomScale = 1;
    webView.scrollView.maximumZoomScale = 2;

    return webView;
}

- (void)isWebViewLoadedVisualize:(WKWebView *)webView completion:(void(^ __nonnull)(BOOL isWebViewLoaded))completion
{
    NSString *jsCommand = @"typeof(visualize)";
    [webView evaluateJavaScript:jsCommand completionHandler:^(id result, NSError *error) {
        BOOL isFunction = [result isEqualToString:@"function"];
        completion(!error && isFunction);
    }];
}

- (void)reset
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    _primaryWebView.navigationDelegate = nil;
    _primaryWebView = nil;

    [self resetChildWebView];
}

- (void)resetChildWebView
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    _secondaryWebView.navigationDelegate = nil;
    _secondaryWebView = nil;
}

- (void)resetZoom
{
    [_primaryWebView.scrollView setZoomScale:0.1
                                        animated:YES];
    [_secondaryWebView.scrollView setZoomScale:0.1
                                          animated:YES];
}

- (void)injectCookiesInWebView:(WKWebView *)webView
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [self verifyCookiesInWebView:webView completion:^(NSDictionary *webViewCookieValues){
        NSDictionary *cookieValues = [self cookieValues];
        NSString *cookiesAsString = [self cookiesAsStringFromCookieValues:cookieValues];
        [webView evaluateJavaScript:cookiesAsString completionHandler:nil];
    }];
}

- (void)cleanCookiesInWebView:(WKWebView *)webView
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [self verifyCookiesInWebView:webView completion:^(NSDictionary *webViewCookieValues){
        NSMutableDictionary *cookieValues = [[self cookieValues] mutableCopy];
        for (NSString *cookieName in cookieValues.allKeys) {
            cookieValues[cookieName] = @"";
        }
        NSString *cookiesAsString = [self cookiesAsStringFromCookieValues:cookieValues];
        [webView evaluateJavaScript:cookiesAsString completionHandler:nil];
    }];
}

#pragma mark - Private API

- (WKWebView *)primaryWebView
{
    if (!_primaryWebView) {
        _primaryWebView = [self createWebView];
    }
    return _primaryWebView;
}

- (WKWebView *)secondaryWebView
{
    if (!_secondaryWebView) {
        _secondaryWebView = [self createWebView];
    }
    return _secondaryWebView;
}

- (WKWebView *)createWebView
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    WKWebViewConfiguration* webViewConfig = [WKWebViewConfiguration new];
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:webViewConfig];
    webView.scrollView.bounces = NO;

    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"resource_viewer" ofType:@"html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    [webView loadHTMLString:htmlString
                    baseURL:[NSURL URLWithString:self.restClient.serverProfile.serverUrl]];

    return webView;
}

- (NSString *)cookiesAsStringFromCookieValues:(NSDictionary *)cookieValues
{
    NSString *cookiesAsString = @"";
    for (NSString *name in cookieValues) {
        cookiesAsString = [cookiesAsString stringByAppendingFormat:@"document.cookie = '%@=%@' ;", name, cookieValues[name]];
    }
    return cookiesAsString;
}

- (NSDictionary *)cookieValues
{
    NSLog(@"restClient cockies: %@", self.restClient.cookies);
    NSMutableDictionary *cookieValues = [@{} mutableCopy];
    for (NSHTTPCookie *cookie in self.restClient.cookies) {
        cookieValues[cookie.name] = cookie.value;
    }
    return cookieValues;
}

- (void)verifyCookiesInWebView:(WKWebView *)webView completion:(void(^ __nonnull)(NSDictionary *cookiesValues))completion
{
    NSString *getCookiesJS = @"document.cookie";
    [webView evaluateJavaScript:getCookiesJS completionHandler:^(id result, NSError *error) {
//        JMLog(@"error: %@", error);
//        JMLog(@"result: %@", result);

        NSMutableDictionary *cookiesValues = [@{} mutableCopy];
        if (!error) {
            NSArray *cookies=nil;
            NSString *cookiesString = result;
            cookies = [cookiesString componentsSeparatedByString:@";"];
            if (cookies.count > 0) {
//                JMLog(@"cookies: %@", cookies);
                for (NSString *cookie in cookies) {
                    NSString *trimmedCookie = [cookie stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    if ([trimmedCookie rangeOfString:@"="].length) {
                        NSArray *components = [trimmedCookie componentsSeparatedByString:@"="];
                        NSString *name = components[0];
                        NSString *value = components[1];
                        cookiesValues[name] = value;
                    }
                }
            }
        }
        completion(cookiesValues);
    }];
}

@end
