/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2015 TIBCO Software, Inc. All rights reserved.
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

#import "JMCancelRequestPopup.h"
#import "JMReportOptionsCell.h"
#import "JMInputControlCell.h"
#import "JMReportOptionsViewController.h"
#import "JSReportOption.h"
#import "JMFiltersVCResult.h"
#import "JMFiltersNetworkManager.h"
#import "JMLocalization.h"
#import "JMThemesManager.h"
#import "JMUtils.h"
#import "NSObject+Additions.h"
#import "UIAlertController+Additions.h"

@interface JMInputControlsViewController () <UITableViewDelegate, UITableViewDataSource, JMInputControlCellDelegate, JMReportOptionsViewControllerDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *runReportButton;
@property (nonatomic, weak) JSReportOption *noneReportOption;
@property (nonatomic, strong) JSReportOption *activeReportOption;
@property (nonatomic, strong) NSMutableArray <JSReportOption *> *reportOptions;
@property (nonatomic, strong) NSArray <JSInputControlDescriptor *> *inputControls;
@property (nonatomic, strong) JSResourceLookup *parentFolderLookup;
@property (nonatomic, strong) JMFiltersNetworkManager *networkManager;
@property (nonatomic, assign, getter=isCookiesDidUpdate) BOOL cookiesDidUpdate;
@end

@implementation JMInputControlsViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = JMLocalizedString(@"report_viewer_options_title");
    self.view.backgroundColor = [[JMThemesManager sharedManager] viewBackgroundColor];
    
    // Remove extra separators
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // setup "Run Report" button
    self.runReportButton.backgroundColor = [[JMThemesManager sharedManager] reportOptionsRunReportButtonBackgroundColor];
    [self.runReportButton setTitleColor:[[JMThemesManager sharedManager] reportOptionsRunReportButtonTextColor]
                               forState:UIControlStateNormal];
    [self.runReportButton setTitle:JMLocalizedString(@"dialog_button_run_report")
                          forState:UIControlStateNormal];

    [self setupNavigationItems];

    self.tableView.estimatedRowHeight = UITableViewAutomaticDimension;

    [self addObservers];

    self.networkManager = [JMFiltersNetworkManager managerWithRestClient:self.restClient];
    [self startPoint];
}


#pragma mark - Notifications

- (void)addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cookiesDidChange:)
                                                 name:JSRestClientDidChangeCookies
                                               object:nil];
}

- (void)cookiesDidChange:(NSNotification *)notification
{
    self.cookiesDidUpdate = YES;
    [self showSessionExpiredAlert];
}

- (void)showSessionExpiredAlert
{
    __weak typeof(self) weakSelf = self;
    // TODO: add translations
    UIAlertController *alertController = [UIAlertController alertControllerWithLocalizedTitle:@"Session was expired"
                                                                                      message:@"Reload?"
                                                                            cancelButtonTitle:@"dialog_button_cancel"
                                                                      cancelCompletionHandler:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action) {
                                                                          __strong typeof(self) strongSelf = weakSelf;
                                                                          // back to collection view
                                                                          [strongSelf.navigationController popToRootViewControllerAnimated:YES];
                                                                      }];
    [alertController addActionWithLocalizedTitle:@"dialog_button_reload"
                                           style:UIAlertActionStyleDefault
                                         handler:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action) {
                                             __strong typeof(self) strongSelf = weakSelf;
                                             if (strongSelf.completionBlock) {
                                                 JMFiltersVCResult *result = [JMFiltersVCResult new];
                                                 result.type = JMFiltersVCResultTypeSessionExpired;
                                                 strongSelf.completionBlock(result);
                                             } else {
                                                 // TODO: We need completion block anyway
                                             }
                                         }];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Setup

- (void)setupNavigationItems
{
    if (![JMUtils isServerProEdition]) {
        self.navigationItem.rightBarButtonItem = nil;
    }

    UIBarButtonItem *backButton = [self backButtonWithTitle:nil
                                                     target:self
                                                     action:@selector(backButtonTapped:)];
    self.navigationItem.leftBarButtonItem = backButton;
}

#pragma mark - Actions

- (IBAction)runReportAction:(id)sender
{
    [self runReport];
}

- (void)backButtonTapped:(id)sender
{
    if (self.completionBlock) {
        JMFiltersVCResult *result = [JMFiltersVCResult new];
        result.type = JMFiltersVCResultTypeNotChange;
        self.completionBlock(result);
    }
}

