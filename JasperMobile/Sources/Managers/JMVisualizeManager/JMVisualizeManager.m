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
//  JMVisualizeManager.m
//  TIBCO JasperMobile
//

#import "JMVisualizeManager.h"

@interface JMVisualizeManager()
@property (nonatomic, strong) NSString *visualizePath;
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@end

@implementation JMVisualizeManager

#pragma mark - Custom Accessors
- (void)loadVisualizeJSWithCompletion:(void(^)(BOOL success, NSError *error))completion
{
    if (!completion) {
        return;
    }

    if ([self isVisualizeLoaded]) {
        completion(YES, nil);
        return;
    }

    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *url = [NSURL URLWithString:self.visualizePath];
    self.downloadTask = [session downloadTaskWithURL:url
                                   completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                       NSData *visEngineData = [[NSData alloc] initWithContentsOfFile:location.path];
                                       if (visEngineData) {
                                           // cache visualize.js
                                           NSCachedURLResponse *cachedURLResponse = [[NSCachedURLResponse alloc] initWithResponse:response
                                                                                                                             data:visEngineData];
                                           [[NSURLCache sharedURLCache] storeCachedResponse:cachedURLResponse
                                                                                 forRequest:[NSURLRequest requestWithURL:url]];

                                           dispatch_async(dispatch_get_main_queue(), ^(void){
                                               completion(YES, nil);
                                           });
                                       } else {
                                           dispatch_async(dispatch_get_main_queue(), ^(void) {
                                               completion(NO, error);
                                           });
                                       }
                                   }];
    [self.downloadTask resume];
}

- (NSString *)htmlStringForReport
{
    NSString *htmlString = [self htmlStringForDashboard];
    return htmlString;
}

- (NSString *)htmlStringForDashboard
{
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"dashboard" ofType:@"html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];

//    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"INITIAL_SCALE_VIEWPORT" withString:@(self.viewportScaleFactor).stringValue];

    // Visualize
    NSString *visualizeURLString = self.visualizePath;
    visualizeURLString = [visualizeURLString stringByAppendingString:@"&_showInputControls=true&_opt=true"];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"VISUALIZE_PATH" withString:visualizeURLString];

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
        NSString *baseURL = self.restClient.serverProfile.serverUrl;
//        NSString *baseURL = @"http://mobiledemo2.jaspersoft.com";
        baseURL = [baseURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
        NSString *visualizePath = [NSString stringWithFormat:@"%@/client/visualize.js?baseUrl=%@", self.restClient.serverProfile.serverUrl, baseURL];

//        BOOL isNeedNonOptimizedVisualize = [self isAmberServer];
//        if (isNeedNonOptimizedVisualize) {
//        }
            visualizePath = [visualizePath stringByAppendingString:@"&_opt=false"];

        _visualizePath = visualizePath;
    }
    return _visualizePath;
}

#pragma mark - Helpers
- (BOOL)isAmberServer
{
    BOOL isAmberServer = NO;
    CGFloat versionNumber = self.restClient.serverProfile.serverInfo.versionAsFloat;
    if (versionNumber >= 6.0 && versionNumber < 6.1f) {
        isAmberServer = YES;
    }
    return isAmberServer;
}

@end