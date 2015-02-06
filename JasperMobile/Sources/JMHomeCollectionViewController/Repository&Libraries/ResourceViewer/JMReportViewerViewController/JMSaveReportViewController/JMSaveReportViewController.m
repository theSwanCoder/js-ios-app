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


#import "JMSaveReportViewController.h"
#import "JMSavedResources+Helpers.h"
#import "UITableViewCell+Additions.h"
#import "JMCancelRequestPopup.h"
#import "JMRequestDelegate.h"
#import "ALToastView.h"
#import "JMSaveReportSection.h"
#import "JMSaveReportNameCell.h"
#import "JMSaveReportFormatCell.h"
#import "JMSaveReportPageRangeCell.h"

NSString * const kJMSaveReportViewControllerSegue = @"SaveReportViewControllerSegue";
NSString * const kJMAttachmentPrefix = @"_";
NSString * const kJMSavePageFromKey = @"kJMSavePageFromKey";
NSString * const kJMSavePageToKey = @"kJMSavePageToKey";
NSString * const kJMSaveReportNameCellIdentifier = @"ReportNameCell";
NSString * const kJMSaveReportFormatCellIdentifier = @"FormatSelectionCell";
NSString * const kJMSaveReportPageRangeCellIdentifier = @"PageRangeCell";

@interface JMSaveReportViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIAlertViewDelegate, JMSaveReportNameCellDelegate, JMSaveReportPageRangeCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSString *selectedReportFormat;
@property (nonatomic, strong) NSString *reportName;
@property (nonatomic, strong) NSString *errorString;

@property (nonatomic, copy) NSDictionary *sections;
@property (nonatomic, strong) NSMutableDictionary *pages;
@property (nonatomic, copy) NSArray *sectionTypes;
@end


@implementation JMSaveReportViewController
objection_requires(@"resourceClient", @"reportClient")

@synthesize resourceClient = _resourceClient;
@synthesize resourceLookup = _resourceLookup;
@synthesize reportClient = _reportClient;

#pragma mark - Lifecycle
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [[JSObjection defaultInjector] injectDependencies:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = [JMCustomLocalizedString(@"savereport.title", nil) capitalizedString];
    self.reportName = self.resourceLookup.label;
    self.selectedReportFormat = [[JMUtils supportedFormatsForReportSaving] firstObject];

    self.view.backgroundColor = kJMDetailViewLightBackgroundColor;
    self.tableView.backgroundColor = kJMDetailViewLightBackgroundColor;
    self.tableView.layer.cornerRadius = 4;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"apply_item"] style:UIBarButtonItemStyleBordered  target:self action:@selector(saveButtonTapped:)];
    [self.tableView setRowHeight:[JMUtils isIphone] ? 44.f : 50.f];
    
    [self setupSections];
}

