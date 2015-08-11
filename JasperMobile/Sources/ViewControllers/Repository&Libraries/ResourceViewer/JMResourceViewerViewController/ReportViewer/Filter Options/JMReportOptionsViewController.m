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
    self.title = JMCustomLocalizedString(@"report.viewer.options.title", nil);    
    self.view.backgroundColor = [[JMThemesManager sharedManager] viewBackgroundColor];
    
    // Remove extra separators
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // setup "Run Report" button
    self.runReportButton.backgroundColor = [[JMThemesManager sharedManager] reportOptionsRunReportButtonBackgroundColor];
    [self.runReportButton setTitleColor:[[JMThemesManager sharedManager] reportOptionsRunReportButtonTextColor]
                               forState:UIControlStateNormal];
    [self.runReportButton setTitle:JMCustomLocalizedString(@"dialog.button.run.report", nil)
                          forState:UIControlStateNormal];
    
    self.tableView.estimatedRowHeight = UITableViewAutomaticDimension;
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
    NSString *cellIdentifier = [[self inputControlDescriptorTypes] objectForKey:inputControlDescriptor.type];
 
    // This solution was taken form http://stackoverflow.com/a/18746930/2523825
    
    // Use the dictionary of offscreen cells to get a cell for the reuse identifier, creating a cell and storing
    // it in the dictionary if one hasn't already been added for the reuse identifier.
    // WARNING: Don't call the table view's dequeueReusableCellWithIdentifier: method here because this will result
    // in a memory leak as the cell is created but never returned from the tableView:cellForRowAtIndexPath: method!
    JMInputControlCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    // Configure the cell for this indexPath
    [cell setInputControlDescriptor:inputControlDescriptor];
    
    // The cell's width must be set to the same size it will end up at once it is in the table view.
    // This is important so that we'll get the correct height for different table view widths, since our cell's
    // height depends on its width due to the multi-line UILabel word wrapping. Don't need to do this above in
    // -[tableView:cellForRowAtIndexPath:] because it happens automatically when the cell is used in the table view.
    cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), CGRectGetHeight(cell.bounds));
    // NOTE: if you are displaying a section index (e.g. alphabet along the right side of the table view), or
    // if you are using a grouped table view style where cells have insets to the edges of the table view,
    // you'll need to adjust the cell.bounds.size.width to be smaller than the full width of the table view we just
    // set it to above. See http://stackoverflow.com/questions/3647242 for discussion on the section index width.
    
    // Do the layout pass on the cell, which will calculate the frames for all the views based on the constraints
    // (Note that the preferredMaxLayoutWidth is set on multi-line UILabels inside the -[layoutSubviews] method
    // in the UITableViewCell subclass
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    // Get the actual height required for the cell
    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
    // Add an extra point to the height to account for the cell separator, which is added between the bottom
    // of the cell's contentView and the bottom of the table view cell.
    height += 1;
    
    return height;
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
    
    [JMCancelRequestPopup presentWithMessage:@"status.loading"
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
