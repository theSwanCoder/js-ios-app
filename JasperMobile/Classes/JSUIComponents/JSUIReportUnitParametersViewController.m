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
//  JSUIReportUnitParametersViewController.m
//  Jaspersoft Corporation
//

#import "JSUIReportUnitParametersViewController.h"
#import "JSInputControlCell.h"
#import "JSUIResourceViewController.h"
#import "JSUIReportUnitViewController.h"
#import "JasperMobileAppDelegate.h"
#import "UIAlertView+LocalizedAlert.h"
#import "JSLocalization.h"
#import "JaspersoftSDK.h"

@implementation JSUIReportUnitParametersViewController

@synthesize descriptor;
@synthesize reportClient;
@synthesize allInputControls;

#pragma mark -
#pragma mark View lifecycle

#define CONST_Cell_height 44.0f
#define CONST_Cell_Content_width 200.0f
#define CONST_Cell_Label_width 200.0f
#define CONST_Cell_width 280.0f
#define CONST_labelFontSize 12
#define CONST_detailFontSize 15
#define INPUT_CONTROLS_SECTION 0
#define TOOLS_SECTION 1
#define RUN_SECTION 2

static UIFont *labelFont;
static UIFont *detailFont;

- (void)viewDidLoad {
	if (descriptor != nil) {
		self.title = [descriptor label];
	}
	[super viewDidLoad];
}

- (id)initWithStyle:(UITableViewStyle)style {
	if ((self = [super initWithStyle:style])) {
		descriptor = nil;
		resourceLoaded = NO;
		allInputControls = [[NSMutableDictionary alloc] init];
		inputControlCells = [[NSMutableArray alloc] initWithCapacity:0];
        inputControls = [[NSMutableArray alloc] initWithCapacity:0];
        
	}
	return self;	
}

