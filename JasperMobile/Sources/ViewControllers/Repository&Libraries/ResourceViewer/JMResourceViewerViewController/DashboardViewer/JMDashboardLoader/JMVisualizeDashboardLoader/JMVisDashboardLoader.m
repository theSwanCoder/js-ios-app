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
#import "JMJavascriptNativeBridge.h"
#import "JMJavascriptCallback.h"
#import "JMVisualizeManager.h"
#import "JMJavascriptRequest.h"
#import "JMDashboardLoader.h"
#import "JMDashboard.h"
#import "JMWebViewManager.h"
#import "JMDashlet.h"
#import "JMDashboardParameter.h"

@interface JMVisDashboardLoader() <JMJavascriptNativeBridgeDelegate>
@property (nonatomic, weak) JMDashboard *dashboard;
//@property (nonatomic, copy) JMDashboardLoaderCompletion completion;
@property (nonatomic, copy) NSURL *externalURL;
@end

@implementation JMVisDashboardLoader
@synthesize bridge = _bridge, delegate = _delegate;

- (void)dealloc
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
}

- (void)setBridge:(JMJavascriptNativeBridge *)bridge
{
    _bridge = bridge;
    _bridge.delegate = self;
}

#pragma mark - Initializers
- (instancetype)initWithDashboard:(JMDashboard *)dashboard
{
    self = [super init];
    if (self) {
        _dashboard = dashboard;
    }
    return self;
}

+ (instancetype)loaderWithDashboard:(JMDashboard *)dashboard
{
    return [[self alloc] initWithDashboard:dashboard];
}


#pragma mark - Public API
- (void)loadDashboardWithCompletion:(JMDashboardLoaderCompletion) completion
{
    [self addListenersForVisualizeEvents];

    JMDashboardLoaderCompletion heapBlock = [completion copy];
    [[JMWebViewManager sharedInstance] isWebViewLoadedVisualize:self.bridge.webView completion:^(BOOL isWebViewLoaded) {
        if (isWebViewLoaded) {
            [self handleDOMContentLoadedWithCompletion:heapBlock];
        } else {
            [self startLoadHTMLWithCompletion:^(BOOL success, NSError *error) {
                if (success) {
                    [self handleDOMContentLoadedWithCompletion:heapBlock];
                } else {
                    NSLog(@"Error loading HTML%@", error.localizedDescription);
                }
            }];
        }
    }];
}

- (void)reloadDashboardWithCompletion:(JMDashboardLoaderCompletion) completion
{
    JMDashboardLoaderCompletion heapBlock = [completion copy];

    JMJavascriptRequest *request = [JMJavascriptRequest new];
    request.command = @"JasperMobile.Dashboard.API.refresh";
    [self.bridge sendJavascriptRequest:request completion:^(JMJavascriptCallback *callback, NSError *error) {
        if (error) {
            heapBlock(NO, error);
        } else {
//            JMLog(@"callback: %@", callback);
            heapBlock(YES, nil);
        }
    }];
}

- (void)reloadMaximizedDashletWithCompletion:(JMDashboardLoaderCompletion) completion
{
    JMDashboardLoaderCompletion heapBlock = [completion copy];

    JMJavascriptRequest *request = [JMJavascriptRequest new];
    request.command = @"JasperMobile.Dashboard.API.refreshDashlet";
    [self.bridge sendJavascriptRequest:request completion:^(JMJavascriptCallback *callback, NSError *error) {
        if (error) {
            heapBlock(NO, error);
        } else {
//            JMLog(@"callback: %@", callback);
            heapBlock(YES, nil);
        }
    }];
}

- (void)fetchParametersWithCompletion:(JMDashboardLoaderCompletion) completion
{
    JMDashboardLoaderCompletion heapBlock = [completion copy];

    JMJavascriptRequest *applyParamsRequest = [JMJavascriptRequest new];
    applyParamsRequest.command = @"JasperMobile.Dashboard.API.getDashboardParameters";
    [self.bridge sendJavascriptRequest:applyParamsRequest completion:^(JMJavascriptCallback *callback, NSError *error) {
        if (error) {
            heapBlock(NO, error);
        } else {
//            JMLog(@"callback: %@", callback);
            heapBlock(YES, nil);
        }
    }];
}

