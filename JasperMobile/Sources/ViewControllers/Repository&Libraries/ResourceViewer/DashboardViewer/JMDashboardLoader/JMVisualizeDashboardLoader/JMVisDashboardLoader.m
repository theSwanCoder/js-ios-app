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
//  JMVisDashboardLoader.m
//  TIBCO JasperMobile
//

#import "JMVisDashboardLoader.h"
#import "JMDashboard.h"
#import "JMVIZWebEnvironment.h"
#import "JMResource.h"
#import "JMJavascriptRequest.h"
#import "JMHyperlink.h"
#import "JMJavascriptRequestExecutor.h"
#import "JMUtils.h"

@interface JMVisDashboardLoader()
@property (nonatomic, strong, readwrite) JMDashboard *dashboard;
@property (nonatomic, weak) JMVIZWebEnvironment *webEnvironment;
@property (nonatomic, assign, readwrite) JMDashboardLoaderState state;
@property (nonatomic, copy, readwrite) JSRESTBase *restClient;
@end

@implementation JMVisDashboardLoader
@synthesize delegate;

- (void)dealloc
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
}

#pragma mark - Initializers
- (id<JMDashboardLoader> __nullable)initWithRESTClient:(JSRESTBase *)restClient
                                        webEnvironment:(JMWebEnvironment * __nonnull)webEnvironment
{
    self = [super init];
    if (self) {
        NSAssert(restClient != nil, @"Parameter for rest client is nil");
        NSAssert([webEnvironment isKindOfClass:[JMVIZWebEnvironment class]], @"WebEnvironment isn't correct class");
        _webEnvironment = (JMVIZWebEnvironment *) webEnvironment;
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
    [self freshRunDashboardWithCompletion:completion];
}

- (void)reloadWithCompletion:(JMDashboardLoaderCompletion __nonnull)completion
{
    NSAssert(completion != nil, @"Completion is nil");
    NSAssert(self.dashboard != nil, @"Dashboard is nil");

    if (self.state == JMDashboardLoaderStateCancel) {
        return;
    }

    JMDashboardLoaderCompletion heapBlock = [completion copy];

    JMJavascriptRequest *request = [JMJavascriptRequest requestWithCommand:@"API.refresh"
                                                               inNamespace:JMJavascriptNamespaceVISDashboard
                                                                parameters:nil];
    self.state = JMDashboardLoaderStateLoading;
    __weak __typeof(self) weakSelf = self;
    [self.webEnvironment sendJavascriptRequest:request completion:^(NSDictionary *parameters, NSError *error) {
        __typeof(self) strongSelf = weakSelf;
        if (strongSelf.state == JMDashboardLoaderStateCancel) {
            return;
        }
        if (error) {
            strongSelf.state = JMDashboardLoaderStateFailed;
            heapBlock(NO, error);
        } else {
            strongSelf.state = JMDashboardLoaderStateReady;
            heapBlock(YES, nil);
        }
    }];
}

- (void)destroy
{
    NSAssert(self.dashboard != nil, @"Dashboard is nil");

    [self destroyDashboard];
    self.state = JMDashboardLoaderStateDestroy;
}

- (void)cancel
{
    NSAssert(self.dashboard != nil, @"Dashboard is nil");

    [self cancelDashboard];
    self.state = JMDashboardLoaderStateCancel;
}

#pragma mark - JMDashboardLoader optional methods

- (void)applyParameters:(NSDictionary <NSString *, NSArray <NSString *>*> *__nonnull)parameters
             completion:(JMDashboardLoaderCompletion __nonnull) completion
{
    NSAssert(completion != nil, @"Completion is nil");
    NSAssert(self.dashboard != nil, @"Dashboard is nil");

    if (self.state == JMDashboardLoaderStateCancel) {
        return;
    }

    JMJavascriptRequest *applyParamsRequest = [JMJavascriptRequest requestWithCommand:@"API.applyParams"
                                                                          inNamespace:JMJavascriptNamespaceVISDashboard
                                                                           parameters:parameters];
    self.state = JMDashboardLoaderStateLoading;
    __weak __typeof(self) weakSelf = self;
    [self.webEnvironment sendJavascriptRequest:applyParamsRequest completion:^(NSDictionary *resultParameters, NSError *error) {
        __typeof(self) strongSelf = weakSelf;
        if (strongSelf.state == JMDashboardLoaderStateCancel) {
            return;
        }
        if (error) {
            strongSelf.state = JMDashboardLoaderStateFailed;
            completion(NO, error);
        } else {

            strongSelf.state = JMDashboardLoaderStateReady;
            completion(YES, nil);
        }
    }];
}

- (void)reloadDashboardComponent:(JSDashboardComponent *__nonnull)component completion:(JMDashboardLoaderCompletion __nonnull)completion
{
    NSAssert(completion != nil, @"Completion is nil");
    NSAssert(self.dashboard != nil, @"Dashboard is nil");

    if (self.state == JMDashboardLoaderStateCancel) {
        return;
    }

    JMJavascriptRequest *request = [JMJavascriptRequest requestWithCommand:@"API.refreshDashlet"
                                                               inNamespace:JMJavascriptNamespaceVISDashboard
                                                                parameters:@{
                                                                        @"identifier" : component.identifier ?: @""
                                                                }];
    __weak __typeof(self) weakSelf = self;
    [self.webEnvironment sendJavascriptRequest:request completion:^(NSDictionary *parameters, NSError *error) {
        __typeof(self) strongSelf = weakSelf;
        if (strongSelf.state == JMDashboardLoaderStateCancel) {
            return;
        }
        if (error) {
            strongSelf.state = JMDashboardLoaderStateFailed;
            completion(NO, error);
        } else {
            // TODO: investigate
//            NSString *isFullReload = parameters[@"isFullReload"];
//            if ([isFullReload isEqualToString:@"true"]) {
//                if (strongSelf.dashboard.maximizedComponent) {
//                    [strongSelf maximizeDashboardComponent:strongSelf.dashboard.maximizedComponent
//                                                completion:completion];
//                }
//            }
            strongSelf.state = JMDashboardLoaderStateReady;
            completion(YES, nil);
        }
    }];
}

- (void)maximizeDashboardComponent:(JSDashboardComponent *__nonnull)component completion:(JMDashboardLoaderCompletion __nonnull)completion
{
    NSAssert(completion != nil, @"Completion is nil");
    NSAssert(self.dashboard != nil, @"Dashboard is nil");
    if (self.state == JMDashboardLoaderStateCancel) {
        return;
    }

    JMJavascriptRequest *request = [JMJavascriptRequest requestWithCommand:@"API.maximizeDashlet"
                                                               inNamespace:JMJavascriptNamespaceVISDashboard
                                                                parameters:@{
                                                                        @"identifier" : component.identifier ?: @""
                                                                }];
    __weak __typeof(self) weakSelf = self;
    [self.webEnvironment sendJavascriptRequest:request completion:^(NSDictionary *parameters, NSError *error) {
        __typeof(self) strongSelf = weakSelf;
        if (strongSelf.state == JMDashboardLoaderStateCancel) {
            return;
        }
        if (error) {
            strongSelf.state = JMDashboardLoaderStateFailed;
            completion(NO, error);
        } else {
            strongSelf.dashboard.maximizedComponent = component;
            strongSelf.state = JMDashboardLoaderStateReady;
            completion(YES, nil);
        }
    }];
}

- (void)minimizeDashboardComponent:(JSDashboardComponent *__nonnull)component completion:(JMDashboardLoaderCompletion __nonnull)completion
{
    NSAssert(completion != nil, @"Completion is nil");
//    NSAssert(component != nil, @"Component is nil");
    NSAssert(self.dashboard != nil, @"Dashboard is nil");

    if (self.state == JMDashboardLoaderStateCancel) {
        return;
    }

    JMJavascriptRequest *request = [JMJavascriptRequest requestWithCommand:@"API.minimizeDashlet"
                                                               inNamespace:JMJavascriptNamespaceVISDashboard
                                                                parameters:@{
                                                                        @"identifier" : component.identifier ?: @""
                                                                }];
    __weak __typeof(self) weakSelf = self;
    [self.webEnvironment sendJavascriptRequest:request completion:^(NSDictionary *parameters, NSError *error) {
        __typeof(self) strongSelf = weakSelf;
        if (strongSelf.state == JMDashboardLoaderStateCancel) {
            return;
        }
        if (error) {
            strongSelf.state = JMDashboardLoaderStateFailed;
            completion(NO, error);
        } else {
            strongSelf.dashboard.maximizedComponent = nil;
            strongSelf.state = JMDashboardLoaderStateReady;
            completion(YES, nil);
        }
    }];
}

#pragma mark - Private API

- (void)freshRunDashboardWithCompletion:(JMDashboardLoaderCompletion __nonnull)completion
{
    NSAssert(completion != nil, @"Completion is nil");
    NSAssert(self.dashboard != nil, @"Dashboard is nil");

    if (self.state == JMDashboardLoaderStateCancel) {
        return;
    }

    // run
    JMJavascriptRequest *runRequest = [JMJavascriptRequest requestWithCommand:@"API.run"
                                                                  inNamespace:JMJavascriptNamespaceVISDashboard
                                                                   parameters:@{
                                                                           @"uri" : self.dashboard.resourceURI,
                                                                           @"is_for_6_0" : @([JMUtils isServerAmber])
                                                                   }];
    self.state = JMDashboardLoaderStateLoading;
    __weak __typeof(self) weakSelf = self;
    [self.webEnvironment sendJavascriptRequest:runRequest completion:^(NSDictionary *parameters, NSError *error) {
        __typeof(self) strongSelf = weakSelf;
        if (strongSelf.state == JMDashboardLoaderStateCancel) {
            return;
        }
        if (error) {
            completion(NO, error);
        } else {
            strongSelf.state = JMDashboardLoaderStateReady;
            completion(YES, nil);
        }
    }];
}

- (void)destroyDashboard
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [self removeListenersForVisualizeEvents];
    JMJavascriptRequest *request = [JMJavascriptRequest requestWithCommand:@"API.destroy"
                                                               inNamespace:JMJavascriptNamespaceVISDashboard
                                                                parameters:nil];
    [self.webEnvironment sendJavascriptRequest:request completion:^(NSDictionary *parameters, NSError *error) {
        // Need capture self to wait until this request finishes
        if (error) {
            JMLog(@"error: %@", error);
        } else {
            JMLog(@"parameters: %@", parameters);
        }
    }];
}

