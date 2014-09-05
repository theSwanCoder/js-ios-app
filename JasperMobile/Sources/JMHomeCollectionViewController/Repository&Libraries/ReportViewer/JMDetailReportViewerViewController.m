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
#import "JMReportViewerToolBar.h"
#import "UIViewController+FetchInputControls.h"
#import "ALToastView.h"

@interface JMDetailReportViewerViewController () <UIWebViewDelegate, JMReportViewerToolBarDelegate>
@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, weak) JMReportViewerToolBar *toolbar;

@property (nonatomic, assign) BOOL isRequestLoaded;

@property (nonatomic, weak) JSConstants *constants;
@property (nonatomic, strong) NSURLRequest *request;

@property (nonatomic, strong) NSString *requestId;
@property (nonatomic, strong) NSString *exportId;
@end


@implementation JMDetailReportViewerViewController
objection_requires(@"resourceClient", @"reportClient", @"resourceLookup",  @"constants")

@synthesize resourceClient = _resourceClient;
@synthesize reportClient   = _reportClient;
@synthesize resourceLookup = _resourceLookup;

#pragma mark - Initialization

- (void)awakeFromNib
{
    [super awakeFromNib];
    [[JSObjection defaultInjector] injectDependencies:self];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.webView.scrollView.bounces = NO;
    self.webView.delegate = self;
    self.webView.suppressesIncrementalRendering = YES;
    [self.webView loadHTMLString:@"" baseURL:nil];

    self.title = self.resourceLookup.label;
    UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"refresh_item.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(refreshButtonTapped:)];
    NSMutableArray *itemsArray = [NSMutableArray arrayWithObject:refreshItem];
    if (self.inputControls && [self.inputControls count]) {
        UIBarButtonItem *editItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"filter_item.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(editButtonTapped:)];
        [itemsArray addObject:editItem];
    }
    self.navigationItem.rightBarButtonItems = itemsArray;
    
    [self addBackButton];
    
    [self runReportExecution];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.isRequestLoaded && self.request) {
        [self.webView loadRequest:self.request];
    }
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
    if (self.webView.loading) {
        [self.webView stopLoading];
        [self loadingDidFinished];
    }
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id destinationViewController = segue.destinationViewController;
    [destinationViewController setInputControls:[[NSMutableArray alloc] initWithArray:self.inputControls copyItems:YES]];
    [destinationViewController setResourceLookup:self.resourceLookup];
    [destinationViewController setDelegate:self];
}

#pragma mark - Actions

- (void)refreshButtonTapped:(id) sender
{
    [JMCancelRequestPopup presentInViewController:self message:@"status.loading" restClient:self.resourceClient cancelBlock:nil];
    [self runReportExecution];
}

- (void) editButtonTapped:(id) sender
{
    [self performSegueWithIdentifier:kJMShowReportOptionsSegue sender:nil];
}

- (void) backButtonTapped:(id) sender
{
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

- (void) addBackButton
{
    NSString *title = [[self.navigationController.viewControllers objectAtIndex:1] title];
    UIImage *backButtonImage = [UIImage imageNamed:@"back_item.png"];
    UIImage *resizebleBackButtonImage = [backButtonImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, backButtonImage.size.width, 0, backButtonImage.size.width) resizingMode:UIImageResizingModeStretch];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleBordered target:self action:@selector(backButtonTapped:)];
    [backItem setBackgroundImage:resizebleBackButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    self.navigationItem.leftBarButtonItem = backItem;
}

- (void)setRequest:(NSURLRequest *)request
{
    if (request != _request) {
        _request = request;
        if (self.webView.isLoading) {
            [self.webView stopLoading];
        }
        [self.webView loadRequest:request];
        self.isRequestLoaded = NO;
    }
}

- (void) runReportExecution
{
    self.toolbar.currentPage = 1;
    
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
        NSString *fullExportId = [NSString stringWithFormat:@"%@;pages=%i", self.exportId, self.toolbar.currentPage];
        NSString *reportUrl = [self.reportClient generateReportOutputUrl:self.requestId exportOutput:fullExportId];
        
        self.request = [NSURLRequest requestWithURL:[NSURL URLWithString:reportUrl]];
    } else {
        [ALToastView toastInView:self.view withText:JMCustomLocalizedString(@"detail.report.viewer.emptyreport.message", nil)];
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

#pragma mark - JMReportViewerToolBarDelegate
- (void)pageDidChangedOnToolbar
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

#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.activityIndicator startAnimating];
    [JMUtils showNetworkActivityIndicator];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self loadingDidFinished];
    if (self.request) {
        self.isRequestLoaded = YES;
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self loadingDidFinished];
    self.isRequestLoaded = NO;
}

- (void)loadingDidFinished
{
    [JMUtils hideNetworkActivityIndicator];
    [self.activityIndicator stopAnimating];
}
@end
