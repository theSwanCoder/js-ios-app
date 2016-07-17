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
//  JMBaseDashboardLoader.m
//  TIBCO JasperMobile
//

#import "JMBaseDashboardLoader.h"
#import "JMDashboard.h"
#import "JMRESTWebEnvironment.h"
#import "JMJavascriptRequest.h"

@interface JMBaseDashboardLoader()
@property (nonatomic, weak) JMDashboard *dashboard;
@property (nonatomic, weak) JMRESTWebEnvironment *webEnvironment;
@property (nonatomic, assign, getter=isCancelLoad) BOOL cancelLoading;
@end

@implementation
JMBaseDashboardLoader
@synthesize delegate = _delegate;

#pragma mark - Initializers
- (void)dealloc
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
}

- (id<JMDashboardLoader> __nullable)initWithDashboard:(JMDashboard *__nonnull)dashboard
                                       webEnvironment:(JMWebEnvironment *)webEnvironment
{
    self = [super init];
    if (self) {
        NSAssert(dashboard != nil, @"Dashboard is nil");
        NSAssert(webEnvironment != nil, @"WebEnvironment is nil");
        _dashboard = dashboard;
        _webEnvironment = (JMRESTWebEnvironment *) webEnvironment;
        [self addListenersForWebEnvironmentEvents];
    }
    return self;
}

+ (id<JMDashboardLoader> __nullable)loaderWithDashboard:(JMDashboard *__nonnull)dashboard
                                         webEnvironment:(JMWebEnvironment *)webEnvironment
{
    return [[self alloc] initWithDashboard:dashboard
                            webEnvironment:webEnvironment];
}

#pragma mark - Public API
- (void)loadDashboardWithCompletion:(void (^)(BOOL success, NSError *error))completion
{
    NSAssert(completion != nil, @"Completion is nil");
    NSAssert(self.dashboard != nil, @"Dashboard is nil");
    if (self.isCancelLoad) {
        return;
    }

    JMDashboardLoaderCompletion heapBlock = [completion copy];

    __weak __typeof(self) weakSelf = self;
    [self.webEnvironment prepareWithCompletion:^(BOOL isReady, NSError *error) {
        __typeof(self) strongSelf = weakSelf;
        if (strongSelf.cancelLoading) {
            return;
        }
        if (isReady) {
            [strongSelf runDashboardWithCompletion:heapBlock];
        } else {
            heapBlock(NO, error);
        }
    }];
}

- (void)reloadDashboardWithCompletion:(JMDashboardLoaderCompletion)completion
{
    NSAssert(completion != nil, @"Completion is nil");
    NSAssert(self.dashboard != nil, @"Dashboard is nil");

    JMDashboardLoaderCompletion heapBlock = [completion copy];

    [self destroyDashboardWithCompletion:^(BOOL success, NSError *error) {
        if (success) {
            __weak __typeof(self) weakSelf = self;
            [self.webEnvironment prepareWithCompletion:^(BOOL isReady, NSError *error) {
                __typeof(self) strongSelf = weakSelf;
                if (strongSelf.cancelLoading) {
                    return;
                }
                if (isReady) {
                    [strongSelf refreshDashboardWithCompletion:heapBlock];
                } else {
                    heapBlock(NO, error);
                }
            }];
        } else {
            heapBlock(NO, error);
        }
    }];
}

- (void)minimizeDashletWithCompletion:(JMDashboardLoaderCompletion __nonnull)completion
{
    // TODO: correct this
//    JMDashboardLoaderCompletion heapBlock = [completion copy];
//
//    JMJavascriptRequest *request = [JMJavascriptRequest requestWithCommand:@"MobileDashboard.minimizeDashlet"
//                                                                parameters:nil];
//    [self.webEnvironment sendJavascriptRequest:request completion:^(NSDictionary *parameters, NSError *error) {
//        if (error) {
//            heapBlock(NO, error);
//        } else {
//            heapBlock(YES, nil);
//        }
//    }];
}

- (void)cancel
{
    self.cancelLoading = YES;
}

- (void)destroy
{
    [self destroyDashboardWithCompletion:nil];
}

