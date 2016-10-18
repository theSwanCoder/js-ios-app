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


#import "JMSavingReportViewController.h"
#import "JMSavedResources+Helpers.h"
#import "JMCancelRequestPopup.h"
#import "JMSaveReportSection.h"
#import "JMSaveReportNameCell.h"
#import "JMSaveReportFormatCell.h"
#import "JMSaveReportPagesCell.h"
#import "JMSaveReportPageRangeCell.h"
#import "JSReportSaver.h"
#import "JMExportManager.h"
#import "JMReportExportTask.h"

NSString * const kJMSaveReportViewControllerSegue = @"SaveReportViewControllerSegue";
NSString * const kJMSaveReportNameCellIdentifier = @"ReportNameCell";
NSString * const kJMSaveReportFormatCellIdentifier = @"FormatSelectionCell";
NSString * const kJMSaveReportPagesCellIdentifier = @"PagesCell";
NSString * const kJMSaveReportPageRangeCellIdentifier = @"PageRangeCell";

@interface JMSavingReportViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, JMSaveReportNameCellDelegate, JMSaveReportPageRangeCellDelegate, JMSaveReportPagesCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *saveReportButton;

@property (nonatomic, strong) NSString *selectedReportFormat;
@property (nonatomic, strong) NSString *reportName;
@property (nonatomic, strong) NSString *errorString;

@property (nonatomic, strong) NSMutableArray *sections;

@property (nonatomic, assign) JMSaveReportPagesType pagesType;
@property (nonatomic, strong) JSReportPagesRange *pagesRange;

@end


@implementation JMSavingReportViewController

#pragma mark - Lifecycle
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = JMLocalizedString(@"report_viewer_save_title");
    self.reportName = self.report.resourceLookup.label;
    self.selectedReportFormat = [[JMUtils supportedFormatsForReportSaving] firstObject];

    self.pagesType = JMSaveReportPagesType_All;
    
    self.view.backgroundColor = [[JMThemesManager sharedManager] viewBackgroundColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    [self.tableView setRowHeight:([JMUtils isCompactWidth] || [JMUtils isCompactHeight]) ? 44.f : 50.f];

    self.saveReportButton.backgroundColor = [[JMThemesManager sharedManager] saveReportSaveReportButtonBackgroundColor];
    [self.saveReportButton setTitleColor:[[JMThemesManager sharedManager] saveReportSaveReportButtonTextColor]
                                forState:UIControlStateNormal];
    [self.saveReportButton setTitle:JMLocalizedString(@"dialog_button_save")
                           forState:UIControlStateNormal];

    [self setupSections];

    [self addObservers];
}

#pragma mark - Notifications

- (void)addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cookiesDidChange:)
                                                 name:JSRestClientDidChangeCookies
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reportLoaderDidChangeCountOfPages:)
                                                 name:JSReportCountOfPagesDidChangeNotification
                                               object:self.report];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setupSections)
                                                 name:JSReportIsMutlipageDidChangedNotification
                                               object:self.report];
}

#pragma mark - Session Expired Handlers

- (void)cookiesDidChange:(NSNotification *)notification
{
    if (self.sessionExpiredBlock) {
        self.sessionExpiredBlock();
    }
}

#pragma mark - Setups
- (void)setupSections
{
    if (!self.sections) {
        self.sections = [@[
                           [JMSaveReportSection sectionWithType:JMSaveReportSectionTypeName
                                                          title:JMLocalizedString(@"report_viewer_save_name")],
                           [JMSaveReportSection sectionWithType:JMSaveReportSectionTypeFormat
                                                          title:JMLocalizedString(@"report_viewer_save_format")],
                           ]mutableCopy];
    }
    
    if (self.report.isMultiPageReport) {
        if (![self sectionForType:JMSaveReportSectionTypePageRange]) {
            [self.sections addObject: [JMSaveReportSection sectionWithType:JMSaveReportSectionTypePageRange
                                                                     title:JMLocalizedString(@"report_viewer_save_pages")]];
        }
    } else {
        if ([self sectionForType:JMSaveReportSectionTypePageRange]) {
            [self.sections removeObject:[self sectionForType:JMSaveReportSectionTypePageRange]];
        }
    }
}

