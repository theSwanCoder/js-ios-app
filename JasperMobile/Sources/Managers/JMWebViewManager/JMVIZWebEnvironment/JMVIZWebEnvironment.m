/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2016 TIBCO Software, Inc. All rights reserved.
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
//  JMVIZWebEnvironment.m
//  TIBCO JasperMobile
//

#import "JMVIZWebEnvironment.h"
#import "JMVisualizeManager.h"
#import "JMJavascriptRequest.h"
#import "JMServerOptionManager.h"


@implementation JMVIZWebEnvironment

#pragma mark - Init
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype __nullable)initWithId:(NSString *__nonnull)identifier initialCookies:(NSArray *__nullable)cookies;
{
    self = [super initWithId:identifier initialCookies:cookies];
    if (self) {
        _visualizeManager = [JMVisualizeManager new];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(cacheReportsOptionDidChange:)
                                                     name:JMCacheReportsOptionDidChangeNotification
                                                   object:nil];
    }
    return self;
}

#pragma mark - Notification
- (void)cacheReportsOptionDidChange:(NSNotification *)notification
{
    JMServerProfile *serverProfile = notification.object;
    [self cleanCache];
    [self removeContainers];
    if (serverProfile.cacheReports.boolValue) {
        [self createContainers];
    }
}

#pragma mark - Public API
- (void)prepareWithCompletion:(void(^)(BOOL isReady, NSError *error))completion
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    __weak __typeof(self) weakSelf = self;
    [self verifyJasperMobileEnableWithCompletion:^(BOOL isJasperMobileEnable) {
        __typeof(self) strongSelf = weakSelf;
        if (isJasperMobileEnable) {
            [strongSelf verifyVisualizeLoadedWithCompletion:^(BOOL isVisualizeLoaded) {
                if (isVisualizeLoaded) {
                    completion(YES, nil);
                } else {
                    [strongSelf loadVisualizeWithCompletion:completion];
                }
            }];
        } else {
            [strongSelf loadJasperMobilePageWithCompletion:completion];
        }
    }];
}

- (void)verifyVisualizeLoadedWithCompletion:(void(^ __nonnull)(BOOL isVisualizeLoaded))completion
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    NSAssert(completion != nil, @"Completion is nil");
    NSString *jsCommand = @"typeof(visualize);";
    [self.webView evaluateJavaScript:jsCommand completionHandler:^(id result, NSError *error) {
        BOOL isFunction = [result isEqualToString:@"function"];
        BOOL isEnable = !error && isFunction;
        completion(isEnable);
    }];
}

- (void)updateViewportScaleFactorWithValue:(CGFloat)scaleFactor
{
    BOOL isInitialScaleFactorSet = self.visualizeManager.viewportScaleFactor > 0.01;
    BOOL isInitialScaleFactorTheSame = fabs(self.visualizeManager.viewportScaleFactor - scaleFactor) >= 0.49;
    if ( !isInitialScaleFactorSet || isInitialScaleFactorTheSame ) {
        self.visualizeManager.viewportScaleFactor = scaleFactor;

        JMJavascriptRequest *request = [JMJavascriptRequest requestWithCommand:@"JasperMobile.Helper.updateViewPortScale"
                                                                   inNamespace:JMJavascriptNamespaceDefault
                                                                    parameters:@{
                                                                            @"scale" : @(scaleFactor)
                                                                    }];
        [self sendJavascriptRequest:request
                         completion:nil];
    }
}

- (void)cleanCache
{
    JMJavascriptRequest *request = [JMJavascriptRequest requestWithCommand:@"reset"
                                                               inNamespace:JMJavascriptNamespaceVISReport
                                                                parameters:nil];
    [self sendJavascriptRequest:request
                     completion:nil];
}

#pragma mark - Helpers
- (void)loadJasperMobilePageWithCompletion:(void(^)(BOOL isLoaded, NSError *error))completion
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [self loadHTML:self.visualizeManager.htmlString
           baseURL:[NSURL URLWithString:self.restClient.serverProfile.serverUrl]];

    __weak __typeof(self) weakSelf = self;
    [self addPendingBlock:^{
        JMLog(@"JasperMobile was loaded");
        __typeof(self) strongSelf = weakSelf;
        [strongSelf loadVisualizeWithCompletion:completion];
    }];
}

- (void)loadVisualizeWithCompletion:(void(^)(BOOL isLoaded, NSError *error))completion
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    // load vis into web environment
    NSString *vizPath = self.visualizeManager.visualizePath;
    JMJavascriptRequest *requireJSLoadRequest = [JMJavascriptRequest requestWithCommand:@"JasperMobile.Helper.loadScripts"
                                                                            inNamespace:JMJavascriptNamespaceDefault
                                                                             parameters:@{
                                                                                     @"scriptURLs" : @[
                                                                                             vizPath,
                                                                                             @"https://code.jquery.com/jquery.min.js"
                                                                                     ]
                                                                             }];
    __weak  __typeof(self) weakSelf = self;
    [self sendJavascriptRequest:requireJSLoadRequest
                     completion:^(NSDictionary *params, NSError *error) {
                         __typeof(self) strongSelf = weakSelf;
                         if (error) {
                             completion(NO, error);
                         } else {
                             JMServerProfile *activeProfile = [JMServerProfile serverProfileForJSProfile:self.restClient.serverProfile];
                             if (activeProfile.cacheReports.boolValue) {
                                 [strongSelf createContainers];
                             }
                             completion(YES, nil);
                         }
                     }];
}

- (void)removeContainers
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    JMJavascriptRequest *request = [JMJavascriptRequest requestWithCommand:@"JasperMobile.containerManager.removeAllContainers"
                                                               inNamespace:JMJavascriptNamespaceDefault
                                                                parameters:nil];
    [self sendJavascriptRequest:request
                     completion:nil];
}

- (void)createContainers
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    JMJavascriptRequest *request = [JMJavascriptRequest requestWithCommand:@"JasperMobile.containerManager.setContainers"
                                                               inNamespace:JMJavascriptNamespaceDefault
                                                                parameters:@{
                                                                        @"containers" : @[
                                                                                @{
                                                                                        @"name" : @"container",
                                                                                        @"isActive" : @NO
                                                                                },
                                                                                @{
                                                                                        @"name" : @"container1",
                                                                                        @"isActive" : @NO
                                                                                },
                                                                                @{
                                                                                        @"name" : @"container2",
                                                                                        @"isActive" : @NO
                                                                                },
                                                                        ]
                                                                }];
    [self sendJavascriptRequest:request
                     completion:nil];
}

@end
