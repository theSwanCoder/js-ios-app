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


//
//  JMPrintResourceViewController.m
//  TIBCO JasperMobile
//

#import "JMPrintResourceViewController.h"
#import "JMReportSaver.h"
#import "JMSaveReportPagesCell.h"
#import "JMSaveReportPageRangeCell.h"
#import "UITableViewCell+Additions.h"
#import "JMPrintPreviewTableViewCell.h"


NSString * const kJMPrintPageFromKey = @"kJMPrintPageFromKey";
NSString * const kJMPrintPageToKey = @"kJMPrintPageToKey";
NSString * const kJMPrintReportPagesCellIdentifier = @"PagesCell";
NSString * const kJMPrintReportPageRangeCellIdentifier = @"PageRangeCell";
NSString * const kJMPrintReportPagePreviewIdentifier = @"PreviewCell";

NSInteger const kJMPrintPreviewImageMinimumHeight = 130;

@interface JMPrintResourceViewController () <UITableViewDataSource, UITableViewDelegate, JMSaveReportPageRangeCellDelegate, JMSaveReportPagesCellDelegate>

@property (nonatomic, strong) JMReport *report;
@property (nonatomic, strong) JSResourceLookup *resourceLookup;
@property (nonatomic, weak) UIWebView *webView;

@property (nonatomic, strong) id printingItem;
@property (nonatomic, weak) IBOutlet UIButton *printButton;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, assign) JMSaveReportPagesType pagesType;
@property (nonatomic, strong) NSMutableDictionary *pages;

@end

@implementation JMPrintResourceViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = kJMDetailViewLightBackgroundColor;
    self.tableView.backgroundColor = kJMDetailViewLightBackgroundColor;

    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 0.01f)];
    
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);

    self.pagesType = JMSaveReportPagesType_All;

    [self.printButton setTitle:JMCustomLocalizedString(@"resource.viewer.print.button.title", nil)
                      forState:UIControlStateNormal];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interfaceOrientationDidChanged:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reportLoaderDidChangeCountOfPages:) name:kJMReportCountOfPagesDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupSections) name:kJMReportIsMutlipageDidChangedNotification object:nil];

    [self updatePrintJob];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Custom Accessories
- (NSMutableDictionary *)pages
{
    if (!_pages) {
        _pages = [NSMutableDictionary dictionaryWithObjectsAndKeys:@(1), kJMPrintPageFromKey, nil];
        if (self.report && self.report.isMultiPageReport) {
            [_pages setObject:@(self.report.countOfPages) forKey:kJMPrintPageToKey];
        } else {
            [_pages setObject:@(1) forKey:kJMPrintPageToKey];
        }
    }
    return _pages;
}

- (NSString *)jobName
{
    if (self.report) {
        return self.report.resourceLookup.label;
    } else if (self.resourceLookup) {
        return self.resourceLookup.label;
    } else {
        NSString *applicationName = [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleDisplayName"];
        return [NSString stringWithFormat:JMCustomLocalizedString(@"resource.viewer.print.operation.name", nil), applicationName];
    }
}

#pragma mark - Public API
- (void)setReport:(JMReport *)report withWebView:(UIWebView *)webView
{
    self.report = report;
    self.webView = webView;
    [self updatePrintJob];
}

- (void)setResourceLookup:(JSResourceLookup *)resourceLookup withWebView:(UIWebView *)webView
{
    self.resourceLookup = resourceLookup;
    self.webView = webView;
    [self updatePrintJob];
}

#pragma mark - JMSaveReportPageRangeCellDelegate
- (NSRange)availableRangeForPageRangeCell:(JMSaveReportPageRangeCell *)cell
{
    if (self.report.countOfPages != NSNotFound) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        if (indexPath.row == 1) {
            return NSMakeRange(1, ((NSNumber *)self.pages[kJMPrintPageToKey]).integerValue);
        } else {
            NSInteger toPage = ((NSNumber *)self.pages[kJMPrintPageFromKey]).integerValue;
            return NSMakeRange(toPage, self.report.countOfPages - toPage + 1);
        }
    }
    return NSMakeRange(NSNotFound, 0);
}

