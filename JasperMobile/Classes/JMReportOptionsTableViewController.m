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
//  JMReportOptionsTableViewController.m
//  Jaspersoft Corporation
//

#import "JMReportOptionsTableViewController.h"
#import "JMCancelRequestPopup.h"
#import "JMConstants.h"
#import "JMInputControlCell.h"
#import "JMInputControlFactory.h"
#import "JMSingleSelectTableViewController.h"
#import "JMRequestDelegate.h"
#import "JMUtils.h"
#import "JMReportViewerViewController.h"
#import <Objection-iOS/Objection.h>

#define kJMICSection 0
#define kJMReportFormatSection 1
#define kJMRunReportSection 2

static NSString * const kJMRunCellIdentifier = @"RunCell";
static NSString * const kJMShowSingleSelectSegue = @"ShowSingleSelect";
static NSString * const kJMShowMultiSelectSegue = @"ShowMultiSelect";
static NSString * const kJMRunReportSegue = @"RunReport";

@interface JMReportOptionsTableViewController()
@property (nonatomic, strong) JMInputControlCell *reportFormatCell;
@property (nonatomic, strong) JMInputControlFactory *inputControlFactory;
@end

@implementation JMReportOptionsTableViewController
objection_requires(@"resourceClient", @"reportClient", @"constants", @"reportOptionsUtil")
inject_default_rotation()

@synthesize inputControls = _inputControls;
@synthesize reportClient = _reportClient;
@synthesize resourceClient = _resourceClient;
@synthesize resourceDescriptor = _resourceDescriptor;

- (JMInputControlFactory *)inputControlFactory
{
    if (!_inputControlFactory) {
        _inputControlFactory = [[JMInputControlFactory alloc] initWithTableViewController:self];
    }
    
    return _inputControlFactory;
}

#pragma mark - Initialization

- (void)awakeFromNib
{
    [super awakeFromNib];
    [[JSObjection defaultInjector] injectDependencies:self];
    self.inputControls = [NSMutableArray array];
}

- (void)dealloc
{
    [self clearData];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [JMUtils setTitleForResourceViewController:self];

    if (self.resourceDescriptor && !self.inputControls.count) {
        [self updateInputControls];
    }
    
    if (!self.reportFormatCell) {
        NSArray *reportOutputFormats = @[
            kJMRunOutputFormatHTML, kJMRunOutputFormatPDF
        ];
        self.reportFormatCell = [self.inputControlFactory reportOutputFormatCellWithFormats:reportOutputFormats];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id destinationViewController = segue.destinationViewController;
    NSString *identifier = segue.identifier;

    if ([identifier isEqualToString:kJMShowSingleSelectSegue] ||
        [identifier isEqualToString:kJMShowMultiSelectSegue]) {
        [destinationViewController setCell:sender];

    } else if ([identifier isEqualToString:kJMRunReportSegue]) {
        [destinationViewController setResourceDescriptor:self.resourceDescriptor];
        [destinationViewController setReportFormat:self.reportFormatCell.value];
        [destinationViewController setParameters:sender];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == kJMICSection) {
        return [JMRequestDelegate isRequestPoolEmpty] ? self.inputControls.count : 0;
    }
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case kJMICSection:
            return [self.inputControls objectAtIndex:indexPath.row];
            
        case kJMReportFormatSection:
            return self.reportFormatCell;
            
        case kJMRunReportSection:
        default: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kJMRunCellIdentifier];
            cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];

            UIButton *run = (UIButton *) [cell viewWithTag:1];
            [JMUtils setBackgroundImagesForButton:run
                                        imageName:@"run_report_button.png"
                             highlightedImageName:@"run_report_button_highlighted.png"
                                       edgesInset:18.0f];
            return cell;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kJMRunReportSection) return 50.0f;
    if (indexPath.section == kJMReportFormatSection) return self.reportFormatCell.height;
    return [[self.inputControls objectAtIndex:indexPath.row] height];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return (section == kJMICSection && self.inputControls.count > 0) ? 12.0f : 1.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 8.0f;
}

#pragma mark - Actions

- (IBAction)runReport:(id)sender
{
    if (self.reportClient.serverProfile.serverInfo.versionAsInteger >= self.constants.VERSION_CODE_EMERALD) {
        [self restV2RunReport];
    } else {
        [self restV1RunReport];
    }
}

#pragma mark - Private -
#pragma mark Configuration

- (void)configureInputControlCell:(id)cell
{
    if ([cell conformsToProtocol:@protocol(JMResourceClientHolder)]) {
        [cell setResourceClient:self.resourceClient];
        [cell setResourceDescriptor:self.resourceDescriptor];
    }

    if ([cell conformsToProtocol:@protocol(JMReportClientHolder)]) {
        [cell setReportClient:self.reportClient];
    }
}

