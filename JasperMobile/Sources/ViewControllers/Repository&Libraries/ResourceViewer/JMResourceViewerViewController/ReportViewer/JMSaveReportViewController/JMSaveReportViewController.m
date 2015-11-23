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


#import "JMSaveReportViewController.h"
#import "JMSavedResources+Helpers.h"
#import "UITableViewCell+Additions.h"
#import "JMCancelRequestPopup.h"
#import "JMSaveReportSection.h"
#import "JMSaveReportNameCell.h"
#import "JMSaveReportFormatCell.h"
#import "JMSaveReportPagesCell.h"
#import "JMSaveReportPageRangeCell.h"
#import "UIAlertView+Additions.h"
#import "JMReport.h"
#import "JSResourceLookup+Helpers.h"
#import "JMReportSaver.h"

NSString * const kJMSaveReportViewControllerSegue = @"SaveReportViewControllerSegue";
NSString * const kJMSavePageFromKey = @"kJMSavePageFromKey";
NSString * const kJMSavePageToKey = @"kJMSavePageToKey";
NSString * const kJMSaveReportNameCellIdentifier = @"ReportNameCell";
NSString * const kJMSaveReportFormatCellIdentifier = @"FormatSelectionCell";
NSString * const kJMSaveReportPagesCellIdentifier = @"PagesCell";
NSString * const kJMSaveReportPageRangeCellIdentifier = @"PageRangeCell";

@interface JMSaveReportViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, JMSaveReportNameCellDelegate, JMSaveReportPageRangeCellDelegate, JMSaveReportPagesCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *saveReportButton;

@property (nonatomic, strong) NSString *selectedReportFormat;
@property (nonatomic, strong) NSString *reportName;
@property (nonatomic, strong) NSString *errorString;

@property (nonatomic, strong) NSMutableArray *sections;

@property (nonatomic, assign) JMSaveReportPagesType pagesType;
@property (nonatomic, strong) NSMutableDictionary *pages;
@end


@implementation JMSaveReportViewController

#pragma mark - Lifecycle
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = [JMCustomLocalizedString(@"report.viewer.save.title", nil) capitalizedString];
    self.reportName = self.report.resourceLookup.label;
    self.selectedReportFormat = [[JMUtils supportedFormatsForReportSaving] firstObject];

    self.pagesType = JMSaveReportPagesType_All;
    
    self.view.backgroundColor = [[JMThemesManager sharedManager] viewBackgroundColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    
    [self.tableView setRowHeight:[JMUtils isIphone] ? 44.f : 50.f];

    self.saveReportButton.backgroundColor = [[JMThemesManager sharedManager] saveReportSaveReportButtonBackgroundColor];
    [self.saveReportButton setTitleColor:[[JMThemesManager sharedManager] saveReportSaveReportButtonTextColor]
                                forState:UIControlStateNormal];
    [self.saveReportButton setTitle:JMCustomLocalizedString(@"dialog.button.save", nil)
                           forState:UIControlStateNormal];

    [self setupSections];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reportLoaderDidChangeCountOfPages:) name:kJMReportCountOfPagesDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupSections) name:kJMReportIsMutlipageDidChangedNotification object:nil];
}

#pragma mark - Setups
- (void)setupSections
{
    if (!self.sections) {
        self.sections = [@[
                           [JMSaveReportSection sectionWithType:JMSaveReportSectionTypeName
                                                          title:JMCustomLocalizedString(@"report.viewer.save.name", nil)],
                           [JMSaveReportSection sectionWithType:JMSaveReportSectionTypeFormat
                                                          title:JMCustomLocalizedString(@"report.viewer.save.format", nil)],
                           ]mutableCopy];
    }
    
    if (self.report.isMultiPageReport) {
        if (![self sectionForType:JMSaveReportSectionTypePageRange]) {
            [self.sections addObject: [JMSaveReportSection sectionWithType:JMSaveReportSectionTypePageRange
                                                                     title:JMCustomLocalizedString(@"report.viewer.save.pages", nil)]];
        }
    } else {
        if ([self sectionForType:JMSaveReportSectionTypePageRange]) {
            [self.sections removeObject:[self sectionForType:JMSaveReportSectionTypePageRange]];
        }
    }
}

