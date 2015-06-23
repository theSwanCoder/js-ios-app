/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2014 TIBCO Software, Inc. All rights reserved.
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

@end

@implementation JMDateInputControlCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.textField.inputView = self.datePicker;
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
}

- (void)setInputControlDescriptor:(JSInputControlDescriptor *)inputControlDescriptor
{
    [super setInputControlDescriptor:inputControlDescriptor];
    self.dateFormatter.dateFormat = inputControlDescriptor.dateTimeFormatValidationRule.format;

    NSString *value = inputControlDescriptor.state.value;
    if (value.length) {
        NSDate *date = [self.dateFormatter dateFromString:value];
        if (!date) {
            date = [NSDate date];
        }
        self.datePicker.date = date;
        self.textField.text = [JMUtils localizedStringFromDate:self.datePicker.date];
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
    UIBarButtonItem *unset = [[UIBarButtonItem alloc] initWithTitle:JMCustomLocalizedString(@"report.viewer.options.ic.title.unset", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(unset:)];
    [items addObject:unset];
    return items;
}

#pragma mark - UIDatePicker action
- (void) dateValueDidChanged:(id)sender
{
    self.textField.text = [JMUtils localizedStringFromDate:self.datePicker.date];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // override a super realization with an empty realization
}

#pragma mark - Actions

- (void)doneButtonTapped:(id)sender
{
    self.inputControlDescriptor.state.value = [self.dateFormatter stringFromDate:self.datePicker.date];
    self.inputControlDescriptor.state.error = nil;
    [self updateDisplayingOfErrorMessage];

    [self.textField resignFirstResponder];
}

- (void)unset:(id)sender
{
    NSDate *date = [self.dateFormatter dateFromString:self.inputControlDescriptor.state.value];
    self.textField.text = [JMUtils localizedStringFromDate:date];
    [self.textField resignFirstResponder];
}

@end