- (void)applyParameters:(NSString *)parametersAsString
{
    JMLog(@"%@", NSStringFromSelector(_cmd));
    JMJavascriptRequest *applyParamsRequest = [JMJavascriptRequest new];
    applyParamsRequest.command = @"JasperMobile.Dashboard.API.applyParams";

    applyParamsRequest.parametersAsString = parametersAsString;
    [self.bridge sendJavascriptRequest:applyParamsRequest completion:^(JMJavascriptCallback *callback, NSError *error) {
        if (error) {
            JMLog(@"error: %@", error);
        } else {
            JMLog(@"callback: %@", callback);
        }
    }];
}

- (void)cancel
{
    [self cancelDashboard];
}

- (void)destroy
{
    [self destroyDashboard];
}

- (void)maximizeDashlet:(JMDashlet *)dashlet
{
    JMLog(@"%@", NSStringFromSelector(_cmd));
    JMJavascriptRequest *request = [JMJavascriptRequest new];
    request.command = @"JasperMobile.Dashboard.API.maximizeDashlet";
    request.parametersAsString = dashlet.identifier;
    [self.bridge sendJavascriptRequest:request completion:^(JMJavascriptCallback *callback, NSError *error) {
        if (error) {
            JMLog(@"error: %@", error);
        } else {
            JMLog(@"callback: %@", callback);
        }
    }];
}

- (void)minimizeDashlet:(JMDashlet *)dashlet
{
    JMLog(@"%@", NSStringFromSelector(_cmd));
    JMJavascriptRequest *request = [JMJavascriptRequest new];
    request.command = @"JasperMobile.Dashboard.API.minimizeDashlet";
    request.parametersAsString = dashlet.identifier;
    [self.bridge sendJavascriptRequest:request completion:^(JMJavascriptCallback *callback, NSError *error) {
        if (error) {
            JMLog(@"error: %@", error);
        } else {
            JMLog(@"callback: %@", callback);
        }
    }];
}

- (void)minimizeDashlet
{
    JMJavascriptRequest *request = [JMJavascriptRequest new];
    request.command = @"JasperMobile.Dashboard.API.minimizeDashlet";
    [self.bridge sendJavascriptRequest:request completion:^(JMJavascriptCallback *callback, NSError *error) {
        if (error) {
            JMLog(@"error: %@", error);
        } else {
            JMLog(@"callback: %@", callback);
        }
    }];
}

- (void)updateViewportScaleFactorWithValue:(CGFloat)scaleFactor
{
    BOOL isInitialScaleFactorSet = self.visualizeManager.viewportScaleFactor > 0.01;
    BOOL isInitialScaleFactorTheSame = fabs(self.visualizeManager.viewportScaleFactor - scaleFactor) >= 0.49;
    if ( !isInitialScaleFactorSet || isInitialScaleFactorTheSame ) {
        self.visualizeManager.viewportScaleFactor = scaleFactor;

        JMJavascriptRequest *request = [JMJavascriptRequest new];
        request.command = @"JasperMobile.Helper.updateViewPortInitialScale";
        request.parametersAsString = [NSString stringWithFormat:@"%@", @(scaleFactor)];
        [self.bridge sendJavascriptRequest:request completion:nil];
    }
}

#pragma mark - Private API
- (void)destroyDashboard
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    JMJavascriptRequest *request = [JMJavascriptRequest new];
    request.command = @"JasperMobile.Dashboard.API.destroy";
    [self.bridge sendJavascriptRequest:request completion:^(JMJavascriptCallback *callback, NSError *error) {
        if (error) {
            JMLog(@"error: %@", error);
        } else {
            JMLog(@"callback: %@", callback);
        }
    }];
}

- (void)cancelDashboard
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    JMJavascriptRequest *request = [JMJavascriptRequest new];
    request.command = @"JasperMobile.Dashboard.API.cancel";
    [self.bridge sendJavascriptRequest:request completion:^(JMJavascriptCallback *callback, NSError *error) {
        if (error) {
            JMLog(@"error: %@", error);
        } else {
            JMLog(@"callback: %@", callback);
        }
    }];
}

#pragma mark - Helpers
- (void)startLoadHTMLWithCompletion:(JMDashboardLoaderCompletion __nonnull)completion
{
    JMLog(@"visuzalise.js did start load");
    JMDashboardLoaderCompletion heapBlock = [completion copy];
    [self.visualizeManager loadVisualizeJSWithCompletion:^(BOOL success, NSError *error){
            if (success) {
                JMLog(@"visuzalise.js did end load");
                NSString *baseURLString = self.restClient.serverProfile.serverUrl;
                NSString *htmlString = [self.visualizeManager htmlStringForDashboard];
                [self.bridge startLoadHTMLString:htmlString
                                         baseURL:[NSURL URLWithString:baseURLString]
                                      completion:^(JMJavascriptCallback *callback, NSError *error) {
                                          if (error) {
                                              heapBlock(NO, error);
                                          } else {
                                              heapBlock(YES, nil);
                                          }
                                      }];
            } else {
                // TODO: handle this error
                JMLog(@"Error loading visualize.js");
                // TODO: add error code
                error = [NSError errorWithDomain:kJMReportLoaderErrorDomain
                                            code:0
                                        userInfo:nil];
                completion(NO, error);
            }
        }];
}

