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
#import "JMLocalization.h"
#import "JMSingleSelectTableViewController.h"
#import "JMRequestDelegate.h"
#import "JMRotationBase.h"
#import "JMUtils.h"
#import "JMReportViewerViewController.h"
#import "UITableViewCell+SetSeparators.h"
#import <Objection-iOS/Objection.h>

static NSInteger const kJMICSection = 0;
static NSInteger const kJMRunReportSection = 1;

static NSString * const kJMRunCellIdentifier = @"RunCell";
static NSString * const kJMShowSingleSelectSegue = @"ShowSingleSelect";
static NSString * const kJMShowMultiSelectSegue = @"ShowMultiSelect";
static NSString * const kJMRunReportSegue = @"RunReport";

static CGFloat const separatorHeight = 1.0f;

__weak static UIColor * separatorColor;

@interface JMReportOptionsTableViewController()
@property (nonatomic, strong) JMInputControlFactory *inputControlFactory;
// Input Controls that should be presented in UI
@property (nonatomic, strong) NSMutableArray *visibleInputControls;
@end

@implementation JMReportOptionsTableViewController
objection_requires(@"resourceClient", @"reportClient", @"constants", @"reportOptionsUtil")
inject_default_rotation()

@synthesize inputControls = _inputControls;
@synthesize reportClient = _reportClient;
@synthesize resourceClient = _resourceClient;
@synthesize resourceLookup = _resourceLookup;
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
    id defaultCenter = [NSNotificationCenter defaultCenter];

    for (JMInputControlCell *cell in self.inputControls) {
        [defaultCenter removeObserver:cell];
    }
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [JMUtils setTitleForResourceViewController:self];

    // TODO: refactor, remove isKindOfClass: method usage
    if (self.resourceLookup && (!self.inputControls.count ||
            ![self.inputControls.firstObject isKindOfClass:JMInputControlCell.class])) {
        [self updateInputControls];
    }
    
    separatorColor = self.tableView.separatorColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id destinationViewController = segue.destinationViewController;
    NSString *identifier = segue.identifier;

    if ([identifier isEqualToString:kJMShowSingleSelectSegue] ||
        [identifier isEqualToString:kJMShowMultiSelectSegue]) {
        [destinationViewController setCell:sender];

    } else if ([identifier isEqualToString:kJMRunReportSegue]) {
        [destinationViewController setResourceLookup:self.resourceLookup];
        [destinationViewController setParameters:sender];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == kJMICSection) {
        return [JMRequestDelegate isRequestPoolEmpty] ? self.visibleInputControls.count : 0;
    }
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case kJMICSection:
            return [self.visibleInputControls objectAtIndex:indexPath.row];
            
        case kJMRunReportSection:
        default: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kJMRunCellIdentifier];
            cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
            cell.backgroundColor = [UIColor clearColor];

            UIButton *run = (UIButton *) [cell viewWithTag:1];
            run.titleLabel.text = JMCustomLocalizedString(@"dialog.button.run.report", nil);
            [JMUtils setBackgroundImagesForButton:run
                                        imageName:@"blue_button.png"
                             highlightedImageName:@"blue_button_highlighted.png"
                                       edgesInset:18.0f];
            return cell;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kJMRunReportSection) return 50.0f;
    return [[self.visibleInputControls objectAtIndex:indexPath.row] height];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return (section == kJMICSection && self.visibleInputControls.count > 0) ? 12.0f : 1.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 8.0f;
}

#pragma mark - Actions

- (IBAction)runReport:(id)sender
{
    if (self.isRestV2) {
        [self restV2RunReport];
    } else {
        [self restV1RunReport];
    }
}

#pragma mark - Private -
#pragma mark Configuration

// TODO: make global
- (BOOL)isRestV2
{
    // TODO: change server version to 5.2.0 instead of 5.5.0 (EMERALD_TWO)
    return self.reportClient.serverProfile.serverInfo.versionAsInteger >= self.constants.VERSION_CODE_EMERALD_TWO;
}

- (void)configureInputControlCell:(id)cell
{
    if ([cell conformsToProtocol:@protocol(JMResourceClientHolder)]) {
        [cell setResourceClient:self.resourceClient];
        if (self.isRestV2) {
            [cell setResourceLookup:self.resourceLookup];
        } else {
            [cell setResourceDescriptor:self.resourceDescriptor];
        }
    }

    if ([cell conformsToProtocol:@protocol(JMReportClientHolder)]) {
        [cell setReportClient:self.reportClient];
    }
}

