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
//  JMScheduleVCRow.m
//  TIBCO JasperMobile
//

#import "JMScheduleVCRow.h"

@implementation JMScheduleVCRow

- (instancetype)initWithRowType:(JMScheduleVCRowType)type hidden:(BOOL)hidden
{
    self = [super init];
    if (self) {
        _type = type;
        _titleKey = [self titleKeyForRowType:type];
        _elementAccessibilityId = [self elementAccessibilityIdForRowType:type];
        _hidden = hidden;
    }
    return self;
}

- (instancetype)initWithRowType:(JMScheduleVCRowType)type
{
    return [self initWithRowType:type hidden:NO];
}

+ (instancetype)rowWithRowType:(JMScheduleVCRowType)type
{
    return [[self alloc] initWithRowType:type];
}

+ (instancetype)rowWithRowType:(JMScheduleVCRowType)type hidden:(BOOL)hidden
{
    return [[self alloc] initWithRowType:type hidden:hidden];
}

#pragma mark - Helpers
- (NSString *)titleKeyForRowType:(JMScheduleVCRowType)type
{
    switch(type) {
        case JMScheduleVCRowTypeLabel: {
            return @"schedules_new_job_label";
        }
        case JMScheduleVCRowTypeDescription: {
            return @"schedules_new_job_description";
        }
        case JMScheduleVCRowTypeOutputFileURI: {
            return @"schedules_new_job_baseOutputFilename";
        }
        case JMScheduleVCRowTypeOutputFolderURI: {
            return @"schedules_new_job_folderURI";
        }
        case JMScheduleVCRowTypeFormat: {
            return @"schedules_new_job_outputFormat";
        }
        case JMScheduleVCRowTypeStartDate: {
            return @"schedules_new_job_startDate";
        }
        case JMScheduleVCRowTypeEndDate: {
            return @"schedules_new_job_endDate";
        }
        case JMScheduleVCRowTypeTimeZone: {
            return @"schedules_new_job_timeZone";
        }
        case JMScheduleVCRowTypeStartImmediately: {
            return @"schedules_new_job_startType";
        }
        case JMScheduleVCRowTypeRepeatType: {
            return @"schedules_new_job_repeat_type";
        }
        case JMScheduleVCRowTypeRepeatCount: {
            return @"schedules_new_job_repeat_count";
        }
        case JMScheduleVCRowTypeRepeatTimeInterval: {
            return @"schedules_new_job_recurrenceIntervalUnit";
        }
        case JMScheduleVCRowTypeRunIndefinitely: {
            return @"schedules_new_job_run_indefinitely";
        }
        case JMScheduleVCRowTypeNumberOfRuns: {
            return @"schedules_new_job_occurrenceCount";
        }
        case JMScheduleVCRowTypeCalendarEveryMonth: {
            return @"schedules_job_calendar_every_month";
        }
        case JMScheduleVCRowTypeCalendarSelectedMonths: {
            return @"schedules_new_job_months";
        }
        case JMScheduleVCRowTypeCalendarEveryDay: {
            return @"schedules_job_calendar_every_day";
        }
        case JMScheduleVCRowTypeCalendarSelectedDays: {
            return @"schedules_new_job_weekDays";
        }
        case JMScheduleVCRowTypeCalendarDatesInMonth: {
            return @"schedules_new_job_monthDays";
        }
        case JMScheduleVCRowTypeCalendarHours: {
            return @"schedules_new_job_hours";
        }
        case JMScheduleVCRowTypeCalendarMinutes: {
            return @"schedules_new_job_minutes";
        }
    }
}

- (NSString *)elementAccessibilityIdForRowType:(JMScheduleVCRowType)type
{
    switch(type) {
        case JMScheduleVCRowTypeLabel: {
            return JMNewSchedulePageAccessibilityId;
        }
        case JMScheduleVCRowTypeDescription: {
            return JMNewSchedulePageDescriptionAccessibilityId;
        }
        case JMScheduleVCRowTypeOutputFileURI: {
            return JMNewSchedulePageOutputFileURIAccessibilityId;
        }
        case JMScheduleVCRowTypeOutputFolderURI: {
            return JMNewSchedulePageOutputFolderURIAccessibilityId;
        }
        case JMScheduleVCRowTypeFormat: {
            return JMNewSchedulePageFormatAccessibilityId;
        }
        case JMScheduleVCRowTypeStartDate: {
            return JMNewSchedulePageStartDateAccessibilityId;
        }
        case JMScheduleVCRowTypeEndDate: {
            return JMNewSchedulePageEndDateAccessibilityId;
        }
        case JMScheduleVCRowTypeTimeZone: {
            return JMNewSchedulePageTimeZoneAccessibilityId;
        }
        case JMScheduleVCRowTypeStartImmediately: {
            return JMNewSchedulePageStartImmediatelyAccessibilityId;
        }
        case JMScheduleVCRowTypeRepeatType: {
            return JMNewSchedulePageRepeatTypeAccessibilityId;
        }
        case JMScheduleVCRowTypeRepeatCount: {
            return JMNewSchedulePageRepeatCountAccessibilityId;
        }
        case JMScheduleVCRowTypeRepeatTimeInterval: {
            return JMNewSchedulePageRepeatTimeIntervalAccessibilityId;
        }
        case JMScheduleVCRowTypeRunIndefinitely: {
            return JMNewSchedulePageRunIndefinitelyAccessibilityId;
        }
        case JMScheduleVCRowTypeNumberOfRuns: {
            return JMNewSchedulePageNumberOfRunsAccessibilityId;
        }
        case JMScheduleVCRowTypeCalendarEveryMonth: {
            return JMNewSchedulePageCalendarEveryMonthAccessibilityId;
        }
        case JMScheduleVCRowTypeCalendarSelectedMonths: {
            return JMNewSchedulePageCalendarSelectedMonthsAccessibilityId;
        }
        case JMScheduleVCRowTypeCalendarEveryDay: {
            return JMNewSchedulePageCalendarEveryDayAccessibilityId;
        }
        case JMScheduleVCRowTypeCalendarSelectedDays: {
            return JMNewSchedulePageCalendarSelectedDaysAccessibilityId;
        }
        case JMScheduleVCRowTypeCalendarDatesInMonth: {
            return JMNewSchedulePageCalendarDatesInMonthAccessibilityId;
        }
        case JMScheduleVCRowTypeCalendarHours: {
            return JMNewSchedulePageCalendarHoursAccessibilityId;
        }
        case JMScheduleVCRowTypeCalendarMinutes: {
            return JMNewSchedulePageCalendarMinutesAccessibilityId;
        }
    }
}

@end
