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

@interface JMVisDashboardLoader() <JMJavascriptNativeBridgeDelegate>
@property (nonatomic, weak) JMDashboard *dashboard;
@property (nonatomic, copy) void(^loadCompletion)(BOOL success, NSError *error);
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
    self.loadCompletion = completion;

    if ([[JMVisualizeWebViewManager sharedInstance] isWebViewEmpty:self.bridge.webView]) {

        [self startLoadHTMLWithCompletion:^(BOOL success, NSError *error) {
            if (success) {

            } else {
                NSLog(@"Error loading HTML%@", error.localizedDescription);
            }
        }];
    } else {
        [self destroyDashboard];
        [self handleOnScriptLoaded];
    }
}

- (void)reloadDashboardWithCompletion:(JMDashboardLoaderCompletion) completion
{
    self.loadCompletion = completion;

    JMJavascriptRequest *request = [JMJavascriptRequest new];
    request.command = @"MobileDashboard.refresh();";
    request.parametersAsString = @"";
    [self.bridge sendRequest:request];
}

- (void)reloadMaximizedDashletWithCompletion:(JMDashboardLoaderCompletion) completion
{
    self.loadCompletion = completion;

    JMJavascriptRequest *request = [JMJavascriptRequest new];
    request.command = @"MobileDashboard.refreshDashlet();";
    request.parametersAsString = @"";
    [self.bridge sendRequest:request];
}

- (void)reset
{
    [self destroyDashboard];
    [self.bridge reset];
}

- (void)minimizeDashlet
{
    JMJavascriptRequest *request = [JMJavascriptRequest new];
    request.command = @"MobileDashboard.minimizeDashlet();";
    request.parametersAsString = @"";
    [self.bridge sendRequest:request];
}

#pragma mark - Private API
- (void)destroyDashboard
{
    JMJavascriptRequest *request = [JMJavascriptRequest new];
    request.command = @"MobileDashboard.destroyDashboard();";
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
                [self.bridge startLoadHTMLString:htmlString baseURL:[NSURL URLWithString:baseURLString]];

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
    JMLog(@"callback parameters: %@", callback.parameters[@"parameters"]);
    if ([callback.type isEqualToString:@"onScriptLoaded"]) {
        [self handleOnScriptLoaded];
    } else if ([callback.type isEqualToString:@"onMaximizeStart"]) {
        [self handleDidStartMaximazeDashletWithParameters:callback.parameters[@"parameters"]];
    } else if ([callback.type isEqualToString:@"onLoadDone"]) {
        [self handleOnLoadDone];
    } else if ([callback.type isEqualToString:@"onReportExecution"]) {
        [self handleOnReportExecution:callback.parameters[@"parameters"]];
    } else if ([callback.type isEqualToString:@"onAdHocExecution"]) {
        [self handleOnAdHocExecution:callback.parameters[@"parameters"]];
    } else if ([callback.type isEqualToString:@"onReferenceClick"]) {
        [self handleOnReferenceClick:callback.parameters[@"parameters"]];
    } else if ([callback.type isEqualToString:@"onAuthError"]) {
        [self javascriptNativeBridgeDidReceiveAuthRequest:self.bridge];
    }
}

- (void)javascriptNativeBridgeDidReceiveAuthRequest:(id <JMJavascriptNativeBridgeProtocol>)bridge
{
    if (self.loadCompletion) {
        // TODO: Need add auth error
        self.loadCompletion(NO, nil);
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
    }
    return shouldLoad;
}

#pragma mark - Handle JS callbacks
- (void)handleOnScriptLoaded
{
    // auth
    JMJavascriptRequest *authRequest = [JMJavascriptRequest new];
    authRequest.command = @"MobileDashboard.authorize(%@);";
    NSString *authParameters = [NSString stringWithFormat:@"{'username': '%@', 'password': '%@', 'organization': '%@'}", self.restClient.serverProfile.username, self.restClient.serverProfile.password, self.restClient.serverProfile.organization];
    authRequest.parametersAsString = authParameters;
    [self.bridge sendRequest:authRequest];

    // run
    JMJavascriptRequest *runRequest = [JMJavascriptRequest new];
    runRequest.command = @"MobileDashboard.run(%@);";
    NSString *runParameters = [NSString stringWithFormat:@"{'uri': '%@'}", self.dashboard.resourceURI];
    runRequest.parametersAsString = runParameters;
    [self.bridge sendRequest:runRequest];
}

- (void)handleOnLoadDone
{
    if (self.loadCompletion) {
        self.loadCompletion(YES, nil);
    }
}

- (void)handleDidStartMaximazeDashletWithParameters:(NSDictionary *)parameters
{
    NSString *title = parameters[@"title"];
    [self.delegate dashboardLoader:self didStartMaximazeDashletWithTitle:title];
}

- (void)handleOnReportExecution:(NSDictionary *)parameters
{
    NSString *resource = parameters[@"resource"];
    NSDictionary *params = parameters[@"params"];

    __weak typeof(self)weakSelf = self;
    [self.restClient resourceLookupForURI:resource
                             resourceType:[JSConstants sharedInstance].WS_TYPE_REPORT_UNIT
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
                                        resourceLookup.resourceType = [JSConstants sharedInstance].WS_TYPE_REPORT_UNIT;

                                        NSArray *reportParameters = [self createReportParametersFromParameters:params];
                                        [strongSelf.delegate dashboardLoader:self
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

@end