- (void)createReportOptionTapped:(id)sender
{
    if ([self validateInputControls]) { // Local validation
        __weak typeof(self) weakSelf = self;
        [self checkParentFolderPermissionWithCompletion:^(BOOL reportOptionsEditingAvailable) {
            __strong typeof(self) strongSelf = weakSelf;
            if (reportOptionsEditingAvailable) {
                __weak typeof(self) weakSelf = strongSelf;
                [strongSelf updatedInputControlsValuesWithCompletion:^(BOOL dataIsValid) { // Server validation
                    __strong typeof(self) strongSelf = weakSelf;
                    if (dataIsValid) {
                        __weak typeof(self) weakSelf = strongSelf;
                        UIAlertController *alertController = [UIAlertController alertTextDialogueControllerWithLocalizedTitle:@"report_viewer_report_options_new_option_title"
                                                                                                                      message:nil
                                                                                                textFieldConfigurationHandler:nil
                                                                                                        textValidationHandler:^NSString * _Nonnull(NSString * _Nullable text) {
                                                                                                            NSString *errorMessage = nil;
                                                                                                            __strong typeof(self) strongSelf = weakSelf;
                                                                                                            if (strongSelf) {
                                                                                                                [JMUtils validateReportName:text errorMessage:&errorMessage];
                                                                                                                if (!errorMessage && ![strongSelf isUniqueNewReportOptionName:text]) {
                                                                                                                    errorMessage = JMLocalizedString(@"report_viewer_report_options_new_option_title_alreadyexist");
                                                                                                                }
                                                                                                            }
                                                                                                            return errorMessage;
                                                                                                        } textEditCompletionHandler:^(NSString * _Nullable text) {
                                                                                                            __strong typeof(self) strongSelf = weakSelf;
                                                                                                            [strongSelf createNewReportOptionWithName:text];
                                                                                                        }];
                        [strongSelf presentViewController:alertController animated:YES completion:nil];
                    }
                }];
            } else {
                NSString *errorMessage = JMLocalizedString(@"report_viewer_report_options_create_permission_error");
                NSError *error = [NSError errorWithDomain:@"dialod_title_error"
                                                     code:0
                                                 userInfo:@{
                                                         NSLocalizedDescriptionKey : errorMessage
                                                 }];
                [JMUtils presentAlertControllerWithError:error
                                              completion:nil];
            }
        }];
    } else {
        [self.tableView reloadData];
    }
}

- (void)deleteReportOptionTapped:(id)sender
{
    __weak typeof(self) weakSelf = self;
    [self checkParentFolderPermissionWithCompletion:^(BOOL reportOptionsEditingAvailable) {
        __strong typeof(self) strongSelf = weakSelf;
        if (reportOptionsEditingAvailable) {
                NSString *confirmationMessage = [NSString stringWithFormat:JMLocalizedString(@"report_viewer_report_options_remove_confirmation_message"), strongSelf.activeReportOption.label];
                UIAlertController *alertController = [UIAlertController alertControllerWithLocalizedTitle:@"dialod_title_confirmation"
                                                                                                  message:confirmationMessage
                                                                                        cancelButtonTitle:@"dialog_button_cancel"
                                                                                  cancelCompletionHandler:nil];
                __weak typeof(self) weakSelf = strongSelf;
                [alertController addActionWithLocalizedTitle:@"dialog_button_ok"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action) {
                                                         __strong typeof(self) strongSelf = weakSelf;
                                                         if (strongSelf) {
                                                             [strongSelf showLoading];
                                                             __weak typeof(self) weakSelf = strongSelf;
                                                             [self.networkManager deleteReportOption:strongSelf.activeReportOption
                                                                                       withReportURI:strongSelf.reportURI
                                                                                          completion:^(BOOL success, NSError *error) {
                                                                                              typeof(self) strongSelf = weakSelf;
                                                                                              [strongSelf hideLoading];
                                                                                              if (success) {
                                                                                                  [strongSelf.reportOptions removeObject:strongSelf.activeReportOption];
                                                                                                  strongSelf.activeReportOption = strongSelf.noneReportOption;
                                                                                                  [strongSelf.tableView reloadData];
                                                                                              } else {
                                                                                                  [strongSelf handleError:error completion:nil];
                                                                                              }
                                                                                          }];
                                                         }
                                                     }];
            [strongSelf presentViewController:alertController
                                     animated:YES
                                   completion:nil];
            } else {
                NSString *errorMessage = JMLocalizedString(@"report_viewer_report_options_remove_permission_error");
                NSError *error = [NSError errorWithDomain:@"dialod_title_error"
                                                     code:NSNotFound
                                                 userInfo:@{
                                                         NSLocalizedDescriptionKey : errorMessage
                                                 }];
                [JMUtils presentAlertControllerWithError:error
                                              completion:nil];
            }
        }];
}

