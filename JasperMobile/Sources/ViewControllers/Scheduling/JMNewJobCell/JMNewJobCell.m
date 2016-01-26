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
//  JMNewJobCell.m
//  TIBCO JasperMobile
//

#import "JMNewJobCell.h"


@implementation JMNewJobCell

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *currentString = textField.text;

    NSString *changedString;

    if (range.length) {
        // remove symbol
        NSRange lastSymbolRange = NSMakeRange(currentString.length - 1, 1);
        changedString = [currentString stringByReplacingCharactersInRange:lastSymbolRange withString:@""];
    } else {
        // add symbol
        changedString = [currentString stringByAppendingString:string];
    }

    if ([self.delegate respondsToSelector:@selector(jobCell:didChangeValue:)]) {
        [self.delegate jobCell:self didChangeValue:changedString];
    }

    return YES;
}

@end