- (void)cancelDashboard
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [self removeListenersForVisualizeEvents];
    JMJavascriptRequest *request = [JMJavascriptRequest requestWithCommand:@"API.cancel"
                                                               inNamespace:JMJavascriptNamespaceVISDashboard
                                                                parameters:nil];
    [self.webEnvironment sendJavascriptRequest:request completion:^(NSDictionary *parameters, NSError *error) {
        if (error) {
            JMLog(@"error: %@", error);
        } else {
            JMLog(@"parameters: %@", parameters);
        }
    }];
}

#pragma mark - Helpers
- (void)addListenersForVisualizeEvents
{
    __weak __typeof(self) weakSelf = self;
    NSString *dashletWillMaximizeListenerId = @"JasperMobile.VIS.Dashboard.API.events.dashlet.didStartMaximize";
    [self.webEnvironment addListener:self
                          forEventId:dashletWillMaximizeListenerId
                            callback:^(NSDictionary *params, NSError *error) {
                                JMLog(dashletWillMaximizeListenerId);
                                __typeof(self) strongSelf = weakSelf;
                                if (error) {
                                    [JMUtils presentAlertControllerWithError:error
                                                                  completion:nil];
                                } else {
                                    [strongSelf handleDidStartMaximizeDashletWithParameters:params];
                                }
                            }];
    NSString *dashletDidMaximizeListenerId = @"JasperMobile.VIS.Dashboard.API.events.dashlet.didEndMaximize";
    [self.webEnvironment addListener:self forEventId:dashletDidMaximizeListenerId
                            callback:^(NSDictionary *params, NSError *error) {
                                JMLog(dashletDidMaximizeListenerId);
                                __typeof(self) strongSelf = weakSelf;
                                if (error) {
                                    [JMUtils presentAlertControllerWithError:error
                                                                  completion:nil];
                                } else {
                                    [strongSelf handleDidEndMaximazeDashletWithParameters:params];
                                }
                            }];

    // Links
    NSString *reportExecutionLinkOptionListenerId = @"JasperMobile.VIS.Event.Link.ReportExecution";
    [self.webEnvironment addListener:self
                          forEventId:reportExecutionLinkOptionListenerId
                            callback:^(NSDictionary *params, NSError *error) {
                                JMLog(reportExecutionLinkOptionListenerId);
                                __typeof(self) strongSelf = weakSelf;
                                if (error) {
                                    JMLog(@"error: %@", error);
                                } else {
                                    [strongSelf handleRunReportWithParameters:params];
                                }
                            }];
    NSString *referenceLinkOptionListenerId = @"JasperMobile.VIS.Event.Link.Reference";
    [self.webEnvironment addListener:self
                          forEventId:referenceLinkOptionListenerId
                            callback:^(NSDictionary *params, NSError *error) {
                                JMLog(referenceLinkOptionListenerId);
                                __typeof(self) strongSelf = weakSelf;
                                if (error) {
                                    JMLog(@"error: %@", error);
                                } else {
                                    [strongSelf handleOnReferenceClick:params];
                                }
                            }];
    NSString *adHocExecutionLinkOptionListenerId = @"JasperMobile.VIS.Event.Link.AdHocExecution";
    [self.webEnvironment addListener:self forEventId:adHocExecutionLinkOptionListenerId
                            callback:^(NSDictionary *params, NSError *error) {
                                JMLog(adHocExecutionLinkOptionListenerId);
                                __typeof(self) strongSelf = weakSelf;
                                if (error) {
                                    JMLog(@"error: %@", error);
                                } else {
                                    [strongSelf handleOnAdHocExecution:params];
                                }
                            }];
    NSString *remoteAnchorListenerId = @"JasperMobile.VIS.Event.Link.RemoteAnchor";
    [self.webEnvironment addListener:self
                          forEventId:remoteAnchorListenerId
                            callback:^(NSDictionary *params, NSError *error) {
                                JMLog(remoteAnchorListenerId);
                                if (!weakSelf) {
                                    return;
                                }
                                if (error) {
                                    [weakSelf handleHyperlinksError:error];
                                } else {
                                    JMLog(@"parameters: %@", params);
                                    NSString *href = params[@"location"];
                                    if (href) {
                                        if ([weakSelf.delegate respondsToSelector:@selector(dashboardLoader:didReceiveEventWithHyperlink:)]) {
                                            JMHyperlink *hyperlink = [JMHyperlink new];
                                            hyperlink.type = JMHyperlinkTypeRemoteAnchor;
                                            hyperlink.href = href;
                                            [weakSelf.delegate dashboardLoader:weakSelf didReceiveEventWithHyperlink:hyperlink];
                                        }
                                    } else {
                                        // TODO: need handle this case?
                                    }
                                }
                            }];
    NSString *remotePageListenerId = @"JasperMobile.VIS.Event.Link.RemotePage";
    [self.webEnvironment addListener:self
                          forEventId:remotePageListenerId
                            callback:^(NSDictionary *params, NSError *error) {
                                JMLog(remotePageListenerId);
                                if (!weakSelf) {
                                    return;
                                }
                                if (error) {
                                    [weakSelf handleHyperlinksError:error];
                                } else {
                                    JMLog(@"parameters: %@", params);
                                    NSString *href = params[@"location"];
                                    if (href) {
                                        if ([weakSelf.delegate respondsToSelector:@selector(dashboardLoader:didReceiveEventWithHyperlink:)]) {
                                            JMHyperlink *hyperlink = [JMHyperlink new];
                                            hyperlink.type = JMHyperlinkTypeRemotePage;
                                            hyperlink.href = href;
                                            [weakSelf.delegate dashboardLoader:weakSelf didReceiveEventWithHyperlink:hyperlink];
                                        }
                                    } else {
                                        // TODO: need handle this case?
                                    }
                                }
                            }];
    NSString *dashletHyperlinkListenerId = @"JasperMobile.VIS.Event.Link.Dashlet";
    [self.webEnvironment addListener:self
                          forEventId:dashletHyperlinkListenerId
                            callback:^(NSDictionary *params, NSError *error) {
                                JMLog(remotePageListenerId);
                                if (!weakSelf) {
                                    return;
                                }
                                if (error) {
                                    [weakSelf handleHyperlinksError:error];
                                } else {
                                    JMLog(@"parameters: %@", params);
                                    if ([self.delegate respondsToSelector:@selector(dashboardLoaderDidReceiveEventWithUnsupportedHyperlink:)]) {
                                        [self.delegate dashboardLoaderDidReceiveEventWithUnsupportedHyperlink:self];
                                    }
                                }
                            }];
}

