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


@implementation JMVIZWebEnvironment

#pragma mark - Init
- (instancetype __nullable)initWithId:(NSString *__nonnull)identifier initialCookies:(NSArray *__nullable)cookies;
{
    self = [super initWithId:identifier initialCookies:cookies];
    if (self) {
        _visualizeManager = [JMVisualizeManager new];
    }
    return self;
}

#pragma mark - Public API
- (void)prepareWithCompletion:(void(^)(BOOL isReady, NSError *error))completion
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    __weak __typeof(self) weakSelf = self;
    [self verifyJasperMobileEnableWithCompletion:^(BOOL isJasperMobileEnable) {
        __typeof(self) strongSelf = weakSelf;
        if (isJasperMobileEnable) {
            if (strongSelf.isCookiesReady) {
                JMLog(@"cookies is ready");
                completion(YES, nil);
            } else {
                JMLog(@"cookies isn't ready");
                // pending completion
                // wait until cookies will be loaded
                JMWebEnvironmentVoidBlock operationBlock = ^{
                    completion(YES, nil);
                };
                JMLog(@"pending preparing webview");
                [strongSelf.pendingOperations addObject:[operationBlock copy]];
            }
        } else {
            __weak __typeof(self) weakSelf = strongSelf;
            [strongSelf loadJasperMobilePageWithCompletion:^(BOOL isLoaded, NSError *error) {
                __typeof(self) strongSelf = weakSelf;
                if (isLoaded) {
                    if (strongSelf.isCookiesReady) {
                        JMLog(@"cookies is ready");
                        completion(YES, nil);
                    } else {
                        JMLog(@"cookies isn't ready");
                        // pending completion
                        // wait until cookies will be loaded
                        JMWebEnvironmentVoidBlock operationBlock = ^{
                            completion(YES, nil);
                        };
                        JMLog(@"pending of preparing webview");
                        [strongSelf.pendingOperations addObject:[operationBlock copy]];
                    }
                } else {
                    completion(NO, error);
                }
            }];
        }
    }];
}

- (void)verifyEnvironmentReadyWithCompletion:(void(^ __nonnull)(BOOL isWebViewLoaded))completion
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
}

- (void)updateViewportScaleFactorWithValue:(CGFloat)scaleFactor
{
    BOOL isInitialScaleFactorSet = self.visualizeManager.viewportScaleFactor > 0.01;
    BOOL isInitialScaleFactorTheSame = fabs(self.visualizeManager.viewportScaleFactor - scaleFactor) >= 0.49;
    if ( !isInitialScaleFactorSet || isInitialScaleFactorTheSame ) {
        self.visualizeManager.viewportScaleFactor = scaleFactor;

        JMJavascriptRequest *request = [JMJavascriptRequest requestWithCommand:@"JasperMobile.Helper.updateViewPortScale"
                                                                    parameters:@{
                                                                            @"scale" : @(scaleFactor)
                                                                    }];
        [self sendJavascriptRequest:request
                         completion:nil];
    }
}

#pragma mark - Helpers
- (void)loadJasperMobilePageWithCompletion:(void(^)(BOOL isLoaded, NSError *error))completion
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    __weak __typeof(self) weakSelf = self;
    [self loadHTML:self.visualizeManager.htmlString
           baseURL:[NSURL URLWithString:self.restClient.serverProfile.serverUrl]
        completion:^(BOOL isSuccess, NSError *error) {
            __typeof(self) strongSelf = weakSelf;
            if (isSuccess) {
                // load vis into web environment
                JMJavascriptRequest *requireJSLoadRequest = [JMJavascriptRequest requestWithCommand:@"JasperMobile.Helper.loadScripts"
                                                                                         parameters:@{
                                                                                                 @"scriptURLs" : @[
                                                                                                         strongSelf.visualizeManager.visualizePath,
                                                                                                         @"https://code.jquery.com/jquery.min.js"
                                                                                                 ]
                                                                                         }];
                [strongSelf sendJavascriptRequest:requireJSLoadRequest
                                       completion:^(NSDictionary *params, NSError *error) {
                                           completion(error == nil, error);
                                       }];
            } else {
                completion(NO, error);
            }
        }];
}

@end