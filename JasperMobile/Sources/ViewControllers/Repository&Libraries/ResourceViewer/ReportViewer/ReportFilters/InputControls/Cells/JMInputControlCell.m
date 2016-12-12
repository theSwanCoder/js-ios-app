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
//  JMInputControlCell.m
//  TIBCO JasperMobile
//

#import "JMInputControlCell.h"
#import "JMThemesManager.h"

@interface JMInputControlCell()
@property (nonatomic, weak) IBOutlet UIView  *valuePlaceHolderView;
@end

@implementation JMInputControlCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.titleLabel.font = [[JMThemesManager sharedManager] tableViewCellTitleFont];
    self.titleLabel.textColor = [[JMThemesManager sharedManager] tableViewCellTitleTextColor];
    self.errorLabel.font = [[JMThemesManager sharedManager] tableViewCellErrorFont];
    self.errorLabel.textColor = [[JMThemesManager sharedManager] tableViewCellErrorColor];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Make sure the contentView does a layout pass here so that its subviews have their frames set, which we
    // need to use to set the preferredMaxLayoutWidth below.
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    
    // Set the preferredMaxLayoutWidth of the mutli-line bodyLabel based on the evaluated width of the label's frame,
    // as this will allow the text to wrap correctly, and as a result allow the label to take on the correct height.
    self.titleLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.titleLabel.frame);
    self.errorLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.errorLabel.frame);
}

- (void) updateDisplayingOfErrorMessage
{
    NSString *errorString = [self.inputControlDescriptor errorString];
    self.errorLabel.text = errorString;
    [self.delegate reloadTableViewCell:self];
}

- (void)updateValue:(NSString *)newValue
{
    if (![self.inputControlDescriptor.state.value isEqualToString:newValue]) {
        self.inputControlDescriptor.state.value = newValue;
        [self.delegate inputControlCellDidChangedValue:self];
    }
}

- (void)setInputControlDescriptor:(JSInputControlDescriptor *)inputControlDescriptor
{
    _inputControlDescriptor = inputControlDescriptor;
    [self setEnabledCell:(!inputControlDescriptor.readOnly.boolValue)];
    if (inputControlDescriptor.mandatory.boolValue) {
        self.titleLabel.text = [NSString stringWithFormat:@"* %@",inputControlDescriptor.label];
    } else {
        self.titleLabel.text = inputControlDescriptor.label;
    }
    [self updateDisplayingOfErrorMessage];
}

- (void)setEnabledCell:(BOOL)enabled
{
    UIColor *textColor = [[JMThemesManager sharedManager] tableViewCellTitleTextColor];
    self.titleLabel.textColor = [textColor colorWithAlphaComponent:enabled ? 1.0f : 0.5f];
}

@end
