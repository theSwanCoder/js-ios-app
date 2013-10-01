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
//  JMSingleSelectInputControlCell.m
//  Jaspersoft Corporation
//

#import "JMSingleSelectInputControlCell.h"
#import "JMCancelRequestPopup.h"
#import "JMConstants.h"
#import "JMRequestDelegate.h"
#import <Objection-iOS/Objection.h>

@interface JMSingleSelectInputControlCell()
@property  (nonatomic, copy) void (^updateSlaveDependenciesBlock)(void);
@property  (nonatomic, strong) NSMutableDictionary *masterDependenciesParameters;
@end

@implementation JMSingleSelectInputControlCell

@synthesize value = _value;
@synthesize resourceClient = _resourceClient;
@synthesize resourceDescriptor = _resourceDescriptor;
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

- (NSString *)isListItem
{
    return @"NO";
}

- (BOOL)needsToUpdateInputControlQueryData
{
    NSInteger type = self.inputControlWrapper.type;
    return type == self.constants.IC_TYPE_SINGLE_SELECT_QUERY || type == self.constants.IC_TYPE_SINGLE_SELECT_QUERY_RADIO;
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

// Clears data, temp solution for memory leak problem
- (void)clearData
{
    self.updateSlaveDependenciesBlock = nil;
    self.masterDependenciesParameters = nil;
    self.resourceDescriptor = nil;
    self.resourceClient = nil;
    self.listOfValues = nil;
    self.constants = nil;
    [self.detailLabel removeFromSuperview];

    [super clearData];
}

#pragma mark - REST v1 -

- (void)setInputControlWrapper:(JSInputControlWrapper *)inputControlWrapper
{
    [super setInputControlWrapper:inputControlWrapper];

    JSObjectionInjector *injector = [JSObjection defaultInjector];
    self.constants = [injector getObject:[JSConstants class]];
    self.value = [NSMutableArray array];
    self.masterDependenciesParameters = [NSMutableDictionary dictionary];
    self.listOfValues = [NSMutableArray array];

    if (inputControlWrapper.listOfValues.count) {
        for (JSResourceProperty *property in inputControlWrapper.listOfValues) {
            JSInputControlOption *option = [[JSInputControlOption alloc] init];
            option.label = property.value;
            option.value = property.name;
            option.selected = [JSConstants stringFromBOOL:NO];

            [self.listOfValues addObject:option];
        }

        if (inputControlWrapper.isMandatory) {
            JSInputControlOption *firstOption = [self.listOfValues objectAtIndex:0];
            firstOption.selected = [JSConstants stringFromBOOL:YES];
            self.value = @[firstOption];
        }
    } else {
        // Disable cell
        [self enabled:NO];
    }

    if (self.needsToUpdateInputControlQueryData) {
        // Add observer to check whenever Input Control should be updated
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateInputControlQueryData:)
                                                     name:kJMUpdateInputControlQueryDataNotification
                                                   object:nil];
    }

    __weak JMSingleSelectInputControlCell *cell = self;

    self.updateSlaveDependenciesBlock = ^{
        [cell sendInputControlQueryNotificationWithMasterDependenciesParameters:[cell.masterDependenciesParameters mutableCopy]];
    };
}

#pragma mark Private