- (JSReportPagesRange *)pagesRange
{
    if (!_pagesRange) {
        _pagesRange = [JSReportPagesRange rangeWithStartPage:1 endPage:self.report.countOfPages];
    }
    return _pagesRange;
}

- (void)setErrorString:(NSString *)errorString
{
    if (![_errorString isEqualToString:errorString]) {
        _errorString = errorString;
        [self reloadSectionForType:JMSaveReportSectionTypeName];
    }
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    
    JMSaveReportSection *currentSection = self.sections[section];
    switch (currentSection.sectionType) {
        case JMSaveReportSectionTypeName: {
            numberOfRows = 1;
            break;
        }
        case JMSaveReportSectionTypeFormat: {
            numberOfRows = [JMUtils supportedFormatsForReportSaving].count;
            break;
        }
        case JMSaveReportSectionTypePageRange: {
            numberOfRows = (self.pagesType == JMSaveReportPagesType_All) ? 1 : 3;
            break;
        }
    }
    return numberOfRows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    JMSaveReportSection *currentSection = self.sections[section];
    return currentSection.title;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && self.errorString) {
        CGFloat maxWidth = self.tableView.frame.size.width - 40;
        CGSize maximumLabelSize = CGSizeMake(maxWidth, CGFLOAT_MAX);
        CGRect textRect = [self.errorString boundingRectWithSize:maximumLabelSize
                                                         options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                      attributes:@{NSFontAttributeName:[[JMThemesManager sharedManager] tableViewCellErrorFont]}
                                                         context:nil];
        return tableView.rowHeight + ceil(textRect.size.height);
    }
    return tableView.rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    JMSaveReportSection *currentSection = self.sections[indexPath.section];
    switch (currentSection.sectionType) {
        case JMSaveReportSectionTypeName: {
            JMSaveReportNameCell *reportNameCell = [tableView dequeueReusableCellWithIdentifier:kJMSaveReportNameCellIdentifier
                                                                                   forIndexPath:indexPath];
            reportNameCell.textField.text = self.reportName;
            reportNameCell.errorLabel.text = self.errorString;
            reportNameCell.cellDelegate = self;
            return reportNameCell;
        }
        case JMSaveReportSectionTypeFormat: {
            JMSaveReportFormatCell *formatCell = [tableView dequeueReusableCellWithIdentifier:kJMSaveReportFormatCellIdentifier
                                                                                 forIndexPath:indexPath];
            NSString *currentFormat = [JMUtils supportedFormatsForReportSaving][indexPath.row];
            formatCell.titleLabel.text = currentFormat;
            formatCell.accessoryType = [self.selectedReportFormat isEqualToString:currentFormat] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            return formatCell;
        }
        case JMSaveReportSectionTypePageRange: {
            if (indexPath.row == 0) {
                JMSaveReportPagesCell *pagesCell = [tableView dequeueReusableCellWithIdentifier:kJMSaveReportPagesCellIdentifier
                                                                                           forIndexPath:indexPath];
                pagesCell.cellDelegate = self;
                pagesCell.pagesType = self.pagesType;
                return pagesCell;
            } else {
                JMSaveReportPageRangeCell *pageRangeCell = [tableView dequeueReusableCellWithIdentifier:kJMSaveReportPageRangeCellIdentifier
                                                                                           forIndexPath:indexPath];
                pageRangeCell.cellDelegate = self;
                
                if (indexPath.row == 1) {
                    pageRangeCell.titleLabel.text = JMLocalizedString(@"report_viewer_save_pages_range_fromPage");
                    pageRangeCell.currentPage = self.pagesRange.startPage;
                } else if (indexPath.row == 2) {
                    pageRangeCell.titleLabel.text = JMLocalizedString(@"report_viewer_save_pages_range_toPage");
                    pageRangeCell.currentPage = self.pagesRange.endPage;
                }
                return pageRangeCell;
            }
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JMSaveReportSection *currentSection = self.sections[indexPath.section];
    if (currentSection.sectionType == JMSaveReportSectionTypeFormat) {
        NSString *reportFormat = [JMUtils supportedFormatsForReportSaving][indexPath.row];
        if (![reportFormat isEqualToString:self.selectedReportFormat]) {
            self.selectedReportFormat = reportFormat;
            NSIndexSet *sections = [NSIndexSet indexSetWithIndex:indexPath.section];
            [self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}

#pragma mark - JMSaveReportNameCellDelegate
- (void)nameCell:(JMSaveReportNameCell *)cell didChangeReportName:(NSString *)reportName
{
    self.reportName = reportName;
}

#pragma mark - JMSaveReportPageRangeCellDelegate
- (NSRange)availableRangeForPageRangeCell:(JMSaveReportPageRangeCell *)cell
{
    if (self.report.countOfPages != NSNotFound) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        if (indexPath.row == 1) {
            return NSMakeRange(1, self.pagesRange.endPage);
        } else {
            return NSMakeRange(self.pagesRange.startPage, self.report.countOfPages - self.pagesRange.startPage + 1);
        }
    }
    return NSMakeRange(NSNotFound, 0);
}

- (void)pageRangeCell:(JMSaveReportPageRangeCell *)cell didSelectPage:(NSInteger)page
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath.row == 1) {
        self.pagesRange.startPage = page;
    } else if (indexPath.row == 2) {
        self.pagesRange.endPage = page;
    }
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - JMSaveReportPagesCellDelegate
- (void)pagesCell:(JMSaveReportPagesCell *)pagesCell didChangedPagesType:(JMSaveReportPagesType)pagesType
{
    self.pagesType = pagesType;
    [self reloadSectionForType:JMSaveReportSectionTypePageRange];
}

#pragma mark - Actions
- (IBAction)saveButtonTapped:(id)sender
{
    [self runSaveAction];
}

#pragma mark - Private
- (void)runSaveAction
{
    [self.view endEditing:YES];
    NSString *errorMessageString = nil;
    BOOL isValidReportName = [JMUtils validateReportName:self.reportName errorMessage:&errorMessageString];
    self.errorString = errorMessageString;

    if (!self.errorString && isValidReportName) {
        __weak typeof(self) weakSelf = self;
        [self verifyRangePagesWithCompletion:^(BOOL success) {
            __strong typeof(self) strongSelf = weakSelf;
            if (success) {
                JMSavedResources *savedResource = [JMSavedResources savedResourceWithReportName:strongSelf.reportName format:strongSelf.selectedReportFormat];
                JMExportResource *exportResource = [JMExportManager exportResourceWithName:strongSelf.reportName format:strongSelf.selectedReportFormat];

                if (savedResource) {
                    strongSelf.errorString = JMLocalizedString(@"report_viewer_save_name_errmsg_notunique");
                    
                    UIAlertController *alertController = [UIAlertController alertControllerWithLocalizedTitle:@"dialod_title_error"
                                                                                                      message:@"report_viewer_save_name_errmsg_notunique_rewrite"
                                                                                            cancelButtonType:JMAlertControllerActionType_Cancel
                                                                                      cancelCompletionHandler:nil];
                    __weak typeof(self) weakSelf = strongSelf;
                    [alertController addActionWithType:JMAlertControllerActionType_Ok style:UIAlertActionStyleDefault handler:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action) {
                        __strong typeof(self) strongSelf = weakSelf;
                        [savedResource removeReport];
                        strongSelf.errorString = nil;
                        
                        [strongSelf saveReport];
                    }];
                    [strongSelf presentViewController:alertController animated:YES completion:nil];
                } else  if (exportResource) {
                    self.errorString = JMLocalizedString(@"report_viewer_save_name_errmsg_notunique");
                    UIAlertController *alertController = [UIAlertController alertControllerWithLocalizedTitle:@"dialod_title_error"
                                                                                                      message:@"report_viewer_save_name_errmsg_notunique_rewrite"
                                                                                            cancelButtonType:JMAlertControllerActionType_Cancel
                                                                                      cancelCompletionHandler:nil];
                    __weak typeof(self) weakSelf = self;
                    [alertController addActionWithType:JMAlertControllerActionType_Ok style:UIAlertActionStyleDefault handler:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action) {
                        __strong typeof(self) strongSelf = weakSelf;
                        [[JMExportManager sharedInstance] cancelTaskForResource:exportResource];
                        strongSelf.errorString = nil;
                        
                        [strongSelf saveReport];
                    }];
                    [self presentViewController:alertController animated:YES completion:nil];
                } else {
                    [strongSelf saveReport];;
                }
            }
        }];
    }
}

