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


#import "JMReportViewerViewController.h"
#import "JMCancelRequestPopup.h"
#import "JMRestReport.h"

#import "JMSaveReportViewController.h"

#import "SWRevealViewController.h"
#import "JMBaseCollectionViewController.h"
#import "JMReportOptionsViewController.h"
#import "ALToastView.h"


@interface JMBaseReportViewerViewController () <UIAlertViewDelegate, JMSaveReportViewControllerDelegate>
@property (assign, nonatomic) JMMenuActionsViewAction menuActionsViewAction;

@end

@implementation JMBaseReportViewerViewController

#pragma mark - Lifecycle
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addObservers];
    self.menuActionsViewAction = JMMenuActionsViewAction_Save | JMMenuActionsViewAction_Refresh;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self updateToobarAppearence];
    
    // start point
    [self startLoadReport];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_toolbar removeFromSuperview];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    if ([segue.identifier isEqualToString:kJMSaveReportViewControllerSegue]) {
        JMSaveReportViewController *destinationViewController = segue.destinationViewController;
        destinationViewController.report = self.report;
        destinationViewController.delegate = self;
    }
}

#pragma mark - Custom Accessors
- (JSResourceLookup *)currentResourceLookup
{
    return self.report.resourceLookup;
}

#pragma mark - Setups
- (void)updateToobarAppearence
{
    if (self.report.isMultiPageReport && self.toolbar) {
        self.toolbar.currentPage = self.report.currentPage;
        if (self.navigationController.visibleViewController == self) {
            [self.navigationController setToolbarHidden:NO animated:YES];
        }
    } else {
        [self.navigationController setToolbarHidden:YES animated:YES];
    }
}

#pragma mark - Setup Back
- (void)setupNavigationItems
{
    [super setupNavigationItems];
    
    [self setupBackNavigationItem];
}

- (void)setupBackNavigationItem
{
    UIViewController *rootViewController = [self.navigationController.viewControllers firstObject];
    NSString *backItemTitle = rootViewController.title;
    
    UIBarButtonItem *backItem = [self backButtonWithTitle:backItemTitle
                                                   target:self
                                                   action:@selector(backButtonTapped:)];
    self.navigationItem.leftBarButtonItem = backItem;
}

#pragma mark - Observe Notifications
- (void)addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(multipageNotification)
                                                 name:kJMReportLoaderReportIsMutlipageNotification
                                               object:self.report];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reportLoaderDidChangeCountOfPages:)
                                                 name:kJMReportLoaderDidChangeCountOfPagesNotification
                                               object:self.report];
}

- (void)multipageNotification
{
    [self updateToobarAppearence];
}

- (void)reportLoaderDidChangeCountOfPages:(NSNotification *)notification
{
    self.toolbar.countOfPages = self.report.countOfPages;
    [self handleReportLoaderDidChangeCountOfPages];
}

- (void)handleReportLoaderDidChangeCountOfPages
{
    // override in child
}

#pragma mark - Actions
- (void)backButtonTapped:(id) sender
{
    [self.view endEditing:YES];
    self.webView.delegate = nil;
    [self backToPreviousView];
}

