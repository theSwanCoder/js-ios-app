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
#import "JMVisualizeManager.h"
#import "JMDashboard.h"
#import "JMWebEnvironment.h"

@interface JMVisDashboardLoader() <JMJavascriptNativeBridgeDelegate>
@property (nonatomic, weak) JMDashboard *dashboard;
@property (nonatomic, weak) JMWebEnvironment *webEnvironment;
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
        _dashboard = dashboard;
        _visualizeManager = [JMVisualizeManager new];
        _webEnvironment = webEnvironment;
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
    [self addListenersForVisualizeEvents];

    JMDashboardLoaderCompletion heapBlock = [completion copy];
    __weak __typeof(self) weakSelf = self;
    [self.webEnvironment verifyEnvironmentReadyWithCompletion:^(BOOL isWebViewLoaded) {
        __typeof(self) strongSelf = weakSelf;
        if (isWebViewLoaded) {
            [strongSelf handleDOMContentLoadedWithCompletion:heapBlock];
        } else {
            __weak __typeof(self) weakSelf = strongSelf;
            [strongSelf startLoadHTMLWithCompletion:^(BOOL success, NSError *error) {
                __typeof(self) strongSelf = weakSelf;
                if (success) {
                    // load vis into web environment
                    JMJavascriptRequest *requireJSLoadRequest = [JMJavascriptRequest requestWithCommand:@"JasperMobile.Helper.loadScript"
                                                                                             parameters:@{
                                                                                                     @"scriptURL" : strongSelf.visualizeManager.visualizePath,
                                                                                             }];
                    [strongSelf.webEnvironment sendJavascriptRequest:requireJSLoadRequest
                                                          completion:^(NSDictionary *params, NSError *error) {
                                                              if (error) {
                                                                  JMLog(@"error: %@", error);
                                                              } else {
                                                                  [strongSelf handleDOMContentLoadedWithCompletion:heapBlock];
                                                              }
                                                          }];
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
    [self.webEnvironment sendJavascriptRequest:request completion:^(NSDictionary *parameters, NSError *error) {
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
    [self.webEnvironment sendJavascriptRequest:request completion:^(NSDictionary *parameters, NSError *error) {
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
    [self.webEnvironment sendJavascriptRequest:applyParamsRequest completion:^(NSDictionary *parameters, NSError *error) {
        if (error) {
            heapBlock(NO, error);
        } else {
//            JMLog(@"callback: %@", callback);
            heapBlock(YES, nil);
        }
    }];
}

- (void)applyParameters:(NSDictionary *)parameters
{
    // TODO: replace received parameter for dictionary
    JMLog(@"%@", NSStringFromSelector(_cmd));
    JMJavascriptRequest *applyParamsRequest = [JMJavascriptRequest requestWithCommand:@"JasperMobile.Dashboard.API.applyParams"
                                                                           parameters:parameters];
    [self.webEnvironment sendJavascriptRequest:applyParamsRequest completion:^(NSDictionary *parameters, NSError *error) {
        if (error) {
            JMLog(@"error: %@", error);
        } else {
            JMLog(@"parameters: %@", parameters);
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

- (void)maximizeDashletForComponent:(JSDashboardComponent *__nonnull)component
{
    JMJavascriptRequest *request = [JMJavascriptRequest requestWithCommand:@"JasperMobile.Dashboard.API.maximizeDashlet"
                                                                parameters:@{
                                                                        @"identifier" : component != nil ? component.identifier : @"null"
                                                                }];
    [self.webEnvironment sendJavascriptRequest:request completion:^(NSDictionary *parameters, NSError *error) {
        if (error) {
            JMLog(@"error: %@", error);
        } else {
            JMLog(@"parameters: %@", parameters);
        }
    }];
}

- (void)minimizeDashletForComponent:(JSDashboardComponent *__nonnull)component
{
    JMJavascriptRequest *request = [JMJavascriptRequest requestWithCommand:@"JasperMobile.Dashboard.API.minimizeDashlet"
                                                                parameters:@{
                                                                        @"identifier" : component != nil ? component.identifier : @"null"
                                                                }];
    __weak __typeof(self) weakSelf = self;
    [self.webEnvironment sendJavascriptRequest:request completion:^(NSDictionary *parameters, NSError *error) {
        __typeof(self) strongSelf = weakSelf;
        if (error) {
            JMLog(@"error: %@", error);
        } else {
            JMLog(@"parameters: %@", parameters);
            strongSelf.dashboard.maximizedComponent = nil;
        }
    }];
}

- (void)minimizeDashlet
{
    [self minimizeDashletForComponent:nil];
}

- (void)updateViewportScaleFactorWithValue:(CGFloat)scaleFactor
{
    BOOL isInitialScaleFactorSet = self.visualizeManager.viewportScaleFactor > 0.01;
    BOOL isInitialScaleFactorTheSame = fabs(self.visualizeManager.viewportScaleFactor - scaleFactor) >= 0.49;
    if ( !isInitialScaleFactorSet || isInitialScaleFactorTheSame ) {
        self.visualizeManager.viewportScaleFactor = scaleFactor;
        JMJavascriptRequest *request = [JMJavascriptRequest requestWithCommand:@"JasperMobile.Helper.updateViewPortInitialScale"
                                                                    parameters:@{
                                                                            @"scale" : @(scaleFactor)
                                                                    }];
        [self.webEnvironment sendJavascriptRequest:request completion:nil];
    }
}

#pragma mark - Private API
- (void)destroyDashboard
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    JMJavascriptRequest *request = [JMJavascriptRequest new];
    request.command = @"JasperMobile.Dashboard.API.destroy";
    [self.webEnvironment sendJavascriptRequest:request completion:^(NSDictionary *parameters, NSError *error) {
        // Need capture self to wait until this request finishes
        [self.webEnvironment removeAllListeners];
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
    JMJavascriptRequest *request = [JMJavascriptRequest new];
    request.command = @"JasperMobile.Dashboard.API.cancel";
    [self.webEnvironment sendJavascriptRequest:request completion:^(NSDictionary *parameters, NSError *error) {
        if (error) {
            JMLog(@"error: %@", error);
        } else {
            JMLog(@"parameters: %@", parameters);
        }
    }];
}

#pragma mark - Helpers
- (void)startLoadHTMLWithCompletion:(JMDashboardLoaderCompletion __nonnull)completion
{
    JMLog(@"visuzalise.js did start load");
    JMDashboardLoaderCompletion heapBlock = [completion copy];
    __weak __typeof(self) weakSelf = self;
    [self.visualizeManager loadVisualizeJSWithCompletion:^(BOOL success, NSError *error){
        __typeof(self) strongSelf = weakSelf;
        if (success) {
            JMLog(@"visuzalise.js did end load");
            NSString *baseURLString = strongSelf.restClient.serverProfile.serverUrl;
            NSString *htmlString = [strongSelf.visualizeManager htmlString];
            [strongSelf.webEnvironment loadHTML:htmlString
                                        baseURL:[NSURL URLWithString:baseURLString]
                                     completion:heapBlock];
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
    [self.webEnvironment addListenerWithId:dashletWillMaximizeListenerId callback:^(NSDictionary *parameters, NSError *error) {
        JMLog(@"JasperMobile.Dashboard.API.events.dashlet.willMaximize");
    }];

    NSString *dashletDidMaximizeListenerId = @"JasperMobile.Dashboard.API.events.dashlet.didMaximize";
    [self.webEnvironment addListenerWithId:dashletDidMaximizeListenerId callback:^(NSDictionary *parameters, NSError *error) {
        JMLog(@"JasperMobile.Dashboard.API.events.dashlet.didMaximize");
        __typeof(self) strongSelf = weakSelf;
        [strongSelf handleDidStartMaximazeDashletWithParameters:parameters];
    }];

    NSString *dashletDidMaximizeFailedListenerId = @"JasperMobile.Dashboard.API.events.dashlet.didMaximize.failed";
    [self.webEnvironment addListenerWithId:dashletDidMaximizeFailedListenerId callback:^(NSDictionary *parameters, NSError *error) {
        JMLog(@"JasperMobile.Dashboard.API.events.dashlet.didMaximize.failed");
        [JMUtils presentAlertControllerWithError:error
                                      completion:nil];
    }];

    // Links
    NSString *reportExecutionLinkOptionListenerId = @"JasperMobile.Dashboard.API.run.linkOptions.events.ReportExecution";
    [self.webEnvironment addListenerWithId:reportExecutionLinkOptionListenerId callback:^(NSDictionary *parameters, NSError *error) {
        JMLog(@"JasperMobile.Report.API.run.linkOptions.events.ReportExecution");
        __typeof(self) strongSelf = weakSelf;
        [strongSelf handleOnReportExecution:parameters];
    }];
    NSString *referenceLinkOptionListenerId = @"JasperMobile.Dashboard.API.run.linkOptions.events.Reference";
    [self.webEnvironment addListenerWithId:referenceLinkOptionListenerId callback:^(NSDictionary *parameters, NSError *error) {
        JMLog(@"JasperMobile.Report.API.run.linkOptions.events.Reference");
        __typeof(self) strongSelf = weakSelf;
        [strongSelf handleOnReferenceClick:parameters];
    }];
    NSString *adHocExecutionLinkOptionListenerId = @"JasperMobile.Dashboard.API.run.linkOptions.events.AdHocExecution";
    [self.webEnvironment addListenerWithId:adHocExecutionLinkOptionListenerId callback:^(NSDictionary *parameters, NSError *error) {
        JMLog(@"JasperMobile.Dashboard.API.run.linkOptions.events.AdHocExecution");
        __typeof(self) strongSelf = weakSelf;
        [strongSelf handleOnAdHocExecution:parameters];
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

    if (!request.URL.host) {
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
    JMJavascriptRequest *runRequest = [JMJavascriptRequest requestWithCommand:@"JasperMobile.Dashboard.API.runDashboard"
                                                                   parameters:@{
                                                                           @"uri" : self.dashboard.resourceURI,
                                                                           @"is_for_6_0" : @([JMUtils isServerAmber]),
                                                                   }];
    runRequest.command = @"JasperMobile.Dashboard.API.runDashboard";
    [self.webEnvironment sendJavascriptRequest:runRequest completion:^(NSDictionary *parameters, NSError *error) {
        if (error) {
            heapBlock(NO, error);
        } else {
            heapBlock(YES, nil);
        }
    }];
}

- (void)handleDidStartMaximazeDashletWithParameters:(NSDictionary *)parameters
{
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
    [self.delegate dashboardLoader:self didStartMaximazeDashletWithTitle:title];
}

- (void)handleOnReportExecution:(NSDictionary *)parameters
{
    NSString *resource = parameters[@"data"][@"resource"];
    NSDictionary *params = parameters[@"data"][@"params"];

    if (resource) {
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
    } else {

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
                break;
            }
        }
        if (urlString) {
            [self.delegate dashboardLoader:self
               didReceiveHyperlinkWithType:JMHyperlinkTypeReference
                            resourceLookup:nil
                                parameters:@[[NSURL URLWithString:urlString]]];
        }
    }
}

- (void)handleOnReferenceClick:(NSDictionary *)parameters
{
    NSString *URLString = parameters[@"location"];
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

@end