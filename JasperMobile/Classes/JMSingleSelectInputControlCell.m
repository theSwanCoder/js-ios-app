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
//  JMSingleSelectInputControlCell.m
//  Jaspersoft Corporation
//

#import "JMSingleSelectInputControlCell.h"
#import "JMCancelRequestPopup.h"
#import "JMRequestDelegate.h"

@interface JMSingleSelectInputControlCell()
@property  (nonatomic, copy) void (^updateSlaveDependenciesBlock)(void);
@end

@implementation JMSingleSelectInputControlCell

@synthesize value = _value;
@synthesize resourceClient = _resourceClient;
@synthesize resourceLookup = _resourceLookup;
@synthesize reportClient = _reportClient;

- (void)setValue:(id)value
{
    if ([value count] > 0) {
        JSInputControlOption *item = [value objectAtIndex:0];
        _value = item.value;
        self.detailLabel.text = item.label;
    } else {
        _value = nil;
        self.detailLabel.text = JS_IC_NOTHING_SUBSTITUTE_LABEL;
    }
}

- (UILabel *)detailLabel
{
    return (UILabel *) [self viewWithTag:2];
}

- (void)updateWithParameters:(NSArray *)parameters
{
    // Set selected value
    self.value = parameters;

    if (self.updateSlaveDependenciesBlock) {
        self.updateSlaveDependenciesBlock();
    }
}

- (void)enabled:(BOOL)enabled
{
    if (enabled) {
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
    } else {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    self.label.enabled = enabled;
    // Enable / Disable calls for didSelectRowAtIndexPath: method
    self.userInteractionEnabled = enabled;
}

- (void)disableCell
{
    [super disableCell];
    [self enabled:NO];
}

#pragma mark - REST v2 -

- (void)setInputControlDescriptor:(JSInputControlDescriptor *)inputControlDescriptor
{
    [super setInputControlDescriptor:inputControlDescriptor];
    [self setInputControlState:inputControlDescriptor.state];
    
    __weak JMSingleSelectInputControlCell *weakSelf = self;
    
    self.updateSlaveDependenciesBlock = ^{
        [weakSelf updatedInputControlsValues];
    };
}

#pragma mark Private

- (void)updatedInputControlsValues
{
    if (!self.inputControlDescriptor.slaveDependencies.count) {
        [self dismissError];
        return;
    }

    __weak JMSingleSelectInputControlCell *weakSelf = self;
    
    // TODO: change loading progress
    [JMCancelRequestPopup presentInViewController:self.delegate message:@"status.loading" restClient:self.reportClient cancelBlock:^{
        [[weakSelf.delegate navigationController] popViewControllerAnimated:YES];
    }];
    
    NSMutableArray *selectedValues = [NSMutableArray array];
    NSMutableArray *allInputControls = [NSMutableArray array];

    // Get values from Input Controls
    for (id inputControlCell in self.delegate.inputControls) {
        JSInputControlDescriptor *descriptor = [inputControlCell inputControlDescriptor];
        [selectedValues addObject:[[JSReportParameter alloc] initWithName:descriptor.uuid
                                                                    value:descriptor.selectedValues]];
        [allInputControls addObject:descriptor.uuid];
    }

    JMRequestDelegate *delegate = [JMRequestDelegate requestDelegateForFinishBlock:^(JSOperationResult *result) {
        for (JSInputControlState *state in result.objects) {
            for (id inputControl in weakSelf.delegate.inputControls) {
                if ([state.uuid isEqualToString:[inputControl inputControlDescriptor].uuid]) {
                    [inputControl setInputControlState:state];
                }
            }
        }
    } viewControllerToDismiss:self.delegate];
    
    [JMRequestDelegate setFinalBlock:^{
        [self.tableView reloadData];
    }];
    
    [self.reportClient updatedInputControlsValues:self.resourceLookup.uri
                                              ids:allInputControls
                                   selectedValues:selectedValues
                                         delegate:delegate];
}

- (void)setInputControlState:(JSInputControlState *)state
{
    self.inputControlDescriptor.state = state;
    self.listOfValues = [state.options mutableCopy];
    
    NSMutableArray *selectedValues = [NSMutableArray array];
    for (JSInputControlOption *option in self.listOfValues) {
        if (option.selected.boolValue) {
            [selectedValues addObject:option];
        }
    }
    
    self.value = selectedValues;
    if (selectedValues.count) {
        self.errorMessage = nil;
    }
}

@end
