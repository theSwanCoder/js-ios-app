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
//  JMScheduleManager.m
//  TIBCO JasperMobile
//

#import "JMScheduleManager.h"

@implementation JMScheduleManager

#pragma mark - Public API
- (void)loadSchedulesForResourceLookup:(JSResourceLookup *)resourceLookup completion:(void (^)(NSArray <JSScheduleLookup *> *, NSError *))completion
{
    if (!completion) {
        return;
    }

    [self.restClient fetchSchedulesForResourceWithURI:resourceLookup.uri completion:^(JSOperationResult *result) {
        if (result.error) {
            completion(nil, result.error);
        } else {
            completion(result.objects, nil);
        }
    }];
}

- (void)loadScheduleInfoWithScheduleId:(NSInteger)scheduleId completion:(JMScheduleCompletion)completion
{
    if (!completion) {
        return;
    }

    [self.restClient fetchScheduleMetadataWithId:scheduleId completion:^(JSOperationResult *result) {
        if (result.error) {
            completion(nil, result.error);
        } else {
            completion(result.objects.firstObject, nil);
        }
    }];
}

- (void)createJobWithData:(JSScheduleMetadata *)schedule completion:(JMScheduleCompletion)completion
{
    [self.restClient createScheduleWithData:schedule
                                 completion:^(JSOperationResult *result) {
                                     NSError *error = result.error;
                                     if (error) {
                                         if (error.code == 1007) {
                                             [self handleErrorWithData:result.body completion:completion];
                                         } else {
                                            completion(nil, result.error);
                                        }
                                    } else {
                                        JSScheduleMetadata *scheduledJob = result.objects.firstObject;
                                        completion(scheduledJob, nil);
                                    }
                                }];
}

- (void)updateSchedule:(JSScheduleMetadata *)schedule completion:(JMScheduleCompletion)completion
{
    if (!completion) {
        return;
    }

    [self.restClient updateSchedule:schedule
                         completion:^(JSOperationResult *result) {
                             if (result.error) {
                                 completion(nil, result.error);
                             } else {
                                 completion(result.objects.firstObject, nil);
                             }
                         }];
}

- (void)deleteJobWithJobIdentifier:(NSInteger)identifier completion:(void(^)(NSError *))completion
{
    if (!completion) {
        return;
    }

    [self.restClient deleteScheduleWithId:identifier
                               completion:^(JSOperationResult *result) {
                                   if (result.error) {
                                       completion(result.error);
                                   } else {
                                       completion(nil);
                                   }
                               }];
}

#pragma mark - Hanlde Errors
- (void)handleErrorWithData:(NSData *)jsonData completion:(JMScheduleCompletion)completion
{
    NSError *serializeError;
    NSDictionary *bodyJSON = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&serializeError];
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
            // TODO: enhance error
            NSError *createScheduledJobError = [[NSError alloc] initWithDomain:@"Error"
                                                                          code:0
                                                                      userInfo:@{NSLocalizedDescriptionKey: fullMessage}];
            completion(nil, createScheduledJobError);
        }
    } else {
        completion(nil, serializeError);
    }
}

@end