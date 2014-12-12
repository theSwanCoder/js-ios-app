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
//  JMInputControlCell.m
//  TIBCO JasperMobile
//

#import "JMInputControlCell.h"

@interface JMInputControlCell()
@property (nonatomic, weak) IBOutlet UIView  *valuePlaceHolderView;
@end

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

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGRect titleLabelRect = self.textLabel.frame;
    titleLabelRect.size.width = self.contentView.frame.size.width - 3 * titleLabelRect.origin.x - self.valuePlaceHolderView.frame.size.width;
    self.textLabel.frame = titleLabelRect;
    
    if ([self.inputControlDescriptor errorString]) {
        CGRect errorLabelRect = self.detailTextLabel.frame;
        errorLabelRect.origin.y = 2 * self.valuePlaceHolderView.frame.origin.y + self.valuePlaceHolderView.frame.size.height;
        self.detailTextLabel.frame = errorLabelRect;
    }
}


- (void) updateDisplayingOfErrorMessage
{
    self.detailTextLabel.text = [self.inputControlDescriptor errorString];
    [self.delegate reloadTableViewCell:self];
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
    [self updateDisplayingOfErrorMessage];
}

- (void)setEnabledCell:(BOOL)enabled
{
    if (enabled) {
        self.textLabel.textColor = [UIColor darkGrayColor];
    } else {
        self.textLabel.textColor = [UIColor lightGrayColor];
    }
}

- (BOOL)isValidData
{
    [self updateDisplayingOfErrorMessage];
    return ![self.inputControlDescriptor errorString];
}

@end
