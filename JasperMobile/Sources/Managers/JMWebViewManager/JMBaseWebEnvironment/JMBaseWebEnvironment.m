/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMBaseWebEnvironment.h"
#import "JMJavascriptRequestExecutor.h"
#import "JMJavascriptEvent.h"
#import "JMAsyncTask.h"
#import "JMJavascriptRequestTask.h"
#import "JMWebEnvironmentLoadingTask.h"
#import "JMWebEnvironmentUpdateCookiesTask.h"
#import "JMWebViewFabric.h"
#import "UIView+Additions.h"

@interface JMBaseWebEnvironment() <JMJavascriptRequestExecutorDelegate>
@property (nonatomic, strong, readwrite) WKWebView *webView;
@property (nonatomic, copy, readwrite) NSString *identifier;
@property (nonatomic, strong, nonnull) NSOperationQueue *operationQueue;
@end

@implementation JMBaseWebEnvironment

#pragma mark - Life Cycle
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
    JMLog(@"%@ - %@:%@", self, NSStringFromSelector(_cmd), [self stateNameForState:_state]);
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
                                                                                            baseURL:baseURL
                                                                                         completion:^{
                                                                                             if (completion) {
                                                                                                 completion(YES, nil);
                                                                                             }
                                                                                         }];
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
                                                                                             URLRequest:request
                                                                                             completion:^{
                                                                                                 if (completion) {
                                                                                                     completion(YES, nil);
                                                                                                 }
                                                                                             }];
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
        if ([JMUtils isSystemVersionEqualOrUp9]) {
            [self.webView loadFileURL:fileURL
              allowingReadAccessToURL:fileURL];
        } else {
            [self.webView loadRequest:[NSURLRequest requestWithURL:fileURL]];
        }
    }
}

#pragma mark - JMJavascriptRequestExecutionProtocol

- (BOOL)canSendJavascriptRequest
{
    return (self.state == JMWebEnvironmentStateEnvironmentReady && self.cookiesState == JMWebEnvironmentCookiesStateValid);
}

- (void)sendJavascriptRequest:(JMJavascriptRequest *__nonnull)request
                   completion:(JMWebEnvironmentRequestParametersCompletion __nullable)completion
             needSessionValid:(BOOL)needSessionValid
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    JMLog(@"request: %@", request.fullCommand);
    JMLog(@"state: %@", [self stateNameForState:self.state]);
    JMLog(@"cookies state: %@", [self stateNameForCookiesState:self.cookiesState]);
    JMLog(@"operation queue operations: %@", self.operationQueue.operations);

    if (self.state == JMWebEnvironmentStateCancel) {
        // TODO: How handle this case
        NSError *error = [[NSError alloc] initWithDomain:@"Visualize Domain Error"
                                                    code:JMJavascriptRequestErrorTypeCancel
                                                userInfo:@{
                                                        NSLocalizedDescriptionKey: @"All javascript requests were canceled"
                                                }];
        if (completion) {
            completion(nil, error);
        }
        return;
    }

    [self verifyWebEnvironmentState];

    if (!needSessionValid) {
        [self processRequest:request
                  completion:completion];
        return;
    }

    switch(self.cookiesState) {
        case JMWebEnvironmentCookiesStateValid: {
            [self processRequest:request
                      completion:completion];
            break;
        }
        case JMWebEnvironmentCookiesStateExpire: {
            @throw [NSException exceptionWithName:@"Wrong state for sending a javascript request"
                                           reason:@"This state should be changed before sending a new javascript request"
                                         userInfo:nil];
        }
        case JMWebEnvironmentCookiesStateRestoreAfterJavascriptRequestFailed: {
            [self updateCookiesInWebViewWithCompletion:nil];
            [self processRequest:request
                      completion:completion];
            break;
        }
        case JMWebEnvironmentCookiesStateRestoreAfterNetworkRequestFailed: {
            [self updateCookiesInWebViewWithCompletion:^(NSDictionary *params, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) {
                        completion(nil, [self createSessionDidRestoreError]);
                    }
                });
            }];
            break;
        }
    }
}

- (void)sendJavascriptRequest:(JMJavascriptRequest *__nonnull)request
                   completion:(JMWebEnvironmentRequestParametersCompletion __nullable)completion
{
    [self sendJavascriptRequest:request
                     completion:completion
               needSessionValid:YES];
}

- (void)verifyWebEnvironmentState
{
    switch (self.state) {
        case JMWebEnvironmentStateWithoutWebView: {
            break;
        }
        case JMWebEnvironmentStateEmptyWebView: {
            [self addOperationsForPreparingWebViewAndEnvironment];
            break;
        }
        case JMWebEnvironmentStateWebViewReady: {
            [self addOperationsForPreparingWebEnvironment];
            break;
        }
        case JMWebEnvironmentStateEnvironmentReady: {
            break;
        }
        case JMWebEnvironmentStateCancel: {
            break;
        }
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
    [self.operationQueue cancelAllOperations];
    NSURLRequest *clearingRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]];
    [self.webView loadRequest:clearingRequest];
    self.state = JMWebEnvironmentStateEmptyWebView;
}

- (void)cancel
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    JMLog(@"operation queue operations: %@", self.operationQueue.operations);
    [self.operationQueue cancelAllOperations];
    JMLog(@"operation queue operations: %@", self.operationQueue.operations);
    [self reset];
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
    self.state = JMWebEnvironmentStateEmptyWebView;
    self.cookiesState = JMWebEnvironmentCookiesStateValid;
}

