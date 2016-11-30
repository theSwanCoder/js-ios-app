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

NSInteger const kJMReportOptionsTableViewCellHeight = 44.f;
#define kJMReportOptionsTableViewCellHorizontalOffset ([JMUtils isIphone] ? 10.f : 15.f)
#define kJMReportOptionsTableViewCellVerticalOffset ([JMUtils isIphone] ? 7.f : 7.f)

@interface JMReportOptionsViewController () <UITableViewDelegate, UITableViewDataSource, JMInputControlCellDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *runReportButton;
@property (nonatomic, strong, readwrite) NSArray *inputControls;

@end

@implementation JMReportOptionsViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = JMCustomLocalizedString(@"report_viewer_options_title", nil);
    self.view.backgroundColor = kJMDetailViewLightBackgroundColor;
    
    // Remove extra separators
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // setup "Run Report" button
    self.runReportButton.backgroundColor = kJMResourcePreviewBackgroundColor;
    [self.runReportButton setTitle:JMCustomLocalizedString(@"dialog_button_run_report", nil)
                          forState:UIControlStateNormal];
}

#pragma mark - Actions
- (IBAction)runReportAction:(id)sender
{
    [self runReport];
}

- (void)backButtonTapped:(id)sender
{
    // TODO: Need to refactor here after adding "Always Prompt" flag support
    if (self.report.isReportAlreadyLoaded) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        NSMutableArray *viewControllers = [self.navigationController.viewControllers mutableCopy];
        while (![[viewControllers lastObject] isKindOfClass:NSClassFromString(@"JMBaseCollectionViewController")]) {
            [viewControllers removeLastObject];
        }
        [self.navigationController popToViewController:[viewControllers lastObject] animated:YES];
    }
}

#pragma mark - Private API
- (void)runReport
{
    [self.view endEditing:YES];

    BOOL isReportParametersChanged = [self isReportParametersChanged];

    if (!self.report.isReportAlreadyLoaded || (self.report.isReportAlreadyLoaded && isReportParametersChanged)) {
        if ([self validateInputControls]) { // Local validation
            [self updatedInputControlsValuesWithCompletion:@weakself(^(BOOL dataIsValid)) { // Server validation
                    if (dataIsValid) {
                        if (self.completionBlock) {
                            self.completionBlock();
                        }
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                } @weakselfend];
        } else {
            [self.tableView reloadData];
        }
    } else {
        [self backButtonTapped:nil];
    }
}

- (BOOL)isReportParametersChanged
{
    for (JSInputControlDescriptor *inputControl in self.report.inputControls) {
        for (JSInputControlDescriptor *internalInputControl in self.inputControls) {
            if ([inputControl.uuid isEqualToString:internalInputControl.uuid]) {
                NSSet *inputControlSelectedValues = [NSSet setWithArray:[inputControl selectedValues]];
                NSSet *internalInputControlSelectedValues = [NSSet setWithArray:[internalInputControl selectedValues]];
                if (![inputControlSelectedValues isEqualToSet:internalInputControlSelectedValues]) {
                    return YES;
                }
                break;
            }
        }
    }

    return NO;
}

- (BOOL) validateInputControls
{
    for (JSInputControlDescriptor *descriptor in self.inputControls) {
        if ([[descriptor errorString] length]) {
            return NO;
        }
    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id destinationViewController = segue.destinationViewController;
    if ([destinationViewController respondsToSelector:@selector(setCell:)]) {
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
        CGFloat maxWidth = tableView.frame.size.width - 2 * kJMReportOptionsTableViewCellHorizontalOffset;
        if ([self isSelectableCellAtIndexPath:indexPath]) {
            maxWidth -= 25;
        }
        CGSize maximumLabelSize = CGSizeMake(maxWidth, CGFLOAT_MAX);
        CGRect textRect = [[inputControlDescriptor errorString] boundingRectWithSize:maximumLabelSize
                                                                             options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                                          attributes:@{NSFontAttributeName:[JMFont tableViewCellDetailErrorFont]}
                                                                             context:nil];
        return kJMReportOptionsTableViewCellHeight + kJMReportOptionsTableViewCellVerticalOffset + ceil(textRect.size.height);
    }
    return kJMReportOptionsTableViewCellHeight;
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
        [JMCancelRequestPopup presentWithMessage:@"status_loading"
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

- (BOOL)isSelectableCellAtIndexPath:(NSIndexPath *)indexPath
{
    JSInputControlDescriptor *descriptor = [self.inputControls objectAtIndex:indexPath.row];
    return ([descriptor.type isEqualToString:[JSConstants sharedInstance].ICD_TYPE_SINGLE_SELECT] ||
            [descriptor.type isEqualToString:[JSConstants sharedInstance].ICD_TYPE_SINGLE_SELECT_RADIO] ||
            [descriptor.type isEqualToString:[JSConstants sharedInstance].ICD_TYPE_MULTI_SELECT] ||
            [descriptor.type isEqualToString:[JSConstants sharedInstance].ICD_TYPE_MULTI_SELECT_CHECKBOX]);
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
    
    [JMCancelRequestPopup presentWithMessage:@"status_loading"
                                 cancelBlock:@weakself(^(void)) {
                                     [self.restClient cancelAllRequests];
                                     [self.navigationController popViewControllerAnimated:YES];
                                 } @weakselfend];

    [self.restClient updatedInputControlsValues:self.report.reportURI
                                            ids:allInputControls
                                 selectedValues:selectedValues
                                completionBlock:@weakself(^(JSOperationResult *result)) {
                                    [JMCancelRequestPopup dismiss];

                                    if (result.error) {
                                        if (result.error.code == JSSessionExpiredErrorCode) {
                                            if (self.restClient.keepSession) {
                                                [self.restClient verifySessionWithCompletion:@weakself(^(BOOL isSessionAuthorized)) {
                                                    if (isSessionAuthorized) {
                                                        [self updatedInputControlsValuesWithCompletion:completion];
                                                    } else {
                                                        [JMUtils showLoginViewAnimated:YES completion:nil];
                                                    }
                                                }@weakselfend];
                                            } else {
                                                [JMUtils showLoginViewAnimated:YES completion:nil];
                                            }
                                        } else {
                                            [JMUtils showAlertViewWithError:result.error];
                                        }
                                    } else {
                                        for (JSInputControlState *state in result.objects) {
                                            for (JSInputControlDescriptor *inputControl in self.inputControls) {
                                                if ([state.uuid isEqualToString:inputControl.uuid]) {
                                                    inputControl.state = state;
                                                    break;
                                                }
                                            }
                                        }
                                        [self.tableView reloadData];
                                        if (completion) {
                                            completion([self validateInputControls]);
                                        }
                                    }
                                } @weakselfend];
}

- (NSArray *)inputControls
{
    if (!_inputControls) {
        _inputControls = [[NSArray alloc] initWithArray:self.report.inputControls copyItems:YES];
    }
    return _inputControls;
}

@end
