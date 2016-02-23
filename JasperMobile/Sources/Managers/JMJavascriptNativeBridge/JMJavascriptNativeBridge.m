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
//  JMJavascriptNativeBridge.m
//  TIBCO JasperMobile
//

#import "JMJavascriptNativeBridge.h"

NSString *const kJMJavascriptNativeBridgeCallbackURL = @"jaspermobile.callback";

@interface JMJavascriptNativeBridge() <WKNavigationDelegate>
@property (nonatomic, copy) NSString *jsInitCode;
@property (nonatomic, assign) BOOL isJSInitCodeInjected;
@property (nonatomic, weak, readwrite) WKWebView *webView;
@property (nonatomic, strong) NSMutableDictionary <JMJavascriptRequest *, JMJavascriptRequestCompletion>*requestCompletions;
@property (nonatomic, strong) NSMutableDictionary <JMJavascriptRequest *, JMJavascriptRequestCompletion>*listenerCallbacks ;
@end

@implementation JMJavascriptNativeBridge
@synthesize webView = _webView, delegate = _delegate;

#pragma mark - Custom Initializers
- (instancetype __nullable)initWithWebView:(WKWebView * __nonnull)webView
{
    self = [super init];
    if (self) {
        _requestCompletions = [NSMutableDictionary dictionary];
        _listenerCallbacks = [NSMutableDictionary dictionary];
        _webView = webView;
        _webView.navigationDelegate = self;
        _isJSInitCodeInjected = NO;
    }
    return self;
}

+ (instancetype __nullable)bridgeWithWebView:(WKWebView * __nonnull)webView
{
    return [[self alloc] initWithWebView:webView];
}

- (void)dealloc
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
}

#pragma mark - Public API
- (void)startLoadHTMLString:(NSString *)HTMLString
                    baseURL:(NSURL *)baseURL
                 completion:(JMJavascriptRequestCompletion __nullable)completion
{
    if (completion) {
        JMJavascriptRequest *request = [JMJavascriptRequest new];
        request.command = @"DOMContentLoaded";
        __weak __typeof(self) weakSelf = self;
        JMJavascriptRequestCompletion heapBlock = [completion copy];
        JMJavascriptRequestCompletion completionWithCookies = ^(JMJavascriptCallback *callback, NSError *error) {
            __typeof(self) strongSelf = weakSelf;
            [strongSelf injectCookies];
            heapBlock(callback, error);
        };
        self.requestCompletions[request] = [completionWithCookies copy];
    }

    // TODO: replace with safety approach
    if (baseURL) {
        [self.webView stopLoading];
        [self.webView loadHTMLString:HTMLString baseURL:baseURL];
    }
}

- (void)loadRequest:(NSURLRequest *)request
{
    [self.webView stopLoading];
    [self.webView loadRequest:request];
}

- (void)sendJavascriptRequest:(JMJavascriptRequest *__nonnull)request
                   completion:(JMJavascriptRequestCompletion __nullable)completion
{
//    JMLog(@"send request: %@", fullJavascriptString);
    if (completion) {
        self.requestCompletions[request] = [completion copy];
    }

    NSString *command = request.command;
    NSString *parameters = request.parametersAsString ?: @"";
    NSString *fullJavascriptString = [NSString stringWithFormat:@"%@(%@);", command, parameters];
    [self.webView evaluateJavaScript:fullJavascriptString completionHandler:^(id result, NSError *error) {
        JMLog(@"error: %@", error);
        JMLog(@"result: %@", request);
    }];
}

- (void)injectJSInitCode:(NSString *)jsCode
{
    self.isJSInitCodeInjected = NO;
    self.jsInitCode = jsCode;
}

- (void)reset
{
    // TODO: replace with safety approach
    self.isJSInitCodeInjected = NO;
    NSURLRequest *clearingRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@""]];
    [self.webView loadRequest:clearingRequest];
    self.requestCompletions = [NSMutableDictionary dictionary];
    [self removeAllListeners];
}

- (void)addListenerWithId:(NSString *__nonnull)listenerId callback:(JMJavascriptRequestCompletion __nullable)callback
{
    if (callback) {
        JMJavascriptRequest *request = [JMJavascriptRequest new];
        request.command = listenerId;
        self.listenerCallbacks[request] = [callback copy];
    }
}

- (void)removeAllListeners
{
    self.listenerCallbacks = [NSMutableDictionary dictionary];
}

