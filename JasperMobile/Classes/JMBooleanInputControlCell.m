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
//  JMBooleanInputControlCell.m
//  Jaspersoft Corporation
//

#import "JMBooleanInputControlCell.h"

@implementation JMBooleanInputControlCell

- (void)setInputControlDescriptor:(JSInputControlDescriptor *)inputControlDescriptor
{
    [super setInputControlDescriptor:inputControlDescriptor];

    self.value = inputControlDescriptor.state.value;
    self.uiSwitch.on = [self.value boolValue];
}

- (UISwitch *)uiSwitch
{
    return (UISwitch *) [self viewWithTag:2];
}

- (void)disableCell
{
    [super disableCell];
    self.uiSwitch.enabled = NO;
}

#pragma mark - Actions

- (IBAction)switchChanged:(id)sender
{
    self.value = [JSConstants stringFromBOOL:[sender isOn]];
}

@end
