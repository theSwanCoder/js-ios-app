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
#import "JMCancelRequestPopup.h"
#import "JMSavedResources+Helpers.h"


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
@property (nonatomic, strong) JSReportPagesRange *pagesRange;


@end

@implementation JMPrintResourceViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [[JMThemesManager sharedManager] viewBackgroundColor];
    self.tableView.backgroundColor = [[JMThemesManager sharedManager] viewBackgroundColor];

    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 0.01f)];
    
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);

    self.pagesType = JMSaveReportPagesType_All;

    [self.printButton setTitle:JMCustomLocalizedString(@"resource.viewer.print.button.title", nil)
                      forState:UIControlStateNormal];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interfaceOrientationDidChanged:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reportLoaderDidChangeCountOfPages:) name:kJSReportCountOfPagesDidChangeNotification object:nil];
    // TODO: setup this notification
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupSections) name:kJMReportIsMutlipageDidChangedNotification object:nil];

    [self setupNavigationItems];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Custom Accessories
- (JSReportPagesRange *)pagesRange
{
    if (!_pagesRange) {
        _pagesRange = [JSReportPagesRange rangeWithStartPage:1 endPage:self.report.countOfPages];
    }
    return _pagesRange;
}

- (NSString *)jobName
{
    if (self.report) {
        return self.report.resourceLookup.label;
    } else if (self.resourceLookup) {
        return self.resourceLookup.label;
    } else {
        NSString *applicationName = [NSBundle mainBundle].infoDictionary[@"CFBundleDisplayName"];
        return [NSString stringWithFormat:JMCustomLocalizedString(@"resource.viewer.print.operation.name", nil), applicationName];
    }
}

#pragma mark - Setups
- (void)setupNavigationItems
{
    [self setupLeftBarButtonItems];
}

- (void)setupLeftBarButtonItems
{
    UIBarButtonItem *backItem = [self backButtonWithTitle:nil
                                                   target:self
                                                   action:@selector(backButtonTapped:)];

    self.navigationItem.leftBarButtonItem = backItem;
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
            return NSMakeRange(1, self.pagesRange.startPage);
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
    if ([self shouldShowRangeCells] && !indexPath.section){
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
            JMSaveReportPagesCell *pagesCell = (JMSaveReportPagesCell *) [tableView dequeueReusableCellWithIdentifier:kJMPrintReportPagesCellIdentifier
                                                                                                         forIndexPath:indexPath];
            pagesCell.cellDelegate = self;
            pagesCell.pagesType = self.pagesType;
            [pagesCell removeTopSeparator];
            return pagesCell;
        } else {
            JMSaveReportPageRangeCell *pageRangeCell = (JMSaveReportPageRangeCell *) [tableView dequeueReusableCellWithIdentifier:kJMPrintReportPageRangeCellIdentifier
                                                                                                                     forIndexPath:indexPath];
            pageRangeCell.cellDelegate = self;
            if (indexPath.row == 1) {
                pageRangeCell.textLabel.text = JMCustomLocalizedString(@"report.viewer.save.pages.range.fromPage", nil);
                pageRangeCell.currentPage = self.pagesRange.startPage;
            } else if (indexPath.row == 2) {
                pageRangeCell.textLabel.text = JMCustomLocalizedString(@"report.viewer.save.pages.range.toPage", nil);
                pageRangeCell.currentPage = self.pagesRange.endPage;
            }
            [pageRangeCell setTopSeparatorWithHeight:1.f color:tableView.separatorColor tableViewStyle:UITableViewStylePlain];
            return pageRangeCell;
        }
    } else {
        JMPrintPreviewTableViewCell *previewCell = (JMPrintPreviewTableViewCell *) [tableView dequeueReusableCellWithIdentifier:kJMPrintReportPagePreviewIdentifier
                                                                                                                   forIndexPath:indexPath];
        CGRect containerBounds = previewCell.containerForWebView.bounds;
        self.webView.frame = containerBounds;
        [previewCell.containerForWebView addSubview:self.webView];

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
                [reportSaver cancelSavingReport];
            }];

            __weak typeof(self)weakSelf = self;
            [reportSaver saveReportWithName:[self tempReportName]
                                     format:kJS_CONTENT_TYPE_PDF
                                 pagesRange:self.pagesRange
                                    addToDB:NO
                                 completion:^(JMSavedResources *savedReport, NSError *error) {
                                     __strong typeof(self)strongSelf = weakSelf;

                                     [JMCancelRequestPopup dismiss];

                                     if (error) {
                                         if (error.code == JSSessionExpiredErrorCode) {
                                             [JMUtils showLoginViewAnimated:YES completion:nil];
                                         } else {
                                             [JMUtils presentAlertControllerWithError:error completion:nil];
                                         }
                                     } else {
                                         NSString *savedReportURL = [JMSavedResources absolutePathToSavedReport:savedReport];
                                         strongSelf.printingItem = [NSURL fileURLWithPath:savedReportURL];
                                         [strongSelf printResource];
                                     }
                                 }];
        } else {
            [self imageFromWebViewWithCompletion:^(UIImage *image) {
                self.printingItem = image;
                [self printResource];
            }];
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
    
    UIPrintInteractionCompletionHandler completionHandler = ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
        if(error){
            JMLog(@"FAILED! due to error in domain %@ with error code %ld", error.domain, (long)error.code);
        } else if (completed) {
            if ([self.printingItem isKindOfClass:[NSURL class]]) {
                NSURL *fileURL = (NSURL *)self.printingItem;
                NSString *directoryPath = [fileURL.path stringByDeletingLastPathComponent];
                if ([[NSFileManager defaultManager] fileExistsAtPath:directoryPath]) {
                    [[NSFileManager defaultManager] removeItemAtPath:directoryPath error:nil];
                }
            }
            if (self.printCompletion) {
                self.printCompletion();
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
    };
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([JMUtils isIphone]) {
            [printController presentAnimated:YES
                           completionHandler:completionHandler];
        } else {
            [printController presentFromRect:self.printButton.frame
                                      inView:self.view
                                    animated:YES
                           completionHandler:completionHandler];
        }
    });
}

