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
//  JMMultiSelectInputControlCell.m
//  Jaspersoft Corporation
//

#import "JMMultiSelectInputControlCell.h"

@implementation JMMultiSelectInputControlCell

@synthesize value = _value;

- (void)setValue:(id)value
{
    NSInteger numberOfValues = [value count];
    NSArray *allValues = [value allObjects];

    allValues = [allValues sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[obj1 label] compare:[obj2 label]];
    }];

    if (numberOfValues > 0) {
        JSInputControlOption *firstOption = [allValues objectAtIndex:0];
        NSMutableString *valuesAsStrings = [NSMutableString stringWithFormat:@"%@", firstOption.label];
        NSMutableArray *selectedValues = [NSMutableArray arrayWithObject:firstOption.value];
        
        for (NSUInteger i = 1; i < numberOfValues; i++) {
            JSInputControlOption *option = [allValues objectAtIndex:i];
            [valuesAsStrings appendFormat:@", %@", option.label];
            [selectedValues addObject:option.value];
        }

        _value = selectedValues;
        self.detailLabel.text = valuesAsStrings;
    } else {
        _value = nil;
        self.detailLabel.text = JS_IC_NOTHING_SUBSTITUTE_LABEL;
    }
}

@end
