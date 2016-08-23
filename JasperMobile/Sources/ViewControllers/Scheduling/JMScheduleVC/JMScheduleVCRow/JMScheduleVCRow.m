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
#import "JMLocalization.h"

@implementation JMScheduleVCRow

- (instancetype)initWithRowType:(JMScheduleVCRowType)type hidden:(BOOL)hidden
{
    self = [super init];
    if (self) {
        _type = type;
        _title = [self titleForRowType:type];
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
- (NSString *)titleForRowType:(JMScheduleVCRowType)type
{
    NSString *title;
    switch(type) {
        case JMScheduleVCRowTypeLabel: {
            title = JMLocalizedString(@"schedules_new_job_label");
            break;
        }
        case JMScheduleVCRowTypeDescription: {
            title =JMLocalizedString(@"schedules_new_job_description");
            break;
        }
        case JMScheduleVCRowTypeOutputFileURI: {
            title = JMLocalizedString(@"schedules_new_job_baseOutputFilename");
            break;
        }
        case JMScheduleVCRowTypeOutputFolderURI: {
            title = JMLocalizedString(@"schedules_new_job_folderURI");
            break;
        }
        case JMScheduleVCRowTypeFormat: {
            title = JMLocalizedString(@"schedules_new_job_outputFormat");
            break;
        }
        case JMScheduleVCRowTypeStartDate: {
            title = JMLocalizedString(@"schedules_new_job_startDate");
            break;
        }
        case JMScheduleVCRowTypeEndDate: {
            title = JMLocalizedString(@"schedules_new_job_endDate");
            break;
        }
        case JMScheduleVCRowTypeTimeZone: {
            title = @"Time Zone";
            break;
        }
        case JMScheduleVCRowTypeStartImmediately: {
            title = JMLocalizedString(@"schedules_new_job_startType");
            break;
        }
        case JMScheduleVCRowTypeRepeatType: {
            title = JMLocalizedString(@"schedules_new_job_repeat_type");
            break;
        }
        case JMScheduleVCRowTypeRepeatCount: {
            title = JMLocalizedString(@"schedules_new_job_repeat_count");
            break;
        }
        case JMScheduleVCRowTypeRepeatTimeInterval: {
            title = JMLocalizedString(@"schedules_new_job_recurrenceIntervalUnit");
            break;
        }
        case JMScheduleVCRowTypeRunIndefinitely: {
            title = JMLocalizedString(@"schedules_new_job_run_indefinitely");
            break;
        }
        case JMScheduleVCRowTypeNumberOfRuns: {
            title = JMLocalizedString(@"schedules_new_job_occurrenceCount");
            break;
        }
        case JMScheduleVCRowTypeCalendarEveryMonth: {
            title = JMLocalizedString(@"schedules_job_calendar_every_month");
            break;
        }
        case JMScheduleVCRowTypeCalendarSelectedMonths: {
            title = JMLocalizedString(@"schedules_new_job_months");
            break;
        }
        case JMScheduleVCRowTypeCalendarEveryDay: {
            title = JMLocalizedString(@"schedules_job_calendar_every_day");
            break;
        }
        case JMScheduleVCRowTypeCalendarSelectedDays: {
            title = JMLocalizedString(@"schedules_new_job_weekDays");
            break;
        }
        case JMScheduleVCRowTypeCalendarDatesInMonth: {
            title = JMLocalizedString(@"schedules_new_job_monthDays");
            break;
        }
        case JMScheduleVCRowTypeCalendarHours: {
            title = JMLocalizedString(@"schedules_new_job_hours");
            break;
        }
        case JMScheduleVCRowTypeCalendarMinutes: {
            title = JMLocalizedString(@"schedules_new_job_minutes");
            break;
        }
    }
    return title;
}

@end
