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
//  JMScheduleVCSection.h
//  TIBCO JasperMobile
//


#import "JMScheduleVCSection.h"

@interface JMScheduleVCSection()
@property (nonatomic, strong, readwrite) NSMutableArray <JMScheduleVCRow *> *internalRows;
@end

@implementation JMScheduleVCSection

- (instancetype)initWithSectionType:(JMScheduleVCSectionType)type rows:(NSArray <JMScheduleVCRow *> *)rows
{
    self = [super init];
    if (self) {
        _title = [self titleForSectionType:type];
        _type = type;
        _internalRows = [rows mutableCopy];
    }
    return self;
}

+ (instancetype)sectionWithSectionType:(JMScheduleVCSectionType)type rows:(NSArray <JMScheduleVCRow *> *)rows
{
    return [[self alloc] initWithSectionType:type rows:rows];
}

- (JMScheduleVCRow *)rowWithType:(JMScheduleVCRowType)type
{
    JMScheduleVCRow *searchRow;
    for (JMScheduleVCRow *row in self.internalRows) {
        if (row.type == type) {
            searchRow = row;
            break;
        }
    }
    if (!searchRow) {
        // TODO: handle this
    }
    return searchRow;
}

- (void)hideRowWithType:(JMScheduleVCRowType)type
{
    JMScheduleVCRow *row = [self rowWithType:type];
    row.hidden = YES;
}

- (void)showRowWithType:(JMScheduleVCRowType)type
{
    JMScheduleVCRow *row = [self rowWithType:type];
    row.hidden = NO;
}

#pragma mark - Custom Accessors
- (NSArray <JMScheduleVCRow *>*)rows
{
    NSMutableArray *rows = [NSMutableArray array];
    for (JMScheduleVCRow *row in self.internalRows) {
        if (!row.hidden) {
            [rows addObject:row];
        }
    }
    return rows;
}

#pragma mark - Helpers
- (NSString *)titleForSectionType:(JMScheduleVCSectionType)type
{
    switch(type) {
        case JMNewScheduleVCSectionTypeMain:
            return JMLocalizedString(@"schedules_new_job_section_main");
        case JMNewScheduleVCSectionTypeOutputOptions:
            return JMLocalizedString(@"schedules_new_job_section_output");
        case JMNewScheduleVCSectionTypeScheduleStart:
            return JMLocalizedString(@"schedules_new_job_section_start");
        case JMNewScheduleVCSectionTypeRecurrence:
            return JMLocalizedString(@"schedules_new_job_section_recurrence");
        case JMNewScheduleVCSectionTypeScheduleEnd:
            return JMLocalizedString(@"schedules_new_job_section_end");
        case JMNewScheduleVCSectionTypeHolidays:
            return JMLocalizedString(@"schedules_new_job_section_holiday");
        default:
            return nil;
    }
}

@end
