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
#import "JMListValue.h"
#import <Objection-iOS/Objection.h>

@interface JMSingleSelectInputControlCell()
@property  (nonatomic, copy) void (^updateWithParametersBlock)(NSSet *parameters);
@property  (nonatomic, strong) NSMutableDictionary *masterDependenciesParameters;
@end

@implementation JMSingleSelectInputControlCell

@synthesize resourceClient = _resourceClient;
@synthesize resourceDescriptor = _resourceDescriptor;

- (void)setValue:(id)value
{
    if ([value count] > 0) {
        JMListValue *item = [value anyObject];
        self.detailLabel.text = item.name;
    } else {
        self.detailLabel.text = self.inputControlWrapper.NOTHING_SUBSTITUTE_LABEL;
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

- (void)updateWithParameters:(NSSet *)parameters
{
    self.updateWithParametersBlock(parameters);
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

// Clears data, temp solution for memory leak problem
- (void)clearData
{
    self.updateWithParametersBlock = nil;
    self.masterDependenciesParameters = nil;
    self.resourceDescriptor = nil;
    self.resourceClient = nil;
    self.listOfValues = nil;
    self.constants = nil;
    self.detailLabel.text = nil;
    
    [super clearData];
}

#pragma mark - REST v2 -
#pragma mark Private

// TODO: here will be REST 2 code ...

#pragma mark - REST v1 -

- (void)setInputControlWrapper:(JSInputControlWrapper *)inputControlWrapper
{
    [super setInputControlWrapper:inputControlWrapper];

    JSObjectionInjector *injector = [JSObjection defaultInjector];
    self.constants = [injector getObject:[JSConstants class]];
    self.value = [NSMutableArray array];
    self.listOfValues = [NSMutableArray array];
    self.masterDependenciesParameters = [NSMutableDictionary dictionary];

    // Disable cell
    [self enabled:NO];

    if (self.needsToUpdateInputControlQueryData) {
        // Add observer to check whenever Input Control should be updated
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateInputControlQueryData:)
                                                     name:kJMUpdateInputControlQueryDataNotification
                                                   object:nil];
    }
        
    __weak JMSingleSelectInputControlCell *cell = self;

    self.updateWithParametersBlock = ^(NSSet *parameters) {
        [cell sendInputControlQueryNotificationWithParams:parameters masterDependenciesParameters:[cell.masterDependenciesParameters mutableCopy]];
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
            [self sendInputControlQueryNotificationWithParams:nil masterDependenciesParameters:nil];

            return;
        }

        //
        if ([JMRequestDelegate isRequestPoolEmpty]) {
            [JMCancelRequestPopup presentInViewController:self.viewController message:@"status.loading" restClient:self.resourceClient cancelBlock:^{
                NSLog(@"Dismiss view controller");
            }];

            [JMRequestDelegate setFinalBlock:^{
                [JMCancelRequestPopup dismiss];
            }];
        }

        __weak JMSingleSelectInputControlCell *cell = self;

        JMRequestDelegate *delegate = [JMRequestDelegate requestDelegateForFinishBlock:^(JSOperationResult *result) {
            JSResourceDescriptor *descriptor = [result.objects objectAtIndex:0];
            NSArray *data = descriptor.inputControlQueryData;

            [cell.listOfValues removeAllObjects];

            // Add values to IC cell
            for (JSResourceProperty *property in data) {
                JMListValue *item = [[JMListValue alloc] initWithName:property.name andValue:property.value isSelected:NO];
                [cell.listOfValues addObject:item];
            }

            if (cell.listOfValues.count) {
                [self enabled:YES];

                // Select first value if cell is mandatory
                if (cell.isMandatory) {
                    // Make first value selected
                    JMListValue *firstItem = [cell.listOfValues objectAtIndex:0];
                    firstItem.selected = YES;

                    [self sendInputControlQueryNotificationWithParams:[NSSet setWithObject:firstItem] masterDependenciesParameters:masterDependenciesParameters];
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
- (void)sendInputControlQueryNotificationWithParams:(NSSet *)parameters masterDependenciesParameters:(NSMutableDictionary *)masterDependenciesParameters
{
    // Set selected value
    self.value = parameters;

    // Do not send notification if there are no slave dependencies
    if (!self.inputControlWrapper.getSlaveDependencies.count) return;
    
    NSMutableArray *resourceParameters = [NSMutableArray array];
    if (!masterDependenciesParameters) masterDependenciesParameters = [NSMutableDictionary dictionary];
    
    for (JMListValue *item in parameters) {
        JSResourceParameter *parameter = [[JSResourceParameter alloc] initWithName:self.inputControlWrapper.name
                                                                        isListItem:self.isListItem
                                                                             value:item.value];
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

@end
