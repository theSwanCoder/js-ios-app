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
//  JMRESTWebEnvironment.m
//  TIBCO JasperMobile
//

#import "JMRESTWebEnvironment.h"
#import "JMJavascriptResponse.h"
#import "JMJavascriptRequest.h"


@implementation JMRESTWebEnvironment

- (void)prepareWithCompletion:(void (^)(BOOL isReady, NSError *error))completion
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    __weak __typeof(self) weakSelf = self;
    [self verifyEnvironmentReadyWithCompletion:^(BOOL isReady) {
        __typeof(self) strongSelf = weakSelf;
        if (isReady) {
            completion(YES, nil);
        } else {
            NSString *htmlStringPath = [[NSBundle mainBundle] pathForResource:@"resource_viewer_rest" ofType:@"html"];
            NSString *htmlString = [NSString stringWithContentsOfFile:htmlStringPath encoding:NSUTF8StringEncoding error:nil];

            // add static dependencies
            // fusion chart dependencies need to be loaded first
            NSString *jrsURI = self.restClient.serverProfile.serverUrl;
            NSString *staticDependencies = @"";
            staticDependencies = [staticDependencies stringByAppendingFormat:@"<script type=\"text/javascript\" src=\"%@/fusion/maps/FusionCharts.js\"></script>", jrsURI];
            staticDependencies = [staticDependencies stringByAppendingFormat:@"<script type=\"text/javascript\" src=\"%@/fusion/maps/jquery.min.js\"></script>", jrsURI];
            staticDependencies = [staticDependencies stringByAppendingFormat:@"<script type=\"text/javascript\" src=\"%@/fusion/maps/FusionCharts.HC.js\"></script>", jrsURI];
            staticDependencies = [staticDependencies stringByAppendingFormat:@"<script type=\"text/javascript\" src=\"%@/fusion/maps/../widgets/FusionCharts.HC.Widgets.js\"></script>", jrsURI];

            htmlString = [htmlString stringByReplacingOccurrencesOfString:@"STATIC_DEPENDENCIES" withString:staticDependencies];

            [strongSelf loadHTML:htmlString
                         baseURL:[NSURL URLWithString:strongSelf.restClient.serverProfile.serverUrl]];

            [strongSelf addPendingBlock:^{
                completion(YES, nil);
            }];
        }
    }];
}

- (void)updateViewportScaleFactorWithValue:(CGFloat)scaleFactor
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
}

#pragma mark - Helpers

- (void)verifyEnvironmentReadyWithCompletion:(void(^ __nonnull)(BOOL isWebViewLoaded))completion
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    [self verifyJasperMobileEnableWithCompletion:^(BOOL isJasperMobileLoaded) {
        JMLog(@"JasperMobile was loaded: %@", isJasperMobileLoaded ? @"YES" : @"NO");
        if (isJasperMobileLoaded) {
            [self isWebViewLoadedContentDiv:self.webView completion:^(BOOL isContantDivLoaded) {
                completion(isContantDivLoaded);
            }];
        } else {
            // TODO: need load html
            completion(NO);
        }
    }];
}

- (void)isWebViewLoadedContentDiv:(WKWebView *)webView completion:(void(^ __nonnull)(BOOL isContantDivLoaded))completion
{
    JMJavascriptRequest *request = [JMJavascriptRequest requestWithCommand:@"JasperMobile.Helper.isContainerLoaded"
                                                                parameters:nil];
    [self sendJavascriptRequest:request
                            completion:^(NSDictionary *parameters, NSError *error) {
                                if (error) {
                                    completion(NO);
                                } else {
                                    if (parameters) {
                                        NSString *isContainerLoaded = parameters[@"isContainerLoaded"];
                                        completion([isContainerLoaded isEqualToString:@"true"]);
                                    }
                                }
                            }];
}

@end