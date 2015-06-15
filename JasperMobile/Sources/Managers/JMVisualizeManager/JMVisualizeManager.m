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
//  JMVisualizeManager.m
//  TIBCO JasperMobile
//

#import "JMVisualizeManager.h"

@interface JMVisualizeManager()
@property (nonatomic, strong) NSString *visualizePath;
@end

@implementation JMVisualizeManager

#pragma mark - Custom Accessors
- (void)loadVisualizeJSWithCompletion:(void(^)(BOOL success, NSError *error))completion
{
    if ([self isVisualizeLoaded]) {
        if (completion) {
            completion(YES, nil);
        }
        return;
    }

    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){

        NSURLResponse *response;
        NSError *error;

        NSURLRequest *visualizeJSRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:self.visualizePath]];
        NSData *data = [NSURLConnection sendSynchronousRequest:visualizeJSRequest returningResponse:&response error:&error];
        if (data) {
            // cache visualize.js
            NSCachedURLResponse *cachedURLResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:data];
            [[NSURLCache sharedURLCache] storeCachedResponse:cachedURLResponse forRequest:visualizeJSRequest];

            dispatch_async(dispatch_get_main_queue(), ^(void){
                if (completion) {
                    completion(YES, nil);
                }
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                if (completion) {
                    completion(NO, error);
                }
            });
        }
    });


}

- (NSString *)htmlStringForReport
{
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"report_optimized" ofType:@"html"];
    if ([JMUtils isServerVersionUpOrEqual6] && ![JMUtils isServerAmber2]) {
        htmlPath = [[NSBundle mainBundle] pathForResource:@"report" ofType:@"html"];
    }

    NSString *htmlString = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];

    // Visualize
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"VISUALIZE_PATH" withString:self.visualizePath];

    // REQUIRE_JS
    NSString *requireJSPath = [[NSBundle mainBundle] pathForResource:@"require.min" ofType:@"js"];
    NSString *requirejsString = [NSString stringWithContentsOfFile:requireJSPath encoding:NSUTF8StringEncoding error:nil];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"REQUIRE_JS" withString:requirejsString];

    // JasperMobile
    NSString *jaspermobilePath = [[NSBundle mainBundle] pathForResource:@"report-ios-mobilejs-sdk" ofType:@"js"];
    NSString *jaspermobileString = [NSString stringWithContentsOfFile:jaspermobilePath encoding:NSUTF8StringEncoding error:nil];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"JASPERMOBILE_SCRIPT" withString:jaspermobileString];

    return htmlString;
}


- (NSString *)htmlStringForDashboard
{
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"dashboard" ofType:@"html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];

    // Visualize
    NSString *baseURLString = self.restClient.serverProfile.serverUrl;
    baseURLString = [baseURLString stringByAppendingString:@"/client/visualize.js?_showInputControls=true&_opt=true"];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"VISUALIZE_PATH" withString:baseURLString];

    // REQUIRE_JS
    NSString *requireJSPath = [[NSBundle mainBundle] pathForResource:@"require.min" ofType:@"js"];
    NSString *requirejsString = [NSString stringWithContentsOfFile:requireJSPath encoding:NSUTF8StringEncoding error:nil];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"REQUIRE_JS" withString:requirejsString];

    // JasperMobile
    NSString *jaspermobilePath = [[NSBundle mainBundle] pathForResource:@"dashboard-amber2-ios-mobilejs-sdk" ofType:@"js"];
    NSString *jaspermobileString = [NSString stringWithContentsOfFile:jaspermobilePath encoding:NSUTF8StringEncoding error:nil];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"JASPERMOBILE_SCRIPT" withString:jaspermobileString];

    return htmlString;
}

#pragma mark - Private API
- (BOOL)isVisualizeLoaded
{
    BOOL isVisualizeLoaded = NO;
    NSURLRequest *visualizeJSRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:self.visualizePath]];
    if ([[NSURLCache sharedURLCache] cachedResponseForRequest:visualizeJSRequest]) {
        isVisualizeLoaded = YES;
    }
    return isVisualizeLoaded;
}

- (NSString *)visualizePath
{
    if (!_visualizePath) {
        NSString *visualizePath = [NSString stringWithFormat:@"%@/client/visualize.js", self.restClient.serverProfile.serverUrl];

        if ([JMUtils isServerVersionUpOrEqual6] && ![JMUtils isServerAmber2]) {
            visualizePath = [visualizePath stringByAppendingString:@"?_opt=false"];
        }
        _visualizePath = visualizePath;
    }
    return _visualizePath;
}

#pragma mark - Helpers


@end