#pragma mark - WKWebViewDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
//    NSLog(@"request from webView: %@", navigationAction.request);
//    NSLog(@"request from webView, allHTTPHeaderFields: %@", navigationAction.request.allHTTPHeaderFields);

    if ([self isLoginRequest:navigationAction.request]) {
        // For dashboard only
        [self.delegate javascriptNativeBridgeDidReceiveAuthRequest:self];
        decisionHandler(WKNavigationActionPolicyCancel);
    }

    if ([self isRequestToRunReport:navigationAction.request]) {
        decisionHandler(WKNavigationActionPolicyCancel);
    }

    if ([self isExternalRequest:navigationAction.request]) {
        BOOL shouldStartLoad = NO;

        if ([self.delegate respondsToSelector:@selector(javascriptNativeBridge:shouldLoadExternalRequest:)]) {
            shouldStartLoad = [self.delegate javascriptNativeBridge:self shouldLoadExternalRequest:navigationAction.request];
        }
        if (shouldStartLoad) {
            decisionHandler(WKNavigationActionPolicyAllow);
        } else {
            decisionHandler(WKNavigationActionPolicyCancel);
        }
    }

    NSString *requestURLString = navigationAction.request.URL.absoluteString;

    if ([requestURLString rangeOfString:kJMJavascriptNativeBridgeCallbackURL].length) {
        NSString *callback = [NSString stringWithFormat:@"http://%@/", kJMJavascriptNativeBridgeCallbackURL];
        NSRange callbackRange = [requestURLString rangeOfString:callback];
        NSRange commandRange = NSMakeRange(callbackRange.length, requestURLString.length - callbackRange.length);
        NSString *command = [requestURLString substringWithRange:commandRange];

        NSDictionary *parameters = [self parseCommand:command];

        JMJavascriptCallback *response = [JMJavascriptCallback new];
        response.type = parameters[@"callback.type"];
        response.parameters = parameters[@"parameters"];
        [self didReceiveCallback:response];
        decisionHandler(WKNavigationActionPolicyCancel);
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    if (self.jsInitCode && !self.isJSInitCodeInjected) {
        self.isJSInitCodeInjected = YES;
        [self.webView evaluateJavaScript:self.jsInitCode completionHandler:^(id result, NSError *error) {
            JMLog(@"error: %@", error);
            JMLog(@"result: %@", result);
        }];
    }

    // add window.onerror listener
    NSString *listenerId = @"JasperMobile.Events.Window.OnError";
   __weak __typeof(self) weakSelf = self;
    [self addListenerWithId:listenerId
                   callback:^(JMJavascriptCallback *callback, NSError *error) {
                       __typeof(self) strongSelf = weakSelf;
                       if ([strongSelf.delegate respondsToSelector:@selector(javascriptNativeBridge:didReceiveOnWindowError:)]) {
                           [strongSelf.delegate javascriptNativeBridge:strongSelf
                                               didReceiveOnWindowError:error];
                       }
                   }];
}

#pragma mark - Helpers
- (NSDictionary *)parseCommand:(NSString *)command
{
    NSString *decodedCommand = [command stringByRemovingPercentEncoding];
    NSArray *components = [decodedCommand componentsSeparatedByString:@"&&"];
    NSMutableDictionary *result = [NSMutableDictionary dictionary];

    NSString *callbackType = [components firstObject];

    if ([callbackType isEqualToString:@"json"]) {
        NSString *parameters = components[1];
//        JMLog(@"origin parameters: %@", parameters);
        parameters = [parameters stringByReplacingOccurrencesOfString:@"/\"" withString:@"\""];
        parameters = [parameters stringByReplacingOccurrencesOfString:@"\"{" withString:@"{"];
        parameters = [parameters stringByReplacingOccurrencesOfString:@"}\"" withString:@"}"];
//        JMLog(@"sanitized parameters: %@", parameters);
        NSData *parametersAsData = [parameters dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:parametersAsData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&error];
        if (json) {
            result[@"callback.type"] = json[@"command"];
            result[@"parameters"] = json[@"parameters"];
        } else {
            result[@"callback.type"] = @"Error";
            result[@"description"] = error.localizedDescription;
        }
    } else {
        result[@"callback.type"] = callbackType;

        NSMutableArray *parameters = [NSMutableArray arrayWithArray:components];
//        JMLog(@"origin parameters: %@", parameters);
        [parameters removeObjectAtIndex:0];
        for (NSString *component in parameters) {
            NSArray *keyValue = [component componentsSeparatedByString:@"="];
            if (keyValue.count == 2) {
                result[keyValue[0]] = keyValue[1];
            }
        }
    }
    return result;
}

