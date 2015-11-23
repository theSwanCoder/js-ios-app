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


#import "JMCancelRequestPopup.h"
#import "JMRestReport.h"

#import "JMSaveReportViewController.h"

#import "SWRevealViewController.h"
#import "JMBaseCollectionViewController.h"
#import "JMInputControlsViewController.h"
#import "ALToastView.h"
#import "JSResourceLookup+Helpers.h"
#import "JMReportViewerToolBar.h"
#import "JMBaseReportViewerViewController.h"
#import "JMPrintResourceViewController.h"
#import "JMReportLoader.h"
#import "JMJavascriptNativeBridgeProtocol.h"
#import "JMReportSaver.h"
#import "JMReportManager.h"


@interface JMBaseReportViewerViewController () <UIAlertViewDelegate, JMSaveReportViewControllerDelegate>
@property (nonatomic, weak) JMReportViewerToolBar *toolbar;
@property (weak, nonatomic) IBOutlet UILabel *emptyReportMessageLabel;
@property (nonatomic, strong, readwrite) JMReport *report;

@property (nonatomic, assign) BOOL isReportAlreadyConfigured;
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
    self.emptyReportMessageLabel.text = JMCustomLocalizedString(@"report.viewer.emptyreport.title", nil);

    [self configureReport];
    
    [self addObservers];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self updateToobarAppearence];
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

#pragma mark - Setups
- (void)updateToobarAppearence
{
    if (self.toolbar && self.report.isMultiPageReport && !self.report.isReportEmpty) {
        self.toolbar.currentPage = self.report.currentPage;
        if (self.navigationController.visibleViewController == self) {
            [self.navigationController setToolbarHidden:NO animated:YES];
        }
    } else {
        [self.navigationController setToolbarHidden:YES animated:YES];
    }
}

#pragma mark - Observe Notifications
- (void)addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(multipageNotification)
                                                 name:kJMReportIsMutlipageDidChangedNotification
                                               object:self.report];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reportLoaderDidChangeCountOfPages:)
                                                 name:kJMReportCountOfPagesDidChangeNotification
                                               object:self.report];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reportLoaderDidChangeCurrentPage:)
                                                 name:kJMReportCurrentPageDidChangeNotification
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

- (void)reportLoaderDidChangeCurrentPage:(NSNotification *)notification
{
    self.toolbar.currentPage = self.report.currentPage;
    [self handleReportLoaderDidChangeCurrentPage];
}

- (void)handleReportLoaderDidChangeCountOfPages
{
    // override in child
}

- (void)handleReportLoaderDidChangeCurrentPage
{
    // override in child
}

#pragma mark - Actions
- (void)cancelResourceViewingAndExit:(BOOL)exit
{
    [self.reportLoader cancelReport];
    if (self.exitBlock) {
        self.exitBlock();
    }
    [super cancelResourceViewingAndExit:exit];
}

- (void)refreshReport
{
    [self resetSubViews];
    [self updateToobarAppearence];
    //
    [self runReportWithPage:1];
}

#pragma mark - Overloaded methods
- (void) startResourceViewing
{
    // empty method because parent call it from viewDidLoad
    // there is issue with "white screen" after loading input controls
    // until current view doesn't appear (on iOS 7)
}

- (void)startLoadReportWithPage:(NSInteger)page
{
    BOOL isReportAlreadyLoaded = self.report.isReportAlreadyLoaded;
    BOOL isReportInLoadingProcess = self.reportLoader.isReportInLoadingProcess;
    
    JMLog(@"report parameters: %@", self.report.reportParameters);
    JMLog(@"report input controls: %@", self.report.activeReportOption.inputControls);
    
    if(!isReportAlreadyLoaded && !isReportInLoadingProcess) {
        // show report with loaded input controls
        // when we start running a report from another report by tapping on hyperlink
        [self runReportWithPage:page];
    }
}