- (void)addListenersForVisualizeEvents
{
    NSString *dashletWillMaximizeListenerId = @"JasperMobile.Dashboard.API.events.dashlet.willMaximize";
    __weak __typeof(self) weakSelf = self;
    [self.bridge addListenerWithId:dashletWillMaximizeListenerId callback:^(JMJavascriptCallback *callback, NSError *error) {
        JMLog(@"JasperMobile.Dashboard.API.events.dashlet.willMaximize");
    }];

    NSString *dashletDidMaximizeListenerId = @"JasperMobile.Dashboard.API.events.dashlet.didMaximize";
    [self.bridge addListenerWithId:dashletDidMaximizeListenerId callback:^(JMJavascriptCallback *callback, NSError *error) {
        JMLog(@"JasperMobile.Report.API.run.reportCompleted");
        __typeof(self) strongSelf = weakSelf;
        [strongSelf handleDidStartMaximazeDashletWithParameters:callback.parameters];
    }];

    NSString *dashletDidMaximizeFailedListenerId = @"JasperMobile.Dashboard.API.events.dashlet.didMaximize.failed";
    [self.bridge addListenerWithId:dashletDidMaximizeFailedListenerId callback:^(JMJavascriptCallback *callback, NSError *error) {
        JMLog(@"JasperMobile.Dashboard.API.events.dashlet.didMaximize.failed");
    }];

    // Links
    NSString *reportExecutionLinkOptionListenerId = @"JasperMobile.Dashboard.API.run.linkOptions.events.ReportExecution";
    [self.bridge addListenerWithId:reportExecutionLinkOptionListenerId callback:^(JMJavascriptCallback *callback, NSError *error) {
        JMLog(@"JasperMobile.Report.API.run.linkOptions.events.ReportExecution");
        __typeof(self) strongSelf = weakSelf;
        [strongSelf handleOnReportExecution:callback.parameters];
    }];
    NSString *referenceLinkOptionListenerId = @"JasperMobile.Dashboard.API.run.linkOptions.events.Reference";
    [self.bridge addListenerWithId:referenceLinkOptionListenerId callback:^(JMJavascriptCallback *callback, NSError *error) {
        JMLog(@"JasperMobile.Report.API.run.linkOptions.events.Reference");
        __typeof(self) strongSelf = weakSelf;
        [strongSelf handleOnReferenceClick:callback.parameters];
    }];
    NSString *adHocExecutionLinkOptionListenerId = @"JasperMobile.Dashboard.API.run.linkOptions.events.AdHocExecution";
    [self.bridge addListenerWithId:adHocExecutionLinkOptionListenerId callback:^(JMJavascriptCallback *callback, NSError *error) {
        JMLog(@"JasperMobile.Report.API.run.linkOptions.events.ReportExecution");
        __typeof(self) strongSelf = weakSelf;
        [strongSelf handleOnAdHocExecution:callback.parameters];
    }];
}

#pragma mark - JMJavascriptNativeBridgeDelegate
- (void)javascriptNativeBridgeDidReceiveAuthRequest:(JMJavascriptNativeBridge *)bridge
{
//    if (self.completion) {
//        // TODO: Need add auth error
//        self.completion(NO, nil);
//    }
    [self.delegate dashboardLoaderDidReceiveAuthRequest:self];
}

- (BOOL)javascriptNativeBridge:(JMJavascriptNativeBridge *)bridge shouldLoadExternalRequest:(NSURLRequest *)request
{
    BOOL shouldLoad = NO;
    // TODO: verify all cases

    if (request.URL.host) {
        self.externalURL = request.URL;
        shouldLoad = NO;
    } else {
        // Request for cleaning webview
        if ([request.URL.absoluteString isEqualToString:@"about:blank"]) {
            shouldLoad = YES;
        }
    }

    return shouldLoad;
}

- (void)javascriptNativeBridge:(JMJavascriptNativeBridge *__nonnull)bridge didReceiveOnWindowError:(NSError *__nonnull)error
{
    // TODO: add handle this error
//    [self.bridge reset];
    JMLog(@"error: %@", error);
}

