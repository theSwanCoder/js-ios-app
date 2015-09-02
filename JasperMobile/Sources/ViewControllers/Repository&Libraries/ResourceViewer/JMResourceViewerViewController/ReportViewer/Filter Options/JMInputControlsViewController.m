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


#import "JMInputControlsViewController.h"
#import "JMSingleSelectTableViewController.h"
#import "UITableViewCell+Additions.h"

#import "JMCancelRequestPopup.h"
#import "JMReportOptionsCell.h"
#import "JMInputControlCell.h"
#import "JMReportOptionsViewController.h"
#import "JMReportManager.h"
#import "JMExtendedReportOption.h"

@interface JMInputControlsViewController () <UITableViewDelegate, UITableViewDataSource, JMInputControlCellDelegate, JMReportOptionsViewControllerDelegate, UITextFieldDelegate, UIAlertViewDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *runReportButton;

@property (nonatomic, strong) JMExtendedReportOption *currentReportOption;
@property (nonatomic, strong) NSArray *currentInputControls;

@property (nonatomic, assign) BOOL isReportOptionsEditingAvailable;

@end

@implementation JMInputControlsViewController

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
    
    [self setupReportOptions];

    self.tableView.estimatedRowHeight = UITableViewAutomaticDimension;
}

#pragma mark - Actions
- (IBAction)runReportAction:(id)sender
{
    [self runReport];
}

- (void)backButtonTapped:(id)sender
{
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
                            self.completionBlock(self.currentReportOption);
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
    return (self.report.activeReportOption != self.currentReportOption);
    
//    for (JSInputControlDescriptor *inputControl in self.report.activeReportOption.inputControls) {
//        for (JSInputControlDescriptor *internalInputControl in self.currentInputControls) {
//            if ([inputControl.uuid isEqualToString:internalInputControl.uuid]) {
//                NSSet *inputControlSelectedValues = [NSSet setWithArray:[inputControl selectedValues]];
//                NSSet *internalInputControlSelectedValues = [NSSet setWithArray:[internalInputControl selectedValues]];
//                if (![inputControlSelectedValues isEqualToSet:internalInputControlSelectedValues]) {
//                    return YES;
//                }
//                break;
//            }
//        }
//    }
//    return NO;
}

