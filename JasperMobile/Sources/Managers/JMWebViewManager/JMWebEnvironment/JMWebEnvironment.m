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
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
}

- (instancetype)initWithId:(NSString *)identifier initialCookies:(NSArray *__nullable)cookies
{
    self = [super init];
    if (self) {
        _webView = [self createWebViewWithCookies:cookies];
        _identifier = identifier;
        _bridge = [JMJavascriptNativeBridge bridgeWithWebView:_webView];
        _bridge.delegate = self;
    }
    return self;
}

+ (instancetype)webEnvironmentWithId:(NSString *)identifier initialCookies:(NSArray *__nullable)cookies
{
    return [[self alloc] initWithId:identifier initialCookies:cookies];
}

#pragma mark - Public API
- (void)loadHTML:(NSString * __nonnull)HTMLString
         baseURL:(NSURL * __nullable)baseURL
      completion:(JMWebEnvironmentRequestBooleanCompletion __nullable)completion
{
    NSAssert(HTMLString != nil, @"HTML should not be nil");
    JMJavascriptRequestCompletion javascriptRequestCompletion;

    if (!self.isCancel) {
        if (completion) {
            javascriptRequestCompletion = ^(JMJavascriptResponse *callback, NSError *error) {
                if (!self.isCancel) {
                    if (error) {
                        completion(NO, error);
                    } else {
                        completion(YES, nil);
                    }
                }
            };
        }

        [self.bridge startLoadHTMLString:HTMLString
                                 baseURL:baseURL
                              completion:javascriptRequestCompletion];
    }
}

- (void)removeCookiesWithCompletion:(void(^)(BOOL success))completion
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    NSAssert([JMUtils isSystemVersion9], @"Should be called only for iOS9");

    NSSet *dataTypes = [NSSet setWithArray:@[WKWebsiteDataTypeCookies]];
    WKWebsiteDataStore *websiteDataStore = self.webView.configuration.websiteDataStore;
    [websiteDataStore fetchDataRecordsOfTypes:dataTypes
                            completionHandler:^(NSArray<WKWebsiteDataRecord *> *array) {
                                [websiteDataStore removeDataOfTypes:dataTypes
                                                     forDataRecords:array
                                                  completionHandler:^{
                                                      JMLog(@"cookies removed successfully");
                                                      if (completion) {
                                                          completion(YES);
                                                      }
                                                  }];
                            }];
}

- (void)updateCookiesWithCookies:(NSArray *)cookies completion:(void(^)(BOOL success))completion
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    [self removeCookiesWithCompletion:^(BOOL success) {
        if (success) {
            NSString *cookiesAsString = [self cookiesAsStringFromCookies:cookies];
            [self.webView evaluateJavaScript:cookiesAsString completionHandler:^(id o, NSError *error) {
                JMLog(@"setting cookies");
                JMLog(@"error: %@", error);
                JMLog(@"o: %@", o);
                if (error) {
                    // TODO: how handle this case?
                    completion(NO);
                } else {
                    completion(YES);
                }
            }];
        } else {
            completion(NO);
        }
    }];
}

- (void)loadRequest:(NSURLRequest * __nonnull)request
{
    if (self.isCancel) {
        return;
    }

    if ([request.URL isFileURL]) {
        // TODO: detect format of file for request
        [self loadLocalFileFromURL:request.URL
                        fileFormat:nil
                           baseURL:nil];
    } else {
        if (self.isCancel) {
            return;
        }
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
    [self verifyJasperMobileEnableWithCompletion:^(BOOL isJasperMobileLoaded) {
        if (isJasperMobileLoaded) {
            [self isWebViewLoadedContentDiv:self.webView completion:^(BOOL isContantDivLoaded) {
                completion(isContantDivLoaded);
            }];
        } else {
            // TODO: need load html
            completion(NO);
        }
    }];
}

- (void)sendJavascriptRequest:(JMJavascriptRequest *__nonnull)request
                   completion:(JMWebEnvironmentRequestParametersCompletion __nullable)completion
{
    JMWebEnvironmentRequestParametersCompletion heapBlock;
    if (completion) {
        heapBlock = [completion copy];
    }
    if (!self.isCancel) {
        if (heapBlock) {
            [self.bridge sendJavascriptRequest:request
                                    completion:^(JMJavascriptResponse *response, NSError *error) {
                                        if (!self.isCancel) {
                                            heapBlock(response.parameters, error);
                                        }
                                    }];
        } else {
            [self.bridge sendJavascriptRequest:request
                                    completion:nil];
        }
    }
}

- (void)addListenerWithId:(NSString *)listenerId
                 callback:(JMWebEnvironmentRequestParametersCompletion)callback
{
    if (!self.isCancel) {
        __weak __typeof(self) weakSelf = self;
        [self.bridge addListenerWithId:listenerId
                              callback:^(JMJavascriptResponse *jsCallback, NSError *error) {
                                  __typeof(self) strongSelf = weakSelf;
                                  if (!strongSelf.isCancel) {
                                      callback(jsCallback.parameters, error);
                                  }
                              }];
    }
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
    NSURLRequest *clearingRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]];
    [self.webView loadRequest:clearingRequest];
}

