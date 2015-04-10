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
}

- (void)setInputControlDescriptor:(JSInputControlDescriptor *)inputControlDescriptor
{
    [super setInputControlDescriptor:inputControlDescriptor];

    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = inputControlDescriptor.dateTimeFormatValidationRule.format;

#warning NEED CHECK CONVERTING DATE WITH TIME ZONE
    NSString *value = inputControlDescriptor.state.value;
    if (value && [value length]) {
        if ([self.dateFormatter dateFromString:value]) {
            self.datePicker.date = [self.dateFormatter dateFromString:value];
        } else {
            self.datePicker.date = [NSDate date];
            inputControlDescriptor.state.value = [self.dateFormatter stringFromDate:self.datePicker.date];
        }
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

- (void) dateValueDidChanged:(id)sender
{
    self.textField.text = [self.dateFormatter stringFromDate:self.datePicker.date];
    self.inputControlDescriptor.state.value = self.textField.text;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return NO;
}

#pragma mark - Actions

- (void)doneButtonTapped:(id)sender
{
    self.textField.text = [self.dateFormatter stringFromDate:self.datePicker.date];
    [super doneButtonTapped:sender];
}

- (void)unset:(id)sender
{
    self.textField.text = nil;
    self.inputControlDescriptor.state.value = self.textField.text;
    [self.textField resignFirstResponder];
}

@end
