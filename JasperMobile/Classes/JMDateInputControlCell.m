/*
 * JasperMobile for iOS
 * Copyright (C) 2011 - 2013 Jaspersoft Corporation. All rights reserved.
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

static UIToolbar *datePickerToolbar;
static UIDatePicker *datePicker;

#import "JMDateInputControlCell.h"
#import "JMLocalization.h"

@implementation JMDateInputControlCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self datePicker].datePickerMode = UIDatePickerModeDate;
        UITextField *textField = self.textField;
        textField.inputView = [self datePicker];
        textField.leftView = nil;
    }

    return self;
}

- (UIDatePicker *)datePicker
{
    if (!datePicker) {
        datePicker = [[UIDatePicker alloc] init];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            datePicker.autoresizingMask = UIViewAutoresizingNone;
        } else {
            datePicker.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        }
        
        [datePicker sizeToFit];
    }

    return datePicker;
}

- (NSDateFormatter *)dateFormatter
{
    if (!_dateFormatter) _dateFormatter = [[NSDateFormatter alloc] init];
    return _dateFormatter;
}

- (void)setInputControlDescriptor:(JSInputControlDescriptor *)inputControlDescriptor
{
    [super setInputControlDescriptor:inputControlDescriptor];
    self.dateFormatter.dateFormat = inputControlDescriptor.validationRules.dateTimeFormatValidationRule.format;

    if ([self.value length]) {
        self.date = [self.dateFormatter dateFromString:self.value];

        if (!self.date) {
            self.date = [NSDate date];
            self.value = [self.dateFormatter stringFromDate:self.date];
            self.textField.text = self.value;
        }
    } else {
        self.date = [NSDate date];
    }
}

- (void)setSelfAsDelegateForPickerToolbar:(UIToolbar *)pickerToolbar
{
    for (UIBarButtonItem *item in pickerToolbar.items) {
        item.target = self;
    }
}

- (UIToolbar *)pickerToolbar
{
    UIToolbar *pickerToolbar = [[UIToolbar alloc] init];
    pickerToolbar.barStyle = UIBarStyleBlackOpaque;
    pickerToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [pickerToolbar sizeToFit];

    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    UIBarButtonItem *unset = [[UIBarButtonItem alloc] initWithTitle:JMCustomLocalizedString(@"ic.title.unset", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(unset:)];
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];

    // Used only for adding flexible space between buttons
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    [pickerToolbar setItems:@[cancel, unset, flexibleSpace, done]];

    return pickerToolbar;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.datePicker.date = self.date;
    
    self.datePicker.frame = CGRectMake(0, 0, self.datePicker.frame.size.width, self.datePicker.frame.size.height);

    // Check if this IC is not a target of DatePicker
    if ([self.datePicker allTargets].anyObject != self) {
        SEL dateChangedSelector = @selector(dateChanged:);
        // If yes then remove all previously added targets
        [self.datePicker removeTarget:nil action:dateChangedSelector forControlEvents:UIControlEventValueChanged];
        // And add self as a new one
        [self.datePicker addTarget:self action:dateChangedSelector forControlEvents:UIControlEventValueChanged];
    }
}

#pragma mark - UIResponder

- (UIView *)inputAccessoryView
{
    if (!datePickerToolbar) {
        datePickerToolbar = [self pickerToolbar];
    } else {
        [self setSelfAsDelegateForPickerToolbar:datePickerToolbar];
    }

    return datePickerToolbar;
}

#pragma mark - Actions

- (void)done:(id)sender
{
    self.textField.text = [self.dateFormatter stringFromDate:self.date];
    self.value = self.textField.text;

    [self dismissError];
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
