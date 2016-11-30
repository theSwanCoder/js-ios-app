/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2016 TIBCO Software, Inc. All rights reserved.
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
//  JMScheduleCell.m
//  TIBCO JasperMobile
//

#import "JMScheduleCell.h"
#import "JMUtils.h"

@interface JMScheduleCell ()
@property(nonatomic, weak) IBOutlet UILabel *titleLabel;
@property(nonatomic, weak) IBOutlet UILabel *errorLabel;
@property(nonatomic, weak) IBOutlet NSLayoutConstraint *titleLabelCenterYConstraint;
@property(nonatomic, weak) IBOutlet NSLayoutConstraint *textFieldCenterYConstraint;
@end

@implementation JMScheduleCell
- (void)setScheduleRow:(JMScheduleVCRow *)scheduleRow {
    if (_scheduleRow != scheduleRow) {
        _scheduleRow = scheduleRow;
        self.titleLabel.text = scheduleRow.title;
    }
}

#pragma mark - Public API
- (void)showErrorMessage:(NSString *)message
{
    if (message) {
        self.errorLabel.textColor = [UIColor redColor];
    } else {
        self.errorLabel.textColor = [UIColor grayColor];
        message = self.scheduleRow.hintMessage;
    }
    self.errorLabel.text = message;
    self.titleLabelCenterYConstraint.constant = (message.length == 0) ? 0 : -10;
    self.textFieldCenterYConstraint.constant = (message.length == 0) ? 0 : -10;
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(scheduleCellDidStartChangeValue:)]) {
        [self.delegate scheduleCellDidStartChangeValue:self];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(scheduleCellDidEndChangeValue:)]) {
        [self.delegate scheduleCellDidEndChangeValue:self];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *currentString = textField.text;

    NSString *changedString;

    if (range.length == 1) {
        // remove symbol
        changedString = [currentString stringByReplacingCharactersInRange:range withString:@""];
    } else if (range.location == 0 && range.length > 1) {
        // autocompleted text
        changedString = string;
    } else {
        // add symbol
        NSRange firstPartOfStringRange = NSMakeRange(0, range.location);
        NSString *firstPartOfString = [currentString substringWithRange:firstPartOfStringRange];

        NSRange lastPartOfStringRange = NSMakeRange(range.location, currentString.length - range.location);
        NSString *lastPartOfString = [currentString substringWithRange:lastPartOfStringRange];

        changedString = [NSString stringWithFormat:@"%@%@%@", firstPartOfString, string, lastPartOfString];
    }

    if ([self.delegate respondsToSelector:@selector(scheduleCell:didChangeValue:)]) {
        [self.delegate scheduleCell:self didChangeValue:changedString];
    }

    JMLog(@"changed string: %@", changedString);

    return YES;
}

@end