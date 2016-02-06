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
#import "JSScheduleJobResource.h"
#import "JSScheduleJobState.h"
#import "JSRESTBase+JSSchedule.h"
#import "JSScheduleJob.h"
#import "JSRESTBase+JMScheduleExtended.h"

@implementation JMSchedulingManager

#pragma mark - Public API
- (void)loadSchedulesWithCompletion:(void(^)(NSArray <JSScheduleJobResource *>*jobs, NSError *error))completion
{
    [self loadResourcesWithCompletion:^(NSArray *jobs, NSError *error) {
        completion(jobs, error);
    }];
}

- (void)loadSchedulesForResourceLookup:(JSResourceLookup *)resourceLookup completion:(void (^)(NSArray <JSScheduleJobResource *> *, NSError *))completion
{
    if (!completion) {
        return;
    }

    [self.restClient fetchScheduledJobResourcesWithResourceURI:resourceLookup.uri completion:^(JSOperationResult *result) {
        if (result.error) {
            completion(nil, result.error);
        } else {
            completion(result.objects, nil);
        }
    }];
}

- (void)createJobWithData:(JSScheduleJob *)jobData completion:(void(^)(JSScheduleJob *, NSError *))completion
{
    if (!completion) {
        return;
    }

    [self.restClient createScheduledJobWithJob:jobData
                                    completion:^(JSOperationResult *result) {
                                        JMLog(@"error: %@", result.error);
                                        NSError *error = result.error;
                                        if (error) {
                                            if (error.code == 1000) {
                                                NSDictionary *bodyJSON = [NSJSONSerialization JSONObjectWithData:result.body options:NSJSONReadingMutableContainers error:nil];
                                                if (bodyJSON) {
                                                    NSArray *errors = bodyJSON[@"error"];
                                                    if (errors.count > 0) {
                                                        NSString *fullMessage = @"";
                                                        for (NSDictionary *errorJSON in errors) {
                                                            id message = errorJSON[@"defaultMessage"];
                                                            NSString *errorMessage = @"";
                                                            NSString *field = errorJSON[@"field"];
                                                            if (message && [message isKindOfClass:[NSString class]]) {
                                                                errorMessage = [NSString stringWithFormat:@"Message: '%@', field: %@", message, field];
                                                            } else {
                                                                NSString *errorCode = errorJSON[@"errorCode"];
                                                                errorMessage = [NSString stringWithFormat:@"Error Code: '%@'", errorCode];
                                                            }
                                                            NSArray *arguments = errorJSON[@"errorArguments"];
                                                            NSString *argumentsString = @"";
                                                            if (arguments) {
                                                                for (NSString *argument in arguments) {
                                                                    argumentsString = [argumentsString stringByAppendingFormat:@"'%@', ", argument];
                                                                }
                                                            }
                                                            if (arguments.count) {
                                                                fullMessage = [fullMessage stringByAppendingFormat:@"%@.\nArguments: %@.\n", errorMessage, argumentsString];
                                                            } else {
                                                                fullMessage = [fullMessage stringByAppendingFormat:@"%@.\n", errorMessage];
                                                            }
                                                        }
                                                        NSError *createScheduledJobError = [[NSError alloc] initWithDomain:@"Error"
                                                                                                                      code:0
                                                                                                                  userInfo:@{NSLocalizedDescriptionKey: fullMessage}];
                                                        completion(nil, createScheduledJobError);
                                                    }
                                                }
                                            } else {
                                                completion(nil, result.error);
                                            }
                                        } else {
                                            JMLog(@"result.objects: %@", result.objects);
                                            JSScheduleJob *scheduledJob = result.objects.firstObject;
                                            completion(scheduledJob, nil);
                                        }
                                    }];
}

- (void)deleteJobWithJobIdentifier:(NSInteger)identifier completion:(void(^)(NSError *))completion
{
    if (!completion) {
        return;
    }

    [self.restClient deleteScheduledJobWithIdentifier:identifier
                                           completion:^(JSOperationResult *result) {
                                                if (result.error) {
                                                    completion(result.error);
                                                } else {
                                                    completion(nil);
                                                }
                                            }];
}

#pragma mark - Private API
- (void)loadResourcesWithCompletion:(void(^)(NSArray <JSScheduleJobResource *>*, NSError *))completion
{
    if (!completion) {
        return;
    }

    [self.restClient fetchScheduledJobResourcesWithCompletion:^(JSOperationResult *result) {
        if (result.error) {
            completion(nil, result.error);
        } else {
            completion(result.objects, nil);
        }
    }];
}

@end