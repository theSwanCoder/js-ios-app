//
//  JMReportViewerViewController.m
//  JasperMobile
//
//  Created by Vlad Zavadsky on 5/23/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

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
@property (nonatomic, weak) JMReportViewerToolBar *toolbar;

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

    __weak typeof(self) weakSelf = self;
    if (![JMRequestDelegate isRequestPoolEmpty]) {
        [JMCancelRequestPopup presentInViewController:self message:@"status.loading" restClient:self.resourceClient cancelBlock:^{
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id destinationViewController = segue.destinationViewController;
    [destinationViewController setResourceLookup:self.resourceLookup];
    [destinationViewController setInputControls:[[NSMutableArray alloc] initWithArray:self.inputControls copyItems:YES]];
    [destinationViewController performSelector:@selector(setDelegate:) withObject:self];
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

    __weak typeof(self) weakSelf = self;
    JMRequestDelegate *delegate = [JMRequestDelegate requestDelegateForFinishBlock:^(JSOperationResult *result) {
        JSReportExecutionResponse *response = [result.objects objectAtIndex:0];
        JSExportExecution *export = [response.exports objectAtIndex:0];
        weakSelf.exportId = export.uuid;
        weakSelf.requestId = response.requestId;
        
        weakSelf.toolbar.countOfPages = [response.totalPages integerValue];
        [weakSelf displayCurrentPageOfReport];
        [weakSelf.navigationController setToolbarHidden:!(self.toolbar.countOfPages > 1) animated:YES];
    } errorBlock: nil
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
