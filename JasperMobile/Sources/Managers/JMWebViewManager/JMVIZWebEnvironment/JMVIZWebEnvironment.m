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
    JMJavascriptRequest *requireJSLoadRequest = [JMJavascriptRequest requestWithCommand:@"JasperMobile.Helper.loadScripts"
                                                                             parameters:@{
                                                                                     @"scriptURLs" : @[
                                                                                             self.visualizeManager.visualizePath,
                                                                                             //@"https://code.jquery.com/jquery.min.js"
                                                                                     ]
                                                                             }];
    [self sendJavascriptRequest:requireJSLoadRequest
                     completion:^(NSDictionary *params, NSError *error) {
                         completion(error == nil, error);
                     }];
}

@end