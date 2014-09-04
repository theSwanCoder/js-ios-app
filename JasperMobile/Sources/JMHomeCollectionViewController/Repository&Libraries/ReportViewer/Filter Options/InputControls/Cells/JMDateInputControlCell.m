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
//  JMDateInputControlCell.m
//  Jaspersoft Corporation
//

#import "JMDateInputControlCell.h"

@interface JMDateInputControlCell()

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation JMDateInputControlCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.textField.inputView = self.datePicker;
    
    UIToolbar *datePickerToolbar = [[UIToolbar alloc] init];
    datePickerToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [datePickerToolbar setItems:[self toolbarItems]];
    [datePickerToolbar sizeToFit];

    self.textField.inputAccessoryView = datePickerToolbar;
}

- (void)setInputControlDescriptor:(JSInputControlDescriptor *)inputControlDescriptor
{
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = inputControlDescriptor.validationRules.dateTimeFormatValidationRule.format;
    
    NSString *value = inputControlDescriptor.state.value;
    if (value && [value length]) {
        if ([self.dateFormatter dateFromString:value]) {
            self.datePicker.date = [self.dateFormatter dateFromString:value];
        } else {
            self.datePicker.date = [NSDate date];
            inputControlDescriptor.state.value = [self.dateFormatter stringFromDate:self.datePicker.date];
        }
    }

    [super setInputControlDescriptor:inputControlDescriptor];
}

- (UIDatePicker *)datePicker
{
    if (!_datePicker) {
        _datePicker = [[UIDatePicker alloc] init];
        _datePicker.datePickerMode = UIDatePickerModeDate;
    }
    return _datePicker;
}

- (NSArray *)toolbarItems
{
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    UIBarButtonItem *unset = [[UIBarButtonItem alloc] initWithTitle:JMCustomLocalizedString(@"ic.title.unset", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(unset:)];
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    return @[cancel, unset, flexibleSpace, done];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return NO;
}

#pragma mark - Actions

- (void)done:(id)sender
{
    self.textField.text = [self.dateFormatter stringFromDate:self.datePicker.date];
    self.inputControlDescriptor.state.value = self.textField.text;
    
    if ([self.detailTextLabel.text length]) {
        [self updateDisplayingOfErrorMessage:nil];
    }
    [self hideDatePicker];
}

- (void)unset:(id)sender
{
    self.textField.text = nil;
    self.inputControlDescriptor.state.value = self.textField.text;
    [self hideDatePicker];
}

- (void)cancel:(id)sender
{
    [self hideDatePicker];
}

- (void)hideDatePicker
{
    [self.textField resignFirstResponder];
}

@end
