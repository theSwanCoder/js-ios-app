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
//  JMInputControlCell.m
//  Jaspersoft Corporation
//

#import "JMInputControlCell.h"

@implementation JMInputControlCell

- (void)setValue:(id)value
{
    _value = value;
    if (self.inputControlDescriptor) {
        self.inputControlDescriptor.state.value = value;
    }
}

- (void)setInputControlDescriptor:(JSInputControlDescriptor *)inputControlDescriptor
{
    _inputControlDescriptor = inputControlDescriptor;
    
    NSString *label = inputControlDescriptor.label;
    if (inputControlDescriptor.mandatory.boolValue) {
        label = [NSString stringWithFormat:@"* %@", label];
    }
    
    self.label.text = label;
}

- (void)setInputControlWrapper:(JSInputControlWrapper *)inputControlWrapper
{
    _inputControlWrapper = inputControlWrapper;
    _isMandatory = inputControlWrapper.isMandatory;

    NSString *label = inputControlWrapper.label;
    if (_isMandatory) {
        label = [NSString stringWithFormat:@"* %@", label];
    }

    self.label.text = label;
}

- (UILabel *)label
{
    return (UILabel *) [self viewWithTag:1];
}

- (void)clearData
{
    // Release through ivar to avoid additional calls of overridden setters
    _value = nil;
    _inputControlDescriptor = nil;
    _inputControlWrapper = nil;
    [self.label removeFromSuperview];
}

@end