- (void)removeListenersForVisualizeEvents
{
    [self.webEnvironment removeListener:self];
}

#pragma mark - Handle JS callbacks

- (void)handleDidStartMaximizeDashletWithParameters:(NSDictionary *)parameters
{
    if (self.state == JMDashboardLoaderStateCancel) {
        return;
    }

    if ([self.delegate respondsToSelector:@selector(dashboardLoaderDidStartMaximizeDashlet:)]) {
        [self.delegate dashboardLoaderDidStartMaximizeDashlet:self];
    }
}

- (void)handleDidEndMaximazeDashletWithParameters:(NSDictionary *)parameters
{
    if (self.state == JMDashboardLoaderStateCancel) {
        return;
    }

    JMLog(@"parameters: %@", parameters);
    if ([JMUtils isServerAmber]) {
//        title = parameters[@"componentId"];
    } else {
//        title = parameters[@"component"][@"name"];
        NSString *componentId = parameters[@"component"][@"id"];
        for(JSDashboardComponent *component in self.dashboard.components) {
            if ([componentId isEqualToString:component.identifier]) {
                self.dashboard.maximizedComponent = component;
                break;
            }
        }
    }

    if ([self.delegate respondsToSelector:@selector(dashboardLoader:didEndMaximazeDashboardComponent:)]) {
        [self.delegate dashboardLoader:self didEndMaximazeDashboardComponent:self.dashboard.maximizedComponent];
    }
}

