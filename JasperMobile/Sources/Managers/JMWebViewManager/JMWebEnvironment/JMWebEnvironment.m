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
//  JMWebEnvironment.m
//  TIBCO JasperMobile
//

#import "JMWebEnvironment.h"
#import "JMJavascriptNativeBridge.h"

@interface JMWebEnvironment()
@property (nonatomic, strong) JMJavascriptNativeBridge * __nonnull bridge;
@end

@implementation JMWebEnvironment

#pragma mark - Initializers
- (void)dealloc
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
}

- (instancetype)initWithId:(NSString *)identifier
{
    self = [super init];
    if (self) {
        _identifier = identifier;
        _webView = [self createWebView];
        _bridge = [JMJavascriptNativeBridge bridgeWithWebView:_webView];
    }
    return self;
}

+ (instancetype)webEnvironmentWithId:(NSString *)identifier
{
    return [[self alloc] initWithId:identifier];
}

#pragma mark - Public API
- (void)loadHTML:(NSString * __nonnull)HTMLString
         baseURL:(NSURL * __nullable)baseURL
      completion:(JMWebEnvironmentRequestBooleanCompletion __nullable)completion
{
    [self.bridge startLoadHTMLString:HTMLString
                             baseURL:baseURL
                          completion:^(JMJavascriptCallback *callback, NSError *error) {
                              if (error) {
                                  completion(NO, error);
                              } else {
                                  completion(YES, nil);
                              }
    }];
}

- (void)loadRequest:(NSURLRequest * __nonnull)request
{
    [self.bridge loadRequest:request];
}

- (void)verifyEnvironmentReadyWithCompletion:(void(^ __nonnull)(BOOL isWebViewLoaded))completion
{
    [self isWebViewLoadedVisualize:self.webView completion:completion];
}

- (void)sendJavascriptRequest:(JMJavascriptRequest *__nonnull)request
                   completion:(JMJavascriptRequestCompletion __nullable)completion
{
    [self.bridge sendJavascriptRequest:request
                            completion:completion];
}

- (void)injectJSInitCode:(NSString *__nonnull)jsCodeString
{
    [self.bridge injectJSInitCode:jsCodeString];
}

- (void)addListenerWithId:(NSString *__nonnull)listenerId
                 callback:(JMWebEnvironmentRequestParametersCompletion __nullable)callback
{
    [self.bridge addListenerWithId:listenerId
                          callback:^(JMJavascriptCallback *jsCallback, NSError *error) {
                              if (callback) {
                                  callback(jsCallback.parameters, nil);
                              } else {
                                  callback(nil, error);
                              }
                          }];
}

- (void)removeAllListeners
{
    [self.bridge removeAllListeners];
}

- (void)resetZoom
{

}

- (void)clean
{
    [self.bridge reset];
}

- (void)reset
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    _webView.navigationDelegate = nil;
    _webView = nil;
}

#pragma mark - Helpers
- (WKWebView *)createWebView
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    WKWebViewConfiguration* webViewConfig = [WKWebViewConfiguration new];
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:webViewConfig];
    webView.scrollView.bounces = NO;

    // TODO: setup on bridge level

    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"resource_viewer" ofType:@"html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    [webView loadHTMLString:htmlString
                    baseURL:[NSURL URLWithString:self.restClient.serverProfile.serverUrl]];

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

@end