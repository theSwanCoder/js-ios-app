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
//  JMListItem.m
//  Jaspersoft Corporation
//

#import "JMListItem.h"

@implementation JMListItem

#pragma mark - Initialization

- (id)initWithName:(NSString *)name andValue:(NSString *)value isSelected:(BOOL)selected
{
    if (self = [self init]) {
        self.name = name;
		self.value = value;
        self.selected = selected;
    }
    
    return self;
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"Name: %@; Value: %@; Selected: %@", self.name, self.value, self.selected ? @"YES" : @"NO"];
}

@end
