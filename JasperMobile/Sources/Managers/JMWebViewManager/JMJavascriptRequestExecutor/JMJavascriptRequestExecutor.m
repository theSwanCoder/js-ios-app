/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMJavascriptEvent.h"
#import "JMUtils.h"
#import "NSObject+Additions.h"

NSString *const kJMJavascriptNativeBridgeCallbackURL = @"jaspermobile.callback";
NSString *const JMJavascriptRequestExecutorErrorCodeKey = @"JMJavascriptRequestExecutorErrorCodeKey";

@interface JMJavascriptRequestExecutor() <WKNavigationDelegate, WKScriptMessageHandler>
@property (nonatomic, strong) NSMutableDictionary <JMJavascriptRequest *, JMJavascriptRequestCompletion>*requestCompletions;
@property (nonatomic, strong) NSMutableArray <JMJavascriptEvent *> *events;
@end

@implementation JMJavascriptRequestExecutor
@synthesize webView = _webView, delegate = _delegate;

#pragma mark - Custom Initializers
- (instancetype __nullable)initWithWebView:(WKWebView * __nonnull)webView
{
    self = [super init];
    if (self) {
        JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
        // TODO: move this funtionality into separate class (something like storage)
        _requestCompletions = [NSMutableDictionary dictionary];
        _events = [NSMutableArray array];
        _webView = webView;
        _webView.navigationDelegate = self;
        [_webView.configuration.userContentController addScriptMessageHandler:self
                                                                         name:@"JMJavascriptRequestExecutor"];
        // add window.onerror listener
        __weak __typeof(self) weakSelf = self;
        JMJavascriptEvent *windowOnErrorEvent = [JMJavascriptEvent eventWithIdentifier:@"JasperMobile.Events.Window.OnError"
                                                                              listener:self
                                                                              callback:^(JMJavascriptResponse *response, NSError *error) {
                                                                                  __strong __typeof(self) strongSelf = weakSelf;
                                                                                  if ([strongSelf.delegate respondsToSelector:@selector(javascriptRequestExecutor:didReceiveError:)]) {
                                                                                      [strongSelf.delegate javascriptRequestExecutor:strongSelf
                                                                                                                     didReceiveError:error];
                                                                                  }
                                                                              }];
        [self addListenerWithEvent:windowOnErrorEvent];
    }
    return self;
}

+ (instancetype __nullable)executorWithWebView:(WKWebView * __nonnull)webView
{
    return [[self alloc] initWithWebView:webView];
}

- (void)dealloc
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
}

#pragma mark - Public API
- (void)startLoadHTMLString:(NSString *)HTMLString
                    baseURL:(NSURL *)baseURL
{
    if (baseURL) {
        [self.webView stopLoading];
        [self.webView loadHTMLString:HTMLString
                             baseURL:baseURL];
    } else {
        // TODO: how handle this case?
    }
}

- (void)sendJavascriptRequest:(JMJavascriptRequest *__nonnull)request
                   completion:(JMJavascriptRequestCompletion __nullable)completion
{
//    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
//    JMLog(@"send request: %@", request);

    if (completion) {
        self.requestCompletions[request] = [completion copy];
    }
    __weak __typeof(self) weakSelf = self;
    [self.webView evaluateJavaScript:[request fullJavascriptRequestString]
                   completionHandler:^(id result, NSError *error) {
                       __strong __typeof(self) strongSelf = weakSelf;
//                       JMLog(@"request: %@", request);
//                       JMLog(@"error: %@", error);
//                       JMLog(@"result: %@", result);
                       if (error) {
                           [strongSelf.requestCompletions removeObjectForKey:request];
                           if (completion) {
                               completion(nil, error);
                           }
                       }
                   }];
}

- (void)addListenerWithEvent:(JMJavascriptEvent * __nonnull)event
{
//    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
//    JMLog(@"listenerId: %@", listenerId);

    id listenerForId = [self findListenerForEvent:event];
    if (!listenerForId) {
        [self.events addObject:event];
    } else {
        JMLog(@"listener is already exists");
    }
}


- (void)reset
{
    [self removeAllListeners];
    self.webView.navigationDelegate = nil;
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"JMJavascriptRequestExecutor"];
}

