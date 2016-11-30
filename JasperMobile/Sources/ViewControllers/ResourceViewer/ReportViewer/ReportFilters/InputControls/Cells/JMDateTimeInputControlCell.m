/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2015 TIBCO Software, Inc. All rights reserved.
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
//  TIBCO JasperMobile
//

#import "JMDateTimeInputControlCell.h"
#import "UITableViewCell+Additions.h"
#import "JMLocalization.h"

@implementation JMDateTimeInputControlCell
- (NSArray *)rightInputAccessoryViewToolbarItems
{
    NSMutableArray *items = [NSMutableArray arrayWithArray:[super rightInputAccessoryViewToolbarItems]];
    UIBarButtonItem *datePickerSwitcher = [[UIBarButtonItem alloc] initWithTitle:JMLocalizedString(@"report_viewer_options_ic_title_time") style:UIBarButtonItemStylePlain target:self action:@selector(datePickerSwitched:)];
    [items insertObject:datePickerSwitcher atIndex:items.count - 1];
    return items;
}

#pragma mark - Actions

- (void)datePickerSwitched:(UIBarButtonItem *)sender
{
    if (self.datePicker.datePickerMode == UIDatePickerModeDate) {
        self.datePicker.datePickerMode = UIDatePickerModeTime;
        sender.title = JMLocalizedString(@"report_viewer_options_ic_title_date");
    } else {
        self.datePicker.datePickerMode = UIDatePickerModeDate;
        sender.title = JMLocalizedString(@"report_viewer_options_ic_title_time");
    }
}

@end