#pragma mark - Private API

- (void)startPoint
{
    [self showLoading];
    __weak typeof(self) weakSelf = self;
    [self prepareFiltersWithCompletion:^(NSArray<JSInputControlDescriptor *> *inputControls) {
        typeof(self) strongSelf = weakSelf;
        [strongSelf hideLoading];
        strongSelf.inputControls = inputControls;
        if (inputControls.count == 0) {
            // back to report viewer
            if (strongSelf.completionBlock) {
                JMFiltersVCResult *result = [JMFiltersVCResult new];
                result.type = JMFiltersVCResultTypeEmptyFilters;
                strongSelf.completionBlock(result);
            }
        } else {
            JSReportOption *reportOption = [JSReportOption defaultReportOption];
            reportOption.inputControls = [[NSArray alloc] initWithArray:inputControls copyItems:YES];
            strongSelf.noneReportOption = reportOption;
            strongSelf.reportOptions = [@[strongSelf.noneReportOption] mutableCopy];

            [strongSelf showLoading];
            __weak typeof(self) weakSelf = strongSelf;
            [strongSelf prepareReportOptions:^(JSReportOption *activeReportOption) {
                typeof(self) strongSelf = weakSelf;
                [strongSelf hideLoading];
                _activeReportOption = activeReportOption;
                [self updateRightBurButtonItem];
                [strongSelf.tableView reloadData];
            }];
        }
    }];
}

- (void)prepareFiltersWithCompletion:(void(^)(NSArray <JSInputControlDescriptor *>*inputControls))completion
{
    __weak typeof(self) weakSelf = self;
    [self.networkManager loadInputControlsWithResourceURI:self.reportURI
                                        initialParameters:self.initialReportParameters
                                               completion:^(NSArray *inputControls, NSError *error) {
                                                   __strong typeof(self) strongSelf = weakSelf;
                                                       if (error) {
                                                           [strongSelf handleError:error completion:nil];
                                                       } else {
                                                           completion(inputControls);
                                                       }
                                                   }];
}

- (void)prepareReportOptions:(void(^)(JSReportOption *activeReportOption))completion
{
    __weak typeof(self) weakSelf = self;
    [self.networkManager loadReportOptionsWithResourceURI:self.reportURI
                                               completion:^(NSArray *reportOptions, NSError *error) {
                                                   typeof(self) strongSelf = weakSelf;
                                                   if (error) {
                                                       [strongSelf handleError:error completion:nil];
                                                   } else {
                                                       [strongSelf.reportOptions addObjectsFromArray:reportOptions];
                                                       if (strongSelf.initialReportOptionURI) {
                                                           JSReportOption *activeReportOption;
                                                           for (JSReportOption *option in strongSelf.reportOptions) {
                                                               if ([option.uri isEqualToString:strongSelf.initialReportOptionURI]) {
                                                                   activeReportOption = option;
                                                                   break;
                                                               }
                                                           }
                                                           if (activeReportOption) {
                                                               __weak typeof(self) weakSelf = strongSelf;
                                                               [self.networkManager loadInputControlsForReportOption:activeReportOption
                                                                                                          completion:^(NSArray *inputControls, NSError *error) {
                                                                                                              typeof(self) strongSelf = weakSelf;
                                                                                                              if (error) {
                                                                                                                  [strongSelf handleError:error completion:nil];
                                                                                                              } else {
                                                                                                                  activeReportOption.inputControls = inputControls;
                                                                                                                  strongSelf.inputControls = [[NSArray alloc] initWithArray:inputControls copyItems:YES];
                                                                                                                  completion(activeReportOption);
                                                                                                              }
                                                                                                          }];
                                                           } else {
                                                               completion(strongSelf.noneReportOption);
                                                           }
                                                       } else {
                                                           completion(strongSelf.noneReportOption);
                                                       }

                                                   }
                                               }];
}

