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
//  JMBaseWebEnvironment.h
//  TIBCO JasperMobile
//

#import "JMBaseWebEnvironment.h"
#import "JMJavascriptRequestExecutor.h"
#import "JMJavascriptEvent.h"
#import "UIView+Additions.h"

@interface JMBaseWebEnvironment() <JMJavascriptRequestExecutorDelegate>
@property (nonatomic, assign, readwrite) JMWebEnvironmentState state;
@property (nonatomic, strong, readwrite) WKWebView * __nullable webView;
@property (nonatomic, copy, readwrite) NSString * __nonnull identifier;
@property (nonatomic, strong) JMJavascriptRequestExecutor * __nonnull requestExecutor;
@property (nonatomic, strong) NSMutableArray <JMWebEnvironmentPendingBlock>*pendingBlocks;
@end

@implementation JMBaseWebEnvironment

#pragma mark - Lify Cycle
- (void)dealloc
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
}

- (instancetype __nullable)initWithId:(NSString *__nonnull)identifier initialCookies:(NSArray *__nullable)cookies
{
    self = [super init];
    if (self) {
        _identifier = identifier;
        _pendingBlocks = [NSMutableArray new];
        [self setupWebEnvironmentWithCookies:cookies];
    }
    return self;
}

+ (instancetype __nullable)webEnvironmentWithId:(NSString *__nullable)identifier initialCookies:(NSArray *__nullable)cookies
{
    return [[self alloc] initWithId:identifier initialCookies:cookies];
}

#pragma mark - Custom Accessors

- (void)setState:(JMWebEnvironmentState)state
{
    _state = state;
    switch(_state) {
        case JMWebEnvironmentStateInitial: {
            JMLog(@"JMWebEnvironmentStateInitial");
            break;
        }
        case JMWebEnvironmentStateWebViewConfiguted: {
            JMLog(@"JMWebEnvironmentStateWebViewConfiguted");
            break;
        }
        case JMWebEnvironmentStateEnvironmentReady: {
            JMLog(@"JMWebEnvironmentStateEnvironmentReady");
            [self executePendingBlocks];
            break;
        }
        case JMWebEnvironmentStateLoading: {
            JMLog(@"JMWebEnvironmentStateLoading");
            break;
        }
        case JMWebEnvironmentStateRequestExecution: {
            JMLog(@"JMWebEnvironmentStateRequestExecution");
            break;
        }
        case JMWebEnvironmentStateReady: {
            JMLog(@"JMWebEnvironmentStateReady");
            [self executePendingBlocks];
            break;
        }
        case JMWebEnvironmentStateSessionExpired: {
            JMLog(@"JMWebEnvironmentStateSessionExpired");
            break;
        }
        case JMWebEnvironmentStateCancel: {
            JMLog(@"JMWebEnvironmentStateCancel");
            break;
        }
    }
}

#pragma mark - JMWebEnvironmentLoadingProtocol

- (void)loadHTML:(NSString * __nonnull)HTMLString
         baseURL:(NSURL * __nullable)baseURL
{
    NSAssert(HTMLString != nil, @"HTML should not be nil");
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    self.state = JMWebEnvironmentStateLoading;
    __weak __typeof(self) weakSelf = self;
    JMJavascriptEvent *event = [JMJavascriptEvent eventWithIdentifier:@"DOMContentLoaded"
                                                             listener:self
                                                             callback:^(JMJavascriptResponse *response, NSError *error) {
                                                                 __typeof(self) strongSelf = weakSelf;
                                                                 JMLog(@"Event was received: DOMContentLoaded");
                                                                 strongSelf.state = JMWebEnvironmentStateEnvironmentReady;
                                                             }];
    [self.requestExecutor addListenerWithEvent:event];
    [self.requestExecutor startLoadHTMLString:HTMLString
                                      baseURL:baseURL];
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

#pragma mark - JMJavascriptRequestExecutionProtocol

- (void)sendJavascriptRequest:(JMJavascriptRequest *__nonnull)request
                   completion:(JMWebEnvironmentRequestParametersCompletion __nullable)completion
{
    __weak __typeof(self) weakSelf = self;
    JMWebEnvironmentPendingBlock pendingBlock = ^{
        JMLog(@"request was sent");
        __typeof(self) strongSelf = weakSelf;
        strongSelf.state = JMWebEnvironmentStateRequestExecution;
        [strongSelf.requestExecutor sendJavascriptRequest:request
                                               completion:^(JMJavascriptResponse *response, NSError *error) {
                                                   strongSelf.state = JMWebEnvironmentStateReady;
                                                   if (completion) {
                                                       completion(response.parameters, error);
                                                   }
                                               }];
    };

    [self addPendingBlock:pendingBlock];
}

- (void)addListener:(id)listener
         forEventId:(NSString *)eventId
           callback:(JMWebEnvironmentRequestParametersCompletion)callback
{
    JMJavascriptEvent *event = [JMJavascriptEvent eventWithIdentifier:eventId listener:listener
                                                             callback:^(JMJavascriptResponse *response, NSError *error) {
                                                                 callback(response.parameters, error);
                                                             }];
    [self.requestExecutor addListenerWithEvent:event];
}

- (void)removeListener:(id)listener
{
    [self.requestExecutor removeListener:listener];
}

#pragma mark - Public API

- (void)cleanCache
{
    // implement in childs
}

- (void)addPendingBlock:(JMWebEnvironmentPendingBlock)pendingBlock
{
    NSAssert(pendingBlock != nil, @"Pending block is nil");
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));

    switch(self.state) {
        case JMWebEnvironmentStateInitial: {
            JMLog(@"JMWebEnvironmentStateInitial");
            [self savePendingBlock:pendingBlock];
            break;
        }
        case JMWebEnvironmentStateWebViewConfiguted: {
            JMLog(@"JMWebEnvironmentStateWebViewConfiguted");
            [self savePendingBlock:pendingBlock];
            break;
        }
        case JMWebEnvironmentStateEnvironmentReady: {
            JMLog(@"JMWebEnvironmentStateEnvironmentReady");
            pendingBlock();
            break;
        }
        case JMWebEnvironmentStateLoading: {
            JMLog(@"JMWebEnvironmentStateLoading");
            [self savePendingBlock:pendingBlock];
            break;
        }
        case JMWebEnvironmentStateRequestExecution: {
            JMLog(@"JMWebEnvironmentStateRequestExecution");
            [self savePendingBlock:pendingBlock];
            break;
        }
        case JMWebEnvironmentStateReady: {
            JMLog(@"JMWebEnvironmentStateReady");
            pendingBlock();
            break;
        }
        case JMWebEnvironmentStateSessionExpired: {
            JMLog(@"JMWebEnvironmentStateSessionExpired");
            [self savePendingBlock:pendingBlock];
            break;
        }
        case JMWebEnvironmentStateCancel: {
            JMLog(@"JMWebEnvironmentStateCancel");
            [self savePendingBlock:pendingBlock];
            break;
        }
    }
}