- (void)configureReport
{
    void(^errorHandlingBlock)(NSError *, NSString *) = ^(NSError *error, NSString *errorMessage) {
        [JMCancelRequestPopup dismiss];
        NSLog(@"%@: %@", errorMessage, error);
        if (error.code == JSSessionExpiredErrorCode) {
            [JMUtils showLoginViewAnimated:YES completion:^{
                [self cancelResourceViewingAndExit:YES];
            }];
        } else {
            [JMUtils showAlertViewWithError:error completion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                [self cancelResourceViewingAndExit:YES];
            }];
        }
    };
    
    NSString *reportURI = self.resourceLookup.uri;

    [JMCancelRequestPopup presentWithMessage:@"status.loading"
                                 cancelBlock:^{
        [self cancelResourceViewingAndExit:YES];
    }];
    [JMReportManager fetchReportLookupWithResourceURI:reportURI
                                completion:^(JSResourceReportUnit *reportUnit, NSError *error) {
                                        [self stopShowLoader];
                                        if (error) {
                                            errorHandlingBlock(error, @"Report Unit Loading Error");
                                        } else {
                                            if (reportUnit) {
                                                if (self.isChildReport) {
                                                    [self.report updateReportParameters:self.initialReportParameters];
                                                    [self startLoadReportWithPage:1];
                                                } else {
                                                    // get report input controls
                                                    [JMReportManager fetchInputControlsWithReportURI:reportURI
                                                                                          completion:^(NSArray *inputControls, NSError *error) {
                                                                                              if (error) {
                                                                                                  errorHandlingBlock(error, @"Report Input Controls Loading Error");
                                                                                              } else {
                                                                                                  if ([inputControls count]) {
                                                                                                      [self.report generateReportOptionsWithInputControls:inputControls];

                                                                                                      // get report options
                                                                                                      [JMReportManager fetchReportOptionsWithReportURI:self.report.reportURI completion:^(NSArray *reportOptions, NSError *error) {
                                                                                                          if (error && error.code == JSSessionExpiredErrorCode) {
                                                                                                              errorHandlingBlock(error, @"Report Options Loading Error");
                                                                                                          } else {
                                                                                                              [JMCancelRequestPopup dismiss];
                                                                                                              self.isReportAlreadyConfigured = YES;

                                                                                                              [self.report addReportOptions:reportOptions];

                                                                                                              if ([reportOptions count] || (reportUnit.alwaysPromptControls && [inputControls count])) {
                                                                                                                  [self showInputControlsViewControllerWithBackButton:YES];
                                                                                                              } else  {
                                                                                                                  [self startLoadReportWithPage:1];
                                                                                                              }
                                                                                                          }
                                                                                                      }];
                                                                                                  } else {
                                                                                                      [JMCancelRequestPopup dismiss];
                                                                                                      [self startLoadReportWithPage:1];
                                                                                                  }
                                                                                              }
                                                                                          }];
                                                }
                                            } else {
                                                NSDictionary *userInfo = @{NSURLErrorFailingURLErrorKey : @"Report Unit Loading Error"};
                                                NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:JSClientErrorCode userInfo:userInfo];
                                                [JMUtils showAlertViewWithError:error completion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                    [self cancelResourceViewingAndExit:YES];
                                                }];
                                            }
                                        }
                                }];
}

#pragma mark - Print
- (void)printResource
{
    // TODO: we don't have events when JIVE is applied to a report.

    [self preparePreviewForPrintWithCompletion:^(NSURL *resourceURL) {
        if (resourceURL) {
            [self printItem:resourceURL
                   withName:self.report.resourceLookup.label
                 completion:^(BOOL completed, NSError *error){
                         [self removeResourceWithURL:resourceURL];
                         if(error){
                             JMLog(@"FAILED! due to error in domain %@ with error code %ld", error.domain, (long)error.code);
                         }
                    }];
        }
    }];
}

- (void)preparePreviewForPrintWithCompletion:(void(^)(NSURL *resourceURL))completion
{
    JMReportSaver *reportSaver = [[JMReportSaver alloc] initWithReport:self.report];
    [JMCancelRequestPopup presentWithMessage:@"status.loading" cancelBlock:^{
        [reportSaver cancelReport];
    }];
    [reportSaver saveReportWithName:[self tempReportName]
                             format:[JSConstants sharedInstance].CONTENT_TYPE_PDF
                              pages:[self makePagesFormat]
                            addToDB:NO
                         completion:^(JMSavedResources *savedReport, NSError *error) {
                                 [JMCancelRequestPopup dismiss];
                                 if (error) {
                                     if (error.code == JSSessionExpiredErrorCode) {
                                         [self.restClient verifyIsSessionAuthorizedWithCompletion:^(BOOL isSessionAuthorized) {
                                                 if (self.restClient.keepSession && isSessionAuthorized) {
                                                     [self preparePreviewForPrintWithCompletion:completion];
                                                 } else {
                                                     [JMUtils showLoginViewAnimated:YES completion:nil];
                                                 }
                                             }];
                                     } else {
                                         [JMUtils showAlertViewWithError:error];
                                     }
                                 } else {
                                     NSString *savedReportURL = [JMSavedResources absolutePathToSavedReport:savedReport];
                                     NSURL *resourceURL = [NSURL fileURLWithPath:savedReportURL];
                                     if (completion) {
                                         completion(resourceURL);
                                         [savedReport removeFromDB];
                                     }
                                 }
                             }];
}