#pragma mark - Handle JS callbacks
- (void)handleDOMContentLoadedWithCompletion:(JMDashboardLoaderCompletion __nonnull)completion
{
    JMDashboardLoaderCompletion heapBlock = [completion copy];
    // run
    JMJavascriptRequest *runRequest = [JMJavascriptRequest new];
    runRequest.command = @"JasperMobile.Dashboard.API.run";
    NSString *runParameters = [NSString stringWithFormat:@"{'uri': '%@'}", self.dashboard.resourceURI];
    runRequest.parametersAsString = runParameters;
    [self.bridge sendJavascriptRequest:runRequest completion:^(JMJavascriptCallback *callback, NSError *error) {
        if (error) {
            heapBlock(NO, error);
        } else {
//            JMLog(@"callback: %@", callback);
            [self handleOnLoadDoneWithParameters:callback.parameters];
            heapBlock(YES, nil);
        }
    }];
}

- (void)handleOnLoadDoneWithParameters:(NSDictionary *)parameters
{
    // Components
    NSArray *rawComponents = parameters[@"components"];
    NSMutableArray *dashlets = [NSMutableArray array];
    for (NSDictionary *rawComponent in rawComponents) {
        JMDashlet *dashlet = [self parseComponentsFromData:rawComponent];
        if (dashlet) {
            [dashlets addObject:dashlet];
        }
    }
    self.dashboard.dashlets = [dashlets copy];
}

- (void)handleDidStartMaximazeDashletWithParameters:(NSDictionary *)parameters
{
    JMLog(@"parameters: %@", parameters);
    NSString *title = parameters[@"component"][@"name"];
    [self.delegate dashboardLoader:self didStartMaximazeDashletWithTitle:title];
}

- (void)handleOnReportExecution:(NSDictionary *)parameters
{
    NSString *resource = parameters[@"resource"];
    NSDictionary *params = parameters[@"params"];

    __weak typeof(self)weakSelf = self;
    [self.restClient resourceLookupForURI:resource
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

                                        NSArray *reportParameters = [strongSelf createReportParametersFromParameters:params];
                                        [strongSelf.delegate dashboardLoader:strongSelf
                                                 didReceiveHyperlinkWithType:JMHyperlinkTypeReportExecution
                                                              resourceLookup:resourceLookup
                                                                  parameters:reportParameters];
                                    }
                                }
    }];

}

- (void)handleOnAdHocExecution:(NSDictionary *)parameters
{
    if (self.externalURL) {
        [self.delegate dashboardLoader:self
           didReceiveHyperlinkWithType:JMHyperlinkTypeReference
                        resourceLookup:nil
                            parameters:@[self.externalURL]];
    }
}

- (void)handleOnReferenceClick:(NSDictionary *)parameters
{
    NSString *URLString = parameters[@"href"];
    if (URLString) {
        [self.delegate dashboardLoader:self
           didReceiveHyperlinkWithType:JMHyperlinkTypeReference
                        resourceLookup:nil
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

- (JMDashlet *)parseComponentsFromData:(NSDictionary *)rawData
{
    NSString *type = rawData[@"type"];

    if ([type isEqualToString:@"inputControl"]) {
        return nil;
    }

    JMDashlet *dashlet = [JMDashlet new];
    dashlet.identifier = rawData[@"id"];
    NSNumber *rawInterective = (NSNumber *) rawData[@"interactive"];
    dashlet.interactive = [rawInterective isKindOfClass:[NSNull class]] ? NO : rawInterective.boolValue;
    NSNumber *rawMaximized = (NSNumber *) rawData[@"maximized"];
    dashlet.maximized = [rawMaximized isKindOfClass:[NSNull class]] ? NO : rawMaximized.boolValue;
    dashlet.name = rawData[@"name"];
    if ([type isEqualToString:@"value"]) {
        dashlet.type = JMDashletTypeValue;
    } else if ([type isEqualToString:@"chart"]) {
        dashlet.type = JMDashletTypeChart;
    } else if ([type isEqualToString:@"filterGroup"]) {
        dashlet.type = JMDashletTypeFilterGroup;
    } else if ([type isEqualToString:@"reportUnit"]) {
        dashlet.type = JMDashletTypeReportUnit;
    } else if ([type isEqualToString:@"adhocDataView"]) {
        dashlet.type = JMDashletTypeAdhocView;
    } else if ([type isEqualToString:@"image"]) {
        dashlet.type = JMDashletTypeImage;
    }
    return dashlet;
}

@end