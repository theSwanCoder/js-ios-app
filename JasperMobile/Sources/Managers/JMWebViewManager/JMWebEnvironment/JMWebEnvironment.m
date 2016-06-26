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

NSString * __nonnull const JMWebEnvironmentDidResetNotification = @"JMWebEnvironmentDidResetNotification";

@interface JMWebEnvironment() <JMJavascriptNativeBridgeDelegate>
@property (nonatomic, strong) JMJavascriptNativeBridge * __nonnull bridge;
@property (nonatomic, strong) NSMutableArray <JMWebEnvironmentPendingBlock>*pendingBlocks;
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
        _pendingBlocks = [NSMutableArray array];
        _webView = [self createWebViewWithCookies:cookies];
        _identifier = identifier;
        _bridge = [JMJavascriptNativeBridge bridgeWithWebView:_webView];
        _bridge.delegate = self;
        __weak __typeof(self) weakSelf = self;
        [self addListenerWithId:@"DOMContentLoaded"
                       callback:^(NSDictionary *params, NSError *error) {
                           __typeof(self) strongSelf = weakSelf;
                           strongSelf.ready = YES;
                       }];
    }
    return self;
}

+ (instancetype)webEnvironmentWithId:(NSString *)identifier initialCookies:(NSArray *__nullable)cookies
{
    return [[self alloc] initWithId:identifier initialCookies:cookies];
}

#pragma mark - Custom Accessors
- (void)setReady:(BOOL)ready
{
    _ready = ready;
    if (_ready) {
        for (JMWebEnvironmentPendingBlock pendingBlock in self.pendingBlocks) {
            pendingBlock();
        }
        self.pendingBlocks = [NSMutableArray array];
    }
}

#pragma mark - Public API
- (void)addPendingBlock:(JMWebEnvironmentPendingBlock)pendingBlock
{
    NSAssert(pendingBlock != nil, @"Pending block is nil");
    [self.pendingBlocks addObject:pendingBlock];
}

- (void)updateCookiesWithCookies:(NSArray *)cookies
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    self.ready = NO;
    __weak __typeof(self) weakSelf = self;
    [self removeCookiesWithCompletion:^(BOOL success) {
        __typeof(self) strongSelf = weakSelf;
        if (success) {
            NSString *cookiesAsString = [strongSelf cookiesAsStringFromCookies:cookies];
            __weak __typeof(self) weakSelf = strongSelf;
            [strongSelf.webView evaluateJavaScript:cookiesAsString completionHandler:^(id o, NSError *error) {
                __typeof(self) strongSelf = weakSelf;
                JMLog(@"setting cookies");
                JMLog(@"error: %@", error);
                JMLog(@"o: %@", o);
                if (error) {
                    // TODO: how handle this case?
                } else {
                    strongSelf.ready = YES;
                }
            }];
        } else {
            // TODO: how handle this case?
        }
    }];
}

- (void)loadHTML:(NSString * __nonnull)HTMLString
         baseURL:(NSURL * __nullable)baseURL
{
    NSAssert(HTMLString != nil, @"HTML should not be nil");

    [self.bridge startLoadHTMLString:HTMLString
                             baseURL:baseURL];
}

- (void)removeCookiesWithCompletion:(void(^)(BOOL success))completion
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    if ([JMUtils isSystemVersion9]) {
        NSSet *dataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
        WKWebsiteDataStore *websiteDataStore = self.webView.configuration.websiteDataStore;
        [websiteDataStore fetchDataRecordsOfTypes:dataTypes
                                completionHandler:^(NSArray<WKWebsiteDataRecord *> *records) {
                                    for (WKWebsiteDataRecord *record in records) {
                                        NSURL *serverURL = [NSURL URLWithString:self.restClient.serverProfile.serverUrl];
                                        if ([record.displayName containsString:serverURL.host]) {
                                            [websiteDataStore removeDataOfTypes:record.dataTypes
                                                                 forDataRecords:@[record]
                                                              completionHandler:^{
                                                                  JMLog(@"record (%@) removed successfully", record);
                                                              }];
                                        }
                                    }
                                    if (completion) {
                                        completion(YES);
                                    }
                                }];
    } else {
        [self removeCookiesForOldVersionWitchCompletion:completion];
    }
}