#pragma mark - Setups
- (void)setupSections
{
    if (self.reportLoader.countOfPages > 1) {
        self.pages = [@{
                kJMSavePageFromKey : @1,
                kJMSavePageToKey : @(self.reportLoader.countOfPages),
        } mutableCopy];

        self.sectionTypes = @[
                @(JMSaveReportSectionTypeName),
                @(JMSaveReportSectionTypeFormat),
                @(JMSaveReportSectionTypePageRange)
        ];
    } else {
        self.sectionTypes = @[
                @(JMSaveReportSectionTypeName),
                @(JMSaveReportSectionTypeFormat)
        ];
    }
    self.sections = @{
            @(JMSaveReportSectionTypeFormat) : [JMSaveReportSection sectionWithType:JMSaveReportSectionTypeFormat
                                                                              title:JMCustomLocalizedString(@"savereport.format", nil)],
            @(JMSaveReportSectionTypeName) : [JMSaveReportSection sectionWithType:JMSaveReportSectionTypeName
                                                                            title:JMCustomLocalizedString(@"savereport.name", nil)],
            @(JMSaveReportSectionTypePageRange) : [JMSaveReportSection sectionWithType:JMSaveReportSectionTypePageRange
                                                                                 title:JMCustomLocalizedString(@"savereport.pagesRange", nil)],
    };
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sectionTypes count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    
    JMSaveReportSectionType sectionType = (JMSaveReportSectionType)((NSNumber *)self.sectionTypes[section]).integerValue;
    switch (sectionType) {
        case JMSaveReportSectionTypeName: {
            numberOfRows = 1;
            break;
        }
        case JMSaveReportSectionTypeFormat: {
            numberOfRows = [JMUtils supportedFormatsForReportSaving].count;
            break;
        }
        case JMSaveReportSectionTypePageRange: {
            numberOfRows = 2;
            break;
        }
    }
    return numberOfRows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    JMSaveReportSectionType sectionType = (JMSaveReportSectionType)((NSNumber *)self.sectionTypes[section]).integerValue;
    JMSaveReportSection *saveReportSection = (JMSaveReportSection *)self.sections[@(sectionType)];
    return saveReportSection.title;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && self.errorString) {
        CGFloat maxWidth = self.tableView.frame.size.width - 40;
        CGSize maximumLabelSize = CGSizeMake(maxWidth, CGFLOAT_MAX);
        CGRect textRect = [self.errorString boundingRectWithSize:maximumLabelSize
                                                         options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                      attributes:@{NSFontAttributeName:[JMFont tableViewCellDetailErrorFont]}
                                                         context:nil];
        return tableView.rowHeight + ceil(textRect.size.height);
    }
    return tableView.rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    JMSaveReportSectionType sectionType = (JMSaveReportSectionType)((NSNumber *)self.sectionTypes[indexPath.section]).integerValue;
    switch (sectionType) {
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
                [formatCell setTopSeparatorWithHeight:1.f color:tableView.separatorColor tableViewStyle:UITableViewStylePlain];
            } else {
                [formatCell removeTopSeparator];
            }
            
            NSString *currentFormat = [JMUtils supportedFormatsForReportSaving][indexPath.row];
            formatCell.textLabel.text = currentFormat;
            formatCell.accessoryType = [self.selectedReportFormat isEqualToString:currentFormat] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            return formatCell;
        }
        case JMSaveReportSectionTypePageRange: {
            JMSaveReportPageRangeCell *pageRangeCell = [tableView dequeueReusableCellWithIdentifier:kJMSaveReportPageRangeCellIdentifier
                                                                                       forIndexPath:indexPath];
            pageRangeCell.cellDelegate = self;
            if (indexPath.row == 0) {
                pageRangeCell.textLabel.text = JMCustomLocalizedString(@"savereport.pagesRange.fromPage", nil);
                pageRangeCell.currentPage = ((NSNumber *)self.pages[kJMSavePageFromKey]).integerValue;
                [pageRangeCell removeTopSeparator];
            } else if (indexPath.row == 1) {
                pageRangeCell.textLabel.text = JMCustomLocalizedString(@"savereport.pagesRange.toPage", nil);
                pageRangeCell.currentPage = ((NSNumber *)self.pages[kJMSavePageToKey]).integerValue;
                [pageRangeCell setTopSeparatorWithHeight:1.f color:tableView.separatorColor tableViewStyle:UITableViewStylePlain];
            }
            pageRangeCell.pageCount = self.reportLoader.countOfPages;
            return pageRangeCell;
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JMSaveReportSectionType sectionType = (JMSaveReportSectionType)((NSNumber *)self.sectionTypes[indexPath.section]).integerValue;
    switch (sectionType) {
        case JMSaveReportSectionTypeName:
        case JMSaveReportSectionTypePageRange:
            break;
        case JMSaveReportSectionTypeFormat:{
            NSString *reportFormat = [JMUtils supportedFormatsForReportSaving][indexPath.row];
            if (![reportFormat isEqualToString:self.selectedReportFormat]) {
                self.selectedReportFormat = reportFormat;
                NSIndexSet *sections = [NSIndexSet indexSetWithIndex:indexPath.section];
                [self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            break;
        };
    }
}

#pragma mark - JMSaveReportNameCellDelegate
- (void)nameCell:(JMSaveReportNameCell *)cell didChangeReportName:(NSString *)reportName
{
    self.reportName = reportName;
    // TODO: valid existing name
}

#pragma mark - JMSaveReportPageRangeCellDelegate
- (void)pageRangeCell:(JMSaveReportPageRangeCell *)cell didSelectPage:(NSNumber *)page
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath.row == 0) {
        if (page.integerValue > ((NSNumber *)self.pages[kJMSavePageToKey]).integerValue) {
            [self showErrorWithMessage:JMCustomLocalizedString(@"savereport.pagesRange.errorFromPage", nil)];
        } else {
            self.pages[kJMSavePageFromKey] = page;
        }
    } else if (indexPath.row == 1) {
        if (page.integerValue < ((NSNumber *)self.pages[kJMSavePageFromKey]).integerValue) {
            [self showErrorWithMessage:JMCustomLocalizedString(@"savereport.pagesRange.errorToPage", nil)];
        } else {
            self.pages[kJMSavePageToKey] = page;
        }
    }
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)showErrorWithMessage:(NSString *)errorMessage
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:errorMessage
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    [alertView show];
}

#pragma mark - Actions
- (void)saveButtonTapped:(id)sender
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
    
    if (!isCreated) *errorMessage = error.localizedDescription;
    return isCreated;
}

- (void)runSaveAction
{
    [self.view endEditing:YES];
    NSString *errorMessageString = nil;
    BOOL isValidReportName = [JMUtils validateReportName:self.reportName extension:self.selectedReportFormat errorMessage:&errorMessageString];
    self.errorString = errorMessageString;

    if (!self.errorString && isValidReportName) {
        if (![JMSavedResources isAvailableReportName:self.reportName format:self.selectedReportFormat]) {
            self.errorString = JMCustomLocalizedString(@"savereport.name.errmsg.notunique", nil);
            [[UIAlertView localizedAlertWithTitle:nil message:@"savereport.name.errmsg.notunique.rewrite" delegate:self cancelButtonTitle:@"dialog.button.cancel" otherButtonTitles:@"dialog.button.ok", nil] show];
        } else {
            [self saveReport];
        }
    }
    // Clear any errors
    [self.tableView reloadData];
}

