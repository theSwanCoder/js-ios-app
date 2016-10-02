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


#import "JMServerOption.h"

@implementation JMServerOption

- (instancetype)initWithTitle:(NSString *)title
                  optionValue:(id)optionValue
               cellIdentifier:(NSString *)cellIdentifier
                     editable:(BOOL)editable
       elementPageAccessibilityId:(NSString *)elementPageAccessibilityId
                    mandatory:(BOOL)mandatory
{
    self = [super init];
    if (self) {
        _titleString = title;
        _optionValue = optionValue;
        _cellIdentifier = cellIdentifier;
        _editable = editable;
        _elementPageAccessibilityId = elementPageAccessibilityId;
        _mandatory = mandatory;
    }
    return self;
}

+ (instancetype)optionWithTitle:(NSString *)title
                    optionValue:(id)optionValue
                 cellIdentifier:(NSString *)cellIdentifier
                       editable:(BOOL)editable
         elementPageAccessibilityId:(NSString *)elementPageAccessibilityId
                      mandatory:(BOOL)mandatory
{
    return [[self alloc] initWithTitle:title
                           optionValue:optionValue
                        cellIdentifier:cellIdentifier
                              editable:editable
                elementPageAccessibilityId:elementPageAccessibilityId
                             mandatory:mandatory];
}

- (void)setOptionValue:(id)optionValue
{
    if (optionValue != _optionValue) {
        _optionValue = optionValue;
        _errorString = nil;
    }
}

@end
