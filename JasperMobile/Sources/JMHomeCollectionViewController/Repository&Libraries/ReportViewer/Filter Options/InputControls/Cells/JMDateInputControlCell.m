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

@implementation JMDateInputControlCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self datePicker].datePickerMode = UIDatePickerModeDate;
        self.textField.inputView = self.datePicker;
        self.textField.inputAccessoryView = self.datePickerToolbar;
    }

    return self;
}

- (void)setValue:(id)value
{
    if (value && [value length]) {
        if ([self.dateFormatter dateFromString:value]) {
            [super setValue:value];
            self.date = [self.dateFormatter dateFromString:value];
        } else {
            self.value = [self.dateFormatter stringFromDate:[NSDate date]];
        }
    }
}

- (void)setInputControlDescriptor:(JSInputControlDescriptor *)inputControlDescriptor
{
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = inputControlDescriptor.validationRules.dateTimeFormatValidationRule.format;
    [super setInputControlDescriptor:inputControlDescriptor];
}

- (UIDatePicker *)datePicker
{
    if (!_datePicker) {
        _datePicker = [[UIDatePicker alloc] init];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            _datePicker.autoresizingMask = UIViewAutoresizingNone;
        } else {
            _datePicker.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        }
        [_datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
        [_datePicker sizeToFit];
    }

    return _datePicker;
}

- (UIToolbar *)datePickerToolbar
{
    if (_datePickerToolbar) {
        _datePickerToolbar = [[UIToolbar alloc] init];
        _datePickerToolbar.barStyle = UIBarStyleBlackOpaque;
        _datePickerToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_datePickerToolbar sizeToFit];
        
        [_datePickerToolbar setItems:[self toolbarItems]];
    }
    return _datePickerToolbar;
}

- (NSArray *)toolbarItems
{
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    UIBarButtonItem *unset = [[UIBarButtonItem alloc] initWithTitle:JMCustomLocalizedString(@"ic.title.unset", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(unset:)];
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    
    // Used only for adding flexible space between buttons
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    return @[cancel, unset, flexibleSpace, done];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.datePicker.date = self.date;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return NO;
}

#pragma mark - Actions

- (void)done:(id)sender
{
    self.textField.text = [self.dateFormatter stringFromDate:self.date];
    self.value = self.textField.text;

    [self updateDisplayingOfErrorMessage:nil];
    [self hideDatePicker];
}

- (void)unset:(id)sender
{
    self.value = nil;
    self.textField.text = nil;
    [self hideDatePicker];
}

- (void)cancel:(id)sender
{
    [self hideDatePicker];
}

- (void)dateChanged:(id)sender
{
    self.date = self.datePicker.date;
}

#pragma mark - Private

- (void)hideDatePicker
{
    [self.textField resignFirstResponder];
}

@end
