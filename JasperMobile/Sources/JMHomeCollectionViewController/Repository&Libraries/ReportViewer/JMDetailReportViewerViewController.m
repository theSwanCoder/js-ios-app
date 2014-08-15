//
//  JMDetailReportViewerViewController.m
//  JasperMobile
//
//  Created by Vlad Zavadsky on 5/23/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import "JMDetailReportViewerViewController.h"
#import "JMConstants.h"
#import <Objection-iOS/Objection.h>
#import "JMRequestDelegate.h"
#import "JMCancelRequestPopup.h"
#import "JMDetailReportViewerActionBarView.h"
#import "UIViewController+FetchInputControls.h"
#import "JMFullScreenButtonProvider.h"
#import "ALToastView.h"

@interface JMDetailReportViewerViewController () <JMBaseActionBarViewDelegate, JMFullScreenButtonProvider>

@property (nonatomic, weak) JSConstants *constants;
@property (nonatomic, strong) JMDetailReportViewerActionBarView *actionBarView;

@property (nonatomic, strong) NSString *requestId;
@property (nonatomic, strong) NSString *exportId;
@end


@implementation JMDetailReportViewerViewController
objection_requires(@"resourceClient", @"reportClient", @"resourceLookup",  @"constants")
inject_default_rotation()

@synthesize resourceClient = _resourceClient;
@synthesize reportClient   = _reportClient;
@synthesize resourceLookup = _resourceLookup;
@synthesize inputControls  = _inputControls; // A mutable array of "JSInputControlDescriptor" objects

#pragma mark - Initialization

- (void)awakeFromNib
{
    [super awakeFromNib];
    [[JSObjection defaultInjector] injectDependencies:self];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = self.resourceLookup.label;
    UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"refresh_item.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(refreshButtonTapped:)];
    NSMutableArray *itemsArray = [NSMutableArray arrayWithObject:refreshItem];
    if (self.inputControls && [self.inputControls count]) {
        UIBarButtonItem *editItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"filter_item.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(editButtonTapped:)];
        [itemsArray addObject:editItem];
    }
    self.navigationItem.rightBarButtonItems = itemsArray;
    
    [self runReportExecution];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    __weak typeof(self) weakSelf = self;
    if (![JMRequestDelegate isRequestPoolEmpty]) {
        [JMCancelRequestPopup presentInViewController:self message:@"status.loading" restClient:self.resourceClient cancelBlock:^{
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }];
    }
}

- (void) runReportExecution
{
    self.actionBarView.currentPage = 1;
    
    __weak typeof(self) weakSelf = self;
    JMRequestDelegate *delegate = [JMRequestDelegate requestDelegateForFinishBlock:^(JSOperationResult *result) {
        JSReportExecutionResponse *response = [result.objects objectAtIndex:0];
        JSExportExecution *export = [response.exports objectAtIndex:0];
        weakSelf.exportId = export.uuid;
        weakSelf.requestId = response.requestId;
        
        weakSelf.actionBarView.countOfPages = [response.totalPages integerValue];
        [weakSelf displayCurrentPageOfReport];
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
    if (self.actionBarView.countOfPages) {
        NSString *fullExportId = [NSString stringWithFormat:@"%@;pages=%i", self.exportId, self.actionBarView.currentPage];
        NSString *reportUrl = [self.reportClient generateReportOutputUrl:self.requestId exportOutput:fullExportId];
        
        self.request = [NSURLRequest requestWithURL:[NSURL URLWithString:reportUrl]];
    } else {
        [ALToastView toastInView:self.view withText:JMCustomLocalizedString(@"detail.report.viewer.emptyreport.message", nil)];
    }
}

- (void)refreshButtonTapped:(id) sender
{
    [JMCancelRequestPopup presentInViewController:self message:@"status.loading" restClient:self.resourceClient cancelBlock:nil];
    [self runReportExecution];
}

- (void) editButtonTapped:(id) sender{
    [self performSegueWithIdentifier:kJMShowReportOptionsSegue sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id destinationViewController = segue.destinationViewController;
    [destinationViewController setInputControls:[self.inputControls mutableCopy]];
    [destinationViewController setResourceLookup:self.resourceLookup];
    [destinationViewController setDelegate:self];
}


#pragma mark - JMActionBarProvider

- (id)actionBar
{
    if (!self.actionBarView) {
        self.actionBarView = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([JMDetailReportViewerActionBarView class])
                                                           owner:self
                                                         options:nil].firstObject;
        self.actionBarView.delegate = self;
    }
    
    return self.actionBarView;
}

#pragma mark - JMBaseActionBarViewDelegate
- (void)actionView:(JMBaseActionBarView *)actionView didSelectAction:(JMBaseActionBarViewAction)action
{
    [self displayCurrentPageOfReport];
}

#pragma mark - JMFullScreenButtonProvider
- (BOOL)shouldDisplayFullScreenButton
{
    return YES;
}


#pragma mark - JMRefreshable

- (void)refresh
{
    [self.navigationController popToViewController:self animated:YES];
    [self runReportExecution];
}

@end
