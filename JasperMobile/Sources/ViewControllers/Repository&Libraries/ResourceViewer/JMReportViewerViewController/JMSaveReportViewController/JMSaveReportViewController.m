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
#import "JMSaveReportSection.h"
#import "JMSaveReportNameCell.h"
#import "JMSaveReportFormatCell.h"
#import "JMSaveReportPageRangeCell.h"
#import "UIAlertView+Additions.h"
#import "JMReport.h"
#import "JSResourceLookup+Helpers.h"


NSString * const kJMSaveReportViewControllerSegue = @"SaveReportViewControllerSegue";
NSString * const kJMAttachmentPrefix = @"_";
NSString * const kJMSavePageFromKey = @"kJMSavePageFromKey";
NSString * const kJMSavePageToKey = @"kJMSavePageToKey";
NSString * const kJMSaveReportNameCellIdentifier = @"ReportNameCell";
NSString * const kJMSaveReportFormatCellIdentifier = @"FormatSelectionCell";
NSString * const kJMSaveReportPageRangeCellIdentifier = @"PageRangeCell";

@interface JMSaveReportViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, JMSaveReportNameCellDelegate, JMSaveReportPageRangeCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *saveReportButton;

@property (nonatomic, strong) NSString *selectedReportFormat;
@property (nonatomic, strong) NSString *reportName;
@property (nonatomic, strong) NSString *errorString;

@property (nonatomic, strong) NSMutableArray *sections;
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

    self.view.backgroundColor = kJMDetailViewLightBackgroundColor;
    self.tableView.backgroundColor = kJMDetailViewLightBackgroundColor;
    
    [self.tableView setRowHeight:[JMUtils isIphone] ? 44.f : 50.f];

    [self.saveReportButton setTitle:JMCustomLocalizedString(@"dialog.button.save", nil)
                           forState:UIControlStateNormal];

    [self setupSections];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reportLoaderDidChangeCountOfPages:) name:kJMReportLoaderDidChangeCountOfPagesNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupSections) name:kJMReportLoaderReportIsMutlipageNotification object:nil];
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
        if (![self rangeSaveReportSection]) {
            [self.sections addObject: [JMSaveReportSection sectionWithType:JMSaveReportSectionTypePageRange
                                                                     title:JMCustomLocalizedString(@"report.viewer.save.pagesRange", nil)]];
        }
    } else {
        if ([self rangeSaveReportSection]) {
            [self.sections removeObject:[self rangeSaveReportSection]];
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
            numberOfRows = 2;
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
                                                      attributes:@{NSFontAttributeName:[JMFont tableViewCellDetailErrorFont]}
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
                pageRangeCell.textLabel.text = JMCustomLocalizedString(@"report.viewer.save.pagesRange.fromPage", nil);
                pageRangeCell.currentPage = ((NSNumber *)self.pages[kJMSavePageFromKey]).integerValue;
                [pageRangeCell removeTopSeparator];
            } else if (indexPath.row == 1) {
                pageRangeCell.textLabel.text = JMCustomLocalizedString(@"report.viewer.save.pagesRange.toPage", nil);
                pageRangeCell.currentPage = ((NSNumber *)self.pages[kJMSavePageToKey]).integerValue;
                [pageRangeCell setTopSeparatorWithHeight:1.f color:tableView.separatorColor tableViewStyle:UITableViewStylePlain];
            }
            return pageRangeCell;
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
    // TODO: valid existing name
}

