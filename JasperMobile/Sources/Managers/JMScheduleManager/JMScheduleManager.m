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
#import "JMResource.h"
#import "NSObject+Additions.h"
#import "JMLocalization.h"
#import "JMUtils.h"

@implementation JMScheduleManager

#pragma mark - Life Cycle
+ (instancetype)sharedManager
{
    static JMScheduleManager *sharedManager;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^() {
        sharedManager = [JMScheduleManager new];
    });
    return sharedManager;
}

#pragma mark - Public API
- (void)loadScheduleMetadataForScheduleWithId:(NSInteger)scheduleId completion:(JMScheduleCompletion __nonnull)completion
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

- (void)createScheduleWithData:(JSScheduleMetadata *)schedule completion:(JMScheduleCompletion)completion
{
    [self.restClient createScheduleWithData:schedule
                                 completion:^(JSOperationResult *result) {
                                     NSError *error = result.error;
                                     if (error) {
                                         if (error.code == JSClientErrorCode) {
                                             [self handleErrorsWithData:result.body completion:completion];
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
                                 if (result.error.code == JSClientErrorCode) {
                                     [self handleErrorsWithData:result.body completion:completion];
                                 } else {
                                     completion(nil, result.error);
                                 }
                             } else {
                                 completion(result.objects.firstObject, nil);
                             }
                         }];
}

- (void)deleteScheduleWithJobIdentifier:(NSInteger)identifier completion:(void(^)(NSError *))completion
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
- (void)handleErrorsWithData:(NSData *)jsonData completion:(JMScheduleCompletion)completion
{
    NSError *serializeError;
    NSDictionary *bodyJSON = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&serializeError];
    if (bodyJSON) {
        NSArray *errors = bodyJSON[@"error"];
        if (errors.count > 0) {
            NSString *fullMessage = @"";
            for (NSDictionary *errorJSON in errors) {
                NSString *message = [self errorMessageFromData:errorJSON];
                if (message.length) {
                    fullMessage = [fullMessage stringByAppendingFormat:@"\n%@\n", message];
                }
            }
            // TODO: enhance error
            if (fullMessage.length == 0) {
                fullMessage = @"General error of creating a new schedule.";

            }
            NSError *createScheduledJobError = [[NSError alloc] initWithDomain:JMLocalizedString(@"schedules_error_domain")
                                                                          code:0
                                                                      userInfo:@{NSLocalizedDescriptionKey: fullMessage}];
            completion(nil, createScheduledJobError);
        }
    } else {
        completion(nil, serializeError);
    }
}

- (NSString *)errorMessageFromData:(NSDictionary *)data
{
    JMLog(@"data: %@", data);
    NSString *errorMessage;
    NSString *field = [[data[@"field"] componentsSeparatedByString:@"."] lastObject];
    
    NSString *defaultMessage = data[@"defaultMessage"];

    if (defaultMessage) {
        errorMessage = defaultMessage;
        id argument = data[@"errorArguments"];
        if (argument) {
            if ([argument isKindOfClass:[NSArray class]]) {
                argument = [argument lastObject];
            }
            NSString *argumentString = [NSString stringWithFormat:@"%@", argument];
            NSRange startRange = [defaultMessage rangeOfString:@"{"];
            NSRange endRange = [defaultMessage rangeOfString:@"}"];
            
            if (startRange.location != NSNotFound && endRange.location != NSNotFound && endRange.location > startRange.location ) {
                NSRange replacingStringRange = NSMakeRange(startRange.location, endRange.location - startRange.location + 1);
                NSString *replacingString = [defaultMessage substringWithRange:replacingStringRange];
                errorMessage = [defaultMessage stringByReplacingOccurrencesOfString:replacingString withString:argumentString];
            }
        }
    } else {
        NSString *errorCode = data[@"errorCode"];
        errorMessage = [self messageFromErrorCode:errorCode];
    }
    
    if (errorMessage.length && field.length) {
        NSString *fieldLocalizedKey = [NSString stringWithFormat:@"schedules_new_job_%@", field];
        NSString *localizedField = JMLocalizedString(fieldLocalizedKey);
        if (localizedField.length == 0 || [localizedField isEqualToString:fieldLocalizedKey]) {
            NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"([a-z])([A-Z])" options:0 error:NULL];
            NSString *dividedFieldName = [regexp stringByReplacingMatchesInString:field options:0 range:NSMakeRange(0, field.length) withTemplate:@"$1 $2"];
            field = [dividedFieldName capitalizedString];
        } else {
            field = localizedField;
        }
        
        errorMessage = [field stringByAppendingFormat:@" - %@", errorMessage];
    }
    return errorMessage;
}