#pragma mark - Helpers
- (void)runDashboardWithCompletion:(JMDashboardLoaderCompletion __nonnull)completion
{
    NSAssert(completion != nil, @"Completion is nil");
    NSAssert(self.dashboard != nil, @"Dashboard is nil");

    JMDashboardLoaderCompletion heapBlock = [completion copy];
    // run
    JMJavascriptRequest *runRequest = [JMJavascriptRequest requestWithCommand:@"API.runDashboard"
                                                                  inNamespace:JMJavascriptNamespaceRESTDashboard
                                                                   parameters:@{
                                                                           @"baseURL" : self.restClient.baseURL.absoluteString,
                                                                           @"resourceURI" : self.dashboard.resourceURI
                                                                   }];
    __weak __typeof(self) weakSelf = self;
    [self.webEnvironment sendJavascriptRequest:runRequest completion:^(NSDictionary *parameters, NSError *error) {
        __typeof(self) strongSelf = weakSelf;
        if (strongSelf.isCancelLoad) {
            return;
        }
        if (error) {
            heapBlock(NO, error);
        } else {
            heapBlock(YES, nil);
        }
    }];
}

- (void)refreshDashboardWithCompletion:(JMDashboardLoaderCompletion __nonnull)completion
{
    NSAssert(completion != nil, @"Completion is nil");
    NSAssert(self.dashboard != nil, @"Dashboard is nil");

    JMDashboardLoaderCompletion heapBlock = [completion copy];

    JMJavascriptRequest *request = [JMJavascriptRequest requestWithCommand:@"API.refresh"
                                                               inNamespace:JMJavascriptNamespaceRESTDashboard
                                                                parameters:@{
                                                                        @"baseURL" : self.restClient.baseURL.absoluteString,
                                                                        @"resourceURI" : self.dashboard.resourceURI
                                                                }];
    __weak __typeof(self) weakSelf = self;
    [self.webEnvironment sendJavascriptRequest:request completion:^(NSDictionary *parameters, NSError *error) {
        __typeof(self) strongSelf = weakSelf;
        if (strongSelf.isCancelLoad) {
            return;
        }
        if (error) {
            heapBlock(NO, error);
        } else {
            heapBlock(YES, nil);
        }
    }];
}

- (void)destroyDashboardWithCompletion:(JMDashboardLoaderCompletion __nullable)completion
{
    NSAssert(self.dashboard != nil, @"Dashboard is nil");

    JMDashboardLoaderCompletion heapBlock = [completion copy];

    JMJavascriptRequest *runRequest = [JMJavascriptRequest requestWithCommand:@"API.destroy"
                                                                  inNamespace:JMJavascriptNamespaceRESTDashboard
                                                                   parameters:nil];
    __weak __typeof(self) weakSelf = self;
    [self.webEnvironment sendJavascriptRequest:runRequest completion:^(NSDictionary *parameters, NSError *error) {
        __typeof(self) strongSelf = weakSelf;
        if (strongSelf.isCancelLoad) {
            return;
        }
        if (!heapBlock) {
            return;
        }
        if (!error) {
            heapBlock(YES, nil);
        } else {
            heapBlock(NO, error);
        }
    }];
}

- (void)addListenersForWebEnvironmentEvents
{
    // Authorization
    __weak __typeof(self) weakSelf = self;
    NSString *unauthorizedListenerId = @"JasperMobile.VIS.Dashboard.API.unauthorized";
    [self.webEnvironment addListener:self
                          forEventId:unauthorizedListenerId
                            callback:^(NSDictionary *params, NSError *error) {
                                JMLog(unauthorizedListenerId);
                                if (!weakSelf) {
                                    return;
                                }
                                [weakSelf.delegate dashboardLoaderDidReceiveAuthRequest:weakSelf];
                            }];
}

- (void)injectJSCodeOldDashboard
{
   CGFloat initialScale = 0.5;
    if ([JMUtils isCompactWidth] || [JMUtils isCompactHeight]) {
        initialScale = 0.25;
    }

    JMJavascriptRequest *request = [JMJavascriptRequest requestWithCommand:@"JasperMobile.Helper.updateViewPortScale"
                                                               inNamespace:JMJavascriptNamespaceDefault
                                                                parameters:@{
                                                                        @"scale" : @(initialScale)
                                                                }];
    [self.webEnvironment sendJavascriptRequest:request
                                    completion:nil];

}

@end