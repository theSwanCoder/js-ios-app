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
#import "JMWebEnvironmentLoadingTask.h"
#import "JMJavascriptRequestTask.h"
#import "NSObject+Additions.h"
#import "JMUtils.h"

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

- (NSOperation *__nullable)taskForPreparingWebView
{
    JMWebEnvironmentLoadingTask *loadingTask = [JMWebEnvironmentLoadingTask taskWithRequestExecutor:self.requestExecutor
                                                                                         HTMLString:self.visualizeManager.htmlString
                                                                                            baseURL:[NSURL URLWithString:self.restClient.serverProfile.serverUrl]];
    __weak __typeof(self) weakSelf = self;
    loadingTask.completion = ^{
        weakSelf.cookiesState = JMWebEnvironmentCookiesStateValid;
    };
    return loadingTask;
}

- (NSOperation *__nullable)taskForPreparingEnvironment
{
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
    JMJavascriptRequestTask *requestTask = [JMJavascriptRequestTask taskWithRequestExecutor:self.requestExecutor
                                                                                    request:requireJSLoadRequest
                                                                                 completion:^(NSDictionary *params, NSError *error) {
                                                                                     if (!weakSelf) {
                                                                                         return;
                                                                                     }
                                                                                     if (error) {
                                                                                         JMLog(@"Error of loading scripts: %@", error);
                                                                                     } else {
                                                                                         JMServerProfile *activeProfile = [JMServerProfile serverProfileForJSProfile:weakSelf.restClient.serverProfile];
                                                                                         if (activeProfile.cacheReports.boolValue) {
                                                                                             [weakSelf createContainers];
                                                                                         }
                                                                                         weakSelf.state = JMWebEnvironmentStateEnvironmentReady;
                                                                                     }
                                                                                 }];
    return requestTask;
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

// delete
- (void)cleanCache
{
    JMJavascriptRequest *request = [JMJavascriptRequest requestWithCommand:@"reset"
                                                               inNamespace:JMJavascriptNamespaceVISReport
                                                                parameters:nil];
    [self sendJavascriptRequest:request
                     completion:nil];
}

#pragma mark - Helpers

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