- (void)clearData
{
    id defaultCenter = [NSNotificationCenter defaultCenter];
    
    for (JMInputControlCell *cell in self.inputControls) {
        [defaultCenter removeObserver:cell];
        [cell clearData];
    }
    
    self.inputControls = nil;
    self.inputControlFactory = nil;
}

#pragma mark Input Controls

- (void)updateInputControls
{
    JMCancelRequestBlock cancelBlock = ^{
        [self.navigationController popViewControllerAnimated:YES];
    };

    if (self.reportClient.serverProfile.serverInfo.versionAsInteger >= self.constants.VERSION_CODE_EMERALD) {
        [JMCancelRequestPopup presentInViewController:self message:@"status.loading" restClient:self.reportClient cancelBlock:cancelBlock];

        NSArray *reportParameters = [self.reportOptionsUtil reportOptionsAsParametersForReport:self.resourceDescriptor.uriString];
        [self.reportClient inputControlsForReport:self.resourceDescriptor.uriString ids:nil selectedValues:reportParameters delegate:self.inputControlsForReportDelegate];
    } else {
        [JMCancelRequestPopup presentInViewController:self message:@"status.loading" restClient:self.resourceClient cancelBlock:cancelBlock];
        [self.resourceClient resource:self.resourceDescriptor.uriString delegate:self.resourceDelegate];
    }
}

- (void)cleanupDependencies:(NSArray *)inputControls
{
    for (JSInputControlWrapper *inputControl in inputControls) {
        NSArray *slaveDependencies = inputControl.getSlaveDependencies;
        NSMutableArray *subDependentControls = [NSMutableArray array];

        // Collect all sub dependent controls
        for (JSInputControlWrapper *dependentControl in slaveDependencies) {
            [subDependentControls addObjectsFromArray:[self allSubDependentControls:dependentControl]];
        }

        // Remove controls that have transitive dependencies
        for (JSInputControlWrapper *subDependentControl in subDependentControls) {
            [inputControl removeSlaveDependency:subDependentControl];
        }
    }
}

- (NSArray *)allSubDependentControls:(JSInputControlWrapper *)inputControl
{
    NSMutableArray *result = [NSMutableArray array];
    NSArray *dependentControls = inputControl.getSlaveDependencies;
    
    // Collect recursively dependent controls if it is not empty
    if (dependentControls) {
        [result addObjectsFromArray:dependentControls];
        for (JSInputControlWrapper *dependentControl in dependentControls) {
            [result addObjectsFromArray:[self allSubDependentControls:dependentControl]];
        }
    }
    
    return result;
}

#pragma mark Rest v1

- (void)createCellFromWrapper:(JSInputControlWrapper *)inputControl
{
    id cell = [self.inputControlFactory inputControlWithInputControlWrapper:inputControl];
    [self configureInputControlCell:cell];
    [self.inputControls addObject:cell];
}

- (id <JSRequestDelegate>)resourceDelegate
{
    __weak JMReportOptionsTableViewController *reportOptions = self;
    
    // Will be invoked in the end after all requests will finish 
    [JMRequestDelegate setFinalBlock:^{
        [reportOptions.tableView reloadData];
    }];
    
    return [JMRequestDelegate requestDelegateForFinishBlock:^(JSOperationResult *result) {
        reportOptions.resourceDescriptor = [result.objects objectAtIndex:0];
        
        NSMutableArray *inputControlWrappers = [NSMutableArray array];
        
        // Create wrapper for IC
        for (JSResourceDescriptor *childResourceDescriptor in reportOptions.resourceDescriptor.childResourceDescriptors) {
            if ([childResourceDescriptor.wsType isEqualToString:reportOptions.constants.WS_TYPE_INPUT_CONTROL]){
                JSInputControlWrapper *inputControl = [[JSInputControlWrapper alloc] initWithResourceDescriptor:childResourceDescriptor];
                [inputControlWrappers addObject:inputControl];
            }
        }
        
        // Update dependencies for IC
        for (JSInputControlWrapper *i in inputControlWrappers) {
            for (NSString *parameter in i.parameterDependencies) {
                for (JSInputControlWrapper *j in inputControlWrappers) {
                    if (j != i && [j.name isEqualToString:parameter]) {
                        [j addSlaveDependency:i];
                        [i addMasterDependency:j];
                    }
                }
            }
        }
        
        [reportOptions cleanupDependencies:inputControlWrappers];
        
        for (JSInputControlWrapper *inputControl in inputControlWrappers) {
            if (!inputControl.dataType && inputControl.dataTypeUri.length > 0) {
                [reportOptions requestDataTypeForInputControlWrapper:inputControl];
            } else {
                [reportOptions createCellFromWrapper:inputControl];
            }
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kJMUpdateInputControlQueryDataNotification
                                                            object:nil];
    } viewControllerToDismiss:self];
}

