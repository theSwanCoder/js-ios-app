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
#import "JMUtils.h"
#import "NSObject+Additions.h"

@interface JMVisualizeManager()
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

- (NSString *)htmlString
{
    NSString *htmlFileName;
    if ([JMUtils isSupportVisualize]) {
        htmlFileName = @"resource_viewer";
    } else {
        htmlFileName = @"resource_viewer_rest";
    }
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:htmlFileName ofType:@"html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    // If need we can add some dependencies like scripts, styles and so on.
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"STATIC_DEPENDENCIES" withString:@""];
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
        NSString *visualizePath = [[NSString stringWithFormat:@"%@/client/visualize.js?baseUrl=%@", self.restClient.serverProfile.serverUrl, baseURL] queryEncodedString];
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