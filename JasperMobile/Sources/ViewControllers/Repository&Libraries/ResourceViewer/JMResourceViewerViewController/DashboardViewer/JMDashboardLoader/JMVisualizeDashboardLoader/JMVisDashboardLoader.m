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
@property (nonatomic, copy) JMDashboardLoaderCompletion completion;
@property (nonatomic, copy) NSURL *externalURL;
@end

@implementation JMVisDashboardLoader
@synthesize bridge = _bridge, delegate = _delegate;

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
    self.completion = completion;

    if ([[JMWebViewManager sharedInstance] isWebViewEmpty:self.bridge.webView]) {

        [self startLoadHTMLWithCompletion:^(BOOL success, NSError *error) {
            if (success) {

            } else {
                NSLog(@"Error loading HTML%@", error.localizedDescription);
            }
        }];
    } else {
        [self handleOnScriptLoaded];
    }
}

- (void)reloadDashboardWithCompletion:(JMDashboardLoaderCompletion) completion
{
    self.completion = completion;

    JMJavascriptRequest *request = [JMJavascriptRequest new];
    request.command = @"MobileDashboard.refresh();";
    request.parametersAsString = @"";
    [self.bridge sendRequest:request];
}

- (void)reloadMaximizedDashletWithCompletion:(JMDashboardLoaderCompletion) completion
{
    self.completion = completion;

    JMJavascriptRequest *request = [JMJavascriptRequest new];
    request.command = @"MobileDashboard.refreshDashlet();";
    request.parametersAsString = @"";
    [self.bridge sendRequest:request];
}

- (void)fetchParametersWithCompletion:(JMDashboardLoaderCompletion) completion
{
    self.completion = completion;

    JMJavascriptRequest *applyParamsRequest = [JMJavascriptRequest new];
    applyParamsRequest.command = @"MobileDashboard.getDashboardParameters();";
    [self.bridge sendRequest:applyParamsRequest];
}

- (void)applyParameters:(NSString *)parametersAsString
{
    JMLog(@"%@", NSStringFromSelector(_cmd));
    JMJavascriptRequest *applyParamsRequest = [JMJavascriptRequest new];
    applyParamsRequest.command = @"MobileDashboard.applyParams(%@);";

    applyParamsRequest.parametersAsString = parametersAsString;
    [self.bridge sendRequest:applyParamsRequest];
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
    request.command = @"MobileDashboard.maximizeDashlet(\"%@\");";
    request.parametersAsString = dashlet.identifier;
    [self.bridge sendRequest:request];
}

- (void)minimizeDashlet:(JMDashlet *)dashlet
{
    JMLog(@"%@", NSStringFromSelector(_cmd));
    JMJavascriptRequest *request = [JMJavascriptRequest new];
    request.command = @"MobileDashboard.minimizeDashlet(\"%@\");";
    request.parametersAsString = dashlet.identifier;
    [self.bridge sendRequest:request];
}

- (void)minimizeDashlet
{
    JMJavascriptRequest *request = [JMJavascriptRequest new];
    request.command = @"MobileDashboard.minimizeDashlet();";
    [self.bridge sendRequest:request];
}

- (void)updateViewportScaleFactorWithValue:(CGFloat)scaleFactor
{
    BOOL isInitialScaleFactorSet = self.visualizeManager.viewportScaleFactor > 0.01;
    BOOL isInitialScaleFactorTheSame = fabs(self.visualizeManager.viewportScaleFactor - scaleFactor) >= 0.49;
    if ( !isInitialScaleFactorSet || isInitialScaleFactorTheSame ) {
        self.visualizeManager.viewportScaleFactor = scaleFactor;

        JMJavascriptRequest *request = [JMJavascriptRequest new];
        request.command = @"JasperMobile.Helper.updateViewPortInitialScale(%@);";
        request.parametersAsString = [NSString stringWithFormat:@"%@", @(scaleFactor)];
        [self.bridge sendRequest:request];
    }
}

#pragma mark - Private API
- (void)destroyDashboard
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    JMJavascriptRequest *request = [JMJavascriptRequest new];
    request.command = @"MobileDashboard.destroy();";
    request.parametersAsString = @"";
    [self.bridge sendRequest:request];
}

- (void)cancelDashboard
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    JMJavascriptRequest *request = [JMJavascriptRequest new];
    request.command = @"MobileDashboard.cancel();";
    request.parametersAsString = @"";
    [self.bridge sendRequest:request];
}