- (void) saveReport
{
    NSString *fullReportDirectory = [JMSavedResources pathToReportDirectoryWithName:self.reportName format:self.selectedReportFormat];
    NSString *errorMessageString = nil;
    
    if ([self createReportDirectory:fullReportDirectory errorMessage:&errorMessageString]) {
        NSMutableArray *parameters = [NSMutableArray array];
        for (JSInputControlDescriptor *inputControlDescriptor in self.inputControls) {
            JSReportParameter *reportParameter = [[JSReportParameter alloc] initWithName:inputControlDescriptor.uuid
                                                                                   value:inputControlDescriptor.selectedValues];
            [parameters addObject:reportParameter];
        }

        [JMCancelRequestPopup presentWithMessage:@"savereport.saving.status.title" restClient:self.reportClient cancelBlock:^{
            [[NSFileManager defaultManager] removeItemAtPath:fullReportDirectory error:nil];
        }];

        JSRequestFinishedBlock checkErrorBlock = @weakself(^(JSOperationResult *result)) {
            if (!result.isSuccessful) {
                [self.reportClient cancelAllRequests];
                [JMRequestDelegate clearRequestPool];
                [[NSFileManager defaultManager] removeItemAtPath:fullReportDirectory error:nil];
            }
            if ([JMRequestDelegate isRequestPoolEmpty]) {
                [JMCancelRequestPopup dismiss];
            }
        }@weakselfend;

        JMRequestDelegate *delegate = [JMRequestDelegate requestDelegateForFinishBlock:@weakself(^(JSOperationResult *result)) {
            if (!result.isSuccessful) {
                checkErrorBlock(result);
            } else {
                JSReportExecutionResponse *response = [result.objects objectAtIndex:0];
                JSExportExecutionResponse *export = [response.exports objectAtIndex:0];
                NSString *requestId = response.requestId;
                
                NSString *fullReportPath = [NSString stringWithFormat:@"%@/%@.%@", fullReportDirectory, kJMReportFilename, self.selectedReportFormat];
                [self.reportClient loadReportOutput:requestId exportOutput:export.uuid loadForSaving:YES path:fullReportPath delegate:[JMRequestDelegate requestDelegateForFinishBlock:checkErrorBlock]];
                
                for (JSReportOutputResource *attachment in export.attachments) {
                    NSString *attachmentPath = [NSString stringWithFormat:@"%@/%@%@", fullReportDirectory, kJMAttachmentPrefix, attachment.fileName];
                    [self.reportClient saveReportAttachment:requestId exportOutput:export.uuid attachmentName:attachment.fileName path:attachmentPath delegate:[JMRequestDelegate requestDelegateForFinishBlock:checkErrorBlock]];
                }
            }
        } @weakselfend];
        
        [JMRequestDelegate setFinalBlock:@weakself(^(void)) {
            [self.navigationController popViewControllerAnimated:YES];
            [JMSavedResources addReport:self.resourceLookup
                               withName:self.reportName
                                 format:self.selectedReportFormat];
            [ALToastView toastInView:self.delegate.view
                            withText:JMCustomLocalizedString(@"savereport.saved", nil)];
        } @weakselfend];
        
        [self.reportClient runReportExecution:self.resourceLookup.uri async:NO outputFormat:self.selectedReportFormat interactive:NO
                                    freshData:YES saveDataSnapshot:NO ignorePagination:NO transformerKey:nil pages:[self makePagesFormat]
                            attachmentsPrefix:kJMAttachmentPrefix parameters:parameters delegate:delegate];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.cancelButtonIndex != buttonIndex) {
        [self saveReport];
    }
}

- (NSString *)makePagesFormat
{
    NSString *pagesFormat;
    NSInteger fromPageNumber = ((NSNumber *)self.pages[kJMSavePageFromKey]).integerValue;
    NSInteger toPageNumber = ((NSNumber *)self.pages[kJMSavePageToKey]).integerValue;
    if (self.pages) {
        BOOL isFromPageChanged = fromPageNumber != 1;
        BOOL isToPageChanged = toPageNumber != self.reportLoader.countOfPages;
        if (isFromPageChanged || isToPageChanged) {
            if (fromPageNumber == toPageNumber) {
                pagesFormat = [NSString stringWithFormat:@"%@", self.pages[kJMSavePageFromKey]];
            } else {
                pagesFormat = [NSString stringWithFormat:@"%@-%@", self.pages[kJMSavePageFromKey], self.pages[kJMSavePageToKey]];
            }
        }
    }
    return pagesFormat;
}

@end