- (void)handleRunReportWithParameters:(NSDictionary *)parameters
{
    if (self.state == JMDashboardLoaderStateCancel) {
        return;
    }

    JMLog(@"parameters: %@", parameters);
    NSDictionary *data = parameters[@"data"];
    if (!data) {
        return;
    }

    NSString *reportPath = data[@"resource"];
    if (reportPath) {
        if ([self.delegate respondsToSelector:@selector(dashboardLoader:didReceiveEventWithHyperlink:)]) {
            JMHyperlink *hyperlink = [JMHyperlink hyperlinkWithHref:reportPath withRawData:data[@"params"]];
            [self.delegate dashboardLoader:self didReceiveEventWithHyperlink:hyperlink];
        }
    }
}

- (void)handleOnAdHocExecution:(NSDictionary *)parameters
{
    if (self.dashboard.maximizedComponent.dashletHyperlinkTarget == JSDashletHyperlinksTargetTypeBlank) {
        NSDictionary *linkObject = parameters[@"linkObject"];
        NSString *urlString;
        if (linkObject[@"URL"]) {
            urlString = linkObject[@"URL"];
        } else {
            // Parse raw parameters (case for amber jrs)
            NSDictionary *params = linkObject[@"parameters"];
            for(NSString *key in params) {
                if([self.dashboard.maximizedComponent.dashletHyperlinkUrl containsString:key]) {
                    NSString *fullPlaceholder = [NSString stringWithFormat:@"$P{%@}", key];
                    urlString = [self.dashboard.maximizedComponent.dashletHyperlinkUrl stringByReplacingOccurrencesOfString:fullPlaceholder
                                                                                                                 withString:params[key]];

                    NSMutableArray *urlComponents = [[urlString componentsSeparatedByString:@"?"] mutableCopy];
                    urlComponents[1] = [[urlComponents lastObject] hostEncodedString];
                    urlString = [urlComponents componentsJoinedByString:@"?"];
                }
            }
        }
        if (urlString) {
            JMHyperlink *hyperlink = [JMHyperlink new];
            hyperlink.type = JMHyperlinkTypeAdHocExecution;
            hyperlink.href = urlString;
            [self.delegate dashboardLoader:self didReceiveEventWithHyperlink:hyperlink];
        } else {
            // TODO: need handle this case?
        }
    }
}

