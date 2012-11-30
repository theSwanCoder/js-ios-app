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
//  JSInputControlCell.m
//  Jaspersoft Corporation
//

#import "JSInputControlCell.h"
#import "JSListSelectorViewController.h"
#import "JSDateTimeSelectorViewController.h"
#import "JSBooleanInputControlCell.h"
#import "JSTextInputControlCell.h"
#import "JSNumberInputControlCell.h"
#import "JSDateInputControlCell.h"
#import "JSDateTimeInputControlCell.h"
#import "JSSingleSelectListInputControlCell.h"
#import "JSMultiselectListInputControlCell.h"
#import "JSUIReportUnitParametersViewController.h"
#import "JSListItem.h"

// Left and right padding
@interface TargetAction : NSObject

@property (nonatomic, retain) id target;
@property (nonatomic) SEL action;

@end

@implementation TargetAction
@synthesize target,action;
@end

@implementation JSInputControlCell

@synthesize descriptor;
@synthesize selectedValue;
@synthesize nameLabel;
@synthesize tableViewController;
@synthesize dataSourceUri;
@synthesize resourceClient;
@synthesize previousSelectedValue;
@synthesize wasModified;

+ (id)inputControlWithResourceDescriptor:(JSResourceDescriptor *)rd tableViewController:(UITableViewController *)tv
                           dataSourceUri:(NSString *)dsUri resourceClient:(JSRESTResource *)resourceClient {
    JSConstants *constants = [JSConstants sharedInstance];
    NSInteger inputControlType = [[rd propertyByName:constants.PROP_INPUTCONTROL_TYPE].value integerValue] ?: constants.IC_TYPE_BOOLEAN;
	JSInputControlCell *ic = nil;
    
	if (inputControlType == constants.IC_TYPE_BOOLEAN) {
		ic = [[JSBooleanInputControlCell alloc] initWithResourceDescriptor:rd tableViewController:tv];
	} else if (inputControlType == constants.IC_TYPE_SINGLE_VALUE) {
		// Check the data type
		JSResourceDescriptor *datatTypeDescriptor = [self findDataType:rd forResourceClient:resourceClient];
        
		NSInteger dataType = [[datatTypeDescriptor propertyByName:constants.PROP_DATATYPE_TYPE].value integerValue] ?: constants.DT_TYPE_TEXT;
        
        if (dataType == constants.DT_TYPE_TEXT) {
			ic = [[JSTextInputControlCell alloc] initWithResourceDescriptor:rd tableViewController:tv];
		} else if (dataType == constants.DT_TYPE_NUMBER) {
			ic = [[JSNumberInputControlCell alloc] initWithResourceDescriptor:rd tableViewController:tv];
		} else if (dataType == constants.DT_TYPE_DATE) {
			ic = [[JSDateInputControlCell alloc] initWithResourceDescriptor:rd tableViewController:tv];
		} else if (dataType == constants.DT_TYPE_DATE_TIME) {
			ic = [[JSDateTimeInputControlCell alloc] initWithResourceDescriptor:rd tableViewController:tv];
		}
	} else if (inputControlType == constants.IC_TYPE_SINGLE_SELECT_LIST_OF_VALUES ||
               inputControlType == constants.IC_TYPE_SINGLE_SELECT_LIST_OF_VALUES_RADIO ||
               inputControlType == constants.IC_TYPE_SINGLE_SELECT_QUERY ||
               inputControlType == constants.IC_TYPE_SINGLE_SELECT_QUERY_RADIO)	{
        ic = [[JSSingleSelectListInputControlCell alloc] initWithDescriptor:rd
                                                        tableViewController:tv
                                                              dataSourceUri:dsUri
                                                             resourceClient:resourceClient];
	} else if (inputControlType == constants.IC_TYPE_MULTI_SELECT_LIST_OF_VALUES ||
			   inputControlType == constants.IC_TYPE_MULTI_SELECT_LIST_OF_VALUES_CHECKBOX ||
			   inputControlType == constants.IC_TYPE_MULTI_SELECT_QUERY ||
			   inputControlType == constants.IC_TYPE_MULTI_SELECT_QUERY_CHECKBOX) {
        ic = [[JSMultiselectListInputControlCell alloc] initWithDescriptor:rd
                                                       tableViewController:tv
                                                             dataSourceUri:dsUri
                                                            resourceClient:resourceClient];
	}
	
	if (ic == nil) ic = [[JSInputControlCell alloc] initWithResourceDescriptor:rd tableViewController:tv];
    ic.resourceClient = resourceClient;
    return ic;
}