- (void)backToPreviousView
{
    [self clearWebView];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Overloaded methods
- (void) runReportExecution
{
    // empty method because parent call it from viewDidLoad
    // there is issue with "white screen" after loading input controls
    // until current view doesn't appear (on iOS 7)
}

- (void)startLoadReport
{
    BOOL isReportEmpty = self.report.isReportEmpty;
    BOOL isInputControlsLoaded = self.report.isInputControlsLoaded;
    BOOL isReportInLoadingProcess = self.reportLoader.isReportInLoadingProcess;
    
    if (!isInputControlsLoaded) {
        // start load input controls
        
        NSString *reportURI = [self.report.reportURI stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [self loadInputControlsWithReportURI:reportURI
                                  completion:@weakself(^(NSArray *inputControls)) {
            self.report.isInputControlsLoaded = YES;
            if (inputControls) {
                [self.report updateInputControls:inputControls];
                [self showReportOptionsViewControllerWithBackButton:YES];
                
                [self.restClient performSelector:@selector(deleteCookies) withObject:nil afterDelay:30];
            } else {
                [self runReport];
            }
        }@weakselfend];
        
    } else if(isInputControlsLoaded && (!isReportEmpty && !isReportInLoadingProcess) ) {
        // show report with loaded input controls
        // when we start running a report from another report by tapping on hyperlink
        [self runReport];
    }
}

#pragma mark - Custom accessors
- (JMReportViewerToolBar *)toolbar
{
    if (!_toolbar) {
        _toolbar = [[[NSBundle mainBundle] loadNibNamed:@"JMReportViewerToolBar" owner:self options:nil] firstObject];
        _toolbar.toolbarDelegate = self;
        _toolbar.currentPage = self.report.currentPage;
        _toolbar.countOfPages = self.report.countOfPages;
        _toolbar.frame = self.navigationController.toolbar.bounds;
        [self.navigationController.toolbar addSubview: _toolbar];
    }
    return _toolbar;
}

#pragma mark - JMMenuActionsViewDelegate
- (void)actionsView:(JMMenuActionsView *)view didSelectAction:(JMMenuActionsViewAction)action
{
    [super actionsView:view didSelectAction:action];
    switch (action) {
        case JMMenuActionsViewAction_Refresh:
            [self refresh];
            break;
        case JMMenuActionsViewAction_Edit: {
            [self showReportOptionsViewControllerWithBackButton:NO];
            break;
        }
        case JMMenuActionsViewAction_Save:
            // TODO: change save action
            
            [self performSegueWithIdentifier:kJMSaveReportViewControllerSegue sender:nil];
            break;
        default:
            break;
    }
}

#pragma mark - JMRefreshable
- (void)refresh
{
    [self clearWebView];
    [self updateToobarAppearence];
    //
    [self runReport];
}

#pragma mark - JMReportViewerToolBarDelegate
- (void)toolbar:(JMReportViewerToolBar *)toolbar pageDidChanged:(NSInteger)page
{
    // overriden in childs
}

#pragma mark - JMSaveReportControllerDelegate
- (void)reportDidSavedSuccessfully
{
    [ALToastView toastInView:self.view
                    withText:JMCustomLocalizedString(@"report.viewer.save.saved", nil)];
}

#pragma mark - Run report
- (void)runReport
{
    // overriden in childs
}

- (void)reloadReport
{
    // overriden in childs
}

#pragma mark - Report Options (Input Controls)
- (void)loadInputControlsWithReportURI:(NSString *)reportURI completion:(void (^)(NSArray *))completion
{
    [self startShowLoaderWithMessage:@"status.loading" cancelBlock:@weakself(^(void)) {
        [self.restClient cancelAllRequests];
        [self.reportLoader cancelReport];
        [self backToPreviousView];
    }@weakselfend];
    
    [self.restClient inputControlsForReport:reportURI
                                        ids:nil
                             selectedValues:nil
                            completionBlock:@weakself(^(JSOperationResult *result)) {
                                [self stopShowLoader];

                                if (result.error) {
                                    if (result.error.code == JSSessionExpiredErrorCode) {
                                        if (self.restClient.keepSession && [self.restClient isSessionAuthorized]) {
                                            [self loadInputControlsWithReportURI:reportURI completion:completion];
                                        } else {
                                            [JMUtils showLoginViewAnimated:YES completion:@weakself(^(void)) {
                                                [self loadInputControlsWithReportURI:reportURI completion:completion];
                                            } @weakselfend];
                                        }
                                    } else {
                                        [JMUtils showAlertViewWithError:result.error];
                                    }
                                } else {
                                    
                                    NSMutableArray *invisibleInputControls = [NSMutableArray array];
                                    for (JSInputControlDescriptor *inputControl in result.objects) {
                                        if (!inputControl.visible.boolValue) {
                                            [invisibleInputControls addObject:inputControl];
                                        }
                                    }
                                    
                                    if (result.objects.count - invisibleInputControls.count == 0) {
                                        completion(nil);
                                    } else {
                                        NSMutableArray *inputControls = [result.objects mutableCopy];
                                        if (invisibleInputControls.count) {
                                            [inputControls removeObjectsInArray:invisibleInputControls];
                                        }                                        
                                        completion([inputControls copy]);
                                    }
                                }
                                
                            }@weakselfend];
}

- (void)showReportOptionsViewControllerWithBackButton:(BOOL)isShowBackButton
{
    JMReportOptionsViewController *reportOptionsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"JMReportOptionsViewController"];
    reportOptionsViewController.resourceLookup = self.report.resourceLookup;
    reportOptionsViewController.inputControls = [[NSArray alloc] initWithArray:self.report.inputControls copyItems:YES];
    reportOptionsViewController.completionBlock = @weakself(^(void)) {
        //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.report updateInputControls:reportOptionsViewController.inputControls];
            [self refresh];
        //});
    }@weakselfend;
    
    if (isShowBackButton) {
        UIViewController *rootViewController = [self.navigationController.viewControllers firstObject];
        NSString *backItemTitle = rootViewController.title;
        
        UIBarButtonItem *backItem = [self backButtonWithTitle:backItemTitle
                                                       target:reportOptionsViewController
                                                       action:@selector(backToLibrary)];
        reportOptionsViewController.navigationItem.leftBarButtonItem = backItem;
    }
    
    [self.navigationController pushViewController:reportOptionsViewController animated:YES];
}

#pragma mark - Helpers
- (JMMenuActionsViewAction)availableActionForResource:(JSResourceLookup *)resource
{
    JMMenuActionsViewAction availableAction = [super availableActionForResource:resource] | self.menuActionsViewAction;
    if (self.report.isReportWithInputControls) {
        availableAction |= JMMenuActionsViewAction_Edit;
    }
    return availableAction;
}

- (void)showEmptyReportMessage
{
    self.emptyReportMessageLabel.hidden = NO;
    self.menuActionsViewAction = JMMenuActionsViewAction_None;
}

- (void)hideEmptyReportMessage
{
    self.emptyReportMessageLabel.hidden = YES;
    self.menuActionsViewAction = JMMenuActionsViewAction_Save | JMMenuActionsViewAction_Refresh;
}

- (void)clearWebView
{
    [self.webView stopLoading];
    [self.webView loadHTMLString:nil baseURL:nil];
}

@end
