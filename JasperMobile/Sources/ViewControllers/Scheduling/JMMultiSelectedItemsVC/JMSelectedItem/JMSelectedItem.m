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
//  JMSelectedItem.h
//  TIBCO JasperMobile
//

#import "JMSelectedItem.h"
#import "JMLocalization.h"

@implementation JMSelectedItem

- (instancetype)initWithTitleKey:(NSString *)titleKey value:(id)value accessibilityId:(NSString *)accessibilityId selected:(BOOL)selected
{
    self = [super init];
    if (self) {
        _titleKey = titleKey;
        _value = value;
        _selected = selected;
        _itemAccessibilityId = accessibilityId;
    }
    return self;
}

+ (instancetype)itemWithTitleKey:(NSString *)titleKey value:(id)value accessibilityId:(NSString *)accessibilityId selected:(BOOL)selected
{
    return [[self alloc] initWithTitleKey:titleKey value:value accessibilityId:accessibilityId selected:selected];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"item: %@, selected:%@", JMLocalizedString(self.titleKey), self.isSelected ? @"YES": @"NO"];
}

@end