- (void)runReport
{
    [self.view endEditing:YES];

    // empty 'none' option
    // we need this if an user marked 'always prompt' as true, but there are any input controls
    BOOL isEmptyNoneOption = (self.inputControls.count == 0 && self.reportOptions.count == 1);
    if ( isEmptyNoneOption) {
        if (self.completionBlock) {
            JMFiltersVCResult *result = [JMFiltersVCResult new];
            result.type = JMFiltersVCResultTypeEmptyFilters;
            self.completionBlock(result);
        }
        return;
    }

    BOOL isNoneReportOption = [self isNoneReportOption:self.activeReportOption];

    if (isNoneReportOption) { // NONE OPTION
        BOOL isReportParametersChanged = [self isReportParametersChanged];
        if (isReportParametersChanged) {
            if ([self validateInputControls]) { // Local validation
                [self updatedInputControlsValuesWithCompletion:^(BOOL dataIsValid) { // Server validation
                    if (dataIsValid) {
                        if (self.cookiesDidUpdate) {
                            return;
                        }
                        if (self.completionBlock) {
                            // parameters
                            NSArray <JSReportParameter *> *reportParameters = [JSUtils reportParametersFromInputControls:self.activeReportOption.inputControls];
                            JMFiltersVCResult *result = [JMFiltersVCResult new];
                            result.type = JMFiltersVCResultTypeReportParameters;
                            result.reportParameters = reportParameters;
                            self.completionBlock(result);
                        }
                    } else {
                        [self.tableView reloadData];
                    }
                }];
            } else {
                [self.tableView reloadData];
            }
        } else {
            if (self.completionBlock) {
                JMFiltersVCResult *result = [JMFiltersVCResult new];
                result.type = JMFiltersVCResultTypeNotChange;
                self.completionBlock(result);
            }
        }
    } else { // SOME REPORT OPTION
        BOOL isReportOptionChanged = [self isReportOptionChanged];
        if (isReportOptionChanged) {
            if (self.completionBlock) {
                // parameters
                JMFiltersVCResult *result = [JMFiltersVCResult new];
                result.type = JMFiltersVCResultTypeFilterOption;
                result.filterOptionURI = self.activeReportOption.uri;
                self.completionBlock(result);
            }
        } else {
            if (self.completionBlock) {
                JMFiltersVCResult *result = [JMFiltersVCResult new];
                result.type = JMFiltersVCResultTypeNotChange;
                self.completionBlock(result);
            }
        }
    }
}

- (BOOL)isNoneReportOption:(JSReportOption *)reportOption
{
    // TODO: consider other properties
    return reportOption.uri == nil;
}

- (BOOL)isReportOptionChanged
{
    // TODO: find a way to verify
    return YES;
}

