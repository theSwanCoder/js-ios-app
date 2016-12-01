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
//  JMTextInputControlCell.m
//  TIBCO JasperMobile
//

#import "JMTextInputControlCell.h"
#import "UITableViewCell+Additions.h"

@implementation JMTextInputControlCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.textField.inputAccessoryView = [self toolbarForInputAccessoryView];
}

- (void)setInputControlDescriptor:(JSInputControlDescriptor *)inputControlDescriptor
{
    [super setInputControlDescriptor:inputControlDescriptor];
    self.textField.text = inputControlDescriptor.state.value;
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

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self updateValue:textField.text.length ? textField.text : @""];
    self.inputControlDescriptor.state.error = nil;
    [self updateDisplayingOfErrorMessage];
}

#pragma mark - Actions
- (void)doneButtonTapped:(id)sender
{
    [self updateValue:self.textField.text];
    [self.textField resignFirstResponder];
}
@end