- (JMRequestDelegateFinalBlock)finalBlockForReportOptions:(__weak JMReportOptionsTableViewController *)reportOptions
{
    return ^{
        if (!reportOptions.visibleInputControls.count) {
            reportOptions.visibleInputControls = [NSMutableArray array];
            
            for (NSUInteger i = 0, count = reportOptions.inputControls.count; i < count; i++) {
                JMInputControlCell *cell = [reportOptions.inputControls objectAtIndex:i];
                
                if (!cell.isHidden) {
                    [cell setTopSeparatorWithHeight:separatorHeight color:separatorColor tableViewStyle:self.tableView.style];
                    // Check if this is the last IC
                    if (i == count - 1) {
                        // And set bottom separator if yes
                        [cell setBottomSeparatorWithHeight:separatorHeight color:separatorColor tableViewStyle:self.tableView.style];
                    }
                    [reportOptions.visibleInputControls addObject:cell];
                }
            }
        }

        [reportOptions.tableView reloadData];
    };
}

#pragma mark Input Controls

- (void)updateInputControls
{
    __weak JMReportOptionsTableViewController *weakSelf = self;
    NSArray *inputControlsData = [self.inputControls copy];
    [self.inputControls removeAllObjects];

    [JMRequestDelegate setFinalBlock:[self finalBlockForReportOptions:weakSelf]];

    if (self.isRestV2) {
        for (JSInputControlDescriptor *inputControlDescriptor in inputControlsData) {
            [self createCellFromInputControlDescriptor:inputControlDescriptor];
        }
    } else {
        // Update dependencies for IC
        for (JSInputControlWrapper *i in inputControlsData) {
            for (NSString *parameter in i.parameterDependencies) {
                for (JSInputControlWrapper *j in inputControlsData) {
                    if (j != i && [j.name isEqualToString:parameter]) {
                        [j addSlaveDependency:i];
                        [i addMasterDependency:j];
                    }
                }
            }
        }

        [self cleanupDependencies:inputControlsData];

        for (JSInputControlWrapper *inputControl in inputControlsData) {
            if (!inputControl.dataType && inputControl.dataTypeUri.length > 0) {
                [self requestDataTypeForInputControlWrapper:inputControl];
            } else {
                [self createCellFromWrapper:inputControl];
            }
        }

        [[NSNotificationCenter defaultCenter] postNotificationName:kJMUpdateInputControlQueryDataNotification
                                                            object:nil];
        
        // Check if application is still requesting information about Input Controls cascades via REST v1
        if (![JMRequestDelegate isRequestPoolEmpty]) {
            // If yes then present Cancel dialog for this view controller
            [JMCancelRequestPopup presentInViewController:self message:@"status.loading" restClient:self.resourceClient cancelBlock:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }
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

- (void)restV2RunReport
{
    if (!self.inputControls.count) {
        [self performSegueWithIdentifier:kJMRunReportSegue sender:nil];
        return;
    }

    NSMutableArray *ids = [NSMutableArray array];
    NSMutableArray *parameters = [NSMutableArray array];

    for (JMInputControlCell *cell in self.inputControls) {
        [ids addObject:cell.inputControlDescriptor.uuid];
        JSReportParameter *reportParameter = [[JSReportParameter alloc] initWithName:cell.inputControlDescriptor.uuid
                                                                               value:cell.inputControlDescriptor.selectedValues];
        [parameters addObject:reportParameter];
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
            [JMRequestDelegate setFinalBlock:[self finalBlockForReportOptions:reportOptions]];
        } else {
            NSMutableDictionary *parametersToUpdate = [NSMutableDictionary dictionary];

            for (JMInputControlCell *cell in self.inputControls) {
                if (cell.value != nil) {
                    [parametersToUpdate setObject:cell.value forKey:cell.inputControlDescriptor.uuid];
                }
            }

            [self.reportOptionsUtil updateReportOptions:parametersToUpdate forReport:reportOptions.resourceLookup.uri];
            [reportOptions performSegueWithIdentifier:kJMRunReportSegue sender:parameters];
        }
    }];

    [self.reportClient updatedInputControlsValues:self.resourceLookup.uri
                                              ids:ids
                                   selectedValues:parameters
                                         delegate:delegate];
}

@end