- (void)removeListener:(id)listener
{
//    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
//    JMLog(@"before remove: events: %@", self.events);
    NSMutableArray *events = [NSMutableArray array];
    for (JMJavascriptEvent *event in self.events) {
        if (![event.listener isEqual:listener]) {
            [events addObject:event];
        }
    }
    self.events = events;
//    JMLog(@"after remove: events: %@", self.events);
}

- (void)removeAllListeners
{
//    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    self.requestCompletions = [NSMutableDictionary dictionary];
    self.events = [NSMutableArray array];
}

#pragma mark - WKWebViewDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    if ([self isLocalFileRequest:navigationAction.request]) {
        // TODO: request from delegate to allow such requests.
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }

    if ([self isCleaningRequest:navigationAction.request]) {
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }

    if ([self isLoginRequest:navigationAction.request]) {
        // For dashboard only (without visualize)
        [self handleUnauthRequest];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }

    if ([self isRequestToRunReport:navigationAction.request]) {
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }

    if ([self isExternalRequest:navigationAction.request]) {
        BOOL shouldStartLoad = NO;

        if ([self.delegate respondsToSelector:@selector(javascriptRequestExecutor:shouldLoadExternalRequest:)]) {
            shouldStartLoad = [self.delegate javascriptRequestExecutor:self shouldLoadExternalRequest:navigationAction.request];
        }
        if (shouldStartLoad) {
            decisionHandler(WKNavigationActionPolicyAllow);
        } else {
            decisionHandler(WKNavigationActionPolicyCancel);
        }
        return;
    }

    NSLog(@"request from webView: %@", navigationAction.request);
    NSLog(@"request from webView, allHTTPHeaderFields: %@", navigationAction.request.allHTTPHeaderFields);

    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [self handleDOMContentLoaded];
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
//    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    id parameters = message.body;
//    JMLog(@"parameters: %@", parameters);

    // At the moment from the webview we can receive only a dictionary
    if ([parameters isKindOfClass:[NSDictionary class]]) {
        [self handleCallbackWithRequestParams:parameters];
    }
}

#pragma mark - Helpers

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

- (BOOL)isLocalFileRequest:(NSURLRequest *)request
{
    BOOL isLocalFileRequest = NO;
    if ([request.URL isFileURL]) {
        isLocalFileRequest = YES;
    }
    return isLocalFileRequest;
}

- (BOOL)isCleaningRequest:(NSURLRequest *)request
{
    BOOL isCleaningRequest = NO;
    NSString *requestURLString = request.URL.absoluteString;
    if ([requestURLString isEqualToString:@"about:blank"]) {
        isCleaningRequest = YES;
    }
    return isCleaningRequest;
}

#pragma mark - Callbacks
- (void)handleCallbackWithRequestParams:(NSDictionary*)parameters
{
    if (parameters) {
        JMJavascriptResponse *response = [JMJavascriptResponse new];
        NSString *type = parameters[@"type"];
        if ([type isEqualToString:@"logging"]) {
            response.type = JMJavascriptCallbackTypeLog;
        } else if ([type isEqualToString:@"callback"]) {
            response.type = JMJavascriptCallbackTypeCallback;
        } else if ([type isEqualToString:@"listener"]) {
            response.type = JMJavascriptCallbackTypeListener;
        }
        response.command = parameters[@"command"];
        id params = parameters[@"parameters"];
        // TODO: investigate other cases
        if (![params isKindOfClass:[NSDictionary class]]) {
            params = nil;
        }
        response.parameters = params;
        [self didReceiveResponse:response];
    } else {
        // TODO: add general errors handling
    }
}

- (void)handleUnauthRequest
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    NSString *unauthorizedListenerId = @"JasperMobile.VIS.Dashboard.API.unauthorized";
    for (JMJavascriptEvent *event in self.events) {
        if ([event.identifier isEqualToString:unauthorizedListenerId]) {
            JMJavascriptRequestCompletion completion = event.callback;
            NSError *error = [self makeErrorFromWebViewError:@{
                    @"code" : @"authentication.error"
            }];
            completion(nil, error);
            break;
        }
    }
}

- (void)handleDOMContentLoaded
{
    NSString *unauthorizedListenerId = @"DOMContentLoaded";
    for (JMJavascriptEvent *event in self.events) {
        if ([event.identifier isEqualToString:unauthorizedListenerId]) {
            JMJavascriptRequestCompletion completion = event.callback;
            completion(nil, nil);
            break;
        }
    }
}

