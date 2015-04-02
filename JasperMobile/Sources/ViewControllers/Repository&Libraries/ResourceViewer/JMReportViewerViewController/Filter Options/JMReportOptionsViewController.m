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
#import "JMSingleSelectTableViewController.h"
#import "UITableViewCell+Additions.h"

#import "JMResourceClientHolder.h"
#import "JMCancelRequestPopup.h"
#import "JMInputControlCell.h"
#import "JMReportViewerViewController.h"

@interface JMReportOptionsViewController () <UITableViewDelegate, UITableViewDataSource, JMInputControlCellDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel    *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *runReportButton;
@end

@implementation JMReportOptionsViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = JMCustomLocalizedString(@"report.viewer.options.title", nil);
    self.titleLabel.text = JMCustomLocalizedString(@"report.viewer.options.titlelabel.title", nil);
    self.titleLabel.textColor = kJMDetailViewLightTextColor;
    
    self.view.backgroundColor = kJMDetailViewLightBackgroundColor;
    
    // Remove extra separators
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.tableView setRowHeight:44.f];

    
    // setup "Run Report" button
    self.runReportButton.backgroundColor = kJMResourcePreviewBackgroundColor;
    [self.runReportButton setTitle:JMCustomLocalizedString(@"dialog.button.run.report", nil)
                          forState:UIControlStateNormal];
}

#pragma mark - Actions
- (IBAction)runReportAction:(id)sender
{
    [self runReport];
}

- (void)backToLibrary
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Private API
- (void)runReport
{
    [self.view endEditing:YES];
    if ([self validateInputControls]) { // Local validation
        
        [JMCancelRequestPopup presentWithMessage:@"status.loading"
                                     cancelBlock:@weakself(^(void)) {
                                         [self.restClient cancelAllRequests];
                                         [self.navigationController popViewControllerAnimated:YES];
                                     } @weakselfend];
        
        [self updatedInputControlsValuesWithCompletion:@weakself(^(BOOL dataIsValid)) { // Server validation
            
            [JMCancelRequestPopup dismiss];
            
            if (dataIsValid) {
                if (self.completionBlock) {
                    self.completionBlock();
                }
                [self.navigationController popViewControllerAnimated:YES];
            }
        } @weakselfend];
    }
}