- (void)requestFinished:(JSOperationResult *)res {
    JSConstants *constants = [JSConstants sharedInstance];
	
	if (res == nil) {
        [[UIAlertView localizedAlert:@"" message:@"error.readingresponse.dialog.msg" delegate:nil cancelButtonTitle:@"dialog.button.ok" otherButtonTitles:nil] show];
	} else if (res.statusCode >= 400) {
        [[UIAlertView localizedAlert:@"" message:@"error.readingresponse.dialog.msg" delegate:nil cancelButtonTitle:@"dialog.button.ok" otherButtonTitles:nil] show];
    } else {
		if (res.objects.count > 0) {
            if ([self.reportClient.serverProfile.serverInfo versionAsInteger] >= [JSConstants sharedInstance].VERSION_CODE_EMERALD) {
                for (JSInputControlDescriptor *icDescriptor in res.objects) {
                    if (icDescriptor.visible.boolValue) {
                        JSInputControlCell *cell = [JSInputControlCell inputControlWithInputControlDescriptor:icDescriptor resourceDescriptor:self.descriptor tableViewController:self reportClient:self.reportClient];
                        [inputControls addObject:icDescriptor];
                        [inputControlCells addObject:cell];
                    }
                }
                
                NSDictionary *reportOptions = [[[JasperMobileAppDelegate sharedInstance] reportOptions] reportOptionsAsDictionaryForReport:self.descriptor.uriString];
                for (JSInputControlCell *cell in inputControlCells) {
                    id options = [reportOptions objectForKey:cell.icDescriptor.uuid];
                    if (options) {
                        cell.wasModified = YES;
                        cell.selectedValue = options;
                    }
                }
            } else {
                self.descriptor = [res.objects objectAtIndex:0];			
                NSString *reportUnitDsUri = nil;
                // Find the data source uri...
                for (int i = 0; i < self.descriptor.childResourceDescriptors.count; ++i) {
                    JSResourceDescriptor *rd = (JSResourceDescriptor *)[self.descriptor.childResourceDescriptors objectAtIndex: i];
                    if ([rd.wsType isEqualToString: constants.WS_TYPE_DATASOURCE] ) {
                        reportUnitDsUri = [rd propertyByName:constants.PROP_FILERESOURCE_REFERENCE_URI].value;
                    } else if ([rd.wsType isEqualToString: constants.WS_TYPE_BEAN] ||
                               [rd.wsType isEqualToString: constants.WS_TYPE_CUSTOM] ||
                               [rd.wsType isEqualToString: constants.WS_TYPE_JDBC] ||
                               [rd.wsType isEqualToString: constants.WS_TYPE_JNDI]) {
                        reportUnitDsUri = rd.uriString;
                    }
                }
                
                for (int i = 0; i < self.descriptor.childResourceDescriptors.count; ++i) {
                    JSResourceDescriptor *rd = (JSResourceDescriptor *)[self.descriptor.childResourceDescriptors objectAtIndex: i];
                    if ([rd.wsType isEqualToString:constants.WS_TYPE_INPUT_CONTROL]) {
                        // Add the input control to this list only if it is visible...
                        NSString *isPropVisible = [rd propertyByName:constants.PROP_INPUTCONTROL_IS_VISIBLE].value ?: @"true";
                        
                        if ([isPropVisible isEqualToString:@"true"]) {	
                            [inputControls addObject:rd];
                            JSInputControlCell *cell = [JSInputControlCell inputControlWithResourceDescriptor:rd tableViewController:self dataSourceUri:reportUnitDsUri resourceClient:[JasperMobileAppDelegate sharedInstance].resourceClient];
                            [inputControlCells addObject:cell];
                        }
                    }
                }
            }
        }
    }
			
    // Update the dependencies of parameters...
    for (int i = 0; i < [inputControlCells count]; i++) {
        JSInputControlCell *cell = [inputControlCells objectAtIndex:i];
        NSArray *dependentByParameters = [cell dependsBy];
        if (dependentByParameters != nil && [dependentByParameters count] > 0) {
            for (int index = 0; index < [dependentByParameters count]; ++index) {
                NSString *paramName = [dependentByParameters objectAtIndex:index];
                
                for (int j=0; j < [inputControlCells count]; j++) {
                    
                    JSInputControlCell *dependencyParameterCell = [inputControlCells objectAtIndex:j];
                    if (dependencyParameterCell == cell) continue;
                    if ([[[dependencyParameterCell descriptor] name] isEqualToString: paramName]) {
                        [cell addDependency:dependencyParameterCell];
                    }
                }
            }
        }
	}
	
	resourceLoaded = true;
	[[self tableView] reloadData];
    [JSUILoadingView hideLoadingView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	
	if (resourceLoaded) return;
	if (descriptor != nil) {
		[self performSelector:@selector(updateTableContent) withObject:nil afterDelay:0.0];
	}	
}

- (void)updateTableContent {
    if (!self.descriptor) return;
    self.navigationItem.title = [NSString stringWithFormat:@"%@", [descriptor label]];
    
    if ([self.reportClient.serverProfile.serverInfo versionAsInteger] >= [JSConstants sharedInstance].VERSION_CODE_EMERALD) {
        
        [JSUILoadingView showCancelableAllRequestsLoadingInView:self.view restClient:self.reportClient cancelBlock:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
        
        [self.reportClient inputControlsForReport:self.descriptor.uriString delegate:self];
    } else {
        JSRESTResource *sharedResourceClient = [JasperMobileAppDelegate sharedInstance].resourceClient;
        // Load this view
        [JSUILoadingView showCancelableLoadingInView:self.view restClient:sharedResourceClient delegate:self cancelBlock:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
        [sharedResourceClient resourceWithQueryData:descriptor.uriString datasourceUri:@"true" resourceParameters:nil delegate:self];
    }
}


- (UIFont*) LabelFont;
{
	if (!labelFont) labelFont = [UIFont boldSystemFontOfSize:CONST_labelFontSize];
	return labelFont;
}

- (UIFont*) DetailFont;
{
	if (!detailFont) detailFont = [UIFont systemFontOfSize:CONST_detailFontSize];
	return detailFont;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if (section == INPUT_CONTROLS_SECTION && resourceLoaded && [inputControls count] > 0) {
		return 12;
	}
    
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 8;
}

#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {	
	int baseSections = 0;
	if (resourceLoaded) baseSections = 3; // Input parameters and Tools...
	return baseSections;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	// Name, Label, Description, type, Preview
	if (descriptor == nil || !resourceLoaded) return 0;
    
    switch (section) {
        case INPUT_CONTROLS_SECTION:
            return [inputControls count];
        case TOOLS_SECTION:
        case RUN_SECTION:
            return 1;
    }
    
    return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	if (indexPath.section == INPUT_CONTROLS_SECTION && resourceLoaded) {
        // User details
		return [inputControlCells objectAtIndex:indexPath.row];
	} else if (indexPath.section == TOOLS_SECTION) {   // User details...
        UITableViewCell *formatCell =  [tableView dequeueReusableCellWithIdentifier:@"FormatCell"];
        if (formatCell == nil) {
            
            formatCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FormatCell"];
            formatCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            reportFormat = @"HTML";
            formatCell.textLabel.text = JSCustomLocalizedString(@"report.output.format", nil);
            formatCell.textLabel.font = [UIFont systemFontOfSize:14.0];
            formatCell.contentView.autoresizesSubviews = YES;
            
            reportFormatLabel = [[UILabel alloc] initWithFrame:CGRectMake(CONST_Cell_width - 25, 10, 60, 21)];
            reportFormatLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
            reportFormatLabel.textAlignment = UITextAlignmentRight;
            reportFormatLabel.tag = 100;
            reportFormatLabel.font = [UIFont systemFontOfSize:14.0];
            reportFormatLabel.textColor = [UIColor colorWithRed:.196 green:0.3098 blue:0.52 alpha:1.0];
            reportFormatLabel.backgroundColor = [UIColor clearColor];
            reportFormatLabel.text = reportFormat;            
            [formatCell.contentView addSubview:reportFormatLabel];
            
            reportFormatCell = formatCell;
        }
        
        return formatCell;
    } else if (indexPath.section == RUN_SECTION) {
        UITableViewCell *runCell =  [tableView dequeueReusableCellWithIdentifier:@"RunCell"];
        if (runCell == nil) {
            
            runCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RunCell"];
            UIView *backView = [[UIView alloc] initWithFrame:CGRectZero];
            backView.backgroundColor = [UIColor clearColor];
            runCell.backgroundView = backView;
            runCell.contentView.autoresizesSubviews = YES;
            
            int buttonWidth = self.tableView.frame.size.width;
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            CGRect frame = CGRectMake(0, 0, buttonWidth, 40);
            button.frame = frame;
            button.tag = 1;
            
            [button.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
            [button setTitle:JSCustomLocalizedString(@"dialog.button.run.report", nil) forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            
            [button setTag:indexPath.row];
            [button addTarget:self action:@selector(runReport) forControlEvents:UIControlEventTouchUpInside];
            
            UIImage *buttonImage = [[UIImage imageNamed:@"b1.png"]
                                    resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
            UIImage *buttonImageHighlight = [[UIImage imageNamed:@"b2.png"]
                                             resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
            [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
            [button setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
            
            [runCell.contentView addSubview:button];
        }
        return runCell;
    }
    
	// We shouldn't reach this point, but return an empty cell just in case
    return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NoCell"];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {	
    if (indexPath.section == INPUT_CONTROLS_SECTION) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if ([cell isKindOfClass: [JSInputControlCell class]]) {
            return [(JSInputControlCell *)cell selectable] ? indexPath : nil;
        }
    }
    
	return indexPath;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {	
	if (indexPath.section == INPUT_CONTROLS_SECTION) {
		// Get selected cell
		if (inputControlCells != nil && inputControlCells.count > indexPath.row) {
			UITableViewCell *cell = [inputControlCells objectAtIndex:indexPath.row];
			if ([cell isKindOfClass: [JSInputControlCell class]]) {
				return [(JSInputControlCell *)cell height];
			}
		}
	} else if (indexPath.section == TOOLS_SECTION || indexPath.section == RUN_SECTION) {
		return 44.0f;
	}
	
	return [self.tableView rowHeight];
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	if (indexPath.section == INPUT_CONTROLS_SECTION) {
		// Get selected cell
		UITableViewCell *cell = [inputControlCells objectAtIndex:indexPath.row];
		if ([cell isKindOfClass: [JSInputControlCell class]])
		{
			[(JSInputControlCell *)cell cellDidSelected];
		}
	} else if (indexPath.section == TOOLS_SECTION) {
        JSListSelectorViewController *rvc = [[JSListSelectorViewController alloc] initWithStyle:UITableViewStyleGrouped];
        rvc.values  = [NSArray arrayWithObjects:@"HTML", @"PDF", nil];
        rvc.mandatory = YES;
        NSNumber *selectedReportFormat;
        if ([reportFormat isEqualToString:@"HTML"]) {
            selectedReportFormat = [NSNumber numberWithInt:0];
        } else {
            selectedReportFormat = [NSNumber numberWithInt:1];
        }
        
        rvc.selectedValues = [NSMutableArray arrayWithObject:selectedReportFormat];//selectedVals;
        rvc.selectionDelegate = self;
        [self.navigationController pushViewController:rvc animated:YES];
    }
}

- (void)setSelectedIndexes:(NSArray *)indexes {
    if ([indexes count]) {
        if ([[indexes objectAtIndex:0] intValue] == 0) {
            reportFormat = @"HTML";
        } else {
            reportFormat = @"PDF";
        }
        
        reportFormatLabel.text = reportFormat;
    }
}

#pragma mark -
#pragma mark Report Execution

- (void)runReport {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
	
	for (int i=0; i< [inputControlCells count]; ++i) {
		UITableViewCell *cell = [inputControlCells objectAtIndex:i];
		if ([cell isKindOfClass: [JSInputControlCell class]]) {
            id value = nil;
            if ([(JSInputControlCell *)cell icDescriptor]) {
                value = [(JSInputControlCell *)cell formattedSelectedValue];
            } else {
                value = [(JSInputControlCell *)cell selectedValue];
            }
            
			if (value != nil) {
                [params setObject:value forKey:[(JSInputControlCell *)cell icDescriptor].uuid ?: [(JSInputControlCell *)cell descriptor].name];
            }
		}
	}    
    
    UIViewController *reportViewer = nil;    
    
    JSUIReportUnitViewController *reportPdfViewer = [[JSUIReportUnitViewController alloc] initWithNibName:@"JSUIReportUnitViewController" bundle:nil];
    [reportPdfViewer setDescriptor:self.descriptor];
    [reportPdfViewer setReportClient:self.reportClient];
    [reportPdfViewer setPreviousController:self];
    [reportPdfViewer setFormat:reportFormat];
    [reportPdfViewer setParameters:params];
    reportViewer = reportPdfViewer;   
    [self presentModalViewController:reportViewer animated:YES];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
}

@end

