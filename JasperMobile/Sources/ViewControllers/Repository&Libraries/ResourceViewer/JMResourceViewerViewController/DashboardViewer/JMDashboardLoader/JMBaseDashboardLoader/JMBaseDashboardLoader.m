/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2014 TIBCO Software, Inc. All rights reserved.
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
#import "JMJavascriptNativeBridgeProtocol.h"
#import "JMJavascriptNativeBridge.h"
#import "JMJavascriptCallback.h"
#import "JMJavascriptRequest.h"
#import "JMDashboard.h"
#import "JSResourceLookup+Helpers.h"

@interface JMBaseDashboardLoader() <JMJavascriptNativeBridgeDelegate>
@property (nonatomic, weak) JMDashboard *dashboard;
@property (nonatomic, copy) void(^loadCompletion)(BOOL success, NSError *error);
@end

@implementation JMBaseDashboardLoader
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
- (void)loadDashboardWithCompletion:(void (^)(BOOL success, NSError *error))completion
{
    [self.bridge loadRequest:self.dashboard.resourceRequest];

    if ([self.dashboard.resourceLookup isNewDashboard]) {
        self.loadCompletion = completion;
        [self injectJSCode];
    } else {
        if (completion) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                completion(YES, nil);
            });
        }
    };
}

- (void)reloadDashboardWithCompletion:(void (^)(BOOL success, NSError *error))completion
{
    [self.bridge reset];

    // waiting until page will be cleared
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self loadDashboardWithCompletion:completion];
    });
}

- (void)minimizeDashlet {
    JMJavascriptRequest *request = [JMJavascriptRequest new];
    request.command = @"MobileDashboard.minimizeDashlet();";
    request.parametersAsString = @"";
    [self.bridge sendRequest:request];
}

- (void)reset
{
    [self.bridge reset];
}

#pragma mark - JMJavascriptNativeBridgeProtocol
- (void)javascriptNativeBridge:(id <JMJavascriptNativeBridgeProtocol>)bridge didReceiveCallback:(JMJavascriptCallback *)callback
{
    JMLog(@"callback parameters: %@", callback.parameters);
    if ([callback.type isEqualToString:@"scriptDidLoad"]) {
        [self handleDidScriptLoad];
    } else if ([callback.type isEqualToString:@"onLoadDone"]) {
        [self handleOnLoadDone];
    } else if ([callback.type isEqualToString:@"didStartMaximazeDashlet"]) {
        [self handleDidStartMaximazeDashletWithParameters:callback.parameters];
    }
}

- (void)javascriptNativeBridgeDidReceiveAuthRequest:(id <JMJavascriptNativeBridgeProtocol>)bridge
{
    [self.delegate dashboardLoaderDidReceiveAuthRequest:self];
}

#pragma mark - JS Handlers
- (void)handleDidScriptLoad
{
    JMJavascriptRequest *request = [JMJavascriptRequest new];
    request.command = @"MobileDashboard.configure({'diagonal': %@}).run();";
    request.parametersAsString = [NSString stringWithFormat:@"%@", @([self diagonal])];
    [self.bridge sendRequest:request];
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

#pragma mark - Helpers
- (CGFloat)diagonal
{
    // TODO: extend this simplified version
    float diagonal = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? [self diagonalIpad]: [self diagonalIphone];
    return diagonal;
}

- (CGFloat)diagonalIpad
{
    return 9.7;
}

- (CGFloat)diagonalIphone
{
    return 4.0;
}

- (void)injectJSCode
{
    NSString *jsMobilePath = [[NSBundle mainBundle] pathForResource:@"dashboard-amber-ios-mobilejs-sdk" ofType:@"js"];
    NSError *error;
    NSString *jsMobile = [NSString stringWithContentsOfFile:jsMobilePath encoding:NSUTF8StringEncoding error:&error];
    [self.bridge injectJSInitCode:jsMobile];
}

@end