- (NSMutableDictionary *)pages
{
    if (!_pages) {
        _pages = [@{
                    kJMSavePageFromKey : @(1),
                    kJMSavePageToKey : @(self.report.countOfPages)
                    } mutableCopy];
    }
    return _pages;
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
            if (indexPath.row) {
                [formatCell setTopSeparatorWithHeight:1.f color:self.view.backgroundColor tableViewStyle:UITableViewStylePlain];
            } else {
                [formatCell removeTopSeparator];
            }
            
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
                [pagesCell removeTopSeparator];
                return pagesCell;
            } else {
                JMSaveReportPageRangeCell *pageRangeCell = [tableView dequeueReusableCellWithIdentifier:kJMSaveReportPageRangeCellIdentifier
                                                                                           forIndexPath:indexPath];
                pageRangeCell.cellDelegate = self;
                
                if (indexPath.row == 1) {
                    pageRangeCell.titleLabel.text = JMCustomLocalizedString(@"report.viewer.save.pages.range.fromPage", nil);
                    pageRangeCell.currentPage = ((NSNumber *)self.pages[kJMSavePageFromKey]).integerValue;
                } else if (indexPath.row == 2) {
                    pageRangeCell.titleLabel.text = JMCustomLocalizedString(@"report.viewer.save.pages.range.toPage", nil);
                    pageRangeCell.currentPage = ((NSNumber *)self.pages[kJMSavePageToKey]).integerValue;
                }
                [pageRangeCell setTopSeparatorWithHeight:1.f color:self.view.backgroundColor tableViewStyle:UITableViewStylePlain];
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
            return NSMakeRange(1, ((NSNumber *)self.pages[kJMSavePageToKey]).integerValue);
        } else {
            NSInteger toPage = ((NSNumber *)self.pages[kJMSavePageFromKey]).integerValue;
            return NSMakeRange(toPage, self.report.countOfPages - toPage + 1);
        }
    }
    return NSMakeRange(NSNotFound, 0);
}

- (void)pageRangeCell:(JMSaveReportPageRangeCell *)cell didSelectPage:(NSNumber *)page
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath.row == 1) {
        self.pages[kJMSavePageFromKey] = page;
    } else if (indexPath.row == 2) {
        self.pages[kJMSavePageToKey] = page;
    }
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - JMSaveReportPagesCellDelegate
- (void)pagesCell:(JMSaveReportPagesCell *)pagesCell didChangedPagesType:(JMSaveReportPagesType)pagesType
{
    self.pagesType = pagesType;
    JMSaveReportSection *rangeSection = [self sectionForType:JMSaveReportSectionTypePageRange];
    NSInteger rangeSectionIndex = [self.sections indexOfObject:rangeSection];
    NSIndexSet *sectionsForUpdate = [NSIndexSet indexSetWithIndex:rangeSectionIndex];
    [self.tableView reloadSections:sectionsForUpdate withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Actions
- (IBAction)saveButtonTapped:(id)sender
{
    [self runSaveAction];
}

#pragma mark - Private

- (BOOL)createReportDirectory:(NSString *)reportDirectory errorMessage:(NSString **)errorMessage
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *error;
    BOOL isCreated = [fileManager createDirectoryAtPath:reportDirectory
                            withIntermediateDirectories:YES
                                             attributes:nil
                                                  error:&error];
    return isCreated;
}

- (void)runSaveAction
{
    [self.view endEditing:YES];
    NSString *errorMessageString = nil;
    BOOL isValidReportName = [JMUtils validateReportName:self.reportName errorMessage:&errorMessageString];
    self.errorString = errorMessageString;

    if (!self.errorString && isValidReportName) {
        if (![JMSavedResources isAvailableReportName:self.reportName format:self.selectedReportFormat]) {
            self.errorString = JMCustomLocalizedString(@"report.viewer.save.name.errmsg.notunique", nil);
            [[UIAlertView localizedAlertWithTitle:@"dialod.title.error" message:@"report.viewer.save.name.errmsg.notunique.rewrite" completion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (alertView.cancelButtonIndex != buttonIndex) {

                    self.errorString = nil;
                    [self.tableView reloadData];

                    [self verifyRangePagesWithCompletion:^{
                        [self saveReport];
                    }];
                }
            } cancelButtonTitle:@"dialog.button.cancel" otherButtonTitles:@"dialog.button.ok", nil] show];
        } else {
            [self verifyRangePagesWithCompletion:^{
                [self saveReport];
            }];
        }
    }
    // Clear any errors
    [self.tableView reloadData];
}

