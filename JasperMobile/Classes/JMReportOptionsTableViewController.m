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

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [JMUtils setTitleForResourceViewController:self];
    separatorColor = self.tableView.separatorColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    // TODO: refactor, remove isKindOfClass: method usage
    if ([self.inputControls.firstObject isKindOfClass:JMInputControlCell.class]) return;

    NSArray *inputControlsData = [self.inputControls copy];
    [self.inputControls removeAllObjects];

    for (JSInputControlDescriptor *inputControlDescriptor in inputControlsData) {
        id cell = [self.inputControlFactory inputControlWithInputControlDescriptor:inputControlDescriptor];

        if ([cell conformsToProtocol:@protocol(JMResourceClientHolder)]) {
            [cell setResourceClient:self.resourceClient];
            [cell setResourceLookup:self.resourceLookup];
        }

        if ([cell conformsToProtocol:@protocol(JMReportClientHolder)]) {
            [cell setReportClient:self.reportClient];
        }

        [cell setTopSeparatorWithHeight:separatorHeight color:separatorColor tableViewStyle:self.tableView.style];
        [self.inputControls addObject:cell];
    }

    id lastCell = self.inputControls.lastObject;
    [lastCell setBottomSeparatorWithHeight:separatorHeight color:separatorColor tableViewStyle:self.tableView.style];
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
        return [JMRequestDelegate isRequestPoolEmpty] ? self.inputControls.count : 0;
    }
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case kJMICSection:
            return [self.inputControls objectAtIndex:indexPath.row];
            
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
            [JMRequestDelegate setFinalBlock:^{
                [reportOptions.tableView reloadData];
            }];
        } else {
            NSMutableDictionary *parametersToUpdate = [NSMutableDictionary dictionary];

            for (JMInputControlCell *cell in self.inputControls) {
                if (cell.value != nil) {
                    [parametersToUpdate setObject:cell.value forKey:cell.inputControlDescriptor.uuid];
                }
            }

            [self.reportOptionsUtil updateReportOptions:parametersToUpdate forReport:reportOptions.resourceLookup.uri];

            id params = self.resourceClient.serverProfile.serverInfo.versionAsInteger >= self.constants.VERSION_CODE_EMERALD_TWO ? parameters : parametersToUpdate;
            [reportOptions performSegueWithIdentifier:kJMRunReportSegue sender:params];
        }
    }];

    [self.reportClient updatedInputControlsValues:self.resourceLookup.uri
                                              ids:ids
                                   selectedValues:parameters
                                         delegate:delegate];
}

@end
