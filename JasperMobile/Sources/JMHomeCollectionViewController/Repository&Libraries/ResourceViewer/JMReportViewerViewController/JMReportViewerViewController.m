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
#import "JMReportViewerToolBar.h"
#import "UIViewController+FetchInputControls.h"
#import "UIAlertView+LocalizedAlert.h"
#import "JMSaveReportViewController.h"
#import "ALToastView.h"

@interface JMReportViewerViewController () <JMReportViewerToolBarDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) NSUndoManager *icUndoManager;
@property (nonatomic, strong) JMReportViewerToolBar *toolbar;

@property (nonatomic, weak) JSConstants *constants;

@property (nonatomic, strong) NSString *requestId;
@property (nonatomic, strong) NSString *exportId;
@end

@implementation JMReportViewerViewController
objection_requires(@"reportClient", @"constants")

@synthesize reportClient    = _reportClient;

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackButton];
    self.icUndoManager = [NSUndoManager new];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self.navigationController setToolbarHidden:!(self.toolbar.countOfPages > 1) animated:YES];

    if (![JMRequestDelegate isRequestPoolEmpty]) {
        [JMCancelRequestPopup presentInViewController:self message:@"status.loading" restClient:self.resourceClient cancelBlock:@weakself(^(void)) {
            [self.navigationController popViewControllerAnimated:YES];
        } @weakselfend ];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:YES animated:YES];
    [self.toolbar removeFromSuperview];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    if ([segue.identifier isEqualToString:kJMShowReportOptionsSegue] || [segue.identifier isEqualToString:kJMSaveReportViewControllerSegue]) {
        id destinationViewController = segue.destinationViewController;
        [destinationViewController setInputControls:[[NSMutableArray alloc] initWithArray:self.inputControls copyItems:YES]];
        [destinationViewController performSelector:@selector(setDelegate:) withObject:self];
    }
}

- (JMResourceViewerAction)availableAction
{
    JMResourceViewerAction availableAction = [super availableAction] | JMResourceViewerAction_Save | JMResourceViewerAction_Refresh;
    if (self.inputControls && [self.inputControls count]) {
        availableAction |= JMResourceViewerAction_Filter;
    }
    return availableAction;
}

- (void)setInputControls:(NSMutableArray *)inputControls
{
    if (self.inputControls != inputControls) {
        if (self.inputControls) {
            [[self.icUndoManager prepareWithInvocationTarget:self] setInputControls:self.inputControls];
            [self.icUndoManager setActionName:@"ResetChanges"];
        }
        [super setInputControls:inputControls];
    }
}

#pragma mark - Actions
- (void) backButtonTapped:(id) sender
{
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

- (void) addBackButton
{
    if (self.inputControls && self.inputControls.count) {
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
    self.toolbar.currentPage = 1;
    
    if (self.request) {
        [JMCancelRequestPopup presentInViewController:self message:@"status.loading" restClient:self.resourceClient cancelBlock:nil];
    }

    JMRequestDelegate *delegate = [JMRequestDelegate requestDelegateForFinishBlock:@weakself(^(JSOperationResult *result)) {
        JSReportExecutionResponse *response = [result.objects objectAtIndex:0];
        JSExportExecution *export = [response.exports objectAtIndex:0];
        self.exportId = export.uuid;
        self.requestId = response.requestId;
        
        self.toolbar.countOfPages = [response.totalPages integerValue];
        [self displayCurrentPageOfReport];
        [self.navigationController setToolbarHidden:!(self.toolbar.countOfPages > 1) animated:YES];
    } @weakselfend
      errorBlock: nil
      viewControllerToDismiss:(!self.requestId) ? self : nil];
    
    NSMutableArray *parameters = [NSMutableArray array];
    for (JSInputControlDescriptor *inputControlDescriptor in self.inputControls) {
        JSReportParameter *reportParameter = [[JSReportParameter alloc] initWithName:inputControlDescriptor.uuid
                                                                               value:inputControlDescriptor.selectedValues];
        [parameters addObject:reportParameter];
    }
    [self.reportClient runReportExecution:self.resourceLookup.uri async:NO outputFormat:self.constants.CONTENT_TYPE_HTML
                              interactive:YES freshData:YES saveDataSnapshot:NO ignorePagination:NO transformerKey:nil
                                    pages:nil attachmentsPrefix:nil parameters:parameters delegate:delegate];
}

- (void) displayCurrentPageOfReport
{
    if (self.toolbar.countOfPages) {
        NSString *fullExportId = [NSString stringWithFormat:@"%@;pages=%ld", self.exportId, (long)self.toolbar.currentPage];
        NSString *reportUrl = [self.reportClient generateReportOutputUrl:self.requestId exportOutput:fullExportId];
        
        self.request = [NSURLRequest requestWithURL:[NSURL URLWithString:reportUrl]];
    } else {
        UIAlertView *alertView = [UIAlertView localizedAlertWithTitle:@"detail.report.viewer.emptyreport.title" message:nil delegate:nil cancelButtonTitle:@"dialog.button.ok" otherButtonTitles: nil];
        if ([self.icUndoManager canUndo]) {
            alertView.delegate = self;
            alertView.message = JMCustomLocalizedString(@"detail.report.viewer.emptyreport.message", nil);
            [alertView addButtonWithTitle:JMCustomLocalizedString(@"dialog.button.cancel", nil)];
        }
        [alertView show];
    }
}

- (JMReportViewerToolBar *)toolbar
{
    if (!_toolbar) {
        _toolbar = [[[NSBundle mainBundle] loadNibNamed:@"JMReportViewerToolBar" owner:self options:nil] firstObject];
        _toolbar.toolbarDelegate = self;
    }
    if (!_toolbar.superview) {
        _toolbar.frame = self.navigationController.toolbar.bounds;
        [self.navigationController.toolbar addSubview: _toolbar];
    }
    return _toolbar;
}

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

#pragma mark - JMReportViewerToolBarDelegate
- (void)pageDidChangedOnToolbar
{
    [self displayCurrentPageOfReport];
}

#pragma mark - JMRefreshable

- (void)refresh
{
    [self.navigationController popToViewController:self animated:YES];
    [self runReportExecution];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.cancelButtonIndex == buttonIndex) {
        [self performSegueWithIdentifier:kJMShowReportOptionsSegue sender:nil];
    }
    [self.icUndoManager undo];
    [self.icUndoManager removeAllActionsWithTarget:self];
}

@end