#pragma mark - JMSaveReportPageRangeCellDelegate
- (NSRange)availableRangeForPageRangeCell:(JMSaveReportPageRangeCell *)cell
{
    if (self.report.countOfPages != NSNotFound) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        if (indexPath.row == 0) {
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
    if (indexPath.row == 0) {
        self.pages[kJMSavePageFromKey] = page;
    } else if (indexPath.row == 1) {
        self.pages[kJMSavePageToKey] = page;
    }
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
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
    BOOL isValidReportName = [JMUtils validateReportName:self.reportName extension:self.selectedReportFormat errorMessage:&errorMessageString];
    self.errorString = errorMessageString;

    if (!self.errorString && isValidReportName) {
        if (![JMSavedResources isAvailableReportName:self.reportName format:self.selectedReportFormat]) {
            self.errorString = JMCustomLocalizedString(@"report.viewer.save.name.errmsg.notunique", nil);
            [[UIAlertView localizedAlertWithTitle:nil message:@"report.viewer.save.name.errmsg.notunique.rewrite" completion:@weakself(^(UIAlertView *alertView, NSInteger buttonIndex)) {
                if (alertView.cancelButtonIndex != buttonIndex) {
                    [self saveReport];
                }
            } @weakselfend cancelButtonTitle:@"dialog.button.cancel" otherButtonTitles:@"dialog.button.ok", nil] show];
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
    if (self.errorString) { // Clear error messages
        self.errorString = nil;
        [self.tableView reloadData];
    }
    
    if ([self createReportDirectory:fullReportDirectory errorMessage:nil]) {
        NSMutableArray *parameters = [NSMutableArray array];
        for (JSInputControlDescriptor *inputControlDescriptor in self.report.inputControls) {
            JSReportParameter *reportParameter = [[JSReportParameter alloc] initWithName:inputControlDescriptor.uuid
                                                                                   value:inputControlDescriptor.selectedValues];
            [parameters addObject:reportParameter];
        }

        [JMCancelRequestPopup presentWithMessage:@"report.viewer.save.saving.status.title" cancelBlock:^{
            [self.restClient cancelAllRequests];
            [[NSFileManager defaultManager] removeItemAtPath:fullReportDirectory error:nil];
        }];

        JSRequestCompletionBlock checkErrorBlock = @weakself(^(JSOperationResult *result)) {
            if (!result.isSuccessful) {
                [JMCancelRequestPopup dismiss];
                [self.restClient cancelAllRequests];
                [[NSFileManager defaultManager] removeItemAtPath:fullReportDirectory error:nil];

                if (result.error.code == JSSessionExpiredErrorCode) {
                    if (self.restClient.keepSession && [self.restClient isSessionAuthorized]) {
                        [self saveReport];
                    } else {
                        [JMUtils showLoginViewAnimated:YES completion:@weakself(^(void)) {
                            [self saveReport];
                        } @weakselfend];
                    }
                } else {
                    [JMUtils showAlertViewWithError:result.error];
                }
            }
            if ([self.restClient isRequestPoolEmpty]) {
                [JMCancelRequestPopup dismiss];
                
                if (result.isSuccessful) {
                    [JMSavedResources addReport:self.report.resourceLookup
                                       withName:self.reportName
                                         format:self.selectedReportFormat];
                    

                    // Save thumbnail image
                    [self saveThumbnailToPath:fullReportDirectory];
                    
                    // Animation
                    [CATransaction begin];
                    [CATransaction setCompletionBlock:^{
                        [self.delegate reportDidSavedSuccessfully];
                    }];
                    
                    [self.navigationController popViewControllerAnimated:YES];
                    [CATransaction commit];
                }
            }
        }@weakselfend;
        
        [self.restClient runReportExecution:self.report.resourceLookup.uri async:NO outputFormat:self.selectedReportFormat interactive:NO
                                  freshData:YES saveDataSnapshot:NO ignorePagination:NO transformerKey:nil pages:[self makePagesFormat]
                          attachmentsPrefix:kJMAttachmentPrefix parameters:parameters completionBlock:@weakself(^(JSOperationResult *result)) {
                              if (result.error) {
                                  checkErrorBlock(result);
                              } else {
                                  JSReportExecutionResponse *response = [result.objects objectAtIndex:0];
                                  JSExportExecutionResponse *export = [response.exports objectAtIndex:0];
                                  NSString *requestId = response.requestId;
                                  
                                  NSString *fullReportPath = [NSString stringWithFormat:@"%@/%@.%@", fullReportDirectory, kJMReportFilename, self.selectedReportFormat];
                                  [self.restClient loadReportOutput:requestId exportOutput:export.uuid loadForSaving:YES path:fullReportPath completionBlock:checkErrorBlock];
                                  
                                  for (JSReportOutputResource *attachment in export.attachments) {
                                      NSString *attachmentPath = [NSString stringWithFormat:@"%@/%@%@", fullReportDirectory, kJMAttachmentPrefix, attachment.fileName];
                                      [self.restClient saveReportAttachment:requestId exportOutput:export.uuid attachmentName:attachment.fileName path:attachmentPath completionBlock:checkErrorBlock];
                                  }
                              }
                          } @weakselfend];
    }
}

- (NSString *)makePagesFormat
{
    NSString *pagesFormat = nil;
    NSInteger fromPageNumber = ((NSNumber *)self.pages[kJMSavePageFromKey]).integerValue;
    NSInteger toPageNumber = ((NSNumber *)self.pages[kJMSavePageToKey]).integerValue;

    if (fromPageNumber != 1 || toPageNumber != self.report.countOfPages) {
        if (fromPageNumber == toPageNumber) {
            pagesFormat = [NSString stringWithFormat:@"%@", self.pages[kJMSavePageFromKey]];
        } else {
            pagesFormat = [NSString stringWithFormat:@"%@-%@", self.pages[kJMSavePageFromKey], self.pages[kJMSavePageToKey]];
        }
    }
    return pagesFormat;
}

- (void) saveThumbnailToPath:(NSString *)directoryPath
{
    __block NSData *thumbnailData = UIImagePNGRepresentation(self.report.thumbnailImage);
    if (!thumbnailData) {
        dispatch_semaphore_t sem = dispatch_semaphore_create(0);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableURLRequest *imageRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[self.report.resourceLookup thumbnailImageUrlString]]];
            [imageRequest setValue:@"image/jpeg" forHTTPHeaderField:@"Accept"];
            NSData *imageData = [NSURLConnection sendSynchronousRequest:imageRequest returningResponse:nil error:nil];
            if ([UIImage imageWithData:imageData]) {
                thumbnailData = imageData;
            }
            dispatch_semaphore_signal(sem);
        });
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    if (thumbnailData) {
        NSString *thumbnailPath = [directoryPath stringByAppendingPathComponent:kJMThumbnailImageFileName];
        [thumbnailData writeToFile:thumbnailPath atomically:YES];
    }
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

- (JMSaveReportSection *)rangeSaveReportSection
{
    for (JMSaveReportSection *section in self.sections) {
        if (section.sectionType == JMSaveReportSectionTypePageRange) {
            return section;
        }
    }
    return nil;
}

@end
