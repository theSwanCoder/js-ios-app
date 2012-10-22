/*
 * JasperMobile for iOS
 * Copyright (C) 2005 - 2012 Jaspersoft Corporation. All rights reserved.
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
//  JSSingleSelectListInputControlCell.m
//  Jaspersoft Corporation
//

#import <jaspersoft-sdk/JaspersoftSDK.h>
#import "JSSingleSelectListInputControlCell.h"
#import "JSListSelectorViewController.h"
#import "JSResourceDescriptor+Helpers.h"
#import "JSListItem.h"

#define JS_LBL_VALUE_WIDTH		160.0f

@implementation JSSingleSelectListInputControlCell

@synthesize items;

- (id)initWithDescriptor:(JSResourceDescriptor *)rd tableViewController: (UITableViewController *)tv {
	return [self initWithDescriptor:rd tableViewController: tv dataSourceUri: nil];
}

- (id)initWithDescriptor:(JSResourceDescriptor *)rd tableViewController:(UITableViewController *)tv dataSourceUri:(NSString *)dsUri resourceClient:(JSRESTResource *)resourceClient {
    JSConstants *constants = [JSConstants sharedInstance];
    
	if ((self = [super initWithDescriptor: rd tableViewController: tv dataSourceUri: dsUri])) {
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
        self.resourceClient = resourceClient;
        loading = FALSE;
        
		NSInteger inputControlType = [[rd propertyByName:constants.PROP_INPUTCONTROL_TYPE].value integerValue];
		
		if (inputControlType == constants.IC_TYPE_SINGLE_SELECT_LIST_OF_VALUES ||
			inputControlType == constants.IC_TYPE_SINGLE_SELECT_LIST_OF_VALUES_RADIO) {
            
			// Look for the LOV resource
			for (int i = 0; i< rd.childResourceDescriptors.count; ++i) {
				JSResourceDescriptor *rdChild = [rd.childResourceDescriptors objectAtIndex:i];
				if ([rdChild.wsType isEqualToString:constants.WS_TYPE_LOV]) {
					self.items = [rdChild listOfItems];
					break;
				}
			}
		} else if (inputControlType == constants.IC_TYPE_SINGLE_SELECT_QUERY ||
                   inputControlType == constants.IC_TYPE_SINGLE_SELECT_QUERY_RADIO) {            
            // Look for a more appropriate datasource if available for this input control
            
            
            
            
            NSString *newDsUri = [rd resourceDescriptorDataSourceURI:[rd resourceDescriptorDataSource]];
            if (!newDsUri) {
                newDsUri = [self findDataSourceUri:rd resourceClient:resourceClient];
            }

            if (newDsUri != nil && newDsUri.length) {
                self.dataSourceUri = newDsUri;
            } else {
                self.dataSourceUri = dsUri;
            }
            
			// Get the date from the input control
			// We need to reload the input control to get the data
			[self reloadInputControlQueryData: nil];
		}
		
		
		self.nameLabel.frame = CGRectMake(self.nameLabel.frame.origin.x, 
                                          self.nameLabel.frame.origin.y, 
                                          JS_LBL_VALUE_WIDTH, 
                                          self.nameLabel.frame.size.height);
        self.selectedValue = nil;
		self.nameLabel.backgroundColor = [UIColor clearColor];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(JS_CELL_PADDING + JS_CONTENT_PADDING + JS_LBL_VALUE_WIDTH, 10.0, 
                                                          JS_CELL_WIDTH - (2*JS_CELL_PADDING + JS_CONTENT_PADDING + JS_LBL_VALUE_WIDTH) - 20.0f, 21.0)];
			
		label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
		label.textAlignment = UITextAlignmentRight;
		label.tag = 100;
		label.font = [UIFont systemFontOfSize:14.0];
		label.textColor = [UIColor colorWithRed:.196 green:0.3098 blue:0.52 alpha:1.0];
        label.backgroundColor = [UIColor clearColor];
		[self updateValueText];
		
		if (self.readonly) {
			label.frame = CGRectMake(246.0, 10.0, 53.0, 21.0);
		} else {	
			self.selectionStyle = UITableViewCellSelectionStyleBlue;
			self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}	
		[self addSubview:label];
	}
	
	return self;
}



// Specifies if the user can select this cell
- (BOOL)selectable {
	return !self.readonly;
}


// User touched the InputControl cell....
- (void)cellDidSelected {
	if (self.readonly) return;
		
    NSMutableArray *selectedVals = [NSMutableArray arrayWithCapacity:0];
    if (self.selectedValue != nil) {
        [selectedVals addObject: [NSNumber numberWithInt: [self indexOfItemWithValue: self.selectedValue] ]];
    }
		
    JSListSelectorViewController *rvc = [[JSListSelectorViewController alloc] initWithStyle:UITableViewStyleGrouped];
    rvc.values  = self.items;
    rvc.mandatory = self.mandatory;
    rvc.selectedValues = selectedVals;
    rvc.selectionDelegate = self;
    [self.tableViewController.navigationController pushViewController: rvc animated: YES];
}


- (void)setSelectedValue:(id)vals {
	if (self.selectedValue ==  vals) return;
	[super setSelectedValue:vals];	
	[self updateValueText];
}

- (void)updateValueText {
    if (loading) {
        label.text = @"Loading...";
        return;
    }
    
	if (self.selectedValue == nil) {
		label.text = @"Not set";
	} else {
		NSInteger index = [self indexOfItemWithValue: self.selectedValue];
		if (index >= 0 && index < [items count]) {
			label.text = [(JSListItem *)[items objectAtIndex: index] name];
		} else {
			label.text = @"?";
		}
	}
}

// This method is invoked by the ListSelectorView
- (void)setSelectedIndexes:(NSMutableArray *)indexes {
	if (indexes.count == 0)	{
		self.selectedValue = nil;
	} else {
		NSString *str =  [(JSListItem *)[self.items objectAtIndex: [[indexes objectAtIndex:0] intValue]] value];
		self.selectedValue = str;       
	}
}

// Return the first item in items with the given value...
- (NSInteger)indexOfItemWithValue: (NSString *)val {
	for (int i=0; i < self.items.count; ++i) {
		if ([[(JSListItem *)[self.items objectAtIndex:i] value] isEqualToString:val]) return i;
	}
	return -1;
}

// Update the records displayed based on the selection....
// if parameters is nil, it is ignored.
- (void)reloadInputControlQueryData:(NSDictionary *)parameters {
    if (self.resourceClient == nil) return;
	
    loading = TRUE;
	[self updateValueText];
    
    NSMutableArray *params = [[NSMutableArray alloc] init];

    for (id objKey in [parameters keyEnumerator]) {
        id value = [parameters objectForKey:objKey];
        
        if (value == nil) continue;
        if ([value isKindOfClass:[NSArray class]]) {
            for (NSString *attr in value) {
                [params addObject:[[JSResourceParameter alloc] initWithName:objKey 
                                                                 isListItem:@"YES"
                                                                      value:attr]];
            }
        } else if ([value isKindOfClass:[NSDate class]]) {
            // Dates should be passed to the service as numbers...
            NSDate *dateValue = (NSDate *)value;
            NSTimeInterval interval = [dateValue timeIntervalSince1970];
            
            [params addObject:[[JSResourceParameter alloc] initWithName:objKey 
                                                             isListItem:@"NO"
                                                                  value:[NSString stringWithFormat:@"%.0f",
                                                                         interval*1000]]];            
        } else {
            [params addObject:[[JSResourceParameter alloc] initWithName:objKey 
                                                             isListItem:@"NO"
                                                                  value:value]];
        }
    }
    [self.resourceClient resourceWithQueryData:self.descriptor.uriString datasourceUri:self.dataSourceUri 
                            resourceParameters:params delegate:self];	
}       

- (void)requestFinished:(JSOperationResult *)result {
    loading = FALSE;
    if (result == nil || result.objects.count == 0) {
        [label setTextColor:[UIColor redColor] ];
		label.text = @"#ERROR";
	} else {
		// Get the data from the descriptor
		// Data is stored in a structured form, let's take a look at it        
        self.descriptor = [result.objects objectAtIndex:0];
		
		// Load the items in memory
		self.items = [NSMutableArray arrayWithCapacity:0];
		
		// We treat the query data rows just like list items, but we need a little conversion first
		NSMutableArray *myItems = [NSMutableArray array];
        
        for (JSResourceProperty *prop in [self.descriptor inputControlQueryData]) {
			JSListItem *item = [[JSListItem alloc] initWithName:prop.name andValue:prop.value];			
			[myItems addObject:item];
        }
    
		self.items = myItems;		
		[self adjustSelection];		
	}
}


// This method is used when data for this input control is changed, and we want to be sure that at least one
// element from the selection is actually selected if the input control is mandatory
// If a selection is already available, it tries to recycle it, otherwise the selection will be cleanup
- (void)adjustSelection {
    NSString *newValue = self.selectedValue;
	if (newValue != nil) {
		NSInteger index = [self indexOfItemWithValue: newValue];
		if (index < 0) {
			newValue = nil;
		}
	}
	
	if (newValue == nil && self.mandatory && self.items.count > 0) {
		newValue = [(JSListItem *)[self.items objectAtIndex:0] value];
	}
    
	if (self.selectedValue != newValue) {
		self.selectedValue = newValue;
	} else {
		[self updateValueText];
	}
}

- (NSString *)findDataSourceUri:(JSResourceDescriptor *)rd resourceClient:(JSRESTResource *)resourceClient {
    JSConstants *constants = [JSConstants sharedInstance];
    
    for (int i=0; i< [[rd childResourceDescriptors] count]; ++i)
    {
        
        JSResourceDescriptor *dsrd = (JSResourceDescriptor *)[[rd childResourceDescriptors] objectAtIndex:i];
        
        if ([dsrd isDataSource]) {
            //1.1. Found datasource, let's check if it is a reference or a real resource
            JSResourceProperty *prop = [dsrd propertyByName:constants.PROP_FILERESOURCE_REFERENCE_URI];
            if (prop) {
                return prop.value;
            }
        }
    }
    
    // If we reached this point, there is no ds resource in this resource descrioptor...
    // Let's look for referenced resources...
    for (JSResourceDescriptor *refrd in rd.childResourceDescriptors) {
        if ([refrd.wsType isEqualToString: constants.WS_TYPE_REFERENCE]) {
            NSString *refUri = [refrd propertyByName:constants.PROP_FILERESOURCE_REFERENCE_URI].value;
            
            if (refUri != nil && resourceClient != nil) {                
                // Load this resource descriptor
                __block JSOperationResult *res = nil;
                __block BOOL requestFinished = NO;
                
                [resourceClient resource:refUri usingBlock:^(JSRequest *request) {
                    request.finishedBlock = ^(JSOperationResult *result) {
                        res = result;
                        requestFinished = YES;
                    };
                }];                
                while (!requestFinished);
                
                if (res != nil && res.objects.count == 1) {
                    JSResourceDescriptor *cRes = (JSResourceDescriptor *)[res.objects objectAtIndex:0];
                    if ([cRes isDataSource]) {
                        return cRes.uriString;
                    }
                    
                    NSString *uri = [self findDataSourceUri:cRes resourceClient:resourceClient];                    
                    if (uri != nil) return uri;                                        
                }
            }
        }
    }
    
    return @"";
}

@end
