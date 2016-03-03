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
#import "JMWebEnvironment.h"

@interface JMBaseDashboardLoader() <JMJavascriptNativeBridgeDelegate>
@property (nonatomic, weak) JMDashboard *dashboard;
@property (nonatomic, copy) void(^loadCompletion)(BOOL success, NSError *error);
@property (nonatomic) BOOL isLoadDone;
@property (nonatomic, weak) JMWebEnvironment *webEnvironment;
@end

@implementation JMBaseDashboardLoader
@synthesize delegate = _delegate;

#pragma mark - Initializers
- (id<JMDashboardLoader> __nullable)initWithDashboard:(JMDashboard *__nonnull)dashboard
                                       webEnvironment:(JMWebEnvironment *)webEnvironment
{
    self = [super init];
    if (self) {
        _dashboard = dashboard;
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
- (void)loadDashboardWithCompletion:(void (^)(BOOL success, NSError *error))completion
{
    // TODO: reimplement without request
    [self.webEnvironment loadRequest:self.dashboard.resourceRequest];

    [self injectJSCodeOldDashboard];
    if (completion) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            completion(YES, nil);
        });
    }
}

- (void)reloadDashboardWithCompletion:(JMDashboardLoaderCompletion)completion
{
    [self.webEnvironment clean];

    // waiting until page will be cleared
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self loadDashboardWithCompletion:completion];
    });
}

- (void)minimizeDashlet {
    JMJavascriptRequest *request = [JMJavascriptRequest new];
    request.command = @"MobileDashboard.minimizeDashlet();";
    request.parametersAsString = @"";
    [self.webEnvironment sendJavascriptRequest:request completion:^(NSDictionary *parameters, NSError *error) {
        if (error) {
            JMLog(@"error: %@", error);
        } else {
            JMLog(@"parameters: %@", parameters);
        }
    }];
}

- (void)cancel
{
    [self.webEnvironment reset];
}

- (void)destroy
{
    [self.webEnvironment reset];
}

#pragma mark - JMJavascriptNativeBridgeProtocol
- (void)javascriptNativeBridgeDidReceiveAuthRequest:(JMJavascriptNativeBridge *)bridge
{
    if (self.loadCompletion) {
        // TODO: Need add auth error
        self.loadCompletion(NO, nil);
    }
    [self.delegate dashboardLoaderDidReceiveAuthRequest:self];
}

- (BOOL)javascriptNativeBridge:(JMJavascriptNativeBridge *)bridge shouldLoadExternalRequest:(NSURLRequest *)request
{
    BOOL shouldLoad = NO;
    // TODO: verify all cases

    if (request.URL.host) {
        shouldLoad = YES;
    }
    return shouldLoad;
}


#pragma mark - Helpers
- (void)injectJSCodeOldDashboard
{
    NSString *jsMobilePath = [[NSBundle mainBundle] pathForResource:@"old_dashboard" ofType:@"js"];
    NSError *error;
    NSString *jsMobile = [NSString stringWithContentsOfFile:jsMobilePath encoding:NSUTF8StringEncoding error:&error];
    CGFloat initialScale = 0.5;
    if ([JMUtils isCompactWidth] || [JMUtils isCompactHeight]) {
        initialScale = 0.25;
    }
    jsMobile = [jsMobile stringByReplacingOccurrencesOfString:@"INITIAL_SCALE_VIEWPORT" withString:@(initialScale).stringValue];
    [self.webEnvironment injectJSInitCode:jsMobile];
}

@end