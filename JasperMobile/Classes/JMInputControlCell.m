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

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        baseHeight = self.frame.size.height;
    }

    return self;
}

- (void)setValue:(id)value
{
    _value = value;
    if (self.inputControlDescriptor) {
        self.inputControlDescriptor.state.value = value;
    }
}

- (void)setErrorMessage:(NSString *)errorMessage
{
    _errorMessage = errorMessage;
    
    UILabel *errorLabel = self.errorLabel;
    errorLabel.text = errorMessage;
    errorLabel.hidden = errorMessage.length == 0;
    if (!errorLabel.hidden) {
        [errorLabel sizeToFit];
    }
}

- (BOOL)dismissError
{
    if (self.errorMessage.length) {
        self.errorMessage = nil;
        
        NSInteger row = [self.delegate.inputControls indexOfObject:self];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        
        [self.delegate.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.delegate.tableView beginUpdates];
        [self.delegate.tableView endUpdates];
        return YES;
    }
    
    return NO;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    UILabel *errorLabel = self.errorLabel;
    if (!errorLabel.hidden) {
        CGRect oldFrame = errorLabel.frame;
        CGRect frame = CGRectMake(oldFrame.origin.x,
                                  oldFrame.origin.y,
                                  self.label.frame.size.width,
                                  oldFrame.size.height);
        errorLabel.frame = frame;
        [errorLabel sizeToFit];
    }
}

- (void)setInputControlDescriptor:(JSInputControlDescriptor *)inputControlDescriptor
{
    _inputControlDescriptor = inputControlDescriptor;

    if (!inputControlDescriptor.visible.boolValue) {
        self.hidden = YES;
    } else {
        if (inputControlDescriptor.mandatory.boolValue) {
            self.mandatoryLabel.hidden = NO;
        }

        if (inputControlDescriptor.readOnly.boolValue) {
            [self disableCell];
        }

        self.label.text = inputControlDescriptor.label;
    }
}

- (UILabel *)label
{
    return (UILabel *) [self viewWithTag:1];
}

- (CGFloat)height
{
    if (!self.errorLabel.hidden) {
        return baseHeight + self.errorLabel.frame.size.height;
    }
    
    return baseHeight;
}

- (void)disableCell
{
    self.label.textColor = [UIColor grayColor];
    self.mandatoryLabel.textColor = self.label.textColor;
}

#pragma mark - Private

- (UILabel *)errorLabel
{
    return (UILabel *) [self viewWithTag:3];
}

- (UILabel *)mandatoryLabel
{
    return (UILabel *) [self viewWithTag:4];
}

@end