- (BOOL) validateInputControls
{
    // TODO: change this COMPLETLY!
    for (int i = 0; i < [self.tableView numberOfRowsInSection:0]; i++) {
        JMInputControlCell *cell = (JMInputControlCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        if (cell && ![cell isValidData]) {
            return NO;
        }
    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id destinationViewController = segue.destinationViewController;
    if ([self isResourceSegue:segue]) {
        // TODO: where we use it ???
        //[destinationViewController setResourceLookup:self.resourceLookup];
        //[destinationViewController setInputControls:sender];
        //self.delegate = destinationViewController;
    } else {
        [destinationViewController setCell:sender];
    }
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.inputControls.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JSInputControlDescriptor *inputControlDescriptor = [self.inputControls objectAtIndex:indexPath.row];
    if ([inputControlDescriptor errorString]) {
        CGFloat maxWidth = tableView.frame.size.width - 30;
        CGSize maximumLabelSize = CGSizeMake(maxWidth, CGFLOAT_MAX);
        CGRect textRect = [[inputControlDescriptor errorString] boundingRectWithSize:maximumLabelSize
                                                                             options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                                          attributes:@{NSFontAttributeName:[JMFont tableViewCellDetailErrorFont]}
                                                                             context:nil];
        return tableView.rowHeight + ceil(textRect.size.height);
    }
    return tableView.rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JSInputControlDescriptor *inputControlDescriptor = [self.inputControls objectAtIndex:indexPath.row];
    NSString *cellIdentifier = [[self inputControlDescriptorTypes] objectForKey:inputControlDescriptor.type];
    JMInputControlCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [cell setBottomSeparatorWithHeight:1
                                 color:tableView.separatorColor
                        tableViewStyle:tableView.style];
    [cell setInputControlDescriptor:inputControlDescriptor];
    cell.delegate = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - JMInputControlCellDelegate
- (void)reloadTableViewCell:(JMInputControlCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath) {
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)updatedInputControlsValuesWithDescriptor:(JSInputControlDescriptor *)descriptor
{
    if (descriptor.slaveDependencies.count) {
        [JMCancelRequestPopup presentWithMessage:@"status.loading"
                                     cancelBlock:@weakself(^(void)) {
                                         [self.restClient cancelAllRequests];
                                         [self.navigationController popViewControllerAnimated:YES];
                                     } @weakselfend];
        
        [self updatedInputControlsValuesWithCompletion:^(BOOL dataIsValid) {
            [JMCancelRequestPopup dismiss];
        }];
    }
}

#pragma mark - Private

- (BOOL)isResourceSegue:(UIStoryboardSegue *)segue;
{
    NSString *identifier = segue.identifier;
    return ([identifier isEqualToString:kJMShowMultiPageReportSegue] ||
            [identifier isEqualToString:kJMShowReportOptionsSegue] ||
            [identifier isEqualToString:kJMShowDashboardViewerSegue] ||
            [identifier isEqualToString:kJMShowSavedRecourcesViewerSegue]);
}

// Returns input control types
- (NSDictionary *)inputControlDescriptorTypes
{
    return @{
             [JSConstants sharedInstance].ICD_TYPE_BOOL                     : @"BooleanCell",
             [JSConstants sharedInstance].ICD_TYPE_SINGLE_VALUE_TEXT        : @"TextEditCell",
             [JSConstants sharedInstance].ICD_TYPE_SINGLE_VALUE_NUMBER      : @"NumberCell",
             [JSConstants sharedInstance].ICD_TYPE_SINGLE_VALUE_DATE        : @"DateCell",
             [JSConstants sharedInstance].ICD_TYPE_SINGLE_VALUE_TIME        : @"TimeCell",
             [JSConstants sharedInstance].ICD_TYPE_SINGLE_VALUE_DATETIME    : @"DateTimeCell",
             [JSConstants sharedInstance].ICD_TYPE_SINGLE_SELECT            : @"SingleSelectCell",
             [JSConstants sharedInstance].ICD_TYPE_SINGLE_SELECT_RADIO      : @"SingleSelectCell",
             [JSConstants sharedInstance].ICD_TYPE_MULTI_SELECT             : @"MultiSelectCell",
             [JSConstants sharedInstance].ICD_TYPE_MULTI_SELECT_CHECKBOX    : @"MultiSelectCell",
             };
}

- (void)updatedInputControlsValuesWithCompletion:(void(^)(BOOL dataIsValid))completion
{
    NSMutableArray *selectedValues = [NSMutableArray array];
    NSMutableArray *allInputControls = [NSMutableArray array];
    // Get values from Input Controls
    for (JSInputControlDescriptor *descriptor in self.inputControls) {
        [selectedValues addObject:[[JSReportParameter alloc] initWithName:descriptor.uuid
                                                                    value:descriptor.selectedValues]];
        [allInputControls addObject:descriptor.uuid];
    }
    
//    [JMCancelRequestPopup presentWithMessage:@"status.loading"
//                                 cancelBlock:@weakself(^(void)) {
//                                     [self.restClient cancelAllRequests];
//                                     [self.navigationController popViewControllerAnimated:YES];
//                                 } @weakselfend];
    
    [self.restClient updatedInputControlsValues:self.resourceLookup.uri
                                            ids:allInputControls
                                 selectedValues:selectedValues
                                completionBlock:@weakself(^(JSOperationResult *result)) {
//                                    [JMCancelRequestPopup dismiss];

                                    if (result.error) {
                                        if (result.error.code == JSSessionExpiredErrorCode) {
                                            if (self.restClient.keepSession && [self.restClient isSessionAuthorized]) {
                                                [self updatedInputControlsValuesWithCompletion:completion];
                                            } else {
                                                [JMUtils showLoginViewAnimated:YES completion:nil];
                                            }
                                        } else {
                                            [JMUtils showAlertViewWithError:result.error];
                                        }
                                    } else {
                                        for (JSInputControlState *state in result.objects) {
                                            for (JSInputControlDescriptor *inputControl in self.inputControls) {
                                                NSString *uuid = state.uuid;
                                                if ([uuid isEqualToString:inputControl.uuid]) {
                                                    inputControl.state = state;
                                                    break;
                                                }
                                            }
                                        }
                                        [self.tableView reloadData];
                                        if ([self validateInputControls]) {
                                            if (completion) {
                                                completion(YES);
                                            }
                                        } else {
                                            [self.tableView reloadData];
                                            if (completion) {
                                                completion(NO);
                                            }
                                        }
                                    }
                                } @weakselfend];
}

@end
