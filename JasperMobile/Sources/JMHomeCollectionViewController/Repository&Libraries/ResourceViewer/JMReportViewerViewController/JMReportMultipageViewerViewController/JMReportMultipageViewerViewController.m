//
//  JMReportMultipageViewerViewController.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 1/25/15.
//  Copyright (c) 2015 TIBCO JasperMobile. All rights reserved.
//

#import "JMReportMultipageViewerViewController.h"
#import "JMReportPageViewerViewController.h"
#import "JMReportViewer.h"
#import "JMReportViewerPaginationToolbar.h"
#import "JMResourcesCollectionViewController.h"
#import "JMReportLoader.h"
#import "JMSaveReportViewController.h"
#import "UIViewController+FetchInputControls.h"
#import "JMCancelRequestPopup.h"

@interface JMReportMultipageViewerViewController() <JMReportViewerPaginationToolbarDelegate, JMReportLoaderDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate>
@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic, assign) NSInteger countOfPages;
@property (nonatomic, strong) JMReportLoader *reportLoader;
@property (nonatomic, weak) JMReportViewerPaginationToolbar *toolbar;
@property (nonatomic, assign) NSInteger currentPage;
@end

@implementation JMReportMultipageViewerViewController

#pragma mark - Lifecycle
-(void)dealloc
{
    [_toolbar removeFromSuperview];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // setups
    [self addBackButton];
    self.countOfPages = 1;
    self.currentPage = 1;
    
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    
    JMReportPageViewerViewController *startingViewController = (JMReportPageViewerViewController *)[self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateToolbarAppearence];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    if ([segue.identifier isEqualToString:kJMShowReportOptionsSegue] || [segue.identifier isEqualToString:kJMSaveReportViewControllerSegue]) {
        id destinationViewController = segue.destinationViewController;
        [destinationViewController setInputControls:[[NSMutableArray alloc] initWithArray:self.reportLoader.inputControls copyItems:YES]];
        [destinationViewController performSelector:@selector(setDelegate:) withObject:self];
        
        if ([segue.identifier isEqualToString:kJMSaveReportViewControllerSegue]) {
            ((JMSaveReportViewController *)destinationViewController).reportLoader = self.reportLoader;
        }
    }
}

#pragma mark - Actions
- (void) backButtonTapped:(id) sender
{
    [self cancelReport];
}

#pragma mark - Public API
- (void)setInputControls:(NSMutableArray *)inputControls
{
    self.reportLoader.inputControls = inputControls;
}

#pragma mark - Properties
- (JMReportLoader *)reportLoader
{
    if (!_reportLoader) {
        _reportLoader = [[JMReportLoader alloc] initWithResourceLookup:self.resourceLookup];
        _reportLoader.delegate = self;
    }
    return _reportLoader;
}

- (JMReportViewerPaginationToolbar *)toolbar
{
    if (!_toolbar) {
        _toolbar = [[[NSBundle mainBundle] loadNibNamed:@"JMReportViewerPaginationToolbar" owner:self options:nil] firstObject];
        _toolbar.toolBarDelegate = self;
        _toolbar.currentPage = self.reportLoader.currentPage;
        _toolbar.countOfPages = self.reportLoader.countOfPages;
        [self.navigationController.toolbar addSubview:_toolbar];
        _toolbar.frame = self.navigationController.toolbar.bounds;
    }
    return _toolbar;
}


#pragma mark - Run Report
- (void) runReportExecution
{
    [self.reportLoader runReportExecution];
}

#pragma mark - Private Methods
- (JMReportPageViewerViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if ( index > self.countOfPages ) {
        return nil;
    }
    
    JMReportPageViewerViewController *reportPageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"JMReportPageViewerViewController"];
    reportPageViewController.pageIndex = index;
    
    return reportPageViewController;
}