- (void)didReceiveResponse:(JMJavascriptResponse *)response
{
//    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
//    JMLog(@"%@", response);
    switch(response.type) {
        case JMJavascriptCallbackTypeLog: {
            JMLog(@"Bridge Message:\n%@\nobject: %@", response.parameters[@"message"], response.parameters[@"object"]);
            break;
        }
        case JMJavascriptCallbackTypeListener: {
            [self handleListenersForResponse:response];
            break;
        }
        case JMJavascriptCallbackTypeCallback: {
            JMJavascriptRequest *foundRequest;
            for (JMJavascriptRequest *request in self.requestCompletions) {
                if ([request.fullCommand isEqualToString:response.command]) {
                    foundRequest = request;
                    break;
                }
            }
            // We should always have a corresponded request on response in storage.
            NSAssert(foundRequest != nil, @"Request wasn't found for response: %@", response);
            if (foundRequest) {
                JMLog(@"foundRequest:%@", foundRequest);
                JMJavascriptRequestCompletion completion = self.requestCompletions[foundRequest];
                [self.requestCompletions removeObjectForKey:foundRequest];
                if (response.parameters && response.parameters[@"error"]) {
                    NSDictionary *errorJSON = response.parameters[@"error"];
                    NSError *error = [self makeErrorFromWebViewError:errorJSON];
                    completion(nil, error);
                } else {
                    completion(response, nil);
                }
            }
            break;
        }
    }
}

- (void)handleListenersForResponse:(JMJavascriptResponse *)response
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    NSArray <JMJavascriptEvent *> *events = [self findEventsForId:response.command];
    for (JMJavascriptEvent *event in events) {
        JMJavascriptRequestCompletion completion = event.callback;
        if (response.parameters && response.parameters[@"error"]) {
            NSDictionary *errorJSON = response.parameters[@"error"];
            NSError *error = [self makeErrorFromWebViewError:errorJSON];
            completion(nil, error);
        } else {
            completion(response, nil);
        }
    }
}

- (NSArray <JMJavascriptEvent *>*)findEventsForId:(NSString *)identifier
{
    NSMutableArray *events = [NSMutableArray array];
    for (JMJavascriptEvent *event in self.events) {
        if ([event.identifier isEqualToString:identifier]) {
            [events addObject:event];
        }
    }
    return events;
}

- (id)findListenerForEvent:(JMJavascriptEvent *)event
{
    id listener;
    for (JMJavascriptEvent *e in self.events) {
        if ([e isEqual:event]) {
            listener = e.listener;
            break;
        }
    }
    return listener;
}

- (NSError *)makeErrorFromWebViewError:(NSDictionary *)errorJSON
{
    NSString *visualizeErrorDomain = @"Visualize Error Domain";
    NSInteger code = JMJavascriptRequestErrorTypeOther;

    id errorCode = errorJSON[@"code"];
    NSString *errorCodeString;
    if (errorCode && [errorCode isKindOfClass:[NSString class]]) {
        errorCodeString = errorCode;
        if ([errorCodeString isEqualToString:@"window.onerror"]) {
            code = JMJavascriptRequestErrorTypeWindow;
            JMLog(@"window.onerror: %@", errorJSON);
        } else if ([errorCodeString isEqualToString:@"unexpected.error"]) {
            code = JMJavascriptRequestErrorTypeUnexpected;
        } else if ([errorCodeString isEqualToString:@"authentication.error"]) {
            code = JMJavascriptRequestErrorTypeSessionDidExpire;
        } else if ([errorCodeString isEqualToString:@"resource.not.found"]) {
            // It is assumed that this code could be only when session was restored
            code = JMJavascriptRequestErrorTypeSessionDidExpire;
        }
    }
    // TODO: need add handle integer codes?

    NSString *errorMessage = errorJSON[@"message"];
    NSMutableDictionary *userInfo;
    if (errorMessage) {
        userInfo = [@{
                NSLocalizedDescriptionKey : errorMessage
        } mutableCopy];
    } else {
        userInfo = [@{
                NSLocalizedDescriptionKey: @"Error"
        } mutableCopy];
    }
    if (errorCodeString) {
        userInfo[JMJavascriptRequestExecutorErrorCodeKey] = errorCodeString;
    }
    NSError *error = [NSError errorWithDomain:visualizeErrorDomain
                                         code:code
                                     userInfo:userInfo];
    return error;
}

@end