#pragma mark - Helpers
- (void)startLoadHTMLWithCompletion:(void(^)(BOOL success, NSError *error))completion
{
    JMLog(@"visuzalise.js did start load");
    [self.visualizeManager loadVisualizeJSWithCompletion:^(BOOL success, NSError *error){
            if (success) {
                JMLog(@"visuzalise.js did end load");
                NSString *baseURLString = self.restClient.serverProfile.serverUrl;
                NSString *htmlString = [self.visualizeManager htmlStringForDashboard];
                [self.bridge startLoadHTMLString:htmlString
                                         baseURL:[NSURL URLWithString:baseURLString]];

                if (completion) {
                    completion(YES, nil);
                }
            } else {
                // TODO: handle this error
                JMLog(@"Error loading visualize.js");
                // TODO: add error code
                error = [NSError errorWithDomain:kJMReportLoaderErrorDomain
                                                     code:0
                                                 userInfo:nil];
                if (completion) {
                    completion(NO, error);
                }
            }
        }];
}

#pragma mark - JMJavascriptNativeBridgeDelegate
- (void)javascriptNativeBridge:(id <JMJavascriptNativeBridgeProtocol>)bridge didReceiveCallback:(JMJavascriptCallback *)callback
{
    if ([callback.type isEqualToString:@"DOMContentLoaded"]) {
        [self handleOnScriptLoaded];
    } else if ([callback.type isEqualToString:@"dashletWillMaximize"]) {
        [self handleDidStartMaximazeDashletWithParameters:callback.parameters[@"parameters"]];
    }  else if ([callback.type isEqualToString:@"dashletDidMaximize"]) {
        // TODO: add handling end of maximazing
    }  else if ([callback.type isEqualToString:@"dashletFailedMaximize"]) {
        // TODO: add handling mazimize error
    } else if ([callback.type isEqualToString:@"onLoadDone"]) {
        [self handleOnLoadDoneWithParameters:callback.parameters[@"parameters"]];
    } else if ([callback.type isEqualToString:@"onReportExecution"]) {
        [self handleOnReportExecution:callback.parameters[@"parameters"]];
    } else if ([callback.type isEqualToString:@"onAdHocExecution"]) {
        [self handleOnAdHocExecution:callback.parameters[@"parameters"]];
    } else if ([callback.type isEqualToString:@"onReferenceClick"]) {
        [self handleOnReferenceClick:callback.parameters[@"parameters"]];
    } else if ([callback.type isEqualToString:@"onAuthError"]) {
        [self javascriptNativeBridgeDidReceiveAuthRequest:self.bridge];
    } else if ([callback.type isEqualToString:@"dashboardParameters"]) {
        [self handleDidFetchDashboardParameters:callback.parameters[@"parameters"]];
    } else if ([callback.type isEqualToString:@"onWindowError"]) {
        JMLog(@"callback.parameters: %@", callback.parameters);
        [self.bridge reset];
        // waiting for resetting of webview
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self loadDashboardWithCompletion:self.completion];
        });
    } else {
        JMLog(@"callback type: %@", callback.type);
        JMLog(@"callback parameters: %@", callback.parameters[@"parameters"]);
    }
}

- (void)javascriptNativeBridgeDidReceiveAuthRequest:(id <JMJavascriptNativeBridgeProtocol>)bridge
{
    if (self.completion) {
        // TODO: Need add auth error
        self.completion(NO, nil);
    }
    [self.delegate dashboardLoaderDidReceiveAuthRequest:self];
}

- (BOOL)javascriptNativeBridge:(id<JMJavascriptNativeBridgeProtocol>)bridge shouldLoadExternalRequest:(NSURLRequest *)request
{
    BOOL shouldLoad = NO;
    // TODO: verify all cases

    if (request.URL.host) {
        self.externalURL = request.URL;
        shouldLoad = YES;
    } else {
        // Request for cleaning webview
        if ([request.URL.absoluteString isEqualToString:@"about:blank"]) {
            shouldLoad = YES;
        }
    }

    return shouldLoad;
}

#pragma mark - Handle JS callbacks
- (void)handleOnScriptLoaded
{
    // run
    JMJavascriptRequest *runRequest = [JMJavascriptRequest new];
    runRequest.command = @"MobileDashboard.run(%@);";
    NSString *runParameters = [NSString stringWithFormat:@"{'uri': '%@'}", self.dashboard.resourceURI];
    runRequest.parametersAsString = runParameters;
    [self.bridge sendRequest:runRequest];
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

    if (self.completion) {
        self.completion(YES, nil);
    }
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

- (void)handleDidFetchDashboardParameters:(NSDictionary *)parameters
{
    JMLog(@"%@", NSStringFromSelector(_cmd));
    JMLog(@"parameters: %@", parameters);
    if (self.completion) {
        // TODO: complete
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
    }
    return dashlet;
}

@end