- (void)savePendingBlock:(JMWebEnvironmentPendingBlock)pendingBlock
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    [self.pendingBlocks addObject:pendingBlock];
}

- (void)resetZoom
{
    [self.webView.scrollView setZoomScale:0.1 animated:YES];
}

- (void)clean
{
    NSURLRequest *clearingRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]];
    [self.webView loadRequest:clearingRequest];
    self.state = JMWebEnvironmentStateWebViewConfiguted;
    self.pendingBlocks = [NSMutableArray array];
}

- (void)reset
{
    [self resetZoom];
    [self.webView removeFromSuperview];
    // TODO: need reset requestExecutor because will be leak
    if (!self.reusable) {
        [self.requestExecutor reset];
    }
    self.pendingBlocks = [NSMutableArray array];
}

#pragma mark - WebView Helpers

- (void)setupWebEnvironmentWithCookies:(NSArray <NSHTTPCookie *> *__nonnull)cookies
{
    NSAssert(cookies != nil, @"Cookies are nil");
    _webView = [self createWebViewWithCookies:cookies];
    _requestExecutor = [JMJavascriptRequestExecutor executorWithWebView:_webView];
    _requestExecutor.delegate = self;
}

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

#pragma mark - Cookies Helpers

- (void)updateCookiesWithCookies:(NSArray *)cookies
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    self.state = JMWebEnvironmentStateSessionExpired;
    [self cleanCache];
    __weak __typeof(self) weakSelf = self;
    if ([JMUtils isSystemVersion9]) {
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
                        strongSelf.state = JMWebEnvironmentStateReady;
                    }
                }];
            } else {
                // TODO: how handle this case?
            }
        }];
    } else {
        UIView *webViewSuperview = self.webView.superview;
        [self.webView removeFromSuperview];
        [self.requestExecutor reset];
        _webView = nil;
        _requestExecutor = nil;
        [self setupWebEnvironmentWithCookies:cookies];
        [webViewSuperview fillWithView:self.webView];
    }
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
    NSError *error;
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cookiesFolderPath error:&error];
    for (NSString *contentPath in contents) {
        error = nil;
        NSString *fullContentPath = [cookiesFolderPath stringByAppendingFormat:@"/%@", contentPath];
        BOOL success = [[NSFileManager defaultManager] removeItemAtPath:fullContentPath error:&error];
        if (!success) {
            JMLog(@"error of removing cookies: %@", error);
        }
    }
    completion(YES);
}

#pragma mark - Helpers

- (void)executePendingBlocks
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    for (JMWebEnvironmentPendingBlock pendingBlock in self.pendingBlocks) {
        pendingBlock();
    }
    self.pendingBlocks = [NSMutableArray array];
}

#pragma mark - JMJavascriptRequestExecutorDelegate

- (void)javascriptRequestExecutor:(JMJavascriptRequestExecutor *__nonnull)executor didReceiveError:(NSError *__nonnull)error
{
    JMLog(@"error from requestExecutor: %@", error);
#ifndef __RELEASE__
    // TODO: move to loader layer
//    [JMUtils presentAlertControllerWithError:error
//                                  completion:nil];
#endif
}

- (BOOL)javascriptRequestExecutor:(JMJavascriptRequestExecutor *__nonnull)executor shouldLoadExternalRequest:(NSURLRequest *__nonnull)request
{
    // TODO: investigate cases.
    return YES;
}

@end