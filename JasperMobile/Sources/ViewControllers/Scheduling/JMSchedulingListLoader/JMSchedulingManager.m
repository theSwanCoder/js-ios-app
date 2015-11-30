//
// Created by Aleksandr Dakhno on 11/30/15.
// Copyright (c) 2015 TIBCO JasperMobile. All rights reserved.
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
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@/%@", self.restClient.serverProfile.serverUrl, [JSConstants sharedInstance].REST_SERVICES_V2_URI, @"jobs", @(identifier)];
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

- (void)createJobWithData:(NSDictionary *)jobData completion:(void(^)(NSDictionary * job, NSError *error))completion
{
    if (!completion) {
        return;
    }

    NSURLSession *session = [NSURLSession sharedSession];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@", self.restClient.serverProfile.serverUrl, [JSConstants sharedInstance].REST_SERVICES_V2_URI, @"jobs"];
    JMLog(@"url: %@", urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"PUT";
    request.allHTTPHeaderFields = @{
            @"Accept" : @"application/job+json",
            @"Content-Type" : @"application/job+json"
    };
    NSData *HTTPBody = [NSJSONSerialization dataWithJSONObject:jobData options:0 error:nil];
    request.HTTPBody = HTTPBody;
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

- (void)deleteJobWithJobIdentifier:(NSInteger)identifier completion:(void(^)(NSError *error))completion
{
    if (!completion) {
        return;
    }

    NSURLSession *session = [NSURLSession sharedSession];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@/%@", self.restClient.serverProfile.serverUrl, [JSConstants sharedInstance].REST_SERVICES_V2_URI, @"jobs", @(identifier)];
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
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@", self.restClient.serverProfile.serverUrl, [JSConstants sharedInstance].REST_SERVICES_V2_URI, @"jobs"];
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