- (NSString *)messageFromErrorCode:(NSString *)errorCode
{
    NSString *message;
    if ([errorCode isEqualToString:@"error.duplicate.report.job.output.filename"]) {
        message = JMLocalizedString(@"schedules_error_duplicate_filename");
    } else if ([errorCode isEqualToString:@"error.length"]) {
        message = JMLocalizedString(@"schedules_error_length");
    } else if ([errorCode isEqualToString:@"error.invalid.chars"]) {
        message = JMLocalizedString(@"schedules_error_general_invalid_chars");
    } else if ([errorCode isEqualToString:@"error.report.job.output.folder.inexistent"]) {
        message = JMLocalizedString(@"schedules_error_output_folder_inexistent");
    } else if ([errorCode isEqualToString:@"error.before.current.date"]) {
        message = JMLocalizedString(@"schedules_error_date_past");
    } else if ([errorCode isEqualToString:@"error.report.job.output.folder.notwriteable"]) {
        message = JMLocalizedString(@"schedules_error_notwriteable_output_folder");
    }
    return message;
}

#pragma mark - New Schedule Metadata
- (JSScheduleMetadata *)createNewScheduleMetadataWithResourceLookup:(JMResource *)resource
{
    JSScheduleMetadata *scheduleMetadata = [JSScheduleMetadata new];

    NSString *resourceFolder = [resource.resourceLookup.uri stringByDeletingLastPathComponent];
    scheduleMetadata.folderURI = resourceFolder;
    scheduleMetadata.reportUnitURI = resource.resourceLookup.uri;
    scheduleMetadata.label = resource.resourceLookup.label;
    scheduleMetadata.baseOutputFilename = [self filenameFromLabel:resource.resourceLookup.label];
    scheduleMetadata.outputFormats = [self defaultFormats];
    scheduleMetadata.outputTimeZone = [self currentTimeZone];

    JSScheduleSimpleTrigger *trigger = [self defaultNoneTrigger];
    scheduleMetadata.trigger = trigger;
    return scheduleMetadata;
}

- (JSScheduleSimpleTrigger *)defaultSimpleTrigger
{
    JSScheduleSimpleTrigger *trigger = [JSScheduleSimpleTrigger new];
    trigger.timezone = [self currentTimeZone];
    trigger.type = JSScheduleTriggerTypeSimple;

    // start date policy
    trigger.startType = JSScheduleTriggerStartTypeImmediately;
    trigger.startDate = nil;

    // recurrence policy - default recurrence policy
    trigger.recurrenceInterval = @1;
    trigger.recurrenceIntervalUnit = JSScheduleSimpleTriggerRecurrenceIntervalTypeDay;

    // end date policy
    trigger.occurrenceCount = @1;
    trigger.endDate = nil;

    return trigger;
}

- (JSScheduleSimpleTrigger *)defaultNoneTrigger
{
    JSScheduleSimpleTrigger *trigger = [JSScheduleSimpleTrigger new];
    trigger.timezone = [self currentTimeZone];
    trigger.type = JSScheduleTriggerTypeNone;

    // start date policy
    trigger.startType = JSScheduleTriggerStartTypeImmediately;
    trigger.startDate = nil;

    // recurrence policy - this detect a none trigger
    trigger.recurrenceInterval = nil;
    trigger.recurrenceIntervalUnit = JSScheduleSimpleTriggerRecurrenceIntervalTypeNone;

    // end date policy
    trigger.occurrenceCount = @1;
    trigger.endDate = nil;

    return trigger;
}

- (JSScheduleCalendarTrigger *)defaultCalendarTrigger
{
    JSScheduleCalendarTrigger *trigger = [JSScheduleCalendarTrigger new];
    trigger.type = JSScheduleTriggerTypeCalendar;
    trigger.timezone = [self currentTimeZone];

    // start date policy
    trigger.startType = JSScheduleTriggerStartTypeImmediately;
    trigger.startDate = nil;

    // end date policy
    trigger.endDate = nil;
    return trigger;
}

- (NSString *)currentTimeZone
{
    NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
    NSString *localTimeZoneName = localTimeZone.name;
    return localTimeZoneName;
}

- (NSArray *)defaultFormats
{
    return @[kJS_CONTENT_TYPE_PDF.uppercaseString];
}

- (NSString *)filenameFromLabel:(NSString *)label
{
    NSString *filename = [label stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    return filename;
}

@end
