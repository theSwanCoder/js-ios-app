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
//  JMInputControlCell.m
//  Jaspersoft Corporation
//

#import "JMInputControlCell.h"

@implementation JMInputControlCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.textLabel.font = [JMFont tableViewCellTitleFont];
    self.textLabel.textColor = [UIColor darkGrayColor];
    
    self.detailTextLabel.font = [JMFont tableViewCellDetailErrorFont];
    self.detailTextLabel.textColor = [UIColor redColor];

    self.contentView.autoresizingMask |= UIViewAutoresizingFlexibleWidth;
}

- (void) updateDisplayingOfErrorMessage:(NSString *)errorMessage
{
    self.detailTextLabel.text = errorMessage;
}

- (void)setInputControlDescriptor:(JSInputControlDescriptor *)inputControlDescriptor
{
    _inputControlDescriptor = inputControlDescriptor;

    [self setEnabledCell:(!inputControlDescriptor.readOnly.boolValue)];
    
    if (inputControlDescriptor.mandatory.boolValue) {
        self.textLabel.text = [NSString stringWithFormat:@"* %@",inputControlDescriptor.label];
    } else {
        self.textLabel.text = inputControlDescriptor.label;
    }
}

- (void)setEnabledCell:(BOOL)enabled
{
    if (enabled) {
        self.textLabel.textColor = [UIColor darkGrayColor];
    } else {
        self.textLabel.textColor = [UIColor lightGrayColor];
    }
}

@end