- (BOOL)isLoginRequest:(NSURLRequest *)request
{
    BOOL isLoginRequest = NO;
    // Check request to login and handle it
    NSString *loginUrlRegex = [NSString stringWithFormat:@"%@/login.html(.+)?", self.restClient.serverProfile.serverUrl];
    NSPredicate *loginUrlValidator = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", loginUrlRegex];
    NSString *requestUrl = request.URL.absoluteString;
    if ([loginUrlValidator evaluateWithObject:requestUrl]) {
        isLoginRequest = YES;
    }
    return isLoginRequest;
}

- (BOOL)isRequestToRunReport:(NSURLRequest *)request
{
    BOOL isRequestToRunReport = NO;

    NSString *requestURLString = request.URL.absoluteString;
    //  don't let run link run report
    if ([requestURLString rangeOfString:@"_flowId=viewReportFlow&reportUnit"].length || [requestURLString rangeOfString:@"_flowId=viewReportFlow&_report"].length) {
        [[UIApplication sharedApplication] openURL:request.URL];
        isRequestToRunReport = YES;
    }
    return isRequestToRunReport;
}

- (BOOL)isExternalRequest:(NSURLRequest *)request
{
    BOOL isExternalRequest = NO;

    NSString *requestURLString = request.URL.absoluteString;
    NSString *requestHostURLString = request.URL.host;
    NSURL *serverURL = [NSURL URLWithString:self.restClient.serverProfile.serverUrl];
    NSString *serverHostURLString = serverURL.host;
    NSString *callbackHostURLString = kJMJavascriptNativeBridgeCallbackURL;

    BOOL isServerURL = [requestHostURLString isEqualToString:serverHostURLString];
    BOOL isCallbackURL = [requestHostURLString isEqualToString:callbackHostURLString];

    if (requestURLString.length > 0 && !(isServerURL || isCallbackURL)) {
        isExternalRequest = YES;
    }

    return isExternalRequest;
}

#pragma mark - Callbacks
- (void)didReceiveCallback:(JMJavascriptCallback *)callback
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    if([callback.type isEqualToString:@"logging"]) {
        JMLog(@"Bridge Message: %@", callback.parameters[@"message"]);
    } else {
        JMLog(@"%@", callback);
        BOOL isRequestCompletionFound = NO;
        for (JMJavascriptRequest *request in self.requestCompletions) {
            JMLog(@"request.command: %@", request.command);
            JMLog(@"callback.type: %@", callback.type);
            if ([request.command isEqualToString:callback.type]) {
                JMJavascriptRequestCompletion completion = self.requestCompletions[request];
                if (callback.parameters[@"error"]) {
                    NSDictionary *errorJSON = callback.parameters[@"error"];
                    NSError *error = [self makeErrorFromWebViewError:errorJSON];
                    completion(nil, error);
                } else {
                    completion(callback, nil);
                }
                [self.requestCompletions removeObjectForKey:request];
                isRequestCompletionFound = YES;
                break;
            }
        }

        if (!isRequestCompletionFound) {
            for (JMJavascriptRequest *request in self.listenerCallbacks) {
                if ([request.command isEqualToString:callback.type]) {
                    JMJavascriptRequestCompletion completion = self.listenerCallbacks[request];
                    if (callback.parameters[@"error"]) {
                        NSDictionary *errorJSON = callback.parameters[@"error"];
                        NSError *error = [self makeErrorFromWebViewError:errorJSON];
                        completion(nil, error);
                    } else {
                        completion(callback, nil);
                    }
                    break;
                }
            }
        }
    }
}

- (NSError *)makeErrorFromWebViewError:(NSDictionary *)errorJSON
{
    NSString *visualizeErrorDomain = @"Visualize Error Domain";
    NSString *errorCodeString = errorJSON[@"code"];
    NSInteger code = JMJavascriptNativeBridgeErrorTypeOther;
    if ([errorCodeString isEqualToString:@"window.onerror"]) {
        code = JMJavascriptNativeBridgeErrorTypeWindow;
    } else if ([errorCodeString isEqualToString:@"authentication.error"]) {
        code = JMJavascriptNativeBridgeErrorAuthError;
    }
    NSString *errorMessage = errorJSON[@"message"];
    NSError *error = [NSError errorWithDomain:visualizeErrorDomain
                                         code:code
                                     userInfo:@{
                                             NSLocalizedDescriptionKey: errorMessage
                                     }];
    return error;
}


#pragma mark - Work with Cookies
- (void)injectCookies
{
//    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    NSString *cookiesAsString = [self cookiesAsStringFromCookies:self.restClient.cookies];
//    JMLog(@"cookiesAsString: %@", cookiesAsString);
    [self.webView evaluateJavaScript:cookiesAsString completionHandler:^(id o, NSError *error) {
        if (error) {
            JMLog(@"error: %@", error);
        } else {
            JMLog(@"injected cookies: %@", self.restClient.cookies);
        }
    }];
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

@end