+ (id)inputControlWithInputControlDescriptor:(JSInputControlDescriptor *)icDescriptor resourceDescriptor:(JSResourceDescriptor *)resourceDescriptor tableViewController:(UITableViewController *)tv reportClient:(JSRESTReport *)reportClient {
    JSConstants *constants = [JSConstants sharedInstance];
	JSInputControlCell *ic = nil;
    NSString *icType = icDescriptor.type;
    
	if ([icType isEqualToString:constants.ICD_TYPE_BOOL]) {
		ic = [[JSBooleanInputControlCell alloc] initWithInputControlDescriptor:icDescriptor
                                                            resourceDescriptor:resourceDescriptor tableViewController:tv];
	} else if ([icType isEqualToString:constants.ICD_TYPE_SINGLE_VALUE_TEXT]) {
        ic = [[JSTextInputControlCell alloc] initWithInputControlDescriptor:icDescriptor
                                                         resourceDescriptor:resourceDescriptor tableViewController:tv];
    } else if ([icType isEqualToString:constants.ICD_TYPE_SINGLE_VALUE_NUMBER]) {
        ic = [[JSNumberInputControlCell alloc] initWithInputControlDescriptor:icDescriptor
                                                           resourceDescriptor:resourceDescriptor tableViewController:tv];
    } else if ([icType isEqualToString:constants.ICD_TYPE_SINGLE_VALUE_DATE]) {
        ic = [[JSDateInputControlCell alloc] initWithInputControlDescriptor:icDescriptor
                                                         resourceDescriptor:resourceDescriptor tableViewController:tv];
    } else if ([icType isEqualToString:constants.ICD_TYPE_SINGLE_VALUE_DATETIME]) {
        ic = [[JSDateTimeInputControlCell alloc] initWithInputControlDescriptor:icDescriptor
                                                             resourceDescriptor:resourceDescriptor tableViewController:tv];
    } else if ([icType isEqualToString:constants.ICD_TYPE_SINGLE_SELECT] ||
               [icType isEqualToString:constants.ICD_TYPE_SINGLE_SELECT_RADIO]) {
        ic = [[JSSingleSelectListInputControlCell alloc] initWithInputControlDescriptor:icDescriptor resourceDescriptor:resourceDescriptor tableViewController:tv];
	} else if ([icType isEqualToString:constants.ICD_TYPE_MULTI_SELECT] ||
               [icType isEqualToString:constants.ICD_TYPE_MULTI_SELECT_CHECKBOX]) {
        ic = [[JSMultiselectListInputControlCell alloc] initWithInputControlDescriptor:icDescriptor resourceDescriptor:resourceDescriptor tableViewController:tv];
	}
    
    ic.reportClient = reportClient;
    [[(JSUIReportUnitParametersViewController *)tv allInputControls] setObject:ic forKey:icDescriptor.uuid];
    return ic;
}


- (id)initWithResourceDescriptor:(JSResourceDescriptor *)rd tableViewController: (UITableViewController *)tv
{
	return [self initWithResourceDescriptor:rd tableViewController:tv dataSourceUri: nil];
}


- (id)initWithResourceDescriptor:(JSResourceDescriptor *)rd tableViewController: (UITableViewController *)tv dataSourceUri:(NSString *)dsUri {
	if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]))
	{
		self.descriptor = rd;
		tableViewController = tv;
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.dataSourceUri = dsUri;
		targetActionsOnChange = [[NSMutableArray alloc] initWithCapacity: 0];
		dependetByInputControls = [[NSMutableArray alloc] initWithCapacity:0];
		
		height = 44.0f; // standard height.
		[self createNameLabel];
	}
	
	return self;
}

