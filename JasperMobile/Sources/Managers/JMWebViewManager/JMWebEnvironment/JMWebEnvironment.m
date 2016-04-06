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

@interface JMWebEnvironment() <JMJavascriptNativeBridgeDelegate>
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
        _bridge.delegate = self;
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
    JMJavascriptRequestCompletion javascriptRequestCompletion;

    if (completion) {
        javascriptRequestCompletion = ^(JMJavascriptCallback *callback, NSError *error) {
            if (error) {
                completion(NO, error);
            } else {
                completion(YES, nil);
            }
        };
    }

    [self.bridge startLoadHTMLString:HTMLString
                             baseURL:baseURL
                          completion:javascriptRequestCompletion];
}

- (void)loadRequest:(NSURLRequest * __nonnull)request
{
    if ([request.URL isFileURL]) {
        // TODO: detect format of file for request
        [self loadLocalFileFromURL:request.URL
                        fileFormat:nil
                           baseURL:nil];
    } else {
        [self.webView loadRequest:request];
    }
}

- (void)loadLocalFileFromURL:(NSURL *)fileURL
                  fileFormat:(NSString *)fileFormat
                     baseURL:(NSURL *)baseURL
{
    if (baseURL && [fileFormat.lowercaseString isEqualToString:@"html"]) {
        NSString* content = [NSString stringWithContentsOfURL:fileURL
                                                     encoding:NSUTF8StringEncoding
                                                        error:NULL];
        [self.webView loadHTMLString:content
                             baseURL:baseURL];
    } else {
        if ([JMUtils isSystemVersion9]) {
            [self.webView loadFileURL:fileURL
              allowingReadAccessToURL:fileURL];
        } else {
            [self.webView loadRequest:[NSURLRequest requestWithURL:fileURL]];
        }
    }
}

- (void)verifyEnvironmentReadyWithCompletion:(void(^ __nonnull)(BOOL isWebViewLoaded))completion
{
    [self isWebViewLoadedVisualize:self.webView completion:completion];
}

- (void)verifyJasperMobileReadyWithCompletion:(void(^ __nonnull)(BOOL isWebViewLoaded))completion
{
    [self isWebViewLoadedJasperMobile:self.webView completion:completion];
}

- (void)sendJavascriptRequest:(JMJavascriptRequest *__nonnull)request
                   completion:(JMWebEnvironmentRequestParametersCompletion __nullable)completion
{
    if (completion) {
        [self.bridge sendJavascriptRequest:request
                                completion:^(JMJavascriptCallback *callback, NSError *error) {
                                    completion(callback.parameters, error);
                                }];
    } else {
        [self.bridge sendJavascriptRequest:request
                                completion:nil];
    }
}

- (void)addListenerWithId:(NSString *)listenerId
                 callback:(JMWebEnvironmentRequestParametersCompletion)callback
{
    [self.bridge addListenerWithId:listenerId
                          callback:^(JMJavascriptCallback *jsCallback, NSError *error) {
                              callback(jsCallback.parameters, error);
                          }];
}

- (void)removeAllListeners
{
    [self.bridge removeAllListeners];
}

- (void)resetZoom
{
    [self.webView.scrollView setZoomScale:0.1 animated:YES];
}

- (void)clean
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [self.bridge removeAllListeners];

    NSURLRequest *clearingRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]];
    [self.webView loadRequest:clearingRequest];
}

#pragma mark - Helpers
- (WKWebView *)createWebView
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    WKWebViewConfiguration* webViewConfig = [WKWebViewConfiguration new];
    WKUserContentController *contentController = [WKUserContentController new];

    [contentController addUserScript:[self injectCookiesScript]];
    [contentController addUserScript:[self jaspermobileScript]];

    webViewConfig.userContentController = contentController;

    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:webViewConfig];
    webView.scrollView.bounces = NO;

    // From for iOS9
//    webView.customUserAgent = @"Mozilla/5.0 (Linux; Android 5.0.1; SCH-I545 Build/LRX22C) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.95 Mobile Safari/537.36";
    return webView;
}

- (WKUserScript *)jaspermobileScript
{
    NSString *jaspermobilePath = [[NSBundle mainBundle] pathForResource:@"vis_jaspermobile" ofType:@"js"];
    NSString *jaspermobileString = [NSString stringWithContentsOfFile:jaspermobilePath encoding:NSUTF8StringEncoding error:nil];

    WKUserScript *script = [[WKUserScript alloc] initWithSource:jaspermobileString
                                                  injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                               forMainFrameOnly:YES];
    return script;
}

- (WKUserScript *)injectCookiesScript
{
    NSString *cookiesAsString = [self cookiesAsStringFromCookies:self.restClient.cookies];

    WKUserScript *script = [[WKUserScript alloc] initWithSource:cookiesAsString
                                                  injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                               forMainFrameOnly:YES];
    return script;
}

- (NSString *)cookiesAsStringFromCookies:(NSArray <NSHTTPCookie *>*)cookies
{
    NSString *cookiesAsString = @"";
    for (NSHTTPCookie *cookie in cookies) {
        NSString *name = cookie.name;
        NSString *value = cookie.value;
        NSString *path = cookie.path;
        cookiesAsString = [cookiesAsString stringByAppendingFormat:@"document.cookie = '%@=%@; expires=null, path=\\'%@\\''; ", name, value, path];
    }
    return cookiesAsString;
}

- (void)isWebViewLoadedVisualize:(WKWebView *)webView completion:(void(^ __nonnull)(BOOL isWebViewLoaded))completion
{
    NSString *jsCommand = @"typeof(visualize)";
    [webView evaluateJavaScript:jsCommand completionHandler:^(id result, NSError *error) {
        BOOL isFunction = [result isEqualToString:@"function"];
        completion(!error && isFunction);
    }];
}

- (void)isWebViewLoadedJasperMobile:(WKWebView *)webView completion:(void(^ __nonnull)(BOOL isWebViewLoaded))completion
{
    NSString *jsCommand = @"typeof(JasperMobile)";
    [webView evaluateJavaScript:jsCommand completionHandler:^(id result, NSError *error) {
        BOOL isObject = [result isEqualToString:@"object"];
        completion(!error && isObject);
    }];
}

#pragma mark - JMJavascriptNativeBridgeDelegate
- (void)javascriptNativeBridge:(JMJavascriptNativeBridge *__nonnull)bridge didReceiveOnWindowError:(NSError *__nonnull)error
{
    // TODO: move to loader layer
    [JMUtils presentAlertControllerWithError:error
                                  completion:nil];
}

@end