- (void)verifyRangePagesWithCompletion:(void(^)(void))completion
{
    BOOL isHTML = [self.selectedReportFormat isEqualToString:[JSConstants sharedInstance].CONTENT_TYPE_HTML];
    if (isHTML) {
        NSInteger fromPage = ((NSNumber *)self.pages[kJMSavePageFromKey]).integerValue;
        NSInteger toPage = ((NSNumber *)self.pages[kJMSavePageToKey]).integerValue;
        if ( (toPage - fromPage) + 1 > kJMSaveReportMaxRangePages ) {
            NSString *errorMessage = [NSString stringWithFormat:JMCustomLocalizedString(@"report.viewer.save.name.errmsg.tooBigRange", nil), @(kJMSaveReportMaxRangePages)];
            [[UIAlertView localizedAlertWithTitle:@"dialod.title.error"
                                          message:errorMessage
                                       completion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                           if (alertView.cancelButtonIndex != buttonIndex) {
                                               self.selectedReportFormat = [JSConstants sharedInstance].CONTENT_TYPE_PDF;
                                               // update format section
                                               JMSaveReportSection *formatSection = [self sectionForType:JMSaveReportSectionTypeFormat];
                                               NSInteger formatSectionIndex = [self.sections indexOfObject:formatSection];
                                               NSIndexSet *sectionsForUpdate = [NSIndexSet indexSetWithIndex:formatSectionIndex];
                                               [self.tableView reloadSections:sectionsForUpdate withRowAnimation:UITableViewRowAnimationAutomatic];
                                               // try save report in format PDF
                                               [self runSaveAction];
                                           }
                                       }
                                cancelButtonTitle:@"dialog.button.cancel"
                                otherButtonTitles:@"dialog.button.ok", nil] show];
        } else {
            if (completion) {
                completion();
            }
        }
    } else {
        if (completion) {
            completion();
        }
    }
}

- (void) saveReport
{
    if (self.errorString) { // Clear error messages
        self.errorString = nil;
        [self.tableView reloadData];
    }

    JMReportSaver *reportSaver = [[JMReportSaver alloc] initWithReport:self.report];
    [JMCancelRequestPopup presentWithMessage:@"report.viewer.save.saving.status.title" cancelBlock:^{
        [reportSaver cancelReport];
    }];
    [reportSaver saveReportWithName:self.reportName
                             format:self.selectedReportFormat
                              pages:[self makePagesFormat]
                            addToDB:YES
                         completion:^(JMSavedResources *savedReport, NSError *error) {
                             [JMCancelRequestPopup dismiss];

                             if (error) {
                                 if (error.code == JSSessionExpiredErrorCode) {
                                     [self.restClient verifyIsSessionAuthorizedWithCompletion:^(BOOL isSessionAuthorized) {
                                             if (self.restClient.keepSession && isSessionAuthorized) {
                                                 [self saveReport];
                                             } else {
                                                 [JMUtils showLoginViewAnimated:YES completion:nil];
                                             }
                                         }];
                                 } else {
                                     [JMUtils showAlertViewWithError:error];
                                     [savedReport removeReport];
                                 }
                             } else {
                                 // Animation
                                 [CATransaction begin];
                                 [CATransaction setCompletionBlock:^{
                                     [self.delegate reportDidSavedSuccessfully];
                                 }];

                                 [self.navigationController popViewControllerAnimated:YES];
                                 [CATransaction commit];
                             }
                         }];
}

- (NSString *)makePagesFormat
{
    NSString *pagesFormat = nil;
    if (self.pagesType != JMSaveReportPagesType_All) {
        NSInteger fromPageNumber = ((NSNumber *)self.pages[kJMSavePageFromKey]).integerValue;
        NSInteger toPageNumber = ((NSNumber *)self.pages[kJMSavePageToKey]).integerValue;
        
        if (fromPageNumber != 1 || toPageNumber != self.report.countOfPages) {
            if (fromPageNumber == toPageNumber) {
                pagesFormat = [NSString stringWithFormat:@"%@", self.pages[kJMSavePageFromKey]];
            } else {
                pagesFormat = [NSString stringWithFormat:@"%@-%@", self.pages[kJMSavePageFromKey], self.pages[kJMSavePageToKey]];
            }
        }
    }
    return pagesFormat;
}

- (void) reportLoaderDidChangeCountOfPages:(NSNotification *) notification
{
    self.pages[kJMSavePageToKey] = @(self.report.countOfPages);
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

@end
