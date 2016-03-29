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

//
//  JMBooleanInputControlCell.m
//  TIBCO JasperMobile
//

#import "JMBooleanInputControlCell.h"

@interface JMBooleanInputControlCell ()
@property (nonatomic, weak) IBOutlet UISwitch *uiSwitch;
@end

@implementation JMBooleanInputControlCell

- (void)setInputControlDescriptor:(JSInputControlDescriptor *)inputControlDescriptor
{
    [super setInputControlDescriptor:inputControlDescriptor];
    self.uiSwitch.on = [inputControlDescriptor.state.value boolValue];
}

- (void)setEnabledCell:(BOOL)enabled
{
    [super setEnabledCell:enabled];
    self.uiSwitch.enabled = enabled;
}

#pragma mark - Actions

- (IBAction)switchChanged:(id)sender
{
    [self performSelector:@selector(updateValue:) withObject:[JSUtils stringFromBOOL:[sender isOn]] afterDelay:0.1]; // Fix issue with animations
}

@end