- (void)recreateWebViewWithCookies:(NSArray <NSHTTPCookie *>*)cookies
{
    UIView *webViewSuperview = self.webView.superview;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (webViewSuperview) {
            [self.webView removeFromSuperview];
        }
    });
    [self.requestExecutor reset];
    _webView = nil;
    _requestExecutor = nil;
    [self setupWebEnvironmentWithCookies:cookies];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (webViewSuperview) {
            [webViewSuperview fillWithView:self.webView];
        } else {
            // TODO: in this case web view will be in 'air'
        }
    });
}

#pragma mark - Helpers

- (void)processRequest:(JMJavascriptRequest *)request
            completion:(JMWebEnvironmentRequestParametersCompletion __nullable)completion
{
    __weak __typeof(self) weakSelf = self;
    [self.operationQueue addOperation:[JMJavascriptRequestTask taskWithRequestExecutor:self.requestExecutor
                                                                               request:request
                                                                            completion:^(NSDictionary *params, NSError *error) {
                                                                                __strong __typeof(self) strongSelf = weakSelf;
                                                                                if (error.code == JMJavascriptRequestErrorTypeSessionDidExpire) {
                                                                                    JMLog(@"cookies are not valid");
                                                                                    strongSelf.cookiesState = JMWebEnvironmentCookiesStateExpire;
                                                                                    if (completion) {
                                                                                        completion(nil, [strongSelf createSessionDidExpireError]);
                                                                                    }
                                                                                } else {
                                                                                    if (completion) {
                                                                                        completion(params, error);
                                                                                    }
                                                                                }
                                                                            }]];
}

- (void)updateCookiesInWebViewWithCompletion:(JMWebEnvironmentRequestParametersCompletion __nullable)completion
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    NSArray *cookies = [JMWebViewManager sharedInstance].cookies;
    __weak __typeof(self) weakSelf = self;
    void(^cookiesUpdatedCompletion)(void) = ^{
        __strong __typeof(self) strongSelf = weakSelf;
        strongSelf.cookiesState = JMWebEnvironmentCookiesStateValid;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(nil, nil);
            }
        });
    };
    if ([JMUtils isSystemVersionEqualOrUp9]) {
        [self.operationQueue addOperation:[JMWebEnvironmentUpdateCookiesTask taskWithRESTClient:self.restClient
                                                                                requestExecutor:self.requestExecutor
                                                                                        cookies:cookies
                                                                                      competion:cookiesUpdatedCompletion]];
    } else {
        [self recreateWebViewWithCookies:cookies];
        [self addOperationsForPreparingWebViewAndEnvironment];
        [self.operationQueue addOperation:[NSBlockOperation blockOperationWithBlock:cookiesUpdatedCompletion]];
    }
}

- (void)addOperationsForPreparingWebViewAndEnvironment
{
    if ([self taskForPreparingWebView]) {
        [self.operationQueue addOperation:[self taskForPreparingWebView]];
    }
    if ([self taskForPreparingEnvironment]) {
        [self.operationQueue addOperation:[self taskForPreparingEnvironment]];
    }
}

- (void)addOperationsForPreparingWebEnvironment
{
    [self.operationQueue addOperation:[self taskForPreparingEnvironment]];
}

- (NSError *)createSessionDidExpireError
{
    NSString *visualizeErrorDomain = @"Visualize Domain Error";
    NSInteger code = JMJavascriptRequestErrorTypeSessionDidExpire;
    NSDictionary *userInfo = @{
            NSLocalizedDescriptionKey: @"Error"
    };
    NSError *error = [NSError errorWithDomain:visualizeErrorDomain
                                         code:code
                                     userInfo:userInfo];
    return error;
}

- (NSError *)createSessionDidRestoreError
{
    NSString *visualizeErrorDomain = @"Visualize Domain Error";
    NSInteger code = JMJavascriptRequestErrorTypeSessionDidRestore;
    NSDictionary *userInfo = @{
            NSLocalizedDescriptionKey: @"Error"
    };
    NSError *error = [NSError errorWithDomain:visualizeErrorDomain
                                         code:code
                                     userInfo:userInfo];
    return error;
}


- (NSString *)stateNameForState:(JMWebEnvironmentState)state
{
    NSString *stateName;
    switch(state) {
        case JMWebEnvironmentStateWithoutWebView: {
            stateName = @"JMWebEnvironmentStateWithoutWebView";
            break;
        }
        case JMWebEnvironmentStateEmptyWebView: {
            stateName = @"JMWebEnvironmentStateEmptyWebView";
            break;
        }
        case JMWebEnvironmentStateWebViewReady: {
            stateName = @"JMWebEnvironmentStateWebViewReady";
            break;
        }
        case JMWebEnvironmentStateEnvironmentReady: {
            stateName = @"JMWebEnvironmentStateEnvironmentReady";
            break;
        }
        case JMWebEnvironmentStateCancel: {
            stateName = @"JMWebEnvironmentStateCancel";
            break;
        }
    }
    return stateName;
}

- (NSString *)stateNameForCookiesState:(JMWebEnvironmentCookiesState)state
{
    NSString *stateName;
    switch(state) {
        case JMWebEnvironmentCookiesStateValid: {
            stateName = @"JMWebEnvironmentCookiesStateValid";
            break;
        }
        case JMWebEnvironmentCookiesStateExpire: {
            stateName = @"JMWebEnvironmentCookiesStateExpire";
            break;
        }
        case JMWebEnvironmentCookiesStateRestoreAfterJavascriptRequestFailed: {
            stateName = @"JMWebEnvironmentCookiesStateRestoreAfterJavascriptRequestFailed";
            break;
        }
        case JMWebEnvironmentCookiesStateRestoreAfterNetworkRequestFailed: {
            stateName = @"JMWebEnvironmentCookiesStateRestoreAfterNetworkRequestFailed";
            break;
        }
    }
    return stateName;
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
