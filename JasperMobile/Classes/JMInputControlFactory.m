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
//  JMInputControlFactory.m
//  Jaspersoft Corporation
//

#import "JMInputControlFactory.h"
#import <Objection-iOS/Objection.h>

static NSString * const kJMBooleanCellIdentifier = @"BooleanCell";
static NSString * const kJMDateCellIdentifier = @"DateCell";
static NSString * const kJMDateTimeCellIdentifier = @"DateTimeCell";
static NSString * const kJMMultiSelectCellIdentifier = @"MultiSelectCell";
static NSString * const kJMNumberCellIdentifier = @"NumberCell";
static NSString * const kJMTextEditCellIdentifier = @"TextEditCell";
static NSString * const kJMSingleSelectCellIdentifier = @"SingleSelectCell";

@interface JMInputControlFactory()
@property (nonatomic, strong) JSConstants *constants;
@end

@implementation JMInputControlFactory
objection_requires(@"constants")

- (id)initWithTableViewController:(UITableViewController *)tableViewController
{
    if (self = [self init]) {
        self.tableViewController = tableViewController;
        [[JSObjection defaultInjector] injectDependencies:self];
    }
    
    return self;
}

- (JMInputControlCell *)inputControlWithInputControlWrapper:(JSInputControlWrapper *)inputControl
{
    static NSDictionary *types;
    if (!types) types = [self inputControlWrapperTypes];
    
    id cellIdentifier = [types objectForKey:@(inputControl.type)];
    if ([cellIdentifier isKindOfClass:[NSDictionary class]]) {
        cellIdentifier = [cellIdentifier objectForKey:@(inputControl.dataType)];
    }
    
    // TODO: add default IC Cell
    JMInputControlCell *cell = [self.tableViewController.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.inputControlWrapper = inputControl;
    
    return cell;
}

- (JMInputControlCell *)inputControlWithInputControlDescriptor:(JSInputControlDescriptor *)inputControl
{
    static NSDictionary *types;
    if (!types) types = [self inputControlDescriptorTypes];
    
    NSString *cellIdentifier = [types objectForKey:inputControl.type];
    
    JMInputControlCell *cell = [self.tableViewController.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.inputControlDescriptor = inputControl;
    
    return cell;
}

#pragma mark - Private

// Returns IC types for REST v1
- (NSDictionary *)inputControlWrapperTypes
{
    JSConstants *constants = self.constants;
    
    NSDictionary *types = @{
        @(constants.IC_TYPE_BOOLEAN) : kJMBooleanCellIdentifier,
        
        @(constants.IC_TYPE_SINGLE_VALUE) : @{
              @(constants.DT_TYPE_TEXT) : kJMTextEditCellIdentifier,
              @(constants.DT_TYPE_NUMBER) : kJMNumberCellIdentifier,
              @(constants.DT_TYPE_DATE) : kJMDateCellIdentifier,
              @(constants.DT_TYPE_DATE_TIME) : kJMDateTimeCellIdentifier,
        },
        
        @(constants.IC_TYPE_SINGLE_SELECT_LIST_OF_VALUES) : kJMSingleSelectCellIdentifier,
        @(constants.IC_TYPE_SINGLE_SELECT_LIST_OF_VALUES_RADIO) : kJMSingleSelectCellIdentifier,
        @(constants.IC_TYPE_SINGLE_SELECT_QUERY) : kJMSingleSelectCellIdentifier,
        @(constants.IC_TYPE_SINGLE_SELECT_QUERY_RADIO) : kJMSingleSelectCellIdentifier,
        
        @(constants.IC_TYPE_MULTI_SELECT_LIST_OF_VALUES) : kJMMultiSelectCellIdentifier,
        @(constants.IC_TYPE_MULTI_SELECT_LIST_OF_VALUES_CHECKBOX) : kJMMultiSelectCellIdentifier,
        @(constants.IC_TYPE_MULTI_SELECT_QUERY) : kJMMultiSelectCellIdentifier,
        @(constants.IC_TYPE_MULTI_SELECT_QUERY_CHECKBOX) : kJMMultiSelectCellIdentifier,
    };

    return types;
}

// Returns IC types for REST v2
- (NSDictionary *)inputControlDescriptorTypes
{
    JSConstants *constants = self.constants;
    
    NSDictionary *types = @{
        constants.ICD_TYPE_BOOL : kJMBooleanCellIdentifier,
        constants.ICD_TYPE_SINGLE_VALUE_TEXT : kJMTextEditCellIdentifier,
        constants.ICD_TYPE_SINGLE_VALUE_NUMBER : kJMNumberCellIdentifier,
        constants.ICD_TYPE_SINGLE_VALUE_DATE : kJMDateCellIdentifier,
        constants.ICD_TYPE_SINGLE_SELECT : kJMSingleSelectCellIdentifier,
        constants.ICD_TYPE_SINGLE_SELECT_RADIO : kJMSingleSelectCellIdentifier,
        constants.ICD_TYPE_MULTI_SELECT : kJMMultiSelectCellIdentifier,
        constants.ICD_TYPE_MULTI_SELECT_CHECKBOX : kJMMultiSelectCellIdentifier,
    };
    
    return types;
}

@end