#pragma mark - Actions
- (void)backButtonTapped:(id)sender
{
    if (self.printCompletion) {
        self.printCompletion();
    }
    [self.navigationController popViewControllerAnimated:YES];
}

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
    self.pagesRange.endPage = self.report.countOfPages;
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
    self.pagesRange = nil;
    self.title = [self jobName];
    self.printingItem = nil;
    [self.tableView reloadData];
}

- (void)imageFromWebViewWithCompletion:(void(^)(UIImage *image))completion
{
    [JMCancelRequestPopup presentWithMessage:@"resource.viewer.print.prepare.title"];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        // Screenshot rendering from webView
        UIGraphicsBeginImageContextWithOptions(self.webView.bounds.size, self.webView.opaque, 0.0);
        [self.webView.layer renderInContext:UIGraphicsGetCurrentContext()];

        UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        dispatch_async(dispatch_get_main_queue(), ^(void){
            [JMCancelRequestPopup dismiss];
            if (completion) {
                completion(viewImage);
            }
        });
    });
}

- (NSString *)tempReportName
{
    return [[NSUUID UUID] UUIDString];
}

- (UIBarButtonItem *)backButtonWithTitle:(NSString *)title
                                  target:(id)target
                                  action:(SEL)action
{
    NSString *backItemTitle = title;
    if (!backItemTitle) {
        NSArray *viewControllers = self.navigationController.viewControllers;
        UIViewController *previousViewController = viewControllers[[viewControllers indexOfObject:self] - 1];
        backItemTitle = previousViewController.title;
    }

    UIImage *backButtonImage = [UIImage imageNamed:@"back_item"];
    UIImage *resizebleBackButtonImage = [backButtonImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, backButtonImage.size.width, 0, backButtonImage.size.width) resizingMode:UIImageResizingModeStretch];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:[self croppedBackButtonTitle:backItemTitle]
                                                                 style:UIBarButtonItemStylePlain
                                                                target:target
                                                                action:action];
    [backItem setBackgroundImage:resizebleBackButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    return backItem;
}

- (NSString *)croppedBackButtonTitle:(NSString *)backButtonTitle
{
    // detect backButton text width to truncate with '...'
    NSDictionary *textAttributes = @{NSFontAttributeName : [[JMThemesManager sharedManager] navigationBarTitleFont]};
    CGSize titleTextSize = [self.title sizeWithAttributes:textAttributes];
    CGFloat titleTextWidth = ceilf(titleTextSize.width);
    CGSize backItemTextSize = [backButtonTitle sizeWithAttributes:textAttributes];
    CGFloat backItemTextWidth = ceilf(backItemTextSize.width);
    CGFloat backItemOffset = 12;

    CGFloat viewWidth = CGRectGetWidth(self.view.bounds);

    if (( (backItemOffset + backItemTextWidth) > (viewWidth - titleTextWidth) / 2 ) && ![backButtonTitle isEqualToString:JMCustomLocalizedString(@"back.button.title", nil)]) {
        return [self croppedBackButtonTitle:JMCustomLocalizedString(@"back.button.title", nil)];
    }
    return backButtonTitle;
}

@end
