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
#import "JMWebEnvironmentLoadingTask.h"
#import "JMJavascriptRequest.h"
#import "JMJavascriptRequestTask.h"
#import "NSObject+Additions.h"
#import "JMUtils.h"

@implementation JMRESTWebEnvironment

- (NSOperation *__nullable)taskForPreparingWebView
{
    NSString *htmlStringPath = [[NSBundle mainBundle] pathForResource:@"resource_viewer_rest" ofType:@"html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:htmlStringPath encoding:NSUTF8StringEncoding error:nil];

    // add static dependencies
    // fusion chart dependencies need to be loaded first
    NSString *jrsURI = self.restClient.serverProfile.serverUrl;
    NSString *staticDependencies = @"";
    staticDependencies = [staticDependencies stringByAppendingFormat:@"<script type=\"text/javascript\" src=\"%@/fusion/maps/FusionCharts.js\"></script>", jrsURI];
//    staticDependencies = [staticDependencies stringByAppendingFormat:@"<script type=\"text/javascript\" src=\"%@/fusion/maps/jquery.min.js\"></script>", jrsURI];
    staticDependencies = [staticDependencies stringByAppendingFormat:@"<script type=\"text/javascript\" src=\"%@/fusion/maps/FusionCharts.HC.js\"></script>", jrsURI];
    staticDependencies = [staticDependencies stringByAppendingFormat:@"<script type=\"text/javascript\" src=\"%@/fusion/maps/../widgets/FusionCharts.HC.Widgets.js\"></script>", jrsURI];

    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"STATIC_DEPENDENCIES" withString:staticDependencies];

    __weak __typeof(self) weakSelf = self;
    JMWebEnvironmentLoadingTask *loadingTask = [JMWebEnvironmentLoadingTask taskWithRequestExecutor:self.requestExecutor
                                                                                         HTMLString:htmlString
                                                                                            baseURL:[NSURL URLWithString:self.restClient.serverProfile.serverUrl]
                                                                                         completion:^{
                                                                                             __strong __typeof(self) strongSelf = weakSelf;
                                                                                             strongSelf.cookiesState = JMWebEnvironmentCookiesStateValid;
                                                                                         }];
    return loadingTask;
}

- (NSOperation *__nullable)taskForPreparingEnvironment
{
    JMJavascriptRequest *requireJSLoadRequest = [JMJavascriptRequest requestWithCommand:@"JasperMobile.Helper.loadScripts"
                                                                            inNamespace:JMJavascriptNamespaceDefault
                                                                             parameters:@{
                                                                                     @"scriptURLs" : @[
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
                                                                                         weakSelf.state = JMWebEnvironmentStateEnvironmentReady;
                                                                                     }
                                                                                 }];
    return requestTask;
}

- (void)updateViewportScaleFactorWithValue:(CGFloat)scaleFactor
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
}

@end