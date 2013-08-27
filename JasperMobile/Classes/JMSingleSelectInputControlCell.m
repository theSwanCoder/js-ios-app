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
#import "JMConstants.h"
#import "JMRequestDelegate.h"
#import "JMListItem.h"
#import <Objection-iOS/Objection.h>

@implementation JMSingleSelectInputControlCell

#pragma mark - Accessors

@synthesize resourceClient = _resourceClient;
@synthesize resourceDescriptor = _resourceDescriptor;

- (void)setInputControlWrapper:(JSInputControlWrapper *)inputControlWrapper
{
    [super setInputControlWrapper:inputControlWrapper];
    
    JSObjectionInjector *injector = [JSObjection defaultInjector];
    self.constants = [injector getObject:[JSConstants class]];
    self.values = [NSMutableArray array];
    self.detailLabel.text = @"";
    
    // Disable cell
    [self enabled:NO];
    
    NSInteger type = inputControlWrapper.type;
    
    if (type == self.constants.IC_TYPE_SINGLE_SELECT_QUERY ||
        type == self.constants.IC_TYPE_SINGLE_SELECT_QUERY_RADIO ||
        type == self.constants.IC_TYPE_MULTI_SELECT_QUERY ||
        type == self.constants.IC_TYPE_MULTI_SELECT_QUERY_CHECKBOX) {
        // Add observer to check whenever Input Control should be updated
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateInputControlQueryData:)
                                                     name:kJMUpdateInputControlQueryDataNotification
                                                   object:nil];
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

#pragma mark - Private

- (void)updateInputControlQueryData:(NSNotification *)notification
{
    // Exclude notifications that object sends to itself
    if (notification.object == self) return;
    
    NSDictionary *userInfo = notification.userInfo;
    
    // Get names of input controls that should be updated
    NSArray *inputControlsToUpdate = [userInfo objectForKey:kJMInputControlsToUpdate];
    
    // Get parameters
    NSMutableArray *parameters = [[userInfo objectForKey:kJMParameters] mutableCopy] ?: [NSMutableArray array];
    
    // Check if input conrol is updating for the 1-st time or inputControlsToUpdate array contains IC name (force update)
    if ((self.inputControlWrapper.masterDependencies.count == 0 && !inputControlsToUpdate) ||
        [inputControlsToUpdate containsObject:self.inputControlWrapper.name]) {
        
        __block JMSingleSelectInputControlCell *cell = self;
        
        JMRequestDelegate *delegate = [JMRequestDelegate requestDelegateForFinishBlock:^(JSOperationResult *result) {
            JSResourceDescriptor *descriptor = [result.objects objectAtIndex:0];
            NSArray *data = descriptor.inputControlQueryData;
            
            // Add values to IC cell
            for (JSResourceProperty *property in data) {
                JMListItem *item = [[JMListItem alloc] initWithName:property.name andValue:property.value isSelected:NO];
                [cell.values addObject:item];
            }
            
            if (cell.values.count) {
                [self enabled:YES];
            }
            
            // If cell is mandatory then other dependent IC's should be updated also
            if (cell.isMandatory && cell.values.count) {
                // Make first value selected
                JMListItem *first = [cell.values objectAtIndex:0];
                first.selected = YES;
                cell.detailLabel.text = first.name;
                
                JSResourceParameter *parameter = [[JSResourceParameter alloc] initWithName:descriptor.name
                                                                                isListItem:cell.isListItem
                                                                                     value:first.value];
                
                // Get all dependent IC's that should be updated
                NSMutableArray *slaveInputControls = [NSMutableArray array];
                for (JSInputControlWrapper *inputControl in cell.inputControlWrapper.slaveDependencies) {
                    [slaveInputControls addObject:inputControl.name];
                }
                
                [parameters addObject:parameter];
                                
                NSDictionary *info = @{
                    kJMInputControlsToUpdate : slaveInputControls,
                    kJMParameters : parameters
                };
                
                // Post update notification
                [[NSNotificationCenter defaultCenter] postNotificationName:kJMUpdateInputControlQueryDataNotification
                                                                    object:self
                                                                  userInfo:info];
            }
        }];
        
        NSString *dataSourceUri = self.inputControlWrapper.dataSourceUri;
        // Get data source from report if it isn't available for input control
        if (!dataSourceUri) {
            JSResourceDescriptor *dataSource = [self.resourceDescriptor resourceDescriptorDataSource];
            dataSourceUri = [dataSource resourceDescriptorDataSourceURI:dataSource];
        }
        
        [self.resourceClient resourceWithQueryData:self.inputControlWrapper.uri
                                     datasourceUri:dataSourceUri
                                resourceParameters:parameters
                                          delegate:delegate];
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

@end