- (void)pageRangeCell:(JMSaveReportPageRangeCell *)cell didSelectPage:(NSNumber *)page
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath.row == 1) {
        self.pages[kJMPrintPageFromKey] = page;
    } else if (indexPath.row == 2) {
        self.pages[kJMPrintPageToKey] = page;
    }
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - JMSaveReportPagesCellDelegate
- (void)pagesCell:(JMSaveReportPagesCell *)pagesCell didChangedPagesType:(JMSaveReportPagesType)pagesType
{
    self.pagesType = pagesType;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self shouldShowRangeCells] ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger countOfRows = 1;
    if ([self shouldShowRangeCells] && !section) {
        countOfRows = (self.pagesType == JMSaveReportPagesType_All) ? 1 : 3;
    }
    return countOfRows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([self shouldShowRangeCells] && !section) {
        return JMCustomLocalizedString(@"report.viewer.save.pages", nil);
    } else {
        return JMCustomLocalizedString(@"resource.viewer.print.preview.title", nil);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat rowHeight = CGRectGetHeight(tableView.bounds) - [self tableView:tableView heightForHeaderInSection:indexPath.section];
    if ([self shouldShowRangeCells]){
        if(indexPath.section) {
            CGFloat heightOfAllOtherSections = 0;
            NSInteger countOfSections = [self numberOfSectionsInTableView:tableView];
            for (NSInteger i = 0; i < countOfSections; i++) {
                if (i != indexPath.section) {
                    heightOfAllOtherSections += CGRectGetHeight([tableView rectForSection:i]);
                }
            }
            rowHeight -= heightOfAllOtherSections;
            if (rowHeight < kJMPrintPreviewImageMinimumHeight) {
                rowHeight = kJMPrintPreviewImageMinimumHeight;
            }
        } else {
            rowHeight = tableView.rowHeight;
        }
    }
    return rowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self shouldShowRangeCells] && !indexPath.section) {
        if (indexPath.row == 0) {
            JMSaveReportPagesCell *pagesCell = [tableView dequeueReusableCellWithIdentifier:kJMPrintReportPagesCellIdentifier
                                                                               forIndexPath:indexPath];
            pagesCell.cellDelegate = self;
            pagesCell.pagesType = self.pagesType;
            [pagesCell removeTopSeparator];
            return pagesCell;
        } else {
            JMSaveReportPageRangeCell *pageRangeCell = [tableView dequeueReusableCellWithIdentifier:kJMPrintReportPageRangeCellIdentifier
                                                                                       forIndexPath:indexPath];
            pageRangeCell.cellDelegate = self;
            if (indexPath.row == 1) {
                pageRangeCell.textLabel.text = JMCustomLocalizedString(@"report.viewer.save.pages.range.fromPage", nil);
                pageRangeCell.currentPage = ((NSNumber *)self.pages[kJMPrintPageFromKey]).integerValue;
            } else if (indexPath.row == 2) {
                pageRangeCell.textLabel.text = JMCustomLocalizedString(@"report.viewer.save.pages.range.toPage", nil);
                pageRangeCell.currentPage = ((NSNumber *)self.pages[kJMPrintPageToKey]).integerValue;
            }
            [pageRangeCell setTopSeparatorWithHeight:1.f color:tableView.separatorColor tableViewStyle:UITableViewStylePlain];
            return pageRangeCell;
        }
    } else {
        JMPrintPreviewTableViewCell *previewCell = [tableView dequeueReusableCellWithIdentifier:kJMPrintReportPagePreviewIdentifier
                                                                                   forIndexPath:indexPath];
        previewCell.previewImageView.image = [self imageFromWebView];
        return previewCell;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[JMPrintPreviewTableViewCell class]]) {
        cell.backgroundColor = [UIColor clearColor];
    }
}

#pragma mark - Private API
- (void)prepareForPrint
{
    if (!self.printingItem) {
        if (self.report && self.report.isMultiPageReport) {
            JMReportSaver *reportSaver = [[JMReportSaver alloc] initWithReport:self.report];
            [JMCancelRequestPopup presentWithMessage:@"resource.viewer.print.prepare.title" cancelBlock:^{
                [reportSaver cancelReport];
            }];
            [reportSaver saveReportWithName:[self tempReportName]
                                     format:[JSConstants sharedInstance].CONTENT_TYPE_PDF
                                      pages:[self makePagesFormat]
                                    addToDB:NO
                                 completion:@weakself(^(NSString *reportURI, NSError *error)) {
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         [JMCancelRequestPopup dismiss];
                                     });
                                     if (error) {
                                         [reportSaver cancelReport];
                                         if (error.code == JSSessionExpiredErrorCode) {
                                             if (self.restClient.keepSession && [self.restClient isSessionAuthorized]) {
                                                 [self prepareForPrint];
                                             } else {
                                                 [JMUtils showLoginViewAnimated:YES completion:nil];
                                             }
                                         } else {
                                             [JMUtils showAlertViewWithError:error];
                                         }
                                     } else {
                                         self.printingItem = [NSURL fileURLWithPath:[[JMUtils applicationDocumentsDirectory] stringByAppendingPathComponent:reportURI]];
                                         [self printResource];
                                     }
                                 }@weakselfend];
        } else {
            self.printingItem = [self imageFromWebView];
            [self printResource];
        }
    } else {
        [self printResource];
    }
}