- (BOOL) validateInputControls
{
    for (JSInputControlDescriptor *descriptor in self.currentInputControls) {
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

    if ([destinationViewController isKindOfClass:[JMReportOptionsViewController class]]) {
        JMReportOptionsViewController *reportOptionsVC = (JMReportOptionsViewController *)destinationViewController;
        reportOptionsVC.listOfValues = self.report.reportOptions;
        reportOptionsVC.delegate = self;
        reportOptionsVC.selectedReportOption = self.currentReportOption;
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger numberOfSections = 0;
    if ([self isMultyReportOptions]) {
        numberOfSections ++;
    }
    if ([self.currentInputControls count]) {
        numberOfSections ++;
    }
    return numberOfSections;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([self isMultyReportOptions] && section == 0) {
        return JMCustomLocalizedString(@"report.viewer.options.title", nil);
    } else {
        return JMCustomLocalizedString(@"report.viewer.report.options.title", nil);
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self isMultyReportOptions] && section == 0) {
        return 1;
    }
    return self.currentInputControls.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [self cellIdentifierForIndexPath:indexPath];
 
    // This solution was taken form http://stackoverflow.com/a/18746930/2523825
    
    // Use the dictionary of offscreen cells to get a cell for the reuse identifier, creating a cell and storing
    // it in the dictionary if one hasn't already been added for the reuse identifier.
    // WARNING: Don't call the table view's dequeueReusableCellWithIdentifier: method here because this will result
    // in a memory leak as the cell is created but never returned from the tableView:cellForRowAtIndexPath: method!
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    // Configure the cell for this indexPath
    if ([self isMultyReportOptions] && indexPath.section == 0) {
        JMReportOptionsCell *roCell = (JMReportOptionsCell *)cell;
        roCell.titleLabel.text = self.currentReportOption.reportOption.label;
    } else {
        JSInputControlDescriptor *inputControlDescriptor = [self.currentInputControls objectAtIndex:indexPath.row];
        JMInputControlCell *icCell = (JMInputControlCell *)cell;
        [icCell setInputControlDescriptor:inputControlDescriptor];
    }
    
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
    
    return (height > 44) ? height : 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [self cellIdentifierForIndexPath:indexPath];
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    // Configure the cell for this indexPath
    if ([self isMultyReportOptions] && indexPath.section == 0) {
        JMReportOptionsCell *roCell = (JMReportOptionsCell *)cell;
        roCell.titleLabel.text = self.currentReportOption.reportOption.label;
    } else {
        JSInputControlDescriptor *inputControlDescriptor = [self.currentInputControls objectAtIndex:indexPath.row];
        JMInputControlCell *icCell = (JMInputControlCell *)cell;
        [icCell setInputControlDescriptor:inputControlDescriptor];
        icCell.delegate = self;
    }
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

- (void)inputControlCellDidChangedValue:(JMInputControlCell *)cell
{
    if ([self isMultyReportOptions]) {
        if ([self.report.reportOptions indexOfObject:self.currentReportOption] != NSNotFound) {
            JMExtendedReportOption *newCurrentOption = [JMExtendedReportOption defaultReportOption];
            newCurrentOption.inputControls = self.currentInputControls;
            self.currentReportOption = newCurrentOption;
        }
    }
}

#pragma mark - JMReportOptionsViewControllerDelegate
- (void)reportOptionsViewController:(JMReportOptionsViewController *)controller didSelectOption:(JMExtendedReportOption *)option
{
    if (self.currentReportOption != option) {
        JMExtendedReportOption *oldActiveReportOption = self.currentReportOption;
        self.currentReportOption = option;

        if (![self.currentInputControls count]) {
            [JMCancelRequestPopup presentWithMessage:@"status.loading" cancelBlock:nil];
            [JMReportManager fetchInputControlsWithReportURI:self.currentReportOption.reportOption.uri completion:@weakself(^(NSArray *inputControls, NSError *error)) {
                [JMCancelRequestPopup dismiss];
                if (error) {
                    if (error.code == JSSessionExpiredErrorCode) {
                        [JMUtils showLoginViewAnimated:YES completion:nil];
                    } else {
                        [JMUtils showAlertViewWithError:error completion:@weakself(^(UIAlertView *alertView, NSInteger buttonIndex)) {
                            self.currentReportOption = oldActiveReportOption;
                        }@weakselfend];
                    }
                } else {
                    self.currentReportOption.inputControls = inputControls;
                    self.currentInputControls = [[NSArray alloc] initWithArray:inputControls copyItems:YES];
                    [self.tableView reloadData];
                }
            }@weakselfend];
        }
    }
}

#pragma mark - Private

- (NSString *)cellIdentifierForIndexPath:(NSIndexPath *)indexPath
{
    if ([self isMultyReportOptions] && indexPath.section == 0) {
        return @"ReportOptionsCell";
    }
    JSInputControlDescriptor *inputControlDescriptor = [self.currentInputControls objectAtIndex:indexPath.row];
    NSDictionary *inputControlDescriptorTypes = @{
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

    return [inputControlDescriptorTypes objectForKey:inputControlDescriptor.type];
}

- (BOOL)isMultyReportOptions
{
    return [self.report.reportOptions count] > 1;
}

- (void)setupReportOptions
{
    self.currentReportOption = self.report.activeReportOption;
    if (![self isMultyReportOptions]) {
        [JMCancelRequestPopup presentWithMessage:@"status.loading" cancelBlock:nil];
        
        [JMReportManager fetchReportOptionsWithReportURI:self.report.reportURI completion:@weakself(^(NSArray *reportOptions, NSError *error)) {
            [JMCancelRequestPopup dismiss];
            if (error) {
                if (error.code == JSSessionExpiredErrorCode) {
                    [JMUtils showLoginViewAnimated:YES completion:nil];
                }
            } else {
                [self.report addReportOptions:reportOptions];
                [self.tableView reloadData];
            }
        }@weakselfend];
    }
}

- (void)setCurrentReportOption:(JMExtendedReportOption *)currentReportOption
{
    if (_currentReportOption != currentReportOption) {
        _currentReportOption = currentReportOption;
        _currentInputControls = [[NSArray alloc] initWithArray:currentReportOption.inputControls copyItems:YES];
        [self updateRightBurButtonItem];
        [self.tableView reloadData];
    }
}

- (void)updatedInputControlsValuesWithCompletion:(void(^)(BOOL dataIsValid))completion
{
    NSMutableArray *selectedValues = [NSMutableArray array];
    NSMutableArray *allInputControls = [NSMutableArray array];
    // Get values from Input Controls
    for (JSInputControlDescriptor *descriptor in self.currentInputControls) {
        [selectedValues addObject:[[JSReportParameter alloc] initWithName:descriptor.uuid
                                                                    value:descriptor.selectedValues]];
        [allInputControls addObject:descriptor.uuid];
    }
    
    [JMCancelRequestPopup presentWithMessage:@"status.loading"
                                 cancelBlock:@weakself(^(void)) {
                                     [self.restClient cancelAllRequests];
                                     [self backButtonTapped:nil];
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
                                            for (JSInputControlDescriptor *inputControl in self.currentInputControls) {
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

- (void)updateRightBurButtonItem
{
#warning NEED ADD PERMISSION CHECKING
    NSInteger indexOfCurrentOption = [self.report.reportOptions indexOfObject:self.currentReportOption];
    if (indexOfCurrentOption != NSNotFound && indexOfCurrentOption != 0) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"delete_item"] style:UIBarButtonItemStyleDone target:self action:@selector(deleteReportOptionTapped:)];
    } else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"save_item"] style:UIBarButtonItemStyleDone target:self action:@selector(createReportOptionTapped:)];
    }
}

- (void)createReportOptionTapped:(id)sender
{
    if ([self validateInputControls]) { // Local validation
        [self updatedInputControlsValuesWithCompletion:@weakself(^(BOOL dataIsValid)) { // Server validation
            if (dataIsValid) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:JMCustomLocalizedString(@"report.viewer.report.options.new.option.title", nil)
                                                                    message:nil
                                                                   delegate:self
                                                          cancelButtonTitle:JMCustomLocalizedString(@"dialog.button.cancel", nil)
                                                          otherButtonTitles:JMCustomLocalizedString(@"dialog.button.ok", nil), nil];
                alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
                UITextField *textField = [alertView textFieldAtIndex:0];
                textField.delegate = self;
                [alertView show];
            }
        } @weakselfend];
    } else {
        [self.tableView reloadData];
    }
}

