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
//  JMSingleSelectInputControlCell.m
//  TIBCO JasperMobile
//

#import "JMSingleSelectInputControlCell.h"

@interface JMSingleSelectInputControlCell()
@property (nonatomic, weak) IBOutlet UILabel *valueLabel;
@end

@implementation JMSingleSelectInputControlCell

- (void)setEnabledCell:(BOOL)enabled
{
    [super setEnabledCell:enabled];
    self.userInteractionEnabled = enabled;
}

- (void)updateWithParameters:(NSArray *)parameters
{
    [self updateValueLabelWithParameters:parameters];
    [self.delegate updatedInputControlsValuesWithDescriptor:self.inputControlDescriptor];
}

- (void)setInputControlDescriptor:(JSInputControlDescriptor *)inputControlDescriptor
{
    [super setInputControlDescriptor:inputControlDescriptor];
    [self setInputControlState:inputControlDescriptor.state];
}

- (void)setInputControlState:(JSInputControlState *)state
{
    self.inputControlDescriptor.state = state;
    NSMutableArray *selectedValues = [NSMutableArray array];
    for (JSInputControlOption *option in state.options) {
        if (option.selected.boolValue) {
            [selectedValues addObject:option];
        }
    }
    [self updateValueLabelWithParameters:selectedValues];
}

- (void)updateValueLabelWithParameters:(NSArray *)parameters
{
    if ([parameters count] > 0) {
        NSArray *allValues = [parameters sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [[obj1 label] compare:[obj2 label]];
        }];
        NSMutableString *valuesAsStrings = [NSMutableString string];
        for (JSInputControlOption *option in allValues) {
            NSString *formatString = [valuesAsStrings length] ? @", %@" : @"%@";
            [valuesAsStrings appendFormat:formatString, option.label];
        }
        self.inputControlDescriptor.state.value = valuesAsStrings;
        self.valueLabel.text = valuesAsStrings;
    } else {
        self.inputControlDescriptor.state.value = nil;
        self.valueLabel.text = @"---";
    }
    [self updateDisplayingOfErrorMessage];
}

@end