- (BOOL)isReportParametersChanged
{
    // TODO: add implementation
    return YES;

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

    if ([destinationViewController isKindOfClass:[JMReportOptionsViewController class]]) {
        JMReportOptionsViewController *reportOptionsVC = (JMReportOptionsViewController *)destinationViewController;
        reportOptionsVC.listOfValues = self.reportOptions;
        reportOptionsVC.delegate = self;
        reportOptionsVC.selectedReportOption = self.activeReportOption;
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger numberOfSections = 0;
    // empty 'none' option
    // we need this if an user marked 'always prompt' as true, but there are any input controls
    BOOL isEmptyNoneOption = (self.inputControls.count == 0 && self.reportOptions.count == 1);
    if ([self isMultyReportOptions] || isEmptyNoneOption) {
        numberOfSections ++;
    }
    if ([self.inputControls count]) {
        numberOfSections ++;
    }
    return numberOfSections;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [[JMThemesManager sharedManager] tableViewCellTitleFont].lineHeight + 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *titleLabel = [UILabel new];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.font = [[JMThemesManager sharedManager] tableViewCellTitleFont];
    titleLabel.textColor = [[JMThemesManager sharedManager] reportOptionsTitleLabelTextColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    NSString *sectionTitle = JMLocalizedString(@"report_viewer_options_title");

    // empty 'none' option
    // we need this if an user marked 'always prompt' as true, but there are any input controls
    BOOL isEmptyNoneOption = (self.inputControls.count == 0 && self.reportOptions.count == 1);
    BOOL isSeveralReportOptions = [self isMultyReportOptions];
    if ( (isSeveralReportOptions || isEmptyNoneOption) && section == 0) {
        sectionTitle = JMLocalizedString(@"report_viewer_report_options_title");
    }
    titleLabel.text = [sectionTitle uppercaseString];
    [titleLabel sizeToFit];
    
    UIView *headerView = [UIView new];
    [headerView addSubview:titleLabel];
    [headerView addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:headerView attribute:NSLayoutAttributeBottom multiplier:1.0 constant: -8.0]];
    
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // empty 'none' option
    // we need this if an user marked 'always prompt' as true, but there are any input controls
    BOOL isEmptyNoneOption = (self.inputControls.count == 0 && self.reportOptions.count == 1);
    BOOL isSeveralReportOptions = [self isMultyReportOptions];
    if ( (isSeveralReportOptions || isEmptyNoneOption) && section == 0) {
        return 1;
    }
    return self.inputControls.count;
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
    // empty 'none' option
    // we need this if an user marked 'always prompt' as true, but there are any input controls
    BOOL isEmptyNoneOption = (self.inputControls.count == 0 && self.reportOptions.count == 1);
    BOOL isSeveralReportOptions = [self isMultyReportOptions];
    if ( (isSeveralReportOptions || isEmptyNoneOption) && indexPath.section == 0) {
        JMReportOptionsCell *roCell = (JMReportOptionsCell *)cell;
        roCell.titleLabel.text = self.activeReportOption.label;
    } else {
        JSInputControlDescriptor *inputControlDescriptor = self.inputControls[indexPath.row];
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
    // empty 'none' option
    // we need this if an user marked 'always prompt' as true, but there are any input controls
    BOOL isEmptyNoneOption = (self.inputControls.count == 0 && self.reportOptions.count == 1);
    BOOL isSeveralReportOptions = [self isMultyReportOptions];
    if ( (isSeveralReportOptions || isEmptyNoneOption) && indexPath.section == 0) {
        JMReportOptionsCell *roCell = (JMReportOptionsCell *)cell;
        roCell.titleLabel.text = self.activeReportOption.label;
    } else {
        JSInputControlDescriptor *inputControlDescriptor = self.inputControls[indexPath.row];
        JMInputControlCell *icCell = (JMInputControlCell *)cell;
        [icCell setInputControlDescriptor:inputControlDescriptor];
        icCell.delegate = self;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
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
        [self showLoadingWithCancelBlock:^{
            [self.networkManager reset];
            [self.navigationController popViewControllerAnimated:YES];
        }];
        [self updatedInputControlsValuesWithCompletion:^(BOOL dataIsValid) {
            [self hideLoading];
        }];
    }
}

- (void)inputControlCellDidChangedValue:(JMInputControlCell *)cell
{
    NSAssert([self.reportOptions indexOfObject:self.activeReportOption] != NSNotFound, @"Not existing report option");

    JSReportOption *newReportOption = [JSReportOption defaultReportOption];
    newReportOption.inputControls = self.inputControls;
    self.activeReportOption = newReportOption;

    [self updateRightBurButtonItem];
    [self.tableView reloadData];
}

#pragma mark - JMReportOptionsViewControllerDelegate
- (void)reportOptionsViewController:(JMReportOptionsViewController *)controller didSelectOption:(JSReportOption *)option
{
    if (self.activeReportOption != option) {
        JSReportOption *oldActiveReportOption = self.activeReportOption;
        self.activeReportOption = option;
        
        if (![self.activeReportOption.inputControls count]) {
            [self showLoading];
            __weak typeof(self)weakSelf = self;
            [self.networkManager loadInputControlsForReportOption:self.activeReportOption
                                                       completion:^(NSArray *inputControls, NSError *error) {
                                                           __strong typeof(self) strongSelf = weakSelf;
                                                           [strongSelf hideLoading];
                                                           if (error) {
                                                               __weak typeof(self) weakSelf = strongSelf;
                                                               [strongSelf handleError:error completion:^{
                                                                   __strong typeof(self) strongSelf = weakSelf;
                                                                   strongSelf.activeReportOption = oldActiveReportOption;
                                                               }];
                                                           } else {
                                                               strongSelf.activeReportOption.inputControls = inputControls;
                                                               strongSelf.inputControls = [[NSArray alloc] initWithArray:inputControls
                                                                                                               copyItems:YES];
                                                               [strongSelf.tableView reloadData];
                                                           }
                                                       }];
        } else {
            self.inputControls = [[NSArray alloc] initWithArray:self.activeReportOption.inputControls
                                                      copyItems:YES];
            [self.tableView reloadData];
        }
    }
}

#pragma mark - Private

- (NSString *)cellIdentifierForIndexPath:(NSIndexPath *)indexPath
{
    // empty 'none' option
    // we need this if an user marked 'always prompt' as true, but there are any input controls
    BOOL isEmptyNoneOption = (self.inputControls.count == 0 && self.reportOptions.count == 1);
    BOOL isSeveralReportOptions = [self isMultyReportOptions];
    if ( (isSeveralReportOptions || isEmptyNoneOption) && indexPath.section == 0) {
        return @"ReportOptionsCell";
    }
    JSInputControlDescriptor *inputControlDescriptor = self.inputControls[indexPath.row];
    NSDictionary *inputControlDescriptorTypes = @{
                                                  @(kJS_ICD_TYPE_BOOL)                     : @"BooleanCell",
                                                  @(kJS_ICD_TYPE_SINGLE_VALUE_TEXT)        : @"TextEditCell",
                                                  @(kJS_ICD_TYPE_SINGLE_VALUE_NUMBER)      : @"NumberCell",
                                                  @(kJS_ICD_TYPE_SINGLE_VALUE_DATE)        : @"DateCell",
                                                  @(kJS_ICD_TYPE_SINGLE_VALUE_TIME)        : @"TimeCell",
                                                  @(kJS_ICD_TYPE_SINGLE_VALUE_DATETIME)    : @"DateTimeCell",
                                                  @(kJS_ICD_TYPE_SINGLE_SELECT)            : @"SingleSelectCell",
                                                  @(kJS_ICD_TYPE_SINGLE_SELECT_RADIO)      : @"SingleSelectCell",
                                                  @(kJS_ICD_TYPE_MULTI_SELECT)             : @"MultiSelectCell",
                                                  @(kJS_ICD_TYPE_MULTI_SELECT_CHECKBOX)    : @"MultiSelectCell",
                                                  };

    return inputControlDescriptorTypes[@(inputControlDescriptor.type)];
}

- (BOOL)isMultyReportOptions
{
    return [self.reportOptions count] > 1;
}

- (void)setActiveReportOption:(JSReportOption *)activeReportOption
{
    if (_activeReportOption != activeReportOption) {
        _activeReportOption = activeReportOption;
        self.inputControls = [[NSArray alloc] initWithArray:activeReportOption.inputControls copyItems:YES];
        [self updateRightBurButtonItem];
        [self.tableView reloadData];
    }
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

    [self showLoadingWithCancelBlock:^{
        [self.networkManager reset];
        if (self.completionBlock) {
            JMFiltersVCResult *result = [JMFiltersVCResult new];
            result.type = JMFiltersVCResultTypeNotChange;
            self.completionBlock(result);
        }
    }];
    NSString *resourceURI = self.activeReportOption.uri;
    if (![resourceURI length]) {
        resourceURI = self.reportURI;
    }
    __weak typeof(self) weakSelf = self;
    [self.networkManager updateInputControlsWithResourceURI:resourceURI
                                           inputControlsIds:allInputControls
                                          updatedParameters:selectedValues
                                                 completion:^(NSArray<JSInputControlState *> *resultStates, NSError *error) {
                                                     __strong typeof(self)strongSelf = weakSelf;
                                                     [strongSelf hideLoading];

                                                     if (error) {
                                                         [strongSelf handleError:error completion:nil];
                                                     } else {
                                                         for (JSInputControlState *state in resultStates) {
                                                             for (JSInputControlDescriptor *inputControl in strongSelf.inputControls) {
                                                                 if ([state.uuid isEqualToString:inputControl.uuid]) {
                                                                     inputControl.state = state;
                                                                     break;
                                                                 }
                                                             }
                                                         }
                                                         [strongSelf.tableView reloadData];
                                                         if (completion) {
                                                             completion([strongSelf validateInputControls]);
                                                         }
                                                     }
                                                 }];
}

- (BOOL)isReportOptionsEditingAvailable
{
    NSInteger permissionMask = self.parentFolderLookup.permissionMask.integerValue;
    return (permissionMask & JSPermissionMask_Administration || permissionMask & JSPermissionMask_Write);
}

- (void)checkParentFolderPermissionWithCompletion:(void(^)(BOOL reportOptionsEditingAvailable))completion
{
    if (self.parentFolderLookup) {
        if (completion) {
            completion([self isReportOptionsEditingAvailable]);
        }
    } else {
        [self showLoadingWithCancelBlock:^{
            [self.networkManager reset];
        }];
        NSString *resourceFolderURI = [self.reportURI stringByDeletingLastPathComponent];
        __weak typeof(self) weakSelf = self;
        [self.restClient resourceLookupForURI:resourceFolderURI resourceType:kJS_WS_TYPE_FOLDER
                                   modelClass:[JSResourceLookup class]
                              completionBlock:^(JSOperationResult *result) {
                                  __strong typeof(self)strongSelf = weakSelf;
                                  [strongSelf hideLoading];

                                  if (result.error) {
                                      [strongSelf handleError:result.error completion:nil];
                                  } else {
                                      strongSelf.parentFolderLookup = [result.objects firstObject];
                                      if (completion) {
                                          completion([strongSelf isReportOptionsEditingAvailable]);
                                      }
                                  }
                              }];
    }
}

- (void)updateRightBurButtonItem
{
    if ([JMUtils isServerProEdition]) {
        if ([self currentReportOptionIsExisted]) {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"delete_item"] style:UIBarButtonItemStyleDone target:self action:@selector(deleteReportOptionTapped:)];
        } else {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"save_item"] style:UIBarButtonItemStyleDone target:self action:@selector(createReportOptionTapped:)];
        }
    }
}

