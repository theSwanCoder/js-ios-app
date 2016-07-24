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
#import "JMAsyncTask.h"
#import "JMJavascriptRequestTask.h"
#import "JMWebEnvironmentLoadingTask.h"
#import "JMWebEnvironmentUpdateCookiesTask.h"
#import "JMWebViewFabric.h"

@interface JMBaseWebEnvironment() <JMJavascriptRequestExecutorDelegate>
@property (nonatomic, strong, readwrite) WKWebView * __nullable webView;
@property (nonatomic, copy, readwrite) NSString * __nonnull identifier;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
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
        _operationQueue = [NSOperationQueue new];
        _operationQueue.name = @"WebEnvironment Queue";
        _operationQueue.maxConcurrentOperationCount = 1;
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
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    switch(_state) {
        case JMWebEnvironmentStateInitial: {
            JMLog(@"JMWebEnvironmentStateInitial");
            break;
        }
        case JMWebEnvironmentStateWebViewCreated: {
            JMLog(@"JMWebEnvironmentStateWebViewCreated");
            break;
        }
        case JMWebEnvironmentStateWebViewConfigured: {
            JMLog(@"JMWebEnvironmentStateWebViewConfigured");
            break;
        }
        case JMWebEnvironmentStateEnvironmentReady: {
            JMLog(@"JMWebEnvironmentStateEnvironmentReady");
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
      completion:(JMWebEnvironmentLoadingCompletion)completion
{
    NSAssert(HTMLString != nil, @"HTML should not be nil");
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    JMWebEnvironmentLoadingTask *loadingTask = [JMWebEnvironmentLoadingTask taskWithRequestExecutor:self.requestExecutor
                                                                                         HTMLString:HTMLString
                                                                                            baseURL:baseURL];
    loadingTask.completion = ^{
        if (completion) {
            completion(YES, nil);
        }
    };
    [self.operationQueue addOperation:loadingTask];
}

- (void)loadRequest:(NSURLRequest * __nonnull)request completion:(JMWebEnvironmentLoadingCompletion)completion
{
    if ([request.URL isFileURL]) {
        // TODO: detect format of file for request
        [self loadLocalFileFromURL:request.URL
                        fileFormat:nil
                           baseURL:nil];
        // TODO: implement completion
        if (completion) {
            completion(YES, nil);
        }
    } else {
        JMWebEnvironmentLoadingTask *loadingTask = [JMWebEnvironmentLoadingTask taskWithRequestExecutor:self.requestExecutor
                                                                                             URLRequest:request];
        loadingTask.completion = ^{
            if (completion) {
                completion(YES, nil);
            }
        };
        [self.operationQueue addOperation:loadingTask];
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
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    JMLog(@"request: %@", request.fullCommand);

    JMJavascriptRequestTask *requestTask = [JMJavascriptRequestTask taskWithRequestExecutor:self.requestExecutor
                                                                                    request:request
                                                                                 completion:completion];

    if (self.state == JMWebEnvironmentStateWebViewCreated) {
        NSOperation *prepareWebViewTask = [self taskForPreparingWebView];
        [self.operationQueue addOperation:prepareWebViewTask];
        NSOperation *prepareEnvironmentTask = [self taskForPreparingEnvironment];
        [self.operationQueue addOperation:prepareEnvironmentTask];
        [self.operationQueue addOperation:requestTask];
    } else if(self.state == JMWebEnvironmentStateWebViewConfigured) {
        JMLog(@"try to send request when state is JMWebEnvironmentStateWebViewConfigured");
        NSOperation *prepareEnvironmentTask = [self taskForPreparingEnvironment];
        [self.operationQueue addOperation:prepareEnvironmentTask];
        [self.operationQueue addOperation:requestTask];
    } else if(self.state == JMWebEnvironmentStateEnvironmentReady) {
        [self.operationQueue addOperation:requestTask];
    } else if(self.state == JMWebEnvironmentStateSessionExpired){
        NSArray *cookies = [JMWebViewManager sharedInstance].cookies;
        __weak __typeof(self) weakSelf = self;
        NSOperation *updateCookiesTask = [JMWebEnvironmentUpdateCookiesTask taskWithRESTClient:self.restClient
                                                                               requestExecutor:self.requestExecutor
                                                                                       cookies:cookies
                                                                                     competion:^{
                                                                                         weakSelf.state = JMWebEnvironmentStateEnvironmentReady;
                                                                                     }];
        [self.operationQueue addOperation:updateCookiesTask];
        [self.operationQueue addOperation:requestTask];
    } else {
        JMLog(@"try to send request when state is %@", @(self.state));
        [self.operationQueue addOperation:requestTask];
    }
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

- (NSOperation *__nullable)taskForPreparingWebView
{
    return nil;
}

- (NSOperation *__nullable)taskForPreparingEnvironment
{
    return nil;
}

- (void)resetZoom
{
    [self.webView.scrollView setZoomScale:0.1 animated:YES];
}

- (void)clean
{
    NSURLRequest *clearingRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]];
    [self.webView loadRequest:clearingRequest];
    self.state = JMWebEnvironmentStateWebViewCreated;
}

- (void)reset
{
    [self resetZoom];
    [self.webView removeFromSuperview];
    // TODO: need reset requestExecutor because will be leak
    if (!self.reusable) {
        [self.requestExecutor reset];
    }
}

#pragma mark - WebView Helpers

- (void)setupWebEnvironmentWithCookies:(NSArray <NSHTTPCookie *> *__nonnull)cookies
{
    NSAssert(cookies != nil, @"Cookies are nil");
    _webView = [[JMWebViewFabric sharedInstance] createWebViewWithCookies:cookies];
    _requestExecutor = [JMJavascriptRequestExecutor executorWithWebView:_webView];
    _requestExecutor.delegate = self;
    self.state = JMWebEnvironmentStateWebViewCreated;
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