- (void)updateInputControlQueryData:(NSNotification *)notification
{
    // Exclude notifications that object sends to itself
    if (notification.object == self) return;

    NSDictionary *userInfo = notification.userInfo;

    // Get names of ICs that should be updated
    NSArray *inputControlsToUpdate = [userInfo objectForKey:kJMInputControlsToUpdate];

    // Get master dependencies parameters
    NSMutableDictionary *masterDependenciesParameters = [userInfo objectForKey:kJMParameters] ? : [NSMutableDictionary dictionary];

    // Check if IC is updating for the 1-st time or inputControlsToUpdate array contains IC name (force update)
    if ((!self.inputControlWrapper.getMasterDependencies.count && !inputControlsToUpdate) ||
            [inputControlsToUpdate containsObject:self.inputControlWrapper.name]) {

        NSString *dataSourceUri = self.inputControlWrapper.dataSourceUri;
        // Get data source from report if it isn't available for input control
        if (!dataSourceUri) {
            JSResourceDescriptor *dataSource = [self.resourceDescriptor resourceDescriptorDataSource];
            dataSourceUri = [dataSource resourceDescriptorDataSourceURI:dataSource];
        }

        NSMutableArray *dependentParameters = [NSMutableArray array];

        if (masterDependenciesParameters.count) {
            for (JSInputControlWrapper *inputControl in self.inputControlWrapper.getMasterDependencies) {
                NSMutableArray *inputControlParameter = [masterDependenciesParameters objectForKey:inputControl.name];

                if (inputControlParameter.count) {
                    [dependentParameters addObjectsFromArray:inputControlParameter];
                    [self.masterDependenciesParameters setObject:inputControlParameter forKey:inputControl.name];
                } else {
                    [dependentParameters removeAllObjects];
                    [self.masterDependenciesParameters removeAllObjects];
                    break;
                }
            }
        }

        // Disable IC cell and remove all items if dependentParameters are empty but cell should be updated
        if (!dependentParameters.count && [inputControlsToUpdate containsObject:self.inputControlWrapper.name]) {
            [self.listOfValues removeAllObjects];
            [self enabled:NO];
            self.value = nil;

            [self sendInputControlQueryNotificationWithMasterDependenciesParameters:nil];

            return;
        }

        __weak JMSingleSelectInputControlCell *cell = self;

        // Show CancelRequestPopup if value for IC was changed (in this case request pool is empty)
        if ([JMRequestDelegate isRequestPoolEmpty]) {
            // TODO: change logic to select previous values instead dismissing view controller
            [JMCancelRequestPopup presentInViewController:self.delegate message:@"status.loading" restClient:self.resourceClient cancelBlock:^{
                [[cell.delegate navigationController] popViewControllerAnimated:YES];
            }];
        }

        JMRequestDelegate *delegate = [JMRequestDelegate requestDelegateForFinishBlock:^(JSOperationResult *result) {
            JSResourceDescriptor *descriptor = [result.objects objectAtIndex:0];
            NSArray *data = descriptor.inputControlQueryData;

            [cell.listOfValues removeAllObjects];

            // Add values to IC cell
            for (JSResourceProperty *property in data) {
                JSInputControlOption *option = [[JSInputControlOption alloc] init];
                option.label = property.name;
                option.value = property.value;
                option.selected = [JSConstants stringFromBOOL:NO];

                [cell.listOfValues addObject:option];
            }

            if (cell.listOfValues.count) {
                if (!self.inputControlWrapper.isReadOnly) {
                    [self enabled:YES];
                }

                // Select first value if cell is mandatory
                if (cell.isMandatory) {
                    // Make first value selected
                    JSInputControlOption *firstOption = [cell.listOfValues objectAtIndex:0];
                    firstOption.selected = [JSConstants stringFromBOOL:YES];
                    cell.value = @[firstOption];

                    [self sendInputControlQueryNotificationWithMasterDependenciesParameters:masterDependenciesParameters];
                }
            }
        }];

        [self.resourceClient resourceWithQueryData:self.inputControlWrapper.uri
                                     datasourceUri:dataSourceUri
                                resourceParameters:dependentParameters
                                          delegate:delegate];
    }
}

// Send UpdateInputControlQueryDataNotification to all dependent ICs.
- (void)sendInputControlQueryNotificationWithMasterDependenciesParameters:(NSMutableDictionary *)masterDependenciesParameters
{
    // Do not send notification if there are no slave dependencies
    if (!self.inputControlWrapper.getSlaveDependencies.count) return;

    NSMutableArray *resourceParameters = [NSMutableArray array];
    if (!masterDependenciesParameters) masterDependenciesParameters = [NSMutableDictionary dictionary];

    for (NSString *value in self.value) {
        JSResourceParameter *parameter = [[JSResourceParameter alloc] initWithName:self.inputControlWrapper.name
                                                                        isListItem:self.isListItem
                                                                             value:value];
        [resourceParameters addObject:parameter];
    }

    // Get all dependent ICs that should be updated
    NSMutableArray *slaveInputControls = [NSMutableArray array];
    for (JSInputControlWrapper *inputControl in self.inputControlWrapper.getSlaveDependencies) {
        [slaveInputControls addObject:inputControl.name];
    }

    if (resourceParameters.count) {
        [masterDependenciesParameters setObject:resourceParameters forKey:self.inputControlWrapper.name];
    }

    NSDictionary *userInfo = @{
        kJMInputControlsToUpdate : slaveInputControls,
        kJMParameters : masterDependenciesParameters
    };

    // Post update notification
    [[NSNotificationCenter defaultCenter] postNotificationName:kJMUpdateInputControlQueryDataNotification
                                                        object:self
                                                      userInfo:userInfo];
}

#pragma mark - REST v2 -

- (void)setInputControlDescriptor:(JSInputControlDescriptor *)inputControlDescriptor
{
    [super setInputControlDescriptor:inputControlDescriptor];
    [self setInputControlState:inputControlDescriptor.state];
    
    __weak JMSingleSelectInputControlCell *cell = self;
    
    self.updateSlaveDependenciesBlock = ^{
        [cell updatedInputControlsValues];
    };
}

#pragma mark Private

- (void)updatedInputControlsValues
{
    if (!self.inputControlDescriptor.slaveDependencies.count) {
        [self dismissError];
        return;
    }

    __weak JMSingleSelectInputControlCell *cell = self;
    
    // TODO: change logic to select previous values instead dismissing view. And check network status!
    [JMCancelRequestPopup presentInViewController:self.delegate message:@"status.loading" restClient:self.reportClient cancelBlock:^{
        [[cell.delegate navigationController] popViewControllerAnimated:YES];
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
            for (id inputControl in cell.delegate.inputControls) {
                if ([state.uuid isEqualToString:[inputControl inputControlDescriptor].uuid]) {
                    [inputControl setInputControlState:state];
                }
            }
        }
    } viewControllerToDismiss:self.delegate];
    
    [JMRequestDelegate setFinalBlock:^{
        [self.delegate.tableView reloadData];
    }];
    
    [self.reportClient updatedInputControlsValues:self.resourceDescriptor.uriString
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
