/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2014 TIBCO Software, Inc. All rights reserved.
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


#import "JMReportOptionsViewController.h"
#import "JMRequestDelegate.h"
#import "JMSingleSelectTableViewController.h"
#import "UIViewController+FetchInputControls.h"
#import "UITableViewCell+Additions.h"

#import "JMInputControlsHolder.h"
#import "JMResourceClientHolder.h"
#import "JMReportClientHolder.h"
#import "JMCancelRequestPopup.h"
#import "JMRequestDelegate.h"
#import "JMInputControlCell.h"


@interface JMReportOptionsViewController () <UITableViewDelegate, UITableViewDataSource, JMInputControlsHolder, JMReportClientHolder, JMResourceClientHolder>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel    *titleLabel;
@property (nonatomic, strong) JSConstants       *constants;

@end

@implementation JMReportOptionsViewController
objection_requires(@"resourceClient", @"reportClient", @"constants")

@synthesize resourceClient = _resourceClient;
@synthesize reportClient = _reportClient;
@synthesize resourceLookup = _resourceLookup;
@synthesize inputControls = _inputControls;

#pragma mark - Initialization

- (void)awakeFromNib
{
    [super awakeFromNib];
    [[JSObjection defaultInjector] injectDependencies:self];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = JMCustomLocalizedString(@"detail.report.options.title", nil);
    self.titleLabel.text = JMCustomLocalizedString(@"detail.report.options.titlelabel.title", nil);
    self.titleLabel.textColor = kJMDetailViewLightTextColor;
    self.tableView.layer.cornerRadius = 4;
    
    self.view.backgroundColor = kJMDetailViewLightBackgroundColor;
    self.tableView.layer.cornerRadius = 4;
    
    // Remove extra separators
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"apply_item"] style:UIBarButtonItemStyleBordered target:self action:@selector(runReport)];
}

- (void)runReport
{
    BOOL allDataIsValid = YES;
    for (int i = 0; i < [self.inputControls count]; i++) {
        JSInputControlDescriptor *descriptor = [self.inputControls objectAtIndex:i];
        if (descriptor.validationRules.mandatoryValidationRule && descriptor.state.value == nil) {
            JMInputControlCell *cell = (JMInputControlCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            [cell updateDisplayingOfErrorMessage: descriptor.validationRules.mandatoryValidationRule.errorMessage];
            allDataIsValid = NO;
        }
    }
    
    if (allDataIsValid) {
        if (!self.delegate) {
            [self performSegueWithIdentifier:kJMShowReportViewerSegue sender:self.inputControls];
        } else {
            [self.delegate performSelector:@selector(setInputControls:) withObject:self.inputControls];
            [self.delegate refresh];
        }
    } else {
        [self.tableView reloadData];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id destinationViewController = segue.destinationViewController;
    
    if ([self isResourceSegue:segue]) {
        [destinationViewController setResourceLookup:self.resourceLookup];
        [destinationViewController setInputControls:sender];
        self.delegate = destinationViewController;
    } else {
        [destinationViewController setCell:sender];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.inputControls.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JSInputControlDescriptor *inputControlDescriptor = [self.inputControls objectAtIndex:indexPath.row];
    NSString *cellIdentifier = [[self inputControlDescriptorTypes] objectForKey:inputControlDescriptor.type];
    JMInputControlCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [cell setBottomSeparatorWithHeight:1 color:tableView.separatorColor tableViewStyle:tableView.style];
    [cell setInputControlDescriptor:inputControlDescriptor];
    cell.delegate = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - JMInputControlsHolder
- (void)updatedInputControlsValuesWithDescriptor:(JSInputControlDescriptor *)descriptor
{
    if (!descriptor.slaveDependencies.count) {
        return;
    }

    NSMutableArray *selectedValues = [NSMutableArray array];
    NSMutableArray *allInputControls = [NSMutableArray array];
    
    // Get values from Input Controls
    for (JSInputControlDescriptor *descriptor in self.inputControls) {
        [selectedValues addObject:[[JSReportParameter alloc] initWithName:descriptor.uuid
                                                                    value:descriptor.selectedValues]];
        [allInputControls addObject:descriptor.uuid];
    }

    [JMCancelRequestPopup presentInViewController:self message:@"status.loading" restClient:self.reportClient cancelBlock:@weakself(^(void)) {
        [self.navigationController popViewControllerAnimated:YES];
    } @weakselfend];
    JMRequestDelegate *delegate = [JMRequestDelegate requestDelegateForFinishBlock:@weakself(^(JSOperationResult *result)) {
        for (JSInputControlState *state in result.objects) {
            for (JSInputControlDescriptor *inputControl in self.inputControls) {
                if ([state.uuid isEqualToString:inputControl.uuid]) {
                    inputControl.state = state;
                    break;
                }
            }
        }
        [self.tableView reloadData];
    } @weakselfend viewControllerToDismiss:self];
    
    [self.reportClient updatedInputControlsValues:self.resourceLookup.uri
                                              ids:allInputControls
                                   selectedValues:selectedValues
                                         delegate:delegate];
}

#pragma mark - Private
// Returns input control types
- (NSDictionary *)inputControlDescriptorTypes
{
    return @{
             self.constants.ICD_TYPE_BOOL :                   @"BooleanCell",
             self.constants.ICD_TYPE_SINGLE_VALUE_TEXT :      @"TextEditCell",
             self.constants.ICD_TYPE_SINGLE_VALUE_NUMBER :    @"NumberCell",
             self.constants.ICD_TYPE_SINGLE_VALUE_DATE :      @"DateCell",
             self.constants.ICD_TYPE_SINGLE_VALUE_TIME :      @"TimeCell",
             self.constants.ICD_TYPE_SINGLE_VALUE_DATETIME :  @"DateTimeCell",
             self.constants.ICD_TYPE_SINGLE_SELECT :          @"SingleSelectCell",
             self.constants.ICD_TYPE_SINGLE_SELECT_RADIO :    @"SingleSelectCell",
             self.constants.ICD_TYPE_MULTI_SELECT :           @"MultiSelectCell",
             self.constants.ICD_TYPE_MULTI_SELECT_CHECKBOX :  @"MultiSelectCell",
             };
}

@end