- (void)createNewReportOptionWithName:(NSString *)name
{
    NSArray *reportParameters = [JSUtils reportParametersFromInputControls:self.inputControls];

    [self showLoading];
    NSString *newReportOptionName = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    __weak typeof(self) weakSelf = self;
    [self.networkManager createReportOptionWithResourceURI:self.reportURI
                                                     label:newReportOptionName
                                          reportParameters:reportParameters
                                                completion:^(JSReportOption *reportOption, NSError *error) {
                                                    __strong typeof(self)strongSelf = weakSelf;
                                                    [strongSelf hideLoading];
                                                    if (error) {
                                                        [strongSelf handleError:error completion:nil];
                                                    } else if (reportOption) {
                                                        JSReportOption *activeReportOption = reportOption;
                                                        activeReportOption.inputControls = strongSelf.inputControls;
                                                        [strongSelf.reportOptions addObject:activeReportOption];
                                                        strongSelf.activeReportOption = activeReportOption;
                                                    } else {
                                                        // TODO: need handle this case?
                                                    }
                                                }];
}

- (BOOL)isUniqueNewReportOptionName:(NSString *)name
{
    for (JSReportOption *reportOption in self.reportOptions) {
        if ([name isEqualToString:reportOption.label]) {
            return NO;
        }
    }
    return YES;
}

- (BOOL) currentReportOptionIsExisted
{
    NSInteger indexOfCurrentOption = [self.reportOptions indexOfObject:self.activeReportOption];
    NSInteger indexOfNoneReportOption = [self.reportOptions indexOfObjectIdenticalTo:self.noneReportOption];
    return (indexOfCurrentOption != NSNotFound && indexOfCurrentOption != indexOfNoneReportOption);
}

#pragma mark - Loading
- (void)showLoading
{
    [self showLoadingWithCancelBlock:nil];
}

- (void)showLoadingWithCancelBlock:(void(^)(void))cancelBlock
{
    [JMCancelRequestPopup presentWithMessage:@"status_loading"
                                 cancelBlock:cancelBlock];
}

- (void)hideLoading
{
    [JMCancelRequestPopup dismiss];
}

#pragma mark - Errors Handle

- (void)handleError:(NSError *)error completion:(void(^)(void))completion
{
    if (error.code == JSSessionExpiredErrorCode) {
        [JMUtils showLoginViewAnimated:YES
                            completion:nil];
    } else {
        [JMUtils presentAlertControllerWithError:error
                                      completion:completion];
    }
}

@end
