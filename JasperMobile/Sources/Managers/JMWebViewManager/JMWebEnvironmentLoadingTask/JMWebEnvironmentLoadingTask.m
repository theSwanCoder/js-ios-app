/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMWebEnvironmentLoadingTask.h"
#import "JMJavascriptEvent.h"
#import "JMJavascriptRequestExecutor.h"
#import "JMWebViewFabric.h"
#import "JMUtils.h"

@interface JMWebEnvironmentLoadingTask()
@property (nonatomic, strong) JMJavascriptRequestExecutor *requestExecutor;
@property (nonatomic, strong) NSString *HTMLString;
@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, strong) NSURLRequest *URLRequest;
@property (nonatomic, copy, nullable) void(^completion)(void);
@end

@implementation JMWebEnvironmentLoadingTask

#pragma mark - Life Cycle

- (instancetype)initWithRequestExecutor:(JMJavascriptRequestExecutor *)requestExecutor
                             HTMLString:(NSString *)HTMLString
                                baseURL:(NSURL *)baseURL
                             completion:(void(^__nullable)(void))completion
{
    self = [super init];
    if (self) {
        _requestExecutor = requestExecutor;
        _HTMLString = HTMLString;
        _baseURL = baseURL;
        _completion = completion;
    }
    return self;
}

+ (instancetype)taskWithRequestExecutor:(JMJavascriptRequestExecutor *)requestExecutor
                             HTMLString:(NSString *)HTMLString
                                baseURL:(NSURL *)baseURL
                             completion:(void(^)(void))completion
{
    return [[self alloc] initWithRequestExecutor:requestExecutor
                                      HTMLString:HTMLString
                                         baseURL:baseURL
                                      completion:completion];
}

- (instancetype)initWithRequestExecutor:(JMJavascriptRequestExecutor *)requestExecutor
                             URLRequest:(NSURLRequest *)URLRequest
                             completion:(void(^)(void))completion
{
    self = [super init];
    if (self) {
        _requestExecutor = requestExecutor;
        _URLRequest = URLRequest;
        _completion = completion;
    }
    return self;
}

+ (instancetype)taskWithRequestExecutor:(JMJavascriptRequestExecutor *)requestExecutor
                             URLRequest:(NSURLRequest *)URLRequest
                             completion:(void(^)(void))completion
{
    return [[self alloc] initWithRequestExecutor:requestExecutor
                                      URLRequest:URLRequest
                                      completion:completion];
}

#pragma mark - Overridden methods NSOperation

- (void)main
{
    if (self.isCancelled) {
        return;
    }
    JMLog(@"%@: Start Loading", self);
    __weak __typeof(self) weakSelf = self;
    JMJavascriptEvent *event = [JMJavascriptEvent eventWithIdentifier:@"DOMContentLoaded"
                                                             listener:self
                                                             callback:^(JMJavascriptResponse *response, NSError *error) {
                                                                 __typeof(self) strongSelf = weakSelf;
                                                                 JMLog(@"%@: Event was received: DOMContentLoaded", strongSelf);
                                                                 if (strongSelf.isCancelled) {
                                                                     // TODO: add sending a canceling error
                                                                     return;
                                                                 }
                                                                 strongSelf.state = JMAsyncTaskStateFinished;
                                                                 [strongSelf.requestExecutor removeListener:strongSelf];
                                                                 if (strongSelf.completion) {
                                                                     strongSelf.completion();
                                                                 }
                                                             }];
    [self.requestExecutor addListenerWithEvent:event];
    // TODO: try other way to separate logic
    if (self.URLRequest) {
        [self operateURLRequest];
    } else {
        [self operateHTMLString];
    }
}

#pragma mark - Helpers

- (void)operateURLRequest
{
    NSMutableURLRequest *requestWithCookies = [NSMutableURLRequest requestWithURL:self.URLRequest.URL];
    requestWithCookies.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
    [requestWithCookies addValue:[[JMWebViewFabric sharedInstance] cookiesAsStringFromCookies:[JMWebViewManager sharedInstance].cookies]
              forHTTPHeaderField:@"Cookie"];
    [self.requestExecutor.webView loadRequest:requestWithCookies];
}

- (void)operateHTMLString
{
    [self.requestExecutor startLoadHTMLString:self.HTMLString
                                      baseURL:self.baseURL];
}

@end
