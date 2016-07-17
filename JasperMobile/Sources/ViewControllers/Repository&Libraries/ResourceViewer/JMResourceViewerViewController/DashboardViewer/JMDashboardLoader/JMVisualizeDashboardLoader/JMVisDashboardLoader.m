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

typedef NS_ENUM(NSInteger, JMDashboardViewerAlertViewType) {
    JMDashboardViewerAlertViewTypeEmptyReport,
    JMDashboardViewerAlertViewTypeErrorLoad
};

#import "JMVisDashboardLoader.h"
#import "JMDashboard.h"
#import "JMVIZWebEnvironment.h"
#import "JMResource.h"
#import "JMJavascriptRequest.h"

@interface JMVisDashboardLoader()
@property (nonatomic, weak) JMDashboard *dashboard;
@property (nonatomic, weak) JMVIZWebEnvironment *webEnvironment;
@property (nonatomic, assign, getter=isCancelLoad) BOOL cancelLoading;
@end

@implementation JMVisDashboardLoader
@synthesize delegate = _delegate;

- (void)dealloc
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
}

#pragma mark - Initializers
- (id<JMDashboardLoader> __nullable)initWithDashboard:(JMDashboard *__nonnull)dashboard
                                       webEnvironment:(JMWebEnvironment *)webEnvironment
{
    self = [super init];
    if (self) {
        NSAssert([webEnvironment isKindOfClass:[JMVIZWebEnvironment class]], @"WebEnvironment isn't correct class");
        _dashboard = dashboard;
        _webEnvironment = (JMVIZWebEnvironment *) webEnvironment;
        [self addListenersForVisualizeEvents];
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
- (void)loadDashboardWithCompletion:(JMDashboardLoaderCompletion) completion
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

- (void)reloadDashboardWithCompletion:(JMDashboardLoaderCompletion) completion
{
    NSAssert(completion != nil, @"Completion is nil");
    NSAssert(self.dashboard != nil, @"Dashboard is nil");
    if (self.isCancelLoad) {
        return;
    }

    JMDashboardLoaderCompletion heapBlock = [completion copy];

    JMJavascriptRequest *request = [JMJavascriptRequest requestWithCommand:@"API.refresh"
                                                               inNamespace:JMJavascriptNamespaceVISDashboard
                                                                parameters:nil];
    __weak __typeof(self) weakSelf = self;
    [self.webEnvironment sendJavascriptRequest:request completion:^(NSDictionary *parameters, NSError *error) {
        __typeof(self) strongSelf = weakSelf;
        if (strongSelf.cancelLoading) {
            return;
        }
        if (error) {
            heapBlock(NO, error);
        } else {
            heapBlock(YES, nil);
        }
    }];
}

- (void)reloadMaximizedDashletWithCompletion:(JMDashboardLoaderCompletion) completion
{
    NSAssert(completion != nil, @"Completion is nil");
    NSAssert(self.dashboard != nil, @"Dashboard is nil");
    if (self.cancelLoading) {
        return;
    }

    JMDashboardLoaderCompletion heapBlock = [completion copy];

    JMJavascriptRequest *request = [JMJavascriptRequest requestWithCommand:@"API.refreshDashlet"
                                                               inNamespace:JMJavascriptNamespaceVISDashboard
                                                                parameters:nil];
    __weak __typeof(self) weakSelf = self;
    [self.webEnvironment sendJavascriptRequest:request completion:^(NSDictionary *parameters, NSError *error) {
        __typeof(self) strongSelf = weakSelf;
        if (strongSelf.cancelLoading) {
            return;
        }
        if (error) {
            heapBlock(NO, error);
        } else {
            NSString *isFullReload = parameters[@"isFullReload"];
            if ([isFullReload isEqualToString:@"true"]) {
                if (strongSelf.dashboard.maximizedComponent) {
                    [strongSelf maximizeDashletForComponent:strongSelf.dashboard.maximizedComponent
                                                 completion:heapBlock];
                }
            }
            heapBlock(YES, nil);
        }
    }];
}

- (void)fetchParametersWithCompletion:(JMDashboardLoaderCompletion) completion
{
    NSAssert(completion != nil, @"Completion is nil");
    NSAssert(self.dashboard != nil, @"Dashboard is nil");
    if (self.cancelLoading) {
        return;
    }

    JMDashboardLoaderCompletion heapBlock = [completion copy];

    JMJavascriptRequest *applyParamsRequest = [JMJavascriptRequest requestWithCommand:@"API.getDashboardParameters"
                                                                          inNamespace:JMJavascriptNamespaceVISDashboard
                                                                           parameters:nil];
    __weak __typeof(self) weakSelf = self;
    [self.webEnvironment sendJavascriptRequest:applyParamsRequest completion:^(NSDictionary *parameters, NSError *error) {
        __typeof(self) strongSelf = weakSelf;
        if (strongSelf.cancelLoading) {
            return;
        }
        if (error) {
            heapBlock(NO, error);
        } else {
            heapBlock(YES, nil);
        }
    }];
}

- (void)applyParameters:(NSDictionary *)parameters completion:(JMDashboardLoaderCompletion __nonnull) completion
{
    NSAssert(completion != nil, @"Completion is nil");
    NSAssert(self.dashboard != nil, @"Dashboard is nil");
    if (self.isCancelLoad) {
        return;
    }
    JMDashboardLoaderCompletion heapBlock = [completion copy];

    JMJavascriptRequest *applyParamsRequest = [JMJavascriptRequest requestWithCommand:@"API.applyParams"
                                                                          inNamespace:JMJavascriptNamespaceVISDashboard
                                                                           parameters:parameters];
    __weak __typeof(self) weakSelf = self;
    [self.webEnvironment sendJavascriptRequest:applyParamsRequest completion:^(NSDictionary *parameters, NSError *error) {
        __typeof(self) strongSelf = weakSelf;
        if (strongSelf.cancelLoading) {
            return;
        }
        if (error) {
            heapBlock(NO, error);
        } else {
            heapBlock(YES, nil);
        }
    }];
}

- (void)cancel
{
    self.cancelLoading = YES;
    [self cancelDashboard];
}

- (void)destroy
{
    [self destroyDashboard];
}

- (void)maximizeDashletForComponent:(JSDashboardComponent *__nullable)component completion:(JMDashboardLoaderCompletion __nonnull) completion
{
    NSAssert(completion != nil, @"Completion is nil");
    NSAssert(self.dashboard != nil, @"Dashboard is nil");
    if (self.isCancelLoad) {
        return;
    }
    JMDashboardLoaderCompletion heapBlock = [completion copy];

    JMJavascriptRequest *request = [JMJavascriptRequest requestWithCommand:@"API.maximizeDashlet"
                                                               inNamespace:JMJavascriptNamespaceVISDashboard
                                                                parameters:@{
                                                                        @"identifier" : component != nil ? component.identifier : @"null"
                                                                }];
    __weak __typeof(self) weakSelf = self;
    [self.webEnvironment sendJavascriptRequest:request completion:^(NSDictionary *parameters, NSError *error) {
        __typeof(self) strongSelf = weakSelf;
        if (strongSelf.cancelLoading) {
            return;
        }
        if (error) {
            heapBlock(NO, error);
        } else {
            strongSelf.dashboard.maximizedComponent = component;
            heapBlock(YES, nil);
        }
    }];
}

- (void)minimizeDashletForComponent:(JSDashboardComponent *__nullable)component completion:(JMDashboardLoaderCompletion __nonnull) completion
{
    NSAssert(completion != nil, @"Completion is nil");
    NSAssert(self.dashboard != nil, @"Dashboard is nil");
    if (self.isCancelLoad) {
        return;
    }
    JMDashboardLoaderCompletion heapBlock = [completion copy];
    JMJavascriptRequest *request = [JMJavascriptRequest requestWithCommand:@"API.minimizeDashlet"
                                                               inNamespace:JMJavascriptNamespaceVISDashboard
                                                                parameters:@{
                                                                        @"identifier" : component != nil ? component.identifier : @"null"
                                                                }];
    __weak __typeof(self) weakSelf = self;
    [self.webEnvironment sendJavascriptRequest:request completion:^(NSDictionary *parameters, NSError *error) {
        __typeof(self) strongSelf = weakSelf;
        if (strongSelf.cancelLoading) {
            return;
        }
        if (error) {
            heapBlock(NO, error);
        } else {
            strongSelf.dashboard.maximizedComponent = nil;
            heapBlock(YES, nil);
        }
    }];
}

- (void)minimizeDashletWithCompletion:(JMDashboardLoaderCompletion __nonnull) completion
{
    [self minimizeDashletForComponent:self.dashboard.maximizedComponent completion:completion];
}

#pragma mark - Private API
- (void)runDashboardWithCompletion:(JMDashboardLoaderCompletion __nonnull)completion
{
    NSAssert(completion != nil, @"Completion is nil");
    NSAssert(self.dashboard != nil, @"Dashboard is nil");
    if (self.isCancelLoad) {
        return;
    }

    JMDashboardLoaderCompletion heapBlock = [completion copy];
    // run
    JMJavascriptRequest *runRequest = [JMJavascriptRequest requestWithCommand:@"API.run"
                                                                  inNamespace:JMJavascriptNamespaceVISDashboard
                                                                   parameters:@{
                                                                           @"uri" : self.dashboard.resourceURI,
                                                                           @"is_for_6_0" : @([JMUtils isServerAmber])
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
                                if ([strongSelf.delegate respondsToSelector:@selector(dashboardLoaderDidStartMaximizeDashlet:)]) {
                                    [strongSelf.delegate dashboardLoaderDidStartMaximizeDashlet:strongSelf];
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
    NSString *reportExecutionLinkOptionListenerId = @"JasperMobile.VIS.Dashboard.API.run.linkOptions.events.ReportExecution";
    [self.webEnvironment addListener:self
                          forEventId:reportExecutionLinkOptionListenerId
                            callback:^(NSDictionary *params, NSError *error) {
                                JMLog(reportExecutionLinkOptionListenerId);
                                __typeof(self) strongSelf = weakSelf;
                                [strongSelf handleOnReportExecution:params];
                            }];
    NSString *referenceLinkOptionListenerId = @"JasperMobile.VIS.Dashboard.API.run.linkOptions.events.Reference";
    [self.webEnvironment addListener:self
                          forEventId:referenceLinkOptionListenerId
                            callback:^(NSDictionary *params, NSError *error) {
                                JMLog(referenceLinkOptionListenerId);
                                __typeof(self) strongSelf = weakSelf;
                                [strongSelf handleOnReferenceClick:params];
                            }];
    NSString *adHocExecutionLinkOptionListenerId = @"JasperMobile.VIS.Dashboard.API.run.linkOptions.events.AdHocExecution";
    [self.webEnvironment addListener:self forEventId:adHocExecutionLinkOptionListenerId
                            callback:^(NSDictionary *params, NSError *error) {
                                JMLog(adHocExecutionLinkOptionListenerId);
                                __typeof(self) strongSelf = weakSelf;
                                [strongSelf handleOnAdHocExecution:params];
                            }];
}

- (void)removeListenersForVisualizeEvents
{
    [self.webEnvironment removeListener:self];
}

#pragma mark - Handle JS callbacks
- (void)handleDidEndMaximazeDashletWithParameters:(NSDictionary *)parameters
{
    if (self.isCancelLoad) {
        return;
    }

    JMLog(@"parameters: %@", parameters);
    NSString *title;
    if ([JMUtils isServerAmber]) {
        title = parameters[@"componentId"];
    } else {
        title = parameters[@"component"][@"name"];
        NSString *componentId = parameters[@"component"][@"id"];
        for(JSDashboardComponent *component in self.dashboard.components) {
            if ([componentId isEqualToString:component.identifier]) {
                self.dashboard.maximizedComponent = component;
            }
        }
    }

    if ([self.delegate respondsToSelector:@selector(dashboardLoader:didEndMaximazeDashletWithTitle:)]) {
        [self.delegate dashboardLoader:self didEndMaximazeDashletWithTitle:title];
    }
}

- (void)handleOnReportExecution:(NSDictionary *)parameters
{
    if (self.isCancelLoad) {
        return;
    }

    NSString *resourceURI = parameters[@"data"][@"resource"];
    NSDictionary *params = parameters[@"data"][@"params"];

    if (resourceURI) {
        __weak typeof(self)weakSelf = self;
        [self.restClient resourceLookupForURI:resourceURI
                                 resourceType:kJS_WS_TYPE_REPORT_UNIT
                                   modelClass:[JSResourceLookup class]
                              completionBlock:^(JSOperationResult *result) {
                                  __strong typeof(self)strongSelf = weakSelf;
                                  NSError *error = result.error;
                                  if (error) {
                                      // TODO: add error handling
//                                    NSString *errorString = error.localizedDescription;
//                                    JMDashboardLoaderErrorType errorType = JMDashboardLoaderErrorTypeUndefined;
//                                    if (errorString && [errorString rangeOfString:@"unauthorized"].length) {
//                                        errorType = JMDashboardLoaderErrorTypeAuthentification;
//                                    }
                                  } else {
                                      JMLog(@"objects: %@", result.objects);
                                      JSResourceLookup *resourceLookup = [result.objects firstObject];
                                      if (resourceLookup) {
                                          resourceLookup.resourceType = kJS_WS_TYPE_REPORT_UNIT;
                                          JMResource *resource = [JMResource resourceWithResourceLookup:resourceLookup];

                                          NSArray *reportParameters = [strongSelf createReportParametersFromParameters:params];
                                          [strongSelf.delegate dashboardLoader:strongSelf
                                                   didReceiveHyperlinkWithType:JMHyperlinkTypeReportExecution
                                                                      resource:resource
                                                                    parameters:reportParameters];
                                      }
                                  }
                              }];
    } else {
        JMLog(@"parameters: %@", parameters);
    }
}

- (void)handleOnAdHocExecution:(NSDictionary *)parameters
{
    if (self.dashboard.maximizedComponent.dashletHyperlinkTarget == JSDashletHyperlinksTargetTypeBlank) {
        NSDictionary *params = parameters[@"link"][@"parameters"];
        NSString *urlString;
        for(NSString *key in params) {
            if([self.dashboard.maximizedComponent.dashletHyperlinkUrl containsString:key]) {
                NSString *fullPlaceholder = [NSString stringWithFormat:@"$P{%@}", key];
                urlString = [self.dashboard.maximizedComponent.dashletHyperlinkUrl stringByReplacingOccurrencesOfString:fullPlaceholder
                                                                                                             withString:params[key]];
                
                NSMutableArray *urlComponents = [[urlString componentsSeparatedByString:@"?"] mutableCopy];
                [urlComponents replaceObjectAtIndex:1 withObject:[[urlComponents lastObject] hostEncodedString]];
                urlString = [urlComponents componentsJoinedByString:@"?"];
            }
        }
        if (urlString) {

            [self.delegate dashboardLoader:self
               didReceiveHyperlinkWithType:JMHyperlinkTypeAdHocExecution
                                  resource:nil
                                parameters:@[[NSURL URLWithString:urlString]]];
        }
    }
}

- (void)handleOnReferenceClick:(NSDictionary *)parameters
{
    if (self.isCancelLoad) {
        return;
    }

    NSString *URLString = parameters[@"location"];
    if (URLString) {
        [self.delegate dashboardLoader:self
           didReceiveHyperlinkWithType:JMHyperlinkTypeReference
                              resource:nil
                            parameters:@[[NSURL URLWithString:URLString]]];
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