- (void)verifyRangePagesWithCompletion:(void(^)(BOOL success))completion
{
    BOOL isNotPDF = ![self.selectedReportFormat isEqualToString:kJS_CONTENT_TYPE_PDF];
    if (isNotPDF) {
        if ((self.pagesRange.endPage - self.pagesRange.startPage) + 1 > kJMSaveReportMaxRangePages ) {
            NSString *errorMessage = [NSString stringWithFormat:JMLocalizedString(@"report_viewer_save_name_errmsg_tooBigRange"), @(kJMSaveReportMaxRangePages), [self.selectedReportFormat uppercaseString]];
            
            UIAlertController *alertController = [UIAlertController alertControllerWithLocalizedTitle:@"dialod_title_error"
                                                                                              message:errorMessage
                                                                                    cancelButtonType:JMAlertControllerActionType_Cancel
                                                                              cancelCompletionHandler:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action) {
                                                                                  if (completion) {
                                                                                      completion(NO);
                                                                                  }
                                                                              }];
            __weak typeof(self) weakSelf = self;
            [alertController addActionWithType:JMAlertControllerActionType_Ok style:UIAlertActionStyleDefault handler:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action) {
                __strong typeof(self) strongSelf = weakSelf;
                strongSelf.selectedReportFormat = kJS_CONTENT_TYPE_PDF;
                // update format section
                JMSaveReportSection *formatSection = [strongSelf sectionForType:JMSaveReportSectionTypeFormat];
                NSInteger formatSectionIndex = [strongSelf.sections indexOfObject:formatSection];
                NSIndexSet *sectionsForUpdate = [NSIndexSet indexSetWithIndex:formatSectionIndex];
                [strongSelf.tableView reloadSections:sectionsForUpdate withRowAnimation:UITableViewRowAnimationAutomatic];
                if (completion) {
                    completion(YES);
                }
            }];
            [self presentViewController:alertController animated:YES completion:nil];
        } else {
            if (completion) {
                completion(YES);
            }
        }
    } else {
        if (completion) {
            completion(YES);
        }
    }
}

