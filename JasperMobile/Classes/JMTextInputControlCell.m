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
//  JMTextInputControlCell.m
//  Jaspersoft Corporation
//

#import "JMTextInputControlCell.h"

@implementation JMTextInputControlCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        UITextField *textField = self.textField;
        textField.delegate = self;
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10.0f, 0)];
        self.textField.leftView = leftView;
        self.textField.leftViewMode = UITextFieldViewModeAlways;
        self.textField.background = [self.textField.background resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10.0f, 0, 10.0f)];
    }

    return self;
}

- (void)setInputControlDescriptor:(JSInputControlDescriptor *)inputControlDescriptor
{
    [super setInputControlDescriptor:inputControlDescriptor];
    self.value = inputControlDescriptor.state.value;
    self.textField.text = self.value;
}

- (UITextField *)textField
{
    return (UITextField *) [self viewWithTag:2];
}

- (void)disableCell
{
    [super disableCell];
    self.textField.enabled = NO;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [textField resignFirstResponder];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *value = [textField.text stringByReplacingCharactersInRange:range withString:string];
    self.value = value.length ? value : nil;
    self.inputControlDescriptor.state.value = self.value;

    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([self dismissError]) {
        [self.textField becomeFirstResponder];
    }
}

@end
