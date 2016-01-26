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
//  JMScheduleJob.m
//  TIBCO JasperMobile
//

#import "JMScheduleJob.h"
#import "JMScheduleTrigger.h"

@interface JMScheduleJob()
@end

@implementation JMScheduleJob

#pragma mark - Object Lifecycle
- (instancetype)initWithReportURI:(NSString *)reportURI
                            label:(NSString *)label
                   outputFilename:(NSString *)outputFilename
                        folderURI:(NSString *)folderURI
                           format:(NSString *)format
                        startDate:(NSDate *)startDate
{
    self = [super init];
    if (self) {
        _reportUnitURI = reportURI;
        _label = label;
        _baseOutputFilename = outputFilename;
        _folderURI = folderURI;
        _outputFormat = format;
        _startDate = startDate;
    }
    return self;
}

+ (instancetype)jobWithReportURI:(NSString *)reportURI
                           label:(NSString *)label
                  outputFilename:(NSString *)outputFilename
                       folderURI:(NSString *)folderURI
                          format:(NSString *)format
                       startDate:(NSDate *)startDate
{
    return [[self alloc] initWithReportURI:reportURI
                                     label:label
                            outputFilename:outputFilename
                                 folderURI:folderURI
                                    format:format
                                 startDate:startDate];
}

#pragma mark - Custom Accessors
- (JMScheduleTrigger *)trigger
{
    if (!_trigger) {
        _trigger = [self simpleTrigger];
    }
    return _trigger;
}

- (NSDate *)startDate
{
    if (!_startDate) {
        _startDate = [NSDate date];
    }
    return _startDate;
}

- (NSString *)outputTimeZone
{
    if (!_outputTimeZone) {
        _outputTimeZone = @"Europe/Helsinki";
    }
    return _outputTimeZone;
}

- (NSString *)folderURI
{
    if (!_folderURI) {
        _folderURI = @"/public/Samples/Reports";
    }
    return _folderURI;
}

#pragma mark - Public API
- (NSData *)jobAsData
{
    NSDictionary *triggerJSON = [self triggerAsJSON:self.trigger];

    NSDictionary *json = @{
            @"label" : self.label,
            @"trigger" : triggerJSON,
            @"source" : @{
                    @"reportUnitURI" : self.reportUnitURI,
            },
            @"baseOutputFilename" : self.baseOutputFilename,
            @"repositoryDestination" : @{
                @"folderURI" : self.folderURI,
            },
            @"outputTimeZone" : self.outputTimeZone,
            @"outputFormats" : @{
                @"outputFormat" : @[self.outputFormat]
            }
    };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:0 error:nil];
    return jsonData;
}

#pragma mark - Helpers
- (JMScheduleTrigger *)simpleTrigger
{
    JMScheduleTrigger *simpleTrigger = [JMScheduleTrigger new];
    simpleTrigger.timezone = self.outputTimeZone;
    simpleTrigger.startType = 2;
    simpleTrigger.occurrenceCount = 1;
    simpleTrigger.startDate = self.startDate;
    return simpleTrigger;
}

- (NSDictionary *)triggerAsJSON:(JMScheduleTrigger *)trigger
{
    NSString *dateAsString = [self dateStringFromDate:trigger.startDate];
    NSDictionary *triggerAsJSON = @{
        @"simpleTrigger" : @{
                @"timezone" : trigger.timezone,
                @"startType" : @(trigger.startType),
                @"startDate" : dateAsString,
                @"occurrenceCount" : @(trigger.occurrenceCount),
        }
    };
    return triggerAsJSON;
}

- (NSString *)dateStringFromDate:(NSDate *)date
{
    NSDateFormatter* outputFormatter = [[NSDateFormatter alloc]init];
    [outputFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];

    // Increase to 1 min for test purposes
    // TODO: remove this
    NSTimeInterval timeInterval = [date timeIntervalSince1970];
    timeInterval += 60;
    date = [NSDate dateWithTimeIntervalSince1970:timeInterval];

    NSString *dateString = [outputFormatter stringFromDate:date];
    return dateString;
}

@end