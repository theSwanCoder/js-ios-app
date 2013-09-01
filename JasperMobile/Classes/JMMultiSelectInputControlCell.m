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
//  JMMultiSelectInputControlCell.m
//  Jaspersoft Corporation
//

#import "JMMultiSelectInputControlCell.h"
#import "JMListValue.h"

@implementation JMMultiSelectInputControlCell

- (NSString *)isListItem
{
    return @"YES";
}

- (BOOL)needsToUpdateInputControlQueryData
{
    NSInteger type = self.inputControlWrapper.type;
    return type == self.constants.IC_TYPE_MULTI_SELECT_QUERY || type == self.constants.IC_TYPE_MULTI_SELECT_QUERY_CHECKBOX;
}

- (void)setValue:(id)value
{
    NSInteger numberOfValues = [value count];
    NSArray *allValues = [value allObjects];

    [allValues sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[obj1 name] compare:[obj2 name]];
    }];

    if (numberOfValues > 0) {
        NSMutableString *selectedValues = [NSMutableString stringWithFormat:@"%@", [[allValues objectAtIndex:0] name]];
        
        for (NSUInteger i = 1; i < numberOfValues; i++) {
            [selectedValues appendFormat:@", %@", [[allValues objectAtIndex:i] name]];
        }
        
        self.detailLabel.text = selectedValues;
    } else {
        self.detailLabel.text = self.inputControlWrapper.NOTHING_SUBSTITUTE_LABEL;
    }
}

@end
