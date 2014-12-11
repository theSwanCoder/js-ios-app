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
//  JMNumberInputControlCell.m
//  TIBCO JasperMobile
//

#import "JMNumberInputControlCell.h"

@implementation JMNumberInputControlCell

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString *decimalSeparator = [[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator];
    if ([string isEqualToString:decimalSeparator]) {
        if (range.location == 0 || [textField.text rangeOfString:decimalSeparator].location != NSNotFound) {
            return NO;
        }
    }
    NSString *stringSet = [NSString stringWithFormat:@"1234567890%@", decimalSeparator];
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:stringSet] invertedSet];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    if ([string isEqualToString:filtered]) {
        return YES;
    }
    return NO;
}

@end
