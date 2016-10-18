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
//  JMWebEnvironmentLoadingTask.h
//  TIBCO JasperMobile
//

#import "JMWebEnvironmentLoadingTask.h"
#import "JMJavascriptEvent.h"
#import "JMJavascriptRequestExecutor.h"
#import "JMWebViewFabric.h"

@interface JMWebEnvironmentLoadingTask()
@property (nonatomic, strong) JMJavascriptRequestExecutor *requestExecutor;
@property (nonatomic, strong) NSString *HTMLString;
@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, strong) NSURLRequest *URLRequest;
@end

@implementation JMWebEnvironmentLoadingTask

#pragma mark - Life Cycle

- (instancetype)initWithRequestExecutor:(JMJavascriptRequestExecutor *)requestExecutor
                             HTMLString:(NSString *)HTMLString
                                baseURL:(NSURL *)baseURL
{
    self = [super init];
    if (self) {
        _requestExecutor = requestExecutor;
        _HTMLString = HTMLString;
        _baseURL = baseURL;
        self.state = JMAsyncTaskStateReady;
    }
    return self;
}

+ (instancetype)taskWithRequestExecutor:(JMJavascriptRequestExecutor *)requestExecutor
                             HTMLString:(NSString *)HTMLString
                                baseURL:(NSURL *)baseURL
{
    return [[self alloc] initWithRequestExecutor:requestExecutor
                                      HTMLString:HTMLString
                                         baseURL:baseURL];
}

- (instancetype)initWithRequestExecutor:(JMJavascriptRequestExecutor *)requestExecutor
                             URLRequest:(NSURLRequest *)URLRequest
{
    self = [super init];
    if (self) {
        _requestExecutor = requestExecutor;
        _URLRequest = URLRequest;
        self.state = JMAsyncTaskStateReady;
    }
    return self;
}

+ (instancetype)taskWithRequestExecutor:(JMJavascriptRequestExecutor *)requestExecutor
                             URLRequest:(NSURLRequest *)URLRequest
{
    return [[self alloc] initWithRequestExecutor:requestExecutor
                                      URLRequest:URLRequest];
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
