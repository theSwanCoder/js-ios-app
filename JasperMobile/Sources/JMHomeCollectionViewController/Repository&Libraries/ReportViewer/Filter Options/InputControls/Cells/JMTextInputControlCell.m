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
//  JMTextInputControlCell.m
//  Jaspersoft Corporation
//

#import "JMTextInputControlCell.h"

@implementation JMTextInputControlCell

- (void)setInputControlDescriptor:(JSInputControlDescriptor *)inputControlDescriptor
{
    [super setInputControlDescriptor:inputControlDescriptor];
    self.textField.text = inputControlDescriptor.state.value;
    UIToolbar *datePickerToolbar = [[UIToolbar alloc] init];
    datePickerToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [datePickerToolbar setItems:[self inputAccessoryViewToolbarItems]];
    [datePickerToolbar sizeToFit];
    
    self.textField.inputAccessoryView = datePickerToolbar;

}

- (NSArray *)inputAccessoryViewToolbarItems
{
    NSMutableArray *items = [NSMutableArray arrayWithArray:[self leftInputAccessoryViewToolbarItems]];
    [items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
    [items addObjectsFromArray:[self rightInputAccessoryViewToolbarItems]];
    return items;
}

- (NSArray *)leftInputAccessoryViewToolbarItems
{
    return [NSArray array];
}

- (NSArray *)rightInputAccessoryViewToolbarItems
{
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonTapped:)];
    return @[done];
}

- (void)setEnabledCell:(BOOL)enabled
{
    [super setEnabledCell:enabled];
    self.textField.enabled = enabled;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [textField resignFirstResponder];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([self.detailTextLabel.text length]) {
        [self updateDisplayingOfErrorMessage:nil];
    }
    NSString *value = [textField.text stringByReplacingCharactersInRange:range withString:string];
    self.inputControlDescriptor.state.value = value.length ? value : nil;

    return YES;
}

#pragma mark - Actions

- (void)doneButtonTapped:(id)sender
{
    self.inputControlDescriptor.state.value = self.textField.text;
    
    if ([self.detailTextLabel.text length]) {
        [self updateDisplayingOfErrorMessage:nil];
    }
    [self.textField resignFirstResponder];
}

@end