- (void)printResource
{
    UIPrintInfo *printInfo = [UIPrintInfo printInfo];
    printInfo.jobName = self.jobName;
    printInfo.outputType = UIPrintInfoOutputGeneral;
    printInfo.duplex = UIPrintInfoDuplexLongEdge;
    
    UIPrintInteractionController *printController = [UIPrintInteractionController sharedPrintController];
    printController.printInfo = printInfo;
    printController.showsPageRange = NO;
    printController.printingItem = self.printingItem;
    
    UIPrintInteractionCompletionHandler completionHandler = @weakself(^(UIPrintInteractionController *printController, BOOL completed, NSError *error)) {
        if(error){
            NSLog(@"FAILED! due to error in domain %@ with error code %zd", error.domain, error.code);
        } else if (completed) {
            if ([self.printingItem isKindOfClass:[NSURL class]]) {
                NSURL *fileURL = (NSURL *)self.printingItem;
                NSString *directoryPath = [fileURL.path stringByDeletingLastPathComponent];
                if ([[NSFileManager defaultManager] fileExistsAtPath:directoryPath]) {
                    [[NSFileManager defaultManager] removeItemAtPath:directoryPath error:nil];
                }
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
    }@weakselfend;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([JMUtils isIphone]) {
            [printController presentAnimated:YES completionHandler:completionHandler];
        } else {
            [printController presentFromRect:self.printButton.frame inView:self.view animated:YES completionHandler:completionHandler];
        }
    });
}

- (NSString *)makePagesFormat
{
    NSString *pagesFormat = nil;
    if (self.pagesType != JMSaveReportPagesType_All) {
        NSInteger fromPageNumber = ((NSNumber *)self.pages[kJMPrintPageFromKey]).integerValue;
        NSInteger toPageNumber = ((NSNumber *)self.pages[kJMPrintPageToKey]).integerValue;
        
        if (fromPageNumber != 1 || toPageNumber != self.report.countOfPages) {
            if (fromPageNumber == toPageNumber) {
                pagesFormat = [NSString stringWithFormat:@"%@", self.pages[kJMPrintPageFromKey]];
            } else {
                pagesFormat = [NSString stringWithFormat:@"%@-%@", self.pages[kJMPrintPageFromKey], self.pages[kJMPrintPageToKey]];
            }
        }
    }
    return pagesFormat;
}

#pragma mark - Actions
- (IBAction)printButtonTapped:(id)sender
{
    [self prepareForPrint];
}

- (void)interfaceOrientationDidChanged:(id)notification
{
    [self.tableView reloadData];
}

- (void) reportLoaderDidChangeCountOfPages:(NSNotification *) notification
{
    self.pages[kJMPrintPageToKey] = @(self.report.countOfPages);
    [self.tableView reloadData];
}

- (void)reportLoaderDidChangeMultipage:(NSNotification *)notification
{
    [self.tableView reloadData];
}

#pragma mark - Helpers
- (BOOL) shouldShowRangeCells
{
    return (self.report && self.report.isMultiPageReport);
}

- (void) updatePrintJob
{
    self.pages = nil;
    self.title = [self jobName];
    self.printingItem = nil;
    [self.tableView reloadData];
}

- (UIImage *)imageFromWebView
{
    // Screenshot rendering from webView
    UIGraphicsBeginImageContextWithOptions(self.webView.bounds.size, self.webView.opaque, 0.0);
    [self.webView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return viewImage;
}

- (NSString *)tempReportName
{
    return [[NSUUID UUID] UUIDString];
    return [[NSProcessInfo processInfo] globallyUniqueString];
}

@end
