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
#import "JMRequestDelegate.h"
#import "JMCancelRequestPopup.h"
#import "JMReportViewer.h"
#import "JMReportViewerToolBar.h"
#import "UIViewController+FetchInputControls.h"
#import "JMSaveReportViewController.h"
#import "JMResourcesCollectionViewController.h"

@interface JMReportViewerViewController () <JMReportViewerToolBarDelegate, JMReportViewerDelegate>
@property (nonatomic, strong) JMReportViewer *reportViewer;
@property (nonatomic, weak) JMReportViewerToolBar *toolbar;
@end

@implementation JMReportViewerViewController

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackButton];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateToolbarAppearence];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    if ([segue.identifier isEqualToString:kJMShowReportOptionsSegue] || [segue.identifier isEqualToString:kJMSaveReportViewControllerSegue]) {
        id destinationViewController = segue.destinationViewController;
        [destinationViewController setInputControls:[[NSMutableArray alloc] initWithArray:self.reportViewer.inputControls copyItems:YES]];
        [destinationViewController performSelector:@selector(setDelegate:) withObject:self];

        if ([segue.identifier isEqualToString:kJMSaveReportViewControllerSegue]) {
            ((JMSaveReportViewController *)destinationViewController).reportViewer = self.reportViewer;
        }
    }
}

#pragma mark - Methods

- (JMMenuActionsViewAction)availableAction
{
    JMMenuActionsViewAction availableAction = [super availableAction] | JMMenuActionsViewAction_Save | JMMenuActionsViewAction_Refresh;
    if (self.reportViewer.inputControls && [self.reportViewer.inputControls count]) {
        availableAction |= JMMenuActionsViewAction_Filter;
    }
    return availableAction;
}

- (void)setInputControls:(NSMutableArray *)inputControls
{
    self.reportViewer.inputControls = inputControls;
}

- (void) updateToolbarAppearence
{
    BOOL isToolbarHidden = YES;
    if (self.reportViewer.multiPageReport && self.toolbar) {
        isToolbarHidden = NO;
    }
    
    if (self.navigationController.toolbarHidden != isToolbarHidden) {
        [self.navigationController setToolbarHidden:isToolbarHidden
                                           animated:YES];
    }
}

#pragma mark - Actions
- (void) backButtonTapped:(id) sender
{
    [self.view endEditing:YES];
    NSInteger currentIndex = [self.navigationController.viewControllers indexOfObject:self];
    for (NSInteger i = currentIndex; i > 0; --i) {
        UIViewController *controller = [self.navigationController.viewControllers objectAtIndex:i];
        if ([controller isKindOfClass:[JMResourcesCollectionViewController class]]) {
            [self.toolbar removeFromSuperview];
            [self.navigationController popToViewController:controller animated:YES];
            break;
        }
    }
}

- (void) addBackButton
{
    NSString *title = [[self.navigationController.viewControllers objectAtIndex:1] title];
    UIImage *backButtonImage = [UIImage imageNamed:@"back_item"];
    UIImage *resizebleBackButtonImage = [backButtonImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, backButtonImage.size.width, 0, backButtonImage.size.width) resizingMode:UIImageResizingModeStretch];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleBordered target:self action:@selector(backButtonTapped:)];
    [backItem setBackgroundImage:resizebleBackButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    self.navigationItem.leftBarButtonItem = backItem;
}

- (void) runReportExecution
{
    [self.reportViewer runReportExecution];
   
    // Load reports with visualize.js
//    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"visualize_test" ofType:@"html"];
//    NSString *htmlString = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
//    
//    NSURL *serverURL = [NSURL URLWithString:self.resourceClient.serverProfile.serverUrl];
//    [self.webView loadHTMLString:htmlString baseURL:serverURL];
}

- (JMReportViewer *)reportViewer
{
    if (!_reportViewer) {
        _reportViewer = [[JMReportViewer alloc] initWithResourceLookup:self.resourceLookup];
        _reportViewer.delegate = self;
    }
    return _reportViewer;
}

- (JMReportViewerToolBar *)toolbar
{
    if (!_toolbar) {
        _toolbar = [[[NSBundle mainBundle] loadNibNamed:@"JMReportViewerToolBar" owner:self options:nil] firstObject];
        _toolbar.toolbarDelegate = self;
        _toolbar.currentPage = self.reportViewer.currentPage;
        _toolbar.countOfPages = self.reportViewer.countOfPages;
        _toolbar.frame = self.navigationController.toolbar.bounds;
        [self.navigationController.toolbar addSubview: _toolbar];
    }
    return _toolbar;
}

#pragma mark -
#pragma mark - JMMenuActionsViewDelegate
- (void)actionsView:(JMMenuActionsView *)view didSelectAction:(JMMenuActionsViewAction)action
{
    [super actionsView:view didSelectAction:action];
    switch (action) {
        case JMMenuActionsViewAction_Refresh:
            [self runReportExecution];
            break;
        case JMMenuActionsViewAction_Filter:
            [self performSegueWithIdentifier:kJMShowReportOptionsSegue sender:nil];
            break;
        case JMMenuActionsViewAction_Save:
            [self performSegueWithIdentifier:kJMSaveReportViewControllerSegue sender:nil];
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark - JMRefreshable
- (void)refresh
{
    [self.navigationController popToViewController:self animated:YES];
    [self runReportExecution];
}

#pragma mark -
#pragma mark - JMReportViewerToolBarDelegate
- (void)toolbar:(JMReportViewerToolBar *)toolbar pageDidChanged:(NSInteger)page
{
    self.reportViewer.currentPage = page;
}

#pragma mark -
#pragma mark - JMReportViewerDelegate
- (void)reportViewerReportDidCanceled:(JMReportViewer *)reportViewer
{
    [self backButtonTapped:nil];
}

- (void)reportViewerDidChangedPagination:(JMReportViewer *)reportViewer
{
    self.toolbar.currentPage = reportViewer.currentPage;
    self.toolbar.countOfPages = reportViewer.countOfPages;
    [self updateToolbarAppearence];
}

- (void) reportViewerShouldDisplayActivityIndicator:(JMReportViewer *)reportViewer
{
    [self.activityIndicator startAnimating];
}

- (void)reportViewer:(JMReportViewer *)reportViewer loadHTMLString:(NSString *)string baseURL:(NSString *)baseURL;
{
    if (self.webView.isLoading) {
        [self.webView stopLoading];
    }
    self.isResourceLoaded = NO;
    [self.webView loadHTMLString:string baseURL:[NSURL URLWithString:baseURL]];
}
@end