- (id)initWithInputControlDescriptor:(JSInputControlDescriptor *)icDescriptor resourceDescriptor:(JSResourceDescriptor *)resourceDescriptor tableViewController:(UITableViewController *)tv {
	if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]))
	{
        self.descriptor = resourceDescriptor;
		tableViewController = tv;
		self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.icDescriptor = icDescriptor;
		targetActionsOnChange = [[NSMutableArray alloc] initWithCapacity: 0];
		dependetByInputControls = [[NSMutableArray alloc] initWithCapacity:0];
        self.wasModified = NO;
		
		height = 44.0f; // standard height.
		[self createNameLabel];
	}
	
	return self;
}


// create the label to display the input control name
-(void)createNameLabel
{
	nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(JS_CELL_PADDING, 10.0, JS_LBL_DEFAULT_WIDTH, 21.0)];
	[self addSubview: nameLabel];
    
	self.nameLabel.font = [UIFont systemFontOfSize:14.0];
	if (self.mandatory) {
		self.nameLabel.font = [UIFont boldSystemFontOfSize:14.0];
	}
	self.nameLabel.textColor = [UIColor blackColor];
	self.nameLabel.autoresizingMask = UIViewAutoresizingNone;
	self.nameLabel.text = (self.icDescriptor != nil) ? self.icDescriptor.label : self.descriptor.label;
    self.nameLabel.backgroundColor = [UIColor clearColor];
	
	if (self.readonly) {
		self.nameLabel.textColor = [UIColor grayColor];
	}
}

// Find the data type of this input control.
// The data type is always the first data type descriptor (if any)
///~ @TODO
+ (JSResourceDescriptor *)findDataType:(JSResourceDescriptor *)rd forResourceClient:(JSRESTResource *)resourceClient  {
	// The data type is always the first child of an input control
	JSResourceDescriptor *dataTypeDescriptor =  [rd.childResourceDescriptors objectAtIndex:0];
    JSConstants *constants = [JSConstants sharedInstance];
	
	// But it could be just a reference to another resource in the repository
	if ([dataTypeDescriptor.wsType isEqualToString:constants.WS_TYPE_REFERENCE] ) {
        
        ///~ @TODO
        NSString *propUri = [dataTypeDescriptor propertyByName:constants.PROP_FILERESOURCE_REFERENCE_URI].value;
        __block JSOperationResult *syncResult = nil;
        __block BOOL requestFinished = NO;
        
        [resourceClient resource:propUri usingBlock:^(JSRequest *request) {
            request.finishedBlock = ^(JSOperationResult *result) {
                syncResult = result;
                requestFinished = YES;
            };
        }];
		
		if (syncResult != nil && syncResult.objects.count > 0) {
			dataTypeDescriptor = [syncResult.objects objectAtIndex:0];
		}
	}
	
	return dataTypeDescriptor;
}


- (BOOL)mandatory {
    NSString *mandatory = [descriptor propertyByName:[JSConstants sharedInstance].PROP_INPUTCONTROL_IS_MANDATORY].value ?: @"";
    return [mandatory isEqualToString:@"true"];
}

- (BOOL)readonly {
    NSString *readonly = [descriptor propertyByName:[JSConstants sharedInstance].PROP_INPUTCONTROL_IS_READONLY].value ?: @"";
    return [readonly isEqualToString:@"true"];
}

- (BOOL)selectable {
	return !self.readonly;
}

- (void)setSelectedValue:(id)vals {
	if (selectedValue == vals) return;
    previousSelectedValue = [selectedValue copy];
    selectedValue = vals;
    
    for (int i = 0; i < [targetActionsOnChange count]; ++i) {
        TargetAction *ta = (TargetAction *)[targetActionsOnChange objectAtIndex:i];
        if ([[ta target] respondsToSelector:[ta action]]) {
            [[ta target] performSelector:[ta action] withObject:self];
        }
    }
    
    if (wasModified) {
        [self updateDependencies];
    }
    
    if (vals && !wasModified) {
        wasModified = YES;
    }
}

