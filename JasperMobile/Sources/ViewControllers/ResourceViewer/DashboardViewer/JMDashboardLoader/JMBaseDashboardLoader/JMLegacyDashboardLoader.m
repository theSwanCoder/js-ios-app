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
//  JMLegacyDashboardLoader.m
//  TIBCO JasperMobile
//

#import "JMLegacyDashboardLoader.h"
#import "JMDashboard.h"
#import "JMRESTWebEnvironment.h"
#import "JMJavascriptRequest.h"

@interface JMLegacyDashboardLoader()
@property (nonatomic, strong, readwrite) JMDashboard *dashboard;
@property (nonatomic, weak) JMRESTWebEnvironment *webEnvironment;
@property (nonatomic, assign, readwrite) JMDashboardLoaderState state;
@property (nonatomic, copy, readwrite) JSRESTBase *restClient;
@end

@implementation JMLegacyDashboardLoader
@synthesize delegate;

#pragma mark - Initializers
- (void)dealloc
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    [self removeListenersForVisualizeEvents];
}

- (id<JMDashboardLoader> __nullable)initWithRESTClient:(JSRESTBase *)restClient
                                        webEnvironment:(JMWebEnvironment * __nonnull)webEnvironment
{
    self = [super init];
    if (self) {
        NSAssert(restClient != nil, @"Parameter for rest client is nil");
        NSAssert(webEnvironment != nil, @"WebEnvironment is nil");
        _webEnvironment = (JMRESTWebEnvironment *) webEnvironment;
        _state = JMDashboardLoaderStateInitial;
        _restClient = [restClient copy];
        [self addListenersForVisualizeEvents];
    }
    return self;
}

+ (id<JMDashboardLoader> __nullable)loaderWithRESTClient:(JSRESTBase *)restClient
                                          webEnvironment:(JMWebEnvironment * __nonnull)webEnvironment
{
    return [[self alloc] initWithRESTClient:restClient
                             webEnvironment:webEnvironment];
}

#pragma mark - JMDashboardLoader required methods

- (void)runDashboard:(JMDashboard *__nonnull)dashboard completion:(JMDashboardLoaderCompletion __nonnull)completion
{
    NSAssert(completion != nil, @"Completion is nil");
    NSAssert(dashboard != nil, @"Dashboard is nil");

    if (self.state == JMDashboardLoaderStateCancel) {
        return;
    }

    self.dashboard = dashboard;
    self.state = JMDashboardLoaderStateConfigured;
    [self loadLegacyDashboardWithCompletion:completion];
}

- (void)destroy
{
    NSAssert(self.dashboard != nil, @"Dashboard is nil");

    self.state = JMDashboardLoaderStateDestroy;
}

- (void)cancel
{
    NSAssert(self.dashboard != nil, @"Dashboard is nil");

    self.state = JMDashboardLoaderStateCancel;
}

#pragma mark - Helpers

- (void)freshRunDashboardWithCompletion:(JMDashboardLoaderCompletion __nonnull)completion
{
    NSAssert(completion != nil, @"Completion is nil");
    NSAssert(self.dashboard != nil, @"Dashboard is nil");

    JMJavascriptRequest *runRequest = [JMJavascriptRequest requestWithCommand:@"API.runDashboard"
                                                                  inNamespace:JMJavascriptNamespaceRESTDashboard
                                                                   parameters:@{
                                                                           @"baseURL" : self.restClient.baseURL.absoluteString,
                                                                           @"resourceURI" : self.dashboard.resourceURI
                                                                   }];
    __weak __typeof(self) weakSelf = self;
    [self.webEnvironment sendJavascriptRequest:runRequest completion:^(NSDictionary *parameters, NSError *error) {
        __typeof(self) strongSelf = weakSelf;
        if (strongSelf.state == JMDashboardLoaderStateCancel) {
            return;
        }
        if (error) {
            completion(NO, error);
        } else {
            completion(YES, nil);
        }
    }];
}

- (void)loadLegacyDashboardWithCompletion:(JMDashboardLoaderCompletion __nonnull)completion
{
    NSString *flowPath = [NSString stringWithFormat:@"%@flow.html?_flowId=dashboardRuntimeFlow&viewAsDashboardFrame=true&dashboardResource=%@", self.restClient.baseURL.absoluteString, self.dashboard.resourceURI];
    NSURL *url = [NSURL URLWithString:flowPath];
    NSMutableURLRequest *request = [[NSURLRequest requestWithURL:url] mutableCopy];
    [self.webEnvironment loadRequest:request completion:^(BOOL isReady, NSError *error) {
        if (isReady) {
            completion(YES, nil);
        }
    }];
}

#pragma mark - Helpers

- (void)addListenersForVisualizeEvents
{
    __weak __typeof(self) weakSelf = self;
    NSString *dashletWillMaximizeListenerId = @"JasperMobile.VIS.Dashboard.API.unauthorized";
    [self.webEnvironment addListener:self
                          forEventId:dashletWillMaximizeListenerId
                            callback:^(NSDictionary *params, NSError *error) {
                                JMLog(dashletWillMaximizeListenerId);
                                __typeof(self) strongSelf = weakSelf;
                                if (error) {
                                    if ([strongSelf.delegate respondsToSelector:@selector(dashboardLoader:didRecieveError:)]) {
                                        [strongSelf.delegate dashboardLoader:strongSelf didRecieveError:error];
                                    }
                                }
                            }];
}

- (void)removeListenersForVisualizeEvents
{
    [self.webEnvironment removeListener:self];
}

@end