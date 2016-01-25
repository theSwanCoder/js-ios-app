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
//  JMSchedulingManager.m
//  TIBCO JasperMobile
//

#import "JMSchedulingManager.h"

@interface JMSchedulingManager ()
@property (nonatomic, readwrite) NSArray *jobs;
@property (nonatomic, strong) NSURLSessionDataTask *downloadTask;
@end

@implementation JMSchedulingManager

#pragma mark - Public API
- (void)loadJobsWithCompletion:(void(^)(NSArray *jobs, NSError *error))completion
{
    [self loadResourcesWithCompletion:^(NSArray *jobs, NSError *error) {
        self.jobs = jobs;
        completion(jobs, error);
    }];
}

- (void)jobInfoWithJobIdentifier:(NSInteger)identifier completion:(void(^)(NSDictionary *jobInfo, NSError *error))completion
{
    if (!completion) {
        return;
    }

    NSURLSession *session = [NSURLSession sharedSession];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@/%@", self.restClient.serverProfile.serverUrl, kJS_REST_SERVICES_V2_URI, @"jobs", @(identifier)];
    JMLog(@"url: %@", urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.allHTTPHeaderFields = @{
            @"Accept" : @"application/job+json"
    };
    self.downloadTask = [session dataTaskWithRequest:request
                                   completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                       JMLog(@"request end");
                                       JMLog(@"data: %@", data);

                                       if (data) {
                                           NSError *jsonParseError;
                                           NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonParseError];
//                                           JMLog(@"json parse error: %@", jsonParseError.localizedDescription);
//                                           JMLog(@"json: %@", json);

                                           if (!json) {
                                               NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                               JMLog(@"error message: %@", message);
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                   completion(nil, jsonParseError);
                                               });
                                           } else {
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                   completion(json, nil);
                                               });
                                           }
                                       } else {
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               completion(nil, error);
                                           });
                                       }
                                   }];
    JMLog(@"request start");
    [self.downloadTask resume];
}

- (void)createJobWithData:(NSData *)jobData completion:(void(^)(NSDictionary * job, NSError *error))completion
{
    if (!completion) {
        return;
    }

    NSURLSession *session = [NSURLSession sharedSession];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@", self.restClient.serverProfile.serverUrl, kJS_REST_SERVICES_V2_URI, @"jobs"];
    JMLog(@"url: %@", urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"PUT";
    request.allHTTPHeaderFields = @{
            @"Accept" : @"application/job+json",
            @"Content-Type" : @"application/job+json"
    };
    request.HTTPBody = jobData;
    self.downloadTask = [session dataTaskWithRequest:request
                                   completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                       JMLog(@"request end");
                                       JMLog(@"data: %@", data);

                                       if (data) {
                                           NSError *jsonParseError;
                                           NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonParseError];
//                                           JMLog(@"json parse error: %@", jsonParseError.localizedDescription);
//                                           JMLog(@"json: %@", json);

                                           if (!json) {
                                               NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                               JMLog(@"error message: %@", message);
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                   completion(nil, jsonParseError);
                                               });
                                           } else {
                                               NSDictionary *errorData = ((NSArray *)json[@"error"]).firstObject;
                                               if (errorData) {
                                                   NSString *errorCode = errorData[@"errorCode"];
                                                   NSString *field = errorData[@"field"];
                                                   NSString *errorMessage = [NSString stringWithFormat:@"%@ in %@", errorCode, field];
                                                   NSError *logicError = [NSError errorWithDomain:@"CreateJobLogicError" code:0 userInfo:@{
                                                           NSLocalizedDescriptionKey : errorMessage
                                                   }];
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       completion(nil, logicError);
                                                   });
                                               } else {
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       completion(json, nil);
                                                   });
                                               }
                                           }
                                       } else {
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               completion(nil, error);
                                           });
                                       }
                                   }];
    JMLog(@"request start");
    [self.downloadTask resume];
}

- (void)deleteJobWithJobIdentifier:(NSInteger)identifier completion:(void(^)(NSError *error))completion
{
    if (!completion) {
        return;
    }

    NSURLSession *session = [NSURLSession sharedSession];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@/%@", self.restClient.serverProfile.serverUrl, kJS_REST_SERVICES_V2_URI, @"jobs", @(identifier)];
    JMLog(@"url: %@", urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"DELETE";
    self.downloadTask = [session dataTaskWithRequest:request
                                   completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                       JMLog(@"request end");
                                       JMLog(@"data: %@", data);

                                       if (data) {
                                           NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                           JMLog(@"message: %@", message);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               completion(nil);
                                           });
                                       } else {
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               completion(error);
                                           });
                                       }
                                   }];
    JMLog(@"request start");
    [self.downloadTask resume];
}

#pragma mark - Private API
- (void)loadResourcesWithCompletion:(void(^)(NSArray *jobs, NSError *error))completion
{
    if (!completion) {
        return;
    }

    NSURLSession *session = [NSURLSession sharedSession];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@", self.restClient.serverProfile.serverUrl, kJS_REST_SERVICES_V2_URI, @"jobs"];
//    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@", self.restClient.serverProfile.serverUrl, [JSConstants sharedInstance].REST_SERVICES_V2_URI, @"jobs?owner=superuser"];
//    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@", self.restClient.serverProfile.serverUrl, [JSConstants sharedInstance].REST_SERVICES_V2_URI, @"jobs?username=superuser"];
//    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@", self.restClient.serverProfile.serverUrl, [JSConstants sharedInstance].REST_SERVICES_V2_URI, @"jobs/2891"];

    JMLog(@"url: %@", urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.allHTTPHeaderFields = @{
            @"Accept" : @"application/json"
    };
    self.downloadTask = [session dataTaskWithRequest:request
                                   completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                       JMLog(@"request end");
                                       JMLog(@"data: %@", data);

                                       if (data) {
                                           NSError *jsonParseError;
                                           NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonParseError];
//                                           JMLog(@"json parse error: %@", jsonParseError);
//                                           JMLog(@"json: %@", json);

                                           NSArray *jobs = json[@"jobsummary"];
                                           JMLog(@"jobs: %@", jobs);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               completion(jobs, nil);
                                           });
                                       }  else {
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               completion(nil, error);
                                           });
                                       }
                                   }];
    JMLog(@"request start");
    [self.downloadTask resume];
}

@end