- (CGFloat)height {
	return height;
}

- (NSArray *)findParameters:(NSString *)query prefix:(NSString *)prefix postfix:(NSString *)postfix func:(BOOL)isFunction {
	NSMutableArray *paramNames = [NSMutableArray array];
	
	if (query != nil) {
		query = [query copy];
		// 1. check for $P parameters...
		
		NSString *tmpQuery = [NSString stringWithString:query]; // copy of the string...
        
		while ([tmpQuery length] > 2) {
			NSRange textRange;
			textRange =[tmpQuery rangeOfString: prefix];
            
			if(textRange.location != NSNotFound) {
				tmpQuery = [tmpQuery substringFromIndex:textRange.location + textRange.length];
				// find the next bracket;
				textRange =[tmpQuery rangeOfString: postfix];
                
				if (textRange.location != NSNotFound) {
					NSString *param = [tmpQuery substringToIndex: textRange.location];
					
					if (isFunction) {
                        // in this case param contains something like: FUNC, field, param name
                        NSArray *chunks = [param componentsSeparatedByString: @","];
                        if (chunks != nil && [chunks count] == 3) {
                            param = [chunks objectAtIndex:2];
                        } else {
                            param = nil;
                        }
                    }
					
					if (param != nil) {
						[paramNames addObject:[param stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
					}
					tmpQuery = [tmpQuery substringFromIndex:textRange.location + textRange.length];
				}
			} else {
				break;
			}
		}
	}
	
	return paramNames;
}

- (NSArray *)dependsBy {
	NSMutableArray *paramNames = [NSMutableArray array];
	// 1. Look for a query object
	for (int i = 0; i < self.descriptor.childResourceDescriptors.count; ++i) {
		JSResourceDescriptor *rd = (JSResourceDescriptor *)[self.descriptor.childResourceDescriptors objectAtIndex:i];
		if ([[rd wsType] isEqualToString: [JSConstants sharedInstance].WS_TYPE_QUERY]) {
			// Find the query string
			NSString *query = [rd propertyByName:[JSConstants sharedInstance].PROP_QUERY].value;
			
			// 1. check for $P parameters
			[paramNames addObjectsFromArray: [self findParameters:query prefix:@"$P{" postfix: @"}" func: NO]];
			[paramNames addObjectsFromArray: [self findParameters:query prefix:@"$P!{" postfix: @"}" func: NO]];
			[paramNames addObjectsFromArray: [self findParameters:query prefix:@"$X{" postfix: @"}" func: YES]];
		}
	}
    
	if ([paramNames count] > 0) return paramNames;
	return nil;
}

- (void)reloadInputControlQueryData:(NSDictionary *)parameters {
	return;
}

- (void)addTarget:(id)aTarget withAction:(SEL)anAction {
	if (aTarget == nil) return;
	if (aTarget == self) return;
	if (anAction == nil) return;
	TargetAction *ta = [[TargetAction alloc] init];
	ta.target = aTarget;
	ta.action = anAction;
	[targetActionsOnChange addObject:ta];
}

- (void)addDependency:(JSInputControlCell *)inputControlCell {
	if (inputControlCell == nil) return; // Do nothing.
    
	if (![dependetByInputControls containsObject:inputControlCell]) {
		[dependetByInputControls addObject:inputControlCell];
	}
	
	[inputControlCell addTarget:self withAction: @selector(updateInputControl:)];
}

- (void)updateInputControl:(id)sender {
	// Force inputcontrols to reload the data
	NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	
	for (int i = 0; i < [dependetByInputControls count]; ++i) {
		JSInputControlCell *ic = (JSInputControlCell *)[dependetByInputControls objectAtIndex:i];
		if ([ic selectedValue] != nil) {
			id value = [ic selectedValue];
			NSString *name = [[ic descriptor] name];
			[parameters setValue:value forKey:name];
		}
	}
	[self reloadInputControlQueryData:parameters];
}

- (void)cellDidSelected {
    NSLog(@"IC Type \"%@\" was not found or this is new type", self.icDescriptor.type);
}

- (id)formattedSelectedValue {
    return self.selectedValue;
}

- (void)updateDependencies {
    if (self.icDescriptor.slaveDependencies) {
        NSDictionary *inputControls = [(JSUIReportUnitParametersViewController *)self.tableViewController allInputControls];
        
        if (!self.selectedValue) {
            for (NSString *slaveId in self.icDescriptor.slaveDependencies) {
                JSInputControlCell *slave = [inputControls objectForKey:slaveId];
                [self updateICCell:slave state:nil];
            }
            self.previousSelectedValue = nil;
            return;
        }
        
        NSArray *masters = self.icDescriptor.masterDependencies;
        NSMutableArray *values = [[NSMutableArray alloc] init];
        [values addObject:[[JSReportParameter alloc] initWithName:self.icDescriptor.uuid value:[self formattedSelectedValue]]];
        
        for (NSString *master in masters) {
            JSInputControlCell *cell = [inputControls objectForKey:master];
            if (cell) {
                [values addObject:[[JSReportParameter alloc] initWithName:cell.icDescriptor.uuid value:[cell formattedSelectedValue]]];
            }
        }
        
        [JSUILoadingView showCancelableAllRequestsLoadingInView:tableViewController.parentViewController.view restClient:self.reportClient cancelBlock:^{
            [self setSelectedValue:self.previousSelectedValue];
        }];
        
        [self.reportClient updatedInputControlsValues:descriptor.uriString ids:self.icDescriptor.slaveDependencies selectedValues:values usingBlock:^(JSRequest *request) {
            request.finishedBlock = ^(JSOperationResult *result) {
                for (JSInputControlState *state in result.objects) {
                    [self updateICCell:[inputControls objectForKey:state.uuid] state:state];
                }
                [JSUILoadingView hideLoadingView];
            };
        }];
    }
}

///~ @TODO: refactor this duplicates
- (void)updateICCell:(id)inputControlCell state:(JSInputControlState *)state {
    NSMutableArray *values = [[NSMutableArray alloc] init];
    JSConstants *constants = [JSConstants sharedInstance];
    NSString *type = [inputControlCell icDescriptor].type;
    
    if ([constants.ICD_TYPE_BOOL isEqualToString:type] ||
        [constants.ICD_TYPE_SINGLE_VALUE_TEXT isEqualToString:type] ||
        [constants.ICD_TYPE_SINGLE_VALUE_NUMBER isEqualToString:type]) {
        [inputControlCell setSelectedValue:state.value];
    } else if (
               [constants.ICD_TYPE_SINGLE_VALUE_DATE isEqualToString:type] ||
               [constants.ICD_TYPE_SINGLE_VALUE_DATETIME isEqualToString:type]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:[inputControlCell performSelector:@selector(dateFormat)]];
        [dateFormatter dateFromString:state.value];
    } else if ([constants.ICD_TYPE_SINGLE_SELECT isEqualToString:type] ||
               [constants.ICD_TYPE_SINGLE_SELECT_RADIO isEqualToString:type]) {
        for (JSInputControlOption *option in state.options) {
            JSListItem *item = [[JSListItem alloc] initWithName:option.label andValue:option.value selected:option.selected.boolValue];
            [values addObject:item];
        }
        [(JSSingleSelectListInputControlCell *)inputControlCell setItems:values];
        [(JSSingleSelectListInputControlCell *)inputControlCell adjustSelection];
    } else if ([constants.ICD_TYPE_MULTI_SELECT isEqualToString:type] ||
               [constants.ICD_TYPE_MULTI_SELECT_CHECKBOX isEqualToString:type]) {
        for (JSInputControlOption *option in state.options) {
            JSListItem *item = [[JSListItem alloc] initWithName:option.label andValue:option.value selected:option.selected.boolValue];
            [values addObject:item];
        }
        [(JSMultiselectListInputControlCell *)inputControlCell setItems:values];
        [(JSMultiselectListInputControlCell *)inputControlCell adjustSelection];
    }
}

@end