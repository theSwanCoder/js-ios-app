/*
 * JasperMobile for iOS
 * Copyright (C) 2011 - 2014 Jaspersoft Corporation. All rights reserved.
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
//  JMDateTimeInputControlCell.m
//  Jaspersoft Corporation
//

#import "JMDateTimeInputControlCell.h"
#import "JMLocalization.h"

static UIToolbar *dateTimePickerToolbar;

typedef enum {
    kJMDateType,
    kJMTimeType
} JMDatePickerType;

@interface JMDateTimeInputControlCell()
@property (nonatomic, assign) JMDatePickerType datePickerType;
@property (nonatomic, weak) UIBarButtonItem *datePickerSwitcher;
@end

@implementation JMDateTimeInputControlCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.datePickerType = kJMDateType;
    }

    return self;
}

- (void)setInputControlDescriptor:(JSInputControlDescriptor *)inputControlDescriptor
{
    [super setInputControlDescriptor:inputControlDescriptor];
    self.time = self.date;
}

#pragma mark - UIResponder

- (UIView *)inputAccessoryView
{
    if (!dateTimePickerToolbar) {
        dateTimePickerToolbar = [self pickerToolbar];

        NSMutableArray *items = [dateTimePickerToolbar.items mutableCopy];
        UIBarButtonItem *datePickerSwitcher = [[UIBarButtonItem alloc] initWithTitle:JMCustomLocalizedString(@"ic.title.time", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(datePickerSwitched:)];

        [items insertObject:datePickerSwitcher atIndex:items.count - 1];
        dateTimePickerToolbar.items = items;

        self.datePickerSwitcher = datePickerSwitcher;
    } else {
        [self setSelfAsDelegateForPickerToolbar:dateTimePickerToolbar];
    }

    return dateTimePickerToolbar;
}

#pragma mark - Actions

- (void)done:(id)sender
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *time = [calendar components:NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:self.time];
    NSDateComponents *date = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:self.date];

    date.hour = time.hour;
    date.minute = time.minute;

    self.date = [calendar dateFromComponents:date];
    [super done:sender];
}

- (void)datePickerSwitched:(id)sender
{
    if (self.datePickerType == kJMDateType) {
        self.datePicker.date = self.time;
        self.datePicker.datePickerMode = UIDatePickerModeTime;
        self.datePickerType = kJMTimeType;
        self.datePickerSwitcher.title = JMCustomLocalizedString(@"ic.title.date", nil);
    } else {
        self.datePicker.date = self.date;
        self.datePicker.datePickerMode = UIDatePickerModeDate;
        self.datePickerType = kJMDateType;
        self.datePickerSwitcher.title = JMCustomLocalizedString(@"ic.title.time", nil);
    }
}

- (void)dateChanged:(id)sender
{
    if (self.datePickerType == kJMDateType) {
        self.date = self.datePicker.date;
    } else {
        self.time = self.datePicker.date;
    }
}

@end