- (void)handleOnReferenceClick:(NSDictionary *)parameters
{
    if (self.state == JMDashboardLoaderStateCancel) {
        return;
    }

    NSString *locationString = parameters[@"location"];
    if (locationString) {
        if ([self.delegate respondsToSelector:@selector(dashboardLoader:didReceiveEventWithHyperlink:)]) {
            JMHyperlink *hyperlink = [JMHyperlink new];
            hyperlink.type = JMHyperlinkTypeReference;
            hyperlink.href = locationString;
            [self.delegate dashboardLoader:self didReceiveEventWithHyperlink:hyperlink];
        }
    }
}


- (void)handleHyperlinksError:(NSError *)error
{
    if (error.code == JMJavascriptRequestErrorTypeOther) {
        NSString *javascriptErrorCode = error.userInfo[JMJavascriptRequestExecutorErrorCodeKey];
        if (javascriptErrorCode && [javascriptErrorCode isEqualToString:@"hyperlink.not.support.error"]) {
            if ([self.delegate respondsToSelector:@selector(dashboardLoaderDidReceiveEventWithUnsupportedHyperlink:)]) {
                [self.delegate dashboardLoaderDidReceiveEventWithUnsupportedHyperlink:self];
            }
        }
    }
}

#pragma mark - Helpers
- (NSArray *)createReportParametersFromParameters:(NSDictionary *)parameters
{
    NSMutableArray *reportParameters = [NSMutableArray array];
    for (NSString *key in parameters.allKeys) {
        [reportParameters addObject:[[JSReportParameter alloc] initWithName:key
                                                            value:parameters[key]]];
    }
    return [reportParameters copy];
}

@end