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
#import "JMJavascriptRequest.h"
#import "JMJavascriptCallback.h"


@interface JMJavascriptNativeBridge() <WKNavigationDelegate>
@property (nonatomic, copy) NSString *jsInitCode;
@property (nonatomic, assign) BOOL isJSInitCodeInjected;
@end

@implementation JMJavascriptNativeBridge
@synthesize webView = _webView, delegate = _delegate;

#pragma mark - Custom Accessors
- (void)setWebView:(WKWebView *)webView
{
    _webView = webView;
    _webView.navigationDelegate = self;
}

#pragma mark - Public API
- (void)startLoadHTMLString:(NSString *)HTMLString baseURL:(NSURL *)baseURL
{
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

- (void)sendRequest:(JMJavascriptRequest *)request
{
    NSString *javascriptString = request.command;
    NSString *parameters = request.parametersAsString ?: @"";
    NSString *fullJavascriptString = [NSString stringWithFormat:javascriptString, parameters];
//    NSLog(@"send request: %@", fullJavascriptString);
    [self.webView evaluateJavaScript:fullJavascriptString completionHandler:^(id result, NSError *error) {
        JMLog(@"error: %@", error);
        JMLog(@"result: %@", request);
    }];
}

- (void)sendRequest:(JMJavascriptRequest *)request completion:(void(^)(JMJavascriptCallback *callback, NSError *error))completion
{
    if (!completion) {
        return;
    }
    NSString *javascriptString = request.command;
    NSString *parameters = request.parametersAsString ?: @"";
    NSString *fullJavascriptString = [NSString stringWithFormat:javascriptString, parameters];
//    JMLog(@"send request: %@", fullJavascriptString);
    [self.webView evaluateJavaScript:fullJavascriptString completionHandler:^(id result, NSError *error) {
        JMLog(@"error: %@", error);
        JMLog(@"result: %@", request);

        NSData *parametersAsData = [result dataUsingEncoding:NSUTF8StringEncoding];
        NSError *parseError;
        id json = [NSJSONSerialization JSONObjectWithData:parametersAsData
                                                  options:NSJSONReadingMutableContainers
                                                    error:&parseError];
        if (json) {
            JMJavascriptCallback *response = [JMJavascriptCallback new];
            response.type = @"callback";
            if ([json isKindOfClass:[NSDictionary class]]) {
                response.parameters = json;
            } else if ([json isKindOfClass:[NSArray class]]) {
                response.parameters = @{@"parameters" : json };
            }
            completion(response, nil);
        } else {
            completion(nil, parseError);
        }
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
}

#pragma mark - UIWebViewDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
//    NSLog(@"request from webView: %@", navigationAction.request);
//    NSLog(@"request from webView, allHTTPHeaderFields: %@", navigationAction.request.allHTTPHeaderFields);

    if ([self isLoginRequest:navigationAction.request]) {
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

    NSString *callback = @"http://jaspermobile.callback/";
    NSString *requestURLString = navigationAction.request.URL.absoluteString;

    if ([requestURLString rangeOfString:callback].length) {

        NSRange callbackRange = [requestURLString rangeOfString:callback];
        NSRange commandRange = NSMakeRange(callbackRange.length, requestURLString.length - callbackRange.length);
        NSString *command = [requestURLString substringWithRange:commandRange];

        NSDictionary *parameters = [self parseCommand:command];

        JMJavascriptCallback *response = [JMJavascriptCallback new];
        response.type = parameters[@"callback.type"];
        response.parameters = parameters;
        [self.delegate javascriptNativeBridge:self didReceiveCallback:response];

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
}

#pragma mark - Helpers
- (NSDictionary *)parseCommand:(NSString *)command
{
    NSString *decodedCommand = [command stringByRemovingPercentEncoding];
    NSArray *components = [decodedCommand componentsSeparatedByString:@"&"];
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
    NSString *callbackHostURLString = @"jaspermobile.callback";

    BOOL isServerURL = [requestHostURLString isEqualToString:serverHostURLString];
    BOOL isCallbackURL = [requestHostURLString isEqualToString:callbackHostURLString];

    if (requestURLString.length > 0 && !(isServerURL || isCallbackURL)) {
        isExternalRequest = YES;
    }

    return isExternalRequest;
}

@end