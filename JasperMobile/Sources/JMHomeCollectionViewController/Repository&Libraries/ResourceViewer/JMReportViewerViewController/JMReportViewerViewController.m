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

@interface JMReportViewerViewController () <JMReportViewerToolBarDelegate, JMReportViewerDelegate>
@property (nonatomic, strong) JMReportViewer *reportViewer;

@property (nonatomic, weak) JMReportViewerToolBar *toolbar;

@end

@implementation JMReportViewerViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackButton];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateToobarAppearence];

    if (![JMRequestDelegate isRequestPoolEmpty]) {
        [JMCancelRequestPopup presentInViewController:self message:@"status.loading" restClient:self.resourceClient cancelBlock:@weakself(^(void)) {
            [self.reportViewer cancelReport];
            [self.navigationController popViewControllerAnimated:YES];
        } @weakselfend ];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    if ([segue.identifier isEqualToString:kJMShowReportOptionsSegue] || [segue.identifier isEqualToString:kJMSaveReportViewControllerSegue]) {
        id destinationViewController = segue.destinationViewController;
        [destinationViewController setInputControls:[[NSMutableArray alloc] initWithArray:self.reportViewer.inputControls copyItems:YES]];
        [destinationViewController performSelector:@selector(setDelegate:) withObject:self];
    }
}

- (JMResourceViewerAction)availableAction
{
    JMResourceViewerAction availableAction = [super availableAction] | JMResourceViewerAction_Save | JMResourceViewerAction_Refresh;
    if (self.reportViewer.inputControls && [self.reportViewer.inputControls count]) {
        availableAction |= JMResourceViewerAction_Filter;
    }
    return availableAction;
}

- (void)setInputControls:(NSMutableArray *)inputControls
{
    self.reportViewer.inputControls = inputControls;
}

- (void) updateToobarAppearence
{
    if (self.reportViewer.multiPageReport && self.toolbar) {
        [self.navigationController setToolbarHidden:NO animated:YES];
    } else {
        [self.navigationController setToolbarHidden:YES animated:YES];
    }
}

#pragma mark - Actions
- (void) backButtonTapped:(id) sender
{
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

- (void) addBackButton
{
    if (self.reportViewer.inputControls && [self.reportViewer.inputControls count]) {
        NSString *title = [[self.navigationController.viewControllers objectAtIndex:1] title];
        UIImage *backButtonImage = [UIImage imageNamed:@"back_item"];
        UIImage *resizebleBackButtonImage = [backButtonImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, backButtonImage.size.width, 0, backButtonImage.size.width) resizingMode:UIImageResizingModeStretch];
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleBordered target:self action:@selector(backButtonTapped:)];
        [backItem setBackgroundImage:resizebleBackButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        
        self.navigationItem.leftBarButtonItem = backItem;
    }
}

- (void) runReportExecution
{
    [self.reportViewer runReportExecution];
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
#pragma mark - JMResourceViewerActionsViewDelegate
- (void)actionsView:(JMResourceViewerActionsView *)view didSelectAction:(JMResourceViewerAction)action
{
    [super actionsView:view didSelectAction:action];
    switch (action) {
        case JMResourceViewerAction_Refresh:
            [self runReportExecution];
            break;
        case JMResourceViewerAction_Filter:
            [self performSegueWithIdentifier:kJMShowReportOptionsSegue sender:nil];
            break;
        case JMResourceViewerAction_Save:
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
- (void)reportViewerDidChangedPagination:(JMReportViewer *)reportViewer
{
    self.toolbar.currentPage = reportViewer.currentPage;
    self.toolbar.countOfPages = reportViewer.countOfPages;
    [self updateToobarAppearence];
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