- (void)reset
{
    [self.bridge removeAllListeners];
    [self.webView removeFromSuperview];
    self.webView = nil;
}

#pragma mark - Helpers
- (WKWebView *)createWebViewWithCookies:(NSArray <NSHTTPCookie *>*)cookies
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    JMLog(@"cookies: %@", cookies);
    WKWebViewConfiguration* webViewConfig = [WKWebViewConfiguration new];
    WKUserContentController *contentController = [WKUserContentController new];

    [contentController addUserScript:[self injectCookiesScriptWithCookies:cookies]];
    [contentController addUserScript:[self jaspermobileScript]];

    webViewConfig.userContentController = contentController;

    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:webViewConfig];

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

- (WKUserScript *)injectCookiesScriptWithCookies:(NSArray <NSHTTPCookie *>*)cookies
{
    NSString *cookiesAsString = [self cookiesAsStringFromCookies:cookies];

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

- (void)verifyDOMReadyWithCompletion:(void(^)(BOOL isReady))completion
{
    [self verifyJasperMobileEnableWithCompletion:^(BOOL isJasperMobileEnable) {
        if (isJasperMobileEnable) {
            NSString *jsCommand = @"JasperMobile.isDOMReady;";
            [self.webView evaluateJavaScript:jsCommand completionHandler:^(id result, NSError *error) {
                NSAssert([result isKindOfClass:[NSNumber class]], @"Wrong class of result");
                BOOL isDOMReady = ((NSNumber *)result).boolValue;
                BOOL isLoaded = !error && isDOMReady;
                if (!self.isCancel) {
                    completion(isLoaded);
                }
            }];
        } else {
            // TODO: need load html
            completion(NO);
        }
    }];
}

- (void)verifyJasperMobileEnableWithCompletion:(void(^ __nonnull)(BOOL isEnable))completion
{
    NSString *jsCommand = @"typeof(JasperMobile);";
    [self.webView evaluateJavaScript:jsCommand completionHandler:^(id result, NSError *error) {
        BOOL isObject = [result isEqualToString:@"object"];
        BOOL isEnable = !error && isObject;
        if (!self.isCancel) {
            completion(isEnable);
        }
    }];
}

- (void)isWebViewLoadedContentDiv:(WKWebView *)webView completion:(void(^ __nonnull)(BOOL isContantDivLoaded))completion
{
    JMJavascriptRequest *request = [JMJavascriptRequest requestWithCommand:@"JasperMobile.Helper.isContainerLoaded"
                                                                parameters:nil];
    [self.bridge sendJavascriptRequest:request
                            completion:^(JMJavascriptResponse *callback, NSError *error) {
                                if (error) {
                                    completion(NO);
                                } else {
                                    NSString *isContainerLoaded = callback.parameters[@"isContainerLoaded"];
                                    completion([isContainerLoaded isEqualToString:@"true"]);
                                }
                            }];
}

#pragma mark - JMJavascriptNativeBridgeDelegate
- (void)javascriptNativeBridge:(JMJavascriptNativeBridge *__nonnull)bridge didReceiveOnWindowError:(NSError *__nonnull)error
{
#ifndef __RELEASE__
    // TODO: move to loader layer
    [JMUtils presentAlertControllerWithError:error
                                  completion:nil];
#endif
}

- (BOOL)javascriptNativeBridge:(JMJavascriptNativeBridge *__nonnull)bridge shouldLoadExternalRequest:(NSURLRequest *__nonnull)request
{
    // TODO: investigate cases.
    return YES;
}

@end