- (void) saveReport
{
    if (self.errorString) { // Clear error messages
        self.errorString = nil;
        [self.tableView reloadData];
    }
    JMReportExportTask *task = [[JMReportExportTask alloc] initWithReport:self.report
                                                                     name:self.reportName
                                                                   format:self.selectedReportFormat
                                                                    pages:self.pagesRange];
    [[JMExportManager sharedInstance] addExportTask:task];

    // Animation
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [self.delegate reportDidSavedSuccessfully];
    }];
    [self.navigationController popViewControllerAnimated:YES];
    [CATransaction commit];
}

- (void) reportLoaderDidChangeCountOfPages:(NSNotification *) notification
{
    self.pagesRange.endPage = self.report.countOfPages;
    [self.tableView reloadData];
}

- (void)reportLoaderDidChangeMultipage:(NSNotification *)notification
{
    [self setupSections];
    [self.tableView reloadData];
}

- (JMSaveReportSection *)sectionForType:(JMSaveReportSectionType)sectionType
{
    for (JMSaveReportSection *section in self.sections) {
        if (section.sectionType == sectionType) {
            return section;
        }
    }
    return nil;
}

- (void) reloadSectionForType:(JMSaveReportSectionType)sectionType
{
    JMSaveReportSection *section = [self sectionForType:sectionType];
    NSInteger rangeSectionIndex = [self.sections indexOfObject:section];
    NSIndexSet *sectionsForUpdate = [NSIndexSet indexSetWithIndex:rangeSectionIndex];
    [self.tableView reloadSections:sectionsForUpdate withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