- (void)requestDataTypeForInputControlWrapper:(JSInputControlWrapper *)inputControlWrapper;
{
    // Define self with __weak modifier (require to avoid circular references and for
    // proper memory management)
    __weak JMReportOptionsTableViewController *reportOptions = self;
    __block JSInputControlWrapper *inputControl = inputControlWrapper;
    
    JMRequestDelegate *delegate = [JMRequestDelegate requestDelegateForFinishBlock:^(JSOperationResult *result) {
        JSResourceDescriptor *dataType = [result.objects objectAtIndex:0];
        JSResourceProperty *dataTypeProperty = [dataType propertyByName:reportOptions.constants.PROP_DATATYPE_TYPE];
        [inputControl setDataType:dataTypeProperty.value.intValue];
        [reportOptions createCellFromWrapper:inputControl];
    }];
    
    [self.resourceClient resource:inputControlWrapper.dataTypeUri delegate:delegate];
}

- (void)restV1RunReport
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    for (JMInputControlCell *cell in self.inputControls) {
        if (cell.value != nil) {
            [parameters setObject:cell.value forKey:cell.inputControlWrapper.name];
        }
    }
    [self performSegueWithIdentifier:kJMRunReportSegue sender:parameters];
}

#pragma mark Rest v2

- (void)createCellFromInputControlDescriptor:(JSInputControlDescriptor *)inputControl
{
    id cell = [self.inputControlFactory inputControlWithInputControlDescriptor:inputControl];
    [self configureInputControlCell:cell];
    [self.inputControls addObject:cell];
}

- (JMRequestDelegate *)inputControlsForReportDelegate
{
    __weak JMReportOptionsTableViewController *reportOptions = self;

    // Will be invoked in the end after all requests will finish
    [JMRequestDelegate setFinalBlock:^{
        [reportOptions.tableView reloadData];
    }];

    return [JMRequestDelegate requestDelegateForFinishBlock:^(JSOperationResult *result) {
        for (JSInputControlDescriptor *inputControlDescriptor in result.objects) {
            [reportOptions createCellFromInputControlDescriptor:inputControlDescriptor];
        }
    } viewControllerToDismiss:self];
}

- (void)restV2RunReport
{
    if (!self.inputControls.count) {
        [self performSegueWithIdentifier:kJMRunReportSegue sender:nil];
        return;
    }

    NSMutableArray *ids = [NSMutableArray array];
    NSMutableArray *parametersToValidate = [NSMutableArray array];

    for (JMInputControlCell *cell in self.inputControls) {
        [ids addObject:cell.inputControlDescriptor.uuid];
        JSReportParameter *reportParameter = [[JSReportParameter alloc] initWithName:cell.inputControlDescriptor.uuid
                                                                               value:cell.inputControlDescriptor.selectedValues];
        [parametersToValidate addObject:reportParameter];
    }

    [JMCancelRequestPopup presentInViewController:self message:@"status.loading" restClient:self.reportClient cancelBlock:nil];

    __weak JMReportOptionsTableViewController *reportOptions = self;

    JMRequestDelegate *delegate = [JMRequestDelegate requestDelegateForFinishBlock:^(JSOperationResult *result) {
        BOOL isValid = YES;

        for (JSInputControlState *state in result.objects) {
            if (!state.error.length) continue;

            for (JMInputControlCell *cell in reportOptions.inputControls) {
                if ([cell.inputControlDescriptor.uuid isEqualToString:state.uuid]) {
                    cell.errorMessage = state.error;
                    isValid = NO;
                }
            }
        }

        if (!isValid) {
            [JMRequestDelegate setFinalBlock:^{
                [reportOptions.tableView reloadData];
            }];
        } else {
            NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

            for (JMInputControlCell *cell in self.inputControls) {
                if (cell.value != nil) {
                    [parameters setObject:cell.value forKey:cell.inputControlDescriptor.uuid];
                }
            }

            [self.reportOptionsUtil updateReportOptions:parameters forReport:reportOptions.resourceDescriptor.uriString];
            [reportOptions performSegueWithIdentifier:kJMRunReportSegue sender:parameters];
        }
    }];

    [self.reportClient updatedInputControlsValues:self.resourceDescriptor.uriString
                                              ids:ids
                                   selectedValues:parametersToValidate
                                         delegate:delegate];
}

@end