- (void)removeCookiesForOldVersionWitchCompletion:(void(^)(BOOL success))completion
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    NSString *libraryPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject;
    NSString *cookiesFolderPath = [libraryPath stringByAppendingString:@"/Cookies"];
    NSError *errors;
    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:cookiesFolderPath error:&errors];
    if (!success) {
        JMLog(@"error of removing cookies: %@", errors);
    }
    completion(success);
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

- (void)sendJavascriptRequest:(JMJavascriptRequest *__nonnull)request
                   completion:(JMWebEnvironmentRequestParametersCompletion __nullable)completion
{
    __weak __typeof(self) weakSelf = self;
    JMWebEnvironmentPendingBlock pendingBlock = ^{
        JMLog(@"request was sent");
        __typeof(self) strongSelf = weakSelf;
        if (completion) {
            JMWebEnvironmentRequestParametersCompletion heapBlock;
            heapBlock = [completion copy];
            [strongSelf.bridge sendJavascriptRequest:request
                                          completion:^(JMJavascriptResponse *response, NSError *error) {
                                              heapBlock(response.parameters, error);
                                          }];
        } else {
            [strongSelf.bridge sendJavascriptRequest:request
                                          completion:nil];
        }
    };

    if (self.ready) {
        JMLog(@"sending request");
        pendingBlock();
    } else {
        JMLog(@"pending request");
        [self addPendingBlock:pendingBlock];
    }
}

- (void)addListenerWithId:(NSString *)listenerId
                 callback:(JMWebEnvironmentRequestParametersCompletion)callback
{
    [self.bridge addListenerWithId:listenerId
                          callback:^(JMJavascriptResponse *jsCallback, NSError *error) {
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
    NSURLRequest *clearingRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]];
    [self.webView loadRequest:clearingRequest];
    self.ready = NO;
    self.pendingBlocks = [NSMutableArray array];
}

- (void)reset
{
    [self.bridge removeAllListeners];
    [self.webView removeFromSuperview];
    self.webView = nil;
    self.pendingBlocks = [NSMutableArray array];

    JMLog(@"JMWebEnvironmentDidResetNotification: %@", JMWebEnvironmentDidResetNotification);

    [[NSNotificationCenter defaultCenter] postNotificationName:JMWebEnvironmentDidResetNotification
                                                        object:self];
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

- (void)verifyJasperMobileEnableWithCompletion:(void(^ __nonnull)(BOOL isEnable))completion
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    NSAssert(completion != nil, @"Completion is nil");
    NSString *jsCommand = @"typeof(JasperMobile);";
    [self.webView evaluateJavaScript:jsCommand completionHandler:^(id result, NSError *error) {
        BOOL isObject = [result isEqualToString:@"object"];
        BOOL isEnable = !error && isObject;
        completion(isEnable);
    }];
}

#pragma mark - JMJavascriptNativeBridgeDelegate
- (void)javascriptNativeBridge:(JMJavascriptNativeBridge *__nonnull)bridge didReceiveError:(NSError *__nonnull)error
{
    JMLog(@"error from bridge: %@", error);
#ifndef __RELEASE__
    // TODO: move to loader layer
//    [JMUtils presentAlertControllerWithError:error
//                                  completion:nil];
#endif
}

- (BOOL)javascriptNativeBridge:(JMJavascriptNativeBridge *__nonnull)bridge shouldLoadExternalRequest:(NSURLRequest *__nonnull)request
{
    // TODO: investigate cases.
    return YES;
}

@end