- (void)deleteReportOptionTapped:(id)sender
{
    [JMCancelRequestPopup presentWithMessage:@"status.loading" cancelBlock:nil];
    [JMReportManager deleteReportOption:self.currentReportOption.reportOption withReportURI:self.report.reportURI completion:@weakself(^(NSError *error)) {
        [JMCancelRequestPopup dismiss];
        if (error) {
            if (error.code == JSSessionExpiredErrorCode) {
                [JMUtils showLoginViewAnimated:YES completion:nil];
            } else {
                [JMUtils showAlertViewWithError:error];
            }
        } else {
            [self.report removeReportOption:self.currentReportOption];
            self.currentReportOption = [self.report.reportOptions firstObject];
        }
    }@weakselfend];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    UITextField *textField = [alertView textFieldAtIndex:0];
    alertView.message = ([self isUniqueNewReportOptionName:textField.text]) ? @"" : JMCustomLocalizedString(@"report.viewer.report.options.new.option.title.alreadyexist", nil);
    return textField.text.length > 0;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.cancelButtonIndex != buttonIndex) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        [textField resignFirstResponder];
        
        NSArray *reportParameters = [JMReportManager reportParametersFromInputControls:self.currentInputControls];
        
        [JMCancelRequestPopup presentWithMessage:@"status.loading" cancelBlock:nil];
        [JMReportManager createReportOptionWithReportURI:self.report.reportURI optionLabel:textField.text reportParameters:reportParameters completion:@weakself(^(JSReportOption *reportOption, NSError *error)) {
            [JMCancelRequestPopup dismiss];
            if (error) {
                if (error.code == JSSessionExpiredErrorCode) {
                    [JMUtils showLoginViewAnimated:YES completion:nil];
                } else {
                    [JMUtils showAlertViewWithError:error];
                }
            } else {
                if (reportOption) {
                    JMExtendedReportOption *extendedReportOption = [JMExtendedReportOption new];
                    extendedReportOption.reportOption = reportOption;
                    extendedReportOption.inputControls = self.currentInputControls;
                    if (![self isUniqueNewReportOptionName:reportOption.label]) {
                        for (JMExtendedReportOption *existedReportOption in self.report.reportOptions) {
                            if ([reportOption.label isEqualToString:existedReportOption.reportOption.label]) {
                                [self.report removeReportOption:existedReportOption];
                                break;
                            }
                        }
                    }
                    [self.report addReportOptions:@[extendedReportOption]];
                    self.currentReportOption= extendedReportOption;
                }
            }
        }@weakselfend];
    }
}

- (BOOL)isUniqueNewReportOptionName:(NSString *)name
{
    for (JMExtendedReportOption *reportOption in self.report.reportOptions) {
        if ([name isEqualToString:reportOption.reportOption.label]) {
            return NO;
        }
    }
    return YES;
}
@end