- (NSString *)tempReportName
{
    return [[NSUUID UUID] UUIDString];
}

- (NSString *)makePagesFormat
{
    NSString *pagesFormat;
    if (self.report.isMultiPageReport) {
        pagesFormat = [NSString stringWithFormat:@"1-%@", @(self.report.countOfPages)];
    } else {
        pagesFormat = [NSString stringWithFormat:@"1"];
    }
    return pagesFormat;
}

- (void)removeResourceWithURL:(NSURL *)resourceURL
{
    NSString *directoryPath = [resourceURL.path stringByDeletingLastPathComponent];
    if ([[NSFileManager defaultManager] fileExistsAtPath:directoryPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:directoryPath error:nil];
    }
}

- (void)runReportWithPage:(NSInteger)page
{
    // This method should be overrided in inherited classes.
}

#pragma mark - Custom accessors
- (JMReport *)report
{
    if (!_report) {
        _report = [self.resourceLookup reportModel];
    }
    return _report;
}

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
            [self refreshReport];
            break;
        case JMMenuActionsViewAction_Edit: {
            [self showInputControlsViewControllerWithBackButton:NO];
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
    [self refreshReport];
}

#pragma mark - JMSaveReportControllerDelegate
- (void)reportDidSavedSuccessfully
{
    [ALToastView toastInView:self.view
                    withText:JMCustomLocalizedString(@"report.viewer.save.saved", nil)];
}

- (void)updateReportWithNewActiveReportOption:(JMExtendedReportOption *)newActiveOption
{
    // can be overriden in childs
    self.report.activeReportOption = newActiveOption;
    [self refresh];
}

#pragma mark - Input Controls
- (void)showInputControlsViewControllerWithBackButton:(BOOL)isShowBackButton
{
    JMInputControlsViewController *inputControlsViewController = (JMInputControlsViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"JMInputControlsViewController"];
    inputControlsViewController.report = self.report;
    inputControlsViewController.completionBlock = ^(JMExtendedReportOption *reportOption) {
        [self updateReportWithNewActiveReportOption:reportOption];
    };

    if (isShowBackButton) {
        UIBarButtonItem *backItem = [self backBarButtonItemWithTarget:inputControlsViewController
                                                               action:@selector(backButtonTapped:)];
        inputControlsViewController.navigationItem.leftBarButtonItem = backItem;
    }

    // There is issue in iOS 7 if self.view is not appeared, we can see white screen after pushing another VC
    while (!self.view.superview) {
        // wait
        [NSThread sleepForTimeInterval:0.25f];
    }

    [self.navigationController pushViewController:inputControlsViewController animated:YES];

}

#pragma mark - Helpers
- (JMMenuActionsViewAction)availableActionForResource:(JSResourceLookup *)resource
{
    JMMenuActionsViewAction availableAction = [super availableActionForResource:resource] | JMMenuActionsViewAction_Save;
    if (self.report.isReportWithInputControls) {
        availableAction |= JMMenuActionsViewAction_Edit;
    }
    if ([self isReportReady] && !self.report.isReportEmpty) {
        availableAction |= JMMenuActionsViewAction_Refresh;
    }
    return availableAction;
}

- (JMMenuActionsViewAction)disabledActionForResource:(JSResourceLookup *)resource
{
    JMMenuActionsViewAction disabledAction = [super disabledActionForResource:resource];
    if (![self isReportReady] || self.report.isReportEmpty) {
        disabledAction |= JMMenuActionsViewAction_Save | JMMenuActionsViewAction_Print;
    }
    return disabledAction;
}

- (void)showEmptyReportMessage
{
    self.emptyReportMessageLabel.hidden = NO;
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)hideEmptyReportMessage
{
    self.emptyReportMessageLabel.hidden = YES;
}

- (BOOL)isReportReady
{
    BOOL isCountOfPagesExist = self.report.countOfPages != NSNotFound;
    return isCountOfPagesExist;
}

@end