- (void) updateToolbarAppearence
{
    BOOL isToolbarHidden = YES;
    if (self.reportLoader.isMultiPageReport && self.toolbar) {
        isToolbarHidden = NO;
    }
    
    if (self.navigationController.toolbarHidden != isToolbarHidden) {
        [self.navigationController setToolbarHidden:isToolbarHidden
                                           animated:YES];
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

- (JMMenuActionsViewAction)availableAction
{
    JMMenuActionsViewAction availableAction = [super availableAction] | JMMenuActionsViewAction_Save | JMMenuActionsViewAction_Refresh;
    if (self.reportLoader.inputControls && [self.reportLoader.inputControls count]) {
        availableAction |= JMMenuActionsViewAction_Filter;
    }
    return availableAction;
}

- (void)startShowLoaderWithMessage:(NSString *)message
{
    [JMUtils showNetworkActivityIndicator];
    [JMCancelRequestPopup presentWithMessage:message
                                  restClient:self.reportLoader.resourceClient
                                 cancelBlock:@weakself(^(void)) {
                                     [self.reportLoader cancelReport];
                                     
                                     [self cancelReport];
                                 }@weakselfend];
}

- (void)stopShowLoader
{
    [JMUtils hideNetworkActivityIndicator];
    [JMCancelRequestPopup dismiss];
}

- (void)cancelReport
{
    [self.view endEditing:YES];
    NSInteger currentIndex = [self.navigationController.viewControllers indexOfObject:self];
    for (NSInteger i = currentIndex; i > 0; --i) {
        UIViewController *controller = [self.navigationController.viewControllers objectAtIndex:i];
        if ([controller isKindOfClass:[JMResourcesCollectionViewController class]]) {
            [self.navigationController popToViewController:controller animated:YES];
            break;
        }
    }
}

#pragma mark - UIPageViewControllerDataSource
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((JMReportPageViewerViewController *)viewController).pageIndex;
    if (index == 0 || index == NSNotFound) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((JMReportPageViewerViewController *) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == self.countOfPages) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

#pragma mark - UIPageViewControllerDelegate
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers
{
    JMReportPageViewerViewController *nextReportPageViewController = (JMReportPageViewerViewController *)pendingViewControllers.firstObject;
    if ( fabs(self.currentPage -  nextReportPageViewController.pageIndex) > 2) {
        if (self.currentPage > nextReportPageViewController.pageIndex) {
            nextReportPageViewController.pageIndex = self.currentPage - 1;
        } else {
            nextReportPageViewController.pageIndex = self.currentPage + 1;
        }
        [nextReportPageViewController startLoadReportPageContentWithLoader:self.reportLoader];
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray *)previousViewControllers
       transitionCompleted:(BOOL)completed
{
    if (completed) {
        JMReportPageViewerViewController *reportPageViewController = (JMReportPageViewerViewController *)pageViewController.viewControllers.firstObject;
        [reportPageViewController startLoadReportPageContentWithLoader:self.reportLoader];
        self.currentPage = reportPageViewController.pageIndex;
        [self.toolbar updateCurrentPageWithPageNumber:(self.currentPage + 1)];
    }
}

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

#pragma mark - JMRefreshable
- (void)refresh
{
    [self.navigationController popToViewController:self animated:YES];
    [self runReportExecution];
}

#pragma mark - JMReportLoaderDelegate
-(void)reportLoaderDidRunReportExecution:(JMReportLoader *)reportLoader
{
    [self startShowLoaderWithMessage:@"Report Running..."];
}

-(void)reportLoaderDidEndReportExecution:(JMReportLoader *)reportLoader
{
    [self stopShowLoader];
    JMReportPageViewerViewController *reportPageViewController = self.pageViewController.viewControllers[self.currentPage-1];
    [reportPageViewController startLoadReportPageContentWithLoader:self.reportLoader];
}

- (void)reportLoaderDidEndWithEmptyReport:(JMReportLoader *)reportLoader
{
    [self stopShowLoader];
}

-(void)reportLoaderDidBeginExportExecution:(JMReportLoader *)reportLoader forPageNumber:(NSInteger)pageNumber
{
    if (!self.reportLoader.isMultiPageReport) {
        [self startShowLoaderWithMessage:@"Export Execution..."];
    }
}

-(void)reportLoaderDidEndExportExecution:(JMReportLoader *)loader forPageNumber:(NSInteger)pageNumber
{
    [self stopShowLoader];
}

-(void)reportLoaderDidBeginLoadOutputResources:(JMReportLoader *)reportLoader forPageNumber:(NSInteger)pageNumber
{
    if (!self.reportLoader.isMultiPageReport) {
        [self startShowLoaderWithMessage:@"Getting Resources..."];
    }
}

-(void)reportLoaderDidEndLoadOutputResources:(JMReportLoader *)reportLoader forPageNumber:(NSInteger)pageNumber
{
    [self stopShowLoader];
}

- (void)reportLoader:(JMReportLoader *)reportLoader didReceiveCountOfPages:(NSUInteger)countOfPages
{
    self.countOfPages = reportLoader.countOfPages;
}

- (void)reportLoader:(JMReportLoader *)reportLoader didUpdateIsMultipageReportValue:(BOOL)isMultipageReport
{
    [self updateToolbarAppearence];
}

#pragma mark - JMReportViewerPaginationToolbarDelegate
- (void)reportViewerPaginationToolbar:(JMReportViewerPaginationToolbar *)toolbar didChangePage:(NSUInteger)page
{
    if ((page - 1) == self.currentPage) {
        return;
    }
    
    UIPageViewControllerNavigationDirection direction = UIPageViewControllerNavigationDirectionForward;
    if ( (page - 1) < self.currentPage) {
        direction = UIPageViewControllerNavigationDirectionReverse;
    }
    
    self.currentPage = page - 1;
    JMReportPageViewerViewController *reportPageViewController = [self viewControllerAtIndex:self.currentPage];
    [self.pageViewController setViewControllers:@[reportPageViewController]
                                      direction:direction
                                       animated:YES
                                     completion:@weakself(^(BOOL finished)) {
                                         [reportPageViewController startLoadReportPageContentWithLoader:self.reportLoader];
                                     }@weakselfend];
}

@end
