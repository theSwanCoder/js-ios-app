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
//  JMDateInputControlCell.m
//  TIBCO JasperMobile
//

#import "JMDateInputControlCell.h"
#import "UITableViewCell+Additions.h"

@interface JMDateInputControlCell()

@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDateFormatter *fieldDateFormatter;

@end

@implementation JMDateInputControlCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.textField.inputView = self.datePicker;
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.fieldDateFormatter = [[NSDateFormatter alloc] init];
}

- (void)setInputControlDescriptor:(JSInputControlDescriptor *)inputControlDescriptor
{
    [super setInputControlDescriptor:inputControlDescriptor];
    self.dateFormatter.dateFormat = inputControlDescriptor.dateTimeFormatValidationRule.format;

    if ([inputControlDescriptor.type isEqualToString:@"singleValueDate"]) {
        self.fieldDateFormatter = [JMUtils formatterForSimpleDate];
    } else if([inputControlDescriptor.type isEqualToString:@"singleValueTime"]) {
        self.fieldDateFormatter = [JMUtils formatterForSimpleTime];
    } else if ([inputControlDescriptor.type isEqualToString:@"singleValueDatetime"]) {
        self.fieldDateFormatter = [JMUtils formatterForSimpleDateTime];
    }

    NSString *value = inputControlDescriptor.state.value;
    if (value.length) {
        NSDate *date = [self.dateFormatter dateFromString:value];
        if (!date) {
            date = [NSDate date];
        }
        self.datePicker.date = date;
        self.textField.text = [self.fieldDateFormatter stringFromDate:self.datePicker.date];
    }
}

- (UIDatePicker *)datePicker
{
    if (!_datePicker) {
        _datePicker = [[UIDatePicker alloc] init];
        _datePicker.datePickerMode = UIDatePickerModeDate;
        [_datePicker addTarget:self action:@selector(dateValueDidChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _datePicker;
}

- (NSArray *)leftInputAccessoryViewToolbarItems
{
    NSMutableArray *items = [NSMutableArray arrayWithArray:[super leftInputAccessoryViewToolbarItems]];
    UIBarButtonItem *unset = [[UIBarButtonItem alloc] initWithTitle:JMCustomLocalizedString(@"report_viewer_options_ic_title_unset", nil) style:UIBarButtonItemStylePlain target:self action:@selector(unset:)];
    [items addObject:unset];
    return items;
}

#pragma mark - UIDatePicker action
- (void) dateValueDidChanged:(id)sender
{
    self.textField.text = [self.fieldDateFormatter stringFromDate:self.datePicker.date];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // override a super realization with an empty realization
}

#pragma mark - Actions

- (void)doneButtonTapped:(id)sender
{
    [self updateValue:[self.dateFormatter stringFromDate:self.datePicker.date]];
    self.inputControlDescriptor.state.error = nil;
    [self updateDisplayingOfErrorMessage];

    [self.textField resignFirstResponder];
}

- (void)unset:(id)sender
{
    [self updateValue:nil];
    self.inputControlDescriptor.state.error = nil;
    [self updateDisplayingOfErrorMessage];

    self.textField.text = @"";

    [self.textField resignFirstResponder];
}

@end
